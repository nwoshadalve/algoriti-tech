import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/clock.dart';
import '../domain/photo_store.dart';

/// [PhotoStore] backed by the system photo picker / camera. Photos are scaled
/// down (a TV card never needs more) and copied under the app's documents.
final class ImagePickerPhotoStore implements PhotoStore {
  ImagePickerPhotoStore(this._clock);

  final Clock _clock;
  final _picker = ImagePicker();

  static const _folder = 'doctor_photos';
  static const _maxSide = 1024.0;
  static const _quality = 85;

  @override
  Future<String?> pick(PhotoSource source) async {
    final picked = await _picker.pickImage(
      source: switch (source) {
        PhotoSource.gallery => ImageSource.gallery,
        PhotoSource.camera => ImageSource.camera,
      },
      maxWidth: _maxSide,
      maxHeight: _maxSide,
      imageQuality: _quality,
    );
    if (picked == null) return null;

    final documents = await getApplicationDocumentsDirectory();
    final folder = await Directory('${documents.path}/$_folder').create();
    // A new name each time, so the image cache never shows an old photo.
    final target = '${folder.path}/${_clock().millisecondsSinceEpoch}.jpg';
    await File(picked.path).copy(target);
    return target;
  }

  @override
  Future<void> remove(String path) async {
    final file = File(path);
    if (await file.exists()) await file.delete();
  }
}
