// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:algoritiq_app/api/local_api_server.dart';
import 'package:algoritiq_app/features/access/application/user_management_service.dart';
import 'package:algoritiq_app/features/clinic/application/doctor_profile_service.dart';
import 'package:algoritiq_app/features/clinic/data/drift_clinic_repository.dart';
import 'package:algoritiq_app/features/clinic/domain/doctor.dart';
import 'package:algoritiq_app/features/clinic/domain/doctor_photo_files.dart';
import 'package:algoritiq_app/features/licensing/domain/license_core.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter_test/flutter_test.dart';

import '../support/access_kit.dart';

typedef Reply = ({
  int status,
  Map<String, Object?> json,
  List<int> bytes,
  String? type,
});

const _jpeg = [0xFF, 0xD8, 0xFF, 0xE0, 1, 2, 3];

/// Photos kept in memory, with a version that grows on each save.
final class _MemoryPhotos implements DoctorPhotoFiles {
  final files = <String, List<int>>{};
  var _next = 0;

  @override
  Future<String> save(List<int> bytes) async {
    final path = 'photo-${++_next}';
    files[path] = bytes;
    return path;
  }

  @override
  Future<List<int>?> read(String path) async => files[path];

  @override
  Future<int> versionOf(String path) async =>
      files.containsKey(path) ? 1000 + int.parse(path.split('-').last) : 0;

  @override
  Future<void> remove(String path) async => files.remove(path);
}

LicensePayload _license(LicenseType type) => LicensePayload(
  keyId: 1,
  type: type,
  maxDoctors: type == LicenseType.doctor ? 1 : 5,
  maxChambers: type == LicenseType.chamber ? 1 : 3,
  issuedDay: 1,
  expiresDay: null,
  device: DeviceCode(Uint8List.fromList([0, 1, 2, 3, 4, 5])),
  licenseId: Uint8List.fromList([1, 2, 3, 4]),
);

