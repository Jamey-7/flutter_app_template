# iOS Platform Setup Guide

This guide covers all iOS-specific configuration needed to deploy your Flutter app to the App Store.

---

## 📋 Prerequisites

- **macOS** with Xcode 26.1+ installed (latest stable version recommended)
- **Apple Developer Account** ($99/year)
- **Physical iOS device** or simulator for testing
- **CocoaPods** installed (`sudo gem install cocoapods`)
- **Minimum iOS Version:** iOS 14.0+ (deployment target)

### Version Requirements (October 2025)

- **Xcode:** 26.1 or later
- **iOS SDK:** iOS 26 (included with Xcode 26.1)
- **Deployment Target:** iOS 14.0 minimum
- **Flutter:** 3.35+ recommended
- **RevenueCat SDK:** Requires iOS 13.0+

---

## 1️⃣ Bundle Identifier Configuration

### Update Bundle ID in Xcode

1. Open the iOS project in Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```

2. Select the **Runner** project in the left sidebar

3. Select the **Runner** target under "TARGETS"

4. Go to the **General** tab

5. Update the **Bundle Identifier**:
   - Default: `com.example.appTemplate`
   - Change to: `com.yourcompany.yourappname`
   - Example: `com.acme.fitnessapp`

6. **Important:** Use lowercase, no spaces, no special characters except dots

### Update Display Name

1. In the same **General** tab, find **Display Name**
2. Change from "App Template" to your app's name
3. This is what users see on their home screen

### Alternative: Update in Info.plist

You can also update the display name in `ios/Runner/Info.plist`:

```xml
<key>CFBundleDisplayName</key>
<string>Your App Name</string>
```

---

## 2️⃣ App Icons & Launch Screen

### App Icons

1. Prepare app icons in required sizes:
   - 1024x1024 (App Store)
   - 180x180 (iPhone)
   - 167x167 (iPad Pro)
   - 152x152 (iPad)
   - 120x120 (iPhone)
   - 87x87 (iPhone)
   - 80x80 (iPad)
   - 76x76 (iPad)
   - 60x60 (iPhone)
   - 58x58 (iPhone/iPad)
   - 40x40 (iPhone/iPad)
   - 29x29 (iPhone/iPad)
   - 20x20 (iPhone/iPad)

2. Add icons to Xcode:
   - In Xcode, open `Runner/Assets.xcassets/AppIcon.appiconset`
   - Drag and drop icons into appropriate slots
   - Or use a tool like [App Icon Generator](https://appicon.co/)

### Launch Screen (Splash Screen)

The template includes a basic launch screen at `ios/Runner/Base.lproj/LaunchScreen.storyboard`.

**Option 1: Customize in Xcode**
1. Open `LaunchScreen.storyboard` in Xcode
2. Modify the UI elements (logo, background color, etc.)
3. Keep it simple - iOS guidelines recommend minimal splash screens

**Option 2: Use flutter_native_splash package**
1. Add to `pubspec.yaml`:
   ```yaml
   dev_dependencies:
     flutter_native_splash: ^2.3.0
   ```

2. Configure in `pubspec.yaml`:
   ```yaml
   flutter_native_splash:
     color: "#ffffff"
     image: assets/splash_logo.png
     ios: true
   ```

3. Generate splash screens:
   ```bash
   flutter pub run flutter_native_splash:create
   ```

---

## 3️⃣ Permissions & Privacy

### Current Permissions

The template **does not require any special permissions** by default. It only uses:
- Network access (automatic)
- Deep linking (already configured)

### Adding App-Specific Permissions

If your app needs additional permissions (camera, photos, location, etc.), add them to `ios/Runner/Info.plist`:

**Camera Access:**
```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to take photos</string>
```

**Photo Library:**
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>We need photo library access to select images</string>
```

**Location (When In Use):**
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to show nearby places</string>
```

**Location (Always):**
```xml
<key>NSLocationAlwaysUsageDescription</key>
<string>We need your location to track your activity</string>
```

**Microphone:**
```xml
<key>NSMicrophoneUsageDescription</key>
<string>We need microphone access to record audio</string>
```

**Contacts:**
```xml
<key>NSContactsUsageDescription</key>
<string>We need access to your contacts</string>
```

**Calendar:**
```xml
<key>NSCalendarsUsageDescription</key>
<string>We need access to your calendar</string>
```

**Reminders:**
```xml
<key>NSRemindersUsageDescription</key>
<string>We need access to your reminders</string>
```

**Bluetooth:**
```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>We need Bluetooth access to connect to devices</string>
```

**Face ID:**
```xml
<key>NSFaceIDUsageDescription</key>
<string>We use Face ID for secure authentication</string>
```

---

## 4️⃣ Deep Linking (Already Configured ✅)

Deep linking was configured in Phase 4. Verify it's set up correctly:

### Check Info.plist

Open `ios/Runner/Info.plist` and verify:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>com.apptemplate.auth</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>apptemplate</string>
        </array>
    </dict>
</array>
```

### Customize URL Scheme

Change `apptemplate` to your app's unique scheme:
- Use lowercase
- No spaces or special characters
- Example: `myfitnessapp`, `acmestore`, etc.

### Update .env File

Update `SUPABASE_REDIRECT_URL` in `.env`:
```
SUPABASE_REDIRECT_URL=yourappscheme://auth-callback
```

