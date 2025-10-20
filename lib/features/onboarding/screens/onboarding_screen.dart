import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/responsive/breakpoints.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../shared/widgets/app_button.dart';

/// Onboarding screen with 2 pages
/// Shows app introduction and key features before signup
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
    if (_currentPage < 1) {
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Theme toggle button
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              ref.read(themeModeProvider.notifier).toggleTheme();
            },
            tooltip: 'Toggle theme',
          ),
        ],
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
                      _buildPageIndicator(0),
                      const SizedBox(width: AppSpacing.sm),
                      _buildPageIndicator(1),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Next/Get Started button
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: AppButton.primary(
                      text: _currentPage == 1 ? 'Get Started' : 'Next',
                      onPressed: _nextPage,
                      icon: _currentPage == 1 ? Icons.arrow_forward : Icons.arrow_forward_ios,
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

  Widget _buildPageIndicator(int pageIndex) {
    final isActive = _currentPage == pageIndex;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? context.colors.primary : AppColors.grey300,
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
                color: AppColors.textSecondary,
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
                color: AppColors.secondary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.workspace_premium,
                size: 100,
                color: AppColors.secondary,
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
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

}
