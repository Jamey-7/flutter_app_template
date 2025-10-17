# Flutter App Template

**A production-ready Flutter starter with authentication, subscriptions, and state management built-in.**

This template boots with Supabase authentication, RevenueCat subscriptions, and Riverpod 3.0 state management. Just add your API keys and start building features.

## ✨ Features

### Phase 1 & 2 Complete ✅

- ✅ **Authentication** - Supabase email/password auth with session persistence
- ✅ **State Management** - Riverpod 3.0 with providers for auth and subscriptions
- ✅ **Routing** - go_router with authentication and subscription guards
- ✅ **Subscriptions** - RevenueCat integration ready
- ✅ **Error Tracking** - Sentry integration for production monitoring
- ✅ **Type Safety** - Freezed data models with code generation
- ✅ **Logging** - Comprehensive logging with tags
- ✅ **Testing** - Unit tests and testing patterns included
- ✅ **Environment Config** - Secure .env file management

### Coming in Future Phases

- 🔄 Complete auth flows (forgot password, email verification)
- 🔄 Full paywall implementation with RevenueCat products
- 🔄 Settings screen for account management
- 🔄 Modern UI theme system (black/white/grey)
- 🔄 Responsive layouts for mobile/tablet/desktop
- 🔄 Networking layer with Dio
- 🔄 Localization support

## 🚀 Quick Start

### 1. Prerequisites

- Flutter SDK 3.9.2+
- [Supabase account](https://supabase.com) (free tier works)
- Optional: [RevenueCat](https://revenuecat.com) for subscriptions
- Optional: [Sentry](https://sentry.io) for error tracking

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure Environment

```bash
cp .env.example .env
```

Edit `.env` with your keys:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your_anon_key_here
REVENUECAT_API_KEY=your_revenuecat_key  # Optional
SENTRY_DSN=your_sentry_dsn              # Optional
```

**Get Supabase keys:**
1. Create project at [supabase.com](https://supabase.com)
2. Go to Project Settings → API
3. Copy Project URL and anon public key

### 4. Generate Code

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 5. Run

```bash
flutter run
```

**See [QUICKSTART.md](QUICKSTART.md) for detailed setup instructions.**

## 📁 Project Structure

```
lib/
├── core/
│   ├── logger/              # Logging service with Sentry
│   ├── router/              # go_router with guards
│   ├── provider_observer.dart
│   └── supabase_client.dart
├── features/
│   ├── auth/
│   │   └── screens/         # Login/signup screens
│   ├── home/
│   │   └── screens/         # Protected home screen
│   └── subscriptions/
│       └── screens/         # Paywall screen
├── models/                  # Freezed data models
│   ├── app_state.dart
│   └── subscription_info.dart
├── providers/               # Riverpod 3.0 providers
│   ├── auth_provider.dart
│   ├── subscription_provider.dart
│   └── app_state_provider.dart
├── app.dart                 # App widget with theme
└── main.dart                # Entry point with initialization
```

## 🏗️ Architecture

### State Management

**Riverpod 3.0** with three core providers:

1. **`currentUserProvider`** - Streams Supabase auth state
2. **`subscriptionProvider`** - Fetches RevenueCat subscription status
3. **`appStateProvider`** - Combines auth + subscription into single state

### Data Flow

```
Supabase Auth ──→ currentUserProvider ──┐
                                        ├──→ appStateProvider ──→ UI
RevenueCat ────→ subscriptionProvider ──┘
```

### Route Guards

```
User State              → Route
─────────────────────────────────────
Not authenticated       → /login
Authenticated + no sub  → /paywall
Authenticated + sub     → /home
```

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Analyze code
flutter analyze

# Format code
flutter format .
```

## 📚 Documentation

- **[QUICKSTART.md](QUICKSTART.md)** - Get running in 5 minutes
- **[PHASE_2_COMPLETE.md](PHASE_2_COMPLETE.md)** - Detailed implementation guide
- **[Project_Plan.md](Project_Plan.md)** - Complete roadmap with all phases

## 🔧 Key Technologies

| Technology | Purpose | Version |
|------------|---------|---------|
| **Flutter** | Framework | 3.9.2+ |
| **Riverpod** | State management | 3.0.3 |
| **Supabase** | Auth & database | 2.9.1 |
| **RevenueCat** | Subscriptions | 9.8.0 |
| **go_router** | Navigation | 14.6.2 |
| **Freezed** | Data models | 3.0.0 |
| **Sentry** | Error tracking | 8.11.0 |
| **Dio** | HTTP client | 5.9.0 |

## 🎯 What Makes This Template Special

### Plug-and-Play
- Add API keys → Run → Everything works
- No manual database setup
- No boilerplate state management
- Pre-configured error tracking

### Production Ready
- Environment validation with helpful errors
- Comprehensive logging throughout
- Sentry integration for monitoring
- Type-safe data models
- Route guards for security

### Modern Stack
- Riverpod 3.0 (latest patterns)
- Material 3 theming
- Freezed for immutability
- Auto-dispose providers for memory efficiency

### Developer Experience
- Clear error messages
- Tagged logging for debugging
- Beautiful UI to visualize state
- Tests included
- Well-documented code

## 🚦 Current Status

**Phase 1 & 2: Complete ✅**

You can:
- ✅ Sign up and sign in with email/password
- ✅ See authentication state in real-time
- ✅ Navigate with automatic route guards
- ✅ View subscription status
- ✅ Sign out and persist sessions
- ✅ Track errors with Sentry

**Next: Phase 3** - Complete auth flows and full paywall implementation

## 🤝 Contributing

This is a template project. Fork it and customize for your needs!

### Extending the Template

1. **Add new features** under `lib/features/`
2. **Create providers** in `lib/providers/`
3. **Add models** in `lib/models/`
4. **Update routes** in `lib/core/router/app_router.dart`
5. **Add tests** in `test/`

## 📝 License

This template is provided as-is for your projects. Customize freely!

## 🆘 Support

### Common Issues

**"Missing required environment variables"**
- Copy `.env.example` to `.env`
- Replace placeholder values with real keys

**"Can't access home screen"**
- Home requires active subscription
- Configure RevenueCat or modify route guard for testing

**Build runner errors**
- Run `flutter clean && flutter pub get`
- Then `flutter pub run build_runner build --delete-conflicting-outputs`

### Resources

- [Supabase Docs](https://supabase.com/docs)
- [RevenueCat Docs](https://docs.revenuecat.com)
- [Riverpod Docs](https://riverpod.dev)
- [go_router Docs](https://pub.dev/packages/go_router)

## 🎉 Ready to Ship

This template gives you:
- ✅ Authentication working
- ✅ State management configured
- ✅ Routes protected
- ✅ Error tracking ready
- ✅ Tests passing
- ✅ Clean architecture

**Just add your features and ship!**
# flutter_app_template
# flutter_app_template
# flutter_app_template
