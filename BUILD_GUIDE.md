# Build and Release Guide

This guide provides instructions for building the Swifty Companion APK both locally and using GitHub Actions.

## Local Build

### Prerequisites
- Flutter SDK (version 3.29.3 or later)
- Android SDK
- JDK 17 (Java 17 is now required for Android Gradle plugin)

### Steps to Build

1. Clone the repository:
   ```bash
   git clone https://github.com/temasictfic/swifty_companion.git
   cd swifty_companion
   ```

2. Get dependencies:
   ```bash
   flutter pub get
   ```

3. Build the APK and/or AAB:
   ```bash
   # For APK (installable file)
   flutter build apk --release
   
   # For AAB (Google Play Store submission)
   flutter build appbundle --release
   ```

4. The build outputs will be available at:
   ```
   # APK location
   build/app/outputs/flutter-apk/app-release.apk
   
   # AAB location
   build/app/outputs/bundle/release/app-release.aab
   ```

## GitHub Actions

The project is set up with GitHub Actions for automated builds.

### How to Use

1. Push to the `main` branch or create a pull request to trigger a build
2. The APK will be available as an artifact in the Actions tab

### Creating a Release

1. Create and push a tag:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

2. GitHub Actions will automatically:
   - Build the APK and AAB
   - Create a release
   - Attach both APK and AAB to the release

## Troubleshooting

### Common Issues

1. **SDK Version Mismatch**
   
   If you see an error like:
   ```
   Because fluttery_mate requires SDK version ^3.7.2, version solving failed.
   ```
   
   Make sure your Flutter version matches the requirement in pubspec.yaml:
   ```bash
   flutter --version
   ```
   
   Update Flutter if needed:
   ```bash
   flutter upgrade
   ```

2. **Build Failures with R8/ProGuard**
   
   If minification causes build issues, try building without it:
   ```bash
   flutter build apk --release --no-shrink
   ```

3. **Duplicate Class Errors**
   
   These typically come from conflicting dependencies. The current build configuration has been adjusted to avoid these conflicts.

## Note on Signing

For production releases, follow the instructions in `SIGNING_GUIDE.md` to properly sign your APK.
