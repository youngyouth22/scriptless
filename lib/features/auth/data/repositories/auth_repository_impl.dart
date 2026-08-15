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
}
