import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/features/persona/domain/entities/industry.dart';
import 'package:scriptless/features/persona/domain/entities/persona_profile.dart';
import 'package:scriptless/features/persona/domain/entities/user_role.dart';
import 'package:scriptless/features/persona/domain/repositories/persona_repository.dart';
import 'package:scriptless/features/persona/domain/usecases/save_persona_profile_usecase.dart';

class MockPersonaRepository extends Mock implements PersonaRepository {}

void main() {
  late MockPersonaRepository mockRepository;
  late SavePersonaProfileUseCase useCase;

  const tProfile = PersonaProfile(
    userId: 'user-123',
    role: UserRole.teamManager,
    industry: Industry.consulting,
    confidenceLevel: 7,
    objectives: ["Gérer un conflit d'équipe"],
  );

  setUp(() {
    mockRepository = MockPersonaRepository();
    useCase = SavePersonaProfileUseCase(mockRepository);
  });

  group('SavePersonaProfileUseCase', () {
    test('should return Right(unit) when repository succeeds', () async {
      when(
        () => mockRepository.savePersonaProfile(tProfile),
      ).thenAnswer((_) async => const Right(unit));

      final result = await useCase(tProfile);

      expect(result, const Right<Failure, Unit>(unit));
      verify(() => mockRepository.savePersonaProfile(tProfile)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return Failure when repository fails', () async {
      const tFailure = ServerFailure('Database error');
      when(
        () => mockRepository.savePersonaProfile(tProfile),
      ).thenAnswer((_) async => const Left(tFailure));

      final result = await useCase(tProfile);

      expect(result, const Left<Failure, Unit>(tFailure));
      verify(() => mockRepository.savePersonaProfile(tProfile)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
