/// Result of a setup action. Expected failures are values, not exceptions.
enum SetupOutcome {
  saved,

  /// A required field is blank (doctor: name, designation, specialty, degree;
  /// chamber: name, address, phone). The screen marks the blank ones.
  fieldsMissing,

  /// The license allows no more chambers.
  limitReached,

  /// Tried to continue without any chamber.
  noChambers,

  /// Storage failed; the user can retry.
  failed,
}
