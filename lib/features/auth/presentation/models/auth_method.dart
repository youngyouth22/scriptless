import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:scriptless/common/resources/app_routes.dart';
import 'package:scriptless/common/resources/image_resources.dart';
import 'package:scriptless/features/auth/presentation/bloc/auth_bloc.dart';

/// Supported authentication methods/providers across the app.
enum AuthMethodType {
  /// Sign up or log in with email and password.
  email,

  /// Google OAuth sign-in.
  google,

  /// Twitter / X OAuth sign-in.
  twitter,

  /// LinkedIn OAuth sign-in.
  linkedIn,
}

/// Action intent for authentication buttons (e.g. Sign up, Log in, Continue).
enum AuthActionType {
  /// User intends to register / sign up.
  signUp,

  /// User intends to log in / sign in.
  signIn,

  /// Generic continuation action.
  continueWith,
}

/// Configuration and helper methods for an authentication method.
@immutable
class AuthMethodConfig {
  /// Default constructor for an [AuthMethodConfig].
  const AuthMethodConfig({
    required this.type,
    required this.displayName,
    required this.iconAssetPath,
    this.loadingProvider,
  });

  /// The type of authentication method.
  final AuthMethodType type;

  /// The display name of the provider
  /// (e.g. "Google", "X", "LinkedIn", "email").
  final String displayName;

  /// Asset path for the provider's SVG/image icon.
  final String iconAssetPath;

  /// Corresponding [AuthProviderType] in [AuthBloc] for tracking loading state.
  final AuthProviderType? loadingProvider;

  /// Returns the human-readable button text based on the [AuthActionType].
  String getLabel(AuthActionType action) {
    switch (action) {
      case AuthActionType.signUp:
        return 'Sign up with $displayName';
      case AuthActionType.signIn:
        return 'Log in with $displayName';
      case AuthActionType.continueWith:
        return 'Continue with $displayName';
    }
  }

  /// Dispatches the appropriate BLoC event or invokes custom callback.
  void triggerAuth(
    BuildContext context, {
    VoidCallback? onEmailPressed,
  }) {
    switch (type) {
      case AuthMethodType.email:
        if (onEmailPressed != null) {
          onEmailPressed();
        } else {
          unawaited(
            context.pushNamed(AppRoutes.authRegister).then((_) {
              if (context.mounted) {
                context.read<AuthBloc>().add(const AuthResetRequested());
              }
            }),
          );
        }
      case AuthMethodType.google:
        context.read<AuthBloc>().add(const AuthGoogleSignInRequested());
      case AuthMethodType.twitter:
        context.read<AuthBloc>().add(const AuthTwitterSignInRequested());
      case AuthMethodType.linkedIn:
        context.read<AuthBloc>().add(const AuthLinkedInSignInRequested());
    }
  }

  /// Email configuration.
  static const email = AuthMethodConfig(
    type: AuthMethodType.email,
    displayName: 'email',
    iconAssetPath: ImageResources.emailIcon,
  );

  /// Google OAuth configuration.
  static const google = AuthMethodConfig(
    type: AuthMethodType.google,
    displayName: 'Google',
    iconAssetPath: ImageResources.googleIcon,
    loadingProvider: AuthProviderType.google,
  );

  /// Twitter / X OAuth configuration.
  static const twitter = AuthMethodConfig(
    type: AuthMethodType.twitter,
    displayName: 'X',
    iconAssetPath: ImageResources.xIcon,
    loadingProvider: AuthProviderType.twitter,
  );

  /// LinkedIn OAuth configuration.
  static const linkedIn = AuthMethodConfig(
    type: AuthMethodType.linkedIn,
    displayName: 'LinkedIn',
    iconAssetPath: ImageResources.linkedinIcon,
    loadingProvider: AuthProviderType.linkedIn,
  );

  /// Retrieves the [AuthMethodConfig] for a given [AuthMethodType].
  static AuthMethodConfig fromType(AuthMethodType type) {
    switch (type) {
      case AuthMethodType.email:
        return email;
      case AuthMethodType.google:
        return google;
      case AuthMethodType.twitter:
        return twitter;
      case AuthMethodType.linkedIn:
        return linkedIn;
    }
  }

  /// Predefined list containing all supported authentication methods.
  static const List<AuthMethodConfig> all = [
    email,
    google,
    twitter,
    linkedIn,
  ];

  /// Predefined list containing only OAuth social providers.
  static const List<AuthMethodConfig> oAuthProviders = [
    google,
    twitter,
    linkedIn,
  ];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthMethodConfig &&
          runtimeType == other.runtimeType &&
          type == other.type;

  @override
  int get hashCode => type.hashCode;
}
