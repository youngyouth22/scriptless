import 'package:flutter_test/flutter_test.dart';
import 'package:scriptless/features/persona/data/models/persona_profile_model.dart';
import 'package:scriptless/features/persona/domain/entities/industry.dart';
import 'package:scriptless/features/persona/domain/entities/persona_profile.dart';
import 'package:scriptless/features/persona/domain/entities/user_role.dart';

void main() {
  const tModel = PersonaProfileModel(
    userId: 'user-123',
    role: UserRole.director,
    industry: Industry.finance,
    confidenceLevel: 9,
    objectives: ['Négocier mon salaire', 'Annoncer un changement'],
  );

  group('PersonaProfileModel', () {
    test('is a subclass of PersonaProfile entity', () {
      expect(tModel, isA<PersonaProfile>());
    });

    test('fromEntity creates valid model', () {
      const entity = PersonaProfile(
        userId: 'user-123',
        role: UserRole.director,
        industry: Industry.finance,
        confidenceLevel: 9,
        objectives: ['Négocier mon salaire', 'Annoncer un changement'],
      );

      final result = PersonaProfileModel.fromEntity(entity);

      expect(result, equals(tModel));
    });

    test('fromJson parses standard DB json map correctly', () {
      final json = {
        'id': 'user-123',
        'role': 'director',
        'industry': 'finance',
        'confidence_level': 9,
        'objectives': ['Négocier mon salaire', 'Annoncer un changement'],
      };

      final result = PersonaProfileModel.fromJson(json);

      expect(result.userId, 'user-123');
      expect(result.role, UserRole.director);
      expect(result.industry, Industry.finance);
      expect(result.confidenceLevel, 9);
      expect(result.objectives, [
        'Négocier mon salaire',
        'Annoncer un changement',
      ]);
    });

    test('fromJson uses default fallback values for nulls', () {
      final json = <String, dynamic>{
        'user_id': 'user-456',
      };

      final result = PersonaProfileModel.fromJson(json);

      expect(result.userId, 'user-456');
      expect(result.role, UserRole.firstTimeManager);
      expect(result.industry, Industry.tech);
      expect(result.confidenceLevel, 5);
      expect(result.objectives, isEmpty);
    });

    test('toSupabaseMap produces correct payload with updated_at', () {
      final map = tModel.toSupabaseMap();

      expect(map['role'], 'director');
      expect(map['industry'], 'finance');
      expect(map['confidence_level'], 9);
      expect(map['objectives'], [
        'Négocier mon salaire',
        'Annoncer un changement',
      ]);
      expect(map.containsKey('updated_at'), isTrue);
    });

    test('toJson produces valid JSON map', () {
      final json = tModel.toJson();

      expect(json['id'], 'user-123');
      expect(json['role'], 'director');
      expect(json['industry'], 'finance');
      expect(json['confidence_level'], 9);
      expect(json['objectives'], [
        'Négocier mon salaire',
        'Annoncer un changement',
      ]);
    });
  });
}
