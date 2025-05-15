# Google Play Store Submission Guide

This guide covers the process of preparing and submitting your app to the Google Play Store using the Android App Bundle (AAB) format.

## Prerequisites

- Google Play Developer account ($25 one-time registration fee)
- App Bundle (AAB) file built with the `build-release-full` script
- Privacy policy URL (required for apps with internet access)
- App icons in various sizes (already included in the project)
- Screenshots of your app

## Building the AAB

The App Bundle (AAB) is the preferred format for Google Play Store submissions. It allows Google to generate optimized APKs for different device configurations.

```bash
# Build the AAB
flutter build appbundle --release

# The AAB will be located at:
# build/app/outputs/bundle/release/app-release.aab
```

## Creating a Google Play Console Account

1. Go to [play.google.com/apps/publish](https://play.google.com/apps/publish)
2. Sign in with your Google account
3. Pay the one-time $25 registration fee
4. Complete the account details

## App Submission Process

### 1. Create New App

1. In Google Play Console, click "Create app"
2. Select app defaults (language, free/paid, app type)
3. Enter app name: "Swifty Companion"
4. Create the app

### 2. Complete Store Listing

Required information:
- App name
- Short description (up to 80 characters)
- Full description (up to 4000 characters)
- App icon (512x512 PNG)
- Feature graphic (1024x500 PNG)
- Screenshots (at least 2)
- Application type
- Category
- Content rating
- Contact details
- Privacy policy URL

### 3. Set Up App Content

1. Complete the content rating questionnaire
2. Specify app's target audience
3. Configure data safety section (declare what user data your app collects)

### 4. Set Up App Releases

1. Go to "Production" track (or "Internal testing" to start with a limited audience)
2. Click "Create new release"
3. Upload your AAB file
4. Add release notes
5. Review and submit

### 5. Pricing & Distribution

1. Select countries for distribution
2. Set pricing (free or paid)
3. Check compliance options

## Important Notes for Swifty Companion

Since Swifty Companion uses the 42 API:
- Include clear instructions on how users should obtain their own API credentials
- Ensure your privacy policy explains what data is accessed and how it's stored
- Mention 42 in the app description and link to their website
- Include screenshots showing the main functionality (search, profile view)

## Testing on the Play Store

Before publishing to all users, consider using the testing tracks:
- Internal testing: Up to 100 testers (quick review)
- Closed testing (Alpha/Beta): Larger groups (quick review)
- Open testing: Unrestricted (full review)

## App Review Process

- Allow 1-7 days for the Google review process
- Common rejection reasons:
  - Insufficient functionality
  - Poor performance
  - Misleading information
  - Privacy policy issues
  - Content policy violations

## Updating Your App

For future updates:
1. Increment the `versionCode` in the `pubspec.yaml` file
2. Rebuild the AAB
3. Create a new release in Google Play Console
4. Upload the new AAB and add release notes
5. Submit for review
