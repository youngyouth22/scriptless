import 'package:flutter_test/flutter_test.dart';
import 'package:scriptless/features/persona/domain/entities/user_role.dart';

void main() {
  group('UserRole', () {
    test('fromDbValue returns correct UserRole for valid values', () {
      expect(
        UserRole.fromDbValue('first_time_manager'),
        UserRole.firstTimeManager,
      );
      expect(
        UserRole.fromDbValue('team_manager'),
        UserRole.teamManager,
      );
      expect(
        UserRole.fromDbValue('cross_functional_manager'),
        UserRole.crossFunctionalManager,
      );
      expect(
        UserRole.fromDbValue('director'),
        UserRole.director,
      );
    });

    test('fromDbValue returns null for invalid or null value', () {
      expect(UserRole.fromDbValue(null), isNull);
      expect(UserRole.fromDbValue('unknown_role'), isNull);
    });

    test('labels are properly populated', () {
      expect(UserRole.firstTimeManager.label, 'Premier manager');
      expect(UserRole.teamManager.label, "Manager d'équipe");
      expect(UserRole.crossFunctionalManager.label, 'Manager transverse');
      expect(UserRole.director.label, 'Directeur / VP');
    });
  });
}
