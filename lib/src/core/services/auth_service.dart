import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'settings_service.dart';

/// Obtains and caches 42 API access tokens (OAuth client-credentials flow).
class AuthService {
  AuthService({required this._client, SettingsService? settings})
    : _settings = settings ?? SettingsService();

  static const String _tokenKey = 'access_token';
  static const String _tokenExpiryKey = 'token_expiry';
  static final Uri _tokenUri = Uri.parse('https://api.intra.42.fr/oauth/token');
  static const Duration _timeout = Duration(seconds: 15);

  final http.Client _client;
  final SettingsService _settings;

  String? _cachedToken;
  DateTime? _cachedExpiry;

  /// Shared in-flight token request so concurrent callers don't each fetch one.
  Future<String>? _pendingToken;

  /// Returns a valid token from memory, disk, or the network (in that order).
  Future<String> getAccessToken() async {
    final token = _cachedToken;
    if (token != null && (_cachedExpiry?.isAfter(DateTime.now()) ?? false)) {
      return token;
    }

    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_tokenKey);
    final expiryMillis = prefs.getInt(_tokenExpiryKey);
    if (stored != null && expiryMillis != null) {
      final expiry = DateTime.fromMillisecondsSinceEpoch(expiryMillis);
      if (expiry.isAfter(DateTime.now())) {
        _cachedToken = stored;
        _cachedExpiry = expiry;
        return stored;
      }
    }

    return _fetchNewToken();
  }

  /// Discards the current token and fetches a new one (used after a 401).
  Future<String> refreshToken() async {
    await clearAuth();
    return _fetchNewToken();
  }

  Future<String> _fetchNewToken() {
    return _pendingToken ??= _requestToken().whenComplete(
      () => _pendingToken = null,
    );
  }

  Future<String> _requestToken() async {
    final credentials = await _settings.getCredentials();
    final clientId = credentials.clientId;
    final clientSecret = credentials.clientSecret;
    if (clientId == null || clientSecret == null) {
      throw const AuthException(
        'No API credentials found. Please configure them in settings.',
      );
    }

    final response = await _postToken(clientId, clientSecret);
    if (response.statusCode != 200) {
      throw AuthException(
        'Failed to obtain access token (HTTP ${response.statusCode})',
      );
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    final token = data['access_token'] as String;
    final expiresIn = (data['expires_in'] as num?)?.toInt() ?? 7200;
    // Refresh a minute early so a token never expires mid-request.
    final expiry = DateTime.now().add(Duration(seconds: expiresIn - 60));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setInt(_tokenExpiryKey, expiry.millisecondsSinceEpoch);

    _cachedToken = token;
    _cachedExpiry = expiry;
    return token;
  }

  Future<http.Response> _postToken(String clientId, String clientSecret) {
    return _client
        .post(
          _tokenUri,
          body: {
            'grant_type': 'client_credentials',
            'client_id': clientId,
            'client_secret': clientSecret,
          },
        )
        .timeout(_timeout);
  }

  /// Clears cached tokens in memory and on disk.
  Future<void> clearAuth() async {
    _cachedToken = null;
    _cachedExpiry = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_tokenExpiryKey);
  }

  /// Returns true if the given credentials can obtain a token.
  Future<bool> validateCredentials(String clientId, String clientSecret) async {
    try {
      final response = await _postToken(clientId, clientSecret);
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}
