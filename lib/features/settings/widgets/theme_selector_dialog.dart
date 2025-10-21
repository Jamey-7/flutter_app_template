import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_themes.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/responsive/breakpoints.dart';

class ThemeSelectorDialog extends ConsumerWidget {
  const ThemeSelectorDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ThemeSelectorDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeTypeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxlarge)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with handle
            Center(
              child: Container(
                margin: EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.sm),
                width: context.responsive<double>(
                  smallMobile: 36,
                  mobile: 40,
                  tablet: 44,
                  desktop: 44,
                ),
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.sm),
              child: Text(
                'Choose Theme',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
              child: Text(
                'Select your preferred theme',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
            // Theme options
            ...AppThemeType.values.map((themeType) {
              final themeData = themeType.data;
              final isSelected = currentTheme == themeType;

              return _ThemeOption(
                themeType: themeType,
                themeData: themeData,
                isSelected: isSelected,
                isDark: isDark,
                theme: theme,
                onTap: () {
                  ref.read(themeTypeProvider.notifier).setTheme(themeType);
                },
              );
            }),
            SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final AppThemeType themeType;
  final AppThemeData themeData;
  final bool isSelected;
  final bool isDark;
  final ThemeData theme;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.themeType,
    required this.themeData,
    required this.isSelected,
    required this.isDark,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          child: Row(
            children: [
              // Color preview
              Container(
                width: context.responsive<double>(
                  smallMobile: 40,
                  mobile: 44,
                  tablet: 48,
                  desktop: 48,
                ),
                height: context.responsive<double>(
                  smallMobile: 40,
                  mobile: 44,
                  tablet: 48,
                  desktop: 48,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                  gradient: LinearGradient(
                    colors: [
                      themeData.gradientStart,
                      themeData.gradientEnd,
                    ],
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.md),
              // Theme info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          themeType.displayName,
                          style: TextStyle(
                            fontSize: context.responsive<double>(
                              smallMobile: 15,
                              mobile: 16,
                              tablet: 17,
                              desktop: 17,
                            ),
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xxs,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppRadius.small),
                          ),
                          child: Text(
                            themeData.mode == ThemeMode.dark ? 'Dark' : 'Light',
                            style: TextStyle(
                              fontSize: context.responsive<double>(
                                smallMobile: 10,
                                mobile: 11,
                                tablet: 12,
                                desktop: 12,
                              ),
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      themeType.description,
                      style: TextStyle(
                        fontSize: context.responsive<double>(
                          smallMobile: 12,
                          mobile: 13,
                          tablet: 14,
                          desktop: 14,
                        ),
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              // Selected indicator
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: theme.colorScheme.primary,
                  size: context.responsive<double>(
                    smallMobile: 22,
                    mobile: 24,
                    tablet: 26,
                    desktop: 26,
                  ),
                )
              else
                Icon(
                  Icons.circle_outlined,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  size: context.responsive<double>(
                    smallMobile: 22,
                    mobile: 24,
                    tablet: 26,
                    desktop: 26,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
