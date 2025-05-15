import 'package:flutter/material.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../widgets/credential_form.dart';

class SettingsPage extends StatefulWidget {
  final bool isInitialSetup;
  
  const SettingsPage({
    super.key,
    this.isInitialSetup = false,
  });

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  final _settingsService = SettingsService();
  final _authService = AuthService();
  
  bool _isLoading = false;
  DateTime? _lastConfiguredDate;
  bool _hasCredentials = false;
  bool _isPerformanceMode = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    
    try {
      final isConfigured = await _settingsService.isConfigured();
      final lastConfigured = await _settingsService.getLastConfiguredDate();
      final performanceMode = await _settingsService.isPerformanceMode;
      
      setState(() {
        _hasCredentials = isConfigured;
        _lastConfiguredDate = lastConfigured;
        _isPerformanceMode = performanceMode;
      });
    } catch (e) {
      _showError('Failed to load settings: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveCredentials(String clientId, String clientSecret) async {
    setState(() => _isLoading = true);
    
    try {
      // Validate credentials first
      final isValid = await _authService.validateCredentials(clientId, clientSecret);
      
      if (!isValid) {
        throw Exception('Invalid credentials. Please check your Client ID and Client Secret.');
      }
      
      // Save credentials
      await _settingsService.saveCredentials(
        clientId: clientId,
        clientSecret: clientSecret,
      );
      
      // Clear cached tokens to force re-authentication
      await _authService.clearAuth();
      
      _showSuccess('Credentials saved successfully!');
      await _loadSettings();
      
      // Handle navigation after saving
      if (mounted) {
        // Get the route arguments to check if this is initial setup
        final route = ModalRoute.of(context);
        final args = route?.settings.arguments as Map<String, dynamic>?;
        final isFromInitialSetup = args?['isInitialSetup'] ?? widget.isInitialSetup;
        
        if (isFromInitialSetup) {
          // Replace all routes and go to home
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home',
            (route) => false,
          );
        } else {
          // Just pop back to previous screen
          Navigator.pop(context);
        }
      }
    } catch (e) {
      _showError('Failed to save credentials: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _clearCredentials() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Credentials'),
        content: const Text(
          'Are you sure you want to clear your API credentials? '
          'You will need to reconfigure them to use the app.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      
      try {
        await _settingsService.clearCredentials();
        await _authService.clearAuth();
        
        _showSuccess('Credentials cleared successfully');
        await _loadSettings();
        
        // If credentials are cleared and no longer configured, go to setup
        if (!_hasCredentials && mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/setup',
            (route) => false,
          );
        }
      } catch (e) {
        _showError('Failed to clear credentials: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !widget.isInitialSetup || _hasCredentials,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        // This is called after the route has been popped
        if (!didPop) {
          // If we prevented the pop, show error message
          _showError('Please configure your API credentials to continue');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          automaticallyImplyLeading: !widget.isInitialSetup || _hasCredentials,
        ),
        body: LoadingOverlay(
          isLoading: _isLoading,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.security,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'API Configuration',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Configure your 42 API credentials for accessing student data.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        if (_hasCredentials && _lastConfiguredDate != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: .1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Configured on ${_formatDate(_lastConfiguredDate!)}',
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                CredentialForm(
                  onSave: _saveCredentials,
                  hasExistingCredentials: _hasCredentials,
                ),
                if (_hasCredentials) ...[
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Danger Zone',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _clearCredentials,
                              icon: const Icon(Icons.delete_forever),
                              label: const Text('Clear Credentials'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Theme.of(context).colorScheme.error,
                                side: BorderSide(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.speed,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Performance',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          title: const Text('Performance Mode'),
                          subtitle: const Text('Disable visual effects for better performance'),
                          value: _isPerformanceMode,
                          onChanged: (value) async {
                            setState(() => _isPerformanceMode = value);
                            await _settingsService.setPerformanceMode(value);
                            _showSuccess('Performance mode ${value ? 'enabled' : 'disabled'}');
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
