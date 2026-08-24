import 'package:supabase_flutter/supabase_flutter.dart';

/// Service wrapper providing access to [SupabaseClient].
class SupabaseService {
  /// Returns the default SupabaseClient instance.
  SupabaseClient get client => Supabase.instance.client;
}
