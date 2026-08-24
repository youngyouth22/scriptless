import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:scriptless/features/auth/presentation/pages/auth_email_login_page.dart';
import 'package:scriptless/features/auth/presentation/pages/auth_register_page.dart';
import 'package:scriptless/features/auth/presentation/pages/login_page.dart';
import 'package:scriptless/features/auth/presentation/widgets/auth_button.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;

  setUp(() async {
    mockAuthBloc = MockAuthBloc();
    final sl = GetIt.instance;
    if (sl.isRegistered<AuthBloc>()) {
      await sl.unregister<AuthBloc>();
    }
    sl.registerFactory<AuthBloc>(() => mockAuthBloc);
  });

  tearDown(() async {
    final sl = GetIt.instance;
    if (sl.isRegistered<AuthBloc>()) {
      await sl.unregister<AuthBloc>();
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

  group('LoginPage Widget Tests', () {
    testWidgets('renders all OAuth buttons and email signup', (tester) async {
      setTestViewport(tester);
      whenListen(
        mockAuthBloc,
        const Stream<AuthState>.empty(),
        initialState: const AuthInitial(),
      );

      await tester.pumpWidget(createWidgetUnderTest(const LoginPage()));
      await tester.pump();

      expect(find.text('Sign up with email'), findsOneWidget);
      expect(find.text('Sign up with Google'), findsOneWidget);
      expect(find.text('Sign up with X'), findsOneWidget);
      expect(find.text('Sign up with LinkedIn'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) => w is RichText && w.text.toPlainText().contains('Log in'),
        ),
        findsOneWidget,
      );
    });

    testWidgets(
      'only Google AuthButton shows loading when Google sign-in is active',
      (tester) async {
        setTestViewport(tester);
        whenListen(
          mockAuthBloc,
          const Stream<AuthState>.empty(),
          initialState: const AuthLoading(provider: AuthProviderType.google),
        );

        await tester.pumpWidget(createWidgetUnderTest(const LoginPage()));
        await tester.pump();

        // Google button should show 'Please wait...'
        expect(find.text('Please wait...'), findsOneWidget);
        // Other buttons should still display their regular text
        expect(find.text('Sign up with email'), findsOneWidget);
        expect(find.text('Sign up with X'), findsOneWidget);
        expect(find.text('Sign up with LinkedIn'), findsOneWidget);
        // Google button text should not be present
        expect(find.text('Sign up with Google'), findsNothing);
      },
    );

    testWidgets(
      'only X AuthButton shows loading when Twitter sign-in is active',
      (tester) async {
        setTestViewport(tester);
        whenListen(
          mockAuthBloc,
          const Stream<AuthState>.empty(),
          initialState: const AuthLoading(provider: AuthProviderType.twitter),
        );

        await tester.pumpWidget(createWidgetUnderTest(const LoginPage()));
        await tester.pump();

        expect(find.text('Please wait...'), findsOneWidget);
        expect(find.text('Sign up with email'), findsOneWidget);
        expect(find.text('Sign up with Google'), findsOneWidget);
        expect(find.text('Sign up with LinkedIn'), findsOneWidget);
        expect(find.text('Sign up with X'), findsNothing);
      },
    );

    testWidgets(
      'only LinkedIn AuthButton shows loading when LinkedIn sign-in is active',
      (tester) async {
        setTestViewport(tester);
        whenListen(
          mockAuthBloc,
          const Stream<AuthState>.empty(),
          initialState: const AuthLoading(provider: AuthProviderType.linkedIn),
        );

        await tester.pumpWidget(createWidgetUnderTest(const LoginPage()));
        await tester.pump();

        expect(find.text('Please wait...'), findsOneWidget);
        expect(find.text('Sign up with email'), findsOneWidget);
        expect(find.text('Sign up with Google'), findsOneWidget);
        expect(find.text('Sign up with X'), findsOneWidget);
        expect(find.text('Sign up with LinkedIn'), findsNothing);
      },
    );

    testWidgets('tapping Google button dispatches AuthGoogleSignInRequested', (
      tester,
    ) async {
      setTestViewport(tester);
      whenListen(
        mockAuthBloc,
        const Stream<AuthState>.empty(),
        initialState: const AuthInitial(),
      );

      await tester.pumpWidget(createWidgetUnderTest(const LoginPage()));
      await tester.pump();

      final googleBtn = find.widgetWithText(AuthButton, 'Sign up with Google');
      await tester.ensureVisible(googleBtn);
      await tester.tap(googleBtn);
      await tester.pump();

      verify(
        () => mockAuthBloc.add(const AuthGoogleSignInRequested()),
      ).called(1);
    });

    testWidgets('shows SnackBar on AuthFailureState', (tester) async {
      setTestViewport(tester);
      whenListen(
        mockAuthBloc,
        Stream.fromIterable([
          const AuthFailureState(
            AuthFailure('Google authentication cancelled'),
          ),
        ]),
        initialState: const AuthInitial(),
      );

      await tester.pumpWidget(createWidgetUnderTest(const LoginPage()));
      await tester.pump();

      expect(find.text('Google authentication cancelled'), findsOneWidget);
    });

    testWidgets(
      'dispatches AuthResetRequested when app resumes during OAuth in progress',
      (tester) async {
        setTestViewport(tester);
        whenListen(
          mockAuthBloc,
          const Stream<AuthState>.empty(),
          initialState: const AuthOAuthInProgress(),
        );

        await tester.pumpWidget(createWidgetUnderTest(const LoginPage()));
        await tester.pump();

        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        await tester.pump();

        verify(() => mockAuthBloc.add(const AuthResetRequested())).called(1);
      },
    );
  });

  group('AuthRegisterPage Widget Tests', () {
    testWidgets('shows validation errors when fields are empty', (
      tester,
    ) async {
      setTestViewport(tester);
      whenListen(
        mockAuthBloc,
        const Stream<AuthState>.empty(),
        initialState: const AuthInitial(),
      );

      await tester.pumpWidget(createWidgetUnderTest(const AuthRegisterPage()));
      await tester.pump();

      final signUpBtn = find.text('Sign Up');
      await tester.ensureVisible(signUpBtn);
      await tester.tap(signUpBtn);
      await tester.pump();

      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
      expect(find.text('Please confirm your password'), findsOneWidget);
    });

    testWidgets('shows validation error for invalid email and short password', (
      tester,
    ) async {
      setTestViewport(tester);
      whenListen(
        mockAuthBloc,
        const Stream<AuthState>.empty(),
        initialState: const AuthInitial(),
      );

      await tester.pumpWidget(createWidgetUnderTest(const AuthRegisterPage()));
      await tester.pump();

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'invalid-email');
      await tester.enterText(textFields.at(1), '123');
      await tester.enterText(textFields.at(2), '123456');

      final signUpBtn = find.text('Sign Up');
      await tester.ensureVisible(signUpBtn);
      await tester.tap(signUpBtn);
      await tester.pump();

      expect(find.text('Please enter a valid email address'), findsOneWidget);
      expect(
        find.text('Password must be at least 6 characters'),
        findsOneWidget,
      );
      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets(
      'dispatches AuthSignUpRequested when form is filled and submitted',
      (tester) async {
        setTestViewport(tester);
        whenListen(
          mockAuthBloc,
          const Stream<AuthState>.empty(),
          initialState: const AuthInitial(),
        );

        await tester.pumpWidget(
          createWidgetUnderTest(const AuthRegisterPage()),
        );
        await tester.pump();

        final textFields = find.byType(TextFormField);
        await tester.enterText(textFields.at(0), 'test@scriptless.ai');
        await tester.enterText(textFields.at(1), 'password123');
        await tester.enterText(textFields.at(2), 'password123');

        final signUpBtn = find.text('Sign Up');
        await tester.ensureVisible(signUpBtn);
        await tester.tap(signUpBtn);
        await tester.pump();

        verify(
          () => mockAuthBloc.add(
            const AuthSignUpRequested(
              email: 'test@scriptless.ai',
              password: 'password123',
            ),
          ),
        ).called(1);
      },
    );
  });

  group('AuthEmailLoginPage Widget Tests', () {
    testWidgets('shows validation errors when fields are empty', (
      tester,
    ) async {
      setTestViewport(tester);
      whenListen(
        mockAuthBloc,
        const Stream<AuthState>.empty(),
        initialState: const AuthInitial(),
      );

      await tester.pumpWidget(
        createWidgetUnderTest(const AuthEmailLoginPage()),
      );
      await tester.pump();

      final logInBtn = find.text('Log In');
      await tester.ensureVisible(logInBtn);
      await tester.tap(logInBtn);
      await tester.pump();

      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets(
      'dispatches AuthSignInRequested when form is filled and submitted',
      (tester) async {
        setTestViewport(tester);
        whenListen(
          mockAuthBloc,
          const Stream<AuthState>.empty(),
          initialState: const AuthInitial(),
        );

        await tester.pumpWidget(
          createWidgetUnderTest(const AuthEmailLoginPage()),
        );
        await tester.pump();

        final textFields = find.byType(TextFormField);
        await tester.enterText(textFields.at(0), 'test@scriptless.ai');
        await tester.enterText(textFields.at(1), 'password123');

        final logInBtn = find.text('Log In');
        await tester.ensureVisible(logInBtn);
        await tester.tap(logInBtn);
        await tester.pump();

        verify(
          () => mockAuthBloc.add(
            const AuthSignInRequested(
              email: 'test@scriptless.ai',
              password: 'password123',
            ),
          ),
        ).called(1);
      },
    );
  });
}
