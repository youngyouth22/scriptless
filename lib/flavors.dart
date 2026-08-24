
/// Represents different flavors of the application.
enum Flavor {
  /// Development flavor.
  dev,

  /// Staging flavor.
  staging,

  /// Production flavor.
  prod,
}

/// Holds global, flavor-specific configuration.
class F {
  /// The current flavor.
  static late final Flavor appFlavor;

  /// Gets the flavor name.
  static String get name => appFlavor.name;

  /// Gets the display title.
  static String get title {
    switch (appFlavor) {
      case Flavor.dev:
        return 'Scriptless Dev';
      case Flavor.staging:
        return 'Scriptless Staging';
      case Flavor.prod:
        return 'Scriptless';
    }
  }
}
