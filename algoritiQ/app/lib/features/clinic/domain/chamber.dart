/// A place where a doctor sees patients (clinic room, hospital wing).
/// Belongs to one doctor ([doctorId]).
final class Chamber {
  const Chamber({
    required this.id,
    required this.doctorId,
    required this.name,
    this.location,
    this.phone,
  });

  final String id;

  /// The doctor this chamber belongs to.
  final String doctorId;
  final String name;
  final String? location;

  /// Serial-booking or contact number patients call.
  final String? phone;
}
