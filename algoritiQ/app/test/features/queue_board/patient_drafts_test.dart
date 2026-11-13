// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:algoritiq_app/features/queue_board/application/patient_drafts.dart';
import 'package:algoritiq_app/features/queue_board/domain/board_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ProviderContainer container;
  late PatientDrafts store;
  var typed = const PatientDraft();

  PatientDraftSync sync(
    String key, {
    PatientDraft baseline = const PatientDraft(),
  }) => PatientDraftSync(
    store: store,
    key: key,
    baseline: baseline,
    snapshot: () => typed,
  );

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
    // Keep the provider alive while the test runs.
    container.listen(patientDraftsProvider, (_, _) {});
    store = container.read(patientDraftsProvider.notifier);
    typed = const PatientDraft();
  });

  test('should keep what was typed as a draft', () {
    final form = sync('page-new');

    typed = const PatientDraft(name: 'করিম', phone: '017');
    form.persist();

    final draft = sync('page-new').restore();
    expect(draft?.name, 'করিম');
    expect(draft?.phone, '017');
  });

  test('should hold no draft while the form is as it was saved', () {
    const saved = PatientDraft(name: 'করিম', phone: '017');
    final form = sync('edit:p1', baseline: saved);

    typed = const PatientDraft(name: 'করিমা', phone: '017');
    form.persist();
    expect(form.restore(), isNotNull);

    typed = saved;
    form.persist();
    expect(form.restore(), isNull);
  });

  test('should drop the draft when it is discarded', () {
    final form = sync('page-new');
    typed = const PatientDraft(gender: PatientGender.female);
    form.persist();

    form.discard();

    expect(form.restore(), isNull);
  });

  test('should keep each form apart', () {
    typed = const PatientDraft(name: 'এক');
    sync('edit:p1').persist();
    typed = const PatientDraft(name: 'দুই');
    sync('edit:p2').persist();

    expect(store.of('edit:p1')?.name, 'এক');
    expect(store.of('edit:p2')?.name, 'দুই');
  });
}
