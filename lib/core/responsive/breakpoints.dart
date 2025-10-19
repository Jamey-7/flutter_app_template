import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class Breakpoints {
  static const double smallMobile = 390;
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;

  static bool isSmallMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < smallMobile;
  }

  static bool isMobile(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= smallMobile && width < mobile;
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
  bool get isSmallMobile => Breakpoints.isSmallMobile(this);
  bool get isMobile => Breakpoints.isMobile(this);
  bool get isTablet => Breakpoints.isTablet(this);
  bool get isDesktop => Breakpoints.isDesktop(this);

  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;

  double get responsivePadding {
    if (isDesktop) return AppSpacing.xl;
    if (isTablet) return AppSpacing.lg;
    if (isMobile) return AppSpacing.md;
    return AppSpacing.sm;
  }

  double get responsiveCardPadding {
    if (isDesktop) return AppSpacing.xl;
    if (isTablet) return AppSpacing.lg;
    if (isMobile) return AppSpacing.md;
    return AppSpacing.sm;
  }

  double get responsiveHorizontalPadding {
    if (isDesktop) return AppSpacing.xxl;
    if (isTablet) return AppSpacing.xl;
    if (isMobile) return AppSpacing.md;
    return AppSpacing.sm;
  }

  double get maxContentWidth {
    if (isDesktop) return 1200;
    if (isTablet) return 800;
    if (isMobile) return screenWidth;
    return screenWidth;
  }

  T responsive<T>({
    T? smallMobile,
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop && desktop != null) return desktop;
    if (isTablet && tablet != null) return tablet;
    if (isMobile) return mobile;
    if (isSmallMobile && smallMobile != null) return smallMobile;
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
