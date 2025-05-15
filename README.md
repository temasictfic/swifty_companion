# Swifty Companion

A modern Flutter application for browsing 42 student profiles using the 42 API.

## Features

- 🔍 Search for 42 students by login
- 👤 View detailed student profiles
- 📊 See projects, skills, and achievements
- 🎨 Modern, dark-themed UI
- 🔐 Secure credential management

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK
- An IDE (VS Code, Android Studio, etc.)
- 42 API credentials (Client ID and Client Secret)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/temasictfic/swifty_companion.git
   cd swifty_companion
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

### Configuration

On first launch, the app will guide you through setting up your 42 API credentials:

1. Launch the app
2. Follow the initial setup wizard
3. Click "Configure API Settings"
4. Enter your 42 API Client ID and Client Secret
5. Click "Save Credentials"

Your credentials are securely stored on the device using platform-specific encryption.

## Usage

1. **Search**: Type a 42 student login in the search bar (minimum 2 characters)
2. **View Profile**: Tap on a search result to view the full profile
3. **Settings**: Access settings via the gear icon to manage your API credentials

## Security

- API credentials are stored securely using platform-specific encryption
- No credentials are transmitted or stored in plain text
- Credentials remain local to your device
- No external configuration files are used

## How to Get 42 API Credentials

1. Log in to your 42 intranet account
2. Navigate to Settings > API
3. Create a new application
4. Copy your Client ID and Client Secret
5. Use these credentials in the app settings

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Dependencies

Key packages used in this project:

- `flutter_secure_storage`: Secure credential storage
- `http`: API requests
- `provider`: State management
- `cached_network_image`: Image caching
- `shimmer`: Loading animations
- `glass_kit`: Glassmorphism effects
- `animations`: Smooth transitions

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- 42 School for providing the API
- Flutter community for excellent packages
- Contributors and testers

## Troubleshooting

### Common Issues

1. **API Credentials Not Working**
   - Ensure your Client ID and Secret are correct
   - Check if your 42 API app is active
   - Try clearing and re-entering credentials

2. **Network Errors**
   - Check your internet connection
   - Verify the API endpoint is accessible
   - Check if your token has expired

3. **Search Not Working**
   - Enter at least 2 characters
   - Check for typos in the login
   - Ensure API credentials are configured

4. **Settings Access**
   - Settings can be accessed from the gear icon in the search screen
   - You can update or clear credentials at any time

For more issues, please check the [Issues](https://github.com/temasictfic/swifty_companion/issues) page or create a new one.
