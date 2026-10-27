/// A doctor who sees patients. A doctor license covers exactly one.
///
/// Everything except [name] is optional; the TV shows what was filled in.
final class Doctor {
  const Doctor({
    required this.id,
    required this.name,
    this.degrees = const [],
    this.designation,
    this.workplace,
    this.registrationNumber,
    this.specialty,
    this.photoPath,
  });

  final String id;

  /// With title, as it should appear (e.g. on the TV).
  final String name;

  /// In display order.
  final List<String> degrees;
  final String? designation;
  final String? workplace;

  /// Medical council registration number (BMDC in Bangladesh).
  final String? registrationNumber;

  /// Areas of expertise.
  final String? specialty;

  /// Photo kept in the app's private storage.
  final String? photoPath;
}
