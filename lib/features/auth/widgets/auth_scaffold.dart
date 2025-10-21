import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/responsive/breakpoints.dart';

/// Reusable scaffold for auth screens with background image and gradient overlay
class AuthScaffold extends StatelessWidget {
  final Widget child;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Widget? topRightAction;

  const AuthScaffold({
    super.key,
    required this.child,
    this.showBackButton = true,
    this.onBackPressed,
    this.topRightAction,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Stack(
          children: [
            // Background Image
            Image.asset(
              'assets/images/login-image.png',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),

            // Gradient Overlay - uses AppGradients from theme
            Container(
              decoration: const BoxDecoration(
                gradient: AppGradients.darkOverlay,
              ),
            ),

            // Main content with responsive layout
            SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: screenHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      // Top spacing for status bar
                      SizedBox(height: topPadding),

                      // Top bar with back button and action button
                      Padding(
                        padding: const EdgeInsets.only(left: 12, right: 16, top: 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Back button
                            if (showBackButton)
                              IconButton(
                                icon: const Icon(
                                  Icons.arrow_back_ios,
                                  color: AppColors.white,
                                  size: 24,
                                ),
                                onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
                              )
                            else
                              const SizedBox(width: 48), // Spacer to maintain layout

                            // Top right action button
                            if (topRightAction != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: topRightAction!,
                              )
                            else
                              const SizedBox.shrink(),
                          ],
                        ),
                      ),

                      // Flexible spacer for centering on tablet/desktop
                      if (!context.isMobile) const Spacer(),

                      // Main content
                      Transform.translate(
                        offset: context.responsive<Offset>(
                          mobile: Offset.zero,
                          tablet: const Offset(0, -20),
                          desktop: const Offset(0, -20),
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: context.responsive<double>(
                              mobile: context.screenWidth,
                              tablet: 600,
                              desktop: 500,
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: context.responsiveHorizontalPadding,
                            ),
                            child: child,
                          ),
                        ),
                      ),

                      // Flexible spacer for centering on tablet/desktop
                      if (!context.isMobile) const Spacer(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
