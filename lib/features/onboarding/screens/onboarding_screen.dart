import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_themes.dart';
import '../../../core/responsive/breakpoints.dart';
import '../../../core/services/rate_service.dart';
import '../../../core/providers/language_provider.dart';
import '../../settings/widgets/language_selector_dialog.dart';
import '../../../shared/widgets/app_button.dart';

/// Onboarding screen with 3 pages
/// Shows app introduction, key features, and rating request before signup
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Navigate to signup after last page (push so user can go back)
      context.push('/signup');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLanguage = ref.watch(languageProvider);

    // Force Default Dark theme for onboarding
    return Theme(
      data: AppTheme.fromThemeData(AppThemeData.defaultTheme()),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            body: SafeArea(
        child: Column(
          children: [
            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  _buildPage1(context),
                  _buildPage2(context),
                  _buildPage3(context),
                ],
              ),
            ),

            // Bottom section with indicators and button
            Padding(
              padding: EdgeInsets.all(context.responsivePadding),
              child: Column(
                children: [
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildPageIndicator(0, context),
                      const SizedBox(width: AppSpacing.sm),
                      _buildPageIndicator(1, context),
                      const SizedBox(width: AppSpacing.sm),
                      _buildPageIndicator(2, context),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Next button (only show on pages 0 and 1)
                  if (_currentPage < 2)
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: AppButton.primary(
                        text: 'Next',
                        onPressed: _nextPage,
                        icon: Icons.arrow_forward_ios,
                        isFullWidth: true,
                      ),
                    ),

                  // Rating buttons (only show on page 2)
                  if (_currentPage == 2)
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Row(
                        children: [
                          // Later button
                          Expanded(
                            child: AppButton.text(
                              text: 'Later',
                              onPressed: _handleSkipRating,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          // Rate App button
                          Expanded(
                            child: AppButton.primary(
                              text: 'Rate App',
                              onPressed: _handleRateApp,
                              icon: Icons.star,
                              isFullWidth: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPageIndicator(int pageIndex, BuildContext context) {
    final isActive = _currentPage == pageIndex;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.outline,
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
    );
  }

  Widget _buildPage1(BuildContext context) {
    final currentLanguage = ref.watch(languageProvider);

    return Padding(
      padding: EdgeInsets.all(context.responsivePadding),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Hero icon
            Container(
              padding: EdgeInsets.all(context.responsive<double>(
                smallMobile: AppSpacing.lg,
                mobile: AppSpacing.xl,
                tablet: AppSpacing.xl,
                desktop: AppSpacing.xl,
              )),
              decoration: BoxDecoration(
                color: context.colors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.flutter_dash,
                size: context.responsive<double>(
                  smallMobile: 70,
                  mobile: 100,
                  tablet: 100,
                  desktop: 100,
                ),
                color: context.colors.primary,
              ),
            ),
            SizedBox(height: context.responsive<double>(
              smallMobile: AppSpacing.lg,
              mobile: AppSpacing.xl,
              tablet: AppSpacing.xl,
              desktop: AppSpacing.xl,
            )),

            // Title
            Text(
              'Welcome to\nApp Template',
              style: (context.responsive<bool>(
                smallMobile: true,
                mobile: false,
                tablet: false,
                desktop: false,
              ))
                  ? context.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    )
                  : context.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),

            // Subtitle
            Text(
              'Your powerful subscription-based app\nbuilt with Flutter',
              style: context.textTheme.titleMedium?.copyWith(
                color: context.colors.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.responsive<double>(
              smallMobile: AppSpacing.md,
              mobile: AppSpacing.lg,
              tablet: AppSpacing.xxl,
              desktop: AppSpacing.xxl,
            )),

            // Language selector button
            GestureDetector(
              onTap: () {
                LanguageSelectorDialog.show(context);
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.responsive<double>(
                    smallMobile: AppSpacing.md,
                    mobile: AppSpacing.lg,
                    tablet: AppSpacing.lg,
                    desktop: AppSpacing.lg,
                  ),
                  vertical: context.responsive<double>(
                    smallMobile: AppSpacing.sm,
                    mobile: AppSpacing.sm,
                    tablet: AppSpacing.md,
                    desktop: AppSpacing.md,
                  ),
                ),
                decoration: BoxDecoration(
                  color: context.colors.onSurface.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      currentLanguage.flag,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      currentLanguage.nativeName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: context.colors.onSurface,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 20,
                      color: context.colors.onSurface.withValues(alpha: 0.6),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage2(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(context.responsivePadding),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Hero icon
            Container(
              padding: EdgeInsets.all(context.responsive<double>(
                smallMobile: AppSpacing.lg,
                mobile: AppSpacing.xl,
                tablet: AppSpacing.xl,
                desktop: AppSpacing.xl,
              )),
              decoration: BoxDecoration(
                color: context.colors.secondary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.workspace_premium,
                size: context.responsive<double>(
                  smallMobile: 70,
                  mobile: 100,
                  tablet: 100,
                  desktop: 100,
                ),
                color: context.colors.secondary,
              ),
            ),
            SizedBox(height: context.responsive<double>(
              smallMobile: AppSpacing.lg,
              mobile: AppSpacing.xl,
              tablet: AppSpacing.xl,
              desktop: AppSpacing.xl,
            )),

            // Title
            Text(
              'Everything You Need',
              style: (context.responsive<bool>(
                smallMobile: true,
                mobile: false,
                tablet: false,
                desktop: false,
              ))
                  ? context.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    )
                  : context.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),

            // Subtitle
            Text(
              'Start your journey with these amazing features',
              style: context.textTheme.titleMedium?.copyWith(
                color: context.colors.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage3(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(context.responsivePadding),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Hero icon - Star
            Container(
              padding: EdgeInsets.all(context.responsive<double>(
                smallMobile: AppSpacing.lg,
                mobile: AppSpacing.xl,
                tablet: AppSpacing.xl,
                desktop: AppSpacing.xl,
              )),
              decoration: BoxDecoration(
                color: context.colors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.star,
                size: context.responsive<double>(
                  smallMobile: 70,
                  mobile: 100,
                  tablet: 100,
                  desktop: 100,
                ),
                color: context.colors.primary,
              ),
            ),
            SizedBox(height: context.responsive<double>(
              smallMobile: AppSpacing.lg,
              mobile: AppSpacing.xl,
              tablet: AppSpacing.xl,
              desktop: AppSpacing.xl,
            )),

            // Title
            Text(
              'Help Us Grow!',
              style: (context.responsive<bool>(
                smallMobile: true,
                mobile: false,
                tablet: false,
                desktop: false,
              ))
                  ? context.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    )
                  : context.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),

            // Subtitle
            Text(
              'Your rating helps us reach more users and improve the app',
              style: context.textTheme.titleMedium?.copyWith(
                color: context.colors.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _handleRateApp() async {
    // Show the native rating dialog
    await RateService.showRatingDialog(context);

    // Navigate to signup after rating
    if (mounted) {
      context.push('/signup');
    }
  }

  void _handleSkipRating() async {
    // Track that user skipped - will remind later
    await RateService.handleSkip();

    // Navigate to signup
    if (mounted) {
      context.push('/signup');
    }
  }

}
