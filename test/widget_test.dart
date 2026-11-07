import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttery_mate/src/core/services/api_service.dart';
import 'package:fluttery_mate/src/core/services/auth_service.dart';
import 'package:fluttery_mate/src/features/search/pages/search_page.dart';
import 'package:fluttery_mate/src/shared/widgets/surface_card.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('SurfaceCard renders its child without any blur layer', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SurfaceCard(
            padding: EdgeInsets.all(20),
            child: Text('Test Content'),
          ),
        ),
      ),
    );

    expect(find.text('Test Content'), findsOneWidget);
    // The old glass containers used an expensive BackdropFilter per card.
    expect(find.byType(BackdropFilter), findsNothing);
    final padding = tester.widget<Padding>(
      find.descendant(
        of: find.byType(SurfaceCard),
        matching: find.byType(Padding),
      ),
    );
    expect(padding.padding, const EdgeInsets.all(20));
  });

  testWidgets('SearchScreen searches after typing and shows results', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'is_configured': true});
    FlutterSecureStorage.setMockInitialValues({
      'client_id': 'test-client-id',
      'client_secret': 'test-client-secret',
    });

    final requested = <Uri>[];
    final client = MockClient((request) async {
      requested.add(request.url);
      if (request.url.path == '/oauth/token') {
        return http.Response(
          jsonEncode({'access_token': 'token', 'expires_in': 7200}),
          200,
        );
      }
      if (request.url.path == '/v2/users') {
        return http.Response(
          jsonEncode([
            {
              'login': 'jdoe2',
              'displayname': 'Jane Doe',
              'image': {'link': 'https://example.com/a.jpg'},
            },
            {
              'login': 'jdoe',
              'displayname': 'John Doe',
              'image': {'link': 'https://example.com/b.jpg'},
            },
          ]),
          200,
        );
      }
      return http.Response('not found', 404);
    });
    final auth = AuthService(client: client);

    await tester.pumpWidget(
      Provider<ApiService>(
        create: (_) => ApiService(client: client, auth: auth),
        child: const MaterialApp(home: SearchScreen()),
      ),
    );

    expect(find.text('Start typing to search'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'j');
    await tester.pump();
    expect(find.text('Please enter at least 2 characters'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'jdoe');
    await tester.pump(const Duration(milliseconds: 500)); // debounce
    await tester.pump(const Duration(seconds: 2)); // network + rate limiter
    await tester.pump();

    expect(find.text('John Doe'), findsOneWidget);
    expect(find.text('Jane Doe'), findsOneWidget);
    // Exact login match is listed first.
    expect(
      tester.getTopLeft(find.text('John Doe')).dy,
      lessThan(tester.getTopLeft(find.text('Jane Doe')).dy),
    );

    final search = requested.firstWhere((u) => u.path == '/v2/users');
    expect(search.queryParameters['search[login]'], 'jdoe%');
  });
}
