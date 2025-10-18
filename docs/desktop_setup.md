# Windows & Linux Desktop Setup Guide

This guide covers Windows and Linux-specific configuration for your Flutter desktop app.

---

## 📋 Important Notes

### RevenueCat Support

**⚠️ RevenueCat does NOT support Windows or Linux platforms.**

The template automatically handles this with a fallback to free tier:

```dart
// In lib/providers/subscription_provider.dart
if (kIsWeb || Platform.isWindows || Platform.isLinux) {
  return SubscriptionInfo.free();
}
```

### Alternative Monetization Options

For Windows/Linux apps with subscriptions:

1. **Stripe Integration**
   - Use Stripe Checkout
   - Handle payments via backend API
   - Sync subscription status with Supabase

2. **PayPal Integration**
   - Use PayPal subscription buttons
   - Handle webhooks on backend
   - Update user subscription status

3. **License Keys**
   - Generate license keys on purchase
   - Validate keys in app
   - Store validation status locally

4. **Backend API**
   - Create custom subscription API
   - Handle payments via Stripe/PayPal/Paddle
   - Return subscription status to Flutter app

**Recommendation:** For production desktop apps with subscriptions, implement a backend API.

---

## 🪟 Windows Setup

### Prerequisites

- Windows 10 or later (64-bit)
- Visual Studio 2022 with "Desktop development with C++" workload
- Flutter SDK installed
- Git for Windows

### Enable Windows Support

```bash
flutter config --enable-windows-desktop
flutter create .
```

### Project Configuration

#### Update App Name

**File:** `windows/runner/main.cpp`

```cpp
Win32Window::Point origin(10, 10);
Win32Window::Size size(1280, 720);
if (!window.Create(L"Your App Name", origin, size)) {
  return EXIT_FAILURE;
}
```

#### Update App Icon

