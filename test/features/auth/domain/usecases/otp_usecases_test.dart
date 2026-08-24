import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/features/auth/domain/repositories/auth_repository.dart';
import 'package:scriptless/features/auth/domain/usecases/resend_password_reset_otp_usecase.dart';
import 'package:scriptless/features/auth/domain/usecases/resend_sign_up_otp_usecase.dart';
import 'package:scriptless/features/auth/domain/usecases/send_password_reset_otp_usecase.dart';
import 'package:scriptless/features/auth/domain/usecases/update_password_usecase.dart';
import 'package:scriptless/features/auth/domain/usecases/verify_password_reset_otp_usecase.dart';
import 'package:scriptless/features/auth/domain/usecases/verify_sign_up_otp_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepository;
  late SendPasswordResetOtpUseCase sendPasswordResetOtpUseCase;
  late VerifyPasswordResetOtpUseCase verifyPasswordResetOtpUseCase;
  late UpdatePasswordUseCase updatePasswordUseCase;
  late ResendPasswordResetOtpUseCase resendPasswordResetOtpUseCase;
  late VerifySignUpOtpUseCase verifySignUpOtpUseCase;
  late ResendSignUpOtpUseCase resendSignUpOtpUseCase;

  const tEmail = 'test@example.com';
  const tToken = '123456';
  const tNewPassword = 'newPassword123!';

  setUp(() {
    mockRepository = MockAuthRepository();
    sendPasswordResetOtpUseCase = SendPasswordResetOtpUseCase(mockRepository);
    verifyPasswordResetOtpUseCase =
        VerifyPasswordResetOtpUseCase(mockRepository);
    updatePasswordUseCase = UpdatePasswordUseCase(mockRepository);
    resendPasswordResetOtpUseCase =
        ResendPasswordResetOtpUseCase(mockRepository);
    verifySignUpOtpUseCase = VerifySignUpOtpUseCase(mockRepository);
    resendSignUpOtpUseCase = ResendSignUpOtpUseCase(mockRepository);
  });

  group('SendPasswordResetOtpUseCase', () {
    test('should return Right(unit) on success', () async {
      when(
        () => mockRepository.sendPasswordResetOtp(
          email: any(named: 'email'),
        ),
      ).thenAnswer((_) async => const Right(unit));

      final result = await sendPasswordResetOtpUseCase(tEmail);

      expect(result, const Right<Failure, Unit>(unit));
      verify(
        () => mockRepository.sendPasswordResetOtp(email: tEmail),
      ).called(1);
    });

    test('should return Left(Failure) on repository failure', () async {
      const tFailure = AuthFailure('User not found');
      when(
        () => mockRepository.sendPasswordResetOtp(
          email: any(named: 'email'),
        ),
      ).thenAnswer((_) async => const Left(tFailure));

      final result = await sendPasswordResetOtpUseCase(tEmail);

      expect(result, const Left<Failure, Unit>(tFailure));
      verify(
        () => mockRepository.sendPasswordResetOtp(email: tEmail),
      ).called(1);
    });
  });

  group('VerifyPasswordResetOtpUseCase', () {
    const tParams = VerifyOtpParams(email: tEmail, token: tToken);

    test('should return Right(unit) on successful OTP verification', () async {
      when(
        () => mockRepository.verifyPasswordResetOtp(
          email: any(named: 'email'),
          token: any(named: 'token'),
        ),
      ).thenAnswer((_) async => const Right(unit));

      final result = await verifyPasswordResetOtpUseCase(tParams);

      expect(result, const Right<Failure, Unit>(unit));
      verify(
        () => mockRepository.verifyPasswordResetOtp(
          email: tEmail,
          token: tToken,
        ),
      ).called(1);
    });

    test('should return Left(Failure) on invalid OTP token', () async {
      const tFailure = AuthFailure('Invalid OTP code');
      when(
        () => mockRepository.verifyPasswordResetOtp(
          email: any(named: 'email'),
          token: any(named: 'token'),
        ),
      ).thenAnswer((_) async => const Left(tFailure));

      final result = await verifyPasswordResetOtpUseCase(tParams);

      expect(result, const Left<Failure, Unit>(tFailure));
      verify(
        () => mockRepository.verifyPasswordResetOtp(
          email: tEmail,
          token: tToken,
        ),
      ).called(1);
    });
  });

  group('VerifySignUpOtpUseCase', () {
    const tParams = VerifyOtpParams(email: tEmail, token: tToken);

    test('should return Right(unit) on successful sign up OTP', () async {
      when(
        () => mockRepository.verifySignUpOtp(
          email: any(named: 'email'),
          token: any(named: 'token'),
        ),
      ).thenAnswer((_) async => const Right(unit));

      final result = await verifySignUpOtpUseCase(tParams);

      expect(result, const Right<Failure, Unit>(unit));
      verify(
        () => mockRepository.verifySignUpOtp(
          email: tEmail,
          token: tToken,
        ),
      ).called(1);
    });
  });

  group('UpdatePasswordUseCase', () {
    test('should return Right(unit) on successful password update', () async {
      when(
        () => mockRepository.updatePassword(
          newPassword: any(named: 'newPassword'),
        ),
      ).thenAnswer((_) async => const Right(unit));

      final result = await updatePasswordUseCase(tNewPassword);

      expect(result, const Right<Failure, Unit>(unit));
      verify(
        () => mockRepository.updatePassword(newPassword: tNewPassword),
      ).called(1);
    });

    test('should return Left(Failure) on update failure', () async {
      const tFailure = AuthFailure('Password too weak');
      when(
        () => mockRepository.updatePassword(
          newPassword: any(named: 'newPassword'),
        ),
      ).thenAnswer((_) async => const Left(tFailure));

      final result = await updatePasswordUseCase(tNewPassword);

      expect(result, const Left<Failure, Unit>(tFailure));
      verify(
        () => mockRepository.updatePassword(newPassword: tNewPassword),
      ).called(1);
    });
  });

  group('ResendPasswordResetOtpUseCase', () {
    test('should return Right(unit) on successful OTP resend', () async {
      when(
        () => mockRepository.resendPasswordResetOtp(
          email: any(named: 'email'),
        ),
      ).thenAnswer((_) async => const Right(unit));

      final result = await resendPasswordResetOtpUseCase(tEmail);

      expect(result, const Right<Failure, Unit>(unit));
      verify(
        () => mockRepository.resendPasswordResetOtp(email: tEmail),
      ).called(1);
    });

    test('should return Left(Failure) on resend failure', () async {
      const tFailure = ServerFailure('Rate limit exceeded');
      when(
        () => mockRepository.resendPasswordResetOtp(
          email: any(named: 'email'),
        ),
      ).thenAnswer((_) async => const Left(tFailure));

      final result = await resendPasswordResetOtpUseCase(tEmail);

      expect(result, const Left<Failure, Unit>(tFailure));
      verify(
        () => mockRepository.resendPasswordResetOtp(email: tEmail),
      ).called(1);
    });
  });

  group('ResendSignUpOtpUseCase', () {
    test(
      'should return Right(unit) on successful sign up OTP resend',
      () async {
        when(
          () => mockRepository.resendSignUpOtp(
            email: any(named: 'email'),
          ),
        ).thenAnswer((_) async => const Right(unit));

        final result = await resendSignUpOtpUseCase(tEmail);

        expect(result, const Right<Failure, Unit>(unit));
        verify(
          () => mockRepository.resendSignUpOtp(email: tEmail),
        ).called(1);
      },
    );
  });

}
