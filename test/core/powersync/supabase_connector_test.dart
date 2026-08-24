import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:powersync/powersync.dart';
import 'package:scriptless/core/powersync/supabase_connector.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockPostgrestClient extends Mock implements PostgrestClient {}

class MockUser extends Mock implements User {}

class MockSession extends Mock implements Session {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockSupabaseClient mockSupabaseClient;
  late MockGoTrueClient mockAuth;
  late MockPostgrestClient mockRest;
  late Directory tempDir;
  late PowerSyncDatabase testDb;
  late SupabaseConnector connector;

  const tEndpoint =
      'https://6a80d0b653f73afec8a9e7cc.powersync.journeyapps.com';

  setUp(() async {
    mockSupabaseClient = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    mockRest = MockPostgrestClient();
    tempDir = Directory.systemTemp.createTempSync('powersync_connector_test_');
    final dbPath = p.join(tempDir.path, 'connector_test.db');

    testDb = PowerSyncDatabase(
      schema: const Schema([]),
      path: dbPath,
    );
    await testDb.initialize();

    when(() => mockSupabaseClient.auth).thenReturn(mockAuth);
    when(() => mockSupabaseClient.rest).thenReturn(mockRest);

    connector = SupabaseConnector(
      supabaseClient: mockSupabaseClient,
      endpoint: tEndpoint,
    );
  });

  tearDown(() async {
    await testDb.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('SupabaseConnector fetchCredentials', () {
    test('returns null when no session is active', () async {
      when(() => mockAuth.currentSession).thenReturn(null);

      final credentials = await connector.fetchCredentials();

      expect(credentials, isNull);
    });

    test('returns PowerSyncCredentials when session exists', () async {
      final mockUser = MockUser();
      final mockSession = MockSession();

      when(() => mockUser.id).thenReturn('user-uuid-123');
      when(() => mockSession.user).thenReturn(mockUser);
      when(() => mockSession.accessToken).thenReturn('test-jwt-token');
      when(() => mockSession.expiresAt).thenReturn(1700000000);
      when(() => mockAuth.currentSession).thenReturn(mockSession);

      final credentials = await connector.fetchCredentials();

      expect(credentials, isNotNull);
      expect(credentials?.endpoint, tEndpoint);
      expect(credentials?.token, 'test-jwt-token');
      expect(credentials?.userId, 'user-uuid-123');
      expect(
        credentials?.expiresAt,
        DateTime.fromMillisecondsSinceEpoch(1700000000 * 1000),
      );
    });
  });

  group('SupabaseConnector invalidateCredentials', () {
    test('calls refreshSession on auth client', () async {
      final mockResponse = AuthResponse();
      when(mockAuth.refreshSession).thenAnswer((_) async => mockResponse);

      connector.invalidateCredentials();

      verify(mockAuth.refreshSession).called(1);
    });
  });

  group('SupabaseConnector uploadData', () {
    test('returns without error when no transaction pending', () async {
      await connector.uploadData(testDb);
      verifyNever(() => mockRest.from(any()));
    });
  });
}
