import 'package:flutter/foundation.dart';
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/features/persona/domain/entities/industry.dart';
import 'package:scriptless/features/persona/domain/entities/persona_profile.dart';
import 'package:scriptless/features/persona/domain/entities/user_role.dart';

/// Status of the persona submission flow.
enum PersonaStatus {
  /// User is filling in the form steps.
  initial,

  /// Persona profile is being saved remotely.
  submitting,

  /// Persona profile was successfully saved.
  success,

  /// An error occurred during submission.
  failure,
}

/// Immutable state representing the persona selection flow.
@immutable
class PersonaState {
  /// Creates a [PersonaState].
  const PersonaState({
    this.currentStep = 0,
    this.totalSteps = 3,
    this.role,
    this.industry,
    this.confidenceLevel = 5,
    this.objectives = const [],
    this.status = PersonaStatus.initial,
    this.failure,
  });

  /// The active step index (0 = Role, 1 = Industry, 2 = Objectives).
  final int currentStep;

  /// Total number of steps in the persona selection wizard.
  final int totalSteps;

  /// Selected user management role.
  final UserRole? role;

  /// Selected industry / sector.
  final Industry? industry;

  /// Self-reported confidence score (1 to 10).
  final int confidenceLevel;

  /// Selected skill improvement objectives.
  final List<String> objectives;

  /// Current submission lifecycle status.
  final PersonaStatus status;

  /// Failure object if an error occurred during submission.
  final Failure? failure;

  /// Whether current step is the first step.
  bool get isFirstStep => currentStep == 0;

  /// Whether current step is the last step.
  bool get isLastStep => currentStep == totalSteps - 1;

  /// Whether Step 1 (Role) has a valid selection.
  bool get isStep1Valid => role != null;

  /// Whether Step 2 (Industry & Confidence) is valid.
  bool get isStep2Valid =>
      industry != null && confidenceLevel >= 1 && confidenceLevel <= 10;

  /// Whether Step 3 (Objectives) has at least one objective selected.
  bool get isStep3Valid => objectives.isNotEmpty;

  /// Whether the user can proceed from the current step.
  bool get canProceed {
    return switch (currentStep) {
      0 => isStep1Valid,
      1 => isStep2Valid,
      2 => isStep3Valid,
      _ => false,
    };
  }

  /// Whether all steps are valid to submit the full profile.
  bool get isProfileComplete => isStep1Valid && isStep2Valid && isStep3Valid;

  /// Dynamic step title displayed below the progress indicator.
  String get stepTitle {
    return switch (currentStep) {
      0 => 'Qui êtes-vous ?',
      1 => 'Votre univers',
      2 => 'Vos objectifs',
      _ => '',
    };
  }

  /// Helper to convert current selections into a [PersonaProfile] entity.
  PersonaProfile? toProfile(String userId) {
    if (role == null || industry == null) return null;
    return PersonaProfile(
      userId: userId,
      role: role!,
      industry: industry!,
      confidenceLevel: confidenceLevel,
      objectives: List<String>.unmodifiable(objectives),
    );
  }

  /// Creates a copy of this state with updated values.
  PersonaState copyWith({
    int? currentStep,
    int? totalSteps,
    UserRole? Function()? role,
    Industry? Function()? industry,
    int? confidenceLevel,
    List<String>? objectives,
    PersonaStatus? status,
    Failure? Function()? failure,
  }) {
    return PersonaState(
      currentStep: currentStep ?? this.currentStep,
      totalSteps: totalSteps ?? this.totalSteps,
      role: role != null ? role() : this.role,
      industry: industry != null ? industry() : this.industry,
      confidenceLevel: confidenceLevel ?? this.confidenceLevel,
      objectives: objectives ?? this.objectives,
      status: status ?? this.status,
      failure: failure != null ? failure() : this.failure,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PersonaState &&
          runtimeType == other.runtimeType &&
          currentStep == other.currentStep &&
          totalSteps == other.totalSteps &&
          role == other.role &&
          industry == other.industry &&
          confidenceLevel == other.confidenceLevel &&
          listEquals(objectives, other.objectives) &&
          status == other.status &&
          failure == other.failure;

  @override
  int get hashCode =>
      currentStep.hashCode ^
      totalSteps.hashCode ^
      role.hashCode ^
      industry.hashCode ^
      confidenceLevel.hashCode ^
      Object.hashAll(objectives) ^
      status.hashCode ^
      failure.hashCode;
}
