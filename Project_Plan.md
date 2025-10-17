# Flutter App Template

This is a complete starter for fast Flutter app development. Copy the template and start coding. Everything is in one place so you can ship repeatably with nice DX.

---

## Phase 1: Bootstrap & Configuration ✅

### **Overview**
This is a Flutter app template that boots with authentication, subscriptions, and the usual app plumbing so you can ship fast. It is plug and play. Add the environment keys and run.

---

### **Core Dependencies and Architecture** ✅
- [x] **Supabase auth** (only email and password) - Added supabase_flutter ^2.9.1
- [x] **Supabase database** - Included in supabase_flutter
- [x] **riverpod: ^3.0.3** for state management - Added flutter_riverpod ^3.0.3
- [x] **flutter_dotenv** for environment keys - Added flutter_dotenv ^5.2.1
- [x] **flutter_lints: ^6.0.0** setup - Upgraded to ^6.0.0
- [x] **heroicons: ^0.11.0** - Added
- [x] **material_symbols_icons: ^4.2874.0** - Added
- [x] **ming_cute_icons: ^0.0.7** - Added
- [x] **flutter_secure_storage** for secure token/credential storage - Added ^9.2.2
- [x] **dio: ^5.9.0** for HTTP requests and third-party API integration - Added
- [x] **freezed** and **json_serializable** for type-safe data models - Added freezed ^3.0.0 and json_serializable ^6.8.0
- [x] **go_router** for navigation with route guards - Added ^14.6.2
- [x] **RevenueCat** for subscriptions - Added purchases_flutter ^9.8.0
- [x] **Sentry** for error tracking - Added sentry_flutter ^8.11.0

---

### **Environment Configuration** ✅

**File: `.env.example`** ✅
```env
# Supabase
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key

# RevenueCat
REVENUECAT_API_KEY=your_revenuecat_api_key

# Sentry
SENTRY_DSN=your_sentry_dsn
```

**Notes:**
- [x] Use `.env` during development - Created .env file
- [x] Keys map to Supabase, RevenueCat, and Sentry - Configured
- [x] Never commit real tokens - Added .env to .gitignore
- [x] Update all values per project for plug-and-play functionality - Template ready
- [x] Configure assets in pubspec.yaml to load .env file - Added

---

### **Folder Structure** ✅
```
lib/
├─ core/
│  ├─ theme/              ✅
│  ├─ logger/             ✅
│  └─ utils/              ✅
├─ features/
│  ├─ auth/               ✅
│  ├─ subscriptions/      ✅
│  └─ settings/           ✅
├─ shared/
│  ├─ widgets/            ✅
│  ├─ forms/              ✅
│  └─ helpers/            ✅
├─ models/                ✅
│  ├─ user.dart
│  └─ subscription.dart
├─ repositories/          ✅
│  └─ subscription_repository.dart
├─ providers/             ✅
└─ app.dart

supabase/
├─ migrations/            ✅
└─ policies/              ✅
   └─ README.md           ✅

test/
├─ unit/                  ✅
├─ widget/                ✅
└─ integration/           ✅
```

---

## Phase 2: State & Data Foundations ✅

### **Riverpod 3.0 Breaking Changes and Migration Notes**

Riverpod 3.0 is a major version with several breaking changes. Key differences from 2.x:

- **Unified Notifier API**: Replace `AutoDisposeNotifier` with `Notifier` (auto-dispose is now unified into the base API). Use `Notifier` and `AsyncNotifier` for state management instead of legacy `StateNotifierProvider`, `StateProvider`, and `ChangeNotifierProvider`.
- **Legacy Providers**: `StateProvider`, `StateNotifierProvider`, and `ChangeNotifierProvider` are moved to `package:flutter_riverpod/legacy.dart` or `package:riverpod/legacy.dart`. Avoid using these in new code.
- **Error Handling**: All provider failures are now wrapped in `ProviderException`. When reading a provider that throws an error, catch `ProviderException` instead of the original error type. To access the original error, use `e.exception`.
- **ProviderObserver Changes**: The observer interface changed. Replace separate `provider` and `container` parameters with a single `ProviderObserverContext` object that contains both.
- **Ref Type Parameter Removal**: `Ref` no longer has a type parameter. Properties like `ProviderRef.state`, `Ref.listenSelf`, and `FutureProviderRef.future` have been moved to `Notifier`, `Notifier.listenSelf`, and `AsyncNotifier.future` respectively.
- **Unified Update Filtering**: All providers now use `==` to filter updates instead of a mix of `==` and `identical`. This may cause `StreamProvider`/`StreamNotifier` to filter values differently.
- **ScopedProvider Removed**: Replace `ScopedProvider` with regular `Provider`.
- **ProviderReference.mounted Removed**: Use `ref.onDispose()` to handle cleanup instead.
- **AsyncValue.error Parameter Change**: The `stacktrace` parameter is now named instead of positional.
- **New Features**:
  - `Ref.mounted`: Similar to `BuildContext.mounted`, to check if a provider is still valid.
  - Automatic retry support with exponential backoff.
  - Pause/resume support for listeners.
  - Experimental offline persistence and mutations.
  - Improved testing with `ProviderContainer.test()` and `provider.overrideWithBuild()`.

