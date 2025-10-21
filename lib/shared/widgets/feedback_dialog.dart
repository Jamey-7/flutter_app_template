import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_themes.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/responsive/breakpoints.dart';

/// Feedback dialog that asks users why they're not enjoying the app
///
/// Shows when user clicks "Not Really" on rating prompt
/// Allows users to provide feedback or feature requests
///
/// Returns:
/// - Map with 'submitted' and 'feedback' keys
/// - null should not occur (barrierDismissible: false forces button choice)
class FeedbackDialog extends ConsumerStatefulWidget {
  const FeedbackDialog({super.key});

  /// Show the feedback dialog
  ///
  /// Returns a map with:
  /// - 'submitted': bool (true if Send clicked, false if Later clicked)
  /// - 'feedback': String (the feedback text, empty if none provided)
  static Future<Map<String, dynamic>?> show(BuildContext context) {
    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const FeedbackDialog(),
    );
  }

  @override
  ConsumerState<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends ConsumerState<FeedbackDialog> {
  final TextEditingController _feedbackController = TextEditingController();

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _handleSend() {
    Navigator.of(context).pop({
      'submitted': true,
      'feedback': _feedbackController.text.trim(),
    });
  }

  void _handleLater() {
    Navigator.of(context).pop({
      'submitted': false,
      'feedback': '',
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeType = ref.watch(themeTypeProvider);
    final themeData = themeType.data;

    return Dialog(
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      surfaceTintColor: Colors.transparent,
      insetPadding: context.responsive<EdgeInsets>(
        smallMobile: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.lg,
        ),
        mobile: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        tablet: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.lg,
        ),
        desktop: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl,
          vertical: AppSpacing.lg,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xxlarge),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Chat/Message icon with gradient
              Container(
                width: context.responsive<double>(
                  smallMobile: 48,
                  mobile: 52,
                  tablet: 56,
                  desktop: 56,
                ),
                height: context.responsive<double>(
                  smallMobile: 48,
                  mobile: 52,
                  tablet: 56,
                  desktop: 56,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      themeData.gradientStart.withValues(alpha: 0.15),
                      themeData.gradientEnd.withValues(alpha: 0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.large),
                ),
                child: ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      themeData.gradientStart,
                      themeData.gradientEnd,
                    ],
                  ).createShader(bounds),
                  child: Icon(
                    Icons.chat_bubble_outline,
                    color: Colors.white,
                    size: context.responsive<double>(
                      smallMobile: 24,
                      mobile: 26,
                      tablet: 28,
                      desktop: 28,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Title
              Text(
                'Tell Us Why',
                style: context.textTheme.titleMedium?.copyWith(
                  fontSize: context.responsive<double>(
                    smallMobile: 18,
                    mobile: 20,
                    tablet: 22,
                    desktop: 22,
                  ),
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),

              // Message
              Text(
                'We\'d love to hear your feedback or any features you\'d like to see',
                style: context.textTheme.bodySmall?.copyWith(
                  fontSize: context.responsive<double>(
                    smallMobile: 13,
                    mobile: 14,
                    tablet: 15,
                    desktop: 15,
                  ),
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Feedback text field
              TextField(
                controller: _feedbackController,
                maxLines: 4,
                maxLength: 500,
                decoration: InputDecoration(
                  hintText: 'Share your thoughts... (optional)',
                  hintStyle: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surface.withValues(alpha: 0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                    borderSide: BorderSide(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                    borderSide: BorderSide(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(AppSpacing.md),
                ),
                style: context.textTheme.bodyMedium?.copyWith(
                  fontSize: context.responsive<double>(
                    smallMobile: 14,
                    mobile: 14,
                    tablet: 15,
                    desktop: 15,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Buttons
              Row(
                children: [
                  // Later button
                  Expanded(
                    child: SizedBox(
                      height: context.responsive<double>(
                        smallMobile: 44,
                        mobile: 48,
                        tablet: 48,
                        desktop: 48,
                      ),
                      child: TextButton(
                        onPressed: _handleLater,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: 0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.large),
                          ),
                        ),
                        child: Text(
                          'Later',
                          style: TextStyle(
                            fontSize: context.responsive<double>(
                              smallMobile: 14,
                              mobile: 14,
                              tablet: 14,
                              desktop: 14,
                            ),
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  // Send button
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: context.responsive<double>(
                        smallMobile: 44,
                        mobile: 48,
                        tablet: 48,
                        desktop: 48,
                      ),
                      child: ElevatedButton(
                        onPressed: _handleSend,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: 0,
                          ),
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.large),
                          ),
                        ),
                        child: Text(
                          'Send',
                          style: TextStyle(
                            fontSize: context.responsive<double>(
                              smallMobile: 14,
                              mobile: 14,
                              tablet: 14,
                              desktop: 14,
                            ),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
