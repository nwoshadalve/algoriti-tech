/// What the user typed for a doctor, before it is cleaned and saved.
final class DoctorDraft {
  const DoctorDraft({
    required this.name,
    this.degrees = const [],
    this.designation,
    this.workplace,
    this.registrationNumber,
    this.specialty,
    this.photoPath,
  });

  final String name;
  final List<String> degrees;
  final String? designation;
  final String? workplace;
  final String? registrationNumber;
  final String? specialty;
  final String? photoPath;
}
