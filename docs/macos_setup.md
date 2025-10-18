# macOS Platform Setup Guide

This guide covers all macOS-specific configuration needed to deploy your Flutter app to the Mac App Store.

---

## 📋 Prerequisites

- macOS with Xcode installed (latest stable version recommended)
- Apple Developer Account ($99/year)
- Mac for testing
- CocoaPods installed (`sudo gem install cocoapods`)

---

## 1️⃣ Bundle Identifier Configuration

### Update Bundle ID in Xcode

1. Open the macOS project in Xcode:
   ```bash
   open macos/Runner.xcworkspace
   ```

2. Select the **Runner** project in the left sidebar

3. Select the **Runner** target under "TARGETS"

4. Go to the **General** tab

5. Update the **Bundle Identifier**:
   - Default: `com.example.appTemplate`
   - Change to: `com.yourcompany.yourappname`
   - Example: `com.acme.fitnessapp`

6. **Important:** Use lowercase, no spaces, no special characters except dots

### Update App Name

**File:** `macos/Runner/Info.plist`

```xml
<key>CFBundleName</key>
<string>Your App Name</string>
```

Or update in Xcode:
- General tab → Display Name

---

## 2️⃣ App Icon Configuration

### Create macOS App Icon

1. Prepare app icon in required sizes:
   - 1024x1024 (App Store)
   - 512x512
   - 256x256
   - 128x128
   - 64x64
   - 32x32
   - 16x16

2. Create an `.icns` file:
   ```bash
   # Using iconutil (macOS built-in)
   mkdir MyIcon.iconset
   # Add all icon sizes to MyIcon.iconset/
   iconutil -c icns MyIcon.iconset
   ```

3. Replace icon in Xcode:
   - Open `Runner/Assets.xcassets/AppIcon.appiconset`
   - Drag and drop icon files

