// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/brand_loader.dart';
import '../../../core/widgets/page_header.dart';
import '../../../l10n/app_localizations.dart';
import '../../access/application/tablet_session.dart';
import '../../home/application/receptionist_work.dart';
import '../application/patient_drafts.dart';
import '../application/queue_board_providers.dart';
import '../domain/board_models.dart';
import '../domain/patient_query.dart';
import 'patient_add_dialog.dart';
import 'queue_desk_format.dart';
import 'queue_desk_patient_edit_dialog.dart';

/// The patient list: search, filter and sort, add a patient, edit one.
class PatientsPage extends ConsumerStatefulWidget {
  const PatientsPage({super.key});

  @override
  ConsumerState<PatientsPage> createState() => _PatientsPageState();
}

/// Gender filter choices: everyone, one gender, or nobody stated.
enum _GenderFilter { all, male, female, other, unset }

class _PatientsPageState extends ConsumerState<PatientsPage> {
  static const _pageSize = 30;
  static const _searchPause = Duration(milliseconds: 300);

  final _search = TextEditingController();
  Timer? _pause;
  var _genderFilter = _GenderFilter.all;
  var _sort = PatientSort.registered;
  var _ascending = false;

  final _items = <PatientSummary>[];
  var _total = 0;
  var _registeredTotal = 0;
  final _scroll = ScrollController();
  var _loading = true;
  var _loadingMore = false;
  var _failed = false;
  var _generation = 0;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(_load()));
  }

  @override
  void dispose() {
    _pause?.cancel();
    _search.dispose();
    _scroll.dispose();
    super.dispose();
  }

  /// Reaching the end of the list asks for the next page.
  void _onScroll() {
    if (!_scroll.hasClients || _loading || _loadingMore || _failed) return;
    if (_items.length >= _total) return;
    if (_scroll.position.extentAfter < 240) unawaited(_load(more: true));
  }

  PatientQuery _query({int offset = 0}) => PatientQuery(
    search: _search.text,
    gender: switch (_genderFilter) {
      _GenderFilter.male => PatientGender.male,
      _GenderFilter.female => PatientGender.female,
      _GenderFilter.other => PatientGender.other,
      _ => null,
    },
    genderUnset: _genderFilter == _GenderFilter.unset,
    sort: _sort,
    ascending: _ascending,
    limit: _pageSize,
    offset: offset,
  );

  bool get _hasFilters =>
      _search.text.trim().isNotEmpty || _genderFilter != _GenderFilter.all;

  Future<void> _load({bool more = false}) async {
    final account = ref.read(tabletSessionProvider)?.account;
    if (account == null) return;
    final generation = ++_generation;
    setState(() {
      if (more) {
        _loadingMore = true;
      } else {
        _loading = _items.isEmpty;
      }
      _failed = false;
    });
    try {
      final page = await ref
          .read(queueBoardServiceProvider)
          .listPatients(account, _query(offset: more ? _items.length : 0));
      if (!mounted || generation != _generation) return;
      setState(() {
        if (!more) _items.clear();
        _items.addAll(page.items);
        _total = page.total;
        _registeredTotal = page.registeredTotal;
        _loading = false;
        _loadingMore = false;
      });
    } on Object {
      if (!mounted || generation != _generation) return;
      setState(() {
        _loading = false;
        _loadingMore = false;
        _failed = true;
      });
    }
  }

  void _reload() => unawaited(_load());

  void _onSearch(String _) {
    _pause?.cancel();
    setState(() {});
    _pause = Timer(_searchPause, _reload);
  }

  void _clearFilters() {
    _search.clear();
    setState(() {
      _genderFilter = _GenderFilter.all;
    });
    _reload();
  }

  String? get _chamberId {
    final work = ref.read(receptionistWorkProvider);
    if (work is! ReceptionistWorkReady) return null;
    return work.selected.deskChamberId ?? work.selected.id;
  }

  Future<void> _add() async {
    final chamberId = _chamberId;
    if (chamberId == null) return;
    final saved = await showPatientAddDialog(
      context: context,
      chamberId: chamberId,
    );
    if (saved != null && mounted) _reload();
  }

  Future<void> _edit(PatientSummary patient) async {
    final saved = await showDeskPatientEditDialog(
      context: context,
      patient: patient,
    );
    if (saved == null || !mounted) return;
    setState(() {
      final index = _items.indexWhere((p) => p.id == saved.id);
      if (index >= 0) _items[index] = saved;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final drafts = ref.watch(patientDraftsProvider);
    final canAdd = _chamberId != null;
    final addLabel = drafts.containsKey('page-new')
        ? '${l10n.patientsAdd} · ${l10n.draftBadge}'
        : l10n.patientsAdd;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        Spacing.md,
        Spacing.md,
        Spacing.md,
        Spacing.md + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: l10n.patientsTitle,
            description: l10n.patientsIntro,
            dense: true,
            actions: FilledButton.icon(
              onPressed: canAdd ? () => unawaited(_add()) : null,
              icon: const Icon(Icons.person_add_outlined, size: 18),
              label: Text(addLabel),
            ),
          ),
          if (!_loading && !(_failed && _items.isEmpty)) ...[
            _totals(l10n),
            const SizedBox(height: Spacing.sm),
          ],
          _toolbar(l10n),
          const SizedBox(height: Spacing.sm),
          Expanded(child: _body(l10n, drafts)),
        ],
      ),
    );
  }

  Widget _toolbar(AppLocalizations l10n) {
    final genderLabels = {
      _GenderFilter.all: l10n.patientsGenderAll,
      _GenderFilter.male: l10n.deskGenderMale,
      _GenderFilter.female: l10n.deskGenderFemale,
      _GenderFilter.other: l10n.deskGenderOther,
      _GenderFilter.unset: l10n.patientsGenderUnset,
    };
    final sortLabels = {
      PatientSort.registered: l10n.patientsSortNewest,
      PatientSort.name: l10n.patientsSortName,
      PatientSort.id: l10n.patientsSortId,
      PatientSort.phone: l10n.patientsSortPhone,
      PatientSort.visits: l10n.patientsSortVisits,
      PatientSort.lastVisit: l10n.patientsSortLastVisit,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _search,
          onChanged: _onSearch,
          autocorrect: false,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            isDense: true,
            hintText: l10n.patientsSearch,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _search.text.isEmpty
                ? null
                : IconButton(
                    tooltip: l10n.deskSearchClear,
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _search.clear();
                      _onSearch('');
                    },
                  ),
          ),
        ),
        const SizedBox(height: Spacing.sm),
        Wrap(
          spacing: Spacing.sm,
          runSpacing: Spacing.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            PopupMenuButton<_GenderFilter>(
              tooltip: l10n.patientsGender,
              onSelected: (v) {
                setState(() => _genderFilter = v);
                _reload();
              },
              itemBuilder: (_) => [
                for (final e in genderLabels.entries)
                  PopupMenuItem(value: e.key, child: Text(e.value)),
              ],
              child: Chip(
                avatar: const Icon(Icons.wc_outlined, size: 18),
                label: Text(genderLabels[_genderFilter]!),
              ),
            ),
            PopupMenuButton<PatientSort>(
              tooltip: l10n.patientsSortOrder,
              onSelected: (v) {
                setState(() {
                  _sort = v;
                  // Names and IDs read best from the start.
                  _ascending = switch (v) {
                    PatientSort.registered ||
                    PatientSort.visits ||
                    PatientSort.lastVisit => false,
                    _ => true,
                  };
                });
                _reload();
              },
              itemBuilder: (_) => [
                for (final e in sortLabels.entries)
                  PopupMenuItem(value: e.key, child: Text(e.value)),
              ],
              child: Chip(
                avatar: const Icon(Icons.sort, size: 18),
                label: Text(sortLabels[_sort]!),
              ),
            ),
            IconButton(
              tooltip: l10n.patientsReverse,
              isSelected: _ascending,
              icon: Icon(
                _ascending ? Icons.arrow_upward : Icons.arrow_downward,
              ),
              onPressed: () {
                setState(() => _ascending = !_ascending);
                _reload();
              },
            ),
            if (_hasFilters)
              TextButton(
                onPressed: _clearFilters,
                child: Text(l10n.patientsClearFilters),
              ),
          ],
        ),
      ],
    );
  }

  Widget _body(AppLocalizations l10n, Map<String, PatientDraft> drafts) {
    if (_loading) return const Center(child: BrandLoader(semanticLabel: ''));
    if (_failed && _items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.patientsLoadFailed),
            const SizedBox(height: Spacing.sm),
            OutlinedButton(onPressed: _reload, child: Text(l10n.retryButton)),
          ],
        ),
      );
    }
    if (_items.isEmpty) {
      return Center(
        child: Text(
          _hasFilters ? l10n.patientsEmptyFiltered : l10n.patientsEmpty,
        ),
      );
    }
    final more = _items.length < _total;
    return ListView.separated(
      controller: _scroll,
      itemCount: _items.length + (more || _failed ? 1 : 0),
      separatorBuilder: (_, _) => const SizedBox(height: Spacing.xs),
      itemBuilder: (context, index) {
        if (index == _items.length) {
          // Scrolling to the end loads the next page by itself; a failed
          // load shows a retry button instead.
          return Align(
            child: _failed && !_loadingMore
                ? OutlinedButton(
                    onPressed: () => unawaited(_load(more: true)),
                    child: Text(l10n.retryButton),
                  )
                : const BrandLoader(semanticLabel: ''),
          );
        }
        final patient = _items[index];
        return _PatientRow(
          patient: patient,
          hasDraft: drafts.containsKey('edit:${patient.id}'),
          onEdit: () => unawaited(_edit(patient)),
        );
      },
    );
  }

  /// How many patients are registered, and how many the list shows now.
  Widget _totals(AppLocalizations l10n) {
    final locale = Locale(l10n.localeName);
    final theme = Theme.of(context);
    Widget stat(IconData icon, String label, int value) => Expanded(
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.md,
            vertical: Spacing.sm,
          ),
          child: Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      queueDeskFormatDigits('$value', locale),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return Row(
      children: [
        stat(Icons.groups_outlined, l10n.patientsTotalLabel, _registeredTotal),
        const SizedBox(width: Spacing.sm),
        stat(Icons.filter_list, l10n.patientsShownLabel, _total),
      ],
    );
  }
}

