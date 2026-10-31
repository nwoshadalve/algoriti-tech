// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
/// Where the doctor's photo lives. The web app uploads the bytes; the tablet
/// keeps them in its private storage, next to the copy its own picker makes.
abstract interface class DoctorPhotoFiles {
  /// Keeps [bytes] and returns the path of the copy.
  Future<String> save(List<int> bytes);

  /// The bytes at [path], or null when the file is gone.
  Future<List<int>?> read(String path);

  /// Changes whenever the photo at [path] does, so clients know to fetch it
  /// again. Never 0 for a photo that exists.
  Future<int> versionOf(String path);

  /// Deletes the copy. A missing file is ignored.
  Future<void> remove(String path);
}
