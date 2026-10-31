// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../../core/clock.dart';
import '../domain/doctor_photo_files.dart';

/// [DoctorPhotoFiles] under the app's documents folder, in the same folder the
/// tablet's own photo picker uses.
final class AppDoctorPhotoFiles implements DoctorPhotoFiles {
  AppDoctorPhotoFiles(this._clock);

  final Clock _clock;

  static const _folder = 'doctor_photos';

  @override
  Future<String> save(List<int> bytes) async {
    final documents = await getApplicationDocumentsDirectory();
    final folder = await Directory('${documents.path}/$_folder').create();
    // A new name each time, so no cache shows an old photo.
    final path = '${folder.path}/${_clock().millisecondsSinceEpoch}.jpg';
    await File(path).writeAsBytes(bytes, flush: true);
    return path;
  }

  @override
  Future<List<int>?> read(String path) async {
    final file = File(path);
    return await file.exists() ? file.readAsBytes() : null;
  }

  @override
  Future<int> versionOf(String path) async {
    final file = File(path);
    if (!await file.exists()) return 0;
    final millis = (await file.lastModified()).millisecondsSinceEpoch;
    return millis == 0 ? 1 : millis;
  }

  @override
  Future<void> remove(String path) async {
    final file = File(path);
    if (await file.exists()) await file.delete();
  }
}
