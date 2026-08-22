import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:scriptless/features/onboarding/domain/usecases/complete_onboarding_usecase.dart';

class MockOnboardingRepository extends Mock implements OnboardingRepository {}

void main() {
  late MockOnboardingRepository mockRepository;
  late CompleteOnboardingUseCase useCase;

  const tUserId = 'user-123';

  setUp(() {
    mockRepository = MockOnboardingRepository();
    useCase = CompleteOnboardingUseCase(mockRepository);
  });

  group('CompleteOnboardingUseCase', () {
    test('should return unit when repository succeeds', () async {
      when(
        () => mockRepository.completeOnboarding(tUserId),
      ).thenAnswer((_) async => const Right<Failure, Unit>(unit));

      final result = await useCase(tUserId);

      expect(result, const Right<Failure, Unit>(unit));
      verify(() => mockRepository.completeOnboarding(tUserId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ServerFailure when repository fails', () async {
      const tFailure = ServerFailure('Update error');
      when(
        () => mockRepository.completeOnboarding(tUserId),
      ).thenAnswer((_) async => const Left<Failure, Unit>(tFailure));

      final result = await useCase(tUserId);

      expect(result, const Left<Failure, Unit>(tFailure));
      verify(() => mockRepository.completeOnboarding(tUserId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
