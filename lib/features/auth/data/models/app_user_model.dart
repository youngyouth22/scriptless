import 'package:scriptless/features/auth/domain/entities/app_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Data model for [AppUser] — lives in the data layer only.
///
/// Maps between Supabase [User] and the domain [AppUser].
class AppUserModel extends AppUser {
  /// Default constructor.
  const AppUserModel({
    required super.id,
    required super.email,
    super.displayName,
  });

  /// Creates an [AppUserModel] from a Supabase [User] object.
  factory AppUserModel.fromSupabaseUser(User user) {
    return AppUserModel(
      id: user.id,
      email: user.email ?? '',
      displayName: user.userMetadata?['display_name'] as String?,
    );
  }

  /// Creates an [AppUserModel] from a JSON map (e.g. PowerSync / local cache).
  factory AppUserModel.fromJson(Map<String, dynamic> json) {
    return AppUserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['display_name'] as String?,
    );
  }

  /// Serializes this model to a JSON map (e.g. for local caching).
  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'display_name': displayName,
  };

  /// Converts the model to the domain entity.
  AppUser toEntity() => AppUser(
    id: id,
    email: email,
    displayName: displayName,
  );
}
