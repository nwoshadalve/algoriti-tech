/// Where first-time setup stands. Saved, so a restart resumes the same step.
enum SetupStage {
  /// Waiting for the doctor's profile.
  profile,

  /// Waiting for at least one chamber.
  chambers,

  /// Setup is complete; the summary has not been acknowledged yet.
  ready,

  /// Setup finished. The app opens straight to home.
  done,
}
