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
      backgroundColor: isDark ? const Color(0xFF1C1C1E) : AppColors.grey100,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1C1C1E) : AppColors.grey100,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 20,
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
              // Profile Card
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    // Avatar
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF3A3A3C)
                            : AppColors.grey200,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person,
                        size: 32,
                        color: isDark ? Colors.white70 : AppColors.grey600,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Name and Email
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getDisplayName(user.email),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.email ?? 'No email',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.white60 : AppColors.grey600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.edit_outlined,
                                size: 14,
                                color: isDark ? Colors.white60 : AppColors.grey600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Edit profile',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark ? Colors.white60 : AppColors.grey600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Settings Icon
                    IconButton(
                      icon: Icon(
                        Icons.settings_outlined,
                        color: isDark ? Colors.white70 : AppColors.grey700,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Subscription Section
              _buildSectionHeader('Subscription', isDark),
              _SubscriptionTile(ref: ref, isDark: isDark),

              const SizedBox(height: 24),

              // Account Section
              _buildSectionHeader('Account', isDark),
              _buildSettingsTile(
                icon: Icons.person_outline,
                title: 'Personal Information',
                isDark: isDark,
                onTap: () {},
              ),
              _buildDivider(isDark),
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

              const SizedBox(height: 24),

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

              const SizedBox(height: 24),

              // Support Section
              _buildSectionHeader('Support and Legal', isDark),
              _buildSettingsTile(
                icon: Icons.support_agent_outlined,
                title: 'One-tap support',
                isDark: isDark,
                onTap: () {},
              ),
              _buildDivider(isDark),
              _buildSettingsTile(
                icon: Icons.description_outlined,
                title: 'Terms and Privacy',
                isDark: isDark,
                onTap: () {},
              ),

              const SizedBox(height: 32),

              // Action Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildActionButton(
                      text: 'Sign Out',
                      icon: Icons.logout,
                      isDark: isDark,
                      isDanger: false,
                      onPressed: () => _handleSignOut(context, ref),
                    ),
                    const SizedBox(height: 12),
                    _buildActionButton(
                      text: 'Delete Account',
                      icon: Icons.delete_outline,
                      isDark: isDark,
                      isDanger: true,
                      onPressed: () => _showDeleteAccountDialog(context, ref),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
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
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white54 : AppColors.grey600,
          letterSpacing: 0.5,
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
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(
                icon,
                size: 24,
                color: isDark ? Colors.white70 : AppColors.grey700,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),
              if (trailing != null)
                Text(
                  trailing,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white60 : AppColors.grey600,
                  ),
                ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                size: 20,
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 24,
            color: isDark ? Colors.white70 : AppColors.grey700,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
          Switch(
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
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 56),
      child: Divider(
        height: 1,
        thickness: 0.5,
        color: isDark ? Colors.white12 : AppColors.grey200,
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required IconData icon,
    required bool isDark,
    required bool isDanger,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(text),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(
            color: isDanger
                ? AppColors.error.withValues(alpha: 0.5)
                : isDark
                    ? Colors.white24
                    : AppColors.grey300,
          ),
          foregroundColor: isDanger
              ? AppColors.error
              : isDark
                  ? Colors.white
                  : Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  String _getDisplayName(String? email) {
    if (email == null) return 'User';
    final name = email.split('@').first;
    // Capitalize first letter
    if (name.isEmpty) return 'User';
    return name[0].toUpperCase() + name.substring(1);
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Icon(
                    isActive ? Icons.workspace_premium : Icons.card_membership,
                    size: 24,
                    color: isDark ? Colors.white70 : AppColors.grey700,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subscription.tier.toUpperCase(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isActive ? 'Active' : 'Free Plan',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white60 : AppColors.grey600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: isDark ? Colors.white38 : AppColors.grey400,
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  size: 24,
                  color: isDark ? Colors.white70 : AppColors.grey700,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Failed to load subscription',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                Text(
                  'Retry',
                  style: TextStyle(
                    fontSize: 14,
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