**Tool:** Use [Image2Icon](https://img2icnsapp.com/) or [App Icon Generator](https://appicon.co/)

---

## 3️⃣ Entitlements Configuration (Critical ⚠️)

macOS apps run in a sandbox and require explicit entitlements for network access, file access, etc.

### Network Entitlements (Required ✅)

The template includes network entitlements for Debug/Profile builds but **missing in Release**.

**File:** `macos/Runner/DebugProfile.entitlements`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.app-sandbox</key>
    <true/>
    <key>com.apple.security.cs.allow-jit</key>
    <true/>
    <key>com.apple.security.network.server</key>
    <true/>
    <key>com.apple.security.network.client</key>
    <true/>
</dict>
</plist>
```

**File:** `macos/Runner/Release.entitlements` (UPDATE REQUIRED ⚠️)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.app-sandbox</key>
    <true/>
    <key>com.apple.security.network.client</key>
    <true/>
</dict>
</plist>
```

**Why This Matters:**
- Without `com.apple.security.network.client`, your app **cannot make API calls** in release builds
- Supabase, RevenueCat, and all network requests will fail
- This is the most common issue with macOS Flutter apps

### Additional Entitlements (Optional)

Add these to both `DebugProfile.entitlements` and `Release.entitlements` if needed:

**File Access (User-Selected Files):**
```xml
<key>com.apple.security.files.user-selected.read-write</key>
<true/>
```

**File Access (Downloads Folder):**
```xml
<key>com.apple.security.files.downloads.read-write</key>
<true/>
```

**File Access (Pictures Folder):**
```xml
<key>com.apple.security.files.pictures.read-write</key>
<true/>
```

**Camera Access:**
```xml
<key>com.apple.security.device.camera</key>
<true/>
```

**Microphone Access:**
```xml
<key>com.apple.security.device.audio-input</key>
<true/>
```

**Location Access:**
```xml
<key>com.apple.security.personal-information.location</key>
<true/>
```

**Contacts Access:**
```xml
<key>com.apple.security.personal-information.addressbook</key>
<true/>
```

**Calendar Access:**
```xml
<key>com.apple.security.personal-information.calendars</key>
<true/>
```

**USB Access:**
```xml
<key>com.apple.security.device.usb</key>
<true/>
```

**Bluetooth Access:**
```xml
<key>com.apple.security.device.bluetooth</key>
<true/>
```

**Printing:**
```xml
<key>com.apple.security.print</key>
<true/>
```

---

## 4️⃣ Privacy Permissions

If your app uses sensitive features, add usage descriptions to `macos/Runner/Info.plist`:

**Camera:**
```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to take photos</string>
```

**Microphone:**
```xml
<key>NSMicrophoneUsageDescription</key>
<string>We need microphone access to record audio</string>
```

**Location:**
```xml
<key>NSLocationUsageDescription</key>
<string>We need your location to show nearby places</string>
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

---

## 5️⃣ RevenueCat macOS Configuration

RevenueCat **supports macOS** with the same iOS SDK.

See the dedicated [RevenueCat Setup Guide](./revenuecat_setup.md) for complete instructions.

### Quick Checklist

- [ ] Create macOS app in RevenueCat dashboard (or use same iOS app)
- [ ] Add App Store Connect API key to RevenueCat
- [ ] Create subscription products in App Store Connect
- [ ] Link products to RevenueCat offerings
- [ ] Configure entitlements (default: "premium")
- [ ] Test with sandbox account

**Note:** macOS uses the same App Store Connect configuration as iOS.

---

## 6️⃣ Signing & Certificates

### Development Signing

1. In Xcode, select the **Runner** target
2. Go to **Signing & Capabilities** tab
3. Check **Automatically manage signing**
4. Select your **Team** (Apple Developer account)
5. Xcode will automatically create development certificates

### Production Signing (Mac App Store)

1. Go to [Apple Developer Portal](https://developer.apple.com/account/)
2. Create a **Mac App Store Distribution Certificate**
3. Create a **Mac App Store Provisioning Profile**
4. In Xcode, select **Release** configuration
5. Choose the distribution certificate and profile

### Hardened Runtime

For Mac App Store submission, enable Hardened Runtime:

1. In Xcode, select **Runner** target
2. Go to **Signing & Capabilities**
3. Click **+ Capability**
4. Add **Hardened Runtime**
5. Configure exceptions as needed (usually none required)

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
flutter build macos --debug
```

**Release Build (Mac App Store):**
```bash
flutter build macos --release
```

**Profile Build (Performance Testing):**
```bash
flutter build macos --profile
```

**Output Location:**
```
build/macos/Build/Products/Release/your_app.app
```

---

## 8️⃣ Testing on macOS

### Local Testing

```bash
flutter run -d macos
```

### Test All Features

- [ ] Authentication flows
- [ ] Network requests (Supabase, RevenueCat)
- [ ] Subscription flow
- [ ] Navigation
- [ ] UI responsiveness
- [ ] Window resizing
- [ ] Menu bar integration (if applicable)
- [ ] Keyboard shortcuts

### Common Test Scenarios

**Test Network Access:**
1. Build release version: `flutter build macos --release`
2. Run the built app from `build/macos/Build/Products/Release/`
3. Try logging in (tests Supabase connection)
4. Try viewing subscription (tests RevenueCat connection)
5. If network fails, check Release.entitlements for `com.apple.security.network.client`

---

## 9️⃣ Mac App Store Submission

### Prerequisites

- [ ] Apple Developer Account
- [ ] App created in App Store Connect
- [ ] Bundle ID registered
- [ ] App icons added
- [ ] Entitlements configured
- [ ] Privacy permissions added
- [ ] RevenueCat configured (if using subscriptions)
- [ ] App tested on macOS

### Create Archive

1. Open Xcode: `open macos/Runner.xcworkspace`
2. Select **Any Mac (Apple Silicon, Intel)** as destination
3. Product → Archive
4. Wait for archive to complete

### Upload to App Store Connect

1. In Xcode Organizer, select your archive
2. Click **Distribute App**
3. Select **App Store Connect**
4. Select **Upload**
5. Follow the wizard
6. Wait for processing (can take 30-60 minutes)

### Submit for Review

1. Go to [App Store Connect](https://appstoreconnect.apple.com/)
2. Select your app
3. Fill in app information:
   - Description
   - Keywords
   - Screenshots (required sizes)
   - Privacy policy URL
   - Support URL
4. Select the uploaded build
5. Submit for review
6. Wait for approval (typically 1-3 days)

---

## 🔟 Common Issues & Solutions

### Issue: "Network requests fail in release build"

**Solution:**
- Add `com.apple.security.network.client` to `Release.entitlements`
- Rebuild and test

### Issue: "App crashes on launch (release build)"

**Solution:**
- Check entitlements are properly configured
- Verify signing certificate is valid
- Check Console.app for crash logs

### Issue: "Provisioning profile doesn't match entitlements"

**Solution:**
1. Go to Apple Developer Portal
2. Edit provisioning profile
3. Ensure all entitlements are enabled
4. Download and install new profile
5. Rebuild

### Issue: "RevenueCat not working on macOS"

**Solution:**
- Verify macOS is enabled in RevenueCat dashboard
- Check network entitlements
- Test with sandbox account
- Ensure App Store Connect configuration is correct

### Issue: "App rejected for missing usage descriptions"

**Solution:**
- Add all required `NS*UsageDescription` keys to Info.plist
- Even if you think you don't use a feature, Apple's automated scan might detect it
- Common culprits: Camera, Microphone, Location

---

## 1️⃣1️⃣ macOS-Specific Features

### Menu Bar

Add custom menu items:

```dart
// In main.dart
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set up menu bar
  if (Platform.isMacOS) {
    // Custom menu configuration
  }
  
  runApp(MyApp());
}
```

### Window Configuration

**File:** `macos/Runner/MainFlutterWindow.swift`

```swift
override func awakeFromNib() {
  let flutterViewController = FlutterViewController.init()
  let windowFrame = self.frame
  self.contentViewController = flutterViewController
  self.setFrame(windowFrame, display: true)
  
  // Set minimum window size
  self.minSize = NSSize(width: 800, height: 600)
  
  // Set title
  self.title = "Your App Name"
  
  RegisterGeneratedPlugins(registry: flutterViewController)
  
  super.awakeFromNib()
}
```

### Dock Icon Badge

```dart
// Using platform channels
const platform = MethodChannel('com.yourapp/dock');
await platform.invokeMethod('setBadge', {'count': 5});
```

---

## 1️⃣2️⃣ Performance Optimization

### Metal Rendering

macOS uses Metal for rendering by default. Ensure it's enabled:

**File:** `macos/Runner/MainFlutterWindow.swift`

```swift
// Metal is enabled by default, no configuration needed
```

### Memory Management

macOS apps can use more memory than mobile apps, but still optimize:
- Use `const` constructors
- Dispose controllers properly
- Avoid memory leaks

---

## 📚 Additional Resources

- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [Flutter macOS Deployment](https://docs.flutter.dev/deployment/macos)
- [Mac App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [RevenueCat macOS SDK](https://docs.revenuecat.com/docs/ios)
- [App Sandbox Documentation](https://developer.apple.com/documentation/security/app_sandbox)

---

## ✅ macOS Setup Complete!

Once you've completed all steps above, your macOS app is ready for:
- ✅ Development testing
- ✅ TestFlight distribution (macOS supports TestFlight!)
- ✅ Mac App Store submission

**Next Steps:**
- Configure other platforms (iOS, Android, Web)
- Set up RevenueCat (see [RevenueCat Setup Guide](./revenuecat_setup.md))
- Review testing procedures (see [Testing Guide](./testing_guide.md))

**Critical Reminder:** Don't forget to add `com.apple.security.network.client` to `Release.entitlements`! This is the #1 issue with macOS Flutter apps.
