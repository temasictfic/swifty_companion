# Flutter's Gradle plugin already ships the keep rules Flutter and its plugins need.
# Only project-specific additions belong here.

# Flutter's embedding references Play Core classes for deferred components, which this
# app does not use. Silence R8's missing-class errors instead of bundling Play Core.
-dontwarn com.google.android.play.core.**
