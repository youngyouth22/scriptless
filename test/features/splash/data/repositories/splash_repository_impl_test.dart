import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scriptless/core/error/exceptions.dart';
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/features/splash/data/datasources/splash_remote_datasource.dart';
import 'package:scriptless/features/splash/data/repositories/splash_repository_impl.dart';

class MockSplashRemoteDataSource extends Mock
    implements SplashRemoteDataSource {}

void main() {
  late MockSplashRemoteDataSource mockRemoteDataSource;
  late SplashRepositoryImpl repository;

  const tUserId = 'user-123';

  setUp(() {
    mockRemoteDataSource = MockSplashRemoteDataSource();
    repository = SplashRepositoryImpl(mockRemoteDataSource);
  });

  group('isOnboardingCompleted', () {
    test('should return true when remote datasource returns true', () async {
      when(
        () => mockRemoteDataSource.isOnboardingCompleted(tUserId),
      ).thenAnswer((_) async => true);

      final result = await repository.isOnboardingCompleted(tUserId);

      expect(result, const Right<Failure, bool>(true));
      verify(
        () => mockRemoteDataSource.isOnboardingCompleted(tUserId),
      ).called(1);
    });

    test('should return false when remote datasource returns false', () async {
      when(
        () => mockRemoteDataSource.isOnboardingCompleted(tUserId),
      ).thenAnswer((_) async => false);

      final result = await repository.isOnboardingCompleted(tUserId);

      expect(result, const Right<Failure, bool>(false));
      verify(
        () => mockRemoteDataSource.isOnboardingCompleted(tUserId),
      ).called(1);
    });

    test(
      'should return ServerFailure when remote throws ServerException',
      () async {
        when(
          () => mockRemoteDataSource.isOnboardingCompleted(tUserId),
        ).thenThrow(const ServerException(message: 'Server error'));

        final result = await repository.isOnboardingCompleted(tUserId);

        expect(
          result,
          const Left<Failure, bool>(ServerFailure('Server error')),
        );
        verify(
          () => mockRemoteDataSource.isOnboardingCompleted(tUserId),
        ).called(1);
      },
    );

    test(
      'should return ServerFailure when remote throws generic Exception',
      () async {
        when(
          () => mockRemoteDataSource.isOnboardingCompleted(tUserId),
        ).thenThrow(Exception('Unexpected error'));

        final result = await repository.isOnboardingCompleted(tUserId);

        expect(
          result,
          const Left<Failure, bool>(
            ServerFailure('Exception: Unexpected error'),
          ),
        );
        verify(
          () => mockRemoteDataSource.isOnboardingCompleted(tUserId),
        ).called(1);
      },
    );
  });

  group('initializePowerSync', () {
    test('should return Right(unit) on successful initialization', () async {
      when(
        () => mockRemoteDataSource.initializePowerSync(),
      ).thenAnswer((_) async {});

      final result = await repository.initializePowerSync();

      expect(result, const Right<Failure, Unit>(unit));
      verify(() => mockRemoteDataSource.initializePowerSync()).called(1);
    });

    test(
      'should return ServerFailure when remote throws ServerException',
      () async {
        when(
          () => mockRemoteDataSource.initializePowerSync(),
        ).thenThrow(const ServerException(message: 'Init failed'));

        final result = await repository.initializePowerSync();

        expect(
          result,
          const Left<Failure, Unit>(ServerFailure('Init failed')),
        );
        verify(() => mockRemoteDataSource.initializePowerSync()).called(1);
      },
    );

    test(
      'should return ServerFailure when remote throws generic Exception',
      () async {
        when(
          () => mockRemoteDataSource.initializePowerSync(),
        ).thenThrow(Exception('Unexpected error'));

        final result = await repository.initializePowerSync();

        expect(
          result,
          const Left<Failure, Unit>(
            ServerFailure('Exception: Unexpected error'),
          ),
        );
        verify(() => mockRemoteDataSource.initializePowerSync()).called(1);
      },
    );
  });
}
