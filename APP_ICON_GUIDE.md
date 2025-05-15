# App Icon Instructions

## Icon Requirements:

1. **Main Icon (required)**: 
   - File: `assets/images/app_icon.png`
   - Size: 1024x1024 pixels
   - Format: PNG with transparency

2. **Android Adaptive Icon Foreground (optional)**:
   - File: `assets/images/app_icon_foreground.png`
   - Size: 1024x1024 pixels
   - Format: PNG with transparency
   - Content should be centered with padding (safe zone is 66% of the image)

## Steps to Generate Icons:

1. Place your icon image(s) in the `assets/images/` directory

2. Run these commands:
   ```bash
   flutter pub get
   flutter pub run flutter_launcher_icons:main
   ```

3. The package will generate all required icon sizes for both Android and iOS

## Customization Options:

You can modify the `flutter_icons` section in pubspec.yaml:

```yaml
flutter_icons:
  android: true              # Generate Android icons
  ios: true                  # Generate iOS icons
  image_path: "assets/images/app_icon.png"
  
  # Android specific options
  adaptive_icon_background: "#191C1E"  # Background color for adaptive icons
  adaptive_icon_foreground: "assets/images/app_icon_foreground.png"
  
  # iOS specific options
  ios: true
  remove_alpha_ios: true     # Remove alpha channel for iOS (recommended)
  
  # Other platforms
  web:
    generate: true
    image_path: "assets/images/app_icon.png"
  windows:
    generate: true
    image_path: "assets/images/app_icon.png"
