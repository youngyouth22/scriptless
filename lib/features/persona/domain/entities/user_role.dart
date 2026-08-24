/// Represents the user's management role in the organization.
enum UserRole {
  /// First-time manager ("Premier manager").
  firstTimeManager('first_time_manager', 'Premier manager'),

  /// Team manager ("Manager d\'équipe").
  teamManager('team_manager', "Manager d'équipe"),

  /// Cross-functional manager ("Manager transverse").
  crossFunctionalManager(
    'cross_functional_manager',
    'Manager transverse',
  ),

  /// Director / VP ("Directeur / VP").
  director('director', 'Directeur / VP');

  const UserRole(this.dbValue, this.label);

  /// The database enum string representation.
  final String dbValue;

  /// Human-readable display label in French.
  final String label;

  /// Parses a database enum string value into a [UserRole], or returns null.
  static UserRole? fromDbValue(String? value) {
    if (value == null) return null;
    for (final role in UserRole.values) {
      if (role.dbValue == value) return role;
    }
    return null;
  }
}
