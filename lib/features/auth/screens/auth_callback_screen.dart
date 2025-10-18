import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/logger/logger.dart';
import '../../../core/supabase_client.dart';
import '../../../shared/widgets/app_loading_indicator.dart';
import '../../../shared/widgets/error_state.dart';

/// Screen that handles deep link callbacks from Supabase auth flows
/// (password reset, email verification, magic links)
class AuthCallbackScreen extends ConsumerStatefulWidget {
  final String? type;
  final String? accessToken;
  final String? refreshToken;

  const AuthCallbackScreen({
    super.key,
    this.type,
    this.accessToken,
    this.refreshToken,
  });

  @override
  ConsumerState<AuthCallbackScreen> createState() => _AuthCallbackScreenState();
}

class _AuthCallbackScreenState extends ConsumerState<AuthCallbackScreen> {
  String? _error;
  bool _isProcessing = true;

  @override
  void initState() {
    super.initState();
    _processCallback();
  }

  Future<void> _processCallback() async {
    try {
      Logger.log(
        'Processing auth callback - Type: ${widget.type}',
        tag: 'AuthCallback',
      );

      final type = widget.type;
      final refreshToken = widget.refreshToken;

      if (type == null) {
        throw Exception('Invalid callback parameters - missing type');
      }

      // Set session from refresh token if available
      if (refreshToken != null) {
        await supabase.auth.setSession(refreshToken);
        Logger.log('Session refreshed from callback token', tag: 'AuthCallback');
      }

      // Handle different callback types
      if (type == 'recovery' || type == 'password_recovery') {
        // Password recovery - navigate to reset password screen
        Logger.log('Password recovery callback', tag: 'AuthCallback');
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/reset-password');
        }
      } else if (type == 'email_verification' || type == 'signup' || type == 'email') {
        // Email verification - navigate to app
        Logger.log('Email verification callback', tag: 'AuthCallback');
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/app');
        }
      } else if (type == 'magiclink') {
        // Magic link login - navigate to app
        Logger.log('Magic link callback', tag: 'AuthCallback');
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/app');
        }
      } else {
        throw Exception('Unknown callback type: $type');
      }
    } on AuthException catch (e, stackTrace) {
      Logger.error('Auth callback failed', e, stackTrace, tag: 'AuthCallback');
      setState(() {
        _error = e.message.isEmpty ? 'Authentication failed' : e.message;
        _isProcessing = false;
      });
    } catch (e, stackTrace) {
      Logger.error('Auth callback failed', e, stackTrace, tag: 'AuthCallback');
      setState(() {
        _error = 'Failed to process authentication link. It may have expired.';
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isProcessing) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppLoadingIndicator(size: AppLoadingSize.large),
              SizedBox(height: 24),
              Text('Processing authentication...'),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ErrorState(
              message: _error!,
              onRetry: () {
                Navigator.of(context).pushReplacementNamed('/login');
              },
            ),
          ),
        ),
      );
    }

    return const Scaffold(
      body: Center(
        child: AppLoadingIndicator(size: AppLoadingSize.large),
      ),
    );
  }
}
