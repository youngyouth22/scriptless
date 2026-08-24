import 'dart:async';
import 'dart:developer';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:powersync/powersync.dart';
import 'package:scriptless/core/constants/powersync_constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Postgres response codes and patterns that represent non-retryable
/// permanent errors.
final List<RegExp> _fatalPostgresCodes = [
  // Class 22 — Data Exception (e.g., data type mismatch)
  RegExp(r'^22...$'),
  // Class 23 — Integrity Constraint Violation (NOT NULL, UNIQUE, FK)
  RegExp(r'^23...$'),
  // Class 42 — Insufficient Privilege / RLS violation (42501)
  RegExp(r'^42501$'),
];

/// Supabase connector for PowerSync authentication and bidirectional sync.
///
/// Implements [PowerSyncBackendConnector] by bridging Supabase JWT auth
/// to [fetchCredentials] and replicating client mutations to Postgres
/// in [uploadData].
class SupabaseConnector extends PowerSyncBackendConnector {
  /// Creates a [SupabaseConnector].
  SupabaseConnector({
    required this.supabaseClient,
    String? endpoint,
  }) : _endpoint = endpoint ??
            (dotenv.isInitialized ? dotenv.env['POWERSYNC_URL'] : null) ??
            PowerSyncConstants.defaultEndpoint;

  /// Supabase client used for authentication and replication requests.
  final SupabaseClient supabaseClient;
  final String _endpoint;
  Future<void>? _refreshFuture;

  @override
  Future<PowerSyncCredentials?> fetchCredentials() async {
    // Wait for any pending session refresh before fetching credentials
    await _refreshFuture;

    final session = supabaseClient.auth.currentSession;
    if (session == null) {
      return null;
    }

    final token = session.accessToken;
    final userId = session.user.id;
    final expiresAt = session.expiresAt == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000);

    return PowerSyncCredentials(
      endpoint: _endpoint,
      token: token,
      userId: userId,
      expiresAt: expiresAt,
    );
  }

  @override
  void invalidateCredentials() {
    // Trigger immediate refresh if PowerSync experiences an auth failure
    _refreshFuture = supabaseClient.auth
        .refreshSession()
        .timeout(const Duration(seconds: 5))
        .then((_) => null, onError: (Object error) {
      log(
        'SupabaseConnector: refreshSession failed — $error',
        name: 'powersync',
      );
      return null;
    });
  }

  @override
  Future<void> uploadData(PowerSyncDatabase database) async {
    final transaction = await database.getNextCrudTransaction();
    if (transaction == null) {
      return;
    }

    CrudEntry? lastOp;
    try {
      for (final op in transaction.crud) {
        lastOp = op;
        final table = supabaseClient.rest.from(op.table);

        switch (op.op) {
          case UpdateType.put:
            final data = Map<String, dynamic>.of(
              op.opData ?? <String, dynamic>{},
            );
            data['id'] = op.id;
            await table.upsert(data);
          case UpdateType.patch:
            await table.update(op.opData ?? <String, dynamic>{}).eq(
                  'id',
                  op.id,
                );
          case UpdateType.delete:
            await table.delete().eq('id', op.id);
        }
      }

      await transaction.complete();
    } on PostgrestException catch (e) {
      final code = e.code;
      final isFatal = code != null &&
          _fatalPostgresCodes.any((pattern) => pattern.hasMatch(code));

      if (isFatal) {
        log(
          'SupabaseConnector: Non-retryable upload error (${e.code}): '
          '${e.message} — discarding op $lastOp',
          name: 'powersync',
        );
        await transaction.complete();
      } else {
        log(
          'SupabaseConnector: Transient upload error (${e.code}): ${e.message}',
          name: 'powersync',
        );
        rethrow;
      }
    } on Exception catch (e) {
      log(
        'SupabaseConnector: Unexpected upload error: $e',
        name: 'powersync',
      );
      rethrow;
    }
  }
}
