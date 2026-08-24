import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/features/persona/domain/entities/industry.dart';
import 'package:scriptless/features/persona/domain/entities/persona_profile.dart';
import 'package:scriptless/features/persona/domain/entities/user_role.dart';
import 'package:scriptless/features/persona/domain/repositories/persona_repository.dart';
import 'package:scriptless/features/persona/domain/usecases/get_persona_profile_usecase.dart';

class MockPersonaRepository extends Mock implements PersonaRepository {}

void main() {
  late MockPersonaRepository mockRepository;
  late GetPersonaProfileUseCase useCase;

  const tUserId = 'user-123';
  const tProfile = PersonaProfile(
    userId: tUserId,
    role: UserRole.crossFunctionalManager,
    industry: Industry.healthcare,
    confidenceLevel: 8,
    objectives: ['Poser des limites'],
  );

  setUp(() {
    mockRepository = MockPersonaRepository();
    useCase = GetPersonaProfileUseCase(mockRepository);
  });

  group('GetPersonaProfileUseCase', () {
    test('should return PersonaProfile when repository succeeds', () async {
      when(
        () => mockRepository.getPersonaProfile(tUserId),
      ).thenAnswer((_) async => const Right(tProfile));

      final result = await useCase(tUserId);

      expect(result, const Right<Failure, PersonaProfile?>(tProfile));
      verify(() => mockRepository.getPersonaProfile(tUserId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return Failure when repository fails', () async {
      const tFailure = ServerFailure('User not found');
      when(
        () => mockRepository.getPersonaProfile(tUserId),
      ).thenAnswer((_) async => const Left(tFailure));

      final result = await useCase(tUserId);

      expect(result, const Left<Failure, PersonaProfile?>(tFailure));
      verify(() => mockRepository.getPersonaProfile(tUserId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
