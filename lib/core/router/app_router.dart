import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/screens/auth_callback_screen.dart';
import '../../features/auth/screens/email_verification_pending_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/reset_password_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/subscriptions/screens/paywall_screen.dart';
import '../../shared/widgets/loading_screen.dart';
import 'router_refresh_notifier.dart';

/// Router provider with route guards
final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ref.watch(routerRefreshProvider);

  final router = GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: true,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final appState = refreshNotifier.appState;
      
      if (appState.isLoading) {
        return state.matchedLocation == '/loading' ? null : '/loading';
      }

      final isAuthenticated = appState.isAuthenticated;
      final hasActiveSubscription = appState.hasActiveSubscription;

      final isOnLoginPage = state.matchedLocation == '/login';
      final isOnSignupPage = state.matchedLocation == '/signup';
      final isOnForgotPasswordPage = state.matchedLocation == '/forgot-password';
      final isOnResetPasswordPage = state.matchedLocation == '/reset-password';
      final isOnPaywallPage = state.matchedLocation == '/paywall';
      final isOnHomePage = state.matchedLocation == '/home';
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
            ? (hasActiveSubscription ? '/home' : '/paywall')
            : '/login';
      }

      // If not authenticated, redirect to login (except for public auth pages)
      if (!isAuthenticated && !isOnLoginPage) {
        return '/login';
      }

      // If authenticated but on login page, redirect based on subscription
      if (isAuthenticated && isOnLoginPage) {
        return hasActiveSubscription ? '/home' : '/paywall';
      }

      // If authenticated but no subscription and trying to access home
      if (isAuthenticated && !hasActiveSubscription && isOnHomePage) {
        return '/paywall';
      }

      // If has subscription but on paywall, redirect to home
      if (isAuthenticated && hasActiveSubscription && isOnPaywallPage) {
        return '/home';
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
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/paywall',
        name: 'paywall',
        builder: (context, state) => const PaywallScreen(),
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
