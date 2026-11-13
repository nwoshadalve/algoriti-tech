// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'board_models.dart';

/// What the patient list can be ordered by. [registered] is the default.
enum PatientSort { registered, name, id, phone, visits, lastVisit }

/// Which patients to list: searched, filtered and ordered by the database.
final class PatientQuery {
  const PatientQuery({
    this.search = '',
    this.gender,
    this.genderUnset = false,
    this.paperFileOnly = false,
    this.sort = PatientSort.registered,
    this.ascending = false,
    this.limit = 30,
    this.offset = 0,
  });

  /// Name (Bengali or English), patient ID or phone; plain text.
  final String search;

  /// Only this gender; [genderUnset] asks for patients with none instead.
  final PatientGender? gender;
  final bool genderUnset;
  final bool paperFileOnly;
  final PatientSort sort;
  final bool ascending;
  final int limit;
  final int offset;

  bool get hasFilters =>
      search.trim().isNotEmpty ||
      gender != null ||
      genderUnset ||
      paperFileOnly;

  PatientQuery copyWith({
    String? search,
    PatientGender? gender,
    bool clearGender = false,
    bool? genderUnset,
    bool? paperFileOnly,
    PatientSort? sort,
    bool? ascending,
    int? limit,
    int? offset,
  }) => PatientQuery(
    search: search ?? this.search,
    gender: clearGender ? null : (gender ?? this.gender),
    genderUnset: genderUnset ?? this.genderUnset,
    paperFileOnly: paperFileOnly ?? this.paperFileOnly,
    sort: sort ?? this.sort,
    ascending: ascending ?? this.ascending,
    limit: limit ?? this.limit,
    offset: offset ?? this.offset,
  );
}

/// One page of the patient list and how many patients match in all.
final class PatientPage {
  const PatientPage({
    required this.items,
    required this.total,
    required this.registeredTotal,
  });

  static const empty = PatientPage(items: [], total: 0, registeredTotal: 0);

  final List<PatientSummary> items;

  /// Patients matching the search and filters.
  final int total;

  /// Every patient registered, whatever the search and filters.
  final int registeredTotal;
}