void main() {
  late AccessKit kit;
  late LocalApiServer server;
  late HttpClient client;
  late String adminToken;
  late _MemoryPhotos photos;
  late DriftClinicRepository clinic;

  Future<Reply> call(
    String method,
    String path, {
    Map<String, Object?>? json,
    List<int>? bytes,
    String? bearer,
  }) async {
    final request = await client.openUrl(
      method,
      Uri.parse('http://127.0.0.1:${server.port}$path'),
    );
    final who = bearer ?? (path.contains('/auth/') ? null : adminToken);
    if (who != null) request.headers.set('authorization', 'Bearer $who');
    if (json != null) {
      request.headers.set('content-type', 'application/json');
      request.write(jsonEncode(json));
    } else if (bytes != null) {
      request.headers.set('content-type', 'image/jpeg');
      request.add(bytes);
    }
    final response = await request.close();
    final body = <int>[for (final chunk in await response.toList()) ...chunk];
    final isJson = response.headers.contentType?.subType == 'json';
    return (
      status: response.statusCode,
      json: isJson && body.isNotEmpty
          ? jsonDecode(utf8.decode(body)) as Map<String, Object?>
          : <String, Object?>{},
      bytes: body,
      type: response.headers.contentType?.mimeType,
    );
  }

  Future<void> start(LicenseType type, {bool withDoctor = true}) async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    kit = await AccessKit.create();
    clinic = DriftClinicRepository(kit.database, kit.clock);
    photos = _MemoryPhotos();
    final doctor = DoctorProfileService(
      clinic: clinic,
      photos: photos,
      licensePayload: () async => _license(type),
    );
    final users = UserManagementService(
      repository: kit.repository,
      clinic: clinic,
      hasher: kit.hasher,
      clock: kit.clock,
      newId: () => 'u-${DateTime.now().microsecondsSinceEpoch}',
      licensePayload: () async => _license(type),
    );
    server = LocalApiServer(
      access: () async => kit.service,
      users: () async => users,
      doctor: () async => doctor,
    );
    await server.start(port: 0, address: InternetAddress.loopbackIPv4);
    client = HttpClient();
    await kit.registerAdmin();
    if (withDoctor) {
      await clinic.saveProfile(
        const Doctor(
          id: 'd1',
          name: 'Dr. Rahim',
          degrees: ['MBBS'],
          specialty: 'Medicine',
        ),
      );
    }
    final login = await call(
      'POST',
      '/api/v1/auth/login',
      json: {'username': 'owner', 'password': AccessKit.password},
    );
    adminToken = login.json['token']! as String;
  }

  tearDown(() async {
    client.close(force: true);
    await server.stop();
    await kit.close();
  });

  Map<String, Object?> doctor(Reply r) =>
      r.json['doctor']! as Map<String, Object?>;

  group('for a doctor license', () {
    setUp(() => start(LicenseType.doctor));

    test('should tell what the clinic is licensed for', () async {
      final result = await call('GET', '/api/v1/clinic');

      expect(result.json['licenseType'], 'doctor');
    });

    test('should show the doctor', () async {
      final result = await call('GET', '/api/v1/doctor');

      expect(result.status, 200);
      expect(doctor(result)['name'], 'Dr. Rahim');
      expect(doctor(result)['degrees'], ['MBBS']);
      expect(doctor(result)['specialty'], 'Medicine');
      expect(doctor(result)['designation'], '');
      expect(doctor(result)['photoVersion'], 0);
    });

    test(
      'should save the details, trimmed, and keep the setup stage',
      () async {
        final result = await call(
          'PUT',
          '/api/v1/doctor',
          json: {
            'name': '  Prof. Dr. Rahim  ',
            'degrees': ['MBBS', ' FCPS ', ''],
            'designation': 'Professor',
            'workplace': 'City Hospital',
            'registrationNumber': 'A-12345',
            'specialty': '',
          },
        );

        expect(result.status, 200);
        expect(doctor(result)['name'], 'Prof. Dr. Rahim');
        expect(doctor(result)['degrees'], ['MBBS', 'FCPS']);
        final again = await call('GET', '/api/v1/doctor');
        expect(doctor(again)['designation'], 'Professor');
        expect(doctor(again)['registrationNumber'], 'A-12345');
        expect(doctor(again)['specialty'], '');
        expect(await clinic.watchDoctors().first, hasLength(1));
      },
    );

    test(
      'should refuse a missing name, long values and too many degrees',
      () async {
        Future<String> code(Map<String, Object?> body) async =>
            ((await call('PUT', '/api/v1/doctor', json: body)).json['error']!
                    as Map)['code']
                as String;

        expect(await code({'name': '  '}), 'doctor_name_missing');
        expect(await code({'name': 'x' * 121}), 'doctor_too_long');
        expect(
          await code({'name': 'A', 'workplace': 'w' * 201}),
          'doctor_too_long',
        );
        expect(
          await code({
            'name': 'A',
            'degrees': [for (var i = 0; i < 13; i++) 'D$i'],
          }),
          'doctor_too_many_degrees',
        );
      },
    );

    test(
      'should keep, serve and replace the photo, and remove the old file',
      () async {
        expect((await call('GET', '/api/v1/doctor/photo')).status, 404);

        final first = await call('PUT', '/api/v1/doctor/photo', bytes: _jpeg);
        final version = doctor(first)['photoVersion']! as int;
        final served = await call('GET', '/api/v1/doctor/photo');
        final second = await call(
          'PUT',
          '/api/v1/doctor/photo',
          bytes: [..._jpeg, 9],
        );

        expect(version, greaterThan(0));
        expect(served.status, 200);
        expect(served.type, 'image/jpeg');
        expect(served.bytes, _jpeg);
        expect(doctor(second)['photoVersion'], greaterThan(version));
        expect(photos.files, hasLength(1));
      },
    );

    test('should refuse a file that is not a picture, or is too big', () async {
      final bad = await call('PUT', '/api/v1/doctor/photo', bytes: [1, 2, 3]);

      expect(bad.status, 415);
      try {
        final big = await call(
          'PUT',
          '/api/v1/doctor/photo',
          bytes: [..._jpeg, ...List.filled(600 * 1024, 0)],
        );
        expect(big.status, 413);
      } on HttpException {
        // Closed early while uploading: also a refusal.
      }
      expect(photos.files, isEmpty);
    });

    test('should remove the photo', () async {
      await call('PUT', '/api/v1/doctor/photo', bytes: _jpeg);

      final result = await call('DELETE', '/api/v1/doctor/photo');

      expect(doctor(result)['photoVersion'], 0);
      expect(photos.files, isEmpty);
    });

    test('should be for admins only', () async {
      await call(
        'POST',
        '/api/v1/users',
        json: {
          'username': 'desk',
          'firstName': 'Front',
          'lastName': 'Desk',
          'email': 'desk@clinic.test',
          'password': 'a-long-passphrase',
        },
      );
      final login = await call(
        'POST',
        '/api/v1/auth/login',
        json: {'username': 'desk', 'password': 'a-long-passphrase'},
      );
      final token = login.json['token']! as String;

      expect((await call('GET', '/api/v1/doctor', bearer: token)).status, 403);
      expect(
        (await call(
          'PUT',
          '/api/v1/doctor',
          bearer: token,
          json: {'name': 'X'},
        )).status,
        403,
      );
      // Anyone signed in may ask what the clinic is licensed for.
      expect((await call('GET', '/api/v1/clinic', bearer: token)).status, 200);
      expect(
        (await call('GET', '/api/v1/doctor', bearer: 'made-up')).status,
        401,
      );
    });
  });

  group('for a chamber license', () {
    setUp(() => start(LicenseType.chamber));

    test('should have no doctor page', () async {
      final clinicInfo = await call('GET', '/api/v1/clinic');
      final result = await call('GET', '/api/v1/doctor');

      expect(clinicInfo.json['licenseType'], 'chamber');
      expect(result.status, 404);
      expect((result.json['error']! as Map)['code'], 'doctor_unavailable');
      expect(
        (await call('PUT', '/api/v1/doctor', json: {'name': 'X'})).status,
        404,
      );
    });
  });

  group('before the doctor is set up', () {
    setUp(() => start(LicenseType.doctor, withDoctor: false));

    test('should have nothing to edit yet', () async {
      expect((await call('GET', '/api/v1/doctor')).status, 404);
    });
  });
}
