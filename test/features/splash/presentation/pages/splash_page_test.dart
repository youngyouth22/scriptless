import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scriptless/di/injection_container.dart';
import 'package:scriptless/features/splash/presentation/cubit/splash_cubit.dart';
import 'package:scriptless/features/splash/presentation/cubit/splash_state.dart';
import 'package:scriptless/features/splash/presentation/pages/splash_page.dart';

class MockSplashCubit extends Mock implements SplashCubit {}

void main() {
  late MockSplashCubit mockSplashCubit;

  setUp(() async {
    mockSplashCubit = MockSplashCubit();
    when(() => mockSplashCubit.state).thenReturn(const SplashInitial());
    when(
      () => mockSplashCubit.stream,
    ).thenAnswer((_) => const Stream<SplashState>.empty());
    when(() => mockSplashCubit.init()).thenAnswer((_) async {});
    when(() => mockSplashCubit.close()).thenAnswer((_) async {});

    if (sl.isRegistered<SplashCubit>()) {
      await sl.unregister<SplashCubit>();
    }
    sl.registerFactory<SplashCubit>(() => mockSplashCubit);
  });

  tearDown(() async {
    if (sl.isRegistered<SplashCubit>()) {
      await sl.unregister<SplashCubit>();
    }
  });

  Widget buildTestWidget() {
    return const MaterialApp(
      home: SplashPage(),
    );
  }

  group('SplashPage', () {
    testWidgets('renders CircularProgressIndicator and calls cubit.init()', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      verify(() => mockSplashCubit.init()).called(1);
    });
  });
}
