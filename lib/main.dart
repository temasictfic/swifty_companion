import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import 'src/app.dart';
import 'src/core/services/api_service.dart';
import 'src/core/services/auth_service.dart';
import 'src/core/services/settings_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Keep decoded avatars/covers within a sane budget on 4 GB phones.
  PaintingBinding.instance.imageCache.maximumSizeBytes = 60 << 20; // 60 MB

  // Decide the first screen while the native launch screen is still visible,
  // instead of showing a Flutter splash with an artificial 1 s delay.
  final isConfigured = await SettingsService().isConfigured();

  // One HTTP client for the whole app so connections are reused (keep-alive).
  final client = http.Client();
  final auth = AuthService(client: client);

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>.value(value: auth),
        Provider<ApiService>(
          create: (_) => ApiService(client: client, auth: auth),
          dispose: (_, api) => api.dispose(),
        ),
      ],
      child: FlutteryMateApp(
        initialRoute: isConfigured ? AppRoutes.home : AppRoutes.setup,
      ),
    ),
  );
}