---

### **Authentication & State Management Architecture**

**Important**: This template does NOT duplicate user or subscription data in Supabase. Instead:

- **Supabase Auth** manages authentication (email, password, sessions, tokens)
- **RevenueCat** is the single source of truth for subscription/monetization data
- **Riverpod** manages application state based on Auth + RevenueCat data
- **Supabase Database** is optional—use it only if you need to store custom user data (e.g., preferences, settings, or app-specific information)

**Session & User State**:
- Session restoration works via `supabase.auth.currentSession` on app restart
- Create a Riverpod `currentUserProvider` that streams `supabase.auth.onAuthStateChange` events
- Dependent providers react to auth state changes
- Store auth tokens/credentials securely using `flutter_secure_storage` (never `SharedPreferences`)

**Subscription State**:
- Create a Riverpod `subscriptionProvider` that fetches RevenueCat subscription data
- Never store subscription info in Supabase—RevenueCat is the source of truth
- Update subscription state via RevenueCat SDK events

**Custom Data (Optional)**:
- If your app needs additional user-specific data (not auth, not subscriptions), add it to Supabase database
- Example: user preferences, app settings, custom metadata
- Implement `CustomDataRepository` backed by Riverpod providers if needed

---

### **Example Providers (Minimal Setup)**

Instead of complex database layer, focus on simple Riverpod providers:

```dart
// Stream-backed auth state with Riverpod 3.0 StreamNotifier API
final currentUserProvider =
    StreamNotifierProvider<CurrentUserNotifier, User?>(CurrentUserNotifier.new);

// RevenueCat subscription state with AsyncNotifier
final subscriptionProvider =
    AsyncNotifierProvider<SubscriptionNotifier, SubscriptionInfo>(
  SubscriptionNotifier.new,
);

// Combined application state exposed as a plain Provider
final appStateProvider = Provider<AppState>((ref) {
  return AppState(
    auth: ref.watch(currentUserProvider),
    subscription: ref.watch(subscriptionProvider),
  );
});
```

---

### **Pre-Built Skeleton Files** ✅

The template includes these ready-to-use files. Just add your `.env` keys and everything connects:

- [x] **`lib/core/supabase_client.dart`** – Supabase client initialization using your `.env` variables
- [x] **`lib/providers/auth_provider.dart`** – `StreamNotifierProvider` wrapper around Supabase auth events with structured error handling
- [x] **`lib/providers/subscription_provider.dart`** – `AsyncNotifierProvider` that guards RevenueCat fetches, platform gates, and refresh hooks
- [x] **`lib/providers/app_state_provider.dart`** – Lightweight provider stitching auth/subscription `AsyncValue`s into a single `AppState`
- [x] **`lib/main.dart`** – Initializes dotenv, Supabase, and Riverpod before `runApp`
- [x] **`supabase/migrations/`** – Empty by default; add custom tables here if needed
- [x] **`supabase/policies/README.md`** – Template for RLS policies if using custom tables

**Setup**: 
1. Create Supabase project (2 min on supabase.com)
2. Copy `.env.example` → `.env`
3. Add your Supabase URL and anon key
4. `flutter run` – auth and subscriptions work out of the box

---

### **Implementation Details** ✅

