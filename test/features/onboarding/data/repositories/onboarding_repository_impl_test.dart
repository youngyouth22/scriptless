import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scriptless/core/error/exceptions.dart';
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/features/onboarding/data/datasources/onboarding_remote_datasource.dart';
import 'package:scriptless/features/onboarding/data/repositories/onboarding_repository_impl.dart';

class MockOnboardingRemoteDataSource extends Mock
    implements OnboardingRemoteDataSource {}

void main() {
  late MockOnboardingRemoteDataSource mockRemoteDataSource;
  late OnboardingRepositoryImpl repository;

  const tUserId = 'user-123';

  setUp(() {
    mockRemoteDataSource = MockOnboardingRemoteDataSource();
    repository = OnboardingRepositoryImpl(mockRemoteDataSource);
  });

  group('completeOnboarding', () {
    test('should return Right(unit) when remote datasource succeeds', () async {
      when(
        () => mockRemoteDataSource.completeOnboarding(tUserId),
      ).thenAnswer((_) async {});

      final result = await repository.completeOnboarding(tUserId);

      expect(result, const Right<Failure, Unit>(unit));
      verify(() => mockRemoteDataSource.completeOnboarding(tUserId)).called(1);
      verifyNoMoreInteractions(mockRemoteDataSource);
    });

    test(
      'should return ServerFailure when remote throws ServerException',
      () async {
        when(
          () => mockRemoteDataSource.completeOnboarding(tUserId),
        ).thenThrow(const ServerException(message: 'Database error'));

        final result = await repository.completeOnboarding(tUserId);

        expect(
          result,
          const Left<Failure, Unit>(ServerFailure('Database error')),
        );
        verify(
          () => mockRemoteDataSource.completeOnboarding(tUserId),
        ).called(1);
      },
    );

    test(
      'should return ServerFailure when remote throws generic Exception',
      () async {
        when(
          () => mockRemoteDataSource.completeOnboarding(tUserId),
        ).thenThrow(Exception('Unexpected error'));

        final result = await repository.completeOnboarding(tUserId);

        expect(
          result,
          const Left<Failure, Unit>(
            ServerFailure('Exception: Unexpected error'),
          ),
        );
        verify(
          () => mockRemoteDataSource.completeOnboarding(tUserId),
        ).called(1);
      },
    );
  });
}
