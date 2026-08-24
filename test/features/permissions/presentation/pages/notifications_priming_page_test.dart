import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scriptless/di/injection_container.dart';
import 'package:scriptless/features/permissions/presentation/cubit/notifications_priming_cubit.dart';
import 'package:scriptless/features/permissions/presentation/cubit/notifications_priming_state.dart';
import 'package:scriptless/features/permissions/presentation/pages/notifications_priming_page.dart';

class MockNotificationsPrimingCubit extends Mock
    implements NotificationsPrimingCubit {}

void main() {
  late MockNotificationsPrimingCubit mockCubit;

  setUp(() async {
    mockCubit = MockNotificationsPrimingCubit();
    when(() => mockCubit.state).thenReturn(
      const NotificationsPrimingInitial(),
    );
    when(() => mockCubit.stream).thenAnswer(
      (_) => const Stream<NotificationsPrimingState>.empty(),
    );
    when(() => mockCubit.checkStatus()).thenAnswer((_) async {});
    when(() => mockCubit.requestNotificationPermission())
        .thenAnswer((_) async {});
    when(() => mockCubit.skip()).thenAnswer((_) {});
    when(() => mockCubit.openSettings()).thenAnswer((_) async {});
    when(() => mockCubit.close()).thenAnswer((_) async {});

    if (sl.isRegistered<NotificationsPrimingCubit>()) {
      await sl.unregister<NotificationsPrimingCubit>();
    }
    sl.registerFactory<NotificationsPrimingCubit>(() => mockCubit);
  });

  tearDown(() async {
    if (sl.isRegistered<NotificationsPrimingCubit>()) {
      await sl.unregister<NotificationsPrimingCubit>();
    }
  });

  Widget buildTestWidget() {
    return const MaterialApp(
      home: NotificationsPrimingPage(),
    );
  }

  group('NotificationsPrimingPage', () {
    testWidgets('renders title, description and action buttons',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Stay On Track'), findsOneWidget);
      expect(find.text('Enable Notifications'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Maybe later'), findsOneWidget);
      verify(() => mockCubit.checkStatus()).called(1);
    });

    testWidgets(
      'tapping Enable Notifications calls requestNotificationPermission',
      (tester) async {
        await tester.pumpWidget(buildTestWidget());

        await tester
            .tap(find.byKey(const Key('notifications_priming_allow_button')));
        await tester.pump();

        verify(() => mockCubit.requestNotificationPermission()).called(1);
      },
    );

    testWidgets('tapping Skip calls cubit.skip()', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester
          .tap(find.byKey(const Key('notifications_priming_skip_button')));
      await tester.pump();

      verify(() => mockCubit.skip()).called(1);
    });

    testWidgets('renders Open Settings button when permanently denied',
        (tester) async {
      when(() => mockCubit.state).thenReturn(
        const NotificationsPrimingPermanentlyDenied(),
      );

      await tester.pumpWidget(buildTestWidget());

      final settingsButtonFinder =
          find.byKey(const Key('notifications_priming_settings_button'));

      expect(settingsButtonFinder, findsOneWidget);

      await tester.ensureVisible(settingsButtonFinder);
      await tester.tap(settingsButtonFinder);
      await tester.pump();

      verify(() => mockCubit.openSettings()).called(1);
    });
  });
}
