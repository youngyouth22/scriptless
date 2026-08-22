import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/features/splash/domain/repositories/splash_repository.dart';
import 'package:scriptless/features/splash/domain/usecases/check_onboarding_status_usecase.dart';

class MockSplashRepository extends Mock implements SplashRepository {}

void main() {
  late MockSplashRepository mockSplashRepository;
  late CheckOnboardingStatusUseCase useCase;

  const tUserId = 'user-123';

  setUp(() {
    mockSplashRepository = MockSplashRepository();
    useCase = CheckOnboardingStatusUseCase(mockSplashRepository);
  });

  group('CheckOnboardingStatusUseCase', () {
    test('should return true when onboarding is completed', () async {
      when(
        () => mockSplashRepository.isOnboardingCompleted(tUserId),
      ).thenAnswer((_) async => const Right<Failure, bool>(true));

      final result = await useCase(tUserId);

      expect(result, const Right<Failure, bool>(true));
      verify(
        () => mockSplashRepository.isOnboardingCompleted(tUserId),
      ).called(1);
      verifyNoMoreInteractions(mockSplashRepository);
    });

    test('should return false when onboarding is not completed', () async {
      when(
        () => mockSplashRepository.isOnboardingCompleted(tUserId),
      ).thenAnswer((_) async => const Right<Failure, bool>(false));

      final result = await useCase(tUserId);

      expect(result, const Right<Failure, bool>(false));
      verify(
        () => mockSplashRepository.isOnboardingCompleted(tUserId),
      ).called(1);
      verifyNoMoreInteractions(mockSplashRepository);
    });

    test('should return ServerFailure when repository fails', () async {
      const tFailure = ServerFailure('Database error');
      when(
        () => mockSplashRepository.isOnboardingCompleted(tUserId),
      ).thenAnswer((_) async => const Left<Failure, bool>(tFailure));

      final result = await useCase(tUserId);

      expect(result, const Left<Failure, bool>(tFailure));
      verify(
        () => mockSplashRepository.isOnboardingCompleted(tUserId),
      ).called(1);
      verifyNoMoreInteractions(mockSplashRepository);
    });
  });
}
