import 'package:dartz/dartz.dart';
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/features/auth/domain/entities/app_user.dart';

/// Contract for all authentication operations.
///
/// Implementations live in the data layer and must never be imported
/// directly from the presentation layer.
abstract class AuthRepository {
  /// Signs in a user with [email] and [password].
  ///
  /// Returns [AppUser] on success or an [AuthFailure] / [ServerFailure] on error.
  Future<Either<Failure, AppUser>> signInWithEmail({
    required String email,
    required String password,
  });

  /// Creates a new account with [email] and [password].
  ///
  /// Returns [AppUser] on success.
  Future<Either<Failure, AppUser>> signUpWithEmail({
    required String email,
    required String password,
  });

  /// Signs out the currently authenticated user.
  Future<Either<Failure, Unit>> signOut();

  /// Returns the currently authenticated [AppUser], or `null`
  /// if unauthenticated.
  Future<Either<Failure, AppUser?>> getCurrentUser();

  /// Emits the authenticated user whenever the auth state changes.
  ///
  /// Emits `null` when the session is lost.
  Stream<AppUser?> get authStateChanges;

  // ── OAuth ────────────────────────────────────────────────────────────────

  /// Initiates Google OAuth sign-in.
  ///
  /// Opens the system browser / in-app WebView. The session result arrives
  /// via [authStateChanges] after the deep-link callback is received.
  /// Returns [Unit] once the browser has been launched, or a [Failure].
  Future<Either<Failure, Unit>> signInWithGoogle();

  /// Initiates X (Twitter) OAuth sign-in.
  ///
  /// Same async pattern as [signInWithGoogle].
  Future<Either<Failure, Unit>> signInWithTwitter();

  /// Initiates LinkedIn OIDC sign-in.
  ///
  /// Same async pattern as [signInWithGoogle].
  Future<Either<Failure, Unit>> signInWithLinkedIn();

  // ── Password Reset & OTP ──────────────────────────────────────────────────

  /// Sends a password reset OTP code to the provided [email].
  Future<Either<Failure, Unit>> sendPasswordResetOtp({required String email});

  /// Verifies the OTP [token] sent to [email] for password recovery.
  Future<Either<Failure, Unit>> verifyPasswordResetOtp({
    required String email,
    required String token,
  });

  /// Updates the user's password to [newPassword].
  Future<Either<Failure, Unit>> updatePassword({required String newPassword});

  /// Resends the password reset OTP code to [email].
  Future<Either<Failure, Unit>> resendPasswordResetOtp({required String email});

  /// Verifies the OTP [token] sent to [email] for account registration
  /// confirmation.
  Future<Either<Failure, Unit>> verifySignUpOtp({
    required String email,
    required String token,
  });

  /// Resends the sign-up verification OTP code to [email].
  Future<Either<Failure, Unit>> resendSignUpOtp({required String email});
}
