// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:algoritiq_app/features/clinic/domain/chamber.dart';
import 'package:algoritiq_app/features/clinic/domain/clinic_repository.dart';
import 'package:algoritiq_app/features/clinic/domain/doctor.dart';

const testDoctor = Doctor(id: 'd1', name: 'ডাঃ মোঃ রহিম উদ্দিন');
const testChamber = Chamber(
  id: 'c1',
  doctorId: 'd1',
  name: 'আল-খিদমাহ্ মেডিকেল সার্ভিসেস, চাঁদপুর',
);

/// Only the two lists the token needs; anything else is a mistake in the test.
class FakeClinic implements ClinicRepository {
  FakeClinic({
    this.doctors = const [testDoctor],
    this.chambers = const [testChamber],
  });

  final List<Doctor> doctors;
  final List<Chamber> chambers;

  @override
  Stream<List<Doctor>> watchDoctors() => Stream.value(doctors);

  @override
  Stream<List<Chamber>> watchChambers() => Stream.value(chambers);

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}
