import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scriptless/features/dashboard/presentation/pages/dashboard_page.dart';

void main() {
  group('DashboardPage', () {
    testWidgets('renders Dashboard page with Accueil content', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DashboardPage(),
        ),
      );

      expect(find.text('Accueil'), findsOneWidget);
    });
  });
}
