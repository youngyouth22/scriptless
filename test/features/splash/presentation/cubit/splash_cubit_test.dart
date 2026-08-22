import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/core/usecase/usecase.dart';
import 'package:scriptless/features/auth/domain/entities/app_user.dart';
import 'package:scriptless/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:scriptless/features/splash/domain/usecases/check_onboarding_status_usecase.dart';
import 'package:scriptless/features/splash/domain/usecases/initialize_powersync_usecase.dart';
import 'package:scriptless/features/splash/presentation/cubit/splash_cubit.dart';
import 'package:scriptless/features/splash/presentation/cubit/splash_state.dart';

class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}

class MockCheckOnboardingStatusUseCase extends Mock
    implements CheckOnboardingStatusUseCase {}

class MockInitializePowerSyncUseCase extends Mock
    implements InitializePowerSyncUseCase {}

void main() {
  late MockGetCurrentUserUseCase mockGetCurrentUser;
  late MockCheckOnboardingStatusUseCase mockCheckOnboardingStatus;
  late MockInitializePowerSyncUseCase mockInitializePowerSync;

  const tUser = AppUser(id: 'user-123', email: 'manager@scriptless.ai');

  setUpAll(() {
    registerFallbackValue(const NoParams());
  });

  setUp(() {
    mockGetCurrentUser = MockGetCurrentUserUseCase();
    mockCheckOnboardingStatus = MockCheckOnboardingStatusUseCase();
    mockInitializePowerSync = MockInitializePowerSyncUseCase();
  });

  SplashCubit buildCubit() => SplashCubit(
    getCurrentUser: mockGetCurrentUser,
    checkOnboardingStatus: mockCheckOnboardingStatus,
    initializePowerSync: mockInitializePowerSync,
  );

  group('SplashCubit', () {
    test('initial state should be SplashInitial', () {
      expect(buildCubit().state, const SplashInitial());
    });

    blocTest<SplashCubit, SplashState>(
      'emits [SplashLoading, SplashNavigateToLogin] when no active session',
      build: () {
        when(() => mockGetCurrentUser(any())).thenAnswer(
          (_) async => const Right<Failure, AppUser?>(null),
        );
        return buildCubit();
      },
      act: (cubit) => cubit.init(),
      expect: () => const [
        SplashLoading(),
        SplashNavigateToLogin(),
      ],
    );

    blocTest<SplashCubit, SplashState>(
      'emits [SplashLoading, SplashNavigateToLogin] on empty user',
      build: () {
        when(() => mockGetCurrentUser(any())).thenAnswer(
          (_) async => Right<Failure, AppUser?>(AppUser.empty()),
        );
        return buildCubit();
      },
      act: (cubit) => cubit.init(),
      expect: () => const [
        SplashLoading(),
        SplashNavigateToLogin(),
      ],
    );

    blocTest<SplashCubit, SplashState>(
      'emits [SplashLoading, SplashNavigateToLogin] when getCurrentUser fails',
      build: () {
        when(() => mockGetCurrentUser(any())).thenAnswer(
          (_) async =>
              const Left<Failure, AppUser?>(ServerFailure('Session error')),
        );
        return buildCubit();
      },
      act: (cubit) => cubit.init(),
      expect: () => const [
        SplashLoading(),
        SplashNavigateToLogin(),
      ],
    );

    blocTest<SplashCubit, SplashState>(
      'emits [SplashLoading, SplashNavigateToOnboarding] when '
      'onboarding is incomplete',
      build: () {
        when(() => mockGetCurrentUser(any())).thenAnswer(
          (_) async => const Right<Failure, AppUser?>(tUser),
        );
        when(() => mockCheckOnboardingStatus(tUser.id)).thenAnswer(
          (_) async => const Right<Failure, bool>(false),
        );
        return buildCubit();
      },
      act: (cubit) => cubit.init(),
      expect: () => const [
        SplashLoading(),
        SplashNavigateToOnboarding(),
      ],
    );

    blocTest<SplashCubit, SplashState>(
      'emits [SplashLoading, SplashError] when onboarding check fails',
      build: () {
        when(() => mockGetCurrentUser(any())).thenAnswer(
          (_) async => const Right<Failure, AppUser?>(tUser),
        );
        when(() => mockCheckOnboardingStatus(tUser.id)).thenAnswer(
          (_) async =>
              const Left<Failure, bool>(ServerFailure('DB fetch error')),
        );
        return buildCubit();
      },
      act: (cubit) => cubit.init(),
      expect: () => const [
        SplashLoading(),
        SplashError(ServerFailure('DB fetch error')),
      ],
    );

    blocTest<SplashCubit, SplashState>(
      'emits [SplashLoading, SplashError] when PowerSync init fails',
      build: () {
        when(() => mockGetCurrentUser(any())).thenAnswer(
          (_) async => const Right<Failure, AppUser?>(tUser),
        );
        when(() => mockCheckOnboardingStatus(tUser.id)).thenAnswer(
          (_) async => const Right<Failure, bool>(true),
        );
        when(() => mockInitializePowerSync(any())).thenAnswer(
          (_) async =>
              const Left<Failure, Unit>(CacheFailure('PowerSync init error')),
        );
        return buildCubit();
      },
      act: (cubit) => cubit.init(),
      expect: () => const [
        SplashLoading(),
        SplashError(CacheFailure('PowerSync init error')),
      ],
    );

    blocTest<SplashCubit, SplashState>(
      'emits [SplashLoading, SplashNavigateToDashboard] when '
      'session, onboarding, and PowerSync all succeed',
      build: () {
        when(() => mockGetCurrentUser(any())).thenAnswer(
          (_) async => const Right<Failure, AppUser?>(tUser),
        );
        when(() => mockCheckOnboardingStatus(tUser.id)).thenAnswer(
          (_) async => const Right<Failure, bool>(true),
        );
        when(() => mockInitializePowerSync(any())).thenAnswer(
          (_) async => const Right<Failure, Unit>(unit),
        );
        return buildCubit();
      },
      act: (cubit) => cubit.init(),
      expect: () => const [
        SplashLoading(),
        SplashNavigateToDashboard(),
      ],
    );
  });
}
