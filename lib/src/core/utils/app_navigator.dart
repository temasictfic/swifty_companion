import 'package:flutter/material.dart';

class AppNavigator {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  static NavigatorState? get navigator => navigatorKey.currentState;
  
  static void navigateToHome() {
    navigator?.pushNamedAndRemoveUntil('/home', (route) => false);
  }
  
  static void navigateToSettings({bool isInitialSetup = false}) {
    navigator?.pushNamed(
      '/settings',
      arguments: {'isInitialSetup': isInitialSetup},
    );
  }
  
  static void pop([dynamic result]) {
    if (navigator?.canPop() ?? false) {
      navigator?.pop(result);
    }
  }
}
