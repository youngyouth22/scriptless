import 'package:scriptless/core/error/exceptions.dart';
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

  /// Initiates Google OAuth sign-in flow.
  Future<void> signInWithGoogle();

  /// Initiates Twitter / X OAuth sign-in flow.
  Future<void> signInWithTwitter();

  /// Initiates LinkedIn OAuth sign-in flow.
  Future<void> signInWithLinkedIn();

  /// Returns the currently authenticated user, or null.
  AppUserModel? getCurrentUser();

  /// A stream that emits the current user whenever the auth state changes.
  Stream<AppUserModel?> get authStateChanges;
}

/// Supabase implementation of [AuthRemoteDataSource].
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  /// Creates an [AuthRemoteDataSourceImpl].
  const AuthRemoteDataSourceImpl(this._client);

  final SupabaseClient _client;

  static const String _redirectUrl = 'com.ootaris.scriptless://auth/callback';

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
      await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: _redirectUrl,
      );
    } on AuthException catch (e) {
      throw AuthExceptionWrapper(message: e.message);
    } on Exception catch (e) {
      throw AuthExceptionWrapper(message: e.toString());
    }
  }

  @override
  Future<void> signInWithTwitter() async {
    try {
      await _client.auth.signInWithOAuth(
        OAuthProvider.twitter,
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
      await _client.auth.signOut();
    } on AuthException catch (e) {
      throw AuthExceptionWrapper(message: e.message);
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
}
