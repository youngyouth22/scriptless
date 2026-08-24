import 'package:flutter/foundation.dart';
import 'package:scriptless/features/persona/domain/entities/industry.dart';
import 'package:scriptless/features/persona/domain/entities/user_role.dart';

/// Immutable domain entity representing a user's persona profile data.
@immutable
class PersonaProfile {
  /// Creates a [PersonaProfile].
  const PersonaProfile({
    required this.userId,
    required this.role,
    required this.industry,
    required this.confidenceLevel,
    required this.objectives,
  });

  /// User unique identifier (matches auth.users id).
  final String userId;

  /// Management role of the user.
  final UserRole role;

  /// Industry/sector of the user.
  final Industry industry;

  /// Self-reported confidence score (1 to 10).
  final int confidenceLevel;

  /// Selected objectives for skill improvement.
  final List<String> objectives;

  /// Creates a copy of this [PersonaProfile] with updated fields.
  PersonaProfile copyWith({
    String? userId,
    UserRole? role,
    Industry? industry,
    int? confidenceLevel,
    List<String>? objectives,
  }) {
    return PersonaProfile(
      userId: userId ?? this.userId,
      role: role ?? this.role,
      industry: industry ?? this.industry,
      confidenceLevel: confidenceLevel ?? this.confidenceLevel,
      objectives: objectives ?? this.objectives,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PersonaProfile &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          role == other.role &&
          industry == other.industry &&
          confidenceLevel == other.confidenceLevel &&
          listEquals(objectives, other.objectives);

  @override
  int get hashCode =>
      userId.hashCode ^
      role.hashCode ^
      industry.hashCode ^
      confidenceLevel.hashCode ^
      Object.hashAll(objectives);

  @override
  String toString() {
    return 'PersonaProfile('
        'userId: $userId, '
        'role: $role, '
        'industry: $industry, '
        'confidenceLevel: $confidenceLevel, '
        'objectives: $objectives)';
  }
}
