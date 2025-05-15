import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _storage = FlutterSecureStorage();
  
  // Keys for secure storage
  static const String _clientIdKey = 'client_id';
  static const String _clientSecretKey = 'client_secret';
  
  // Keys for shared preferences
  static const String _isConfiguredKey = 'is_configured';
  static const String _lastConfiguredAtKey = 'last_configured_at';
  
  // Singleton instance
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();
  
  /// Save API credentials securely
  Future<void> saveCredentials({
    required String clientId,
    required String clientSecret,
  }) async {
    try {
      // Validate inputs
      if (clientId.isEmpty || clientSecret.isEmpty) {
        throw ArgumentError('Client ID and Client Secret cannot be empty');
      }
      
      // Save to secure storage
      await _storage.write(key: _clientIdKey, value: clientId);
      await _storage.write(key: _clientSecretKey, value: clientSecret);
      
      // Mark as configured in shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isConfiguredKey, true);
      await prefs.setString(_lastConfiguredAtKey, DateTime.now().toIso8601String());
    } catch (e) {
      throw Exception('Failed to save credentials: $e');
    }
  }
  
  /// Get stored credentials
  Future<Map<String, String?>> getCredentials() async {
    try {
      final clientId = await _storage.read(key: _clientIdKey);
      final clientSecret = await _storage.read(key: _clientSecretKey);
      
      return {
        'clientId': clientId,
        'clientSecret': clientSecret,
      };
    } catch (e) {
      throw Exception('Failed to retrieve credentials: $e');
    }
  }
  
  /// Check if app is configured with credentials
  Future<bool> isConfigured() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isConfigured = prefs.getBool(_isConfiguredKey) ?? false;
      
      // Double check that credentials actually exist
      if (isConfigured) {
        final credentials = await getCredentials();
        return credentials['clientId'] != null && credentials['clientSecret'] != null;
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }
  
  /// Get the last configuration date
  Future<DateTime?> getLastConfiguredDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = prefs.getString(_lastConfiguredAtKey);
    
    if (dateString != null) {
      return DateTime.tryParse(dateString);
    }
    
    return null;
  }
  
  /// Clear all stored credentials
  Future<void> clearCredentials() async {
    try {
      // Clear secure storage
      await _storage.delete(key: _clientIdKey);
      await _storage.delete(key: _clientSecretKey);
      
      // Clear configuration flags
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isConfiguredKey, false);
      await prefs.remove(_lastConfiguredAtKey);
    } catch (e) {
      throw Exception('Failed to clear credentials: $e');
    }
  }
  
  /// Validate credentials by making a test API call
  Future<bool> validateCredentials(String clientId, String clientSecret) async {
    // This is a placeholder - you should implement actual validation
    // by making a test API call to verify the credentials work
    return clientId.isNotEmpty && clientSecret.isNotEmpty;
  }
}
