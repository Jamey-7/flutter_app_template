import 'package:shared_preferences/shared_preferences.dart';
import '../logger/logger.dart';

/// Service for tracking onboarding completion status
/// Uses SharedPreferences to persist user's onboarding state
class OnboardingService {
  static const String _onboardingKey = 'has_completed_onboarding';

  /// Check if user has completed onboarding
  /// Returns true if onboarding has been completed, false otherwise
  static Future<bool> hasCompletedOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final completed = prefs.getBool(_onboardingKey) ?? false;
      Logger.log(
        'Onboarding completion status: $completed',
        tag: 'OnboardingService',
      );
      return completed;
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to check onboarding status, defaulting to false',
        e,
        stackTrace,
        tag: 'OnboardingService',
      );
      return false;
    }
  }

  /// Mark onboarding as complete
  /// Call this after user signs up or signs in for the first time
  static Future<void> markOnboardingComplete() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_onboardingKey, true);
      Logger.log('Onboarding marked as complete', tag: 'OnboardingService');
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to mark onboarding as complete',
        e,
        stackTrace,
        tag: 'OnboardingService',
      );
    }
  }

  /// Clear onboarding status (for testing or sign out)
  /// Optional: call this on sign out if you want users to see onboarding again
  static Future<void> clearOnboardingStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_onboardingKey);
      Logger.log('Onboarding status cleared', tag: 'OnboardingService');
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to clear onboarding status',
        e,
        stackTrace,
        tag: 'OnboardingService',
      );
    }
  }
}
