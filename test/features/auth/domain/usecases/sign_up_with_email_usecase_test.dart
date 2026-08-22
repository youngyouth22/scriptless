import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/features/auth/domain/entities/app_user.dart';
import 'package:scriptless/features/auth/domain/repositories/auth_repository.dart';
import 'package:scriptless/features/auth/domain/usecases/sign_up_with_email_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepository;
  late SignUpWithEmailUseCase useCase;

  const tUser = AppUser(id: 'user-new', email: 'newuser@example.com');
  const tParams = SignUpParams(
    email: 'newuser@example.com',
    password: 'securePassword123',
  );

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = SignUpWithEmailUseCase(mockRepository);
  });

  group('SignUpWithEmailUseCase', () {
    test('should return AppUser when sign-up is successful', () async {
      when(
        () => mockRepository.signUpWithEmail(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => const Right<Failure, AppUser>(tUser));

      final result = await useCase(tParams);

      expect(result, const Right<Failure, AppUser>(tUser));
      verify(
        () => mockRepository.signUpWithEmail(
          email: tParams.email,
          password: tParams.password,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test(
      'should return AuthFailure when repository fails with auth error',
      () async {
        const tFailure = AuthFailure('User already registered');
        when(
          () => mockRepository.signUpWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => const Left<Failure, AppUser>(tFailure));

        final result = await useCase(tParams);

        expect(result, const Left<Failure, AppUser>(tFailure));
        verify(
          () => mockRepository.signUpWithEmail(
            email: tParams.email,
            password: tParams.password,
          ),
        ).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test(
      'should return ServerFailure when repository fails with server error',
      () async {
        const tFailure = ServerFailure('Unexpected server error');
        when(
          () => mockRepository.signUpWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => const Left<Failure, AppUser>(tFailure));

        final result = await useCase(tParams);

        expect(result, const Left<Failure, AppUser>(tFailure));
        verify(
          () => mockRepository.signUpWithEmail(
            email: tParams.email,
            password: tParams.password,
          ),
        ).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );
  });
}
