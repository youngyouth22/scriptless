import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scriptless/common/widgets/custom_circular_loading_indicator.dart';
import 'package:scriptless/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:scriptless/features/auth/presentation/models/auth_method.dart';
import 'package:scriptless/features/auth/presentation/widgets/auth_icon_button.dart';
import 'package:scriptless/features/auth/presentation/widgets/auth_method_icon_buttons.dart';

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

  group('AuthMethodIconButtons Widget Tests', () {
    testWidgets('renders 3 default OAuth icon buttons', (tester) async {
      whenListen(
        mockAuthBloc,
        const Stream<AuthState>.empty(),
        initialState: const AuthInitial(),
      );

      await tester.pumpWidget(
        createWidgetUnderTest(
          const AuthMethodIconButtons(),
        ),
      );

      expect(find.byType(AuthIconButton), findsNWidgets(3));
    });

    testWidgets('renders custom list of methods', (tester) async {
      whenListen(
        mockAuthBloc,
        const Stream<AuthState>.empty(),
        initialState: const AuthInitial(),
      );

      await tester.pumpWidget(
        createWidgetUnderTest(
          const AuthMethodIconButtons(
            methods: [
              AuthMethodType.google,
              AuthMethodType.email,
            ],
          ),
        ),
      );

      expect(find.byType(AuthIconButton), findsNWidgets(2));
    });

    testWidgets(
      'tapping Google icon button dispatches AuthGoogleSignInRequested',
      (tester) async {
        whenListen(
          mockAuthBloc,
          const Stream<AuthState>.empty(),
          initialState: const AuthInitial(),
        );

        await tester.pumpWidget(
          createWidgetUnderTest(
            const AuthMethodIconButtons(),
          ),
        );

        final iconButtons = find.byType(AuthIconButton);
        await tester.tap(iconButtons.at(0));
        await tester.pump();

        verify(
          () => mockAuthBloc.add(const AuthGoogleSignInRequested()),
        ).called(1);
      },
    );

    testWidgets(
      'tapping Twitter icon button dispatches AuthTwitterSignInRequested',
      (tester) async {
        whenListen(
          mockAuthBloc,
          const Stream<AuthState>.empty(),
          initialState: const AuthInitial(),
        );

        await tester.pumpWidget(
          createWidgetUnderTest(
            const AuthMethodIconButtons(),
          ),
        );

        final iconButtons = find.byType(AuthIconButton);
        await tester.tap(iconButtons.at(1));
        await tester.pump();

        verify(
          () => mockAuthBloc.add(const AuthTwitterSignInRequested()),
        ).called(1);
      },
    );

    testWidgets('shows loading indicator on the active provider', (
      tester,
    ) async {
      whenListen(
        mockAuthBloc,
        const Stream<AuthState>.empty(),
        initialState: const AuthLoading(provider: AuthProviderType.google),
      );

      await tester.pumpWidget(
        createWidgetUnderTest(
          const AuthMethodIconButtons(),
        ),
      );

      expect(find.byType(CustomCircularLoadingIndicator), findsOneWidget);
    });
  });
}
