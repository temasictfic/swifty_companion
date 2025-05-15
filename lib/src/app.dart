import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/services/settings_service.dart';
import 'core/themes/app_theme.dart';
import 'core/utils/app_navigator.dart';
import 'features/auth/pages/initial_setup_page.dart';
import 'features/profile/pages/profile_page.dart';
import 'features/search/pages/search_page.dart';
import 'features/settings/pages/settings_page.dart';

class FlutteryMateApp extends StatelessWidget {
  const FlutteryMateApp({super.key});

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
      title: 'Fluttery Mate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme().darkTheme,
      navigatorKey: AppNavigator.navigatorKey,
      home: const SplashScreen(),
      routes: {
        '/home': (context) => const SearchScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/settings': (context) => const SettingsPage(),
        '/setup': (context) => const InitialSetupPage(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  final SettingsService _settingsService = SettingsService();

  @override
  void initState() {
    super.initState();
    _checkConfiguration();
  }

  Future<void> _checkConfiguration() async {
    // Add a small delay for better UX
    await Future.delayed(const Duration(seconds: 1));
    
    try {
      final isConfigured = await _settingsService.isConfigured();
      
      if (mounted) {
        if (isConfigured) {
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          Navigator.pushReplacementNamed(context, '/setup');
        }
      }
    } catch (e) {
      // In case of error, go to setup
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/setup');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor.withValues(alpha: 0.8),
              Theme.of(context).primaryColor.withValues(alpha: 0.2),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.school,
                size: 80,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              const SizedBox(height: 24),
              Text(
                'Fluttery Mate',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              CircularProgressIndicator(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
