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

class MockAuthRepository extends Mock implements AuthRepository {}

class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}

class MockHasSeenOnboardingUseCase extends Mock
    implements HasSeenOnboardingUseCase {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockGetCurrentUserUseCase mockGetCurrentUser;
  late MockHasSeenOnboardingUseCase mockHasSeenOnboarding;

  const tUser = AppUser(id: 'user-1', email: 'test@scriptless.ai');

  setUpAll(() {
    registerFallbackValue(const NoParams());
  });

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockGetCurrentUser = MockGetCurrentUserUseCase();
    mockHasSeenOnboarding = MockHasSeenOnboardingUseCase();
    when(
      () => mockAuthRepository.authStateChanges,
    ).thenAnswer((_) => const Stream.empty());
    // Default: onboarding already seen (returning user).
    when(
      () => mockHasSeenOnboarding(any()),
    ).thenAnswer((_) async => const Right<Failure, bool>(true));
  });

  AppBloc buildBloc() => AppBloc(
    authRepository: mockAuthRepository,
    getCurrentUser: mockGetCurrentUser,
    hasSeenOnboarding: mockHasSeenOnboarding,
  );

  group('AppBloc', () {
    test('initial state should be AppLoading', () {
      expect(buildBloc().state, const AppLoading());
    });

    blocTest<AppBloc, AppState>(
      'emits [AppAuthenticated] when session is found on startup',
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
      'emits [AppAuthenticated] on AppUserAuthenticated event',
      build: buildBloc,
      act: (bloc) => bloc.add(const AppUserAuthenticated(tUser)),
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
