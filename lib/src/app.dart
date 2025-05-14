import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/themes/app_theme.dart';
import 'features/profile/screens/profile_screen.dart';
import 'features/search/screens/search_screen.dart';

class SwiftyCompanionApp extends StatelessWidget {
  const SwiftyCompanionApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Set system overlay style for modern UI
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    return MaterialApp(
      title: 'Swifty Companion',
      debugShowCheckedModeBanner: false,
      theme: AppTheme().darkTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const SearchScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
