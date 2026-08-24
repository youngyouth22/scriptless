import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/features/persona/domain/entities/industry.dart';
import 'package:scriptless/features/persona/domain/entities/persona_objective.dart';
import 'package:scriptless/features/persona/domain/entities/persona_profile.dart';
import 'package:scriptless/features/persona/domain/entities/user_role.dart';
import 'package:scriptless/features/persona/domain/usecases/save_persona_profile_usecase.dart';
import 'package:scriptless/features/persona/presentation/cubit/persona_cubit.dart';
import 'package:scriptless/features/persona/presentation/cubit/persona_state.dart';

class MockSavePersonaProfileUseCase extends Mock
    implements SavePersonaProfileUseCase {}

void main() {
  late MockSavePersonaProfileUseCase mockSavePersonaProfile;

  const tUserId = 'user-123';
  const tProfile = PersonaProfile(
    userId: tUserId,
    role: UserRole.teamManager,
    industry: Industry.tech,
    confidenceLevel: 8,
    objectives: [PersonaObjective.difficultFeedback],
  );

  setUpAll(() {
    registerFallbackValue(tProfile);
  });

  setUp(() {
    mockSavePersonaProfile = MockSavePersonaProfileUseCase();
  });

  PersonaCubit buildCubit() => PersonaCubit(
        savePersonaProfile: mockSavePersonaProfile,
      );

  group('PersonaCubit', () {
    test('initial state has correct default values', () {
      final cubit = buildCubit();
      expect(cubit.state.currentStep, 0);
      expect(cubit.state.totalSteps, 3);
      expect(cubit.state.role, isNull);
      expect(cubit.state.industry, isNull);
      expect(cubit.state.confidenceLevel, 5);
      expect(cubit.state.objectives, isEmpty);
      expect(cubit.state.status, PersonaStatus.initial);
      expect(cubit.state.isFirstStep, isTrue);
      expect(cubit.state.isLastStep, isFalse);
      expect(cubit.state.canProceed, isFalse);
      expect(cubit.state.stepTitle, 'Qui êtes-vous ?');
    });

    blocTest<PersonaCubit, PersonaState>(
      'selectRole updates role and marks step 1 valid',
      build: buildCubit,
      act: (cubit) => cubit.selectRole(UserRole.teamManager),
      expect: () => [
        isA<PersonaState>()
            .having((s) => s.role, 'role', UserRole.teamManager)
            .having((s) => s.isStep1Valid, 'isStep1Valid', isTrue)
            .having((s) => s.canProceed, 'canProceed', isTrue),
      ],
    );

    blocTest<PersonaCubit, PersonaState>(
      'selectIndustry updates industry',
      build: buildCubit,
      act: (cubit) => cubit.selectIndustry(Industry.tech),
      expect: () => [
        isA<PersonaState>()
            .having((s) => s.industry, 'industry', Industry.tech),
      ],
    );

    blocTest<PersonaCubit, PersonaState>(
      'setConfidenceLevel clamps and updates confidence level',
      build: buildCubit,
      act: (cubit) {
        cubit
          ..setConfidenceLevel(8)
          ..setConfidenceLevel(15) // should clamp to 10
          ..setConfidenceLevel(-2); // should clamp to 1
      },
      expect: () => [
        isA<PersonaState>().having(
          (s) => s.confidenceLevel,
          'confidenceLevel',
          8,
        ),
        isA<PersonaState>().having(
          (s) => s.confidenceLevel,
          'confidenceLevel',
          10,
        ),
        isA<PersonaState>().having(
          (s) => s.confidenceLevel,
          'confidenceLevel',
          1,
        ),
      ],
    );

    blocTest<PersonaCubit, PersonaState>(
      'toggleObjective toggles objective presence in list',
      build: buildCubit,
      act: (cubit) {
        cubit
          ..toggleObjective(PersonaObjective.difficultFeedback)
          ..toggleObjective(PersonaObjective.sayNoWithoutGuilt)
          ..toggleObjective(PersonaObjective.difficultFeedback);
      },
      expect: () => [
        isA<PersonaState>().having(
          (s) => s.objectives,
          'objectives',
          [PersonaObjective.difficultFeedback],
        ),
        isA<PersonaState>().having(
          (s) => s.objectives,
          'objectives',
          [
            PersonaObjective.difficultFeedback,
            PersonaObjective.sayNoWithoutGuilt,
          ],
        ),
        isA<PersonaState>().having(
          (s) => s.objectives,
          'objectives',
          [PersonaObjective.sayNoWithoutGuilt],
        ),
      ],
    );

    blocTest<PersonaCubit, PersonaState>(
      'setObjectives updates entire objectives list',
      build: buildCubit,
      act: (cubit) => cubit.setObjectives([
        PersonaObjective.negotiateSalary,
        PersonaObjective.setBoundaries,
      ]),
      expect: () => [
        isA<PersonaState>().having(
          (s) => s.objectives,
          'objectives',
          [
            PersonaObjective.negotiateSalary,
            PersonaObjective.setBoundaries,
          ],
        ),
      ],
    );

    group('Step navigation', () {
      blocTest<PersonaCubit, PersonaState>(
        'nextStep advances to step 1 when step 0 is valid',
        build: buildCubit,
        seed: () => const PersonaState(
          role: UserRole.firstTimeManager,
        ),
        act: (cubit) => cubit.nextStep(),
        expect: () => [
          isA<PersonaState>()
              .having((s) => s.currentStep, 'currentStep', 1)
              .having((s) => s.stepTitle, 'stepTitle', 'Votre univers'),
        ],
      );

      blocTest<PersonaCubit, PersonaState>(
        'nextStep does not advance if current step is invalid',
        build: buildCubit,
        seed: () => const PersonaState(),
        act: (cubit) => cubit.nextStep(),
        expect: () => <PersonaState>[],
      );

      blocTest<PersonaCubit, PersonaState>(
        'nextStep does not advance past last step',
        build: buildCubit,
        seed: () => const PersonaState(
          currentStep: 2,
          role: UserRole.teamManager,
          industry: Industry.tech,
          objectives: [PersonaObjective.difficultFeedback],
        ),
        act: (cubit) => cubit.nextStep(),
        expect: () => <PersonaState>[],
      );

      blocTest<PersonaCubit, PersonaState>(
        'previousStep navigates back from step 1 to 0',
        build: buildCubit,
        seed: () => const PersonaState(currentStep: 1),
        act: (cubit) => cubit.previousStep(),
        expect: () => [
          isA<PersonaState>().having((s) => s.currentStep, 'currentStep', 0),
        ],
      );

      blocTest<PersonaCubit, PersonaState>(
        'previousStep does not go below step 0',
        build: buildCubit,
        seed: () => const PersonaState(),
        act: (cubit) => cubit.previousStep(),
        expect: () => <PersonaState>[],
      );

      blocTest<PersonaCubit, PersonaState>(
        'goToStep jumps to valid step',
        build: buildCubit,
        act: (cubit) => cubit.goToStep(2),
        expect: () => [
          isA<PersonaState>()
              .having((s) => s.currentStep, 'currentStep', 2)
              .having((s) => s.stepTitle, 'stepTitle', 'Vos objectifs')
              .having((s) => s.isLastStep, 'isLastStep', isTrue),
        ],
      );
    });

    group('submitPersona', () {
      blocTest<PersonaCubit, PersonaState>(
        'emits failure with ValidationFailure when profile is incomplete',
        build: buildCubit,
        seed: () => const PersonaState(
          currentStep: 2,
          industry: Industry.tech,
          objectives: [PersonaObjective.difficultFeedback],
        ),
        act: (cubit) => cubit.submitPersona(tUserId),
        expect: () => [
          isA<PersonaState>()
              .having((s) => s.status, 'status', PersonaStatus.failure)
              .having(
                (s) => s.failure,
                'failure',
                isA<ValidationFailure>(),
              ),
        ],
      );

      blocTest<PersonaCubit, PersonaState>(
        'emits [submitting, success] when save succeeds',
        build: () {
          when(
            () => mockSavePersonaProfile(any()),
          ).thenAnswer((_) async => const Right(unit));
          return buildCubit();
        },
        seed: () => const PersonaState(
          currentStep: 2,
          role: UserRole.teamManager,
          industry: Industry.tech,
          confidenceLevel: 8,
          objectives: [PersonaObjective.difficultFeedback],
        ),
        act: (cubit) => cubit.submitPersona(tUserId),
        expect: () => [
          isA<PersonaState>()
              .having((s) => s.status, 'status', PersonaStatus.submitting),
          isA<PersonaState>()
              .having((s) => s.status, 'status', PersonaStatus.success),
        ],
        verify: (_) {
          verify(() => mockSavePersonaProfile(any())).called(1);
        },
      );

      blocTest<PersonaCubit, PersonaState>(
        'emits [submitting, failure] when save fails',
        build: () {
          when(
            () => mockSavePersonaProfile(any()),
          ).thenAnswer(
            (_) async => const Left(ServerFailure('Connection error')),
          );
          return buildCubit();
        },
        seed: () => const PersonaState(
          currentStep: 2,
          role: UserRole.teamManager,
          industry: Industry.tech,
          confidenceLevel: 8,
          objectives: [PersonaObjective.difficultFeedback],
        ),
        act: (cubit) => cubit.submitPersona(tUserId),
        expect: () => [
          isA<PersonaState>()
              .having((s) => s.status, 'status', PersonaStatus.submitting),
          isA<PersonaState>()
              .having((s) => s.status, 'status', PersonaStatus.failure)
              .having(
                (s) => s.failure,
                'failure',
                const ServerFailure('Connection error'),
              ),
        ],
      );
    });
  });
}
