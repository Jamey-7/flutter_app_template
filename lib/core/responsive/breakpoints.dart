import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 1200;

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobile;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobile && width < tablet;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tablet;
  }
}

extension ResponsiveExtensions on BuildContext {
  bool get isMobile => Breakpoints.isMobile(this);
  bool get isTablet => Breakpoints.isTablet(this);
  bool get isDesktop => Breakpoints.isDesktop(this);

  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;

  double get responsivePadding {
    if (isMobile) return AppSpacing.md;
    if (isTablet) return AppSpacing.lg;
    return AppSpacing.xl;
  }

  double get responsiveCardPadding {
    if (isMobile) return AppSpacing.md;
    if (isTablet) return AppSpacing.lg;
    return AppSpacing.xl;
  }

  double get responsiveHorizontalPadding {
    if (isMobile) return AppSpacing.md;
    if (isTablet) return AppSpacing.xl;
    return AppSpacing.xxl;
  }

  double get maxContentWidth {
    if (isMobile) return screenWidth;
    if (isTablet) return 800;
    return 1200;
  }

  T responsive<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop && desktop != null) return desktop;
    if (isTablet && tablet != null) return tablet;
    return mobile;
  }
}

class ResponsivePadding extends StatelessWidget {
  final Widget child;

  const ResponsivePadding({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(context.responsivePadding),
      child: child,
    );
  }
}

class ResponsiveCenter extends StatelessWidget {
  final Widget child;

  const ResponsiveCenter({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: context.maxContentWidth),
        child: child,
      ),
    );
  }
}
