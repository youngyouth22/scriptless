import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:powersync/powersync.dart';
import 'package:scriptless/core/error/exceptions.dart';
import 'package:scriptless/core/powersync/powersync.dart';
import 'package:scriptless/features/splash/data/datasources/splash_remote_datasource.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockPowerSyncService extends Mock implements PowerSyncService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockSupabaseClient mockSupabaseClient;
  late MockPowerSyncService mockPowerSyncService;
  late SplashRemoteDataSourceImpl dataSource;
  late Directory tempDir;
  late PowerSyncDatabase testDb;

  setUp(() async {
    mockSupabaseClient = MockSupabaseClient();
    mockPowerSyncService = MockPowerSyncService();
    tempDir = Directory.systemTemp.createTempSync('splash_powersync_test_');
    final dbPath = p.join(tempDir.path, 'splash_test.db');

    testDb = PowerSyncDatabase(
      schema: const Schema([]),
      path: dbPath,
    );
    await testDb.initialize();

    dataSource = SplashRemoteDataSourceImpl(
      mockSupabaseClient,
      mockPowerSyncService,
    );
  });

  tearDown(() async {
    await testDb.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('SplashRemoteDataSourceImpl initializePowerSync', () {
    test('calls initialize on PowerSyncService', () async {
      when(mockPowerSyncService.initialize).thenAnswer((_) async => testDb);

      await dataSource.initializePowerSync();

      verify(mockPowerSyncService.initialize).called(1);
    });

    test('throws ServerException when PowerSyncService fails', () async {
      when(mockPowerSyncService.initialize)
          .thenThrow(Exception('Failed to initialize database'));

      expect(
        dataSource.initializePowerSync,
        throwsA(isA<ServerException>()),
      );
    });
  });
}