#### **Supabase Client Initialization** ✅
- [x] Use **singleton pattern** in `lib/core/supabase_client.dart`
- [x] Initialize before `runApp` in `main.dart`
- Example:
```dart
final supabaseClient = Supabase.instance.client;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  
  runApp(const MyApp());
}
```

#### **Riverpod Provider Patterns** ✅
- [x] Upgrade to Riverpod 3's notifier APIs (`StreamNotifier`/`AsyncNotifier`) with explicit `ref.keepAlive()` and auth-driven subscription refreshes
- [x] Normalize state sharing by exposing a pure `Provider<AppState>` that wraps the underlying `AsyncValue`s
- [x] Add `AsyncValue.when` UI handling paths (loading, error, data) across the template, including dedicated loading route guards

#### **Error Handling Strategy** ✅
- [x] Wrap provider access in try-catch or use `AsyncValue` pattern:
```dart
final subscriptionProvider = AsyncNotifierProvider<SubscriptionNotifier, SubscriptionInfo>(
  SubscriptionNotifier.new,
);

class SubscriptionNotifier extends AsyncNotifier<SubscriptionInfo> {
  @override
  Future<SubscriptionInfo> build() async {
    // Platform guards + RevenueCat fetch + auth-triggered refresh
  }
}
```
- Use `AsyncValue.when()` in widgets and route guards to surface loading + error affordances
- Log all provider failures through the central Logger and surface user-safe messaging in UI

#### **Testing Riverpod Providers** ✅
- [x] Override providers in tests using `ProviderScope(overrides: [...]):`
```dart
test('auth provider returns user', () async {
  const container = ProviderContainer(
    overrides: [
      currentUserProvider.overrideWithValue(
        AsyncValue.data(mockUser),
      ),
    ],
  );
  
  final user = container.read(currentUserProvider);
  expect(user.value, mockUser);
});
```
- Mock Supabase responses in unit tests
- Use `ProviderContainer` for isolated testing without full app context

---

### **Secure Token Storage** ✅

- [x] Supabase automatically handles secure token storage and refresh via `supabase_flutter`—no extra work needed
- Never manually log or expose tokens in debug output
- If you need to store OTHER sensitive data (custom API keys, etc.), then optionally add `flutter_secure_storage`

---

### **Optional: Type-Safe Data Models** ✅

If your app needs custom Supabase database tables:

- [x] Use `freezed` and `json_serializable` to generate type-safe data models
- **Model Generation Workflow**:
```bash
  flutter pub run build_runner build
```
- Keep models focused on custom data only—auth and subscription data come from their respective sources

---

### **App Initialization** ✅

- [x] Initialize dotenv and Supabase before `runApp`
- [x] Ensure Riverpod notifiers initialize current auth and subscription state, with `AppProviderObserver` capturing diagnostics
- [x] Handle deep links and initial route redirection gracefully (for subscription links or Supabase magic links)
- [x] This prevents async bugs when cloning or extending the template

### **Additional Phase 2 Completions** ✅

- [x] **Logger Service** (`lib/core/logger/logger.dart`) - Console logging with Sentry integration
- [x] **Provider Observer** (`lib/core/provider_observer.dart`) - Riverpod 3.0 compatible error tracking
- [x] **Router with Guards** (`lib/core/router/app_router.dart`) - go_router with auth/subscription guards
- [x] **Data Models** - `SubscriptionInfo` and `AppState` with freezed
- [x] **Login Screen** (`lib/features/auth/screens/login_screen.dart`) - Email/password auth
- [x] **Home Screen** (`lib/features/home/screens/home_screen.dart`) - AsyncValue-driven UX with retry affordances
- [x] **Paywall Screen** (`lib/features/subscriptions/screens/paywall_screen.dart`) - Subscription gate
- [x] **Environment Validation** - Fails fast with helpful errors
- [x] **Tests** - Riverpod overrides updated for new notifier APIs
- [x] **App Widget** (`lib/app.dart`) - Material 3 theme with router

---

## Phase 3: Authentication & Monetization

### **Authentication and User Flow**

- **Pre-built Auth Screens**: Sign in, sign up, forgot password, settings screen to change email/password.
- **Reusable Widgets**: Auth forms, paywall, settings.
- **Route Protection**: Use `go_router` with redirect guards that check login/subscription state to put content behind paywalls.

---

### **Supabase Magic Link Setup**

