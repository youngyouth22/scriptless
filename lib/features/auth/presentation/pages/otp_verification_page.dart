import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:scriptless/common/resources/app_colors.dart';
import 'package:scriptless/common/resources/app_routes.dart';
import 'package:scriptless/common/resources/app_spacing.dart';
import 'package:scriptless/common/resources/app_typography.dart';
import 'package:scriptless/common/resources/image_resources.dart';
import 'package:scriptless/common/widgets/custom_textfield.dart';
import 'package:scriptless/common/widgets/primary_button.dart';
import 'package:scriptless/di/injection_container.dart';
import 'package:scriptless/features/auth/presentation/bloc/otp_bloc.dart';

/// Supported modes for the versatile [OtpVerificationPage].
enum OtpFlowType {
  /// Unauthenticated password reset flow (Email -> OTP -> New Password).
  forgotPassword,

  /// Account verification after registration (starts at OTP step with email).
  signUpVerification,

  /// Change password flow (OTP -> New Password or directly New Password).
  changePassword,
}

/// Routing arguments for [OtpVerificationPage].
class OtpPageArgs {
  /// Creates [OtpPageArgs].
  const OtpPageArgs({
    required this.email,
    this.flowType = OtpFlowType.forgotPassword,
  });

  /// The target email address.
  final String email;

  /// The flow mode.
  final OtpFlowType flowType;
}

/// Versatile OTP and password reset / change page using [PageView].
class OtpVerificationPage extends StatelessWidget {
  /// Creates an [OtpVerificationPage].
  const OtpVerificationPage({
    super.key,
    this.initialEmail,
    this.flowType = OtpFlowType.forgotPassword,
  });

  /// Optional initial email to pre-fill.
  final String? initialEmail;

  /// The flow mode (defaults to [OtpFlowType.forgotPassword]).
  final OtpFlowType flowType;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OtpBloc>(
      create: (_) => sl<OtpBloc>(),
      child: _OtpVerificationView(
        initialEmail: initialEmail,
        flowType: flowType,
      ),
    );
  }
}

class _OtpVerificationView extends StatefulWidget {
  const _OtpVerificationView({
    required this.flowType,
    this.initialEmail,
  });

  final String? initialEmail;
  final OtpFlowType flowType;

  @override
  State<_OtpVerificationView> createState() => _OtpVerificationViewState();
}

class _OtpVerificationViewState extends State<_OtpVerificationView> {
  late final PageController _pageController;
  late int _currentStep;

  final _emailFormKey = GlobalKey<FormState>();
  final _otpFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  late final TextEditingController _emailController;
  late final TextEditingController _otpController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  Timer? _resendTimer;
  int _resendCountdown = 60;
  bool _canResend = true;

  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  bool get _isSignUp => widget.flowType == OtpFlowType.signUpVerification;

