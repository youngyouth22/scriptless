import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:scriptless/common/resources/app_colors.dart';
import 'package:scriptless/common/resources/app_routes.dart';
import 'package:scriptless/common/resources/app_typography.dart';
import 'package:scriptless/common/widgets/primary_button.dart';
import 'package:scriptless/di/injection_container.dart';
import 'package:scriptless/features/permissions/presentation/cubit/microphone_priming_cubit.dart';
import 'package:scriptless/features/permissions/presentation/cubit/microphone_priming_state.dart';

/// Microphone permission explanation / priming page.
///
/// Prompts the user to understand why microphone access is required for
/// real-time voice conversations before triggering the OS permission prompt.
class MicrophonePrimingPage extends StatelessWidget {
  /// Creates the [MicrophonePrimingPage].
  const MicrophonePrimingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MicrophonePrimingCubit>(
      create: (context) {
        final cubit = sl<MicrophonePrimingCubit>();
        unawaited(cubit.checkStatus());
        return cubit;
      },
      child: const _MicrophonePrimingView(),
    );
  }
}

class _MicrophonePrimingView extends StatelessWidget {
  const _MicrophonePrimingView();

  void _onProceed(BuildContext context) {
    if (context.mounted) {
      context.pushReplacement(AppRoutes.permissionsNotificationsPriming);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MicrophonePrimingCubit, MicrophonePrimingState>(
      listener: (context, state) {
        if (state is MicrophonePrimingGranted ||
            state is MicrophonePrimingSkipped) {
          _onProceed(context);
        } else if (state is MicrophonePrimingFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final isRequesting = state is MicrophonePrimingRequesting;
        final isPermanentlyDenied =
            state is MicrophonePrimingPermanentlyDenied;

        return Scaffold(
          backgroundColor: AppColors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              TextButton(
                key: const Key('microphone_priming_skip_button'),
                onPressed: isRequesting
                    ? null
                    : () => context.read<MicrophonePrimingCubit>().skip(),
                child: Text(
                  'Skip',
                  style: AppTypography.bodyMMedium.copyWith(
                    color: AppColors.grey300,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        child: Column(
                          children: [
                            const Spacer(),
                            Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                color: AppColors.purpleHard.withValues(
                                  alpha: 0.15,
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.purpleHard.withValues(
                                    alpha: 0.4,
                                  ),
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.mic_rounded,
                                size: 48,
                                color: AppColors.purpleHard,
                              ),
                            ),
                            const SizedBox(height: 32),
                            Text(
                              'Enable Microphone Access',
                              textAlign: TextAlign.center,
                              style: AppTypography.h3Bold.copyWith(
                                color: AppColors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Scriptless uses your microphone for real-time '
                              'voice AI simulation and instant feedback during '
                              'workplace conversation practices.',
                              textAlign: TextAlign.center,
                              style: AppTypography.bodyLRegular.copyWith(
                                color: AppColors.grey300,
                              ),
                            ),
                            if (isPermanentlyDenied) ...[
                              const SizedBox(height: 24),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.extraYellow.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.extraYellow.withValues(
                                      alpha: 0.3,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.info_outline,
                                      color: AppColors.extraYellow,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'Microphone access is disabled in '
                                        'system settings. Please enable it in '
                                        'Settings.',
                                        style: AppTypography.bodySRegular
                                            .copyWith(
                                          color: AppColors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const Spacer(),
                            if (isPermanentlyDenied)
                              PrimaryButton(
                                key: const Key(
                                  'microphone_priming_settings_button',
                                ),
                                text: 'Open Settings',
                                isLoading: isRequesting,
                                onPressed: () => context
                                    .read<MicrophonePrimingCubit>()
                                    .openSettings(),
                              )
                            else
                              PrimaryButton(
                                key: const Key(
                                  'microphone_priming_allow_button',
                                ),
                                text: 'Enable Microphone',
                                isLoading: isRequesting,
                                onPressed: () => context
                                    .read<MicrophonePrimingCubit>()
                                    .requestMicrophonePermission(),
                              ),
                            const SizedBox(height: 12),
                            TextButton(
                              key: const Key(
                                'microphone_priming_maybe_later_button',
                              ),
                              onPressed: isRequesting
                                  ? null
                                  : () => context
                                      .read<MicrophonePrimingCubit>()
                                      .skip(),
                              child: Text(
                                'Maybe later',
                                style: AppTypography.bodyMMedium.copyWith(
                                  color: AppColors.grey400,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
