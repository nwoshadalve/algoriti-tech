/// Where a photo comes from.
enum PhotoSource { gallery, camera }

/// Picks a photo and keeps a copy in the app's private storage, so it works
/// offline and survives the original being deleted.
abstract interface class PhotoStore {
  /// Lets the user choose a photo. Returns the path of the saved copy, or
  /// null if they cancelled. Throws if the photo can't be read or saved.
  Future<String?> pick(PhotoSource source);

  /// Deletes a saved copy. Missing files are ignored.
  Future<void> remove(String path);
}
