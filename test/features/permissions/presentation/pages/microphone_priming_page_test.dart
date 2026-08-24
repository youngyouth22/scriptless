import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scriptless/di/injection_container.dart';
import 'package:scriptless/features/permissions/presentation/cubit/microphone_priming_cubit.dart';
import 'package:scriptless/features/permissions/presentation/cubit/microphone_priming_state.dart';
import 'package:scriptless/features/permissions/presentation/pages/microphone_priming_page.dart';

class MockMicrophonePrimingCubit extends Mock
    implements MicrophonePrimingCubit {}

void main() {
  late MockMicrophonePrimingCubit mockCubit;

  setUp(() async {
    mockCubit = MockMicrophonePrimingCubit();
    when(() => mockCubit.state).thenReturn(
      const MicrophonePrimingInitial(),
    );
    when(() => mockCubit.stream).thenAnswer(
      (_) => const Stream<MicrophonePrimingState>.empty(),
    );
    when(() => mockCubit.checkStatus()).thenAnswer((_) async {});
    when(() => mockCubit.requestMicrophonePermission())
        .thenAnswer((_) async {});
    when(() => mockCubit.skip()).thenAnswer((_) {});
    when(() => mockCubit.openSettings()).thenAnswer((_) async {});
    when(() => mockCubit.close()).thenAnswer((_) async {});

    if (sl.isRegistered<MicrophonePrimingCubit>()) {
      await sl.unregister<MicrophonePrimingCubit>();
    }
    sl.registerFactory<MicrophonePrimingCubit>(() => mockCubit);
  });

  tearDown(() async {
    if (sl.isRegistered<MicrophonePrimingCubit>()) {
      await sl.unregister<MicrophonePrimingCubit>();
    }
  });

  Widget buildTestWidget() {
    return const MaterialApp(
      home: MicrophonePrimingPage(),
    );
  }

  group('MicrophonePrimingPage', () {
    testWidgets('renders title, description and action buttons',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Enable Microphone Access'), findsOneWidget);
      expect(find.text('Enable Microphone'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Maybe later'), findsOneWidget);
      verify(() => mockCubit.checkStatus()).called(1);
    });

    testWidgets('tapping Enable Microphone calls requestMicrophonePermission',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester
          .tap(find.byKey(const Key('microphone_priming_allow_button')));
      await tester.pump();

      verify(() => mockCubit.requestMicrophonePermission()).called(1);
    });

    testWidgets('tapping Skip calls cubit.skip()', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.byKey(const Key('microphone_priming_skip_button')));
      await tester.pump();

      verify(() => mockCubit.skip()).called(1);
    });

    testWidgets('renders Open Settings button when permanently denied',
        (tester) async {
      when(() => mockCubit.state).thenReturn(
        const MicrophonePrimingPermanentlyDenied(),
      );

      await tester.pumpWidget(buildTestWidget());

      final settingsButtonFinder =
          find.byKey(const Key('microphone_priming_settings_button'));

      expect(settingsButtonFinder, findsOneWidget);

      await tester.ensureVisible(settingsButtonFinder);
      await tester.tap(settingsButtonFinder);
      await tester.pump();

      verify(() => mockCubit.openSettings()).called(1);
    });
  });
}
