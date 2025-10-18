# Android Platform Setup Guide

This guide covers all Android-specific configuration needed to deploy your Flutter app to the Google Play Store.

---

## 📋 Prerequisites

- Android Studio installed (latest stable version recommended)
- Android SDK installed (API 21+ / Android 5.0+)
- Google Play Console account ($25 one-time fee)
- Physical Android device or emulator for testing
- Java Development Kit (JDK) 11 or higher

---

## 1️⃣ Package Name Configuration

### Update Package Name in build.gradle.kts

The package name (Application ID) uniquely identifies your app on the Play Store.

**File:** `android/app/build.gradle.kts`

```kotlin
android {
    namespace = "com.yourcompany.yourappname"  // Update this
    
    defaultConfig {
        applicationId = "com.yourcompany.yourappname"  // Update this
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
}
```

**Important:**
- Use lowercase letters only
- Use dots to separate segments (e.g., `com.acme.fitnessapp`)
- Must match Google Play Console configuration
- Cannot be changed after first upload to Play Store
- Default is: `com.example.app_template` (must change before publishing)

### Update Package Name in MainActivity

**File:** `android/app/src/main/kotlin/com/example/app_template/MainActivity.kt`

1. Rename the folder structure to match your package name:
   ```
   android/app/src/main/kotlin/com/yourcompany/yourappname/
   ```

2. Update the package declaration in `MainActivity.kt`:
   ```kotlin
   package com.yourcompany.yourappname
   
   import io.flutter.embedding.android.FlutterActivity
   
   class MainActivity: FlutterActivity() {
   }
   ```

### Quick Rename Script

You can use this bash script to rename everything at once:

```bash
#!/bin/bash
OLD_PACKAGE="com.example.app_template"
NEW_PACKAGE="com.yourcompany.yourappname"

# Update build.gradle.kts
sed -i '' "s/$OLD_PACKAGE/$NEW_PACKAGE/g" android/app/build.gradle.kts

# Update AndroidManifest.xml (if package is referenced)
sed -i '' "s/$OLD_PACKAGE/$NEW_PACKAGE/g" android/app/src/main/AndroidManifest.xml

# Rename directory structure
OLD_PATH="android/app/src/main/kotlin/com/example/app_template"
NEW_PATH="android/app/src/main/kotlin/com/yourcompany/yourappname"
mkdir -p "$(dirname "$NEW_PATH")"
mv "$OLD_PATH" "$NEW_PATH"

# Update MainActivity.kt
sed -i '' "s/$OLD_PACKAGE/$NEW_PACKAGE/g" "$NEW_PATH/MainActivity.kt"

echo "Package name updated to $NEW_PACKAGE"
```

---

## 2️⃣ App Name & Icon

### Update App Name

**File:** `android/app/src/main/AndroidManifest.xml`

```xml
<application
    android:label="Your App Name"
    android:name="${applicationName}"
    android:icon="@mipmap/ic_launcher">
```

Change `android:label` from "app_template" to your app's name.

### Update App Icon

1. Prepare app icons in required sizes:
   - `mipmap-mdpi`: 48x48
   - `mipmap-hdpi`: 72x72
   - `mipmap-xhdpi`: 96x96
   - `mipmap-xxhdpi`: 144x144
   - `mipmap-xxxhdpi`: 192x192

2. Replace icons in:
   ```
   android/app/src/main/res/mipmap-*/ic_launcher.png
   ```

