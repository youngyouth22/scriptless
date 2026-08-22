import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scriptless/di/injection_container.dart';
import 'package:scriptless/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:scriptless/features/onboarding/presentation/cubit/onboarding_state.dart';
import 'package:scriptless/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:scriptless/features/onboarding/presentation/widgets/onboarding_slide.dart';
import 'package:scriptless/features/onboarding/presentation/widgets/page_indicator.dart';

class MockOnboardingCubit extends Mock implements OnboardingCubit {}

void main() {
  late MockOnboardingCubit mockOnboardingCubit;

  setUp(() async {
    mockOnboardingCubit = MockOnboardingCubit();
    when(() => mockOnboardingCubit.state).thenReturn(
      const OnboardingInProgress(currentIndex: 0),
    );
    when(() => mockOnboardingCubit.stream).thenAnswer(
      (_) => const Stream<OnboardingState>.empty(),
    );
    when(() => mockOnboardingCubit.skip()).thenAnswer((_) async {});
    when(() => mockOnboardingCubit.close()).thenAnswer((_) async {});

    if (sl.isRegistered<OnboardingCubit>()) {
      await sl.unregister<OnboardingCubit>();
    }
    sl.registerFactory<OnboardingCubit>(() => mockOnboardingCubit);
  });

  tearDown(() async {
    if (sl.isRegistered<OnboardingCubit>()) {
      await sl.unregister<OnboardingCubit>();
    }
  });

  Widget buildTestWidget() {
    return const MaterialApp(
      home: OnboardingPage(),
    );
  }

  group('OnboardingPage', () {
    testWidgets(
      'renders PageView, OnboardingSlide, Indicator and Skip button',
      (tester) async {
        await tester.pumpWidget(buildTestWidget());

        expect(find.byType(PageView), findsOneWidget);
        expect(find.byType(OnboardingSlide), findsOneWidget);
        expect(find.byType(OnboardingPageIndicator), findsOneWidget);
        expect(find.text('Skip'), findsOneWidget);
        expect(find.text('Next'), findsOneWidget);
      },
    );

    testWidgets('tapping Skip calls cubit.skip()', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.text('Skip'));
      await tester.pump();

      verify(() => mockOnboardingCubit.skip()).called(1);
    });
  });
}
