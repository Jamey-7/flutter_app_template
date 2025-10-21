import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';

import '../../auth/providers/auth_provider.dart';
import '../../subscriptions/providers/subscription_provider.dart';
import '../../../core/theme/app_themes.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/services/onboarding_service.dart';
import '../../../shared/widgets/app_dialog.dart';
import '../../../shared/widgets/app_snack_bar.dart';
import '../widgets/theme_selector_dialog.dart';
import '../widgets/language_selector_dialog.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 22),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Not signed in'));
          }

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              const SizedBox(height: 16),

              // Premium Unlock Card (only for free users)
              const _PremiumUnlockCard(),

              // Email Section
              _buildSectionHeader('Email', context),
              _buildSettingsTile(
                icon: Icons.email_outlined,
                title: user.email ?? 'No email',
                context: context,
                onTap: () {},
              ),

              const SizedBox(height: 20),

              // Subscription Section
              _buildSectionHeader('Subscription', context),
              const _SubscriptionTile(),

              const SizedBox(height: 20),

              // General Section
              _buildSectionHeader('General', context),
              _buildSettingsTile(
                icon: Icons.palette_outlined,
                title: 'Theme',
                trailing: ref.watch(themeTypeProvider).displayName,
                context: context,
                onTap: () {
                  ThemeSelectorDialog.show(context);
                },
              ),
              _buildDivider(context),
              _buildSettingsTileWithHeroIcon(
                heroIcon: HeroIcons.language,
                title: 'Language',
                trailing: ref.watch(languageProvider).nativeName,
                context: context,
                onTap: () {
                  LanguageSelectorDialog.show(context);
                },
              ),
              _buildDivider(context),
              _buildSettingsTile(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                context: context,
                onTap: () {},
              ),
              _buildDivider(context),
              _buildSettingsTile(
                icon: Icons.help_outline,
                title: 'Help Center',
                context: context,
                onTap: () {},
              ),

              const SizedBox(height: 20),

              // Account Section
              _buildSectionHeader('Account', context),
              _buildSettingsTile(
                icon: Icons.email_outlined,
                title: 'Change Email',
                context: context,
                onTap: () => context.push('/settings/change-email'),
              ),
              _buildDivider(context),
              _buildSettingsTile(
                icon: Icons.lock_outline,
                title: 'Change Password',
                context: context,
                onTap: () => context.push('/settings/change-password'),
              ),
              _buildDivider(context),
              _buildSettingsTile(
                icon: Icons.delete_outline,
                title: 'Delete Account',
                context: context,
                onTap: () => _showDeleteAccountDialog(context, ref),
                isDestructive: true,
              ),

              const SizedBox(height: 20),

              // Legal Section
              _buildSectionHeader('Legal', context),
              _buildSettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                context: context,
                onTap: () {},
              ),
              _buildDivider(context),
              _buildSettingsTile(
                icon: Icons.description_outlined,
                title: 'Terms & Conditions',
                context: context,
                onTap: () {},
              ),
              _buildDivider(context),
              _buildSettingsTile(
                icon: Icons.info_outline,
                title: 'Disclaimer',
                context: context,
                onTap: () {},
              ),

              const SizedBox(height: 24),

              // Sign Out Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _handleSignOut(context, ref),
                    icon: const Icon(Icons.logout, size: 16),
                    label: const Text('Sign Out'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildSectionHeader(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? trailing,
    required BuildContext context,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final effectiveColor = isDestructive ? theme.colorScheme.error : theme.colorScheme.onSurface;
    final effectiveIconColor = isDestructive ? theme.colorScheme.error : theme.colorScheme.onSurface.withValues(alpha: 0.7);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              Icon(
                icon,
                size: 22,
                color: effectiveIconColor,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: effectiveColor,
                  ),
                ),
              ),
              if (trailing != null)
                Text(
                  trailing,
                  style: TextStyle(
                    fontSize: 15,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              const SizedBox(width: 6),
              Icon(
                Icons.chevron_right,
                size: 18,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTileWithHeroIcon({
    required HeroIcons heroIcon,
    required String title,
    String? trailing,
    required BuildContext context,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final effectiveColor = isDestructive ? theme.colorScheme.error : theme.colorScheme.onSurface;
    final effectiveIconColor = isDestructive ? theme.colorScheme.error : theme.colorScheme.onSurface.withValues(alpha: 0.7);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              HeroIcon(
                heroIcon,
                size: 22,
                color: effectiveIconColor,
                style: HeroIconStyle.outline,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: effectiveColor,
                  ),
                ),
              ),
              if (trailing != null)
                Text(
                  trailing,
                  style: TextStyle(
                    fontSize: 15,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              const SizedBox(width: 6),
              Icon(
                Icons.chevron_right,
                size: 18,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 52),
      child: Divider(
        height: 1,
        thickness: 0.5,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12),
      ),
    );
  }

  Future<void> _handleSignOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await AppDialog.showConfirmation(
      context,
      title: 'Sign Out',
      message: 'Are you sure you want to sign out?',
      confirmText: 'Sign Out',
      cancelText: 'Cancel',
    );

    if (confirmed == true && context.mounted) {
      try {
        await AuthService.signOut();
        // Clear onboarding status so user goes to onboarding screen
        await OnboardingService.clearOnboardingStatus();
        ref.invalidate(subscriptionProvider);
      } catch (e) {
        if (context.mounted) {
          AppSnackBar.showError(context, 'Failed to sign out');
        }
      }
    }
  }

  Future<void> _showDeleteAccountDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await AppDialog.showConfirmation(
      context,
      title: 'Delete Account?',
      message:
          'This will permanently delete your account and all associated data. This action cannot be undone.',
      confirmText: 'Yes, Delete',
      cancelText: 'Cancel',
    );

    if (confirmed == true && context.mounted) {
      AppSnackBar.showInfo(
        context,
        'Account deletion is not yet implemented. Please contact support.',
      );
    }
  }
}

