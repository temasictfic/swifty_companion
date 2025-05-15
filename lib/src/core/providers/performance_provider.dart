import 'package:flutter/material.dart';
import '../services/settings_service.dart';

class PerformanceProvider extends ChangeNotifier {
  final _settingsService = SettingsService();
  bool _isPerformanceMode = false;

  bool get isPerformanceMode => _isPerformanceMode;

  PerformanceProvider() {
    _loadPerformanceMode();
  }

  Future<void> _loadPerformanceMode() async {
    _isPerformanceMode = await _settingsService.isPerformanceMode;
    notifyListeners();
  }

  Future<void> togglePerformanceMode() async {
    _isPerformanceMode = !_isPerformanceMode;
    await _settingsService.setPerformanceMode(_isPerformanceMode);
    notifyListeners();
  }
}