- Use Supabase's built-in **magic link** flow for password resets and email changes.
- **Password Recovery**:
```dart
  supabase.auth.resetPasswordForEmail(email, redirectTo: 'myapp://reset')
```
- **Configuration**: 
  - Configure redirect URLs in Supabase Dashboard → Authentication → URL Configuration for each platform (web, iOS, Android).
- **Handle Redirects**: Use `onAuthStateChange` listener:
  - Detect `PASSWORD_RECOVERY` event → navigate to reset password page
  - Detect `SIGNED_IN` event → automatically handle sign-in
- **Deep Linking Setup**:
  - **iOS**: Add custom scheme (`myapp://`) under **URL Types** in `Info.plist`
  - **Android**: Add `<intent-filter>` in `AndroidManifest.xml` for the same scheme
- This avoids needing a manual OTP UI and allows password recovery with minimal setup.

---

### **Subscriptions and Paywall**

- **RevenueCat for subscriptions**
- A reusable `PaywallScreen` template with placeholders for product IDs and pricing for RevenueCat.

---

## Phase 4: Networking & Services

### **HTTP Client & Networking**

- Include `dio: ^5.9.0` in `pubspec.yaml` with a `DioClient` helper.
- **DioClient Features**:
  - Shared interceptors for auth headers
  - Request/response logging (debug mode only)
  - Retry logic
  - Error transformation for unified error handling
- Use Dio for non-Supabase HTTP requests (REST endpoints, third-party APIs, Supabase Edge Functions).
- Route responses through repository layer for consistency and testability.

---

### **Error Tracking and Logging**

- **Sentry Integration**: Use Sentry Flutter SDK to catch errors.
- **Logger Service**: Create a Logger Service with `logMessage` that:
  - Sends printouts to terminal
  - Only shows on debug and `--profile` modes, not production

---

## Phase 5: UI Systems

### **Icon System**

- **Priority Order**:
  1. Use `heroicons` for icons where they exist
  2. Otherwise use `material_symbols_icons`
  3. Fall back to `ming_cute_icons` for additional coverage
- Create an icon utility file that maps common icon names to appropriate icon package.
- Maintain consistency in icon usage throughout all screens and widgets.

---

### **UI and Theming**

- **Central ThemeData Setup**:
  - Dark/light themes
  - No color, just black, whites, greys (modern theme)
  - Modern snackbar design
  - Modern simple theme data to make Material 3 design less ugly
  - Remove ugly purple default
  - Consistent theme and responsive layout baked in
- **Responsive Helpers**: `ScreenUtil`, `LayoutBuilder`, etc. so all apps scale nicely.
- **Base AppScaffold Widget**: Handles padding, snackbars, safe areas, etc.
- **Sliver App Bars**: Use throughout the app.
- **Reusable Components**: Buttons, text fields, forms with validation.

---

### **Sliver Layout System**

- Use Sliver-based layouts throughout the app for flexible scrolling behavior and dynamic app bars.
- **Implementation**:
  - Use `CustomScrollView` with `SliverAppBar`, `SliverList`, and `SliverToBoxAdapter`
  - Avoid static `Column` + `SingleChildScrollView` patterns
- **Benefits**:
  - Collapsible headers
  - Floating or pinned app bars
  - Smooth transitions on scroll
- Create a reusable `AppSliverScaffold` widget that wraps `CustomScrollView` and handles:
  - Sliver app bar
  - Padding
  - Safe area
  - Optional pull-to-refresh
- Ensure sliver layouts remain responsive by combining with custom breakpoint system.

---

### **Responsive System**

- Use `LayoutBuilder` and `MediaQuery` for custom responsive layout system.
- **Avoid** third-party libraries like `responsive_framework`.
- Define breakpoints for mobile, tablet, and desktop in a single `responsive.dart` file.
- Create a `ResponsiveScaffold` widget that automatically switches between layouts based on screen width.
- Add `BuildContext` extensions:
  - `isMobile`
  - `isTablet`
  - `isDesktop`
- Use `flutter_screenutil` for consistent text and spacing scaling across devices.
- **Adaptive Layouts**:
  - Bottom navigation on mobile
  - Sidebar navigation on tablet/desktop
- Ensure all pages look good across different screen sizes.

---

### **Offline and Loading States**

