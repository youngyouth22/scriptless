import 'package:scriptless/core/error/exceptions.dart';
import 'package:scriptless/features/persona/data/models/persona_profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Contract interface for remote persona data operations.
abstract class PersonaRemoteDataSource {
  /// Updates the persona attributes for the given profile in the remote
  /// database.
  Future<void> updatePersonaProfile(PersonaProfileModel model);

  /// Retrieves the persona profile for [userId] from the remote database.
  Future<PersonaProfileModel?> getPersonaProfile(String userId);
}

/// Supabase implementation of [PersonaRemoteDataSource].
class PersonaRemoteDataSourceImpl implements PersonaRemoteDataSource {
  /// Creates a [PersonaRemoteDataSourceImpl].
  const PersonaRemoteDataSourceImpl(this._supabaseClient);

  final SupabaseClient _supabaseClient;

  @override
  Future<void> updatePersonaProfile(PersonaProfileModel model) async {
    try {
      await _supabaseClient
          .from('profiles')
          .update(model.toSupabaseMap())
          .eq('id', model.userId);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } on Exception catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<PersonaProfileModel?> getPersonaProfile(String userId) async {
    try {
      final response = await _supabaseClient
          .from('profiles')
          .select('id, role, industry, confidence_level, objectives')
          .eq('id', userId)
          .maybeSingle();

      if (response == null || response['role'] == null) {
        return null;
      }

      return PersonaProfileModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } on Exception catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
