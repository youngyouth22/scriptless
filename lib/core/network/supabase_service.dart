import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  /// Returns the default SupabaseClient instance
  SupabaseClient get client => Supabase.instance.client;
}
