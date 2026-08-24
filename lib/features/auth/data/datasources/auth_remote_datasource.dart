import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:scriptless/core/error/exceptions.dart';
import 'package:scriptless/core/powersync/powersync.dart';
import 'package:scriptless/features/auth/data/models/app_user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Contract for the remote auth data source.
abstract class AuthRemoteDataSource {
  /// Signs in with [email] and [password].
  Future<AppUserModel> signInWithEmail({
    required String email,
    required String password,
  });

  /// Registers a new user with [email] and [password].
  Future<AppUserModel> signUpWithEmail({
    required String email,
    required String password,
  });

  /// Signs out the current user.
  Future<void> signOut();

  /// Initiates Google Sign-In using native Google SDK and Supabase ID token.
  Future<void> signInWithGoogle();

  /// Initiates Twitter / X OAuth sign-in flow.
  Future<void> signInWithTwitter();

  /// Initiates LinkedIn OAuth sign-in flow.
  Future<void> signInWithLinkedIn();

  /// Returns the currently authenticated user, or null.
  AppUserModel? getCurrentUser();

  /// A stream that emits the current user whenever the auth state changes.
  Stream<AppUserModel?> get authStateChanges;

  /// Sends a password reset OTP code to the provided [email].
  Future<void> sendPasswordResetOtp({required String email});

  /// Verifies the recovery OTP [token] for [email].
  Future<void> verifyPasswordResetOtp({
    required String email,
    required String token,
  });

  /// Updates the user's password to [newPassword].
  Future<void> updatePassword({required String newPassword});

  /// Resends the password reset OTP code to [email].
  Future<void> resendPasswordResetOtp({required String email});

  /// Verifies the sign-up confirmation OTP [token] for [email].
  Future<void> verifySignUpOtp({
    required String email,
    required String token,
  });

  /// Resends the sign-up verification OTP code to [email].
  Future<void> resendSignUpOtp({required String email});
}

