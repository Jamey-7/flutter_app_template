import 'package:supabase_flutter/supabase_flutter.dart';

/// Global Supabase client instance
/// Initialize before use via Supabase.initialize() in main.dart
final supabase = Supabase.instance.client;
