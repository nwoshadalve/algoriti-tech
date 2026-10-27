import 'package:flutter/material.dart';

import '../domain/doctor.dart';

/// The text controllers behind the profile form.
class ProfileControllers {
  final name = TextEditingController();
  final designation = TextEditingController();
  final workplace = TextEditingController();
  final registration = TextEditingController();
  final specialty = TextEditingController();

  void fill(Doctor doctor) {
    name.text = doctor.name;
    designation.text = doctor.designation ?? '';
    workplace.text = doctor.workplace ?? '';
    registration.text = doctor.registrationNumber ?? '';
    specialty.text = doctor.specialty ?? '';
  }

  void dispose() {
    name.dispose();
    designation.dispose();
    workplace.dispose();
    registration.dispose();
    specialty.dispose();
  }
}
