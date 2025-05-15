# Fluttery Mate - API Settings Integration

## Overview

This update adds the ability to configure API credentials directly within the app instead of relying solely on a `.env` file. Users can now set up and manage their 42 API credentials through a dedicated settings interface.

## New Features

1. **Settings Service**: Secure storage of API credentials using `flutter_secure_storage`
2. **Settings Page**: User interface for managing API credentials
3. **Initial Setup Flow**: First-time users are guided through the setup process
4. **Credential Validation**: Validates credentials before saving
5. **Settings Access**: Easy access to settings from the main search screen

## Implementation Details

### New Files Created

1. **`lib/src/core/services/settings_service.dart`**
   - Manages credential storage and retrieval
   - Uses secure storage for sensitive data

2. **`lib/src/features/settings/pages/settings_page.dart`**
   - Main settings interface
   - Allows users to add/update/remove credentials

3. **`lib/src/features/settings/widgets/credential_form.dart`**
   - Reusable form widget for credential input
   - Includes validation and security features

4. **`lib/src/features/auth/pages/initial_setup_page.dart`**
   - Onboarding screen for new users
   - Guides users through initial configuration

5. **`lib/src/shared/widgets/loading_overlay.dart`**
   - Utility widget for loading states

### Modified Files

1. **`lib/src/core/services/auth_service.dart`**
   - Updated to use credentials from settings service
   - Falls back to `.env` if available

2. **`lib/src/app.dart`**
   - Added splash screen and routing logic
   - Checks configuration on app startup

3. **`lib/src/features/search/screens/search_screen.dart`**
   - Added settings button in the header

4. **`lib/main.dart`**
   - Gracefully handles missing `.env` file

5. **`pubspec.yaml`**
   - Added `flutter_secure_storage` dependency

## Setup Instructions

1. Run `flutter pub get` to install the new dependency
2. Build and run the application
3. On first launch, you'll be prompted to configure your API credentials
4. Enter your 42 API Client ID and Client Secret
5. The app will validate and save your credentials securely

## Security Features

- Credentials are stored using platform-specific secure storage
- Passwords are obscured during input
- Credentials are validated before saving
- Clear confirmation required before deleting credentials
- No credentials are stored in plain text

## Usage

### First-Time Setup
1. Launch the app
2. Click "Configure API Settings"
3. Enter your Client ID and Client Secret
4. Click "Save Credentials"

### Updating Credentials
1. Click the settings icon in the search screen
2. Expand the "Update Credentials" section
3. Enter new credentials
4. Click "Update Credentials"

### Clearing Credentials
1. Go to Settings
2. Scroll to "Danger Zone"
3. Click "Clear Credentials"
4. Confirm the action

## Migration from .env

The app now supports both methods:
- Existing `.env` configurations will continue to work
- New users can configure credentials in-app
- Settings take precedence over `.env` file

## Future Enhancements

Consider adding:
- Credential import/export functionality
- Multiple profile support
- OAuth token caching and refresh
- Biometric authentication for settings access
