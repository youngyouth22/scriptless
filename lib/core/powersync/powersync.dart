import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:powersync/powersync.dart';
import 'package:scriptless/core/constants/powersync_constants.dart';
import 'package:scriptless/core/powersync/models/schema.dart';
import 'package:scriptless/core/powersync/supabase_connector.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Resolves the filesystem path for the local SQLite database.
Future<String> getDatabasePath({String? filename}) async {
  final dbName = filename ?? PowerSyncConstants.databaseFilename;
  if (kIsWeb) {
    return dbName;
  }
  final dir = await getApplicationSupportDirectory();
  return p.join(dir.path, dbName);
}

/// Service managing the PowerSync database lifecycle and Supabase sync.
class PowerSyncService {
  /// Creates a [PowerSyncService].
  PowerSyncService({
    required this.supabaseClient,
    PowerSyncDatabase? database,
    this.connector,
  }) : _db = database;

  /// Supabase client used for authentication.
  final SupabaseClient supabaseClient;

  /// Optional connector instance.
  final SupabaseConnector? connector;

  PowerSyncDatabase? _db;
  StreamSubscription<AuthState>? _authSubscription;

  /// Returns the underlying [PowerSyncDatabase] instance.
  /// Throws [StateError] if not initialized.
  PowerSyncDatabase get db {
    final database = _db;
    if (database == null) {
      throw StateError(
        'PowerSyncDatabase has not been initialized. Call initialize() first.',
      );
    }
    return database;
  }

  /// Returns whether the database has been initialized.
  bool get isInitialized => _db != null;

  /// Initializes the SQLite database and hooks into Supabase auth changes.
  Future<PowerSyncDatabase> initialize({String? pathOverride}) async {
    if (_db != null) {
      return _db!;
    }

    final dbPath = pathOverride ?? await getDatabasePath();
    final database = PowerSyncDatabase(
      schema: schema,
      path: dbPath,
    );

    await database.initialize();
    _db = database;

    final activeConnector = connector ??
        SupabaseConnector(
          supabaseClient: supabaseClient,
        );

    // Connect immediately if the user is already authenticated
    final session = supabaseClient.auth.currentSession;
    if (session != null) {
      log(
        'PowerSyncService: Active session detected, connecting...',
        name: 'powersync',
      );
      unawaited(database.connect(connector: activeConnector));
    }

    // Bind auth lifecycle stream
    _setupAuthListener(database, activeConnector);

    return database;
  }

  void _setupAuthListener(
    PowerSyncDatabase database,
    SupabaseConnector activeConnector,
  ) {
    unawaited(_authSubscription?.cancel());
    _authSubscription =
        supabaseClient.auth.onAuthStateChange.listen((data) async {
      final event = data.event;
      log('PowerSyncService: Auth event received — $event', name: 'powersync');

      if (event == AuthChangeEvent.signedIn ||
          event == AuthChangeEvent.userUpdated) {
        log(
          'PowerSyncService: Connecting to PowerSync sync stream',
          name: 'powersync',
        );
        await database.connect(connector: activeConnector);
      } else if (event == AuthChangeEvent.signedOut) {
        log(
          'PowerSyncService: Disconnecting from PowerSync',
          name: 'powersync',
        );
        await database.disconnect();
      } else if (event == AuthChangeEvent.tokenRefreshed) {
        log(
          'PowerSyncService: Token refreshed, updating credentials',
          name: 'powersync',
        );
        unawaited(activeConnector.prefetchCredentials());
      }
    });
  }

  /// Disconnects from sync and deletes local user database contents.
  /// Call this when the user performs an explicit sign out.
  Future<void> disconnectAndClear() async {
    final database = _db;
    if (database != null) {
      log(
        'PowerSyncService: Disconnecting and clearing local database',
        name: 'powersync',
      );
      await database.disconnectAndClear();
    }
  }

  /// Disposes active listeners and closes the database connection.
  Future<void> dispose() async {
    unawaited(_authSubscription?.cancel());
    _authSubscription = null;
    final database = _db;
    if (database != null) {
      await database.close();
      _db = null;
    }
  }
}
