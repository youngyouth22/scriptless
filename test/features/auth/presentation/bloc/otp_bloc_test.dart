import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/features/auth/domain/usecases/resend_password_reset_otp_usecase.dart';
import 'package:scriptless/features/auth/domain/usecases/resend_sign_up_otp_usecase.dart';
import 'package:scriptless/features/auth/domain/usecases/send_password_reset_otp_usecase.dart';
import 'package:scriptless/features/auth/domain/usecases/update_password_usecase.dart';
import 'package:scriptless/features/auth/domain/usecases/verify_password_reset_otp_usecase.dart';
import 'package:scriptless/features/auth/domain/usecases/verify_sign_up_otp_usecase.dart';
import 'package:scriptless/features/auth/presentation/bloc/otp_bloc.dart';

class MockSendPasswordResetOtpUseCase extends Mock
    implements SendPasswordResetOtpUseCase {}

class MockVerifyPasswordResetOtpUseCase extends Mock
    implements VerifyPasswordResetOtpUseCase {}

class MockUpdatePasswordUseCase extends Mock
    implements UpdatePasswordUseCase {}

class MockResendPasswordResetOtpUseCase extends Mock
    implements ResendPasswordResetOtpUseCase {}

class MockVerifySignUpOtpUseCase extends Mock
    implements VerifySignUpOtpUseCase {}

class MockResendSignUpOtpUseCase extends Mock
    implements ResendSignUpOtpUseCase {}

