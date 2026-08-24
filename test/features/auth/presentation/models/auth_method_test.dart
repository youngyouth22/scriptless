import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scriptless/common/resources/image_resources.dart';
import 'package:scriptless/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:scriptless/features/auth/presentation/models/auth_method.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  group('AuthMethodConfig Unit Tests', () {
    test('fromType returns corresponding config for all types', () {
      expect(
        AuthMethodConfig.fromType(AuthMethodType.email),
        AuthMethodConfig.email,
      );
      expect(
        AuthMethodConfig.fromType(AuthMethodType.google),
        AuthMethodConfig.google,
      );
      expect(
        AuthMethodConfig.fromType(AuthMethodType.twitter),
        AuthMethodConfig.twitter,
      );
      expect(
        AuthMethodConfig.fromType(AuthMethodType.linkedIn),
        AuthMethodConfig.linkedIn,
      );
    });

    test('getLabel produces correct labels for each AuthActionType', () {
      const google = AuthMethodConfig.google;
      expect(google.getLabel(AuthActionType.signUp), 'Sign up with Google');
      expect(google.getLabel(AuthActionType.signIn), 'Log in with Google');
      expect(
        google.getLabel(AuthActionType.continueWith),
        'Continue with Google',
      );

      const email = AuthMethodConfig.email;
      expect(email.getLabel(AuthActionType.signUp), 'Sign up with email');
      expect(email.getLabel(AuthActionType.signIn), 'Log in with email');
      expect(
        email.getLabel(AuthActionType.continueWith),
        'Continue with email',
      );
    });

    test('iconAssetPath returns correct resource', () {
      expect(AuthMethodConfig.email.iconAssetPath, ImageResources.emailIcon);
      expect(AuthMethodConfig.google.iconAssetPath, ImageResources.googleIcon);
      expect(AuthMethodConfig.twitter.iconAssetPath, ImageResources.xIcon);
      expect(
        AuthMethodConfig.linkedIn.iconAssetPath,
        ImageResources.linkedinIcon,
      );
    });

    test('predefined lists contain expected items', () {
      expect(AuthMethodConfig.all.length, 4);
      expect(AuthMethodConfig.oAuthProviders.length, 3);
      expect(
        AuthMethodConfig.oAuthProviders.map((c) => c.type),
        containsAll([
          AuthMethodType.google,
          AuthMethodType.twitter,
          AuthMethodType.linkedIn,
        ]),
      );
    });

    testWidgets('triggerAuth dispatches Google signIn event', (tester) async {
      final mockAuthBloc = MockAuthBloc();
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>.value(
            value: mockAuthBloc,
            child: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () => AuthMethodConfig.google.triggerAuth(context),
                  child: const Text('Tap'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tap'));
      await tester.pump();

      verify(
        () => mockAuthBloc.add(const AuthGoogleSignInRequested()),
      ).called(1);
    });

    testWidgets('triggerAuth dispatches Twitter signIn event', (tester) async {
      final mockAuthBloc = MockAuthBloc();
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>.value(
            value: mockAuthBloc,
            child: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () =>
                      AuthMethodConfig.twitter.triggerAuth(context),
                  child: const Text('Tap'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tap'));
      await tester.pump();

      verify(
        () => mockAuthBloc.add(const AuthTwitterSignInRequested()),
      ).called(1);
    });

    testWidgets('triggerAuth dispatches LinkedIn signIn event', (tester) async {
      final mockAuthBloc = MockAuthBloc();
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>.value(
            value: mockAuthBloc,
            child: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () =>
                      AuthMethodConfig.linkedIn.triggerAuth(context),
                  child: const Text('Tap'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tap'));
      await tester.pump();

      verify(
        () => mockAuthBloc.add(const AuthLinkedInSignInRequested()),
      ).called(1);
    });

    testWidgets('triggerAuth calls onEmailPressed if provided for email type', (
      tester,
    ) async {
      var customEmailCalled = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => AuthMethodConfig.email.triggerAuth(
                  context,
                  onEmailPressed: () => customEmailCalled = true,
                ),
                child: const Text('Tap'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Tap'));
      await tester.pump();

      expect(customEmailCalled, isTrue);
    });
  });
}
