import 'package:flutter/material.dart';

/// Scénarios / Library page (Tab index 1).
class LibraryPage extends StatelessWidget {
  /// Creates the [LibraryPage].
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Text('Scénarios'),
        ),
      ),
    );
  }
}