- **Optional but useful**:
  - Global loading overlay or skeleton loader widget for async operations
  - Gracefully handle loss of internet connection (e.g., offline banner)

---

## Phase 6: Quality Assurance

### **Testing**

- Include basic example tests under `/test`:
  - Unit tests
  - Widget tests
  - Integration tests
- **Purpose**: Validate core systems (auth UI, logging, routing) and provide ready testing framework.
- **Mock Supabase**: Use `mocktail` or custom fakes in unit and widget tests for:
  - `SignInScreen`
  - `PaywallScreen`
  - Key business logic
- **Integration Tests**: Verify `go_router` redirects based on auth/subscription guards.
- **Riverpod Testing**: Document how to:
  - Override providers using `ProviderScope(overrides: [...])`
  - Mock Supabase responses or repositories
  - Test business logic without network calls
- Include test examples for Repository/Service layer mocking and Riverpod provider overrides.

---

## Phase 7: Platform Delivery

### **Cross-Platform Configuration and Platform Setup Checklist**

#### iOS
- Update **Info.plist**:
  - Permissions
  - Deep link scheme (`myapp://`)
  - App name
  - ATS settings for Supabase
- Register redirect URLs in Supabase dashboard (`myapp://login-callback`)
- Configure app icons and splash screens

#### Android
- Add `<intent-filter>` for custom deep link scheme
- Include `INTERNET` permission and correct package name
- Configure adaptive icons and splash screens

#### macOS
- Enable network access in entitlements and sandbox settings
- Add icons and correct bundle ID

#### Windows
- Add app manifest with `InternetClient` capability
- Configure icons and metadata in `CMakeLists.txt`

#### Web
- Set meta tags and favicon in `index.html`
- Add Supabase redirect URL (`https://myapp.web.app/login-callback`)
- Ensure `.env` variables are properly exposed or handled via safe config file

#### Platform Setup Checklist
- [ ] Update Info.plist bundle ID and app name
- [ ] Update AndroidManifest package ID and deep links
- [ ] Add Supabase redirect URL to iOS/Android/Web
- [ ] Confirm icons and splash assets are replaced
- [ ] Verify auth flow on all platforms
- [ ] Test subscription flow on iOS and Android
- [ ] Run flutter build for each platform before release

---

## Phase 8: Documentation & Localization

### **Localization & Internationalization**

- Add at least one localization ARB file (e.g., `lib/l10n/app_en.arb`)
- Include `l10n.yaml` configuration for easy extension
- **Workflow**: Document how to generate localized strings using Flutter gen-l10n tool
- Include `LocalizationsProvider` in Riverpod to manage locale changes
- Make localization accessible throughout the app

---

### **Documentation**

The template must include a detailed `README.md` file that serves as a **developer and AI instruction manual**.

**Must Document**:
- Purpose, structure, dependencies
- Architecture patterns and conventions
- Quick Start instructions (clone → add keys → run)
- Architecture overview diagram (auth flow, paywall, routing)
- Common gotchas and extension points (where to inject new features, how to override theme)
- Testing and linting commands with expected output

**Goal**: Make it possible for an AI or new developer to understand how everything works, what conventions to follow, and how to safely extend or modify the project.

---

## Quick Start
```bash
# Clone the template
git clone <repository-url>
cd flutter_app_template

# Copy environment configuration
cp .env.example .env

# Install dependencies
flutter pub get

# Generate code for freezed/json_serializable
flutter pub run build_runner build

# Run the app
flutter run
```

---

## Common Gotchas

- Always initialize Supabase and dotenv before `runApp`
- Use `flutter_secure_storage` for tokens, never `SharedPreferences`
- Mock Supabase responses in tests using `mocktail`
- Override Riverpod providers in tests with `ProviderScope(overrides: [])`
- Use Sliver layouts for all scrollable content
- Test deep linking on both iOS and Android before release
- Verify RLS policies are enabled on all Supabase tables

---

## Extension Points

- Add new features under `lib/features/`
- Create new repositories under `lib/repositories/`
- Add new providers under `lib/providers/`
- Extend theme in `lib/core/theme/`
- Add new widgets in `lib/shared/widgets/`
- Add new models in `lib/models/`

---

## Testing Commands
```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Format code
flutter format .

# Lint code
flutter analyze
```