3. **Recommended Tool:** Use [Android Asset Studio](https://romannurik.github.io/AndroidAssetStudio/icons-launcher.html)

### Adaptive Icons (Android 8.0+)

Create adaptive icons for modern Android:

**File:** `android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_launcher_background"/>
    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>
</adaptive-icon>
```

---

## 3️⃣ Splash Screen Configuration

### Option 1: Native Android Splash Screen (Recommended)

**File:** `android/app/src/main/res/values/styles.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="LaunchTheme" parent="@android:style/Theme.Light.NoTitleBar">
        <item name="android:windowBackground">@drawable/launch_background</item>
    </style>
</resources>
```

**File:** `android/app/src/main/res/drawable/launch_background.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:drawable="@android:color/white" />
    <item>
        <bitmap
            android:gravity="center"
            android:src="@mipmap/ic_launcher" />
    </item>
</layer-list>
```

### Option 2: flutter_native_splash Package

1. Add to `pubspec.yaml`:
   ```yaml
   dev_dependencies:
     flutter_native_splash: ^2.3.0
   ```

2. Configure:
   ```yaml
   flutter_native_splash:
     color: "#ffffff"
     image: assets/splash_logo.png
     android: true
     android_12: true  # Android 12+ splash screen
   ```

3. Generate:
   ```bash
   flutter pub run flutter_native_splash:create
   ```

---

## 4️⃣ Permissions Configuration

### Current Permissions (Already Configured ✅)

**File:** `android/app/src/main/AndroidManifest.xml`

The template includes:
```xml
<!-- No permissions declared in manifest -->
```

**Note:** The `INTERNET` permission is automatically added by Flutter for release builds.

### Adding App-Specific Permissions

Add permissions **outside** the `<application>` tag but inside `<manifest>`:

**Internet (Automatic):**
```xml
<!-- Automatically added by Flutter, no need to declare -->
```

**Camera:**
```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-feature android:name="android.hardware.camera" android:required="false"/>
```

**Location (Coarse):**
```xml
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

**Location (Fine):**
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
```

**Location (Background - Android 10+):**
```xml
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION"/>
```

**Storage (Read):**
```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

**Storage (Write):**
```xml
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
```

**Microphone:**
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
```

**Bluetooth:**
```xml
<uses-permission android:name="android.permission.BLUETOOTH"/>
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN"/>
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT"/> <!-- Android 12+ -->
<uses-permission android:name="android.permission.BLUETOOTH_SCAN"/> <!-- Android 12+ -->
```

**Contacts:**
```xml
<uses-permission android:name="android.permission.READ_CONTACTS"/>
<uses-permission android:name="android.permission.WRITE_CONTACTS"/>
```

**Phone:**
```xml
<uses-permission android:name="android.permission.READ_PHONE_STATE"/>
<uses-permission android:name="android.permission.CALL_PHONE"/>
```

**Vibration:**
```xml
<uses-permission android:name="android.permission.VIBRATE"/>
```

### Runtime Permissions (Android 6.0+)

For dangerous permissions, request at runtime using packages like:
- `permission_handler: ^11.0.0`

Example:
```dart
import 'package:permission_handler/permission_handler.dart';

Future<void> requestCameraPermission() async {
  final status = await Permission.camera.request();
  if (status.isGranted) {
    // Permission granted
  }
}
```

---

## 5️⃣ Deep Linking (Already Configured ✅)

Deep linking was configured in Phase 4. Verify it's set up correctly:

### Check AndroidManifest.xml

**File:** `android/app/src/main/AndroidManifest.xml`

```xml
<activity android:name=".MainActivity">
    <!-- Deep linking for auth callbacks -->
    <intent-filter android:autoVerify="true">
        <action android:name="android.intent.action.VIEW"/>
        <category android:name="android.intent.category.DEFAULT"/>
        <category android:name="android.intent.category.BROWSABLE"/>
        <data android:scheme="apptemplate"/>
    </intent-filter>
</activity>
```

### Customize URL Scheme

Change `apptemplate` to your app's unique scheme:
```xml
<data android:scheme="yourappname"/>
```

### Update .env File

```
SUPABASE_REDIRECT_URL=yourappname://auth-callback
```

### Test Deep Linking

```bash
adb shell am start -W -a android.intent.action.VIEW -d "yourappname://auth-callback"
```

---

## 6️⃣ RevenueCat Android Configuration

See the dedicated [RevenueCat Setup Guide](./revenuecat_setup.md) for complete instructions.

### Quick Checklist

- [ ] Create Android app in RevenueCat dashboard
- [ ] Add Google Play Service Account credentials
- [ ] Create subscription products in Google Play Console
- [ ] Link products to RevenueCat offerings
- [ ] Configure entitlements (default: "premium")
- [ ] Test with test account

---

## 7️⃣ App Signing

### Debug Signing (Development)

Flutter automatically uses debug keystore for development:
- Location: `~/.android/debug.keystore`
- No configuration needed

### Release Signing (Play Store)

#### Step 1: Create Upload Keystore

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

**Important:** Save the keystore password and key password securely!

#### Step 2: Create key.properties

**File:** `android/key.properties`

```properties
storePassword=your_keystore_password
keyPassword=your_key_password
keyAlias=upload
storeFile=/Users/yourusername/upload-keystore.jks
```

**Important:** Add `android/key.properties` to `.gitignore`!

#### Step 3: Configure build.gradle.kts

**File:** `android/app/build.gradle.kts`

Add before `android` block:

```kotlin
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    // ... existing config
    
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
            // Enables code shrinking, obfuscation, and optimization
            minifyEnabled true
            // Enables resource shrinking
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

---

## 8️⃣ ProGuard Configuration (Code Obfuscation)

### Create ProGuard Rules

**File:** `android/app/proguard-rules.pro`

```proguard
# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Gson (if using)
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }

# RevenueCat
-keep class com.revenuecat.purchases.** { *; }

# Supabase
-keep class io.supabase.** { *; }

