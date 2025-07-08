import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseManager {
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: 'https://<tu_project_url>.supabase.co',
      anonKey: '<tu_anon_key>',
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}