import 'package:flutter/material.dart';

/// Historique / History page (Tab index 2).
class HistoryPage extends StatelessWidget {
  /// Creates the [HistoryPage].
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Text('Historique'),
        ),
      ),
    );
  }
}
