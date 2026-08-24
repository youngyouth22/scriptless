// Bloc constructors must call super() in the initializer list, which prevents
// using initializing formals (this._field) for private fields.
// ignore_for_file: prefer_initializing_formals
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/features/auth/domain/usecases/resend_password_reset_otp_usecase.dart';
import 'package:scriptless/features/auth/domain/usecases/resend_sign_up_otp_usecase.dart';
import 'package:scriptless/features/auth/domain/usecases/send_password_reset_otp_usecase.dart';
import 'package:scriptless/features/auth/domain/usecases/update_password_usecase.dart';
import 'package:scriptless/features/auth/domain/usecases/verify_password_reset_otp_usecase.dart';
import 'package:scriptless/features/auth/domain/usecases/verify_sign_up_otp_usecase.dart';

part 'otp_event.dart';
part 'otp_state.dart';

/// Manages OTP verification and password reset/update state.
class OtpBloc extends Bloc<OtpEvent, OtpState> {
  /// Creates an [OtpBloc].
  OtpBloc({
    required SendPasswordResetOtpUseCase sendPasswordResetOtp,
    required VerifyPasswordResetOtpUseCase verifyPasswordResetOtp,
    required UpdatePasswordUseCase updatePassword,
    required ResendPasswordResetOtpUseCase resendPasswordResetOtp,
    required VerifySignUpOtpUseCase verifySignUpOtp,
    required ResendSignUpOtpUseCase resendSignUpOtp,
  }) : _sendPasswordResetOtp = sendPasswordResetOtp,
       _verifyPasswordResetOtp = verifyPasswordResetOtp,
       _updatePassword = updatePassword,
       _resendPasswordResetOtp = resendPasswordResetOtp,
       _verifySignUpOtp = verifySignUpOtp,
       _resendSignUpOtp = resendSignUpOtp,
       super(const OtpInitial()) {
    on<OtpEmailSubmitted>(_onEmailSubmitted);
    on<OtpCodeSubmitted>(_onCodeSubmitted);
    on<OtpNewPasswordSubmitted>(_onNewPasswordSubmitted);
    on<OtpResendRequested>(_onResendRequested);
    on<OtpResetRequested>(_onResetRequested);
  }

  final SendPasswordResetOtpUseCase _sendPasswordResetOtp;
  final VerifyPasswordResetOtpUseCase _verifyPasswordResetOtp;
  final UpdatePasswordUseCase _updatePassword;
  final ResendPasswordResetOtpUseCase _resendPasswordResetOtp;
  final VerifySignUpOtpUseCase _verifySignUpOtp;
  final ResendSignUpOtpUseCase _resendSignUpOtp;

  void _onResetRequested(
    OtpResetRequested event,
    Emitter<OtpState> emit,
  ) {
    emit(const OtpInitial());
  }

  Future<void> _onEmailSubmitted(
    OtpEmailSubmitted event,
    Emitter<OtpState> emit,
  ) async {
    emit(const OtpLoading(action: OtpActionType.sendEmail));
    log('OtpBloc: sending OTP email to ${event.email}', name: 'auth.otp');

    final result = await _sendPasswordResetOtp(event.email);

    result.fold(
      (failure) {
        log('OtpBloc: send OTP failed — ${failure.message}', name: 'auth.otp');
        emit(OtpFailureState(failure));
      },
      (_) {
        log('OtpBloc: send OTP success for ${event.email}', name: 'auth.otp');
        emit(OtpEmailSentSuccess(event.email));
      },
    );
  }

  Future<void> _onCodeSubmitted(
    OtpCodeSubmitted event,
    Emitter<OtpState> emit,
  ) async {
    emit(const OtpLoading(action: OtpActionType.verifyOtp));
    log('OtpBloc: verifying OTP for ${event.email}', name: 'auth.otp');

    final Either<Failure, Unit> result;
    if (event.isSignUpVerification) {
      result = await _verifySignUpOtp(
        VerifyOtpParams(email: event.email, token: event.token),
      );
    } else {
      result = await _verifyPasswordResetOtp(
        VerifyOtpParams(email: event.email, token: event.token),
      );
    }

    result.fold(
      (failure) {
        log(
          'OtpBloc: verify OTP failed — ${failure.message}',
          name: 'auth.otp',
        );
        emit(OtpFailureState(failure));
      },
      (_) {
        log(
          'OtpBloc: verify OTP success for ${event.email}',
          name: 'auth.otp',
        );
        emit(OtpVerifiedSuccess(event.email));
      },
    );
  }

  Future<void> _onNewPasswordSubmitted(
    OtpNewPasswordSubmitted event,
    Emitter<OtpState> emit,
  ) async {
    emit(const OtpLoading(action: OtpActionType.updatePassword));
    log('OtpBloc: updating password', name: 'auth.otp');

    final result = await _updatePassword(event.newPassword);

    result.fold(
      (failure) {
        log(
          'OtpBloc: update password failed — ${failure.message}',
          name: 'auth.otp',
        );
        emit(OtpFailureState(failure));
      },
      (_) {
        log('OtpBloc: update password success', name: 'auth.otp');
        emit(const OtpPasswordResetSuccess());
      },
    );
  }

  Future<void> _onResendRequested(
    OtpResendRequested event,
    Emitter<OtpState> emit,
  ) async {
    emit(const OtpLoading(action: OtpActionType.resendOtp));
    log('OtpBloc: resending OTP to ${event.email}', name: 'auth.otp');

    final Either<Failure, Unit> result;
    if (event.isSignUpVerification) {
      result = await _resendSignUpOtp(event.email);
    } else {
      result = await _resendPasswordResetOtp(event.email);
    }

    result.fold(
      (failure) {
        log(
          'OtpBloc: resend OTP failed — ${failure.message}',
          name: 'auth.otp',
        );
        emit(OtpFailureState(failure));
      },
      (_) {
        log(
          'OtpBloc: resend OTP success for ${event.email}',
          name: 'auth.otp',
        );
        emit(OtpEmailSentSuccess(event.email));
      },
    );
  }
}