void main() {
  late MockSendPasswordResetOtpUseCase mockSendOtp;
  late MockVerifyPasswordResetOtpUseCase mockVerifyOtp;
  late MockUpdatePasswordUseCase mockUpdatePassword;
  late MockResendPasswordResetOtpUseCase mockResendOtp;
  late MockVerifySignUpOtpUseCase mockVerifySignUpOtp;
  late MockResendSignUpOtpUseCase mockResendSignUpOtp;
  late OtpBloc otpBloc;

  const tEmail = 'test@example.com';
  const tToken = '123456';
  const tPassword = 'newPassword123!';

  setUpAll(() {
    registerFallbackValue(const VerifyOtpParams(email: '', token: ''));
  });

  setUp(() {
    mockSendOtp = MockSendPasswordResetOtpUseCase();
    mockVerifyOtp = MockVerifyPasswordResetOtpUseCase();
    mockUpdatePassword = MockUpdatePasswordUseCase();
    mockResendOtp = MockResendPasswordResetOtpUseCase();
    mockVerifySignUpOtp = MockVerifySignUpOtpUseCase();
    mockResendSignUpOtp = MockResendSignUpOtpUseCase();

    otpBloc = OtpBloc(
      sendPasswordResetOtp: mockSendOtp,
      verifyPasswordResetOtp: mockVerifyOtp,
      updatePassword: mockUpdatePassword,
      resendPasswordResetOtp: mockResendOtp,
      verifySignUpOtp: mockVerifySignUpOtp,
      resendSignUpOtp: mockResendSignUpOtp,
    );
  });

  tearDown(() async {
    await otpBloc.close();
  });

  test('initial state is OtpInitial', () {
    expect(otpBloc.state, const OtpInitial());
  });

  group('OtpEmailSubmitted', () {
    blocTest<OtpBloc, OtpState>(
      'emits [OtpLoading, OtpEmailSentSuccess] on successful email submission',
      build: () {
        when(
          () => mockSendOtp(any()),
        ).thenAnswer((_) async => const Right(unit));
        return otpBloc;
      },
      act: (bloc) => bloc.add(const OtpEmailSubmitted(tEmail)),
      expect: () => [
        const OtpLoading(action: OtpActionType.sendEmail),
        const OtpEmailSentSuccess(tEmail),
      ],
      verify: (_) {
        verify(() => mockSendOtp(tEmail)).called(1);
      },
    );

    blocTest<OtpBloc, OtpState>(
      'emits [OtpLoading, OtpFailureState] on email send failure',
      build: () {
        when(
          () => mockSendOtp(any()),
        ).thenAnswer((_) async => const Left(AuthFailure('Email not found')));
        return otpBloc;
      },
      act: (bloc) => bloc.add(const OtpEmailSubmitted(tEmail)),
      expect: () => [
        const OtpLoading(action: OtpActionType.sendEmail),
        const OtpFailureState(AuthFailure('Email not found')),
      ],
    );
  });

  group('OtpCodeSubmitted', () {
    blocTest<OtpBloc, OtpState>(
      'emits [OtpLoading, OtpVerifiedSuccess] on successful OTP verification',
      build: () {
        when(
          () => mockVerifyOtp(any()),
        ).thenAnswer((_) async => const Right(unit));
        return otpBloc;
      },
      act: (bloc) => bloc.add(
        const OtpCodeSubmitted(email: tEmail, token: tToken),
      ),
      expect: () => [
        const OtpLoading(action: OtpActionType.verifyOtp),
        const OtpVerifiedSuccess(tEmail),
      ],
    );

    blocTest<OtpBloc, OtpState>(
      'emits [OtpLoading, OtpVerifiedSuccess] on successful sign-up OTP',
      build: () {
        when(
          () => mockVerifySignUpOtp(any()),
        ).thenAnswer((_) async => const Right(unit));
        return otpBloc;
      },
      act: (bloc) => bloc.add(
        const OtpCodeSubmitted(
          email: tEmail,
          token: tToken,
          isSignUpVerification: true,
        ),
      ),
      expect: () => [
        const OtpLoading(action: OtpActionType.verifyOtp),
        const OtpVerifiedSuccess(tEmail),
      ],
    );

    blocTest<OtpBloc, OtpState>(
      'emits [OtpLoading, OtpFailureState] on OTP verification failure',
      build: () {
        when(
          () => mockVerifyOtp(any()),
        ).thenAnswer((_) async => const Left(AuthFailure('Invalid code')));
        return otpBloc;
      },
      act: (bloc) => bloc.add(
        const OtpCodeSubmitted(email: tEmail, token: tToken),
      ),
      expect: () => [
        const OtpLoading(action: OtpActionType.verifyOtp),
        const OtpFailureState(AuthFailure('Invalid code')),
      ],
    );
  });

  group('OtpNewPasswordSubmitted', () {
    blocTest<OtpBloc, OtpState>(
      'emits [OtpLoading, OtpPasswordResetSuccess] on successful update',
      build: () {
        when(
          () => mockUpdatePassword(any()),
        ).thenAnswer((_) async => const Right(unit));
        return otpBloc;
      },
      act: (bloc) => bloc.add(const OtpNewPasswordSubmitted(tPassword)),
      expect: () => [
        const OtpLoading(action: OtpActionType.updatePassword),
        const OtpPasswordResetSuccess(),
      ],
    );

    blocTest<OtpBloc, OtpState>(
      'emits [OtpLoading, OtpFailureState] on password update failure',
      build: () {
        when(
          () => mockUpdatePassword(any()),
        ).thenAnswer((_) async => const Left(AuthFailure('Weak password')));
        return otpBloc;
      },
      act: (bloc) => bloc.add(const OtpNewPasswordSubmitted(tPassword)),
      expect: () => [
        const OtpLoading(action: OtpActionType.updatePassword),
        const OtpFailureState(AuthFailure('Weak password')),
      ],
    );
  });

  group('OtpResendRequested', () {
    blocTest<OtpBloc, OtpState>(
      'emits [OtpLoading, OtpEmailSentSuccess] on successful OTP resend',
      build: () {
        when(
          () => mockResendOtp(any()),
        ).thenAnswer((_) async => const Right(unit));
        return otpBloc;
      },
      act: (bloc) => bloc.add(const OtpResendRequested(tEmail)),
      expect: () => [
        const OtpLoading(action: OtpActionType.resendOtp),
        const OtpEmailSentSuccess(tEmail),
      ],
    );

    blocTest<OtpBloc, OtpState>(
      'emits [OtpLoading, OtpEmailSentSuccess] on successful sign-up resend',
      build: () {
        when(
          () => mockResendSignUpOtp(any()),
        ).thenAnswer((_) async => const Right(unit));
        return otpBloc;
      },
      act: (bloc) => bloc.add(
        const OtpResendRequested(
          tEmail,
          isSignUpVerification: true,
        ),
      ),
      expect: () => [
        const OtpLoading(action: OtpActionType.resendOtp),
        const OtpEmailSentSuccess(tEmail),
      ],
    );
  });

  group('OtpResetRequested', () {
    blocTest<OtpBloc, OtpState>(
      'resets state to OtpInitial',
      build: () => otpBloc,
      act: (bloc) => bloc.add(const OtpResetRequested()),
      expect: () => [const OtpInitial()],
    );
  });
}
