import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scriptless/common/resources/app_colors.dart';
import 'package:scriptless/common/widgets/custom_circular_loading_indicator.dart';
import 'package:scriptless/common/widgets/primary_button.dart';

void main() {
  Widget buildTestableWidget(Widget widget) {
    return MaterialApp(
      home: Scaffold(
        body: Center(child: widget),
      ),
    );
  }

  group('PrimaryButton Widget Tests', () {
    testWidgets('renders text correctly with default colors', (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        buildTestableWidget(
          PrimaryButton(
            text: 'Submit',
            onPressed: () => pressed = true,
          ),
        ),
      );

      expect(find.text('Submit'), findsOneWidget);

      await tester.tap(find.text('Submit'));
      await tester.pump();

      expect(pressed, isTrue);
    });

    testWidgets('renders loading state when isLoading is true', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          PrimaryButton(
            text: 'Submit',
            isLoading: true,
            onPressed: () {},
          ),
        ),
      );

      expect(find.byType(CustomCircularLoadingIndicator), findsOneWidget);
    });

    testWidgets('renders custom textColor and backgroundColor', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          PrimaryButton(
            text: 'Custom',
            backgroundColor: AppColors.white,
            textColor: AppColors.purpleHard,
            onPressed: () {},
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('Custom'));
      expect(textWidget.style?.color, equals(AppColors.purpleHard));
    });

    testWidgets('renders icon when provided', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          PrimaryButton(
            text: 'With Icon',
            icon: const Icon(Icons.arrow_forward),
            onPressed: () {},
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
      expect(find.text('With Icon'), findsOneWidget);
    });

    testWidgets('renders disabled state without failing or disappearing',
        (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const PrimaryButton(
            text: 'Disabled',
          ),
        ),
      );

      expect(find.text('Disabled'), findsOneWidget);
      final textWidget = tester.widget<Text>(find.text('Disabled'));
      expect(textWidget.style?.color, isNotNull);
    });
  });
}
