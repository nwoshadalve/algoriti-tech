// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:drift/drift.dart';

@DataClassName('DoctorRow')
class Doctors extends Table {
  TextColumn get id => text()();

  /// Name with title, as the doctor wants it shown (e.g. on the TV).
  TextColumn get name => text()();

  /// Areas of expertise, one free-text line.
  TextColumn get specialty => text().nullable()();

  /// Degrees in display order, as a JSON array of strings.
  TextColumn get degrees => text().withDefault(const Constant('[]'))();

  /// Position, e.g. a professor grade and department.
  TextColumn get designation => text().nullable()();

  /// Hospital or institution the doctor works at.
  TextColumn get workplace => text().nullable()();

  /// Medical council registration number (BMDC in Bangladesh).
  TextColumn get registrationNumber => text().nullable()();

  /// Path of the photo copy kept in the app's private storage.
  TextColumn get photoPath => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('ChamberRow')
class Chambers extends Table {
  TextColumn get id => text()();

  /// The doctor this chamber belongs to (the parent record).
  TextColumn get doctorId => text().references(Doctors, #id)();
  TextColumn get name => text()();
  TextColumn get location => text().nullable()();

  /// Serial-booking or contact number patients call.
  TextColumn get phone => text().nullable()();

  /// UTC epoch milliseconds; keeps chambers in the order they were added.
  IntColumn get createdAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Small key/value store for app state that must survive restarts.
@DataClassName('SettingRow')
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

/// People who can sign in. Never deleted (audit); `status` deactivates.
@DataClassName('UserRow')
class Users extends Table {
  TextColumn get id => text()();
  TextColumn get username => text().unique()();
  TextColumn get displayName => text()();
  TextColumn get email => text().withDefault(const Constant(''))();
  TextColumn get firstName => text().withDefault(const Constant(''))();
  TextColumn get lastName => text().withDefault(const Constant(''))();
  TextColumn get phone => text().withDefault(const Constant(''))();

  /// Profile picture (a small JPEG, PNG or WebP), if one was uploaded.
  BlobColumn get photo => blob().nullable()();

  /// UTC epoch milliseconds of the last photo change; 0 when there is none.
  /// Clients use it to know when to fetch the picture again.
  IntColumn get photoVersion => integer().withDefault(const Constant(0))();
  TextColumn get role => text()();

  /// Self-describing slow hash; the password itself is never stored.
  TextColumn get passwordHash => text()();
  TextColumn get status => text().withDefault(const Constant('active'))();

  /// UTC epoch milliseconds.
  IntColumn get createdAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Which chambers (doctor licence) or doctors (chamber licence) a receptionist
/// may work on.
@DataClassName('UserScopeAssignmentRow')
class UserScopeAssignments extends Table {
  TextColumn get userId => text().references(Users, #id)();
  TextColumn get scopeId => text()();

  @override
  Set<Column<Object>> get primaryKey => {userId, scopeId};
}

/// Sign-in sessions. Only a hash of the token is kept.
@DataClassName('AuthSessionRow')
class AuthSessions extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().references(Users, #id)();
  TextColumn get tokenHash => text().unique()();
  IntColumn get createdAt => integer()();
  IntColumn get expiresAt => integer()();
  BoolColumn get revoked => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// A browser that may sign in with a PIN. The PIN means something only
/// together with the secret kept in that browser (`tokenHash` is a hash of it),
/// so a stolen PIN alone opens nothing. Both are stored only as hashes.
@DataClassName('PinDeviceRow')
class PinDevices extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().references(Users, #id)();
  TextColumn get tokenHash => text().unique()();
  TextColumn get pinHash => text()();

  /// Which browser, for the person to recognise in their list.
  TextColumn get label => text().withDefault(const Constant(''))();
  IntColumn get createdAt => integer()();

  /// UTC epoch milliseconds of the last PIN sign-in; 0 when never.
  IntColumn get lastUsedAt => integer().withDefault(const Constant(0))();

  /// Wrong PINs in a row. Reaching the limit removes the device.
  IntColumn get failures => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Append-only, hash-chained trail of who did what.
@DataClassName('AuditEntryRow')
class AuditEntries extends Table {
  IntColumn get seq => integer().autoIncrement()();
  IntColumn get at => integer()();
  TextColumn get actorId => text().nullable()();
  TextColumn get action => text()();
  TextColumn get detail => text().nullable()();
  TextColumn get prevHash => text()();
  TextColumn get hash => text()();
}
