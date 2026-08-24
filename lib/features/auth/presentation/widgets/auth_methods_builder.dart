import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scriptless/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:scriptless/features/auth/presentation/models/auth_method.dart';

/// Data class representing the state of an auth method item.
@immutable
class AuthMethodItemData {
  /// Default constructor for [AuthMethodItemData].
  const AuthMethodItemData({
    required this.config,
    required this.label,
    required this.isLoading,
    required this.isAnyLoading,
    required this.onPressed,
  });

  /// The method configuration.
  final AuthMethodConfig config;

  /// The localized or resolved display label (e.g. "Sign up with Google").
  final String label;

  /// Whether this specific auth method is in a loading state.
  final bool isLoading;

  /// Whether any auth method or OAuth browser flow is currently loading.
  final bool isAnyLoading;

  /// The callback to invoke on tap (disabled if [isAnyLoading] is true).
  final VoidCallback? onPressed;

  /// Helper to get the method type.
  AuthMethodType get type => config.type;

  /// Helper to get the icon asset path.
  String get iconAssetPath => config.iconAssetPath;
}

/// Widget builder that consumes [AuthBloc] and provides resolved
/// [AuthMethodItemData] for every configured [AuthMethodType].
class AuthMethodsBuilder extends StatelessWidget {
  /// Default constructor for [AuthMethodsBuilder].
  const AuthMethodsBuilder({
    required this.builder,
    super.key,
    this.methods = const [
      AuthMethodType.email,
      AuthMethodType.google,
      AuthMethodType.twitter,
      AuthMethodType.linkedIn,
    ],
    this.action = AuthActionType.signUp,
    this.onEmailPressed,
  });

  /// The list of auth methods to include.
  final List<AuthMethodType> methods;

  /// The action intent (e.g. sign up, sign in).
  final AuthActionType action;

  /// Optional custom handler for email button clicks.
  final VoidCallback? onEmailPressed;

  /// Builder callback that provides the resolved items.
  final Widget Function(
    BuildContext context,
    List<AuthMethodItemData> items,
  )
  builder;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isAnyLoading =
            state is AuthLoading || state is AuthOAuthInProgress;

        final items = methods
            .map((methodType) {
              final config = AuthMethodConfig.fromType(methodType);
              final isLoading =
                  state is AuthLoading &&
                  config.loadingProvider != null &&
                  state.provider == config.loadingProvider;

              return AuthMethodItemData(
                config: config,
                label: config.getLabel(action),
                isLoading: isLoading,
                isAnyLoading: isAnyLoading,
                onPressed: isAnyLoading
                    ? null
                    : () => config.triggerAuth(
                        context,
                        onEmailPressed: onEmailPressed,
                      ),
              );
            })
            .toList(growable: false);

        return builder(context, items);
      },
    );
  }
}
