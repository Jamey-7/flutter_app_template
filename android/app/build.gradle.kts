plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    // TODO: Update namespace to match your app's package name
    // Example: namespace = "com.yourcompany.yourappname"
    // This must match your package structure in kotlin/ directory
    namespace = "com.example.app_template"
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
        // TODO: Update applicationId to your unique package name
        // Example: applicationId = "com.yourcompany.yourappname"
        // IMPORTANT: This cannot be changed after publishing to Play Store
        // Must use lowercase, dots to separate segments, no spaces or special characters
        // See docs/android_setup.md for detailed instructions
        applicationId = "com.example.app_template"
        
        // Android API Levels (Updated October 2025)
        // minSdk: Minimum Android version your app supports
        //         API 23 = Android 6.0 (recommended for better security features)
        //         API 21 = Android 5.0 (Flutter default, but older)
        minSdk = 23
        
        // targetSdk: Android version your app is tested against
        //            CRITICAL: Google Play requires API 35+ as of August 31, 2025
        //            API 35 = Android 15 (required for Play Store submission)
        targetSdk = 35
        
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
