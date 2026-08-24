import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scriptless/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:scriptless/features/auth/presentation/widgets/auth_button.dart';
import 'package:scriptless/features/auth/presentation/widgets/auth_icon_button.dart';
import 'package:scriptless/features/auth/presentation/widgets/responsive_horizontal_auth_buttons.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
  });

  Widget createWidgetUnderTest(Widget child, {double width = 400}) {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<AuthBloc>.value(
          value: mockAuthBloc,
          child: SizedBox(
            width: width,
            child: child,
          ),
        ),
      ),
    );
  }

  group('ResponsiveHorizontalAuthButtons Widget Tests', () {
    testWidgets('renders icon buttons when width is above breakpoint', (
      tester,
    ) async {
      whenListen(
        mockAuthBloc,
        const Stream<AuthState>.empty(),
        initialState: const AuthInitial(),
      );

      await tester.pumpWidget(
        createWidgetUnderTest(
          const ResponsiveHorizontalAuthButtons(),
          width: 500,
        ),
      );

      expect(find.byType(AuthIconButton), findsNWidgets(3));
      expect(find.byType(AuthButton), findsNothing);
    });

    testWidgets('renders full buttons when width is below breakpoint', (
      tester,
    ) async {
      whenListen(
        mockAuthBloc,
        const Stream<AuthState>.empty(),
        initialState: const AuthInitial(),
      );

      await tester.pumpWidget(
        createWidgetUnderTest(
          const ResponsiveHorizontalAuthButtons(),
          width: 200,
        ),
      );

      expect(find.byType(AuthButton), findsNWidgets(3));
      expect(find.byType(AuthIconButton), findsNothing);
    });
  });
}
