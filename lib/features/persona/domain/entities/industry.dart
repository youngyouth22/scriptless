/// Represents the industry sector the user works in.
enum Industry {
  /// Technology sector.
  tech('tech', 'Tech'),

  /// Retail sector.
  retail('retail', 'Retail'),

  /// Finance and banking sector.
  finance('finance', 'Finance'),

  /// Healthcare and medical sector.
  healthcare('healthcare', 'Healthcare'),

  /// Consulting and professional services.
  consulting('consulting', 'Consulting'),

  /// Education and training sector.
  education('education', 'Education'),

  /// Manufacturing and industrial sector.
  manufacturing('manufacturing', 'Manufacturing'),

  /// Other sector.
  other('other', 'Other');

  const Industry(this.dbValue, this.label);

  /// The database enum string representation.
  final String dbValue;

  /// Human-readable display label.
  final String label;

  /// Parses a database enum string value into an [Industry], or returns null.
  static Industry? fromDbValue(String? value) {
    if (value == null) return null;
    for (final ind in Industry.values) {
      if (ind.dbValue == value) return ind;
    }
    return null;
  }
}
