import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/app_state_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/subscription_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              try {
                await AuthService.signOut();
                ref.invalidate(subscriptionProvider);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error signing out: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome message
              Text(
                'Welcome!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                appState.subscription.when(
                  data: (_) => 'You are successfully authenticated and have an active subscription.',
                  loading: () => 'Loading subscription details...',
                  error: (error, _) => 'Subscription status unavailable: $error',
                ),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 32),

              // Auth state card
              _StateCard(
                title: 'Authentication State',
                icon: Icons.person_outline,
                children: [
                  _InfoRow(
                    label: 'Status',
                    value: appState.isAuthenticated ? 'Signed In' : 'Signed Out',
                    valueColor: appState.isAuthenticated ? Colors.green : Colors.red,
                  ),
                  if (appState.user != null) ...[
                    _InfoRow(
                      label: 'Email',
                      value: appState.user!.email ?? 'N/A',
                    ),
                    _InfoRow(
                      label: 'User ID',
                      value: '${appState.user!.id.substring(0, 8)}...',
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),

              // Subscription state card
              appState.subscription.when(
                data: (subscription) => _StateCard(
                  title: 'Subscription State',
                  icon: Icons.card_membership_outlined,
                  children: [
                    _InfoRow(
                      label: 'Status',
                      value: subscription.isActive ? 'Active' : 'Inactive',
                      valueColor: subscription.isActive ? Colors.green : Colors.orange,
                    ),
                    _InfoRow(
                      label: 'Tier',
                      value: subscription.tier.toUpperCase(),
                    ),
                    if (subscription.expirationDate != null)
                      _InfoRow(
                        label: 'Expires',
                        value: _formatDate(subscription.expirationDate!),
                      ),
                    if (subscription.productIdentifier != null)
                      _InfoRow(
                        label: 'Product',
                        value: subscription.productIdentifier!,
                      ),
                  ],
                ),
                loading: () => const _StateCard(
                  title: 'Subscription State',
                  icon: Icons.card_membership_outlined,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: LinearProgressIndicator(minHeight: 6),
                    ),
                  ],
                ),
                error: (error, _) => _StateCard(
                  title: 'Subscription State',
                  icon: Icons.warning_amber_rounded,
                  children: [
                    Text('Failed to load subscription: $error'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => ref.read(subscriptionProvider.notifier).refreshSubscription(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Info message
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Phase 2 Complete! Auth and subscription state management is working.',
                        style: TextStyle(color: Colors.blue.shade900),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class _StateCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _StateCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
