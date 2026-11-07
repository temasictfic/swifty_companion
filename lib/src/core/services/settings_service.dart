import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef ApiCredentials = ({String? clientId, String? clientSecret});

/// Persists the user's 42 API credentials (secure storage) and app flags.
class SettingsService {
  factory SettingsService() => _instance;
  SettingsService._internal();
  static final SettingsService _instance = SettingsService._internal();

  static const _storage = FlutterSecureStorage();

  static const String _clientIdKey = 'client_id';
  static const String _clientSecretKey = 'client_secret';
  static const String _isConfiguredKey = 'is_configured';
  static const String _lastConfiguredAtKey = 'last_configured_at';

  /// Cached after the first read: secure storage goes through the Android
  /// Keystore, which is slow on mid-range phones.
  ApiCredentials? _cachedCredentials;

  Future<void> saveCredentials({
    required String clientId,
    required String clientSecret,
  }) async {
    if (clientId.isEmpty || clientSecret.isEmpty) {
      throw ArgumentError('Client ID and Client Secret cannot be empty');
    }
    await _storage.write(key: _clientIdKey, value: clientId);
    await _storage.write(key: _clientSecretKey, value: clientSecret);
    _cachedCredentials = (clientId: clientId, clientSecret: clientSecret);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isConfiguredKey, true);
    await prefs.setString(
      _lastConfiguredAtKey,
      DateTime.now().toIso8601String(),
    );
  }

  Future<ApiCredentials> getCredentials() async {
    final cached = _cachedCredentials;
    if (cached != null) return cached;
    final values = await Future.wait([
      _storage.read(key: _clientIdKey),
      _storage.read(key: _clientSecretKey),
    ]);
    return _cachedCredentials = (clientId: values[0], clientSecret: values[1]);
  }

  /// True when credentials were saved and can still be read back.
  Future<bool> isConfigured() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!(prefs.getBool(_isConfiguredKey) ?? false)) return false;
      final credentials = await getCredentials();
      return credentials.clientId != null && credentials.clientSecret != null;
    } catch (_) {
      return false;
    }
  }

  Future<DateTime?> getLastConfiguredDate() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_lastConfiguredAtKey);
    return value == null ? null : DateTime.tryParse(value);
  }

  Future<void> clearCredentials() async {
    await _storage.delete(key: _clientIdKey);
    await _storage.delete(key: _clientSecretKey);
    _cachedCredentials = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isConfiguredKey, false);
    await prefs.remove(_lastConfiguredAtKey);
  }
}
