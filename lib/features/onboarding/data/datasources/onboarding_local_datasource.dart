import 'package:shared_preferences/shared_preferences.dart';

/// Contract for the local onboarding datasource.
///
/// Persists whether the user has ever seen the onboarding marketing slides
/// using [SharedPreferences] so that the guard survives app restarts.
abstract class OnboardingLocalDataSource {
  /// Returns `true` if the user has already seen the onboarding flow.
  Future<bool> hasSeenOnboarding();

  /// Persists the fact that the user has seen the onboarding flow.
  Future<void> markOnboardingSeen();
}

/// [SharedPreferences] implementation of [OnboardingLocalDataSource].
class OnboardingLocalDataSourceImpl implements OnboardingLocalDataSource {
  /// Creates an [OnboardingLocalDataSourceImpl].
  const OnboardingLocalDataSourceImpl(this._prefs);

  final SharedPreferences _prefs;

  /// SharedPreferences key for the onboarding-seen flag.
  static const String _kOnboardingSeen = 'onboarding_seen';

  @override
  Future<bool> hasSeenOnboarding() async =>
      _prefs.getBool(_kOnboardingSeen) ?? false;

  @override
  Future<void> markOnboardingSeen() async =>
      _prefs.setBool(_kOnboardingSeen, true);
}