# Keep your models
-keep class com.yourcompany.yourapp.models.** { *; }
```

---

## 9️⃣ Build Configuration

### Update Version & Build Number

**File:** `pubspec.yaml`

```yaml
version: 1.0.0+1
```
- `1.0.0` = Version name (user-facing)
- `+1` = Version code (must increment with each upload)

### Build Modes

**Debug Build:**
```bash
flutter build apk --debug
```

**Release Build (APK):**
```bash
flutter build apk --release
```

**Release Build (App Bundle - Recommended):**
```bash
flutter build appbundle --release
```

**Split APKs by ABI (Smaller file size):**
```bash
flutter build apk --release --split-per-abi
```

This creates separate APKs for:
- `app-armeabi-v7a-release.apk` (32-bit ARM)
- `app-arm64-v8a-release.apk` (64-bit ARM)
- `app-x86_64-release.apk` (64-bit Intel)

---

## 🔟 Testing on Android

### Emulator Testing

1. Create emulator in Android Studio:
   - Tools → Device Manager → Create Device
   - Choose Pixel 6 or similar
   - Select system image (API 33+ recommended)

2. Start emulator:
   ```bash
   flutter emulators --launch <emulator_id>
   ```

3. Run app:
   ```bash
   flutter run
   ```

### Physical Device Testing

1. Enable Developer Options on device:
   - Settings → About Phone → Tap "Build Number" 7 times

2. Enable USB Debugging:
   - Settings → Developer Options → USB Debugging

3. Connect device via USB

4. Verify connection:
   ```bash
   flutter devices
   ```

5. Run app:
   ```bash
   flutter run
   ```

### Testing Checklist

- [ ] Authentication flows
- [ ] Deep linking (auth callbacks)
- [ ] Subscription flow (RevenueCat test mode)
- [ ] Navigation
- [ ] UI on different screen sizes
- [ ] Permissions (if applicable)
- [ ] Network connectivity
- [ ] App icons and splash screen
- [ ] Back button behavior
- [ ] App lifecycle (background/foreground)

---

## 1️⃣1️⃣ Google Play Store Submission

### Prerequisites

- [ ] Google Play Console account ($25 one-time fee)
- [ ] Signed app bundle (.aab file)
- [ ] App icons (512x512 high-res icon)
- [ ] Feature graphic (1024x500)
- [ ] Screenshots (at least 2, up to 8)
- [ ] Privacy policy URL
- [ ] App description (short & full)
- [ ] Content rating questionnaire completed

### Submission Steps

1. **Create App in Play Console:**
   - Go to [Google Play Console](https://play.google.com/console/)
   - Create Application
   - Fill in app details

2. **Upload App Bundle:**
   - Production → Create Release
   - Upload `.aab` file
   - Add release notes

3. **Store Listing:**
   - Add app title, description
   - Upload screenshots
   - Add feature graphic
   - Set category and tags

4. **Content Rating:**
   - Complete questionnaire
   - Get rating (Everyone, Teen, Mature, etc.)

5. **Pricing & Distribution:**
   - Set price (free or paid)
   - Select countries
   - Accept terms

6. **Submit for Review:**
   - Review all sections
   - Submit app
   - Wait for approval (typically 1-3 days)

### Internal Testing Track

Before production release, use internal testing:

1. Create internal testing release
2. Add testers (up to 100 email addresses)
3. Share testing link
4. Gather feedback
5. Fix issues
6. Promote to production

---

## 1️⃣2️⃣ Common Issues & Solutions

### Issue: "Duplicate class found"

**Solution:**
- Check for conflicting dependencies in `build.gradle.kts`
- Run `flutter clean` and rebuild

### Issue: "Execution failed for task ':app:processReleaseResources'"

**Solution:**
- Check for invalid characters in `AndroidManifest.xml`
- Ensure all resources are properly named (lowercase, no spaces)

### Issue: "Keystore file not found"

**Solution:**
- Verify `storeFile` path in `key.properties`
- Use absolute path or relative to `android/` directory

### Issue: RevenueCat not working

**Solution:**
- Verify Google Play Service Account is linked in RevenueCat dashboard
- Check product IDs match between Play Console and RevenueCat
- Test with a real device (not emulator) for subscriptions

### Issue: Deep links not working

**Solution:**
1. Verify intent filter in `AndroidManifest.xml`
2. Test with: `adb shell am start -W -a android.intent.action.VIEW -d "yourscheme://auth-callback"`
3. Ensure app is installed when testing

### Issue: "App not installed" error

**Solution:**
- Uninstall previous version first
- Check package name matches
- Verify signing configuration

---

## 1️⃣3️⃣ Performance Optimization

### Enable R8 (Code Shrinking)

Already configured in the signing section above. Reduces APK size by 30-50%.

### Analyze APK Size

```bash
flutter build apk --analyze-size
```

### Reduce APK Size Tips

1. Use app bundle instead of APK
2. Enable ProGuard/R8
3. Remove unused resources
4. Compress images
5. Use vector graphics (SVG)
6. Split APKs by ABI

---

## 📚 Additional Resources

- [Android Developer Documentation](https://developer.android.com/)
- [Flutter Android Deployment](https://docs.flutter.dev/deployment/android)
- [Google Play Console Help](https://support.google.com/googleplay/android-developer/)
- [RevenueCat Android SDK](https://docs.revenuecat.com/docs/android)
- [ProGuard Manual](https://www.guardsquare.com/manual/home)

---

## ✅ Android Setup Complete!

Once you've completed all steps above, your Android app is ready for:
- ✅ Development testing
- ✅ Internal testing track
- ✅ Google Play Store submission

**Next Steps:**
- Configure iOS (see [iOS Setup Guide](./ios_setup.md))
- Set up RevenueCat (see [RevenueCat Setup Guide](./revenuecat_setup.md))
- Review testing procedures (see [Testing Guide](./testing_guide.md))
