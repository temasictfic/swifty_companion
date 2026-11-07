# Release Notes - v1.1.0

## ⚡ Performance

- Much smoother scrolling on mid-range phones: removed the per-card blur
  (`BackdropFilter`) effects, which cost a full offscreen GPU pass per card
- Profile tabs (projects, skills, achievements) now build lazily, only what is on screen
- Profiles open faster: one request instead of two for user + projects, the header
  appears instantly from search data, and coalition data loads in parallel
- Profiles no longer reload themselves during navigation
- Network connections are reused (keep-alive) instead of a new TLS handshake per request
- Requests respect the 42 API rate limit (2 req/s) and retry automatically on HTTP 429
- Large API responses are decoded in a background isolate
- Results are cached for 5 minutes, so going back to a profile is instant
- Avatars are downloaded and decoded at display size
- Removed the 1 second artificial splash delay, and there is no more white flash at startup
- Smaller release APK: R8 code and resource shrinking enabled, unused packages removed

## 🐛 Fixes

- Search results from an older query can no longer replace newer ones
- Coalition score/rank now comes from the displayed coalition (was: highest score of any)
- Crashes on unexpected API data (missing dates, malformed colours, null ids) fixed
- "setState after dispose" errors when leaving screens during a request fixed
- Settings could not be left with the back button during initial setup
- Removed the non-functional "Performance Mode" switch (the app is now fast by default)

## 🎨 New

- New app icon with the official 42 logo
- Adaptive icon (Android 8+) and themed / monochrome icon (Android 13+)
- Pull to refresh on profiles, plus a Retry button when loading fails

## 📱 Technical Details

- Built with Flutter 3.47.9 / Dart 3.13
- Android Gradle Plugin 9.1, Gradle 9.3.1, Kotlin 2.4
- Minimum Android version: Android 7.0 (API level 24)

> **Note:** the secure storage library was upgraded to a new major version.
> You will be asked to enter your 42 API credentials once after updating.

---

Thank you for using Swifty Companion! This app was created as part of the 42 Mobile Initiation project.
