import 'package:flutter/foundation.dart';

/// Represents the authenticated user in the domain layer.
///
/// This entity is framework-agnostic — it has no dependency on Supabase or
/// any external package.
@immutable
class AppUser {
  /// Creates an [AppUser].
  const AppUser({
    required this.id,
    required this.email,
    this.displayName,
  });

  /// Returns an empty/anonymous user — useful in tests.
  factory AppUser.empty() => const AppUser(id: '', email: '');

  /// Unique identifier (UUID from Supabase Auth).
  final String id;

  /// The user's email address.
  final String email;

  /// Optional display name, set during onboarding.
  final String? displayName;

  /// Returns `true` if the user has no ID (not authenticated).
  bool get isEmpty => id.isEmpty;

  /// Returns `true` if the user has an ID (authenticated).
  bool get isNotEmpty => !isEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppUser &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email;

  @override
  int get hashCode => id.hashCode ^ email.hashCode;

  @override
  String toString() =>
      'AppUser(id: $id, email: $email, displayName: $displayName)';
}
