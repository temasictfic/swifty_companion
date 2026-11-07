import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttery_mate/src/core/services/api_service.dart';
import 'package:fluttery_mate/src/core/services/auth_service.dart';
import 'package:fluttery_mate/src/core/services/rate_limiter.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({'is_configured': true});
    FlutterSecureStorage.setMockInitialValues({
      'client_id': 'test-client-id',
      'client_secret': 'test-client-secret',
    });
  });

  test('RateLimiter allows 2 requests per window', () async {
    final limiter = RateLimiter(window: const Duration(milliseconds: 200));
    final sw = Stopwatch()..start();
    await Future.wait([limiter.acquire(), limiter.acquire()]);
    expect(sw.elapsedMilliseconds, lessThan(100));
    await limiter.acquire();
    expect(sw.elapsedMilliseconds, greaterThanOrEqualTo(190));
  });

  test(
    'concurrent requests share one token fetch, retry 401 and 429',
    () async {
      var tokenCalls = 0;
      var userCalls = 0;
      final client = MockClient((request) async {
        if (request.url.path == '/oauth/token') {
          tokenCalls++;
          return http.Response(
            jsonEncode({
              'access_token': 'token$tokenCalls',
              'expires_in': 7200,
            }),
            200,
          );
        }
        if (request.url.path == '/v2/users/jdoe') {
          userCalls++;
          if (userCalls == 1) return http.Response('', 401);
          if (userCalls == 2) {
            return http.Response('', 429, headers: {'retry-after': '1'});
          }
          return http.Response(
            jsonEncode({
              'login': 'jdoe',
              'projects_users': [
                {
                  'project': {'name': 'libft'},
                  'status': 'finished',
                  'validated?': true,
                  'final_mark': 125,
                  'created_at': '2024-01-01T00:00:00Z',
                },
              ],
            }),
            200,
          );
        }
        if (request.url.path == '/v2/users/jdoe/coalitions') {
          return http.Response(
            jsonEncode([
              {
                'id': 7,
                'name': 'Piscine',
                'slug': 'piscine-x',
                'cover_url': '',
              },
              {
                'id': 3,
                'name': 'Order',
                'slug': 'order',
                'cover_url': 'c.jpg',
                'color': '#ff0000',
              },
            ]),
            200,
          );
        }
        if (request.url.path == '/v2/users/jdoe/coalitions_users') {
          return http.Response(
            jsonEncode([
              {
                'id': 1,
                'coalition_id': 7,
                'score': 9000,
                'rank': 1,
                'user_id': 1,
              },
              {
                'id': 2,
                'coalition_id': 3,
                'score': 120,
                'rank': 42,
                'user_id': 1,
              },
            ]),
            200,
          );
        }
        return http.Response('', 404);
      });

      final api = ApiService(
        client: client,
        auth: AuthService(client: client),
      );

      final (user, info) = await (
        api.getUserDetails('jdoe'),
        api.getCoalitionInfo('jdoe'),
      ).wait;

      expect(user.login, 'jdoe');
      expect(user.projects.single.name, 'libft');
      // One initial token, one refresh after the 401.
      expect(tokenCalls, 2);
      expect(info.coalition?.name, 'Order');
      // Score/rank comes from the *same* coalition, not the highest score.
      expect(info.membership?.rank, 42);

      // Cached: no extra request.
      await api.getUserDetails('jdoe');
      expect(userCalls, 3);
    },
  );

  test('missing user throws a 404 ApiException', () async {
    final client = MockClient((request) async {
      if (request.url.path == '/oauth/token') {
        return http.Response(
          jsonEncode({'access_token': 't', 'expires_in': 7200}),
          200,
        );
      }
      return http.Response('', 404);
    });
    final api = ApiService(
      client: client,
      auth: AuthService(client: client),
    );
    expect(
      api.getUserDetails('nobody'),
      throwsA(
        isA<ApiException>().having((e) => e.statusCode, 'statusCode', 404),
      ),
    );
  });
}