---

## 5️⃣ RevenueCat iOS Configuration

See the dedicated [RevenueCat Setup Guide](./revenuecat_setup.md) for complete instructions.

### Quick Checklist

- [ ] Create iOS app in RevenueCat dashboard
- [ ] Add App Store Connect API key to RevenueCat
- [ ] Create subscription products in App Store Connect
- [ ] Link products to RevenueCat offerings
- [ ] Configure entitlements (default: "premium")
- [ ] Test with sandbox account

---

## 6️⃣ Signing & Certificates

### Development Signing

1. In Xcode, select the **Runner** target
2. Go to **Signing & Capabilities** tab
3. Check **Automatically manage signing**
4. Select your **Team** (Apple Developer account)
5. Xcode will automatically create development certificates

### Production Signing (App Store)

1. Go to [Apple Developer Portal](https://developer.apple.com/account/)
2. Create an **App Store Distribution Certificate**
3. Create an **App Store Provisioning Profile**
4. In Xcode, select **Release** configuration
5. Choose the distribution certificate and profile

### Alternative: Manual Signing

If you prefer manual signing:
1. Uncheck **Automatically manage signing**
2. Select your provisioning profile manually
3. Ensure certificate is installed in Keychain

---

## 7️⃣ Build Configuration

### Update Version & Build Number

Edit `pubspec.yaml`:
```yaml
version: 1.0.0+1
```
- `1.0.0` = Version number (user-facing)
- `+1` = Build number (increments with each upload)

### Build Modes

**Debug Build (Development):**
```bash
flutter build ios --debug
```

**Release Build (App Store):**
```bash
flutter build ios --release
```

**Profile Build (Performance Testing):**
```bash
flutter build ios --profile
```

---

## 8️⃣ Testing on iOS

### Simulator Testing

1. Open iOS Simulator:
   ```bash
   open -a Simulator
   ```

2. Run the app:
   ```bash
   flutter run -d "iPhone 15 Pro"
   ```

3. Test all features:
   - [ ] Authentication flows
   - [ ] Deep linking (auth callbacks)
   - [ ] Subscription flow (RevenueCat sandbox)
   - [ ] Navigation
   - [ ] UI responsiveness

### Physical Device Testing

1. Connect iPhone/iPad via USB
2. Trust the computer on the device
3. Run the app:
   ```bash
   flutter run
   ```

4. **Important:** For RevenueCat testing, you need a physical device or TestFlight

### TestFlight Testing

1. Archive the app in Xcode:
   - Product → Archive
2. Upload to App Store Connect
3. Add internal/external testers
4. Test subscription flows with sandbox accounts

---

## 9️⃣ App Store Submission Checklist

### Before Submission

- [ ] Bundle ID matches App Store Connect
- [ ] App icons added (all sizes)
- [ ] Launch screen configured
- [ ] Privacy permissions added with descriptions
- [ ] RevenueCat products configured
- [ ] Deep linking tested
- [ ] Version and build number updated
- [ ] All features tested on physical device
- [ ] TestFlight beta testing completed
- [ ] App Store screenshots prepared (required sizes)
- [ ] App Store description written
- [ ] Privacy policy URL ready
- [ ] Terms of service URL ready

### Submission Steps

1. Create app in [App Store Connect](https://appstoreconnect.apple.com/)
2. Fill in app information
3. Upload build via Xcode or Transporter
4. Submit for review
5. Wait for approval (typically 1-3 days)

---

## 🔟 Common Issues & Solutions

### Issue: "No valid code signing certificates found"

**Solution:**
1. Open Xcode → Preferences → Accounts
2. Add your Apple ID
3. Download Manual Profiles
4. Or enable "Automatically manage signing"

### Issue: "The app ID cannot be registered to your development team"

**Solution:**
- Bundle ID already taken by another developer
- Choose a unique bundle ID
- Check App Store Connect for conflicts

### Issue: "Provisioning profile doesn't include signing certificate"

**Solution:**
1. Revoke old certificates in Apple Developer Portal
2. Create new certificate
3. Download and install in Keychain
4. Regenerate provisioning profile

### Issue: RevenueCat not working in simulator

**Solution:**
- RevenueCat requires StoreKit configuration file for simulator testing
- Or test on physical device with sandbox account
- See [RevenueCat Setup Guide](./revenuecat_setup.md)

### Issue: Deep links not working

**Solution:**
1. Verify URL scheme in Info.plist
2. Check Supabase redirect URL configuration
3. Test with: `xcrun simctl openurl booted yourscheme://auth-callback`
4. Ensure app is installed when testing

---

## 📚 Additional Resources

- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [Flutter iOS Deployment](https://docs.flutter.dev/deployment/ios)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [RevenueCat iOS SDK](https://docs.revenuecat.com/docs/ios)
- [Xcode Help](https://help.apple.com/xcode/)

---

## ✅ iOS Setup Complete!

Once you've completed all steps above, your iOS app is ready for:
- ✅ Development testing
- ✅ TestFlight distribution
- ✅ App Store submission

**Next Steps:**
- Configure Android (see [Android Setup Guide](./android_setup.md))
- Set up RevenueCat (see [RevenueCat Setup Guide](./revenuecat_setup.md))
- Review testing procedures (see [Testing Guide](./testing_guide.md))