1. Create a 256x256 PNG icon
2. Convert to ICO format using [ICO Convert](https://icoconvert.com/)
3. Replace `windows/runner/resources/app_icon.ico`

#### Update Version

**File:** `windows/runner/Runner.rc`

```cpp
#define VERSION_AS_NUMBER 1,0,0,1
#define VERSION_AS_STRING "1.0.0.1"
```

### Build Configuration

**Debug Build:**
```bash
flutter build windows --debug
```

**Release Build:**
```bash
flutter build windows --release
```

**Output Location:**
```
build/windows/x64/runner/Release/
```

### Distribution

#### Option 1: Portable Executable

The build output is already portable. Just zip the entire `Release/` folder:

```bash
cd build/windows/x64/runner/Release/
zip -r YourApp-Windows-v1.0.0.zip .
```

Users can extract and run `your_app.exe`.

#### Option 2: MSIX Installer (Microsoft Store)

1. Add `msix` package to `pubspec.yaml`:
   ```yaml
   dev_dependencies:
     msix: ^3.16.0
   ```

2. Configure in `pubspec.yaml`:
   ```yaml
   msix_config:
     display_name: Your App Name
     publisher_display_name: Your Company
     identity_name: com.yourcompany.yourapp
     publisher: CN=YourPublisher
     msix_version: 1.0.0.0
     logo_path: assets/app_icon.png
     capabilities: internetClient
   ```

3. Create MSIX:
   ```bash
   flutter pub run msix:create
   ```

4. Output: `build/windows/x64/runner/Release/your_app.msix`

#### Option 3: Inno Setup Installer

1. Download [Inno Setup](https://jrsoftware.org/isinfo.php)

2. Create installer script `installer.iss`:
   ```iss
   [Setup]
   AppName=Your App Name
   AppVersion=1.0.0
   DefaultDirName={autopf}\YourApp
   DefaultGroupName=Your App
   OutputDir=build\windows\installer
   OutputBaseFilename=YourApp-Setup-v1.0.0
   Compression=lzma2
   SolidCompression=yes
   
   [Files]
   Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs
   
   [Icons]
   Name: "{group}\Your App"; Filename: "{app}\your_app.exe"
   Name: "{autodesktop}\Your App"; Filename: "{app}\your_app.exe"
   ```

3. Compile with Inno Setup

### Testing on Windows

```bash
flutter run -d windows
```

**Test Checklist:**
- [ ] Authentication flows
- [ ] Network requests (Supabase)
- [ ] Navigation
- [ ] UI responsiveness
- [ ] Window resizing
- [ ] Keyboard shortcuts
- [ ] File dialogs (if applicable)
- [ ] System tray integration (if applicable)

### Common Issues

**Issue: "Visual Studio not found"**

**Solution:**
- Install Visual Studio 2022
- Ensure "Desktop development with C++" workload is installed
- Run `flutter doctor` to verify

**Issue: "DLL not found" when running .exe**

**Solution:**
- Ensure all DLLs from `Release/` folder are included
- Don't move the .exe without its dependencies
- Use installer or zip the entire folder

**Issue: Network requests fail**

**Solution:**
- Windows Firewall might block the app
- Add firewall exception
- Or run as administrator (not recommended for production)

---

## 🐧 Linux Setup

### Prerequisites

- Ubuntu 20.04 or later (or equivalent)
- Flutter SDK installed
- Required libraries:
  ```bash
  sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev
  ```

### Enable Linux Support

```bash
flutter config --enable-linux-desktop
flutter create .
```

### Project Configuration

#### Update App Name

**File:** `linux/my_application.cc`

```cpp
gtk_window_set_title(window, "Your App Name");
gtk_window_set_default_size(window, 1280, 720);
```

#### Update App Icon

1. Create a 512x512 PNG icon
2. Save as `linux/runner/resources/app_icon.png`
3. Or use multiple sizes in `linux/runner/resources/`

### Build Configuration

**Debug Build:**
```bash
flutter build linux --debug
```

**Release Build:**
```bash
flutter build linux --release
```

**Output Location:**
```
build/linux/x64/release/bundle/
```

### Distribution

#### Option 1: Portable Bundle

Zip the entire bundle folder:

```bash
cd build/linux/x64/release/bundle/
tar -czf YourApp-Linux-v1.0.0.tar.gz .
```

Users can extract and run `./your_app`.

#### Option 2: Snap Package

1. Install snapcraft:
   ```bash
   sudo snap install snapcraft --classic
   ```

2. Create `snap/snapcraft.yaml`:
   ```yaml
   name: your-app
   version: '1.0.0'
   summary: Your app summary
   description: Your app description
   
   base: core22
   confinement: strict
   grade: stable
   
   apps:
     your-app:
       command: your_app
       plugs:
         - network
         - desktop
         - desktop-legacy
   
   parts:
     your-app:
       plugin: dump
       source: build/linux/x64/release/bundle/
   ```

3. Build snap:
   ```bash
   flutter build linux --release
   snapcraft
   ```

4. Output: `your-app_1.0.0_amd64.snap`

#### Option 3: AppImage

1. Download [appimagetool](https://github.com/AppImage/AppImageKit/releases)

2. Create AppDir structure:
   ```bash
   mkdir -p YourApp.AppDir/usr/bin
   cp -r build/linux/x64/release/bundle/* YourApp.AppDir/usr/bin/
   ```

3. Create desktop file `YourApp.AppDir/your-app.desktop`:
   ```ini
   [Desktop Entry]
   Name=Your App
   Exec=your_app
   Icon=app_icon
   Type=Application
   Categories=Utility;
   ```

4. Add icon:
   ```bash
   cp linux/runner/resources/app_icon.png YourApp.AppDir/app_icon.png
   ```

5. Create AppImage:
   ```bash
   appimagetool YourApp.AppDir YourApp-v1.0.0-x86_64.AppImage
   ```

#### Option 4: Debian Package (.deb)

1. Create package structure:
   ```bash
   mkdir -p your-app_1.0.0/DEBIAN
   mkdir -p your-app_1.0.0/usr/bin
   mkdir -p your-app_1.0.0/usr/share/applications
   mkdir -p your-app_1.0.0/usr/share/icons/hicolor/512x512/apps
   ```

2. Copy files:
   ```bash
   cp -r build/linux/x64/release/bundle/* your-app_1.0.0/usr/bin/
   ```

3. Create control file `your-app_1.0.0/DEBIAN/control`:
   ```
   Package: your-app
   Version: 1.0.0
   Section: utils
   Priority: optional
   Architecture: amd64
   Maintainer: Your Name <your@email.com>
   Description: Your app description
   ```

4. Create desktop file `your-app_1.0.0/usr/share/applications/your-app.desktop`:
   ```ini
   [Desktop Entry]
   Name=Your App
   Exec=/usr/bin/your_app
   Icon=your-app
   Type=Application
   Categories=Utility;
   ```

5. Add icon:
   ```bash
   cp linux/runner/resources/app_icon.png your-app_1.0.0/usr/share/icons/hicolor/512x512/apps/your-app.png
   ```

6. Build package:
   ```bash
   dpkg-deb --build your-app_1.0.0
   ```

### Testing on Linux

```bash
flutter run -d linux
```

**Test Checklist:**
- [ ] Authentication flows
- [ ] Network requests (Supabase)
- [ ] Navigation
- [ ] UI responsiveness
- [ ] Window resizing
- [ ] Keyboard shortcuts
- [ ] File dialogs (if applicable)
- [ ] System tray integration (if applicable)

### Common Issues

**Issue: "GTK libraries not found"**

**Solution:**
```bash
sudo apt-get install libgtk-3-dev
```

**Issue: "Failed to load libflutter_linux_gtk.so"**

**Solution:**
- Ensure all files from `bundle/` are kept together
- Don't move the executable without its dependencies

**Issue: Network requests fail**

**Solution:**
- Check firewall settings
- Ensure network permissions in snap/flatpak confinement

---

## 🎨 Desktop-Specific UI Considerations

### Window Management

Use `window_manager` package for advanced window control:

```yaml
dependencies:
  window_manager: ^0.3.7
```

```dart
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  
  WindowOptions windowOptions = WindowOptions(
    size: Size(1280, 720),
    minimumSize: Size(800, 600),
    center: true,
    title: 'Your App Name',
  );
  
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  
  runApp(MyApp());
}
```

### System Tray

Use `tray_manager` package:

```yaml
dependencies:
  tray_manager: ^0.2.0
```

```dart
import 'package:tray_manager/tray_manager.dart';

await trayManager.setIcon('assets/tray_icon.png');
await trayManager.setToolTip('Your App');
```

### File Picker

Use `file_picker` package:

```yaml
dependencies:
  file_picker: ^6.1.1
```

```dart
import 'package:file_picker/file_picker.dart';

FilePickerResult? result = await FilePicker.platform.pickFiles();
if (result != null) {
  File file = File(result.files.single.path!);
}
```

### Keyboard Shortcuts

Use `hotkey_manager` package:

```yaml
dependencies:
  hotkey_manager: ^0.2.0
```

```dart
import 'package:hotkey_manager/hotkey_manager.dart';

HotKey hotKey = HotKey(
  key: PhysicalKeyboardKey.keyN,
  modifiers: [HotKeyModifier.control],
);

await hotKeyManager.register(
  hotKey,
  keyDownHandler: (hotKey) {
    // Handle Ctrl+N
  },
);
```

---

## 📦 Distribution Platforms

### Windows

- **Microsoft Store** - MSIX package required
- **Steam** - Popular for games and apps
- **itch.io** - Indie-friendly platform
- **Your Website** - Direct download (EXE or installer)

### Linux

- **Snap Store** - Ubuntu's official store
- **Flathub** - Flatpak repository
- **AppImage Hub** - AppImage directory
- **Your Website** - Direct download (.deb, .tar.gz, AppImage)

---

## 🔒 Security Considerations

### Code Signing

**Windows:**
- Purchase code signing certificate
- Sign .exe with `signtool.exe`
- Required for SmartScreen bypass

**Linux:**
- Not required but recommended
- Use GPG to sign packages

### Auto-Updates

Consider using:
- **Sparkle** (Windows/macOS)
- **AppUpdater** (cross-platform)
- **Custom update checker** via API

---

## 📚 Additional Resources

- [Flutter Desktop Documentation](https://docs.flutter.dev/platform-integration/desktop)
- [Windows Deployment](https://docs.flutter.dev/deployment/windows)
- [Linux Deployment](https://docs.flutter.dev/deployment/linux)
- [MSIX Documentation](https://pub.dev/packages/msix)
- [Snapcraft Documentation](https://snapcraft.io/docs)

---

## ✅ Desktop Setup Complete!

Your desktop app is ready for:
- ✅ Windows distribution
- ✅ Linux distribution
- ✅ Local testing

**Important Reminders:**
- ⚠️ RevenueCat not supported on Windows/Linux
- ⚠️ Implement alternative monetization (Stripe, PayPal, license keys)
- ⚠️ Test on target platforms before distribution
- ⚠️ Consider code signing for Windows

**Next Steps:**
- Configure mobile platforms (iOS, Android)
- Implement backend for subscriptions (if needed)
- Set up distribution channels
- Create installers for easy deployment
