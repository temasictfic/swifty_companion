import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'src/app.dart';
import 'src/core/services/api_service.dart';
import 'src/core/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configure image cache for better performance
  PaintingBinding.instance.imageCache.maximumSize = 100; // Max number of images
  PaintingBinding.instance.imageCache.maximumSizeBytes = 50 * 1024 * 1024; // 50 MB
  
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => AuthService()),
        Provider(create: (_) => ApiService()),
      ],
      child: const FlutteryMateApp(),
    ),
  );
}
