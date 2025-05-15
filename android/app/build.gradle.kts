plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.fluttery_mate"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.fluttery_mate"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // Add multidex support
        multiDexEnabled = true
    }

    buildTypes {
        getByName("release") {
            // Use debug signing config for simplicity
            signingConfig = signingConfigs.getByName("debug")
            
            // Disable minification
            isMinifyEnabled = false
            isShrinkResources = false
            
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Add multidex support
    implementation("androidx.multidex:multidex:2.0.1")
    
    // Play Core libraries - use only ONE to avoid duplicates
    // We're commenting out most of these to avoid duplicates
    // implementation("com.google.android.play:core:1.10.3")
    // implementation("com.google.android.play:core-ktx:1.8.1")
    // implementation("com.google.android.play:review:2.0.1")
    
    // This provides the minimal Play Core functionality 
    // needed by Flutter without duplicates
    implementation("com.google.android.play:core-common:2.0.3")
    implementation("com.google.android.play:feature-delivery:2.1.0")
    
    // Avoid using both core and review libraries together 
    // as they have overlapping classes
}
