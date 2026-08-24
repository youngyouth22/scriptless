import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:powersync/powersync.dart';
import 'package:scriptless/core/powersync/powersync.dart';
import 'package:scriptless/core/powersync/supabase_connector.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockSupabaseConnector extends Mock implements SupabaseConnector {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockSupabaseClient mockSupabaseClient;
  late MockGoTrueClient mockAuth;
  late MockSupabaseConnector mockConnector;
  late Directory tempDir;
  late PowerSyncDatabase testDatabase;
  late PowerSyncService service;

  setUp(() async {
    mockSupabaseClient = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    mockConnector = MockSupabaseConnector();
    tempDir = Directory.systemTemp.createTempSync('powersync_test_');
    final dbPath = p.join(tempDir.path, 'test.db');

    testDatabase = PowerSyncDatabase(
      schema: const Schema([]),
      path: dbPath,
    );
    await testDatabase.initialize();

    when(() => mockSupabaseClient.auth).thenReturn(mockAuth);
    when(() => mockAuth.onAuthStateChange)
        .thenAnswer((_) => const Stream<AuthState>.empty());

    service = PowerSyncService(
      supabaseClient: mockSupabaseClient,
      database: testDatabase,
      connector: mockConnector,
    );
  });

  tearDown(() async {
    await testDatabase.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('PowerSyncService unit tests', () {
    test('isInitialized returns true when database is provided', () {
      expect(service.isInitialized, isTrue);
      expect(service.db, testDatabase);
    });

    test('db throws StateError when database is not set', () {
      final uninitService = PowerSyncService(
        supabaseClient: mockSupabaseClient,
      );

      expect(uninitService.isInitialized, isFalse);
      expect(() => uninitService.db, throwsStateError);
    });

    test('disconnectAndClear completes without error', () async {
      await service.disconnectAndClear();
      expect(service.isInitialized, isTrue);
    });

    test('dispose closes database connection', () async {
      await service.dispose();
      expect(service.isInitialized, isFalse);
    });
  });
}
