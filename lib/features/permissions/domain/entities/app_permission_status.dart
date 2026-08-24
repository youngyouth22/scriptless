/// Represents the status of an application permission in the domain layer.
enum AppPermissionStatus {
  /// The user has granted access to the requested feature.
  granted,

  /// The user has denied access to the requested feature.
  denied,

  /// The user has permanently denied access to the requested feature.
  /// User must manually enable the permission via device Settings.
  permanentlyDenied,

  /// The OS has restricted access to the feature (e.g., parental controls).
  restricted,

  /// The user has granted limited access (e.g., partial photo access on iOS).
  limited,

  /// The application is provisionally authorized (e.g., non-interruptive
  /// notifications on iOS).
  provisional,

  /// The status could not be determined.
  unknown;

  /// Whether the permission has been granted or provisionally authorized.
  bool get isGranted =>
      this == AppPermissionStatus.granted ||
      this == AppPermissionStatus.limited ||
      this == AppPermissionStatus.provisional;

  /// Whether the permission is denied and can still be re-requested via
  /// system dialog.
  bool get isDenied => this == AppPermissionStatus.denied;

  /// Whether the user has chosen to permanently deny permission.
  bool get isPermanentlyDenied =>
      this == AppPermissionStatus.permanentlyDenied;

  /// Whether the permission is restricted by parental controls or device
  /// policy.
  bool get isRestricted => this == AppPermissionStatus.restricted;
}
