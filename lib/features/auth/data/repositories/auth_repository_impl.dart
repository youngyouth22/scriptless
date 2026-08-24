import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:scriptless/core/error/exceptions.dart';
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:scriptless/features/auth/domain/entities/app_user.dart';
import 'package:scriptless/features/auth/domain/repositories/auth_repository.dart';

/// Concrete implementation of [AuthRepository].
///
/// Catches typed exceptions from the data source and maps them to [Failure]
/// types so the domain / presentation layers never see raw exceptions.
class AuthRepositoryImpl implements AuthRepository {
  /// Creates an [AuthRepositoryImpl].
  const AuthRepositoryImpl(this._remoteDataSource);

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, AppUser>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final model = await _remoteDataSource.signInWithEmail(
        email: email,
        password: password,
      );
      return Right(model.toEntity());
    } on AuthExceptionWrapper catch (e) {
      log('AuthRepositoryImpl.signInWithEmail: ${e.message}', name: 'auth');
      return Left(AuthFailure(e.message));
    } on Exception catch (e) {
      log('AuthRepositoryImpl.signInWithEmail unexpected: $e', name: 'auth');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AppUser>> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final model = await _remoteDataSource.signUpWithEmail(
        email: email,
        password: password,
      );
      return Right(model.toEntity());
    } on AuthExceptionWrapper catch (e) {
      log('AuthRepositoryImpl.signUpWithEmail: ${e.message}', name: 'auth');
      return Left(AuthFailure(e.message));
    } on Exception catch (e) {
      log('AuthRepositoryImpl.signUpWithEmail unexpected: $e', name: 'auth');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> signInWithGoogle() async {
    try {
      await _remoteDataSource.signInWithGoogle();
      return const Right(unit);
    } on AuthExceptionWrapper catch (e) {
      log('AuthRepositoryImpl.signInWithGoogle: ${e.message}', name: 'auth');
      return Left(AuthFailure(e.message));
    } on Exception catch (e) {
      log('AuthRepositoryImpl.signInWithGoogle unexpected: $e', name: 'auth');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> signInWithTwitter() async {
    try {
      await _remoteDataSource.signInWithTwitter();
      return const Right(unit);
    } on AuthExceptionWrapper catch (e) {
      log('AuthRepositoryImpl.signInWithTwitter: ${e.message}', name: 'auth');
      return Left(AuthFailure(e.message));
    } on Exception catch (e) {
      log('AuthRepositoryImpl.signInWithTwitter unexpected: $e', name: 'auth');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> signInWithLinkedIn() async {
    try {
      await _remoteDataSource.signInWithLinkedIn();
      return const Right(unit);
    } on AuthExceptionWrapper catch (e) {
      log('AuthRepositoryImpl.signInWithLinkedIn: ${e.message}', name: 'auth');
      return Left(AuthFailure(e.message));
    } on Exception catch (e) {
      log('AuthRepositoryImpl.signInWithLinkedIn unexpected: $e', name: 'auth');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    try {
      await _remoteDataSource.signOut();
      return const Right(unit);
    } on AuthExceptionWrapper catch (e) {
      log('AuthRepositoryImpl.signOut: ${e.message}', name: 'auth');
      return Left(AuthFailure(e.message));
    } on Exception catch (e) {
      log('AuthRepositoryImpl.signOut unexpected: $e', name: 'auth');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AppUser?>> getCurrentUser() async {
    try {
      final model = _remoteDataSource.getCurrentUser();
      return Right(model?.toEntity());
    } on Exception catch (e) {
      log('AuthRepositoryImpl.getCurrentUser unexpected: $e', name: 'auth');
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Stream<AppUser?> get authStateChanges =>
      _remoteDataSource.authStateChanges.map((model) => model?.toEntity());

  @override
  Future<Either<Failure, Unit>> sendPasswordResetOtp({
    required String email,
  }) async {
    try {
      await _remoteDataSource.sendPasswordResetOtp(email: email);
      return const Right(unit);
    } on AuthExceptionWrapper catch (e) {
      log(
        'AuthRepositoryImpl.sendPasswordResetOtp: ${e.message}',
        name: 'auth',
      );
      return Left(AuthFailure(e.message));
    } on Exception catch (e) {
      log(
        'AuthRepositoryImpl.sendPasswordResetOtp unexpected: $e',
        name: 'auth',
      );
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> verifyPasswordResetOtp({
    required String email,
    required String token,
  }) async {
    try {
      await _remoteDataSource.verifyPasswordResetOtp(
        email: email,
        token: token,
      );
      return const Right(unit);
    } on AuthExceptionWrapper catch (e) {
      log(
        'AuthRepositoryImpl.verifyPasswordResetOtp: ${e.message}',
        name: 'auth',
      );
      return Left(AuthFailure(e.message));
    } on Exception catch (e) {
      log(
        'AuthRepositoryImpl.verifyPasswordResetOtp unexpected: $e',
        name: 'auth',
      );
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updatePassword({
    required String newPassword,
  }) async {
    try {
      await _remoteDataSource.updatePassword(newPassword: newPassword);
      return const Right(unit);
    } on AuthExceptionWrapper catch (e) {
      log('AuthRepositoryImpl.updatePassword: ${e.message}', name: 'auth');
      return Left(AuthFailure(e.message));
    } on Exception catch (e) {
      log('AuthRepositoryImpl.updatePassword unexpected: $e', name: 'auth');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> resendPasswordResetOtp({
    required String email,
  }) async {
    try {
      await _remoteDataSource.resendPasswordResetOtp(email: email);
      return const Right(unit);
    } on AuthExceptionWrapper catch (e) {
      log(
        'AuthRepositoryImpl.resendPasswordResetOtp: ${e.message}',
        name: 'auth',
      );
      return Left(AuthFailure(e.message));
    } on Exception catch (e) {
      log(
        'AuthRepositoryImpl.resendPasswordResetOtp unexpected: $e',
        name: 'auth',
      );
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> verifySignUpOtp({
    required String email,
    required String token,
  }) async {
    try {
      await _remoteDataSource.verifySignUpOtp(
        email: email,
        token: token,
      );
      return const Right(unit);
    } on AuthExceptionWrapper catch (e) {
      log(
        'AuthRepositoryImpl.verifySignUpOtp: ${e.message}',
        name: 'auth',
      );
      return Left(AuthFailure(e.message));
    } on Exception catch (e) {
      log(
        'AuthRepositoryImpl.verifySignUpOtp unexpected: $e',
        name: 'auth',
      );
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> resendSignUpOtp({
    required String email,
  }) async {
    try {
      await _remoteDataSource.resendSignUpOtp(email: email);
      return const Right(unit);
    } on AuthExceptionWrapper catch (e) {
      log(
        'AuthRepositoryImpl.resendSignUpOtp: ${e.message}',
        name: 'auth',
      );
      return Left(AuthFailure(e.message));
    } on Exception catch (e) {
      log(
        'AuthRepositoryImpl.resendSignUpOtp unexpected: $e',
        name: 'auth',
      );
      return Left(ServerFailure(e.toString()));
    }
  }
}