// Premium Unlock Card Widget
class _PremiumUnlockCard extends ConsumerWidget {
  const _PremiumUnlockCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionAsync = ref.watch(subscriptionProvider);
    final theme = Theme.of(context);
    final themeType = ref.watch(themeTypeProvider);
    final themeData = themeType.data;

    return subscriptionAsync.when(
      data: (subscription) {
        // Only show for free plan users
        if (subscription.isActive) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                themeData.gradientStart,
                themeData.gradientEnd,
              ],
            ),
          ),
          child: Container(
            margin: const EdgeInsets.all(1.5),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(14.5),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => context.go('/paywall'),
                borderRadius: BorderRadius.circular(14.5),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        // Icon
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.workspace_premium,
                            color: theme.colorScheme.primary,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Text Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Unlock Access Now',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Get unlimited access to all features',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Arrow
                        Icon(
                          Icons.arrow_forward_ios,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                          size: 16,
                        ),
                      ],
                    ),
                ),
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }
}

// Subscription Tile Widget
class _SubscriptionTile extends ConsumerWidget {
  const _SubscriptionTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionAsync = ref.watch(subscriptionProvider);
    final theme = Theme.of(context);

    return subscriptionAsync.when(
      data: (subscription) {
        final isActive = subscription.isActive;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (isActive) {
                context.push('/subscription-details');
              } else {
                context.go('/paywall');
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              child: Row(
                children: [
                  Icon(
                    Icons.workspace_premium,
                    size: 22,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subscription.tier.toUpperCase(),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          isActive ? 'Active' : 'Free Plan',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ),
      ),
      error: (error, _) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            ref.invalidate(subscriptionProvider);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  size: 22,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Failed to load subscription',
                    style: TextStyle(
                      fontSize: 15,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                Text(
                  'Retry',
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
