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
import 'package:scriptless/common/widgets/custom_textfield.dart';
import 'package:scriptless/common/widgets/primary_button.dart';
import 'package:scriptless/di/injection_container.dart';
import 'package:scriptless/features/auth/presentation/bloc/auth_bloc.dart';

/// Registration screen with email & password.
class AuthRegisterPage extends StatelessWidget {
  /// Default constructor.
  const AuthRegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (_) => sl<AuthBloc>(),
      child: const _AuthRegisterView(),
    );
  }
}

class _AuthRegisterView extends StatefulWidget {
  const _AuthRegisterView();

  @override
  State<_AuthRegisterView> createState() => _AuthRegisterViewState();
}

class _AuthRegisterViewState extends State<_AuthRegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        AuthSignUpRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
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
        } else if (state is AuthSuccess) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(
                  'Account created successfully!',
                  style: AppTypography.bodyMSemiBold.copyWith(
                    color: AppColors.white,
                  ),
                ),
                backgroundColor: AppColors.purpleHard,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
        }
      },
      builder: (context, state) {
        final isLoading =
            state is AuthLoading &&
            state.provider == AuthProviderType.emailSignUp;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.grey950),
              onPressed: () => context.pop(),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create Account',
                      style: AppTypography.h3Bold.copyWith(
                        color: AppColors.grey950,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.spacing8),
                    Text(
                      'Sign up with your email and start your journey.',
                      style: AppTypography.bodyLRegular.copyWith(
                        color: AppColors.grey500,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.spacing32),
                    CustomTextField(
                      labelText: 'Email address',
                      hintText: 'name@example.com',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email is required';
                        }
                        if (!_emailRegex.hasMatch(value.trim())) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.spacing16),
                    CustomTextField(
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      controller: _passwordController,
                      isPassword: true,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.spacing16),
                    CustomTextField(
                      labelText: 'Confirm Password',
                      hintText: 'Re-enter your password',
                      controller: _confirmPasswordController,
                      isPassword: true,
                      textInputAction: TextInputAction.done,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.spacing32),
                    PrimaryButton(
                      text: 'Sign Up',
                      isLoading: isLoading,
                      onPressed: isLoading ? null : _submitForm,
                    ),
                    const SizedBox(height: AppSpacing.spacing24),
                    Center(
                      child: RichText(
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
                                ..onTap = () {
                                  context.pushReplacementNamed(
                                    AppRoutes.authEmailLogin,
                                  );
                                },
                              style: AppTypography.bodyMSemiBold.copyWith(
                                color: AppColors.purpleHard,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
