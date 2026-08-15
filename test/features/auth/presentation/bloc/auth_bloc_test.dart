import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/core/usecase/usecase.dart';
import 'package:scriptless/features/auth/domain/entities/app_user.dart';
import 'package:scriptless/features/auth/domain/usecases/sign_in_with_email_usecase.dart';
import 'package:scriptless/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:scriptless/features/auth/domain/usecases/sign_in_with_linkedin_usecase.dart';
import 'package:scriptless/features/auth/domain/usecases/sign_in_with_twitter_usecase.dart';
import 'package:scriptless/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:scriptless/features/auth/presentation/bloc/auth_bloc.dart';

class MockSignInWithEmailUseCase extends Mock
    implements SignInWithEmailUseCase {}

class MockSignInWithGoogleUseCase extends Mock
    implements SignInWithGoogleUseCase {}

class MockSignInWithTwitterUseCase extends Mock
    implements SignInWithTwitterUseCase {}

class MockSignInWithLinkedInUseCase extends Mock
    implements SignInWithLinkedInUseCase {}

class MockSignOutUseCase extends Mock implements SignOutUseCase {}

void main() {
  late MockSignInWithEmailUseCase mockSignInWithEmail;
  late MockSignInWithGoogleUseCase mockSignInWithGoogle;
  late MockSignInWithTwitterUseCase mockSignInWithTwitter;
  late MockSignInWithLinkedInUseCase mockSignInWithLinkedIn;
  late MockSignOutUseCase mockSignOut;

  const tUser = AppUser(id: 'user-1', email: 'test@scriptless.ai');

  setUpAll(() {
    registerFallbackValue(
      const SignInParams(email: 'test@example.com', password: 'password'),
    );
    registerFallbackValue(const NoParams());
  });

  setUp(() {
    mockSignInWithEmail = MockSignInWithEmailUseCase();
    mockSignInWithGoogle = MockSignInWithGoogleUseCase();
    mockSignInWithTwitter = MockSignInWithTwitterUseCase();
    mockSignInWithLinkedIn = MockSignInWithLinkedInUseCase();
    mockSignOut = MockSignOutUseCase();
  });

  AuthBloc buildBloc() => AuthBloc(
        signInWithEmail: mockSignInWithEmail,
        signInWithGoogle: mockSignInWithGoogle,
        signInWithTwitter: mockSignInWithTwitter,
        signInWithLinkedIn: mockSignInWithLinkedIn,
        signOut: mockSignOut,
      );

  group('AuthBloc', () {
    test('initial state should be AuthInitial', () {
      expect(buildBloc().state, const AuthInitial());
    });

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthSuccess] on successful email sign in',
      build: () {
        when(() => mockSignInWithEmail(any()))
            .thenAnswer((_) async => const Right(tUser));
        return buildBloc();
      },
      act: (bloc) => bloc.add(
        const AuthSignInRequested(
          email: 'test@scriptless.ai',
          password: 'pass',
        ),
      ),
      expect: () => const [
        AuthLoading(),
        AuthSuccess(tUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailureState] on failed email sign in',
      build: () {
        when(() => mockSignInWithEmail(any())).thenAnswer(
          (_) async => const Left(AuthFailure('Invalid credentials')),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(
        const AuthSignInRequested(
          email: 'test@scriptless.ai',
          password: 'wrong',
        ),
      ),
      expect: () => const [
        AuthLoading(),
        AuthFailureState(AuthFailure('Invalid credentials')),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthOAuthInProgress] when Google OAuth succeeds',
      build: () {
        when(() => mockSignInWithGoogle(any()))
            .thenAnswer((_) async => const Right(unit));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AuthGoogleSignInRequested()),
      expect: () => const [
        AuthLoading(),
        AuthOAuthInProgress(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthSignedOut] when sign out succeeds',
      build: () {
        when(() => mockSignOut(any()))
            .thenAnswer((_) async => const Right(unit));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AuthSignOutRequested()),
      expect: () => const [
        AuthLoading(),
        AuthSignedOut(),
      ],
    );
  });
}
