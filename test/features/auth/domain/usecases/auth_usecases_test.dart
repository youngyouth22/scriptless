import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/core/usecase/usecase.dart';
import 'package:scriptless/features/auth/domain/entities/app_user.dart';
import 'package:scriptless/features/auth/domain/repositories/auth_repository.dart';
import 'package:scriptless/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:scriptless/features/auth/domain/usecases/sign_in_with_email_usecase.dart';
import 'package:scriptless/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:scriptless/features/auth/domain/usecases/sign_in_with_linkedin_usecase.dart';
import 'package:scriptless/features/auth/domain/usecases/sign_in_with_twitter_usecase.dart';
import 'package:scriptless/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:scriptless/features/auth/domain/usecases/sign_up_with_email_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepository;
  late SignInWithEmailUseCase signInWithEmailUseCase;
  late SignInWithGoogleUseCase signInWithGoogleUseCase;
  late SignInWithTwitterUseCase signInWithTwitterUseCase;
  late SignInWithLinkedInUseCase signInWithLinkedInUseCase;
  late SignOutUseCase signOutUseCase;
  late GetCurrentUserUseCase getCurrentUserUseCase;

  const tUser = AppUser(id: 'user-123', email: 'test@example.com');

  setUp(() {
    mockRepository = MockAuthRepository();
    signInWithEmailUseCase = SignInWithEmailUseCase(mockRepository);
    signInWithGoogleUseCase = SignInWithGoogleUseCase(mockRepository);
    signInWithTwitterUseCase = SignInWithTwitterUseCase(mockRepository);
    signInWithLinkedInUseCase = SignInWithLinkedInUseCase(mockRepository);
    signOutUseCase = SignOutUseCase(mockRepository);
    getCurrentUserUseCase = GetCurrentUserUseCase(mockRepository);
  });

  group('SignInWithEmailUseCase', () {
    const tParams = SignInParams(
      email: 'test@example.com',
      password: 'password123',
    );

    test('should return AppUser on successful sign in', () async {
      when(
        () => mockRepository.signInWithEmail(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => const Right<Failure, AppUser>(tUser));

      final result = await signInWithEmailUseCase(tParams);

      expect(result, const Right<Failure, AppUser>(tUser));
      verify(
        () => mockRepository.signInWithEmail(
          email: tParams.email,
          password: tParams.password,
        ),
      ).called(1);
    });

    test('should return Failure when repository fails', () async {
      const tFailure = AuthFailure('Invalid credentials');
      when(
        () => mockRepository.signInWithEmail(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => const Left<Failure, AppUser>(tFailure));

      final result = await signInWithEmailUseCase(tParams);

      expect(result, const Left<Failure, AppUser>(tFailure));
    });
  });

  group('SignUpWithEmailUseCase', () {
    const tParams = SignUpParams(
      email: 'test@example.com',
      password: 'password123',
    );

    test('should return AppUser on successful sign up', () async {
      final signUpUseCase = SignUpWithEmailUseCase(mockRepository);
      when(
        () => mockRepository.signUpWithEmail(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => const Right<Failure, AppUser>(tUser));

      final result = await signUpUseCase(tParams);

      expect(result, const Right<Failure, AppUser>(tUser));
      verify(
        () => mockRepository.signUpWithEmail(
          email: tParams.email,
          password: tParams.password,
        ),
      ).called(1);
    });
  });

  group('OAuth UseCases', () {
    test('SignInWithGoogleUseCase delegates to repository', () async {
      when(
        () => mockRepository.signInWithGoogle(),
      ).thenAnswer((_) async => const Right<Failure, Unit>(unit));

      final result = await signInWithGoogleUseCase(const NoParams());

      expect(result, const Right<Failure, Unit>(unit));
      verify(() => mockRepository.signInWithGoogle()).called(1);
    });

    test('SignInWithTwitterUseCase delegates to repository', () async {
      when(
        () => mockRepository.signInWithTwitter(),
      ).thenAnswer((_) async => const Right<Failure, Unit>(unit));

      final result = await signInWithTwitterUseCase(const NoParams());

      expect(result, const Right<Failure, Unit>(unit));
      verify(() => mockRepository.signInWithTwitter()).called(1);
    });

    test('SignInWithLinkedInUseCase delegates to repository', () async {
      when(
        () => mockRepository.signInWithLinkedIn(),
      ).thenAnswer((_) async => const Right<Failure, Unit>(unit));

      final result = await signInWithLinkedInUseCase(const NoParams());

      expect(result, const Right<Failure, Unit>(unit));
      verify(() => mockRepository.signInWithLinkedIn()).called(1);
    });
  });

  group('SignOutUseCase & GetCurrentUserUseCase', () {
    test('SignOutUseCase delegates to repository', () async {
      when(
        () => mockRepository.signOut(),
      ).thenAnswer((_) async => const Right<Failure, Unit>(unit));

      final result = await signOutUseCase(const NoParams());

      expect(result, const Right<Failure, Unit>(unit));
      verify(() => mockRepository.signOut()).called(1);
    });

    test('GetCurrentUserUseCase returns current user', () async {
      when(
        () => mockRepository.getCurrentUser(),
      ).thenAnswer((_) async => const Right<Failure, AppUser?>(tUser));

      final result = await getCurrentUserUseCase(const NoParams());

      expect(result, const Right<Failure, AppUser?>(tUser));
      verify(() => mockRepository.getCurrentUser()).called(1);
    });
  });
}