/// Supabase implementation of [AuthRemoteDataSource].
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  /// Creates an [AuthRemoteDataSourceImpl].
  AuthRemoteDataSourceImpl(
    this._client, {
    this.powerSyncService,
    GoogleSignIn? googleSignIn,
    this.serverClientId,
  }) : _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final SupabaseClient _client;

  /// Optional PowerSync service to clear local database on sign out.
  final PowerSyncService? powerSyncService;
  final GoogleSignIn _googleSignIn;

  /// Optional server client ID override for Google Sign-In.
  final String? serverClientId;
  bool _isGoogleInitialized = false;

  static const String _redirectUrl = 'com.ootaris.scriptless://auth/callback';

  Future<void> _ensureGoogleInitialized() async {
    if (_isGoogleInitialized) return;
    var clientId = serverClientId;
    if (clientId == null || clientId.isEmpty) {
      if (dotenv.isInitialized) {
        clientId =
            dotenv.env['GOOGLE_WEB_CLIENT_ID'] ??
            dotenv.env['GOOGLE_SERVER_CLIENT_ID'];
      }
      clientId ??= const String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');
    }
    if (clientId.isNotEmpty) {
      try {
        await _googleSignIn.initialize(serverClientId: clientId);
      } on Exception catch (_) {
        // Ignored if already initialized on startup
      }
    }
    _isGoogleInitialized = true;
  }

  @override
  Future<AppUserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null) {
        throw const AuthExceptionWrapper(message: 'Sign in returned no user.');
      }
      return AppUserModel.fromSupabaseUser(user);
    } on AuthException catch (e) {
      throw AuthExceptionWrapper(message: e.message);
    } on Exception catch (e) {
      throw AuthExceptionWrapper(message: e.toString());
    }
  }

  @override
  Future<AppUserModel> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null) {
        throw const AuthExceptionWrapper(message: 'Sign up returned no user.');
      }
      return AppUserModel.fromSupabaseUser(user);
    } on AuthException catch (e) {
      throw AuthExceptionWrapper(message: e.message);
    } on Exception catch (e) {
      throw AuthExceptionWrapper(message: e.toString());
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    try {
      await _ensureGoogleInitialized();
      final googleAccount = await _googleSignIn.authenticate();
      final idToken = googleAccount.authentication.idToken;

      if (idToken == null) {
        throw const AuthExceptionWrapper(
          message: 'No ID token found for Google sign in.',
        );
      }

      await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw const AuthExceptionWrapper(
          message: 'Google sign in was cancelled.',
        );
      }
      throw AuthExceptionWrapper(
        message: e.description ?? e.code.name,
      );
    } on AuthException catch (e) {
      throw AuthExceptionWrapper(message: e.message);
    } on AuthExceptionWrapper {
      rethrow;
    } on Exception catch (e) {
      throw AuthExceptionWrapper(message: e.toString());
    }
  }

  @override
  Future<void> signInWithTwitter() async {
    try {
      await _client.auth.signInWithOAuth(
        OAuthProvider.x,
        redirectTo: _redirectUrl,
      );
    } on AuthException catch (e) {
      throw AuthExceptionWrapper(message: e.message);
    } on Exception catch (e) {
      throw AuthExceptionWrapper(message: e.toString());
    }
  }

  @override
  Future<void> signInWithLinkedIn() async {
    try {
      await _client.auth.signInWithOAuth(
        OAuthProvider.linkedinOidc,
        redirectTo: _redirectUrl,
      );
    } on AuthException catch (e) {
      throw AuthExceptionWrapper(message: e.message);
    } on Exception catch (e) {
      throw AuthExceptionWrapper(message: e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      final futures = <Future<void>>[
        _client.auth.signOut(),
        _googleSignIn.signOut(),
      ];
      final powerSync = powerSyncService;
      if (powerSync != null) {
        futures.add(powerSync.disconnectAndClear());
      }
      await Future.wait(futures);
    } on AuthException catch (e) {
      throw AuthExceptionWrapper(message: e.message);
    } on Exception catch (e) {
      throw AuthExceptionWrapper(message: e.toString());
    }
  }

  @override
  AppUserModel? getCurrentUser() {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return AppUserModel.fromSupabaseUser(user);
  }

  @override
  Stream<AppUserModel?> get authStateChanges =>
      _client.auth.onAuthStateChange.map((event) {
        final user = event.session?.user;
        if (user == null) return null;
        return AppUserModel.fromSupabaseUser(user);
      });

  @override
  Future<void> sendPasswordResetOtp({required String email}) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw AuthExceptionWrapper(message: e.message);
    } on Exception catch (e) {
      throw AuthExceptionWrapper(message: e.toString());
    }
  }

  @override
  Future<void> verifyPasswordResetOtp({
    required String email,
    required String token,
  }) async {
    try {
      await _client.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.recovery,
      );
    } on AuthException catch (e) {
      throw AuthExceptionWrapper(message: e.message);
    } on Exception catch (e) {
      throw AuthExceptionWrapper(message: e.toString());
    }
  }

  @override
  Future<void> updatePassword({required String newPassword}) async {
    try {
      await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } on AuthException catch (e) {
      throw AuthExceptionWrapper(message: e.message);
    } on Exception catch (e) {
      throw AuthExceptionWrapper(message: e.toString());
    }
  }

  @override
  Future<void> resendPasswordResetOtp({required String email}) async {
    try {
      await _client.auth.resend(
        type: OtpType.recovery,
        email: email,
      );
    } on AuthException catch (e) {
      throw AuthExceptionWrapper(message: e.message);
    } on Exception catch (e) {
      throw AuthExceptionWrapper(message: e.toString());
    }
  }

  @override
  Future<void> verifySignUpOtp({
    required String email,
    required String token,
  }) async {
    try {
      await _client.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.signup,
      );
    } on AuthException catch (e) {
      throw AuthExceptionWrapper(message: e.message);
    } on Exception catch (e) {
      throw AuthExceptionWrapper(message: e.toString());
    }
  }

  @override
  Future<void> resendSignUpOtp({required String email}) async {
    try {
      await _client.auth.resend(
        type: OtpType.signup,
        email: email,
      );
    } on AuthException catch (e) {
      throw AuthExceptionWrapper(message: e.message);
    } on Exception catch (e) {
      throw AuthExceptionWrapper(message: e.toString());
    }
  }
}
