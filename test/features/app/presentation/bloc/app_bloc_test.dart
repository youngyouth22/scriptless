import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/core/usecase/usecase.dart';
import 'package:scriptless/features/app/presentation/bloc/app_bloc.dart';
import 'package:scriptless/features/auth/domain/entities/app_user.dart';
import 'package:scriptless/features/auth/domain/repositories/auth_repository.dart';
import 'package:scriptless/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:scriptless/features/onboarding/domain/usecases/has_seen_onboarding_usecase.dart';
import 'package:scriptless/features/persona/domain/entities/industry.dart';
import 'package:scriptless/features/persona/domain/entities/persona_profile.dart';
import 'package:scriptless/features/persona/domain/entities/user_role.dart';
import 'package:scriptless/features/persona/domain/usecases/get_persona_profile_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}

class MockHasSeenOnboardingUseCase extends Mock
    implements HasSeenOnboardingUseCase {}

class MockGetPersonaProfileUseCase extends Mock
    implements GetPersonaProfileUseCase {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockGetCurrentUserUseCase mockGetCurrentUser;
  late MockHasSeenOnboardingUseCase mockHasSeenOnboarding;
  late MockGetPersonaProfileUseCase mockGetPersonaProfile;

  const tUser = AppUser(id: 'user-1', email: 'test@scriptless.ai');
  const tPersonaProfile = PersonaProfile(
    userId: 'user-1',
    role: UserRole.firstTimeManager,
    industry: Industry.tech,
    confidenceLevel: 6,
    objectives: ['Donner un feedback difficile'],
  );

  setUpAll(() {
    registerFallbackValue(const NoParams());
  });

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockGetCurrentUser = MockGetCurrentUserUseCase();
    mockHasSeenOnboarding = MockHasSeenOnboardingUseCase();
    mockGetPersonaProfile = MockGetPersonaProfileUseCase();

    when(
      () => mockAuthRepository.authStateChanges,
    ).thenAnswer((_) => const Stream.empty());

    // Default: onboarding already seen (returning user).
    when(
      () => mockHasSeenOnboarding(any()),
    ).thenAnswer((_) async => const Right<Failure, bool>(true));

    // Default: persona profile complete.
    when(
      () => mockGetPersonaProfile(any()),
    ).thenAnswer(
      (_) async => const Right<Failure, PersonaProfile?>(tPersonaProfile),
    );
  });

  AppBloc buildBloc() => AppBloc(
    authRepository: mockAuthRepository,
    getCurrentUser: mockGetCurrentUser,
    hasSeenOnboarding: mockHasSeenOnboarding,
    getPersonaProfile: mockGetPersonaProfile,
  );

  group('AppBloc', () {
    test('initial state should be AppLoading', () {
      expect(buildBloc().state, const AppLoading());
    });

    blocTest<AppBloc, AppState>(
      'emits [AppAuthenticated] when session found on startup '
      'and persona complete',
      build: () {
        when(
          () => mockGetCurrentUser(any()),
        ).thenAnswer((_) async => const Right(tUser));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AppStarted()),
      expect: () => const [
        AppAuthenticated(tUser),
      ],
    );

    blocTest<AppBloc, AppState>(
      'emits [AppNeedsPersona] when session found on startup '
      'and persona profile is null',
      build: () {
        when(
          () => mockGetCurrentUser(any()),
        ).thenAnswer((_) async => const Right(tUser));
        when(
          () => mockGetPersonaProfile(any()),
        ).thenAnswer((_) async => const Right<Failure, PersonaProfile?>(null));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AppStarted()),
      expect: () => const [
        AppNeedsPersona(tUser),
      ],
    );

    blocTest<AppBloc, AppState>(
      'emits [AppNeedsPersona] when session found on startup '
      'and getPersonaProfile fails',
      build: () {
        when(
          () => mockGetCurrentUser(any()),
        ).thenAnswer((_) async => const Right(tUser));
        when(
          () => mockGetPersonaProfile(any()),
        ).thenAnswer((_) async => const Left(ServerFailure('DB error')));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AppStarted()),
      expect: () => const [
        AppNeedsPersona(tUser),
      ],
    );

    blocTest<AppBloc, AppState>(
      'emits [AppUnauthenticated] when no session found and onboarding seen',
      build: () {
        when(
          () => mockGetCurrentUser(any()),
        ).thenAnswer((_) async => const Right<Failure, AppUser?>(null));
        when(
          () => mockHasSeenOnboarding(any()),
        ).thenAnswer((_) async => const Right<Failure, bool>(true));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AppStarted()),
      expect: () => const [
        AppUnauthenticated(),
      ],
    );

    blocTest<AppBloc, AppState>(
      'emits [AppNeedsOnboarding] when no session found '
      'and onboarding not seen',
      build: () {
        when(
          () => mockGetCurrentUser(any()),
        ).thenAnswer((_) async => const Right<Failure, AppUser?>(null));
        when(
          () => mockHasSeenOnboarding(any()),
        ).thenAnswer((_) async => const Right<Failure, bool>(false));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AppStarted()),
      expect: () => const [
        AppNeedsOnboarding(),
      ],
    );

    blocTest<AppBloc, AppState>(
      'emits [AppUnauthenticated] when getCurrentUser fails '
      'and onboarding seen',
      build: () {
        when(() => mockGetCurrentUser(any())).thenAnswer(
          (_) async =>
              const Left<Failure, AppUser?>(ServerFailure('Connection error')),
        );
        when(
          () => mockHasSeenOnboarding(any()),
        ).thenAnswer((_) async => const Right<Failure, bool>(true));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AppStarted()),
      expect: () => const [
        AppUnauthenticated(),
      ],
    );

    blocTest<AppBloc, AppState>(
      'emits [AppAuthenticated] on AppUserAuthenticated event '
      'when persona is complete',
      build: buildBloc,
      act: (bloc) => bloc.add(const AppUserAuthenticated(tUser)),
      expect: () => const [
        AppAuthenticated(tUser),
      ],
    );

    blocTest<AppBloc, AppState>(
      'emits [AppNeedsPersona] on AppUserAuthenticated event '
      'when persona is null',
      build: () {
        when(
          () => mockGetPersonaProfile(any()),
        ).thenAnswer((_) async => const Right<Failure, PersonaProfile?>(null));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AppUserAuthenticated(tUser)),
      expect: () => const [
        AppNeedsPersona(tUser),
      ],
    );

    blocTest<AppBloc, AppState>(
      'emits [AppAuthenticated] on AppPersonaCompleted event',
      build: buildBloc,
      act: (bloc) => bloc.add(const AppPersonaCompleted(tUser)),
      expect: () => const [
        AppAuthenticated(tUser),
      ],
    );

    blocTest<AppBloc, AppState>(
      'emits [AppUnauthenticated] on AppUserUnauthenticated event',
      build: buildBloc,
      act: (bloc) => bloc.add(const AppUserUnauthenticated()),
      expect: () => const [
        AppUnauthenticated(),
      ],
    );
  });
}
