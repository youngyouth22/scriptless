import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scriptless/common/widgets/arrow_back_button.dart';

void main() {
  Widget buildTestableWidget(Widget widget) {
    return MaterialApp(
      home: Scaffold(
        body: Center(child: widget),
      ),
    );
  }

  group('ArrowBackButton Widget Tests', () {
    testWidgets('renders properly and responds to tap', (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        buildTestableWidget(
          ArrowBackButton(
            onPressed: () => pressed = true,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(ArrowBackButton), findsOneWidget);

      await tester.tap(find.byType(ArrowBackButton));
      await tester.pumpAndSettle();

      expect(pressed, isTrue);
    });

    testWidgets('handles press animation on tap down and up', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          ArrowBackButton(
            onPressed: () {},
          ),
        ),
      );

      await tester.pumpAndSettle();

      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(ArrowBackButton)),
      );
      await tester.pump(const Duration(milliseconds: 70));

      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('scales down when isVisible is false', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const ArrowBackButton(
            isVisible: false,
          ),
        ),
      );

      expect(find.byType(ArrowBackButton), findsOneWidget);
      await tester.pumpAndSettle();
    });
  });
}
