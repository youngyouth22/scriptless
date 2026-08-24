import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:scriptless/core/error/exceptions.dart';
import 'package:scriptless/features/persona/data/datasources/persona_remote_datasource.dart';
import 'package:scriptless/features/persona/data/models/persona_profile_model.dart';
import 'package:scriptless/features/persona/domain/entities/industry.dart';
import 'package:scriptless/features/persona/domain/entities/user_role.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakePostgrestTransformBuilder<T> extends Fake
    implements PostgrestTransformBuilder<T> {
  FakePostgrestTransformBuilder(this._value);

  final T _value;

  @override
  Future<R> then<R>(
    FutureOr<R> Function(T value) onValue, {
    Function? onError,
  }) {
    return Future.value(_value).then(onValue, onError: onError);
  }
}

class FakePostgrestFilterBuilder<T> extends Fake
    implements PostgrestFilterBuilder<T> {
  FakePostgrestFilterBuilder({
    this.value,
    this.singleValue,
    this.errorToThrow,
    this.onEq,
  });

  final T? value;
  final Map<String, dynamic>? singleValue;
  final Exception? errorToThrow;
  final void Function(String column, Object val)? onEq;

  @override
  PostgrestFilterBuilder<T> eq(String column, Object val) {
    onEq?.call(column, val);
    if (errorToThrow != null) {
      throw errorToThrow!;
    }
    return this;
  }

  @override
  PostgrestTransformBuilder<Map<String, dynamic>?> maybeSingle() {
    if (errorToThrow != null) {
      throw errorToThrow!;
    }
    return FakePostgrestTransformBuilder<Map<String, dynamic>?>(singleValue);
  }

  @override
  Future<R> then<R>(
    FutureOr<R> Function(T value) onValue, {
    Function? onError,
  }) {
    if (errorToThrow != null) {
      return Future<T>.error(errorToThrow!).then(onValue, onError: onError);
    }
    return Future.value(value as T).then(onValue, onError: onError);
  }
}

// Fake query builder for test mocks.
// ignore: must_be_immutable
class FakeSupabaseQueryBuilder extends Fake implements SupabaseQueryBuilder {
  FakeSupabaseQueryBuilder({this.filterBuilder});

  FakePostgrestFilterBuilder<List<Map<String, dynamic>>>? filterBuilder;
  Map<dynamic, dynamic>? lastUpdatePayload;
  String? lastSelectColumns;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> update(
    Map<dynamic, dynamic> values, {
    String? returning,
  }) {
    lastUpdatePayload = values;
    return filterBuilder ??
        FakePostgrestFilterBuilder<List<Map<String, dynamic>>>();
  }

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> select([
    String columns = '*',
  ]) {
    lastSelectColumns = columns;
    return filterBuilder ??
        FakePostgrestFilterBuilder<List<Map<String, dynamic>>>();
  }
}

class FakeSupabaseClient extends Fake implements SupabaseClient {
  FakeSupabaseClient({required this.queryBuilder});

  final FakeSupabaseQueryBuilder queryBuilder;
  String? lastRequestedTable;

  @override
  SupabaseQueryBuilder from(String table) {
    lastRequestedTable = table;
    return queryBuilder;
  }
}

