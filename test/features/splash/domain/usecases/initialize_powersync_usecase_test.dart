import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/core/usecase/usecase.dart';
import 'package:scriptless/features/splash/domain/repositories/splash_repository.dart';
import 'package:scriptless/features/splash/domain/usecases/initialize_powersync_usecase.dart';

class MockSplashRepository extends Mock implements SplashRepository {}

void main() {
  late MockSplashRepository mockSplashRepository;
  late InitializePowerSyncUseCase useCase;

  setUp(() {
    mockSplashRepository = MockSplashRepository();
    useCase = InitializePowerSyncUseCase(mockSplashRepository);
  });

  group('InitializePowerSyncUseCase', () {
    test(
      'should return unit when PowerSync initializes successfully',
      () async {
        when(
          () => mockSplashRepository.initializePowerSync(),
        ).thenAnswer((_) async => const Right<Failure, Unit>(unit));

        final result = await useCase(const NoParams());

        expect(result, const Right<Failure, Unit>(unit));
        verify(() => mockSplashRepository.initializePowerSync()).called(1);
        verifyNoMoreInteractions(mockSplashRepository);
      },
    );

    test('should return Failure when PowerSync initialization fails', () async {
      const tFailure = CacheFailure('Failed to open SQLite database');
      when(
        () => mockSplashRepository.initializePowerSync(),
      ).thenAnswer((_) async => const Left<Failure, Unit>(tFailure));

      final result = await useCase(const NoParams());

      expect(result, const Left<Failure, Unit>(tFailure));
      verify(() => mockSplashRepository.initializePowerSync()).called(1);
      verifyNoMoreInteractions(mockSplashRepository);
    });
  });
}
