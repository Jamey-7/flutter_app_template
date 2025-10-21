import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/providers/auth_provider.dart';
import '../../subscriptions/providers/subscription_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/responsive/breakpoints.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_dialog.dart';
import '../../../shared/widgets/app_snack_bar.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: userAsync.when(
          data: (user) {
            if (user == null) {
              return const Center(child: Text('Not signed in'));
            }

            return SingleChildScrollView(
              padding: EdgeInsets.all(context.responsivePadding),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Appearance Section
                      Text(
                        'Appearance',
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _ThemeToggleCard(ref: ref),
                      const SizedBox(height: AppSpacing.xl),

                      // Account Information Section
                      Text(
                        'Account Information',
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppCard.elevated(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _InfoRow(
                              label: 'Email',
                              value: user.email ?? 'N/A',
                              icon: Icons.email_outlined,
                            ),
                            const Divider(height: AppSpacing.lg),
                            _InfoRow(
                              label: 'User ID',
                              value: user.id,
                              icon: Icons.fingerprint,
                              isMonospace: true,
                            ),
                            const Divider(height: AppSpacing.lg),
                            _InfoRow(
                              label: 'Created',
                              value: user.createdAt,
                              icon: Icons.calendar_today,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Account Management Section
                      Text(
                        'Account Management',
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppCard.elevated(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _SettingsTile(
                              icon: Icons.email_outlined,
                              title: 'Change Email',
                              subtitle: 'Update your email address',
                              onTap: () {
                                context.push('/settings/change-email');
                              },
                            ),
                            const Divider(height: 1),
                            _SettingsTile(
                              icon: Icons.lock_outline,
                              title: 'Change Password',
                              subtitle: 'Update your password',
                              onTap: () {
                                context.push('/settings/change-password');
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Subscription Section
                      Text(
                        'Subscription',
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _SubscriptionCard(ref: ref),
                      const SizedBox(height: AppSpacing.xl),

                      // Danger Zone Section
                      Text(
                        'Danger Zone',
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.colors.error,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppCard.outlined(
                        color: context.colors.error.withValues(alpha: 0.05),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Delete Account',
                              style: context.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: context.colors.error,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'Permanently delete your account and all associated data. This action cannot be undone.',
                              style: context.textTheme.bodySmall?.copyWith(
                                color: context.colors.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            ElevatedButton.icon(
                              onPressed: () => _showDeleteAccountDialog(context, ref),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: context.colors.error,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 48),
                              ),
                              icon: const Icon(Icons.delete_forever),
                              label: const Text('Delete Account'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Sign Out Button
                      AppButton.secondary(
                        text: 'Sign Out',
                        onPressed: () => _handleSignOut(context, ref),
                        icon: Icons.logout,
                        isFullWidth: true,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Error: $error')),
        ),
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

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isMonospace;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
    this.isMonospace = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: context.colors.onSurface.withValues(alpha: 0.6)),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  fontFamily: isMonospace ? 'monospace' : null,
                  fontSize: isMonospace ? 12 : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(
          children: [
            Icon(icon, color: context.colors.primary),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: context.colors.onSurface.withValues(alpha: 0.6)),
          ],
        ),
      ),
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  final WidgetRef ref;

  const _SubscriptionCard({required this.ref});

  @override
  Widget build(BuildContext context) {
    final subscriptionAsync = ref.watch(subscriptionProvider);

    return subscriptionAsync.when(
      data: (subscription) => AppCard.elevated(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  subscription.isActive
                      ? Icons.check_circle
                      : Icons.info_outline,
                  color: subscription.isActive
                      ? const Color(0xFF10B981) // Success green
                      : const Color(0xFFF59E0B), // Warning amber
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    subscription.isActive ? 'Active Subscription' : 'Free Tier',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _InfoRow(
              label: 'Tier',
              value: subscription.tier.toUpperCase(),
              icon: Icons.card_membership,
            ),
            if (subscription.expirationDate != null) ...[
              const Divider(height: AppSpacing.lg),
              _InfoRow(
                label: 'Expires',
                value: _formatDate(subscription.expirationDate!),
                icon: Icons.calendar_today,
              ),
            ],
            if (subscription.productIdentifier != null) ...[
              const Divider(height: AppSpacing.lg),
              _InfoRow(
                label: 'Product',
                value: subscription.productIdentifier!,
                icon: Icons.shopping_bag,
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            if (subscription.isActive) ...[
              AppButton.secondary(
                text: 'Manage Subscription',
                onPressed: () {
                  context.push('/subscription-details');
                },
                icon: Icons.settings,
                isFullWidth: true,
              ),
            ] else ...[
              AppButton.primary(
                text: 'Upgrade to Premium',
                onPressed: () {
                  context.go('/paywall');
                },
                icon: Icons.upgrade,
                isFullWidth: true,
              ),
            ],
          ],
        ),
      ),
      loading: () => AppCard.elevated(
        child: Center(
          child: Column(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Loading subscription...',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
      error: (error, _) => AppCard.elevated(
        child: Column(
          children: [
            Text(
              'Failed to load subscription',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.error,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton.secondary(
              text: 'Retry',
              onPressed: () {
                ref.invalidate(subscriptionProvider);
              },
              size: AppButtonSize.small,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class _ThemeToggleCard extends StatelessWidget {
  final WidgetRef ref;

  const _ThemeToggleCard({required this.ref});

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    return AppCard.elevated(
      child: Row(
        children: [
          Icon(
            isDarkMode ? Icons.dark_mode : Icons.light_mode,
            color: context.colors.primary,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dark Mode',
                  style: context.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Switch between light and dark theme',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isDarkMode,
            onChanged: (_) {
              ref.read(themeModeProvider.notifier).toggleTheme();
            },
          ),
        ],
      ),
    );
  }
}
