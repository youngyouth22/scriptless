import 'package:flutter_test/flutter_test.dart';
import 'package:scriptless/features/persona/domain/entities/industry.dart';

void main() {
  group('Industry', () {
    test('fromDbValue returns correct Industry for valid strings', () {
      expect(Industry.fromDbValue('tech'), Industry.tech);
      expect(Industry.fromDbValue('retail'), Industry.retail);
      expect(Industry.fromDbValue('finance'), Industry.finance);
      expect(Industry.fromDbValue('healthcare'), Industry.healthcare);
      expect(Industry.fromDbValue('consulting'), Industry.consulting);
      expect(Industry.fromDbValue('education'), Industry.education);
      expect(Industry.fromDbValue('manufacturing'), Industry.manufacturing);
      expect(Industry.fromDbValue('other'), Industry.other);
    });

    test('fromDbValue returns null for invalid or null value', () {
      expect(Industry.fromDbValue(null), isNull);
      expect(Industry.fromDbValue('space_travel'), isNull);
    });

    test('labels are properly populated', () {
      expect(Industry.tech.label, 'Tech');
      expect(Industry.retail.label, 'Retail');
      expect(Industry.finance.label, 'Finance');
      expect(Industry.healthcare.label, 'Healthcare');
      expect(Industry.consulting.label, 'Consulting');
      expect(Industry.education.label, 'Education');
      expect(Industry.manufacturing.label, 'Manufacturing');
      expect(Industry.other.label, 'Other');
    });
  });
}
