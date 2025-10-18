import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/app/screens/app_home_screen.dart';
import '../../features/app/screens/example_feature_screen.dart';
import '../../features/auth/screens/auth_callback_screen.dart';
import '../../features/auth/screens/email_verification_pending_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/reset_password_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/welcome/screens/welcome_screen.dart';
import '../../features/settings/screens/change_email_screen.dart';
import '../../features/settings/screens/change_password_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/subscriptions/screens/paywall_screen.dart';
import '../../features/subscriptions/screens/subscription_details_screen.dart';
import '../../shared/widgets/loading_screen.dart';
import '../logger/logger.dart';
import 'router_refresh_notifier.dart';

/// Router provider with route guards
final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ref.watch(routerRefreshProvider);

  final router = GoRouter(
    initialLocation: '/welcome',
    debugLogDiagnostics: true,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final appState = refreshNotifier.appState;
      
      if (appState.isLoading) {
        return state.matchedLocation == '/loading' ? null : '/loading';
      }

      // Exit loading screen on auth/subscription errors
      if (appState.hasError && state.matchedLocation == '/loading') {
        Logger.warning(
          'Exiting loading screen due to app state error',
          tag: 'Router',
        );
        return '/welcome';
      }

      final isAuthenticated = appState.isAuthenticated;
      final hasActiveSubscription = appState.hasActiveSubscription;

      final isOnWelcomePage = state.matchedLocation == '/welcome';
      final isOnLoginPage = state.matchedLocation == '/login';
      final isOnSignupPage = state.matchedLocation == '/signup';
      final isOnForgotPasswordPage = state.matchedLocation == '/forgot-password';
      final isOnResetPasswordPage = state.matchedLocation == '/reset-password';
      final isOnAppRoute = state.matchedLocation.startsWith('/app');
      final isOnPaywallPage = state.matchedLocation == '/paywall';
      final isOnSettingsRoute = state.matchedLocation.startsWith('/settings');
      final isOnLoadingPage = state.matchedLocation == '/loading';
      final isOnAuthCallback = state.matchedLocation == '/auth-callback';
      final isOnEmailVerificationPending =
          state.matchedLocation == '/email-verification-pending';

      // Allow auth-related pages without authentication check
      if (isOnAuthCallback ||
          isOnSignupPage ||
          isOnForgotPasswordPage ||
          isOnResetPasswordPage ||
          isOnEmailVerificationPending) {
        return null;
      }

      if (!appState.isLoading && isOnLoadingPage) {
        return isAuthenticated
            ? (hasActiveSubscription ? '/app' : '/welcome')
            : '/welcome';
      }

      // Authenticated users with active subscription skip welcome/login
      if (isAuthenticated && hasActiveSubscription) {
        if (isOnWelcomePage || isOnLoginPage || isOnSignupPage) {
          return '/app';
        }
      }

      // Authenticated users WITHOUT subscription can access welcome, paywall, settings
      if (isAuthenticated && !hasActiveSubscription) {
        // Block access to /app routes - redirect to paywall
        if (isOnAppRoute) {
          return '/paywall';
        }
        // Allow: /welcome, /paywall, /settings
      }

      // Unauthenticated users can only access public routes
      if (!isAuthenticated) {
        // Allow: /welcome, /login, /signup, /forgot-password, /auth-callback
        // Block: /paywall, /settings, /app
        if (isOnPaywallPage || isOnSettingsRoute || isOnAppRoute) {
          return '/welcome';
        }
      }

      // ========================================
      // SUBSCRIPTION GUARD - PAID APP ROUTES
      // ========================================
      // This is the core pattern for gating features behind subscriptions.
      // Any route starting with /app/* requires an active subscription.
      // Free users are automatically redirected to the paywall.
      //
      // To add more protected routes:
      // 1. Create your feature screen in lib/features/app/screens/
      // 2. Add a route under the '/app' group below
      // 3. The guard will automatically protect it
      //
      // Example: If you add '/app/my-feature', users without subscriptions
      // will be redirected to '/paywall' automatically.
      if (isOnAppRoute && !hasActiveSubscription) {
        return '/paywall';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/loading',
        name: 'loading',
        builder: (context, state) => const LoadingScreen(),
      ),
      // ========================================
      // Welcome/Landing Screen (Default Entry)
      // ========================================
      GoRoute(
        path: '/welcome',
        name: 'welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      // ========================================
      // Authentication Routes (Public)
      // ========================================
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/email-verification-pending',
        name: 'email-verification-pending',
        builder: (context, state) {
          final email = state.extra as String? ?? '';
          return EmailVerificationPendingScreen(email: email);
        },
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        name: 'reset-password',
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      // ========================================
      // Protected Routes (Require Authentication)
      // ========================================
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: 'change-email',
            name: 'change-email',
            builder: (context, state) => const ChangeEmailScreen(),
          ),
          GoRoute(
            path: 'change-password',
            name: 'change-password',
            builder: (context, state) => const ChangePasswordScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/paywall',
        name: 'paywall',
        builder: (context, state) => const PaywallScreen(),
      ),
      GoRoute(
        path: '/subscription-details',
        name: 'subscription-details',
        builder: (context, state) => const SubscriptionDetailsScreen(),
      ),
      // ========================================
      // PAID APP ROUTES - Subscription Required
      // ========================================
      // This is where you build your app features!
      //
      // All routes under /app/* are automatically protected by the
      // subscription guard in the redirect logic above.
      //
      // Pattern to follow:
      // 1. Entry point: /app -> AppHomeScreen (welcome + feature list)
      // 2. Features: /app/feature-name -> YourFeatureScreen
      //
      // Users without active subscriptions cannot access these routes.
      // They will be automatically redirected to /paywall.
      //
      // Example features you might add:
      // - /app/analytics
      // - /app/dashboard
      // - /app/tools
      // - /app/settings
      // - /app/export
      // ========================================
      GoRoute(
        path: '/app',
        name: 'app',
        builder: (context, state) => const AppHomeScreen(),
        routes: [
          GoRoute(
            path: 'example-feature',
            name: 'example-feature',
            builder: (context, state) => const ExampleFeatureScreen(),
          ),
          // TODO: Add your feature routes here
          // GoRoute(
          //   path: 'your-feature',
          //   name: 'your-feature',
          //   builder: (context, state) => const YourFeatureScreen(),
          // ),
        ],
      ),
      // Auth callback route for deep links (password reset, email verification)
      GoRoute(
        path: '/auth-callback',
        name: 'auth-callback',
        builder: (context, state) {
          final uri = state.uri;
          return AuthCallbackScreen(
            type: uri.queryParameters['type'],
            accessToken: uri.queryParameters['access_token'],
            refreshToken: uri.queryParameters['refresh_token'],
          );
        },
      ),
    ],
  );

  // Dispose router when provider is disposed
  ref.onDispose(router.dispose);

  return router;
});
