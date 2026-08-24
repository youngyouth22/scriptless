import 'package:scriptless/core/powersync/supabase_connector.dart';

/// Legacy backend connector alias mapped to [SupabaseConnector].
class MyBackendConnector extends SupabaseConnector {
  /// Creates a [MyBackendConnector].
  MyBackendConnector({
    required super.supabaseClient,
    super.endpoint,
  });
}
