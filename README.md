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
   git clone https://github.com/yourusername/swifty-companion.git
   cd swifty-companion
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

The app now supports two methods for API configuration:

#### Method 1: In-App Configuration (Recommended)

1. Launch the app
2. Follow the initial setup wizard
3. Enter your 42 API credentials when prompted
4. Your credentials will be securely stored on the device

#### Method 2: .env File

1. Copy `.env.example` to `.env`:
   ```bash
   cp .env.example .env
   ```

2. Add your 42 API credentials:
   ```
   CLIENT_ID=your_client_id_here
   CLIENT_SECRET=your_client_secret_here
   ```

## Usage

1. **Search**: Type a 42 student login in the search bar (minimum 2 characters)
2. **View Profile**: Tap on a search result to view the full profile
3. **Settings**: Access settings via the gear icon to manage your API credentials

## Security

- API credentials are stored securely using platform-specific encryption
- No credentials are transmitted or stored in plain text
- Credentials remain local to your device

## Project Structure

```
lib/
├── src/
│   ├── app.dart                 # Main app configuration
│   ├── core/                    # Core business logic
│   │   ├── models/             # Data models
│   │   ├── services/           # API and auth services
│   │   ├── themes/             # App theming
│   │   └── utils/              # Utility functions
│   ├── features/               # Feature modules
│   │   ├── auth/              # Authentication features
│   │   ├── profile/           # Profile display
│   │   ├── search/            # Search functionality
│   │   └── settings/          # Settings management
│   └── shared/                # Shared widgets
└── main.dart                  # App entry point
```

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

For more issues, please check the [Issues](https://github.com/yourusername/swifty-companion/issues) page or create a new one.
