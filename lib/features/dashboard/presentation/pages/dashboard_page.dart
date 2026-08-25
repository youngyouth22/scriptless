import 'package:flutter/material.dart';

/// Main Dashboard / Accueil page (Tab index 0).
class DashboardPage extends StatelessWidget {
  /// Creates the [DashboardPage].
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Text('Accueil'),
        ),
      ),
    );
  }
}
