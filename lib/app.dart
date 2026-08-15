import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:scriptless/di/injection_container.dart';
import 'package:scriptless/flavors.dart';

/// Root widget of the application configured with [GoRouter].
class App extends StatelessWidget {
  /// Creates the [App] widget.
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final router = sl<GoRouter>();

    return MaterialApp.router(
      title: F.title,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      routerConfig: router,
      builder: (context, child) => _flavorBanner(
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }

  Widget _flavorBanner({required Widget child, bool show = true}) => show
      ? Banner(
          location: BannerLocation.topStart,
          message: F.name,
          color: Colors.green.withAlpha(150),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12,
            letterSpacing: 1,
          ),
          textDirection: TextDirection.ltr,
          child: child,
        )
      : child;
}
