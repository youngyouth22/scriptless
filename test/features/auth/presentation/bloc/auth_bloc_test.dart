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
import 'package:scriptless/features/auth/domain/usecases/sign_up_with_email_usecase.dart';
import 'package:scriptless/features/auth/presentation/bloc/auth_bloc.dart';

class MockSignInWithEmailUseCase extends Mock
    implements SignInWithEmailUseCase {}

class MockSignUpWithEmailUseCase extends Mock
    implements SignUpWithEmailUseCase {}

class MockSignInWithGoogleUseCase extends Mock
    implements SignInWithGoogleUseCase {}

class MockSignInWithTwitterUseCase extends Mock
    implements SignInWithTwitterUseCase {}

class MockSignInWithLinkedInUseCase extends Mock
    implements SignInWithLinkedInUseCase {}

class MockSignOutUseCase extends Mock implements SignOutUseCase {}

void main() {
  late MockSignInWithEmailUseCase mockSignInWithEmail;
  late MockSignUpWithEmailUseCase mockSignUpWithEmail;
  late MockSignInWithGoogleUseCase mockSignInWithGoogle;
  late MockSignInWithTwitterUseCase mockSignInWithTwitter;
  late MockSignInWithLinkedInUseCase mockSignInWithLinkedIn;
  late MockSignOutUseCase mockSignOut;

  const tUser = AppUser(id: 'user-1', email: 'test@scriptless.ai');

  setUpAll(() {
    registerFallbackValue(
      const SignInParams(email: 'test@example.com', password: 'password'),
    );
    registerFallbackValue(
      const SignUpParams(email: 'test@example.com', password: 'password'),
    );
    registerFallbackValue(const NoParams());
  });

  setUp(() {
    mockSignInWithEmail = MockSignInWithEmailUseCase();
    mockSignUpWithEmail = MockSignUpWithEmailUseCase();
    mockSignInWithGoogle = MockSignInWithGoogleUseCase();
    mockSignInWithTwitter = MockSignInWithTwitterUseCase();
    mockSignInWithLinkedIn = MockSignInWithLinkedInUseCase();
    mockSignOut = MockSignOutUseCase();
  });

  AuthBloc buildBloc() => AuthBloc(
    signInWithEmail: mockSignInWithEmail,
    signUpWithEmail: mockSignUpWithEmail,
    signInWithGoogle: mockSignInWithGoogle,
    signInWithTwitter: mockSignInWithTwitter,
    signInWithLinkedIn: mockSignInWithLinkedIn,
    signOut: mockSignOut,
  );

  group('AuthBloc', () {
    test('initial state should be AuthInitial', () {
      expect(buildBloc().state, const AuthInitial());
    });

    group('AuthSignInRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthSuccess] on successful email sign in',
        build: () {
          when(
            () => mockSignInWithEmail(any()),
          ).thenAnswer((_) async => const Right(tUser));
          return buildBloc();
        },
        act: (bloc) => bloc.add(
          const AuthSignInRequested(
            email: 'test@scriptless.ai',
            password: 'pass',
          ),
        ),
        expect: () => const [
          AuthLoading(provider: AuthProviderType.emailSignIn),
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
          AuthLoading(provider: AuthProviderType.emailSignIn),
          AuthFailureState(AuthFailure('Invalid credentials')),
        ],
      );
    });

    group('AuthSignUpRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthSuccess] on successful email sign up',
        build: () {
          when(
            () => mockSignUpWithEmail(any()),
          ).thenAnswer((_) async => const Right(tUser));
          return buildBloc();
        },
        act: (bloc) => bloc.add(
          const AuthSignUpRequested(
            email: 'test@scriptless.ai',
            password: 'password123',
          ),
        ),
        expect: () => const [
          AuthLoading(provider: AuthProviderType.emailSignUp),
          AuthSuccess(tUser),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthFailureState] on failed email sign up',
        build: () {
          when(() => mockSignUpWithEmail(any())).thenAnswer(
            (_) async => const Left(AuthFailure('Email already in use')),
          );
          return buildBloc();
        },
        act: (bloc) => bloc.add(
          const AuthSignUpRequested(
            email: 'test@scriptless.ai',
            password: 'password123',
          ),
        ),
        expect: () => const [
          AuthLoading(provider: AuthProviderType.emailSignUp),
          AuthFailureState(AuthFailure('Email already in use')),
        ],
      );
    });

    group('OAuth flows', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthOAuthInProgress] when Google OAuth succeeds',
        build: () {
          when(
            () => mockSignInWithGoogle(any()),
          ).thenAnswer((_) async => const Right(unit));
          return buildBloc();
        },
        act: (bloc) => bloc.add(const AuthGoogleSignInRequested()),
        expect: () => const [
          AuthLoading(provider: AuthProviderType.google),
          AuthOAuthInProgress(),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthFailureState] when Google OAuth fails',
        build: () {
          when(() => mockSignInWithGoogle(any())).thenAnswer(
            (_) async => const Left(AuthFailure('Google OAuth cancelled')),
          );
          return buildBloc();
        },
        act: (bloc) => bloc.add(const AuthGoogleSignInRequested()),
        expect: () => const [
          AuthLoading(provider: AuthProviderType.google),
          AuthFailureState(AuthFailure('Google OAuth cancelled')),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthOAuthInProgress] when Twitter OAuth succeeds',
        build: () {
          when(
            () => mockSignInWithTwitter(any()),
          ).thenAnswer((_) async => const Right(unit));
          return buildBloc();
        },
        act: (bloc) => bloc.add(const AuthTwitterSignInRequested()),
        expect: () => const [
          AuthLoading(provider: AuthProviderType.twitter),
          AuthOAuthInProgress(),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthFailureState] when Twitter OAuth fails',
        build: () {
          when(() => mockSignInWithTwitter(any())).thenAnswer(
            (_) async => const Left(AuthFailure('Twitter OAuth failed')),
          );
          return buildBloc();
        },
        act: (bloc) => bloc.add(const AuthTwitterSignInRequested()),
        expect: () => const [
          AuthLoading(provider: AuthProviderType.twitter),
          AuthFailureState(AuthFailure('Twitter OAuth failed')),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthOAuthInProgress] when LinkedIn OAuth succeeds',
        build: () {
          when(
            () => mockSignInWithLinkedIn(any()),
          ).thenAnswer((_) async => const Right(unit));
          return buildBloc();
        },
        act: (bloc) => bloc.add(const AuthLinkedInSignInRequested()),
        expect: () => const [
          AuthLoading(provider: AuthProviderType.linkedIn),
          AuthOAuthInProgress(),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthFailureState] when LinkedIn OAuth fails',
        build: () {
          when(() => mockSignInWithLinkedIn(any())).thenAnswer(
            (_) async => const Left(AuthFailure('LinkedIn OAuth failed')),
          );
          return buildBloc();
        },
        act: (bloc) => bloc.add(const AuthLinkedInSignInRequested()),
        expect: () => const [
          AuthLoading(provider: AuthProviderType.linkedIn),
          AuthFailureState(AuthFailure('LinkedIn OAuth failed')),
        ],
      );
    });

    group('AuthSignOutRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading(signOut), AuthSignedOut] when sign out succeeds',
        build: () {
          when(
            () => mockSignOut(any()),
          ).thenAnswer((_) async => const Right(unit));
          return buildBloc();
        },
        act: (bloc) => bloc.add(const AuthSignOutRequested()),
        expect: () => const [
          AuthLoading(provider: AuthProviderType.signOut),
          AuthSignedOut(),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading(signOut), AuthFailureState] when sign out fails',
        build: () {
          when(() => mockSignOut(any())).thenAnswer(
            (_) async => const Left(AuthFailure('Sign out error')),
          );
          return buildBloc();
        },
        act: (bloc) => bloc.add(const AuthSignOutRequested()),
        expect: () => const [
          AuthLoading(provider: AuthProviderType.signOut),
          AuthFailureState(AuthFailure('Sign out error')),
        ],
      );
    });
  });
}
