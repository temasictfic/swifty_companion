import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/coalition_model.dart';
import '../models/coalition_user_model.dart';
import '../models/json_utils.dart';
import '../models/user_model.dart';
import 'auth_service.dart';
import 'rate_limiter.dart';

/// Coalition info shown on a profile; either part may be missing.
typedef CoalitionInfo = ({
  CoalitionModel? coalition,
  CoalitionUserModel? membership,
});

/// Client for the 42 intra API (v2).
///
/// Performance notes:
/// * One shared [http.Client] keeps TLS connections alive between requests
///   (the old code opened a fresh connection — and TLS handshake — per call).
/// * Requests are rate limited to the API's 2 req/s, and 429s are retried.
/// * Large responses (full user profiles) are decoded off the UI isolate.
/// * Results are cached for a few minutes, so reopening a profile is instant.
class ApiService {
  ApiService({required this._client, required this._auth});

  static const String _host = 'api.intra.42.fr';
  static const Duration _timeout = Duration(seconds: 20);
  static const Duration _cacheTtl = Duration(minutes: 5);
  static const int _maxCacheEntries = 30;

  /// Responses bigger than this are parsed in a background isolate.
  static const int _isolateThreshold = 48 * 1024;

  final http.Client _client;
  final AuthService _auth;
  final RateLimiter _limiter = RateLimiter();

  /// Insertion-ordered (Dart map literals are LinkedHashMaps), used as an LRU.
  final _cache = <String, ({DateTime at, Object? value})>{};
  final _inFlight = <String, Future<Object?>>{};

