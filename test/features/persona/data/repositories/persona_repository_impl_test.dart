import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scriptless/core/error/exceptions.dart';
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/features/persona/data/datasources/persona_remote_datasource.dart';
import 'package:scriptless/features/persona/data/models/persona_profile_model.dart';
import 'package:scriptless/features/persona/data/repositories/persona_repository_impl.dart';
import 'package:scriptless/features/persona/domain/entities/industry.dart';
import 'package:scriptless/features/persona/domain/entities/persona_profile.dart';
import 'package:scriptless/features/persona/domain/entities/user_role.dart';

class MockPersonaRemoteDataSource extends Mock
    implements PersonaRemoteDataSource {}

void main() {
  late MockPersonaRemoteDataSource mockRemoteDataSource;
  late PersonaRepositoryImpl repository;

  const tProfile = PersonaProfile(
    userId: 'user-123',
    role: UserRole.teamManager,
    industry: Industry.consulting,
    confidenceLevel: 6,
    objectives: ['Donner un feedback difficile'],
  );

  const tModel = PersonaProfileModel(
    userId: 'user-123',
    role: UserRole.teamManager,
    industry: Industry.consulting,
    confidenceLevel: 6,
    objectives: ['Donner un feedback difficile'],
  );

  setUpAll(() {
    registerFallbackValue(tModel);
  });

  setUp(() {
    mockRemoteDataSource = MockPersonaRemoteDataSource();
    repository = PersonaRepositoryImpl(mockRemoteDataSource);
  });

  group('savePersonaProfile', () {
    test('should return Right(unit) when remote succeeds', () async {
      when(
        () => mockRemoteDataSource.updatePersonaProfile(any()),
      ).thenAnswer((_) async {});

      final result = await repository.savePersonaProfile(tProfile);

      expect(result, const Right<Failure, Unit>(unit));
      verify(() => mockRemoteDataSource.updatePersonaProfile(any())).called(1);
      verifyNoMoreInteractions(mockRemoteDataSource);
    });

    test('should return ServerFailure when remote throws ServerException',
        () async {
      when(
        () => mockRemoteDataSource.updatePersonaProfile(any()),
      ).thenThrow(const ServerException(message: 'Database failure'));

      final result = await repository.savePersonaProfile(tProfile);

      expect(
        result,
        const Left<Failure, Unit>(ServerFailure('Database failure')),
      );
      verify(() => mockRemoteDataSource.updatePersonaProfile(any())).called(1);
    });

    test('should return ServerFailure when remote throws unexpected Exception',
        () async {
      when(
        () => mockRemoteDataSource.updatePersonaProfile(any()),
      ).thenThrow(Exception('Unexpected crash'));

      final result = await repository.savePersonaProfile(tProfile);

      expect(
        result,
        const Left<Failure, Unit>(ServerFailure('Exception: Unexpected crash')),
      );
    });
  });

  group('getPersonaProfile', () {
    test('should return Right(PersonaProfile) when found', () async {
      when(
        () => mockRemoteDataSource.getPersonaProfile('user-123'),
      ).thenAnswer((_) async => tModel);

      final result = await repository.getPersonaProfile('user-123');

      expect(result, const Right<Failure, PersonaProfile?>(tModel));
      verify(
        () => mockRemoteDataSource.getPersonaProfile('user-123'),
      ).called(1);
    });

    test('should return Right(null) when profile does not exist', () async {
      when(
        () => mockRemoteDataSource.getPersonaProfile('user-123'),
      ).thenAnswer((_) async => null);

      final result = await repository.getPersonaProfile('user-123');

      expect(result, const Right<Failure, PersonaProfile?>(null));
    });

    test('should return ServerFailure when remote throws ServerException',
        () async {
      when(
        () => mockRemoteDataSource.getPersonaProfile('user-123'),
      ).thenThrow(const ServerException(message: 'Failed to fetch'));

      final result = await repository.getPersonaProfile('user-123');

      expect(
        result,
        const Left<Failure, PersonaProfile?>(ServerFailure('Failed to fetch')),
      );
    });

    test('should return ServerFailure when generic Exception occurs',
        () async {
      when(
        () => mockRemoteDataSource.getPersonaProfile('user-123'),
      ).thenThrow(Exception('Generic error'));

      final result = await repository.getPersonaProfile('user-123');

      expect(
        result,
        const Left<Failure, PersonaProfile?>(
          ServerFailure('Exception: Generic error'),
        ),
      );
    });
  });
}
