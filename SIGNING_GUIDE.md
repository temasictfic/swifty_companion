# Android Release Signing Setup

To properly sign your release APK for distribution, follow these steps:

## 1. Generate a Keystore

Run this command to generate a new keystore:

```bash
keytool -genkey -v -keystore ~/swifty-companion-release.keystore -alias swifty-companion -keyalg RSA -keysize 2048 -validity 10000
```

Remember the passwords and alias you choose!

## 2. Local Signing Setup

For local builds, create a `key.properties` file in the `android` folder:

```properties
storePassword=your_keystore_password
keyPassword=your_key_password
keyAlias=your_key_alias
storeFile=/path/to/your/keystore.jks
```

**Note:** This file is gitignored and should never be committed.

## 3. GitHub Actions Setup

For GitHub Actions to sign your releases automatically:

1. **Encode your keystore to base64:**
   ```bash
   # On Linux/Mac
   base64 -i ~/swifty-companion-release.keystore -o keystore_base64.txt
   
   # On Windows (PowerShell)
   [Convert]::ToBase64String([IO.File]::ReadAllBytes("$env:USERPROFILE\swifty-companion-release.keystore")) | Out-File keystore_base64.txt
   ```

2. **Add these secrets to your GitHub repository:**
   
   Go to Settings → Secrets and variables → Actions, then add:
   
   - `ANDROID_SIGNING_KEY`: The entire contents of `keystore_base64.txt`
   - `ANDROID_KEY_ALIAS`: Your key alias (e.g., "swifty-companion")
   - `ANDROID_KEY_STORE_PASSWORD`: Your keystore password
   - `ANDROID_KEY_PASSWORD`: Your key password

3. **Optional - For Google Play Store uploads:**
   - `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON`: Your Google Play service account JSON

## 4. Build Process

### Local Build:
```bash
flutter build apk --release
flutter build appbundle --release
```

### GitHub Actions:
- Push a tag: `git tag v1.0.0 && git push origin v1.0.0`
- The workflow will automatically:
  - Build unsigned APK and AAB
  - Sign them using your secrets
  - Create a GitHub release
  - (Optional) Upload to Google Play Store

## 5. Important Notes

- The `build.gradle.kts` only handles local signing via `key.properties`
- GitHub Actions handles signing separately using the signing action
- Never commit your keystore or passwords
- Keep backups of your keystore - losing it means you can't update your app
- The same keystore must be used for all future updates

## 6. Troubleshooting

If builds fail on GitHub Actions:
1. Verify all secrets are set correctly
2. Check that the base64 encoding is complete (no truncation)
3. Ensure the key alias matches exactly
4. Check the workflow logs for specific error messages

For local builds:
1. Verify `key.properties` file path is correct
2. Ensure the keystore file exists at the specified path
3. Check that all passwords are correct