class _PatientRow extends StatelessWidget {
  const _PatientRow({
    required this.patient,
    required this.hasDraft,
    required this.onEdit,
  });

  final PatientSummary patient;
  final bool hasDraft;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final details = [
      queueDeskFormatDigits(patient.clinicPatientId, Locale(l10n.localeName)),
      queueDeskDisplayPhone(patient.phoneNormalized),
      if (patient.ageLabel != null) '${l10n.patientsAge} ${patient.ageLabel}',
      switch (patient.gender) {
        PatientGender.male => l10n.deskGenderMale,
        PatientGender.female => l10n.deskGenderFemale,
        PatientGender.other => l10n.deskGenderOther,
        _ => null,
      },
      if (patient.hasPaperFile) l10n.patientsPaperOnly,
    ].whereType<String>().where((e) => e.isNotEmpty).join(' · ');
    final locale = Locale(l10n.localeName);
    final lastVisit = patient.lastVisitAt;
    final registered = patient.registeredAt;
    final registeredText = registered == null
        ? ''
        : '${l10n.patientsRegistered} '
              '${DateFormat.yMMMd(l10n.localeName).format(registered.toLocal())}'
              ' · ';
    final visits = lastVisit == null
        ? l10n.patientsNoVisits
        : '${l10n.patientsVisits} '
              '${queueDeskFormatDigits('${patient.visitCount}', locale)}'
              ' · ${l10n.patientsLastVisit} '
              '${DateFormat.yMMMd(l10n.localeName).format(lastVisit.toLocal())}';
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.md,
            vertical: Spacing.sm,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(details, style: muted),
                    const SizedBox(height: Spacing.xs),
                    Row(
                      children: [
                        Icon(
                          Icons.history,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: Spacing.xs),
                        Flexible(
                          child: Text('$registeredText$visits', style: muted),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (hasDraft)
                Padding(
                  padding: const EdgeInsets.only(right: Spacing.sm),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(Radii.field),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.sm,
                        vertical: Spacing.xs,
                      ),
                      child: Text(
                        l10n.draftBadge,
                        style: theme.textTheme.labelSmall,
                      ),
                    ),
                  ),
                ),
              IconButton(
                tooltip: l10n.patientsEdit,
                icon: const Icon(Icons.edit_outlined),
                onPressed: onEdit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
