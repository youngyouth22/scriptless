import 'package:dartz/dartz.dart';
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/core/usecase/usecase.dart';
import 'package:scriptless/features/persona/domain/entities/persona_profile.dart';
import 'package:scriptless/features/persona/domain/repositories/persona_repository.dart';

/// Use case for fetching a user's existing persona profile.
class GetPersonaProfileUseCase implements UseCase<PersonaProfile?, String> {
  /// Creates a [GetPersonaProfileUseCase].
  const GetPersonaProfileUseCase(this._repository);

  final PersonaRepository _repository;

  @override
  Future<Either<Failure, PersonaProfile?>> call(String params) =>
      _repository.getPersonaProfile(params);
}
