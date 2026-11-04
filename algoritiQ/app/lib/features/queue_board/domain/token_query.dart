// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'board_models.dart';

/// What the session table can be ordered by. [issued] is the default and has
/// no column heading of its own.
enum TokenSort { issued, id, name, serial, queue, wait, status }

/// One request for a page of the session table: what to match, how to order
/// it and which slice to return. Sorting, filtering and paging are done by
/// the database, never by the screen.
final class TokenQuery {
  const TokenQuery({
    this.search = '',
    this.status,
    this.queueTypeId,
    this.notPrintedOnly = false,
    this.sort = TokenSort.issued,
    this.ascending = false,
    this.limit = 30,
    this.offset = 0,
  });

  /// Name (Bengali or English), patient ID, serial or phone; plain text.
  final String search;
  final TokenStatus? status;
  final String? queueTypeId;
  final bool notPrintedOnly;
  final TokenSort sort;
  final bool ascending;
  final int limit;
  final int offset;

  /// Anything narrowing the list, so the screen can offer "clear filters".
  bool get hasFilters =>
      search.trim().isNotEmpty ||
      status != null ||
      queueTypeId != null ||
      notPrintedOnly;

  TokenQuery copyWith({
    String? search,
    TokenStatus? status,
    bool clearStatus = false,
    String? queueTypeId,
    bool clearQueue = false,
    bool? notPrintedOnly,
    TokenSort? sort,
    bool? ascending,
    int? limit,
    int? offset,
  }) => TokenQuery(
    search: search ?? this.search,
    status: clearStatus ? null : (status ?? this.status),
    queueTypeId: clearQueue ? null : (queueTypeId ?? this.queueTypeId),
    notPrintedOnly: notPrintedOnly ?? this.notPrintedOnly,
    sort: sort ?? this.sort,
    ascending: ascending ?? this.ascending,
    limit: limit ?? this.limit,
    offset: offset ?? this.offset,
  );
}
