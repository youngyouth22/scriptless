import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scriptless/core/error/exceptions.dart';
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:scriptless/features/auth/data/repositories/auth_repository_impl.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

void main() {
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late AuthRepositoryImpl repository;

  const tEmail = 'test@example.com';
  const tToken = '123456';
  const tNewPassword = 'newPassword123!';

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    repository = AuthRepositoryImpl(mockRemoteDataSource);
  });

  group('sendPasswordResetOtp', () {
    test('should return Right(unit) when remoteDataSource succeeds', () async {
      when(
        () => mockRemoteDataSource.sendPasswordResetOtp(
          email: any(named: 'email'),
        ),
      ).thenAnswer((_) async {});

      final result = await repository.sendPasswordResetOtp(email: tEmail);

      expect(result, const Right<Failure, Unit>(unit));
      verify(
        () => mockRemoteDataSource.sendPasswordResetOtp(email: tEmail),
      ).called(1);
    });

    test(
      'should return Left(AuthFailure) on AuthExceptionWrapper',
      () async {
        when(
          () => mockRemoteDataSource.sendPasswordResetOtp(
            email: any(named: 'email'),
          ),
        ).thenThrow(const AuthExceptionWrapper(message: 'Email not found'));

        final result = await repository.sendPasswordResetOtp(email: tEmail);

        expect(
          result,
          const Left<Failure, Unit>(AuthFailure('Email not found')),
        );
      },
    );
  });

  group('verifyPasswordResetOtp', () {
    test('should return Right(unit) when verification succeeds', () async {
      when(
        () => mockRemoteDataSource.verifyPasswordResetOtp(
          email: any(named: 'email'),
          token: any(named: 'token'),
        ),
      ).thenAnswer((_) async {});

      final result = await repository.verifyPasswordResetOtp(
        email: tEmail,
        token: tToken,
      );

      expect(result, const Right<Failure, Unit>(unit));
      verify(
        () => mockRemoteDataSource.verifyPasswordResetOtp(
          email: tEmail,
          token: tToken,
        ),
      ).called(1);
    });

    test('should return Left(AuthFailure) when token is invalid', () async {
      when(
        () => mockRemoteDataSource.verifyPasswordResetOtp(
          email: any(named: 'email'),
          token: any(named: 'token'),
        ),
      ).thenThrow(const AuthExceptionWrapper(message: 'Invalid OTP'));

      final result = await repository.verifyPasswordResetOtp(
        email: tEmail,
        token: tToken,
      );

      expect(
        result,
        const Left<Failure, Unit>(AuthFailure('Invalid OTP')),
      );
    });
  });

  group('updatePassword', () {
    test('should return Right(unit) when update succeeds', () async {
      when(
        () => mockRemoteDataSource.updatePassword(
          newPassword: any(named: 'newPassword'),
        ),
      ).thenAnswer((_) async {});

      final result = await repository.updatePassword(
        newPassword: tNewPassword,
      );

      expect(result, const Right<Failure, Unit>(unit));
      verify(
        () => mockRemoteDataSource.updatePassword(newPassword: tNewPassword),
      ).called(1);
    });
  });

  group('resendPasswordResetOtp', () {
    test('should return Right(unit) when resend succeeds', () async {
      when(
        () => mockRemoteDataSource.resendPasswordResetOtp(
          email: any(named: 'email'),
        ),
      ).thenAnswer((_) async {});

      final result = await repository.resendPasswordResetOtp(email: tEmail);

      expect(result, const Right<Failure, Unit>(unit));
      verify(
        () => mockRemoteDataSource.resendPasswordResetOtp(email: tEmail),
      ).called(1);
    });
  });

  group('verifySignUpOtp', () {
    test('should return Right(unit) when verifySignUpOtp succeeds', () async {
      when(
        () => mockRemoteDataSource.verifySignUpOtp(
          email: any(named: 'email'),
          token: any(named: 'token'),
        ),
      ).thenAnswer((_) async {});

      final result = await repository.verifySignUpOtp(
        email: tEmail,
        token: tToken,
      );

      expect(result, const Right<Failure, Unit>(unit));
      verify(
        () => mockRemoteDataSource.verifySignUpOtp(
          email: tEmail,
          token: tToken,
        ),
      ).called(1);
    });
  });

  group('resendSignUpOtp', () {
    test('should return Right(unit) when resendSignUpOtp succeeds', () async {
      when(
        () => mockRemoteDataSource.resendSignUpOtp(
          email: any(named: 'email'),
        ),
      ).thenAnswer((_) async {});

      final result = await repository.resendSignUpOtp(email: tEmail);

      expect(result, const Right<Failure, Unit>(unit));
      verify(
        () => mockRemoteDataSource.resendSignUpOtp(email: tEmail),
      ).called(1);
    });
  });
}
