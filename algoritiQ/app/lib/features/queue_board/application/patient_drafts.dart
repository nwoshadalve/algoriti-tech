// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../access/application/tablet_session.dart';
import '../domain/board_models.dart';

/// What was typed in a patient form and not saved yet.
final class PatientDraft {
  const PatientDraft({
    this.name = '',
    this.phone = '',
    this.age = '',
    this.gender,
    this.hasPaperFile = false,
    this.queueTypeId,
    this.fee = '',
    this.isFree = false,
  });

  final String name;
  final String phone;
  final String age;
  final PatientGender? gender;
  final bool hasPaperFile;
  final String? queueTypeId;
  final String fee;
  final bool isFree;

  bool sameAs(PatientDraft other) =>
      name.trim() == other.name.trim() &&
      phone.trim() == other.phone.trim() &&
      age.trim() == other.age.trim() &&
      gender == other.gender &&
      hasPaperFile == other.hasPaperFile &&
      queueTypeId == other.queueTypeId &&
      fee.trim() == other.fee.trim() &&
      isFree == other.isFree;
}

/// Patient forms that were left before saving, by form: `desk-new:<chamber>`,
/// `page-new` and `edit:<patientId>`. Kept in memory while the person is
/// signed in, so a form closed by mistake (or left for another screen) comes
/// back as it was, until it is saved or discarded.
final patientDraftsProvider =
    NotifierProvider<PatientDrafts, Map<String, PatientDraft>>(
      PatientDrafts.new,
    );

class PatientDrafts extends Notifier<Map<String, PatientDraft>> {
  @override
  Map<String, PatientDraft> build() {
    // Another person signing in starts with no drafts.
    ref.watch(tabletSessionProvider.select((s) => s?.account.id));
    return const {};
  }

  PatientDraft? of(String key) => state[key];

  void put(String key, PatientDraft draft) {
    state = {...state, key: draft};
  }

  void clear(String key) {
    if (!state.containsKey(key)) return;
    state = {...state}..remove(key);
  }
}

/// Keeps one form's draft up to date as it is typed. [baseline] is the form
/// as it opens without a draft: empty for a new patient, the saved values for
/// an edit. A form equal to its baseline has no draft.
final class PatientDraftSync {
  PatientDraftSync({
    required this.store,
    required this.key,
    required this.baseline,
    required this.snapshot,
  });

  final PatientDrafts store;
  final String key;
  final PatientDraft baseline;
  final PatientDraft Function() snapshot;

  PatientDraft? restore() => store.of(key);

  void persist() {
    final now = snapshot();
    if (now.sameAs(baseline)) {
      store.clear(key);
    } else {
      store.put(key, now);
    }
  }

  void discard() => store.clear(key);
}
