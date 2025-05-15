# Flutter Secure Storage
-keepclassmembers class * extends com.it_nomads.fluttersecurestorage.FlutterSecureStoragePlugin {
    <methods>;
}

# Keep AndroidKeyStore classes
-keep class android.security.** { *; }
-keep class javax.crypto.** { *; }

# Keep encryption related classes
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# Google Play Core - needed for Flutter
-keep class com.google.android.play.core.** { *; }
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }

# Prevent stripping of methods/fields that are accessed via reflection
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# General Flutter rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Flutter Embedding
-keep class io.flutter.embedding.** { *; }
