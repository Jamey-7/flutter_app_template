import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_themes.dart';
import '../../../core/responsive/breakpoints.dart';
import '../../../core/services/rate_service.dart';
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

                  // Next/Get Started button (only show on pages 0 and 1)
                  if (_currentPage < 2)
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: AppButton.primary(
                        text: _currentPage == 1 ? 'Next' : 'Next',
                        onPressed: _nextPage,
                        icon: Icons.arrow_forward_ios,
                        isFullWidth: true,
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
    return Padding(
      padding: EdgeInsets.all(context.responsivePadding),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Hero icon
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: context.colors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.flutter_dash,
                size: 100,
                color: context.colors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Title
            Text(
              'Welcome to\nApp Template',
              style: context.textTheme.displaySmall?.copyWith(
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
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: context.colors.secondary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.workspace_premium,
                size: 100,
                color: context.colors.secondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Title
            Text(
              'Everything You Need',
              style: context.textTheme.displaySmall?.copyWith(
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
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: context.colors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.star,
                size: context.responsive<double>(
                  mobile: 100,
                  tablet: 120,
                  desktop: 140,
                ),
                color: context.colors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Title
            Text(
              'Help Us Grow!',
              style: context.textTheme.displaySmall?.copyWith(
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
            const SizedBox(height: AppSpacing.xl),

            // Benefits list
            _buildBenefitsList(context),
            const SizedBox(height: AppSpacing.xxl),

            // Buttons
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Not Right Now button
                  Expanded(
                    child: AppButton.text(
                      text: 'Not Right Now',
                      onPressed: _handleSkipRating,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  // Rate App button
                  Expanded(
                    flex: 2,
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
    );
  }

  Widget _buildBenefitsList(BuildContext context) {
    final benefits = [
      'Support independent developers',
      'Help us add features you love',
      'Only takes 5 seconds',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: benefits.map((benefit) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: context.colors.primary,
                size: 24,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  benefit,
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: context.colors.onSurface,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
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
