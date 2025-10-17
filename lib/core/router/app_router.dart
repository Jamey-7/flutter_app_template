import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/screens/login_screen.dart';
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
      final isOnPaywallPage = state.matchedLocation == '/paywall';
      final isOnHomePage = state.matchedLocation == '/home';
      final isOnLoadingPage = state.matchedLocation == '/loading';

      if (!appState.isLoading && isOnLoadingPage) {
        return isAuthenticated
            ? (hasActiveSubscription ? '/home' : '/paywall')
            : '/login';
      }

      // If not authenticated, redirect to login
      if (!isAuthenticated && !isOnLoginPage) {
        return '/login';
      }

      // If authenticated but on login page, redirect to home
      if (isAuthenticated && isOnLoginPage) {
        return '/home';
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
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
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
    ],
  );

  // Dispose router when provider is disposed
  ref.onDispose(router.dispose);

  return router;
});
