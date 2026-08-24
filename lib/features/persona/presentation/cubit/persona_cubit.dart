// Cubit constructors must call super() in the initializer list.
// ignore_for_file: prefer_initializing_formals
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/features/persona/domain/entities/industry.dart';
import 'package:scriptless/features/persona/domain/entities/user_role.dart';
import 'package:scriptless/features/persona/domain/usecases/save_persona_profile_usecase.dart';
import 'package:scriptless/features/persona/presentation/cubit/persona_state.dart';

/// Cubit managing the 3-step persona selection wizard and persistence.
class PersonaCubit extends Cubit<PersonaState> {
  /// Creates a [PersonaCubit].
  PersonaCubit({
    required SavePersonaProfileUseCase savePersonaProfile,
    int totalSteps = 3,
  })  : _savePersonaProfile = savePersonaProfile,
        super(PersonaState(totalSteps: totalSteps));

  final SavePersonaProfileUseCase _savePersonaProfile;

  /// Selects the user's role (Step 1).
  void selectRole(UserRole role) {
    log('PersonaCubit: Selected role -> ${role.name}', name: 'persona');
    emit(state.copyWith(role: () => role));
  }

  /// Selects the user's industry sector (Step 2).
  void selectIndustry(Industry industry) {
    log(
      'PersonaCubit: Selected industry -> ${industry.name}',
      name: 'persona',
    );
    emit(state.copyWith(industry: () => industry));
  }

  /// Sets the self-reported confidence score (1 to 10) (Step 2).
  void setConfidenceLevel(int level) {
    final clamped = level.clamp(1, 10);
    log(
      'PersonaCubit: Set confidence level -> $clamped',
      name: 'persona',
    );
    emit(state.copyWith(confidenceLevel: clamped));
  }

  /// Toggles selection of an objective (Step 3).
  void toggleObjective(String objective) {
    final current = List<String>.from(state.objectives);
    if (current.contains(objective)) {
      current.remove(objective);
    } else {
      current.add(objective);
    }
    log(
      'PersonaCubit: Toggled objective "$objective", '
      'total selected: ${current.length}',
      name: 'persona',
    );
    emit(state.copyWith(objectives: current));
  }

  /// Replaces the list of selected objectives (Step 3).
  void setObjectives(List<String> objectives) {
    log(
      'PersonaCubit: Set objectives count -> ${objectives.length}',
      name: 'persona',
    );
    emit(state.copyWith(objectives: List<String>.from(objectives)));
  }

  /// Advances to the next step if current step is valid.
  void nextStep() {
    if (state.canProceed && state.currentStep < state.totalSteps - 1) {
      final next = state.currentStep + 1;
      log('PersonaCubit: Next step -> $next', name: 'persona');
      emit(state.copyWith(currentStep: next));
    }
  }

  /// Navigates back to the previous step.
  void previousStep() {
    if (state.currentStep > 0) {
      final prev = state.currentStep - 1;
      log('PersonaCubit: Previous step -> $prev', name: 'persona');
      emit(state.copyWith(currentStep: prev));
    }
  }

  /// Jumps directly to a step index.
  void goToStep(int step) {
    if (step >= 0 && step < state.totalSteps) {
      log('PersonaCubit: Go to step -> $step', name: 'persona');
      emit(state.copyWith(currentStep: step));
    }
  }

  /// Persists the selected persona profile for [userId].
  Future<void> submitPersona(String userId) async {
    log('PersonaCubit: Submitting persona for user $userId', name: 'persona');

    final profile = state.toProfile(userId);
    if (profile == null || !state.isProfileComplete) {
      log(
        'PersonaCubit: Incomplete profile before submission',
        name: 'persona',
      );
      emit(
        state.copyWith(
          status: PersonaStatus.failure,
          failure: () => const ValidationFailure(
            'Veuillez compléter toutes les étapes du profil.',
          ),
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: PersonaStatus.submitting,
        failure: () => null,
      ),
    );

    final result = await _savePersonaProfile(profile);

    result.fold(
      (failure) {
        log(
          'PersonaCubit: Save persona failed — ${failure.message}',
          name: 'persona',
        );
        _safeEmit(
          state.copyWith(
            status: PersonaStatus.failure,
            failure: () => failure,
          ),
        );
      },
      (_) {
        log('PersonaCubit: Save persona succeeded', name: 'persona');
        _safeEmit(
          state.copyWith(
            status: PersonaStatus.success,
            failure: () => null,
          ),
        );
      },
    );
  }

  void _safeEmit(PersonaState state) {
    if (!isClosed) {
      emit(state);
    }
  }
}