  /// Searches users whose login matches [query] (first 20 results).
  Future<List<UserModel>> searchUsers(String query) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    final users = await _cached<List<UserModel>>(
      'search:$q',
      () => _get('/v2/users', {
        'search[login]': '$q%',
        'page[size]': '20',
      }, _parseUserList),
    );
    // Exact match first, then logins starting with the query, then the rest.
    int rank(UserModel u) => u.login == q ? 0 : (u.login.startsWith(q) ? 1 : 2);
    return [...users]..sort((a, b) {
      final byRank = rank(a).compareTo(rank(b));
      return byRank != 0 ? byRank : a.login.compareTo(b.login);
    });
  }

  /// Full profile, including projects, skills and achievements (one request).
  Future<UserModel> getUserDetails(String login, {bool forceRefresh = false}) {
    return _cached<UserModel>(
      'user:$login',
      () => _get('/v2/users/${Uri.encodeComponent(login)}', null, _parseUser),
      forceRefresh: forceRefresh,
    );
  }

  /// The user's active coalition plus their score/rank in *that* coalition.
  Future<CoalitionInfo> getCoalitionInfo(
    String login, {
    bool forceRefresh = false,
  }) {
    return _cached<CoalitionInfo>('coalition:$login', () async {
      final encoded = Uri.encodeComponent(login);
      final results = await Future.wait([
        _get('/v2/users/$encoded/coalitions', null, asMapList),
        _get(
          '/v2/users/$encoded/coalitions_users',
          null,
          asMapList,
        ).catchError((Object _) => const <Map<String, dynamic>>[]),
      ]);
      final coalition = _pickCoalition(results[0]);
      return (
        coalition: coalition,
        membership: _pickMembership(results[1], coalition?.id),
      );
    }, forceRefresh: forceRefresh);
  }

  /// Drops cached data, e.g. after the credentials change.
  void clearCache() {
    _cache.clear();
    _inFlight.clear();
  }

  void dispose() => _client.close();

  // ---------------------------------------------------------------------------

  static CoalitionModel? _pickCoalition(List<Map<String, dynamic>> coalitions) {
    if (coalitions.isEmpty) return null;
    bool hasCover(Map<String, dynamic> c) =>
        asString(c['cover_url']).isNotEmpty;
    String slug(Map<String, dynamic> c) => asString(c['slug']);

    final chosen = coalitions.firstWhere(
      (c) =>
          hasCover(c) &&
          (slug(c).contains('42') || !slug(c).contains('piscine')),
      orElse: () =>
          coalitions.firstWhere(hasCover, orElse: () => coalitions.last),
    );
    return CoalitionModel.fromJson(chosen);
  }

  static CoalitionUserModel? _pickMembership(
    List<Map<String, dynamic>> memberships,
    int? coalitionId,
  ) {
    if (memberships.isEmpty) return null;
    final models = memberships.map(CoalitionUserModel.fromJson).toList();
    for (final m in models) {
      if (m.coalitionId == coalitionId) return m;
    }
    models.sort((a, b) => b.score.compareTo(a.score));
    return models.first;
  }

  Future<T> _cached<T>(
    String key,
    Future<T> Function() fetch, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final hit = _cache[key];
      if (hit != null && DateTime.now().difference(hit.at) < _cacheTtl) {
        // Re-insert to mark as most recently used.
        _cache
          ..remove(key)
          ..[key] = hit;
        return hit.value as T;
      }
      final pending = _inFlight[key];
      if (pending != null) return await pending as T;
    }

    final future = fetch();
    _inFlight[key] = future;
    try {
      final value = await future;
      _cache
        ..remove(key)
        ..[key] = (at: DateTime.now(), value: value);
      while (_cache.length > _maxCacheEntries) {
        _cache.remove(_cache.keys.first);
      }
      return value;
    } finally {
      if (identical(_inFlight[key], future)) _inFlight.remove(key);
    }
  }

  Future<T> _get<T>(
    String path,
    Map<String, String>? query,
    T Function(Object? json) parse,
  ) async {
    final uri = Uri.https(_host, path, query);
    var token = await _auth.getAccessToken();
    var refreshedToken = false;

    for (var attempt = 0; ; attempt++) {
      await _limiter.acquire();
      final http.Response response;
      try {
        response = await _client
            .get(
              uri,
              headers: {
                'Authorization': 'Bearer $token',
                'Accept': 'application/json',
              },
            )
            .timeout(_timeout);
      } on TimeoutException {
        throw const ApiException(
          'The request timed out. Check your connection.',
        );
      } on http.ClientException catch (e) {
        throw ApiException('Network error: ${e.message}');
      }

      switch (response.statusCode) {
        case 200:
          return _decode(response.body, parse);
        case 401 when !refreshedToken:
          token = await _auth.refreshToken();
          refreshedToken = true;
        case 429 when attempt < 3:
          final retryAfter =
              int.tryParse(response.headers['retry-after'] ?? '') ?? 1;
          await Future<void>.delayed(Duration(seconds: retryAfter.clamp(1, 5)));
        case 404:
          throw const ApiException('Not found', statusCode: 404);
        default:
          throw ApiException(
            'Request failed (HTTP ${response.statusCode})',
            statusCode: response.statusCode,
          );
      }
    }
  }

  static Future<T> _decode<T>(String body, T Function(Object? json) parse) {
    if (body.length < _isolateThreshold) {
      return Future.value(parse(json.decode(body)));
    }
    return compute(_DecodeJob<T>(parse).call, body);
  }

  static List<UserModel> _parseUserList(Object? json) =>
      asMapList(json)
          .map(UserModel.fromJson)
          // Same behaviour as before: hide accounts without a photo (mostly
          // system / test accounts).
          .where((u) => u.login.isNotEmpty && u.imageUrl != null)
          .toList(growable: false);

  static UserModel _parseUser(Object? json) =>
      UserModel.fromJson(json as Map<String, dynamic>);
}

/// Top-level-safe callable so `compute` can send it to the worker isolate.
class _DecodeJob<T> {
  const _DecodeJob(this.parse);
  final T Function(Object? json) parse;
  T call(String body) => parse(json.decode(body));
}

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}
