import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:scriptless/common/resources/app_colors.dart';
import 'package:scriptless/common/resources/app_routes.dart';
import 'package:scriptless/common/resources/app_spacing.dart';
import 'package:scriptless/common/resources/app_typography.dart';
import 'package:scriptless/common/resources/image_resources.dart';
import 'package:scriptless/di/injection_container.dart';
import 'package:scriptless/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:scriptless/features/auth/presentation/widgets/auth_method_buttons.dart';

/// Login screen (email + OAuth entry point).
class LoginPage extends StatelessWidget {
  /// Default constructor
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (_) => sl<AuthBloc>(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // When returning to app after OAuth browser is closed/cancelled
    if (state == AppLifecycleState.resumed) {
      final authBloc = context.read<AuthBloc>();
      final currentState = authBloc.state;
      if (currentState is AuthOAuthInProgress || currentState is AuthLoading) {
        authBloc.add(const AuthResetRequested());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailureState) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    SvgPicture.asset(
                      ImageResources.alertIcon,
                      colorFilter: const ColorFilter.mode(
                        AppColors.white,
                        BlendMode.srcIn,
                      ),
                      width: 20,
                    ),
                    const SizedBox(width: AppSpacing.spacing8),
                    Expanded(
                      child: Text(
                        state.message,
                        style: AppTypography.bodyMSemiBold.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                backgroundColor: AppColors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
        }
      },
      builder: (context, state) {
        final isAnyLoading =
            state is AuthLoading || state is AuthOAuthInProgress;

        return Scaffold(
          persistentFooterAlignment: AlignmentDirectional.center,
          persistentFooterButtons: const [
            Padding(
              padding: EdgeInsets.all(16),
              child: PrivacyRuleWidget(),
            ),
          ],
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Placeholder(
                      fallbackHeight: 200,
                      fallbackWidth: double.infinity,
                    ),
                  ),
                  Text(
                    'Sign up to see your personlized study plan!',
                    textAlign: TextAlign.center,
                    style: AppTypography.headingH4Bold.copyWith(
                      color: AppColors.grey950,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.spacing8),
                  Text(
                    'This will also let you save and sync your progress '
                    'across different devices & Social platforms',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyLRegular.copyWith(
                      color: AppColors.grey500,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.spacing24),
                  const AuthMethodButtons(),
                  const SizedBox(height: AppSpacing.spacing16),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: AppTypography.bodyMMedium.copyWith(
                        color: AppColors.grey500,
                      ),
                      children: [
                        const TextSpan(text: 'Already have an account? '),
                        TextSpan(
                          text: 'Log in',
                          recognizer: TapGestureRecognizer()
                            ..onTap = isAnyLoading
                                ? null
                                : () async {
                                    await context.pushNamed(
                                      AppRoutes.authEmailLogin,
                                    );
                                    if (context.mounted) {
                                      context.read<AuthBloc>().add(
                                        const AuthResetRequested(),
                                      );
                                    }
                                  },
                          style: AppTypography.bodyMSemiBold.copyWith(
                            color: AppColors.purpleHard,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Widget displaying terms of service and privacy policy links.
class PrivacyRuleWidget extends StatelessWidget {
  /// Default constructor.
  const PrivacyRuleWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: AppTypography.bodyMMedium.copyWith(
          color: AppColors.grey500,
        ),
        children: [
          const TextSpan(
            text: 'By continuing, you agree to Fluengo AI ',
          ),
          TextSpan(
            text: 'Terms & Service ',
            recognizer: TapGestureRecognizer()..onTap = () async {},
            style: AppTypography.bodyMMedium.copyWith(
              color: AppColors.purpleHard,
            ),
          ),
          const TextSpan(text: 'and '),
          TextSpan(
            text: 'Privacy Policy',
            recognizer: TapGestureRecognizer()..onTap = () async {},
            style: AppTypography.bodyMMedium.copyWith(
              color: AppColors.purpleHard,
            ),
          ),
        ],
      ),
    );
  }
}