void main() {
  late FakeSupabaseClient fakeClient;
  late FakeSupabaseQueryBuilder fakeQueryBuilder;
  late PersonaRemoteDataSourceImpl dataSource;

  const tModel = PersonaProfileModel(
    userId: 'user-123',
    role: UserRole.teamManager,
    industry: Industry.retail,
    confidenceLevel: 7,
    objectives: ["Gérer un conflit d'équipe"],
  );

  setUp(() {
    fakeQueryBuilder = FakeSupabaseQueryBuilder();
    fakeClient = FakeSupabaseClient(queryBuilder: fakeQueryBuilder);
    dataSource = PersonaRemoteDataSourceImpl(fakeClient);
  });

  group('updatePersonaProfile', () {
    test('should execute update on profiles table successfully', () async {
      String? eqCol;
      Object? eqVal;

      fakeQueryBuilder.filterBuilder =
          FakePostgrestFilterBuilder<List<Map<String, dynamic>>>(
        value: [],
        onEq: (col, val) {
          eqCol = col;
          eqVal = val;
        },
      );

      await dataSource.updatePersonaProfile(tModel);

      expect(fakeClient.lastRequestedTable, 'profiles');
      expect(fakeQueryBuilder.lastUpdatePayload?['role'], 'team_manager');
      expect(fakeQueryBuilder.lastUpdatePayload?['industry'], 'retail');
      expect(fakeQueryBuilder.lastUpdatePayload?['confidence_level'], 7);
      expect(fakeQueryBuilder.lastUpdatePayload?['objectives'], [
        "Gérer un conflit d'équipe",
      ]);
      expect(eqCol, 'id');
      expect(eqVal, 'user-123');
    });

    test('should throw ServerException when PostgrestException is raised',
        () async {
      fakeQueryBuilder.filterBuilder =
          FakePostgrestFilterBuilder<List<Map<String, dynamic>>>(
        errorToThrow: const PostgrestException(message: 'Database error'),
      );

      expect(
        () => dataSource.updatePersonaProfile(tModel),
        throwsA(isA<ServerException>()),
      );
    });

    test('should throw ServerException when generic Exception occurs',
        () async {
      fakeQueryBuilder.filterBuilder =
          FakePostgrestFilterBuilder<List<Map<String, dynamic>>>(
        errorToThrow: Exception('Network error'),
      );

      expect(
        () => dataSource.updatePersonaProfile(tModel),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('getPersonaProfile', () {
    final tProfileData = {
      'id': 'user-123',
      'role': 'team_manager',
      'industry': 'retail',
      'confidence_level': 7,
      'objectives': ["Gérer un conflit d'équipe"],
    };

    test('should return PersonaProfileModel when record exists', () async {
      String? eqCol;
      Object? eqVal;

      fakeQueryBuilder.filterBuilder =
          FakePostgrestFilterBuilder<List<Map<String, dynamic>>>(
        singleValue: tProfileData,
        onEq: (col, val) {
          eqCol = col;
          eqVal = val;
        },
      );

      final result = await dataSource.getPersonaProfile('user-123');

      expect(fakeClient.lastRequestedTable, 'profiles');
      expect(
        fakeQueryBuilder.lastSelectColumns,
        'id, role, industry, confidence_level, objectives',
      );
      expect(eqCol, 'id');
      expect(eqVal, 'user-123');
      expect(result, isNotNull);
      expect(result?.userId, 'user-123');
      expect(result?.role, UserRole.teamManager);
      expect(result?.industry, Industry.retail);
      expect(result?.confidenceLevel, 7);
      expect(result?.objectives, ["Gérer un conflit d'équipe"]);
    });

    test('should return null when profile not found', () async {
      fakeQueryBuilder.filterBuilder =
          FakePostgrestFilterBuilder<List<Map<String, dynamic>>>();

      final result = await dataSource.getPersonaProfile('user-123');

      expect(result, isNull);
    });

    test('should return null when profile exists but role is null', () async {
      fakeQueryBuilder.filterBuilder =
          FakePostgrestFilterBuilder<List<Map<String, dynamic>>>(
        singleValue: {
          'id': 'user-123',
          'role': null,
          'industry': null,
          'confidence_level': null,
          'objectives': null,
        },
      );

      final result = await dataSource.getPersonaProfile('user-123');

      expect(result, isNull);
    });

    test('should throw ServerException when select fails', () async {
      fakeQueryBuilder.filterBuilder =
          FakePostgrestFilterBuilder<List<Map<String, dynamic>>>(
        errorToThrow: const PostgrestException(message: 'Query failed'),
      );

      expect(
        () => dataSource.getPersonaProfile('user-123'),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
