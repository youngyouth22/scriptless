// Abstract contract is required for Clean Architecture
// and dependency inversion.
// ignore_for_file: one_member_abstracts
import 'package:scriptless/core/error/exceptions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Contract for the remote onboarding datasource.
abstract class OnboardingRemoteDataSource {
  /// Updates the onboarding completed flag in the remote database.
  Future<void> completeOnboarding(String userId);
}

/// Supabase implementation of [OnboardingRemoteDataSource].
class OnboardingRemoteDataSourceImpl implements OnboardingRemoteDataSource {
  /// Creates an [OnboardingRemoteDataSourceImpl].
  const OnboardingRemoteDataSourceImpl(this._supabaseClient);

  final SupabaseClient _supabaseClient;

  @override
  Future<void> completeOnboarding(String userId) async {
    try {
      await _supabaseClient
          .from('profiles')
          .update({
            'onboarding_completed': 1,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } on Exception catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
