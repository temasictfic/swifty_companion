import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_service.dart';

class AuthService {
  static const String _tokenKey = 'access_token';
  static const String _tokenExpiryKey = 'token_expiry';
  static const String _baseUrl = 'https://api.intra.42.fr/oauth/token';

  // Cache the token in memory for quick access
  String? _cachedToken;
  DateTime? _cachedExpiry;
  
  // Singleton instance
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();
  
  final SettingsService _settingsService = SettingsService();

  /// Get API credentials from settings only
  Future<Map<String, String>> _getApiCredentials() async {
    //print('Getting API credentials...');
    
    // Get credentials from secure storage
    final credentials = await _settingsService.getCredentials();
    
    if (credentials['clientId'] != null && credentials['clientSecret'] != null) {
      //print('Got credentials from secure storage');
      return {
        'clientId': credentials['clientId']!,
        'clientSecret': credentials['clientSecret']!,
      };
    }
    
    //print('No credentials in secure storage');
    throw Exception('No API credentials found. Please configure them in settings.');
  }

  /// Get a valid access token, either from cache or by fetching a new one
  Future<String> getAccessToken() async {
    // Check memory cache first
    if (_cachedToken != null && _cachedExpiry != null) {
      if (_cachedExpiry!.isAfter(DateTime.now())) {
        return _cachedToken!;
      }
    }

    // Check persistent storage
    final storedToken = await _getStoredToken();
    if (storedToken != null) {
      _cachedToken = storedToken['token'] as String;
      _cachedExpiry = storedToken['expiry'] as DateTime;
      return _cachedToken!;
    }

    // Fetch new token
    return _fetchNewToken();
  }

  /// Fetch a new access token from the API
  Future<String> _fetchNewToken() async {
    try {
      final credentials = await _getApiCredentials();
      
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'grant_type': 'client_credentials',
          'client_id': credentials['clientId']!,
          'client_secret': credentials['clientSecret']!,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['access_token'] as String;
        final expiresIn = data['expires_in'] as int;

        // Calculate expiry time
        final expiry = DateTime.now().add(Duration(seconds: expiresIn - 60)); // 60 seconds buffer

        // Store token
        await _storeToken(token, expiry);

        // Update cache
        _cachedToken = token;
        _cachedExpiry = expiry;

        return token;
      } else {
        throw Exception('Failed to obtain access token: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching access token: $e');
    }
  }

  /// Get stored token from SharedPreferences
  Future<Map<String, dynamic>?> _getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final expiryMillis = prefs.getInt(_tokenExpiryKey);

    if (token == null || expiryMillis == null) {
      return null;
    }

    final expiry = DateTime.fromMillisecondsSinceEpoch(expiryMillis);

    if (expiry.isAfter(DateTime.now())) {
      return {
        'token': token,
        'expiry': expiry,
      };
    }

    // Token expired, clear it
    await _clearStoredToken();
    return null;
  }

  /// Store token in SharedPreferences
  Future<void> _storeToken(String token, DateTime expiry) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setInt(_tokenExpiryKey, expiry.millisecondsSinceEpoch);
  }

  /// Clear stored token
  Future<void> _clearStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_tokenExpiryKey);
  }

  /// Force refresh the access token
  Future<String> refreshToken() async {
    await _clearStoredToken();
    _cachedToken = null;
    _cachedExpiry = null;
    return _fetchNewToken();
  }

  /// Clear all authentication data
  Future<void> clearAuth() async {
    await _clearStoredToken();
    _cachedToken = null;
    _cachedExpiry = null;
  }
  
  /// Validate credentials by attempting to get an access token
  Future<bool> validateCredentials(String clientId, String clientSecret) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'grant_type': 'client_credentials',
          'client_id': clientId,
          'client_secret': clientSecret,
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
