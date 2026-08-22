import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:scriptless/common/resources/app_routes.dart';
import 'package:scriptless/di/injection_container.dart';
import 'package:scriptless/features/splash/presentation/cubit/splash_cubit.dart';
import 'package:scriptless/features/splash/presentation/cubit/splash_state.dart';

/// Splash screen placeholder.
///
/// UI design to be customized by the UI designer.
/// Listens to [SplashCubit] and redirects to the appropriate destination route.
class SplashPage extends StatelessWidget {
  /// Creates the [SplashPage].
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SplashCubit>(
      create: (context) {
        final cubit = sl<SplashCubit>();
        unawaited(cubit.init());
        return cubit;
      },
      child: const _SplashPageView(),
    );
  }
}

class _SplashPageView extends StatelessWidget {
  const _SplashPageView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashCubit, SplashState>(
      listener: (context, state) {
        switch (state) {
          case SplashNavigateToLogin():
            context.go(AppRoutes.authLogin);
          case SplashNavigateToOnboarding():
            context.go(AppRoutes.onboarding);
          case SplashNavigateToDashboard():
            context.go(AppRoutes.dashboard);
          case SplashError():
            // Error handling or retry UI can be added by UI designer.
            break;
          case SplashInitial():
          case SplashLoading():
            break;
        }
      },
      child: const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
