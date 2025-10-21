import 'package:flutter/material.dart';
import 'package:rate_my_app/rate_my_app.dart';

/// Service for handling app rating requests using rate_my_app package
///
/// This service manages when and how to show app rating dialogs,
/// including tracking user interactions and respecting their preferences.
class RateService {
  static RateMyApp? _rateMyApp;

  /// Initialize the RateMyApp instance
  ///
  /// Configuration:
  /// - minDays: 0 (can show during onboarding)
  /// - minLaunches: 1 (after first launch)
  /// - remindDays: 3 (ask again 3 days after "Not Right Now")
  /// - remindLaunches: 5 (ask again after 5 more launches)
  ///
  /// Note: You need to replace the identifiers with your actual app IDs:
  /// - googlePlayIdentifier: Your app's package name (e.g., 'com.example.app')
  /// - appStoreIdentifier: Your app's numeric ID from App Store Connect
  static Future<RateMyApp> _getRateMyApp() async {
    if (_rateMyApp != null) {
      return _rateMyApp!;
    }

    _rateMyApp = RateMyApp(
      preferencesPrefix: 'rateMyApp_',
      minDays: 0,
      minLaunches: 1,
      remindDays: 3,
      remindLaunches: 5,
      // TODO: Replace with your actual app identifiers
      googlePlayIdentifier: 'com.yourcompany.appname',
      appStoreIdentifier: '1234567890',
    );

    await _rateMyApp!.init();
    return _rateMyApp!;
  }

  /// Check if the rating dialog should be shown
  ///
  /// Returns true if conditions are met (days, launches, etc.)
  static Future<bool> shouldShow() async {
    final rateMyApp = await _getRateMyApp();
    return rateMyApp.shouldOpenDialog;
  }

  /// Show the native store rating dialog
  ///
  /// This displays the platform-specific rating interface:
  /// - iOS: In-app rating dialog (iOS 10.3+)
  /// - Android: Redirects to Play Store
  ///
  /// The dialog will automatically handle the "Rate" action.
  /// Returns a Future that completes when dialog is dismissed.
  static Future<void> showRatingDialog(BuildContext context) async {
    final rateMyApp = await _getRateMyApp();

    if (!rateMyApp.shouldOpenDialog) {
      return;
    }

    // Show the native rating dialog
    // ignore: use_build_context_synchronously
    await rateMyApp.showRateDialog(
      context,
      title: 'Rate Our App',
      message: 'If you like this app, please take a moment to rate it!',
      rateButton: 'RATE',
      noButton: 'NO THANKS',
      laterButton: 'MAYBE LATER',
      listener: (button) {
        switch (button) {
          case RateMyAppDialogButton.rate:
            debugPrint('User clicked: Rate');
          case RateMyAppDialogButton.later:
            debugPrint('User clicked: Maybe Later');
          case RateMyAppDialogButton.no:
            debugPrint('User clicked: No Thanks');
        }
        return true;
      },
    );
  }

  /// Mark the rating dialog as shown without actually showing it
  ///
  /// This is useful when you want to track that the user saw
  /// the rating screen but didn't interact with it.
  static Future<void> markAsShown() async {
    final rateMyApp = await _getRateMyApp();
    await rateMyApp.callEvent(RateMyAppEventType.laterButtonPressed);
  }

  /// User clicked "Not Right Now" - track for remind later functionality
  ///
  /// This will set up the remind conditions (3 days or 5 launches)
  /// so the rating request appears again in the future.
  static Future<void> handleSkip() async {
    final rateMyApp = await _getRateMyApp();
    await rateMyApp.callEvent(RateMyAppEventType.laterButtonPressed);
    debugPrint('Rating skipped - will remind after 3 days or 5 launches');
  }

  /// User declined to rate - never ask again
  ///
  /// This permanently dismisses the rating request.
  static Future<void> handleDecline() async {
    final rateMyApp = await _getRateMyApp();
    await rateMyApp.callEvent(RateMyAppEventType.noButtonPressed);
    debugPrint('Rating declined - will not ask again');
  }

  /// User rated the app - mark as completed
  ///
  /// This marks the rating as done and won't ask again.
  static Future<void> handleRated() async {
    final rateMyApp = await _getRateMyApp();
    await rateMyApp.callEvent(RateMyAppEventType.rateButtonPressed);
    debugPrint('User rated the app');
  }

  /// Reset all rating preferences (useful for testing)
  ///
  /// WARNING: Only use this during development/testing.
  /// DO NOT call this in production code.
  static Future<void> resetForTesting() async {
    final rateMyApp = await _getRateMyApp();
    await rateMyApp.reset();
    debugPrint('Rating preferences reset');
  }
}
