// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:algoritiq_app/features/clinic/domain/photo_store.dart';

/// Hands out a preset photo path instead of opening the system picker.
class FakePhotoStore implements PhotoStore {
  FakePhotoStore({this.next, this.fails = false});

  /// What the next [pick] returns; null behaves like the user cancelling.
  String? next;
  final bool fails;
  final removed = <String>[];

  @override
  Future<String?> pick(PhotoSource source) async {
    if (fails) throw const FormatException('unreadable photo');
    return next;
  }

  @override
  Future<void> remove(String path) async => removed.add(path);
}
