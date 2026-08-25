import 'package:flutter/material.dart';

/// Profil / Profile page (Tab index 3).
class ProfilePage extends StatelessWidget {
  /// Creates the [ProfilePage].
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Text('Profil'),
        ),
      ),
    );
  }
}