  @override
  void initState() {
    super.initState();
    _currentStep = _isSignUp ? 1 : 0;
    _pageController = PageController(initialPage: _currentStep);
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
    _otpController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    if (_isSignUp) {
      _startResendTimer();
    }
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _pageController.dispose();
    _emailController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() {
      _resendCountdown = 60;
      _canResend = false;
    });
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown <= 1) {
        timer.cancel();
        setState(() {
          _canResend = true;
          _resendCountdown = 60;
        });
      } else {
        setState(() {
          _resendCountdown--;
        });
      }
    });
  }

  void _goToPage(int page) {
    setState(() {
      _currentStep = page;
    });
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _handleBack() {
    if (_currentStep > 0 && _currentStep < 3 && !_isSignUp) {
      _goToPage(_currentStep - 1);
    } else {
      context.pop();
    }
  }

  void _submitEmail() {
    if (_emailFormKey.currentState?.validate() ?? false) {
      context.read<OtpBloc>().add(
        OtpEmailSubmitted(_emailController.text.trim()),
      );
    }
  }

  void _submitOtp() {
    if (_otpFormKey.currentState?.validate() ?? false) {
      context.read<OtpBloc>().add(
        OtpCodeSubmitted(
          email: _emailController.text.trim(),
          token: _otpController.text.trim(),
          isSignUpVerification: _isSignUp,
        ),
      );
    }
  }

  void _submitNewPassword() {
    if (_passwordFormKey.currentState?.validate() ?? false) {
      context.read<OtpBloc>().add(
        OtpNewPasswordSubmitted(_passwordController.text),
      );
    }
  }

  void _resendCode() {
    if (!_canResend) return;
    context.read<OtpBloc>().add(
      OtpResendRequested(
        _emailController.text.trim(),
        isSignUpVerification: _isSignUp,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
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
                  message,
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
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(AppSpacing.spacing16),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OtpBloc, OtpState>(
      listener: (context, state) {
        if (state is OtpEmailSentSuccess) {
          _startResendTimer();
          if (_currentStep == 0) {
            _goToPage(1);
          }
        } else if (state is OtpVerifiedSuccess) {
          if (_isSignUp) {
            _goToPage(3);
          } else if (_currentStep == 1) {
            _goToPage(2);
          }
        } else if (state is OtpPasswordResetSuccess) {
          _goToPage(3);
        } else if (state is OtpFailureState) {
          _showErrorSnackBar(state.message);
        }
      },
      builder: (context, state) {
        final isLoading = state is OtpLoading;
        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: AppBar(
            backgroundColor: AppColors.white,
            elevation: 0,
            leading: _currentStep < 3
                ? IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.grey950,
                      size: 20,
                    ),
                    onPressed: _handleBack,
                  )
                : null,
          ),
          body: SafeArea(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildEmailStep(isLoading),
                _buildOtpStep(isLoading),
                _buildNewPasswordStep(isLoading),
                _buildSuccessStep(),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Step 0: Email ─────────────────────────────────────────────────────────

  Widget _buildEmailStep(bool isLoading) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing24),
      child: Form(
        key: _emailFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.spacing16),
            Text(
              'Forgot password?',
              textAlign: TextAlign.center,
              style: AppTypography.h3Bold.copyWith(color: AppColors.grey950),
            ),
            const SizedBox(height: AppSpacing.spacing8),
            Text(
              "Enter your email address and we'll send you "
              'a 6-digit confirmation code to reset your password.',
              textAlign: TextAlign.center,
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
              textInputAction: TextInputAction.done,
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
            const SizedBox(height: AppSpacing.spacing32),
            PrimaryButton(
              text: 'Send Code',
              isLoading: isLoading,
              onPressed: isLoading ? null : _submitEmail,
            ),
            const SizedBox(height: AppSpacing.spacing24),
            Center(
              child: TextButton(
                onPressed: () => context.pop(),
                child: Text(
                  'Back to Log In',
                  style: AppTypography.bodyMSemiBold.copyWith(
                    color: AppColors.purpleHard,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Step 1: OTP Code ──────────────────────────────────────────────────────

  Widget _buildOtpStep(bool isLoading) {
    final defaultPinTheme = PinTheme(
      width: 48,
      height: 56,
      textStyle: AppTypography.h4Bold.copyWith(color: AppColors.grey950),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: AppColors.purpleLight,
        border: Border.all(color: AppColors.purpleHard, width: 1.5),
      ),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: AppColors.red),
      ),
    );

    final title =
        _isSignUp ? 'Verify your account' : 'Enter verification code';
    final subtitlePrefix = _isSignUp
        ? "We've sent a 6-digit verification code to\n"
        : "We've sent a 6-digit code to\n";

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing24),
      child: Form(
        key: _otpFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.spacing16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.h3Bold.copyWith(color: AppColors.grey950),
            ),
            const SizedBox(height: AppSpacing.spacing8),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: AppTypography.bodyLRegular.copyWith(
                  color: AppColors.grey500,
                ),
                children: [
                  TextSpan(text: subtitlePrefix),
                  TextSpan(
                    text: _emailController.text.trim(),
                    style: AppTypography.bodyLSemiBold.copyWith(
                      color: AppColors.grey950,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.spacing32),
            Center(
              child: Pinput(
                length: 6,
                controller: _otpController,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: focusedPinTheme,
                errorPinTheme: errorPinTheme,
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'Please enter the 6-digit code';
                  }
                  return null;
                },
                onCompleted: (_) => _submitOtp(),
              ),
            ),
            const SizedBox(height: AppSpacing.spacing24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Didn't receive the code? ",
                  style: AppTypography.bodyMMedium.copyWith(
                    color: AppColors.grey500,
                  ),
                ),
                if (_canResend)
                  TextButton(
                    onPressed: isLoading ? null : _resendCode,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Resend',
                      style: AppTypography.bodyMSemiBold.copyWith(
                        color: AppColors.purpleHard,
                      ),
                    ),
                  )
                else
                  Text(
                    'Resend in ${_resendCountdown}s',
                    style: AppTypography.bodyMSemiBold.copyWith(
                      color: AppColors.grey400,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.spacing32),
            PrimaryButton(
              text: 'Verify Code',
              isLoading: isLoading,
              onPressed: isLoading ? null : _submitOtp,
            ),
            if (!_isSignUp) ...[
              const SizedBox(height: AppSpacing.spacing16),
              Center(
                child: TextButton(
                  onPressed: () => _goToPage(0),
                  child: Text(
                    'Change email',
                    style: AppTypography.bodyMMedium.copyWith(
                      color: AppColors.grey600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Step 2: New Password ──────────────────────────────────────────────────

  Widget _buildNewPasswordStep(bool isLoading) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing24),
      child: Form(
        key: _passwordFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.spacing16),
            Text(
              'Create new password',
              textAlign: TextAlign.center,
              style: AppTypography.h3Bold.copyWith(color: AppColors.grey950),
            ),
            const SizedBox(height: AppSpacing.spacing8),
            Text(
              'Your new password must be at least 6 characters long.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyLRegular.copyWith(
                color: AppColors.grey500,
              ),
            ),
            const SizedBox(height: AppSpacing.spacing32),
            CustomTextField(
              labelText: 'New Password',
              hintText: 'Enter new password',
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
              hintText: 'Re-enter new password',
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
              text: widget.flowType == OtpFlowType.changePassword
                  ? 'Update Password'
                  : 'Reset Password',
              isLoading: isLoading,
              onPressed: isLoading ? null : _submitNewPassword,
            ),
          ],
        ),
      ),
    );
  }

  // ── Step 3: Success ───────────────────────────────────────────────────────

  Widget _buildSuccessStep() {
    final title =
        _isSignUp ? 'Account verified!' : 'Password updated!';
    final subtitle = _isSignUp
        ? 'Your account has been verified successfully. '
          'You can now sign in and get started.'
        : 'Your password has been reset successfully. '
          'You can now sign in with your new credentials.';
    final buttonText = _isSignUp ? 'Get Started' : 'Back to Log In';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: AppColors.purpleLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              size: 48,
              color: AppColors.purpleHard,
            ),
          ),
          const SizedBox(height: AppSpacing.spacing24),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.h3Bold.copyWith(color: AppColors.grey950),
          ),
          const SizedBox(height: AppSpacing.spacing8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppTypography.bodyLRegular.copyWith(
              color: AppColors.grey500,
            ),
          ),
          const SizedBox(height: AppSpacing.spacing32),
          PrimaryButton(
            text: buttonText,
            onPressed: () {
              context.goNamed(AppRoutes.authEmailLogin);
            },
          ),
        ],
      ),
    );
  }
}
