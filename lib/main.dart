import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/logger/logger.dart';
import 'core/provider_observer.dart';
import 'providers/subscription_provider.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Load environment variables
    if (!kIsWeb) {
      Logger.log('Loading environment variables...', tag: 'Main');
      await dotenv.load(fileName: '.env');
      Logger.log('Environment variables loaded', tag: 'Main');
    }

    // Validate required environment variables
    _validateEnvironment();

    // Initialize Sentry
    final sentryDsn = dotenv.env['SENTRY_DSN'];
    if (sentryDsn != null && sentryDsn.isNotEmpty && sentryDsn != 'your_sentry_dsn') {
      Logger.log('Initializing Sentry...', tag: 'Main');
      await SentryFlutter.init(
        (options) {
          options.dsn = sentryDsn;
          options.tracesSampleRate = 1.0;
          options.environment = dotenv.env['ENVIRONMENT'] ?? 'development';
        },
      );
      Logger.log('Sentry initialized', tag: 'Main');
    } else {
      Logger.warning('Sentry DSN not configured, skipping initialization', tag: 'Main');
    }

    // Initialize Supabase
    final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? const String.fromEnvironment('SUPABASE_URL');
    final supabaseAnonKey =
        dotenv.env['SUPABASE_ANON_KEY'] ?? const String.fromEnvironment('SUPABASE_ANON_KEY');
    
    Logger.log('Initializing Supabase...', tag: 'Main');
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    Logger.log('Supabase initialized', tag: 'Main');

    // Initialize RevenueCat
    final revenueCatApiKey =
        dotenv.env['REVENUECAT_API_KEY'] ?? const String.fromEnvironment('REVENUECAT_API_KEY');
    if (revenueCatApiKey.isNotEmpty && 
        revenueCatApiKey != 'your_revenuecat_api_key') {
      Logger.log('Initializing RevenueCat...', tag: 'Main');
      await SubscriptionService.initialize(revenueCatApiKey);
      Logger.log('RevenueCat initialized', tag: 'Main');
    } else {
      Logger.warning(
        'RevenueCat API key not configured, subscription features will use free tier',
        tag: 'Main',
      );
    }

    Logger.log('All services initialized successfully', tag: 'Main');

    // Run app with Riverpod and error handling
    runApp(
      ProviderScope(
        observers: [AppProviderObserver()],
        child: const App(),
      ),
    );
  } catch (e, stackTrace) {
    Logger.error('Failed to initialize app', e, stackTrace, tag: 'Main');
    
    // Show error screen
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Failed to Initialize App',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    e.toString(),
                    style: const TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Please check your .env file configuration',
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Validate that required environment variables are present
void _validateEnvironment() {
  final requiredVars = {
    'SUPABASE_URL': dotenv.env['SUPABASE_URL'] ?? const String.fromEnvironment('SUPABASE_URL'),
    'SUPABASE_ANON_KEY':
        dotenv.env['SUPABASE_ANON_KEY'] ?? const String.fromEnvironment('SUPABASE_ANON_KEY'),
  };

  final missing = <String>[];
  final placeholder = <String>[];

  for (final entry in requiredVars.entries) {
    if (entry.value.isEmpty) {
      missing.add(entry.key);
    } else if (entry.value.startsWith('your_')) {
      placeholder.add(entry.key);
    }
  }

  if (missing.isNotEmpty) {
    throw Exception(
      'Missing required environment variables: ${missing.join(', ')}\n'
      'Please copy .env.example to .env and add your keys.',
    );
  }

  if (placeholder.isNotEmpty) {
    throw Exception(
      'Please update placeholder values in .env file: ${placeholder.join(', ')}\n'
      'Replace "your_*" values with actual keys from your services.',
    );
  }

  Logger.log('Environment validation passed', tag: 'Main');
}
