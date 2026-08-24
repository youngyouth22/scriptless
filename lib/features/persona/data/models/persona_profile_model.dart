import 'package:scriptless/features/persona/domain/entities/industry.dart';
import 'package:scriptless/features/persona/domain/entities/persona_profile.dart';
import 'package:scriptless/features/persona/domain/entities/user_role.dart';

/// Data model representing persona profile data with serialization methods.
class PersonaProfileModel extends PersonaProfile {
  /// Creates a [PersonaProfileModel].
  const PersonaProfileModel({
    required super.userId,
    required super.role,
    required super.industry,
    required super.confidenceLevel,
    required super.objectives,
  });

  /// Factory constructor to create a [PersonaProfileModel] from a
  /// [PersonaProfile] entity.
  factory PersonaProfileModel.fromEntity(PersonaProfile entity) {
    return PersonaProfileModel(
      userId: entity.userId,
      role: entity.role,
      industry: entity.industry,
      confidenceLevel: entity.confidenceLevel,
      objectives: List<String>.from(entity.objectives),
    );
  }

  /// Factory constructor to parse a database row/JSON map into a
  /// [PersonaProfileModel].
  factory PersonaProfileModel.fromJson(Map<String, dynamic> json) {
    final rawUserId = (json['id'] ?? json['user_id'] ?? '').toString();
    final roleStr = json['role'] as String?;
    final industryStr = json['industry'] as String?;
    final confidenceLevel = (json['confidence_level'] as num?)?.toInt() ?? 5;

    final rawObjectives = json['objectives'];
    final objectives = <String>[];
    if (rawObjectives is List) {
      for (final item in rawObjectives) {
        if (item != null) {
          objectives.add(item.toString());
        }
      }
    }

    final parsedRole =
        UserRole.fromDbValue(roleStr) ?? UserRole.firstTimeManager;
    final parsedIndustry =
        Industry.fromDbValue(industryStr) ?? Industry.tech;

    return PersonaProfileModel(
      userId: rawUserId,
      role: parsedRole,
      industry: parsedIndustry,
      confidenceLevel: confidenceLevel,
      objectives: objectives,
    );
  }

  /// Converts this model to a map suitable for updating the Supabase
  /// `profiles` table.
  Map<String, dynamic> toSupabaseMap() {
    return {
      'role': role.dbValue,
      'industry': industry.dbValue,
      'confidence_level': confidenceLevel,
      'objectives': objectives,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  /// Converts this model to a general JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': userId,
      'role': role.dbValue,
      'industry': industry.dbValue,
      'confidence_level': confidenceLevel,
      'objectives': objectives,
    };
  }
}
