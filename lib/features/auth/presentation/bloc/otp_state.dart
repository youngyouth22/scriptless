part of 'otp_bloc.dart';

/// Actions that can be performed in the OTP / Password Reset flow.
enum OtpActionType {
  /// Sending the OTP email.
  sendEmail,

  /// Verifying the OTP code.
  verifyOtp,

  /// Updating the new password.
  updatePassword,

  /// Resending the OTP code.
  resendOtp,
}

/// States emitted by [OtpBloc].
@immutable
sealed class OtpState {
  const OtpState();
}

/// Initial state of the OTP / Password reset flow.
final class OtpInitial extends OtpState {
  /// Default constructor.
  const OtpInitial();
}

/// An async action is in progress.
@immutable
final class OtpLoading extends OtpState {
  /// Creates an [OtpLoading] state.
  const OtpLoading({required this.action});

  /// The action currently being performed.
  final OtpActionType action;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OtpLoading &&
          runtimeType == other.runtimeType &&
          action == other.action;

  @override
  int get hashCode => action.hashCode;
}

/// The OTP was successfully sent to the requested [email].
@immutable
final class OtpEmailSentSuccess extends OtpState {
  /// Creates an [OtpEmailSentSuccess] state.
  const OtpEmailSentSuccess(this.email);

  /// The email address to which the OTP was dispatched.
  final String email;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OtpEmailSentSuccess &&
          runtimeType == other.runtimeType &&
          email == other.email;

  @override
  int get hashCode => email.hashCode;
}

/// The OTP token was successfully verified.
@immutable
final class OtpVerifiedSuccess extends OtpState {
  /// Creates an [OtpVerifiedSuccess] state.
  const OtpVerifiedSuccess(this.email);

  /// The verified email.
  final String email;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OtpVerifiedSuccess &&
          runtimeType == other.runtimeType &&
          email == other.email;

  @override
  int get hashCode => email.hashCode;
}

/// The new password was successfully set.
final class OtpPasswordResetSuccess extends OtpState {
  /// Default constructor.
  const OtpPasswordResetSuccess();
}

/// An error occurred during the OTP / Password reset flow.
@immutable
final class OtpFailureState extends OtpState {
  /// Creates an [OtpFailureState].
  const OtpFailureState(this.failure);

  /// The typed failure.
  final Failure failure;

  /// Convenience getter for human-readable error message.
  String get message => failure.message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OtpFailureState &&
          runtimeType == other.runtimeType &&
          failure == other.failure;

  @override
  int get hashCode => failure.hashCode;
}
