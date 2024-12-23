import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;

export 'database/database.dart';

String _kSupabaseUrl = 'https://nrapqjwyqvwopwoxevlw.supabase.co';
String _kSupabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5yYXBxand5cXZ3b3B3b3hldmx3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzA4MDU2MzQsImV4cCI6MjA0NjM4MTYzNH0.hq-X6YEAD7DG9WIiJhqwRb3ZtMruaEzAbr0Wm4TBoQU';

class SupaFlow {
  SupaFlow._();

  static SupaFlow? _instance;
  static SupaFlow get instance => _instance ??= SupaFlow._();

  final _supabase = Supabase.instance.client;
  static SupabaseClient get client => instance._supabase;

  static Future initialize() => Supabase.initialize(
        url: _kSupabaseUrl,
        anonKey: _kSupabaseAnonKey,
        debug: false,
      );
}
