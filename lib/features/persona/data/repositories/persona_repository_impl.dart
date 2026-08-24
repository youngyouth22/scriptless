import 'package:dartz/dartz.dart';
import 'package:scriptless/core/error/exceptions.dart';
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/features/persona/data/datasources/persona_remote_datasource.dart';
import 'package:scriptless/features/persona/data/models/persona_profile_model.dart';
import 'package:scriptless/features/persona/domain/entities/persona_profile.dart';
import 'package:scriptless/features/persona/domain/repositories/persona_repository.dart';

/// Implementation of [PersonaRepository] interacting with remote data sources.
class PersonaRepositoryImpl implements PersonaRepository {
  /// Creates a [PersonaRepositoryImpl].
  const PersonaRepositoryImpl(this._remoteDataSource);

  final PersonaRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, Unit>> savePersonaProfile(
    PersonaProfile profile,
  ) async {
    try {
      final model = PersonaProfileModel.fromEntity(profile);
      await _remoteDataSource.updatePersonaProfile(model);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PersonaProfile?>> getPersonaProfile(
    String userId,
  ) async {
    try {
      final profileModel = await _remoteDataSource.getPersonaProfile(userId);
      return Right(profileModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
