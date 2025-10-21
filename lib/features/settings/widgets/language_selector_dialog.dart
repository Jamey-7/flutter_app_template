import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/responsive/breakpoints.dart';

class LanguageSelectorDialog extends ConsumerWidget {
  const LanguageSelectorDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const LanguageSelectorDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLanguage = ref.watch(languageProvider);
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.7, // Start at 70% screen height
      minChildSize: 0.25, // Can't be smaller than 25%
      maxChildSize: 0.94, // Max height is 94% of screen
      snap: true, // Enable snapping
      snapSizes: const [0.7, 0.94], // Snap points at 70% and 94%
      builder: (BuildContext context, ScrollController scrollController) {
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
                // Drag handle (FIXED - always visible)
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
                // Scrollable content (header + languages)
                Expanded(
                  child: ListView(
                    controller: scrollController, // Connect to DraggableScrollableSheet
                    physics: const ClampingScrollPhysics(),
                    children: [
                      // Header
                      Padding(
                        padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.sm),
                        child: Text(
                          'Choose Language',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      // Description
                      Padding(
                        padding: EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
                        child: Text(
                          'Select your preferred language',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                      // Language options
                      ...AppLanguage.values.map((language) {
                        final isSelected = currentLanguage == language;

                        return _LanguageOption(
                          language: language,
                          isSelected: isSelected,
                          theme: theme,
                          onTap: () {
                            ref.read(languageProvider.notifier).setLanguage(language);
                          },
                        );
                      }),
                      SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final AppLanguage language;
  final bool isSelected;
  final ThemeData theme;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.language,
    required this.isSelected,
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
              // Flag SVG
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
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
                alignment: Alignment.center,
                padding: EdgeInsets.all(AppSpacing.sm),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.small - 2),
                  child: SvgPicture.asset(
                    language.flagPath,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.md),
              // Language info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      language.englishName,
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
                    SizedBox(height: AppSpacing.xxs),
                    Text(
                      language.nativeName,
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
