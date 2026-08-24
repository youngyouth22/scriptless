import 'package:dartz/dartz.dart';
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/features/persona/domain/entities/persona_profile.dart';

/// Contract interface for persona data management in the domain layer.
abstract class PersonaRepository {
  /// Saves or updates the persona profile for a user.
  Future<Either<Failure, Unit>> savePersonaProfile(PersonaProfile profile);

  /// Retrieves the persona profile for a given [userId].
  Future<Either<Failure, PersonaProfile?>> getPersonaProfile(String userId);
}
