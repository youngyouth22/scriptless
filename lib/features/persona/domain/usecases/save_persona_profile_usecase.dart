import 'package:dartz/dartz.dart';
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/core/usecase/usecase.dart';
import 'package:scriptless/features/persona/domain/entities/persona_profile.dart';
import 'package:scriptless/features/persona/domain/repositories/persona_repository.dart';

/// Use case for persisting a user's selected persona profile.
class SavePersonaProfileUseCase implements UseCase<Unit, PersonaProfile> {
  /// Creates a [SavePersonaProfileUseCase].
  const SavePersonaProfileUseCase(this._repository);

  final PersonaRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(PersonaProfile params) =>
      _repository.savePersonaProfile(params);
}
