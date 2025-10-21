import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/providers/auth_provider.dart';
import '../../subscriptions/providers/subscription_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../shared/widgets/app_dialog.dart';
import '../../../shared/widgets/app_snack_bar.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
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

              // Email Section
              _buildSectionHeader('Email', isDark),
              _buildSettingsTile(
                icon: Icons.email_outlined,
                title: user.email ?? 'No email',
                isDark: isDark,
                onTap: () {},
              ),

              const SizedBox(height: 20),

              // Subscription Section
              _buildSectionHeader('Subscription', isDark),
              _SubscriptionTile(ref: ref, isDark: isDark),

              const SizedBox(height: 20),

              // General Section
              _buildSectionHeader('General', isDark),
              _buildToggleTile(
                icon: Icons.dark_mode_outlined,
                title: 'Dark Mode',
                value: ref.watch(themeModeProvider) == ThemeMode.dark,
                isDark: isDark,
                onChanged: (value) {
                  ref.read(themeModeProvider.notifier).toggleTheme();
                },
              ),
              _buildDivider(isDark),
              _buildSettingsTile(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                isDark: isDark,
                onTap: () {},
              ),
              _buildDivider(isDark),
              _buildSettingsTile(
                icon: Icons.help_outline,
                title: 'Help Center',
                isDark: isDark,
                onTap: () {},
              ),

              const SizedBox(height: 20),

              // Account Section
              _buildSectionHeader('Account', isDark),
              _buildSettingsTile(
                icon: Icons.email_outlined,
                title: 'Change Email',
                isDark: isDark,
                onTap: () => context.push('/settings/change-email'),
              ),
              _buildDivider(isDark),
              _buildSettingsTile(
                icon: Icons.lock_outline,
                title: 'Change Password',
                isDark: isDark,
                onTap: () => context.push('/settings/change-password'),
              ),
              _buildDivider(isDark),
              _buildSettingsTile(
                icon: Icons.delete_outline,
                title: 'Delete Account',
                isDark: isDark,
                onTap: () => _showDeleteAccountDialog(context, ref),
                isDestructive: true,
              ),

              const SizedBox(height: 20),

              // Legal Section
              _buildSectionHeader('Legal', isDark),
              _buildSettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                isDark: isDark,
                onTap: () {},
              ),
              _buildDivider(isDark),
              _buildSettingsTile(
                icon: Icons.description_outlined,
                title: 'Terms & Conditions',
                isDark: isDark,
                onTap: () {},
              ),
              _buildDivider(isDark),
              _buildSettingsTile(
                icon: Icons.info_outline,
                title: 'Disclaimer',
                isDark: isDark,
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
                      backgroundColor: isDark ? Colors.white : Colors.black,
                      foregroundColor: isDark ? Colors.black : Colors.white,
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

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white54 : AppColors.grey600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? trailing,
    required bool isDark,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final effectiveColor = isDestructive ? AppColors.error : (isDark ? Colors.white : Colors.black);
    final effectiveIconColor = isDestructive ? AppColors.error : (isDark ? Colors.white70 : AppColors.grey700);

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
                    color: isDark ? Colors.white60 : AppColors.grey600,
                  ),
                ),
              const SizedBox(width: 6),
              Icon(
                Icons.chevron_right,
                size: 18,
                color: isDark ? Colors.white38 : AppColors.grey400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required String title,
    required bool value,
    required bool isDark,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(
            icon,
            size: 22,
            color: isDark ? Colors.white70 : AppColors.grey700,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: value,
              onChanged: onChanged,
              thumbColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return isDark ? Colors.white : Colors.black;
                }
                return isDark ? Colors.white60 : AppColors.grey400;
              }),
              trackColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return isDark
                      ? Colors.white.withValues(alpha: 0.3)
                      : Colors.black.withValues(alpha: 0.3);
                }
                return isDark ? Colors.white24 : AppColors.grey300;
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 52),
      child: Divider(
        height: 1,
        thickness: 0.5,
        color: isDark ? Colors.white12 : AppColors.grey200,
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
          'This will permanently delete your account and all associated data. This action cannot be undone.\n\nAre you absolutely sure?',
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

// Subscription Tile Widget
class _SubscriptionTile extends StatelessWidget {
  final WidgetRef ref;
  final bool isDark;

  const _SubscriptionTile({
    required this.ref,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final subscriptionAsync = ref.watch(subscriptionProvider);

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
                    isActive ? Icons.workspace_premium : Icons.card_membership,
                    size: 22,
                    color: isDark ? Colors.white70 : AppColors.grey700,
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
                            color: isDark ? Colors.white : Colors.black,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          isActive ? 'Active' : 'Free Plan',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white60 : AppColors.grey600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: isDark ? Colors.white38 : AppColors.grey400,
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
              color: isDark ? Colors.white38 : AppColors.grey400,
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
                  color: isDark ? Colors.white70 : AppColors.grey700,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Failed to load subscription',
                    style: TextStyle(
                      fontSize: 15,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                Text(
                  'Retry',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white60 : AppColors.grey600,
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
