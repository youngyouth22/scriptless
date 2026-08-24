part of 'otp_bloc.dart';

/// Events driving [OtpBloc].
@immutable
sealed class OtpEvent {
  const OtpEvent();
}

/// Request sending a password reset / verification OTP to [email].
@immutable
final class OtpEmailSubmitted extends OtpEvent {
  /// Creates an [OtpEmailSubmitted] event.
  const OtpEmailSubmitted(this.email);

  /// The email address to send the OTP to.
  final String email;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OtpEmailSubmitted &&
          runtimeType == other.runtimeType &&
          email == other.email;

  @override
  int get hashCode => email.hashCode;
}

/// Request verification of the 6-digit OTP code for [email].
@immutable
final class OtpCodeSubmitted extends OtpEvent {
  /// Creates an [OtpCodeSubmitted] event.
  const OtpCodeSubmitted({
    required this.email,
    required this.token,
    this.isSignUpVerification = false,
  });

  /// The user's email address.
  final String email;

  /// The OTP code.
  final String token;

  /// Whether this verification is for sign-up account confirmation.
  final bool isSignUpVerification;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OtpCodeSubmitted &&
          runtimeType == other.runtimeType &&
          email == other.email &&
          token == other.token &&
          isSignUpVerification == other.isSignUpVerification;

  @override
  int get hashCode => Object.hash(email, token, isSignUpVerification);
}

/// Request setting a new password after OTP verification.
@immutable
final class OtpNewPasswordSubmitted extends OtpEvent {
  /// Creates an [OtpNewPasswordSubmitted] event.
  const OtpNewPasswordSubmitted(this.newPassword);

  /// The new password.
  final String newPassword;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OtpNewPasswordSubmitted &&
          runtimeType == other.runtimeType &&
          newPassword == other.newPassword;

  @override
  int get hashCode => newPassword.hashCode;
}

/// Request resending the OTP code to [email].
@immutable
final class OtpResendRequested extends OtpEvent {
  /// Creates an [OtpResendRequested] event.
  const OtpResendRequested(
    this.email, {
    this.isSignUpVerification = false,
  });

  /// The email address.
  final String email;

  /// Whether this resend is for sign-up account confirmation.
  final bool isSignUpVerification;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OtpResendRequested &&
          runtimeType == other.runtimeType &&
          email == other.email &&
          isSignUpVerification == other.isSignUpVerification;

  @override
  int get hashCode => Object.hash(email, isSignUpVerification);
}

/// Resets the OTP state back to [OtpInitial].
@immutable
final class OtpResetRequested extends OtpEvent {
  /// Default constructor.
  const OtpResetRequested();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is OtpResetRequested;

  @override
  int get hashCode => runtimeType.hashCode;
}
