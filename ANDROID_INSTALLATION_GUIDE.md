# Installing Swifty Companion on Android Phone

This guide provides multiple methods to install your Flutter app on an Android device.

## Prerequisites

- Flutter SDK installed and configured
- Android phone
- USB cable (for some methods)
- Project built successfully with `flutter build`

## Method 1: USB Debugging (Recommended for Development)

### 1. Enable Developer Options
1. Go to **Settings** → **About Phone**
2. Find **Build Number** and tap it **7 times**
3. You'll see a message: "Developer options enabled"

### 2. Enable USB Debugging
1. Go to **Settings** → **Developer Options**
2. Enable **USB Debugging**
3. Enable **Install via USB** (if available)

### 3. Connect Your Phone
1. Connect your phone to your computer with a USB cable
2. On your phone, accept the "Allow USB debugging?" prompt
3. Check "Always allow from this computer" for convenience

### 4. Verify Connection
```bash
flutter devices
```
Your device should appear in the list like:
```
SM G9900 (mobile) • RFXXXXXXXX • android-arm64 • Android 11 (API 30)
```

### 5. Install and Run
```bash
# Run in debug mode
flutter run

# OR install release version
flutter install --release
```

## Method 2: Build APK and Transfer

### 1. Build the APK
```bash
# Build release APK
flutter build apk --release
```
The APK will be created at:
```
build/app/outputs/flutter-apk/app-release.apk
```

### 2. Transfer Methods
Choose one of these methods to transfer the APK:

#### Email
1. Email the APK file to yourself
2. Open the email on your phone
3. Download and install the APK

#### Cloud Storage
1. Upload to Google Drive, Dropbox, or OneDrive
2. Download the file on your phone
3. Install from the downloads folder

#### USB Transfer
1. Connect phone via USB
2. Copy the APK to phone's storage
3. Use a file manager to locate and install

### 3. Install the APK
1. Locate the APK file on your phone
2. Tap to install
3. You may need to enable "Install from unknown sources"

## Method 3: Build Split APKs (Optimized Size)

### 1. Build Split APKs
```bash
flutter build apk --split-per-abi
```

This creates multiple APKs:
- `app-armeabi-v7a-release.apk` (32-bit ARM)
- `app-arm64-v8a-release.apk` (64-bit ARM)
- `app-x86_64-release.apk` (64-bit x86)

### 2. Choose the Right APK
Check your device architecture:
```bash
adb shell getprop ro.product.cpu.abi
```

### 3. Install Appropriate APK
Install the APK matching your device architecture.

## Method 4: App Bundle (Play Store Ready)

### 1. Build App Bundle
```bash
flutter build appbundle
```
Output location:
```
build/app/outputs/bundle/release/app-release.aab
```

### 2. Generate APKs from Bundle
Use bundletool (mainly for Play Store distribution):
```bash
java -jar bundletool.jar build-apks \
  --bundle=app-release.aab \
  --output=app-release.apks
```

## Quick Commands Reference

```bash
# Check connected devices
flutter devices

# Run app in debug mode
flutter run

# Build and install release version
flutter build apk --release
flutter install --release

# Build optimized APKs
flutter build apk --split-per-abi

# Clean build
flutter clean
flutter pub get
flutter build apk --release
```

## Troubleshooting

### Device Not Showing in `flutter devices`

1. **Check USB Connection**
   - Try a different USB cable
   - Use a USB 2.0 port instead of 3.0
   - Connect directly to computer (not through a hub)

2. **Install Drivers**
   - Windows: Install OEM USB drivers
   - Mac/Linux: Usually works out of the box

3. **Restart ADB**
   ```bash
   adb kill-server
   adb start-server
   ```

### "Install from Unknown Sources" Error

1. **Android 8.0 and higher**:
   - Settings → Apps & notifications
   - Advanced → Special app access
   - Install unknown apps
   - Select your browser/file manager
   - Allow from this source

2. **Older Android versions**:
   - Settings → Security
   - Enable "Unknown sources"

### Build Errors

```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter build apk --release

# If still failing, try:
cd android
./gradlew clean
cd ..
flutter build apk --release
```

### App Crashes on Launch

1. Check minimum Android version:
   ```yaml
   # In android/app/build.gradle
   minSdkVersion 21  # or higher
   ```

2. Ensure all permissions are granted

3. Build in debug mode first to see error logs:
   ```bash
   flutter run --debug
   ```

## Security Notes

- Only install APKs from trusted sources
- Use release builds for distribution
- Debug builds are larger and slower
- Consider using app signing for production

## File Locations

| Build Type | Location |
|------------|----------|
| Debug APK | `build/app/outputs/flutter-apk/app-debug.apk` |
| Release APK | `build/app/outputs/flutter-apk/app-release.apk` |
| Split APKs | `build/app/outputs/flutter-apk/app-{abi}-release.apk` |
| App Bundle | `build/app/outputs/bundle/release/app-release.aab` |

## Best Practices

1. **For Development**: Use USB debugging with `flutter run`
2. **For Testing**: Build release APK and install via USB
3. **For Distribution**: Use app bundles for Play Store
4. **For Sharing**: Build universal APK or split APKs

---

*Last updated: May 2025*
