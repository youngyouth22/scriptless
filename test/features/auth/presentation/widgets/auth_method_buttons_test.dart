import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scriptless/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:scriptless/features/auth/presentation/models/auth_method.dart';
import 'package:scriptless/features/auth/presentation/widgets/auth_button.dart';
import 'package:scriptless/features/auth/presentation/widgets/auth_method_buttons.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
  });

  Widget createWidgetUnderTest(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<AuthBloc>.value(
          value: mockAuthBloc,
          child: child,
        ),
      ),
    );
  }

  group('AuthMethodButtons Widget Tests', () {
    testWidgets('renders all default auth buttons with sign up labels', (
      tester,
    ) async {
      whenListen(
        mockAuthBloc,
        const Stream<AuthState>.empty(),
        initialState: const AuthInitial(),
      );

      await tester.pumpWidget(
        createWidgetUnderTest(
          const AuthMethodButtons(),
        ),
      );

      expect(find.text('Sign up with email'), findsOneWidget);
      expect(find.text('Sign up with Google'), findsOneWidget);
      expect(find.text('Sign up with X'), findsOneWidget);
      expect(find.text('Sign up with LinkedIn'), findsOneWidget);
      expect(find.byType(AuthButton), findsNWidgets(4));
    });

    testWidgets('renders custom subset of methods with log in labels', (
      tester,
    ) async {
      whenListen(
        mockAuthBloc,
        const Stream<AuthState>.empty(),
        initialState: const AuthInitial(),
      );

      await tester.pumpWidget(
        createWidgetUnderTest(
          const AuthMethodButtons(
            methods: [AuthMethodType.google, AuthMethodType.twitter],
            action: AuthActionType.signIn,
          ),
        ),
      );

      expect(find.text('Log in with Google'), findsOneWidget);
      expect(find.text('Log in with X'), findsOneWidget);
      expect(find.text('Log in with email'), findsNothing);
      expect(find.text('Log in with LinkedIn'), findsNothing);
      expect(find.byType(AuthButton), findsNWidgets(2));
    });

    testWidgets('tapping Google button dispatches AuthGoogleSignInRequested', (
      tester,
    ) async {
      whenListen(
        mockAuthBloc,
        const Stream<AuthState>.empty(),
        initialState: const AuthInitial(),
      );

      await tester.pumpWidget(
        createWidgetUnderTest(
          const AuthMethodButtons(),
        ),
      );

      await tester.tap(find.text('Sign up with Google'));
      await tester.pump();

      verify(
        () => mockAuthBloc.add(const AuthGoogleSignInRequested()),
      ).called(1);
    });

    testWidgets(
      'tapping Twitter button dispatches AuthTwitterSignInRequested',
      (tester) async {
        whenListen(
          mockAuthBloc,
          const Stream<AuthState>.empty(),
          initialState: const AuthInitial(),
        );

        await tester.pumpWidget(
          createWidgetUnderTest(
            const AuthMethodButtons(),
          ),
        );

        await tester.tap(find.text('Sign up with X'));
        await tester.pump();

        verify(
          () => mockAuthBloc.add(const AuthTwitterSignInRequested()),
        ).called(1);
      },
    );

    testWidgets(
      'tapping LinkedIn button dispatches AuthLinkedInSignInRequested',
      (tester) async {
        whenListen(
          mockAuthBloc,
          const Stream<AuthState>.empty(),
          initialState: const AuthInitial(),
        );

        await tester.pumpWidget(
          createWidgetUnderTest(
            const AuthMethodButtons(),
          ),
        );

        await tester.tap(find.text('Sign up with LinkedIn'));
        await tester.pump();

        verify(
          () => mockAuthBloc.add(const AuthLinkedInSignInRequested()),
        ).called(1);
      },
    );

    testWidgets('shows loading on Google button and disables all others', (
      tester,
    ) async {
      whenListen(
        mockAuthBloc,
        const Stream<AuthState>.empty(),
        initialState: const AuthLoading(provider: AuthProviderType.google),
      );

      await tester.pumpWidget(
        createWidgetUnderTest(
          const AuthMethodButtons(),
        ),
      );

      expect(find.text('Please wait...'), findsOneWidget);
      expect(find.text('Sign up with Google'), findsNothing);
      expect(find.text('Sign up with email'), findsOneWidget);
      expect(find.text('Sign up with X'), findsOneWidget);
      expect(find.text('Sign up with LinkedIn'), findsOneWidget);

      // Tapping another button while loading should not dispatch any event
      await tester.tap(find.text('Sign up with X'));
      await tester.pump();

      verifyNever(() => mockAuthBloc.add(const AuthTwitterSignInRequested()));
    });

    testWidgets('invokes custom onEmailPressed callback', (tester) async {
      var emailClicked = false;
      whenListen(
        mockAuthBloc,
        const Stream<AuthState>.empty(),
        initialState: const AuthInitial(),
      );

      await tester.pumpWidget(
        createWidgetUnderTest(
          AuthMethodButtons(
            onEmailPressed: () => emailClicked = true,
          ),
        ),
      );

      await tester.tap(find.text('Sign up with email'));
      await tester.pump();

      expect(emailClicked, isTrue);
    });
  });
}
