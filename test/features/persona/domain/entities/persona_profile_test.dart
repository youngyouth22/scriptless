import 'package:flutter_test/flutter_test.dart';
import 'package:scriptless/features/persona/domain/entities/industry.dart';
import 'package:scriptless/features/persona/domain/entities/persona_profile.dart';
import 'package:scriptless/features/persona/domain/entities/user_role.dart';

void main() {
  group('PersonaProfile', () {
    const tProfile = PersonaProfile(
      userId: 'user-123',
      role: UserRole.firstTimeManager,
      industry: Industry.tech,
      confidenceLevel: 6,
      objectives: ['Donner un feedback difficile'],
    );

    test('supports value equality', () {
      const profile2 = PersonaProfile(
        userId: 'user-123',
        role: UserRole.firstTimeManager,
        industry: Industry.tech,
        confidenceLevel: 6,
        objectives: ['Donner un feedback difficile'],
      );

      expect(tProfile, equals(profile2));
      expect(tProfile.hashCode, equals(profile2.hashCode));
    });

    test('copyWith creates modified copy', () {
      final updated = tProfile.copyWith(
        confidenceLevel: 8,
        industry: Industry.finance,
      );

      expect(updated.userId, 'user-123');
      expect(updated.role, UserRole.firstTimeManager);
      expect(updated.industry, Industry.finance);
      expect(updated.confidenceLevel, 8);
      expect(updated.objectives, ['Donner un feedback difficile']);
    });

    test('toString returns formatted representation', () {
      expect(tProfile.toString(), contains('user-123'));
      expect(tProfile.toString(), contains('firstTimeManager'));
    });
  });
}
