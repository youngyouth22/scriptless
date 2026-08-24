import 'package:scriptless/core/error/exceptions.dart';
import 'package:scriptless/core/powersync/powersync.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Contract for the remote splash datasource.
abstract class SplashRemoteDataSource {
  /// Queries the remote database to check if the user completed onboarding.
  Future<bool> isOnboardingCompleted(String userId);

  /// Connects/Initializes PowerSync database.
  Future<void> initializePowerSync();
}

/// Supabase implementation of [SplashRemoteDataSource].
class SplashRemoteDataSourceImpl implements SplashRemoteDataSource {
  /// Creates a [SplashRemoteDataSourceImpl].
  const SplashRemoteDataSourceImpl(
    this._supabaseClient,
    this._powerSyncService,
  );

  final SupabaseClient _supabaseClient;
  final PowerSyncService _powerSyncService;

  @override
  Future<bool> isOnboardingCompleted(String userId) async {
    try {
      final response = await _supabaseClient
          .from('profiles')
          .select('onboarding_completed')
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        return false;
      }

      final onboardingCompleted = response['onboarding_completed'];
      if (onboardingCompleted is int) {
        return onboardingCompleted == 1;
      }
      if (onboardingCompleted is bool) {
        return onboardingCompleted;
      }
      return false;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } on Exception catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> initializePowerSync() async {
    try {
      await _powerSyncService.initialize();
    } on Exception catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
