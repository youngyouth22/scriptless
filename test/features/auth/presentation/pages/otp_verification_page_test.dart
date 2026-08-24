import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/features/auth/presentation/bloc/otp_bloc.dart';
import 'package:scriptless/features/auth/presentation/pages/otp_verification_page.dart';

class MockOtpBloc extends MockBloc<OtpEvent, OtpState> implements OtpBloc {}

void main() {
  late MockOtpBloc mockOtpBloc;

  setUp(() async {
    mockOtpBloc = MockOtpBloc();
    final sl = GetIt.instance;
    if (sl.isRegistered<OtpBloc>()) {
      await sl.unregister<OtpBloc>();
    }
    sl.registerFactory<OtpBloc>(() => mockOtpBloc);
  });

  tearDown(() async {
    final sl = GetIt.instance;
    if (sl.isRegistered<OtpBloc>()) {
      await sl.unregister<OtpBloc>();
    }
  });

  Widget createWidgetUnderTest(Widget child) {
    return MaterialApp(
      home: child,
    );
  }

  void setTestViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  group('OtpVerificationPage Widget Tests', () {
    testWidgets('renders Step 0 (Email step) initially with Send Code button', (
      tester,
    ) async {
      setTestViewport(tester);
      whenListen(
        mockOtpBloc,
        const Stream<OtpState>.empty(),
        initialState: const OtpInitial(),
      );

      await tester.pumpWidget(
        createWidgetUnderTest(const OtpVerificationPage()),
      );
      await tester.pump();

      expect(find.text('Forgot password?'), findsOneWidget);
      expect(find.text('Send Code'), findsOneWidget);
      expect(find.text('Back to Log In'), findsOneWidget);
    });

    testWidgets(
      'renders Step 1 directly when flowType is signUpVerification',
      (tester) async {
        setTestViewport(tester);
        whenListen(
          mockOtpBloc,
          const Stream<OtpState>.empty(),
          initialState: const OtpInitial(),
        );

        await tester.pumpWidget(
          createWidgetUnderTest(
            const OtpVerificationPage(
              initialEmail: 'test@example.com',
              flowType: OtpFlowType.signUpVerification,
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Verify your account'), findsOneWidget);
        expect(find.text('Verify Code'), findsOneWidget);
        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is RichText &&
                widget.text.toPlainText().contains('test@example.com'),
          ),
          findsOneWidget,
        );
      },


    );

    testWidgets('shows validation error when email is empty and submitted', (
      tester,
    ) async {
      setTestViewport(tester);
      whenListen(
        mockOtpBloc,
        const Stream<OtpState>.empty(),
        initialState: const OtpInitial(),
      );

      await tester.pumpWidget(
        createWidgetUnderTest(const OtpVerificationPage()),
      );
      await tester.pump();

      await tester.tap(find.text('Send Code'));
      await tester.pump();

      expect(find.text('Email is required'), findsOneWidget);
    });

    testWidgets('shows SnackBar on OtpFailureState', (tester) async {
      setTestViewport(tester);
      whenListen(
        mockOtpBloc,
        Stream.fromIterable([
          const OtpFailureState(AuthFailure('Invalid code')),
        ]),
        initialState: const OtpInitial(),
      );

      await tester.pumpWidget(
        createWidgetUnderTest(const OtpVerificationPage()),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('Invalid code'), findsOneWidget);
    });
  });
}
