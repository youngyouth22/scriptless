/// Predefined learning and improvement objectives available in the
/// persona selection step.
abstract final class PersonaObjective {
  /// Giving difficult feedback.
  static const String difficultFeedback = 'Donner un feedback difficile';

  /// Saying no without guilt.
  static const String sayNoWithoutGuilt = 'Dire non sans culpabiliser';

  /// Managing team conflicts.
  static const String manageTeamConflict = "Gérer un conflit d'équipe";

  /// Salary negotiation.
  static const String negotiateSalary = 'Négocier mon salaire';

  /// Announcing change.
  static const String announceChange = 'Annoncer un changement';

  /// Setting boundaries.
  static const String setBoundaries = 'Poser des limites';

  /// All predefined objectives in standard display order.
  static const List<String> defaultObjectives = [
    difficultFeedback,
    sayNoWithoutGuilt,
    manageTeamConflict,
    negotiateSalary,
    announceChange,
    setBoundaries,
  ];
}
