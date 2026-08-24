import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:scriptless/common/resources/app_colors.dart';
import 'package:scriptless/common/resources/app_routes.dart';
import 'package:scriptless/common/resources/app_typography.dart';
import 'package:scriptless/common/widgets/primary_button.dart';
import 'package:scriptless/di/injection_container.dart';
import 'package:scriptless/features/permissions/presentation/cubit/notifications_priming_cubit.dart';
import 'package:scriptless/features/permissions/presentation/cubit/notifications_priming_state.dart';

/// Notifications permission explanation / priming page.
///
/// Prompts the user to understand why push notifications are recommended for
/// daily practice reminders and habit building before triggering the OS prompt.
class NotificationsPrimingPage extends StatelessWidget {
  /// Creates the [NotificationsPrimingPage].
  const NotificationsPrimingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NotificationsPrimingCubit>(
      create: (context) {
        final cubit = sl<NotificationsPrimingCubit>();
        unawaited(cubit.checkStatus());
        return cubit;
      },
      child: const _NotificationsPrimingView(),
    );
  }
}

class _NotificationsPrimingView extends StatelessWidget {
  const _NotificationsPrimingView();

  void _onProceed(BuildContext context) {
    if (context.mounted) {
      context.go(AppRoutes.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NotificationsPrimingCubit, NotificationsPrimingState>(
      listener: (context, state) {
        if (state is NotificationsPrimingGranted ||
            state is NotificationsPrimingSkipped) {
          _onProceed(context);
        } else if (state is NotificationsPrimingFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final isRequesting = state is NotificationsPrimingRequesting;
        final isPermanentlyDenied =
            state is NotificationsPrimingPermanentlyDenied;

        return Scaffold(
          backgroundColor: AppColors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              TextButton(
                key: const Key('notifications_priming_skip_button'),
                onPressed: isRequesting
                    ? null
                    : () => context.read<NotificationsPrimingCubit>().skip(),
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
                                Icons.notifications_active_rounded,
                                size: 48,
                                color: AppColors.purpleHard,
                              ),
                            ),
                            const SizedBox(height: 32),
                            Text(
                              'Stay On Track',
                              textAlign: TextAlign.center,
                              style: AppTypography.h3Bold.copyWith(
                                color: AppColors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Get personalized coaching reminders, scenario '
                              'updates, and streak notifications to build '
                              'consistent leadership communication habits.',
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
                                        'Notifications are disabled in system '
                                        'settings. Please enable them in '
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
                                  'notifications_priming_settings_button',
                                ),
                                text: 'Open Settings',
                                isLoading: isRequesting,
                                onPressed: () => context
                                    .read<NotificationsPrimingCubit>()
                                    .openSettings(),
                              )
                            else
                              PrimaryButton(
                                key: const Key(
                                  'notifications_priming_allow_button',
                                ),
                                text: 'Enable Notifications',
                                isLoading: isRequesting,
                                onPressed: () => context
                                    .read<NotificationsPrimingCubit>()
                                    .requestNotificationPermission(),
                              ),
                            const SizedBox(height: 12),
                            TextButton(
                              key: const Key(
                                'notifications_priming_maybe_later_button',
                              ),
                              onPressed: isRequesting
                                  ? null
                                  : () => context
                                      .read<NotificationsPrimingCubit>()
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
