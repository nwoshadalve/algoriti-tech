// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $DoctorsTable extends Doctors with TableInfo<$DoctorsTable, DoctorRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DoctorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _specialtyMeta = const VerificationMeta(
    'specialty',
  );
  @override
  late final GeneratedColumn<String> specialty = GeneratedColumn<String>(
    'specialty',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _degreesMeta = const VerificationMeta(
    'degrees',
  );
  @override
  late final GeneratedColumn<String> degrees = GeneratedColumn<String>(
    'degrees',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _designationMeta = const VerificationMeta(
    'designation',
  );
  @override
  late final GeneratedColumn<String> designation = GeneratedColumn<String>(
    'designation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _workplaceMeta = const VerificationMeta(
    'workplace',
  );
  @override
  late final GeneratedColumn<String> workplace = GeneratedColumn<String>(
    'workplace',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _registrationNumberMeta =
      const VerificationMeta('registrationNumber');
  @override
  late final GeneratedColumn<String> registrationNumber =
      GeneratedColumn<String>(
        'registration_number',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _photoPathMeta = const VerificationMeta(
    'photoPath',
  );
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
    'photo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    specialty,
    degrees,
    designation,
    workplace,
    registrationNumber,
    photoPath,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'doctors';
  @override
  VerificationContext validateIntegrity(
    Insertable<DoctorRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('specialty')) {
      context.handle(
        _specialtyMeta,
        specialty.isAcceptableOrUnknown(data['specialty']!, _specialtyMeta),
      );
    }
    if (data.containsKey('degrees')) {
      context.handle(
        _degreesMeta,
        degrees.isAcceptableOrUnknown(data['degrees']!, _degreesMeta),
      );
    }
    if (data.containsKey('designation')) {
      context.handle(
        _designationMeta,
        designation.isAcceptableOrUnknown(
          data['designation']!,
          _designationMeta,
        ),
      );
    }
    if (data.containsKey('workplace')) {
      context.handle(
        _workplaceMeta,
        workplace.isAcceptableOrUnknown(data['workplace']!, _workplaceMeta),
      );
    }
    if (data.containsKey('registration_number')) {
      context.handle(
        _registrationNumberMeta,
        registrationNumber.isAcceptableOrUnknown(
          data['registration_number']!,
          _registrationNumberMeta,
        ),
      );
    }
    if (data.containsKey('photo_path')) {
      context.handle(
        _photoPathMeta,
        photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DoctorRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DoctorRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      specialty: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}specialty'],
      ),
      degrees: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}degrees'],
      )!,
      designation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}designation'],
      ),
      workplace: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workplace'],
      ),
      registrationNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}registration_number'],
      ),
      photoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_path'],
      ),
    );
  }

  @override
  $DoctorsTable createAlias(String alias) {
    return $DoctorsTable(attachedDatabase, alias);
  }
}

class DoctorRow extends DataClass implements Insertable<DoctorRow> {
  final String id;

  /// Name with title, as the doctor wants it shown (e.g. on the TV).
  final String name;

  /// Areas of expertise, one free-text line.
  final String? specialty;

  /// Degrees in display order, as a JSON array of strings.
  final String degrees;

  /// Position, e.g. a professor grade and department.
  final String? designation;

  /// Hospital or institution the doctor works at.
  final String? workplace;

  /// Medical council registration number (BMDC in Bangladesh).
  final String? registrationNumber;

  /// Path of the photo copy kept in the app's private storage.
  final String? photoPath;
  const DoctorRow({
    required this.id,
    required this.name,
    this.specialty,
    required this.degrees,
    this.designation,
    this.workplace,
    this.registrationNumber,
    this.photoPath,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || specialty != null) {
      map['specialty'] = Variable<String>(specialty);
    }
    map['degrees'] = Variable<String>(degrees);
    if (!nullToAbsent || designation != null) {
      map['designation'] = Variable<String>(designation);
    }
    if (!nullToAbsent || workplace != null) {
      map['workplace'] = Variable<String>(workplace);
    }
    if (!nullToAbsent || registrationNumber != null) {
      map['registration_number'] = Variable<String>(registrationNumber);
    }
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    return map;
  }

  DoctorsCompanion toCompanion(bool nullToAbsent) {
    return DoctorsCompanion(
      id: Value(id),
      name: Value(name),
      specialty: specialty == null && nullToAbsent
          ? const Value.absent()
          : Value(specialty),
      degrees: Value(degrees),
      designation: designation == null && nullToAbsent
          ? const Value.absent()
          : Value(designation),
      workplace: workplace == null && nullToAbsent
          ? const Value.absent()
          : Value(workplace),
      registrationNumber: registrationNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(registrationNumber),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
    );
  }

  factory DoctorRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DoctorRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      specialty: serializer.fromJson<String?>(json['specialty']),
      degrees: serializer.fromJson<String>(json['degrees']),
      designation: serializer.fromJson<String?>(json['designation']),
      workplace: serializer.fromJson<String?>(json['workplace']),
      registrationNumber: serializer.fromJson<String?>(
        json['registrationNumber'],
      ),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'specialty': serializer.toJson<String?>(specialty),
      'degrees': serializer.toJson<String>(degrees),
      'designation': serializer.toJson<String?>(designation),
      'workplace': serializer.toJson<String?>(workplace),
      'registrationNumber': serializer.toJson<String?>(registrationNumber),
      'photoPath': serializer.toJson<String?>(photoPath),
    };
  }

  DoctorRow copyWith({
    String? id,
    String? name,
    Value<String?> specialty = const Value.absent(),
    String? degrees,
    Value<String?> designation = const Value.absent(),
    Value<String?> workplace = const Value.absent(),
    Value<String?> registrationNumber = const Value.absent(),
    Value<String?> photoPath = const Value.absent(),
  }) => DoctorRow(
    id: id ?? this.id,
    name: name ?? this.name,
    specialty: specialty.present ? specialty.value : this.specialty,
    degrees: degrees ?? this.degrees,
    designation: designation.present ? designation.value : this.designation,
    workplace: workplace.present ? workplace.value : this.workplace,
    registrationNumber: registrationNumber.present
        ? registrationNumber.value
        : this.registrationNumber,
    photoPath: photoPath.present ? photoPath.value : this.photoPath,
  );
  DoctorRow copyWithCompanion(DoctorsCompanion data) {
    return DoctorRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      specialty: data.specialty.present ? data.specialty.value : this.specialty,
      degrees: data.degrees.present ? data.degrees.value : this.degrees,
      designation: data.designation.present
          ? data.designation.value
          : this.designation,
      workplace: data.workplace.present ? data.workplace.value : this.workplace,
      registrationNumber: data.registrationNumber.present
          ? data.registrationNumber.value
          : this.registrationNumber,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DoctorRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('specialty: $specialty, ')
          ..write('degrees: $degrees, ')
          ..write('designation: $designation, ')
          ..write('workplace: $workplace, ')
          ..write('registrationNumber: $registrationNumber, ')
          ..write('photoPath: $photoPath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    specialty,
    degrees,
    designation,
    workplace,
    registrationNumber,
    photoPath,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DoctorRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.specialty == this.specialty &&
          other.degrees == this.degrees &&
          other.designation == this.designation &&
          other.workplace == this.workplace &&
          other.registrationNumber == this.registrationNumber &&
          other.photoPath == this.photoPath);
}

class DoctorsCompanion extends UpdateCompanion<DoctorRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> specialty;
  final Value<String> degrees;
  final Value<String?> designation;
  final Value<String?> workplace;
  final Value<String?> registrationNumber;
  final Value<String?> photoPath;
  final Value<int> rowid;
  const DoctorsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.specialty = const Value.absent(),
    this.degrees = const Value.absent(),
    this.designation = const Value.absent(),
    this.workplace = const Value.absent(),
    this.registrationNumber = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DoctorsCompanion.insert({
    required String id,
    required String name,
    this.specialty = const Value.absent(),
    this.degrees = const Value.absent(),
    this.designation = const Value.absent(),
    this.workplace = const Value.absent(),
    this.registrationNumber = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<DoctorRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? specialty,
    Expression<String>? degrees,
    Expression<String>? designation,
    Expression<String>? workplace,
    Expression<String>? registrationNumber,
    Expression<String>? photoPath,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (specialty != null) 'specialty': specialty,
      if (degrees != null) 'degrees': degrees,
      if (designation != null) 'designation': designation,
      if (workplace != null) 'workplace': workplace,
      if (registrationNumber != null) 'registration_number': registrationNumber,
      if (photoPath != null) 'photo_path': photoPath,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DoctorsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? specialty,
    Value<String>? degrees,
    Value<String?>? designation,
    Value<String?>? workplace,
    Value<String?>? registrationNumber,
    Value<String?>? photoPath,
    Value<int>? rowid,
  }) {
    return DoctorsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      specialty: specialty ?? this.specialty,
      degrees: degrees ?? this.degrees,
      designation: designation ?? this.designation,
      workplace: workplace ?? this.workplace,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      photoPath: photoPath ?? this.photoPath,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (specialty.present) {
      map['specialty'] = Variable<String>(specialty.value);
    }
    if (degrees.present) {
      map['degrees'] = Variable<String>(degrees.value);
    }
    if (designation.present) {
      map['designation'] = Variable<String>(designation.value);
    }
    if (workplace.present) {
      map['workplace'] = Variable<String>(workplace.value);
    }
    if (registrationNumber.present) {
      map['registration_number'] = Variable<String>(registrationNumber.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DoctorsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('specialty: $specialty, ')
          ..write('degrees: $degrees, ')
          ..write('designation: $designation, ')
          ..write('workplace: $workplace, ')
          ..write('registrationNumber: $registrationNumber, ')
          ..write('photoPath: $photoPath, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChambersTable extends Chambers
    with TableInfo<$ChambersTable, ChamberRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChambersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _doctorIdMeta = const VerificationMeta(
    'doctorId',
  );
  @override
  late final GeneratedColumn<String> doctorId = GeneratedColumn<String>(
    'doctor_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES doctors (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    doctorId,
    name,
    location,
    phone,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chambers';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChamberRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('doctor_id')) {
      context.handle(
        _doctorIdMeta,
        doctorId.isAcceptableOrUnknown(data['doctor_id']!, _doctorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_doctorIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChamberRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChamberRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      doctorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}doctor_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ChambersTable createAlias(String alias) {
    return $ChambersTable(attachedDatabase, alias);
  }
}

class ChamberRow extends DataClass implements Insertable<ChamberRow> {
  final String id;

  /// The doctor this chamber belongs to (the parent record).
  final String doctorId;
  final String name;
  final String? location;

  /// Serial-booking or contact number patients call.
  final String? phone;

  /// UTC epoch milliseconds; keeps chambers in the order they were added.
  final int createdAt;
  const ChamberRow({
    required this.id,
    required this.doctorId,
    required this.name,
    this.location,
    this.phone,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['doctor_id'] = Variable<String>(doctorId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  ChambersCompanion toCompanion(bool nullToAbsent) {
    return ChambersCompanion(
      id: Value(id),
      doctorId: Value(doctorId),
      name: Value(name),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      createdAt: Value(createdAt),
    );
  }

  factory ChamberRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChamberRow(
      id: serializer.fromJson<String>(json['id']),
      doctorId: serializer.fromJson<String>(json['doctorId']),
      name: serializer.fromJson<String>(json['name']),
      location: serializer.fromJson<String?>(json['location']),
      phone: serializer.fromJson<String?>(json['phone']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'doctorId': serializer.toJson<String>(doctorId),
      'name': serializer.toJson<String>(name),
      'location': serializer.toJson<String?>(location),
      'phone': serializer.toJson<String?>(phone),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  ChamberRow copyWith({
    String? id,
    String? doctorId,
    String? name,
    Value<String?> location = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    int? createdAt,
  }) => ChamberRow(
    id: id ?? this.id,
    doctorId: doctorId ?? this.doctorId,
    name: name ?? this.name,
    location: location.present ? location.value : this.location,
    phone: phone.present ? phone.value : this.phone,
    createdAt: createdAt ?? this.createdAt,
  );
  ChamberRow copyWithCompanion(ChambersCompanion data) {
    return ChamberRow(
      id: data.id.present ? data.id.value : this.id,
      doctorId: data.doctorId.present ? data.doctorId.value : this.doctorId,
      name: data.name.present ? data.name.value : this.name,
      location: data.location.present ? data.location.value : this.location,
      phone: data.phone.present ? data.phone.value : this.phone,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChamberRow(')
          ..write('id: $id, ')
          ..write('doctorId: $doctorId, ')
          ..write('name: $name, ')
          ..write('location: $location, ')
          ..write('phone: $phone, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, doctorId, name, location, phone, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChamberRow &&
          other.id == this.id &&
          other.doctorId == this.doctorId &&
          other.name == this.name &&
          other.location == this.location &&
          other.phone == this.phone &&
          other.createdAt == this.createdAt);
}

class ChambersCompanion extends UpdateCompanion<ChamberRow> {
  final Value<String> id;
  final Value<String> doctorId;
  final Value<String> name;
  final Value<String?> location;
  final Value<String?> phone;
  final Value<int> createdAt;
  final Value<int> rowid;
  const ChambersCompanion({
    this.id = const Value.absent(),
    this.doctorId = const Value.absent(),
    this.name = const Value.absent(),
    this.location = const Value.absent(),
    this.phone = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChambersCompanion.insert({
    required String id,
    required String doctorId,
    required String name,
    this.location = const Value.absent(),
    this.phone = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       doctorId = Value(doctorId),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<ChamberRow> custom({
    Expression<String>? id,
    Expression<String>? doctorId,
    Expression<String>? name,
    Expression<String>? location,
    Expression<String>? phone,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (doctorId != null) 'doctor_id': doctorId,
      if (name != null) 'name': name,
      if (location != null) 'location': location,
      if (phone != null) 'phone': phone,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChambersCompanion copyWith({
    Value<String>? id,
    Value<String>? doctorId,
    Value<String>? name,
    Value<String?>? location,
    Value<String?>? phone,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return ChambersCompanion(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      name: name ?? this.name,
      location: location ?? this.location,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (doctorId.present) {
      map['doctor_id'] = Variable<String>(doctorId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChambersCompanion(')
          ..write('id: $id, ')
          ..write('doctorId: $doctorId, ')
          ..write('name: $name, ')
          ..write('location: $location, ')
          ..write('phone: $phone, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, SettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class SettingRow extends DataClass implements Insertable<SettingRow> {
  final String key;
  final String value;
  const SettingRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory SettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  SettingRow copyWith({String? key, String? value}) =>
      SettingRow(key: key ?? this.key, value: value ?? this.value);
  SettingRow copyWithCompanion(AppSettingsCompanion data) {
    return SettingRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingRow &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<SettingRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SettingRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UsersTable extends Users with TableInfo<$UsersTable, UserRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _firstNameMeta = const VerificationMeta(
    'firstName',
  );
  @override
  late final GeneratedColumn<String> firstName = GeneratedColumn<String>(
    'first_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _lastNameMeta = const VerificationMeta(
    'lastName',
  );
  @override
  late final GeneratedColumn<String> lastName = GeneratedColumn<String>(
    'last_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _photoMeta = const VerificationMeta('photo');
  @override
  late final GeneratedColumn<Uint8List> photo = GeneratedColumn<Uint8List>(
    'photo',
    aliasedName,
    true,
    type: DriftSqlType.blob,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _photoVersionMeta = const VerificationMeta(
    'photoVersion',
  );
  @override
  late final GeneratedColumn<int> photoVersion = GeneratedColumn<int>(
    'photo_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _passwordHashMeta = const VerificationMeta(
    'passwordHash',
  );
  @override
  late final GeneratedColumn<String> passwordHash = GeneratedColumn<String>(
    'password_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    username,
    displayName,
    email,
    firstName,
    lastName,
    phone,
    photo,
    photoVersion,
    role,
    passwordHash,
    status,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('first_name')) {
      context.handle(
        _firstNameMeta,
        firstName.isAcceptableOrUnknown(data['first_name']!, _firstNameMeta),
      );
    }
    if (data.containsKey('last_name')) {
      context.handle(
        _lastNameMeta,
        lastName.isAcceptableOrUnknown(data['last_name']!, _lastNameMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('photo')) {
      context.handle(
        _photoMeta,
        photo.isAcceptableOrUnknown(data['photo']!, _photoMeta),
      );
    }
    if (data.containsKey('photo_version')) {
      context.handle(
        _photoVersionMeta,
        photoVersion.isAcceptableOrUnknown(
          data['photo_version']!,
          _photoVersionMeta,
        ),
      );
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('password_hash')) {
      context.handle(
        _passwordHashMeta,
        passwordHash.isAcceptableOrUnknown(
          data['password_hash']!,
          _passwordHashMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_passwordHashMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      firstName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}first_name'],
      )!,
      lastName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_name'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      )!,
      photo: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}photo'],
      ),
      photoVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}photo_version'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      passwordHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}password_hash'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class UserRow extends DataClass implements Insertable<UserRow> {
  final String id;
  final String username;
  final String displayName;
  final String email;
  final String firstName;
  final String lastName;
  final String phone;

  /// Profile picture (a small JPEG, PNG or WebP), if one was uploaded.
  final Uint8List? photo;

  /// UTC epoch milliseconds of the last photo change; 0 when there is none.
  /// Clients use it to know when to fetch the picture again.
  final int photoVersion;
  final String role;

  /// Self-describing slow hash; the password itself is never stored.
  final String passwordHash;
  final String status;

  /// UTC epoch milliseconds.
  final int createdAt;
  const UserRow({
    required this.id,
    required this.username,
    required this.displayName,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.photo,
    required this.photoVersion,
    required this.role,
    required this.passwordHash,
    required this.status,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['username'] = Variable<String>(username);
    map['display_name'] = Variable<String>(displayName);
    map['email'] = Variable<String>(email);
    map['first_name'] = Variable<String>(firstName);
    map['last_name'] = Variable<String>(lastName);
    map['phone'] = Variable<String>(phone);
    if (!nullToAbsent || photo != null) {
      map['photo'] = Variable<Uint8List>(photo);
    }
    map['photo_version'] = Variable<int>(photoVersion);
    map['role'] = Variable<String>(role);
    map['password_hash'] = Variable<String>(passwordHash);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      username: Value(username),
      displayName: Value(displayName),
      email: Value(email),
      firstName: Value(firstName),
      lastName: Value(lastName),
      phone: Value(phone),
      photo: photo == null && nullToAbsent
          ? const Value.absent()
          : Value(photo),
      photoVersion: Value(photoVersion),
      role: Value(role),
      passwordHash: Value(passwordHash),
      status: Value(status),
      createdAt: Value(createdAt),
    );
  }

  factory UserRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserRow(
      id: serializer.fromJson<String>(json['id']),
      username: serializer.fromJson<String>(json['username']),
      displayName: serializer.fromJson<String>(json['displayName']),
      email: serializer.fromJson<String>(json['email']),
      firstName: serializer.fromJson<String>(json['firstName']),
      lastName: serializer.fromJson<String>(json['lastName']),
      phone: serializer.fromJson<String>(json['phone']),
      photo: serializer.fromJson<Uint8List?>(json['photo']),
      photoVersion: serializer.fromJson<int>(json['photoVersion']),
      role: serializer.fromJson<String>(json['role']),
      passwordHash: serializer.fromJson<String>(json['passwordHash']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'username': serializer.toJson<String>(username),
      'displayName': serializer.toJson<String>(displayName),
      'email': serializer.toJson<String>(email),
      'firstName': serializer.toJson<String>(firstName),
      'lastName': serializer.toJson<String>(lastName),
      'phone': serializer.toJson<String>(phone),
      'photo': serializer.toJson<Uint8List?>(photo),
      'photoVersion': serializer.toJson<int>(photoVersion),
      'role': serializer.toJson<String>(role),
      'passwordHash': serializer.toJson<String>(passwordHash),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  UserRow copyWith({
    String? id,
    String? username,
    String? displayName,
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    Value<Uint8List?> photo = const Value.absent(),
    int? photoVersion,
    String? role,
    String? passwordHash,
    String? status,
    int? createdAt,
  }) => UserRow(
    id: id ?? this.id,
    username: username ?? this.username,
    displayName: displayName ?? this.displayName,
    email: email ?? this.email,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    phone: phone ?? this.phone,
    photo: photo.present ? photo.value : this.photo,
    photoVersion: photoVersion ?? this.photoVersion,
    role: role ?? this.role,
    passwordHash: passwordHash ?? this.passwordHash,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
  );
  UserRow copyWithCompanion(UsersCompanion data) {
    return UserRow(
      id: data.id.present ? data.id.value : this.id,
      username: data.username.present ? data.username.value : this.username,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      email: data.email.present ? data.email.value : this.email,
      firstName: data.firstName.present ? data.firstName.value : this.firstName,
      lastName: data.lastName.present ? data.lastName.value : this.lastName,
      phone: data.phone.present ? data.phone.value : this.phone,
      photo: data.photo.present ? data.photo.value : this.photo,
      photoVersion: data.photoVersion.present
          ? data.photoVersion.value
          : this.photoVersion,
      role: data.role.present ? data.role.value : this.role,
      passwordHash: data.passwordHash.present
          ? data.passwordHash.value
          : this.passwordHash,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserRow(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('displayName: $displayName, ')
          ..write('email: $email, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('phone: $phone, ')
          ..write('photo: $photo, ')
          ..write('photoVersion: $photoVersion, ')
          ..write('role: $role, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    username,
    displayName,
    email,
    firstName,
    lastName,
    phone,
    $driftBlobEquality.hash(photo),
    photoVersion,
    role,
    passwordHash,
    status,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserRow &&
          other.id == this.id &&
          other.username == this.username &&
          other.displayName == this.displayName &&
          other.email == this.email &&
          other.firstName == this.firstName &&
          other.lastName == this.lastName &&
          other.phone == this.phone &&
          $driftBlobEquality.equals(other.photo, this.photo) &&
          other.photoVersion == this.photoVersion &&
          other.role == this.role &&
          other.passwordHash == this.passwordHash &&
          other.status == this.status &&
          other.createdAt == this.createdAt);
}

class UsersCompanion extends UpdateCompanion<UserRow> {
  final Value<String> id;
  final Value<String> username;
  final Value<String> displayName;
  final Value<String> email;
  final Value<String> firstName;
  final Value<String> lastName;
  final Value<String> phone;
  final Value<Uint8List?> photo;
  final Value<int> photoVersion;
  final Value<String> role;
  final Value<String> passwordHash;
  final Value<String> status;
  final Value<int> createdAt;
  final Value<int> rowid;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.username = const Value.absent(),
    this.displayName = const Value.absent(),
    this.email = const Value.absent(),
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.phone = const Value.absent(),
    this.photo = const Value.absent(),
    this.photoVersion = const Value.absent(),
    this.role = const Value.absent(),
    this.passwordHash = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String id,
    required String username,
    required String displayName,
    this.email = const Value.absent(),
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.phone = const Value.absent(),
    this.photo = const Value.absent(),
    this.photoVersion = const Value.absent(),
    required String role,
    required String passwordHash,
    this.status = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       username = Value(username),
       displayName = Value(displayName),
       role = Value(role),
       passwordHash = Value(passwordHash),
       createdAt = Value(createdAt);
  static Insertable<UserRow> custom({
    Expression<String>? id,
    Expression<String>? username,
    Expression<String>? displayName,
    Expression<String>? email,
    Expression<String>? firstName,
    Expression<String>? lastName,
    Expression<String>? phone,
    Expression<Uint8List>? photo,
    Expression<int>? photoVersion,
    Expression<String>? role,
    Expression<String>? passwordHash,
    Expression<String>? status,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (username != null) 'username': username,
      if (displayName != null) 'display_name': displayName,
      if (email != null) 'email': email,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (phone != null) 'phone': phone,
      if (photo != null) 'photo': photo,
      if (photoVersion != null) 'photo_version': photoVersion,
      if (role != null) 'role': role,
      if (passwordHash != null) 'password_hash': passwordHash,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith({
    Value<String>? id,
    Value<String>? username,
    Value<String>? displayName,
    Value<String>? email,
    Value<String>? firstName,
    Value<String>? lastName,
    Value<String>? phone,
    Value<Uint8List?>? photo,
    Value<int>? photoVersion,
    Value<String>? role,
    Value<String>? passwordHash,
    Value<String>? status,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return UsersCompanion(
      id: id ?? this.id,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      photo: photo ?? this.photo,
      photoVersion: photoVersion ?? this.photoVersion,
      role: role ?? this.role,
      passwordHash: passwordHash ?? this.passwordHash,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (firstName.present) {
      map['first_name'] = Variable<String>(firstName.value);
    }
    if (lastName.present) {
      map['last_name'] = Variable<String>(lastName.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (photo.present) {
      map['photo'] = Variable<Uint8List>(photo.value);
    }
    if (photoVersion.present) {
      map['photo_version'] = Variable<int>(photoVersion.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (passwordHash.present) {
      map['password_hash'] = Variable<String>(passwordHash.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('displayName: $displayName, ')
          ..write('email: $email, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('phone: $phone, ')
          ..write('photo: $photo, ')
          ..write('photoVersion: $photoVersion, ')
          ..write('role: $role, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserScopeAssignmentsTable extends UserScopeAssignments
    with TableInfo<$UserScopeAssignmentsTable, UserScopeAssignmentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserScopeAssignmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (id)',
    ),
  );
  static const VerificationMeta _scopeIdMeta = const VerificationMeta(
    'scopeId',
  );
  @override
  late final GeneratedColumn<String> scopeId = GeneratedColumn<String>(
    'scope_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [userId, scopeId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_scope_assignments';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserScopeAssignmentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('scope_id')) {
      context.handle(
        _scopeIdMeta,
        scopeId.isAcceptableOrUnknown(data['scope_id']!, _scopeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_scopeIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, scopeId};
  @override
  UserScopeAssignmentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserScopeAssignmentRow(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      scopeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope_id'],
      )!,
    );
  }

  @override
  $UserScopeAssignmentsTable createAlias(String alias) {
    return $UserScopeAssignmentsTable(attachedDatabase, alias);
  }
}

class UserScopeAssignmentRow extends DataClass
    implements Insertable<UserScopeAssignmentRow> {
  final String userId;
  final String scopeId;
  const UserScopeAssignmentRow({required this.userId, required this.scopeId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['scope_id'] = Variable<String>(scopeId);
    return map;
  }

  UserScopeAssignmentsCompanion toCompanion(bool nullToAbsent) {
    return UserScopeAssignmentsCompanion(
      userId: Value(userId),
      scopeId: Value(scopeId),
    );
  }

  factory UserScopeAssignmentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserScopeAssignmentRow(
      userId: serializer.fromJson<String>(json['userId']),
      scopeId: serializer.fromJson<String>(json['scopeId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'scopeId': serializer.toJson<String>(scopeId),
    };
  }

  UserScopeAssignmentRow copyWith({String? userId, String? scopeId}) =>
      UserScopeAssignmentRow(
        userId: userId ?? this.userId,
        scopeId: scopeId ?? this.scopeId,
      );
  UserScopeAssignmentRow copyWithCompanion(UserScopeAssignmentsCompanion data) {
    return UserScopeAssignmentRow(
      userId: data.userId.present ? data.userId.value : this.userId,
      scopeId: data.scopeId.present ? data.scopeId.value : this.scopeId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserScopeAssignmentRow(')
          ..write('userId: $userId, ')
          ..write('scopeId: $scopeId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(userId, scopeId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserScopeAssignmentRow &&
          other.userId == this.userId &&
          other.scopeId == this.scopeId);
}

class UserScopeAssignmentsCompanion
    extends UpdateCompanion<UserScopeAssignmentRow> {
  final Value<String> userId;
  final Value<String> scopeId;
  final Value<int> rowid;
  const UserScopeAssignmentsCompanion({
    this.userId = const Value.absent(),
    this.scopeId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserScopeAssignmentsCompanion.insert({
    required String userId,
    required String scopeId,
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       scopeId = Value(scopeId);
  static Insertable<UserScopeAssignmentRow> custom({
    Expression<String>? userId,
    Expression<String>? scopeId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (scopeId != null) 'scope_id': scopeId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserScopeAssignmentsCompanion copyWith({
    Value<String>? userId,
    Value<String>? scopeId,
    Value<int>? rowid,
  }) {
    return UserScopeAssignmentsCompanion(
      userId: userId ?? this.userId,
      scopeId: scopeId ?? this.scopeId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (scopeId.present) {
      map['scope_id'] = Variable<String>(scopeId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserScopeAssignmentsCompanion(')
          ..write('userId: $userId, ')
          ..write('scopeId: $scopeId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AuthSessionsTable extends AuthSessions
    with TableInfo<$AuthSessionsTable, AuthSessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuthSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (id)',
    ),
  );
  static const VerificationMeta _tokenHashMeta = const VerificationMeta(
    'tokenHash',
  );
  @override
  late final GeneratedColumn<String> tokenHash = GeneratedColumn<String>(
    'token_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expiresAtMeta = const VerificationMeta(
    'expiresAt',
  );
  @override
  late final GeneratedColumn<int> expiresAt = GeneratedColumn<int>(
    'expires_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revokedMeta = const VerificationMeta(
    'revoked',
  );
  @override
  late final GeneratedColumn<bool> revoked = GeneratedColumn<bool>(
    'revoked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("revoked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    tokenHash,
    createdAt,
    expiresAt,
    revoked,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'auth_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<AuthSessionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('token_hash')) {
      context.handle(
        _tokenHashMeta,
        tokenHash.isAcceptableOrUnknown(data['token_hash']!, _tokenHashMeta),
      );
    } else if (isInserting) {
      context.missing(_tokenHashMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
      );
    } else if (isInserting) {
      context.missing(_expiresAtMeta);
    }
    if (data.containsKey('revoked')) {
      context.handle(
        _revokedMeta,
        revoked.isAcceptableOrUnknown(data['revoked']!, _revokedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AuthSessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AuthSessionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      tokenHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}token_hash'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}expires_at'],
      )!,
      revoked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}revoked'],
      )!,
    );
  }

  @override
  $AuthSessionsTable createAlias(String alias) {
    return $AuthSessionsTable(attachedDatabase, alias);
  }
}

class AuthSessionRow extends DataClass implements Insertable<AuthSessionRow> {
  final String id;
  final String userId;
  final String tokenHash;
  final int createdAt;
  final int expiresAt;
  final bool revoked;
  const AuthSessionRow({
    required this.id,
    required this.userId,
    required this.tokenHash,
    required this.createdAt,
    required this.expiresAt,
    required this.revoked,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['token_hash'] = Variable<String>(tokenHash);
    map['created_at'] = Variable<int>(createdAt);
    map['expires_at'] = Variable<int>(expiresAt);
    map['revoked'] = Variable<bool>(revoked);
    return map;
  }

  AuthSessionsCompanion toCompanion(bool nullToAbsent) {
    return AuthSessionsCompanion(
      id: Value(id),
      userId: Value(userId),
      tokenHash: Value(tokenHash),
      createdAt: Value(createdAt),
      expiresAt: Value(expiresAt),
      revoked: Value(revoked),
    );
  }

  factory AuthSessionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AuthSessionRow(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      tokenHash: serializer.fromJson<String>(json['tokenHash']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      expiresAt: serializer.fromJson<int>(json['expiresAt']),
      revoked: serializer.fromJson<bool>(json['revoked']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'tokenHash': serializer.toJson<String>(tokenHash),
      'createdAt': serializer.toJson<int>(createdAt),
      'expiresAt': serializer.toJson<int>(expiresAt),
      'revoked': serializer.toJson<bool>(revoked),
    };
  }

  AuthSessionRow copyWith({
    String? id,
    String? userId,
    String? tokenHash,
    int? createdAt,
    int? expiresAt,
    bool? revoked,
  }) => AuthSessionRow(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    tokenHash: tokenHash ?? this.tokenHash,
    createdAt: createdAt ?? this.createdAt,
    expiresAt: expiresAt ?? this.expiresAt,
    revoked: revoked ?? this.revoked,
  );
  AuthSessionRow copyWithCompanion(AuthSessionsCompanion data) {
    return AuthSessionRow(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      tokenHash: data.tokenHash.present ? data.tokenHash.value : this.tokenHash,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
      revoked: data.revoked.present ? data.revoked.value : this.revoked,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AuthSessionRow(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('tokenHash: $tokenHash, ')
          ..write('createdAt: $createdAt, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('revoked: $revoked')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, tokenHash, createdAt, expiresAt, revoked);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuthSessionRow &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.tokenHash == this.tokenHash &&
          other.createdAt == this.createdAt &&
          other.expiresAt == this.expiresAt &&
          other.revoked == this.revoked);
}

class AuthSessionsCompanion extends UpdateCompanion<AuthSessionRow> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> tokenHash;
  final Value<int> createdAt;
  final Value<int> expiresAt;
  final Value<bool> revoked;
  final Value<int> rowid;
  const AuthSessionsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.tokenHash = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.revoked = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AuthSessionsCompanion.insert({
    required String id,
    required String userId,
    required String tokenHash,
    required int createdAt,
    required int expiresAt,
    this.revoked = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       tokenHash = Value(tokenHash),
       createdAt = Value(createdAt),
       expiresAt = Value(expiresAt);
  static Insertable<AuthSessionRow> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? tokenHash,
    Expression<int>? createdAt,
    Expression<int>? expiresAt,
    Expression<bool>? revoked,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (tokenHash != null) 'token_hash': tokenHash,
      if (createdAt != null) 'created_at': createdAt,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (revoked != null) 'revoked': revoked,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AuthSessionsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? tokenHash,
    Value<int>? createdAt,
    Value<int>? expiresAt,
    Value<bool>? revoked,
    Value<int>? rowid,
  }) {
    return AuthSessionsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      tokenHash: tokenHash ?? this.tokenHash,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      revoked: revoked ?? this.revoked,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (tokenHash.present) {
      map['token_hash'] = Variable<String>(tokenHash.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<int>(expiresAt.value);
    }
    if (revoked.present) {
      map['revoked'] = Variable<bool>(revoked.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuthSessionsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('tokenHash: $tokenHash, ')
          ..write('createdAt: $createdAt, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('revoked: $revoked, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AuditEntriesTable extends AuditEntries
    with TableInfo<$AuditEntriesTable, AuditEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuditEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<int> at = GeneratedColumn<int>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actorIdMeta = const VerificationMeta(
    'actorId',
  );
  @override
  late final GeneratedColumn<String> actorId = GeneratedColumn<String>(
    'actor_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _detailMeta = const VerificationMeta('detail');
  @override
  late final GeneratedColumn<String> detail = GeneratedColumn<String>(
    'detail',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _prevHashMeta = const VerificationMeta(
    'prevHash',
  );
  @override
  late final GeneratedColumn<String> prevHash = GeneratedColumn<String>(
    'prev_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hashMeta = const VerificationMeta('hash');
  @override
  late final GeneratedColumn<String> hash = GeneratedColumn<String>(
    'hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    seq,
    at,
    actorId,
    action,
    detail,
    prevHash,
    hash,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audit_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<AuditEntryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('seq')) {
      context.handle(
        _seqMeta,
        seq.isAcceptableOrUnknown(data['seq']!, _seqMeta),
      );
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    if (data.containsKey('actor_id')) {
      context.handle(
        _actorIdMeta,
        actorId.isAcceptableOrUnknown(data['actor_id']!, _actorIdMeta),
      );
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('detail')) {
      context.handle(
        _detailMeta,
        detail.isAcceptableOrUnknown(data['detail']!, _detailMeta),
      );
    }
    if (data.containsKey('prev_hash')) {
      context.handle(
        _prevHashMeta,
        prevHash.isAcceptableOrUnknown(data['prev_hash']!, _prevHashMeta),
      );
    } else if (isInserting) {
      context.missing(_prevHashMeta);
    }
    if (data.containsKey('hash')) {
      context.handle(
        _hashMeta,
        hash.isAcceptableOrUnknown(data['hash']!, _hashMeta),
      );
    } else if (isInserting) {
      context.missing(_hashMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {seq};
  @override
  AuditEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AuditEntryRow(
      seq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seq'],
      )!,
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}at'],
      )!,
      actorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}actor_id'],
      ),
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      detail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}detail'],
      ),
      prevHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prev_hash'],
      )!,
      hash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hash'],
      )!,
    );
  }

  @override
  $AuditEntriesTable createAlias(String alias) {
    return $AuditEntriesTable(attachedDatabase, alias);
  }
}

class AuditEntryRow extends DataClass implements Insertable<AuditEntryRow> {
  final int seq;
  final int at;
  final String? actorId;
  final String action;
  final String? detail;
  final String prevHash;
  final String hash;
  const AuditEntryRow({
    required this.seq,
    required this.at,
    this.actorId,
    required this.action,
    this.detail,
    required this.prevHash,
    required this.hash,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['seq'] = Variable<int>(seq);
    map['at'] = Variable<int>(at);
    if (!nullToAbsent || actorId != null) {
      map['actor_id'] = Variable<String>(actorId);
    }
    map['action'] = Variable<String>(action);
    if (!nullToAbsent || detail != null) {
      map['detail'] = Variable<String>(detail);
    }
    map['prev_hash'] = Variable<String>(prevHash);
    map['hash'] = Variable<String>(hash);
    return map;
  }

  AuditEntriesCompanion toCompanion(bool nullToAbsent) {
    return AuditEntriesCompanion(
      seq: Value(seq),
      at: Value(at),
      actorId: actorId == null && nullToAbsent
          ? const Value.absent()
          : Value(actorId),
      action: Value(action),
      detail: detail == null && nullToAbsent
          ? const Value.absent()
          : Value(detail),
      prevHash: Value(prevHash),
      hash: Value(hash),
    );
  }

  factory AuditEntryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AuditEntryRow(
      seq: serializer.fromJson<int>(json['seq']),
      at: serializer.fromJson<int>(json['at']),
      actorId: serializer.fromJson<String?>(json['actorId']),
      action: serializer.fromJson<String>(json['action']),
      detail: serializer.fromJson<String?>(json['detail']),
      prevHash: serializer.fromJson<String>(json['prevHash']),
      hash: serializer.fromJson<String>(json['hash']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'seq': serializer.toJson<int>(seq),
      'at': serializer.toJson<int>(at),
      'actorId': serializer.toJson<String?>(actorId),
      'action': serializer.toJson<String>(action),
      'detail': serializer.toJson<String?>(detail),
      'prevHash': serializer.toJson<String>(prevHash),
      'hash': serializer.toJson<String>(hash),
    };
  }

  AuditEntryRow copyWith({
    int? seq,
    int? at,
    Value<String?> actorId = const Value.absent(),
    String? action,
    Value<String?> detail = const Value.absent(),
    String? prevHash,
    String? hash,
  }) => AuditEntryRow(
    seq: seq ?? this.seq,
    at: at ?? this.at,
    actorId: actorId.present ? actorId.value : this.actorId,
    action: action ?? this.action,
    detail: detail.present ? detail.value : this.detail,
    prevHash: prevHash ?? this.prevHash,
    hash: hash ?? this.hash,
  );
  AuditEntryRow copyWithCompanion(AuditEntriesCompanion data) {
    return AuditEntryRow(
      seq: data.seq.present ? data.seq.value : this.seq,
      at: data.at.present ? data.at.value : this.at,
      actorId: data.actorId.present ? data.actorId.value : this.actorId,
      action: data.action.present ? data.action.value : this.action,
      detail: data.detail.present ? data.detail.value : this.detail,
      prevHash: data.prevHash.present ? data.prevHash.value : this.prevHash,
      hash: data.hash.present ? data.hash.value : this.hash,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AuditEntryRow(')
          ..write('seq: $seq, ')
          ..write('at: $at, ')
          ..write('actorId: $actorId, ')
          ..write('action: $action, ')
          ..write('detail: $detail, ')
          ..write('prevHash: $prevHash, ')
          ..write('hash: $hash')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(seq, at, actorId, action, detail, prevHash, hash);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuditEntryRow &&
          other.seq == this.seq &&
          other.at == this.at &&
          other.actorId == this.actorId &&
          other.action == this.action &&
          other.detail == this.detail &&
          other.prevHash == this.prevHash &&
          other.hash == this.hash);
}

class AuditEntriesCompanion extends UpdateCompanion<AuditEntryRow> {
  final Value<int> seq;
  final Value<int> at;
  final Value<String?> actorId;
  final Value<String> action;
  final Value<String?> detail;
  final Value<String> prevHash;
  final Value<String> hash;
  const AuditEntriesCompanion({
    this.seq = const Value.absent(),
    this.at = const Value.absent(),
    this.actorId = const Value.absent(),
    this.action = const Value.absent(),
    this.detail = const Value.absent(),
    this.prevHash = const Value.absent(),
    this.hash = const Value.absent(),
  });
  AuditEntriesCompanion.insert({
    this.seq = const Value.absent(),
    required int at,
    this.actorId = const Value.absent(),
    required String action,
    this.detail = const Value.absent(),
    required String prevHash,
    required String hash,
  }) : at = Value(at),
       action = Value(action),
       prevHash = Value(prevHash),
       hash = Value(hash);
  static Insertable<AuditEntryRow> custom({
    Expression<int>? seq,
    Expression<int>? at,
    Expression<String>? actorId,
    Expression<String>? action,
    Expression<String>? detail,
    Expression<String>? prevHash,
    Expression<String>? hash,
  }) {
    return RawValuesInsertable({
      if (seq != null) 'seq': seq,
      if (at != null) 'at': at,
      if (actorId != null) 'actor_id': actorId,
      if (action != null) 'action': action,
      if (detail != null) 'detail': detail,
      if (prevHash != null) 'prev_hash': prevHash,
      if (hash != null) 'hash': hash,
    });
  }

  AuditEntriesCompanion copyWith({
    Value<int>? seq,
    Value<int>? at,
    Value<String?>? actorId,
    Value<String>? action,
    Value<String?>? detail,
    Value<String>? prevHash,
    Value<String>? hash,
  }) {
    return AuditEntriesCompanion(
      seq: seq ?? this.seq,
      at: at ?? this.at,
      actorId: actorId ?? this.actorId,
      action: action ?? this.action,
      detail: detail ?? this.detail,
      prevHash: prevHash ?? this.prevHash,
      hash: hash ?? this.hash,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (at.present) {
      map['at'] = Variable<int>(at.value);
    }
    if (actorId.present) {
      map['actor_id'] = Variable<String>(actorId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (detail.present) {
      map['detail'] = Variable<String>(detail.value);
    }
    if (prevHash.present) {
      map['prev_hash'] = Variable<String>(prevHash.value);
    }
    if (hash.present) {
      map['hash'] = Variable<String>(hash.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuditEntriesCompanion(')
          ..write('seq: $seq, ')
          ..write('at: $at, ')
          ..write('actorId: $actorId, ')
          ..write('action: $action, ')
          ..write('detail: $detail, ')
          ..write('prevHash: $prevHash, ')
          ..write('hash: $hash')
          ..write(')'))
        .toString();
  }
}

class $PinDevicesTable extends PinDevices
    with TableInfo<$PinDevicesTable, PinDeviceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PinDevicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (id)',
    ),
  );
  static const VerificationMeta _tokenHashMeta = const VerificationMeta(
    'tokenHash',
  );
  @override
  late final GeneratedColumn<String> tokenHash = GeneratedColumn<String>(
    'token_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _pinHashMeta = const VerificationMeta(
    'pinHash',
  );
  @override
  late final GeneratedColumn<String> pinHash = GeneratedColumn<String>(
    'pin_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastUsedAtMeta = const VerificationMeta(
    'lastUsedAt',
  );
  @override
  late final GeneratedColumn<int> lastUsedAt = GeneratedColumn<int>(
    'last_used_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _failuresMeta = const VerificationMeta(
    'failures',
  );
  @override
  late final GeneratedColumn<int> failures = GeneratedColumn<int>(
    'failures',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    tokenHash,
    pinHash,
    label,
    createdAt,
    lastUsedAt,
    failures,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pin_devices';
  @override
  VerificationContext validateIntegrity(
    Insertable<PinDeviceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('token_hash')) {
      context.handle(
        _tokenHashMeta,
        tokenHash.isAcceptableOrUnknown(data['token_hash']!, _tokenHashMeta),
      );
    } else if (isInserting) {
      context.missing(_tokenHashMeta);
    }
    if (data.containsKey('pin_hash')) {
      context.handle(
        _pinHashMeta,
        pinHash.isAcceptableOrUnknown(data['pin_hash']!, _pinHashMeta),
      );
    } else if (isInserting) {
      context.missing(_pinHashMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_used_at')) {
      context.handle(
        _lastUsedAtMeta,
        lastUsedAt.isAcceptableOrUnknown(
          data['last_used_at']!,
          _lastUsedAtMeta,
        ),
      );
    }
    if (data.containsKey('failures')) {
      context.handle(
        _failuresMeta,
        failures.isAcceptableOrUnknown(data['failures']!, _failuresMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PinDeviceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PinDeviceRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      tokenHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}token_hash'],
      )!,
      pinHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pin_hash'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      lastUsedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_used_at'],
      )!,
      failures: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}failures'],
      )!,
    );
  }

  @override
  $PinDevicesTable createAlias(String alias) {
    return $PinDevicesTable(attachedDatabase, alias);
  }
}

class PinDeviceRow extends DataClass implements Insertable<PinDeviceRow> {
  final String id;
  final String userId;
  final String tokenHash;
  final String pinHash;

  /// Which browser, for the person to recognise in their list.
  final String label;
  final int createdAt;

  /// UTC epoch milliseconds of the last PIN sign-in; 0 when never.
  final int lastUsedAt;

  /// Wrong PINs in a row. Reaching the limit removes the device.
  final int failures;
  const PinDeviceRow({
    required this.id,
    required this.userId,
    required this.tokenHash,
    required this.pinHash,
    required this.label,
    required this.createdAt,
    required this.lastUsedAt,
    required this.failures,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['token_hash'] = Variable<String>(tokenHash);
    map['pin_hash'] = Variable<String>(pinHash);
    map['label'] = Variable<String>(label);
    map['created_at'] = Variable<int>(createdAt);
    map['last_used_at'] = Variable<int>(lastUsedAt);
    map['failures'] = Variable<int>(failures);
    return map;
  }

  PinDevicesCompanion toCompanion(bool nullToAbsent) {
    return PinDevicesCompanion(
      id: Value(id),
      userId: Value(userId),
      tokenHash: Value(tokenHash),
      pinHash: Value(pinHash),
      label: Value(label),
      createdAt: Value(createdAt),
      lastUsedAt: Value(lastUsedAt),
      failures: Value(failures),
    );
  }

  factory PinDeviceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PinDeviceRow(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      tokenHash: serializer.fromJson<String>(json['tokenHash']),
      pinHash: serializer.fromJson<String>(json['pinHash']),
      label: serializer.fromJson<String>(json['label']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      lastUsedAt: serializer.fromJson<int>(json['lastUsedAt']),
      failures: serializer.fromJson<int>(json['failures']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'tokenHash': serializer.toJson<String>(tokenHash),
      'pinHash': serializer.toJson<String>(pinHash),
      'label': serializer.toJson<String>(label),
      'createdAt': serializer.toJson<int>(createdAt),
      'lastUsedAt': serializer.toJson<int>(lastUsedAt),
      'failures': serializer.toJson<int>(failures),
    };
  }

  PinDeviceRow copyWith({
    String? id,
    String? userId,
    String? tokenHash,
    String? pinHash,
    String? label,
    int? createdAt,
    int? lastUsedAt,
    int? failures,
  }) => PinDeviceRow(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    tokenHash: tokenHash ?? this.tokenHash,
    pinHash: pinHash ?? this.pinHash,
    label: label ?? this.label,
    createdAt: createdAt ?? this.createdAt,
    lastUsedAt: lastUsedAt ?? this.lastUsedAt,
    failures: failures ?? this.failures,
  );
  PinDeviceRow copyWithCompanion(PinDevicesCompanion data) {
    return PinDeviceRow(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      tokenHash: data.tokenHash.present ? data.tokenHash.value : this.tokenHash,
      pinHash: data.pinHash.present ? data.pinHash.value : this.pinHash,
      label: data.label.present ? data.label.value : this.label,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastUsedAt: data.lastUsedAt.present
          ? data.lastUsedAt.value
          : this.lastUsedAt,
      failures: data.failures.present ? data.failures.value : this.failures,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PinDeviceRow(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('tokenHash: $tokenHash, ')
          ..write('pinHash: $pinHash, ')
          ..write('label: $label, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUsedAt: $lastUsedAt, ')
          ..write('failures: $failures')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    tokenHash,
    pinHash,
    label,
    createdAt,
    lastUsedAt,
    failures,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PinDeviceRow &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.tokenHash == this.tokenHash &&
          other.pinHash == this.pinHash &&
          other.label == this.label &&
          other.createdAt == this.createdAt &&
          other.lastUsedAt == this.lastUsedAt &&
          other.failures == this.failures);
}

class PinDevicesCompanion extends UpdateCompanion<PinDeviceRow> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> tokenHash;
  final Value<String> pinHash;
  final Value<String> label;
  final Value<int> createdAt;
  final Value<int> lastUsedAt;
  final Value<int> failures;
  final Value<int> rowid;
  const PinDevicesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.tokenHash = const Value.absent(),
    this.pinHash = const Value.absent(),
    this.label = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUsedAt = const Value.absent(),
    this.failures = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PinDevicesCompanion.insert({
    required String id,
    required String userId,
    required String tokenHash,
    required String pinHash,
    this.label = const Value.absent(),
    required int createdAt,
    this.lastUsedAt = const Value.absent(),
    this.failures = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       tokenHash = Value(tokenHash),
       pinHash = Value(pinHash),
       createdAt = Value(createdAt);
  static Insertable<PinDeviceRow> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? tokenHash,
    Expression<String>? pinHash,
    Expression<String>? label,
    Expression<int>? createdAt,
    Expression<int>? lastUsedAt,
    Expression<int>? failures,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (tokenHash != null) 'token_hash': tokenHash,
      if (pinHash != null) 'pin_hash': pinHash,
      if (label != null) 'label': label,
      if (createdAt != null) 'created_at': createdAt,
      if (lastUsedAt != null) 'last_used_at': lastUsedAt,
      if (failures != null) 'failures': failures,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PinDevicesCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? tokenHash,
    Value<String>? pinHash,
    Value<String>? label,
    Value<int>? createdAt,
    Value<int>? lastUsedAt,
    Value<int>? failures,
    Value<int>? rowid,
  }) {
    return PinDevicesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      tokenHash: tokenHash ?? this.tokenHash,
      pinHash: pinHash ?? this.pinHash,
      label: label ?? this.label,
      createdAt: createdAt ?? this.createdAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      failures: failures ?? this.failures,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (tokenHash.present) {
      map['token_hash'] = Variable<String>(tokenHash.value);
    }
    if (pinHash.present) {
      map['pin_hash'] = Variable<String>(pinHash.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (lastUsedAt.present) {
      map['last_used_at'] = Variable<int>(lastUsedAt.value);
    }
    if (failures.present) {
      map['failures'] = Variable<int>(failures.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PinDevicesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('tokenHash: $tokenHash, ')
          ..write('pinHash: $pinHash, ')
          ..write('label: $label, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUsedAt: $lastUsedAt, ')
          ..write('failures: $failures, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QueueTypesTable extends QueueTypes
    with TableInfo<$QueueTypesTable, QueueTypeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QueueTypesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerKeyMeta = const VerificationMeta(
    'ownerKey',
  );
  @override
  late final GeneratedColumn<String> ownerKey = GeneratedColumn<String>(
    'owner_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _englishNameMeta = const VerificationMeta(
    'englishName',
  );
  @override
  late final GeneratedColumn<String> englishName = GeneratedColumn<String>(
    'english_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bengaliNameMeta = const VerificationMeta(
    'bengaliName',
  );
  @override
  late final GeneratedColumn<String> bengaliName = GeneratedColumn<String>(
    'bengali_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startNumberMeta = const VerificationMeta(
    'startNumber',
  );
  @override
  late final GeneratedColumn<int> startNumber = GeneratedColumn<int>(
    'start_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endNumberMeta = const VerificationMeta(
    'endNumber',
  );
  @override
  late final GeneratedColumn<int> endNumber = GeneratedColumn<int>(
    'end_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayOrderMeta = const VerificationMeta(
    'displayOrder',
  );
  @override
  late final GeneratedColumn<int> displayOrder = GeneratedColumn<int>(
    'display_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerKey,
    englishName,
    bengaliName,
    startNumber,
    endNumber,
    displayOrder,
    enabled,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'queue_types';
  @override
  VerificationContext validateIntegrity(
    Insertable<QueueTypeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_key')) {
      context.handle(
        _ownerKeyMeta,
        ownerKey.isAcceptableOrUnknown(data['owner_key']!, _ownerKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerKeyMeta);
    }
    if (data.containsKey('english_name')) {
      context.handle(
        _englishNameMeta,
        englishName.isAcceptableOrUnknown(
          data['english_name']!,
          _englishNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_englishNameMeta);
    }
    if (data.containsKey('bengali_name')) {
      context.handle(
        _bengaliNameMeta,
        bengaliName.isAcceptableOrUnknown(
          data['bengali_name']!,
          _bengaliNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_bengaliNameMeta);
    }
    if (data.containsKey('start_number')) {
      context.handle(
        _startNumberMeta,
        startNumber.isAcceptableOrUnknown(
          data['start_number']!,
          _startNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startNumberMeta);
    }
    if (data.containsKey('end_number')) {
      context.handle(
        _endNumberMeta,
        endNumber.isAcceptableOrUnknown(data['end_number']!, _endNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_endNumberMeta);
    }
    if (data.containsKey('display_order')) {
      context.handle(
        _displayOrderMeta,
        displayOrder.isAcceptableOrUnknown(
          data['display_order']!,
          _displayOrderMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayOrderMeta);
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id, ownerKey};
  @override
  QueueTypeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QueueTypeRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_key'],
      )!,
      englishName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}english_name'],
      )!,
      bengaliName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bengali_name'],
      )!,
      startNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_number'],
      )!,
      endNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_number'],
      )!,
      displayOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}display_order'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
    );
  }

  @override
  $QueueTypesTable createAlias(String alias) {
    return $QueueTypesTable(attachedDatabase, alias);
  }
}

class QueueTypeRow extends DataClass implements Insertable<QueueTypeRow> {
  final String id;
  final String ownerKey;
  final String englishName;
  final String bengaliName;
  final int startNumber;
  final int endNumber;
  final int displayOrder;
  final bool enabled;
  const QueueTypeRow({
    required this.id,
    required this.ownerKey,
    required this.englishName,
    required this.bengaliName,
    required this.startNumber,
    required this.endNumber,
    required this.displayOrder,
    required this.enabled,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_key'] = Variable<String>(ownerKey);
    map['english_name'] = Variable<String>(englishName);
    map['bengali_name'] = Variable<String>(bengaliName);
    map['start_number'] = Variable<int>(startNumber);
    map['end_number'] = Variable<int>(endNumber);
    map['display_order'] = Variable<int>(displayOrder);
    map['enabled'] = Variable<bool>(enabled);
    return map;
  }

  QueueTypesCompanion toCompanion(bool nullToAbsent) {
    return QueueTypesCompanion(
      id: Value(id),
      ownerKey: Value(ownerKey),
      englishName: Value(englishName),
      bengaliName: Value(bengaliName),
      startNumber: Value(startNumber),
      endNumber: Value(endNumber),
      displayOrder: Value(displayOrder),
      enabled: Value(enabled),
    );
  }

  factory QueueTypeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QueueTypeRow(
      id: serializer.fromJson<String>(json['id']),
      ownerKey: serializer.fromJson<String>(json['ownerKey']),
      englishName: serializer.fromJson<String>(json['englishName']),
      bengaliName: serializer.fromJson<String>(json['bengaliName']),
      startNumber: serializer.fromJson<int>(json['startNumber']),
      endNumber: serializer.fromJson<int>(json['endNumber']),
      displayOrder: serializer.fromJson<int>(json['displayOrder']),
      enabled: serializer.fromJson<bool>(json['enabled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerKey': serializer.toJson<String>(ownerKey),
      'englishName': serializer.toJson<String>(englishName),
      'bengaliName': serializer.toJson<String>(bengaliName),
      'startNumber': serializer.toJson<int>(startNumber),
      'endNumber': serializer.toJson<int>(endNumber),
      'displayOrder': serializer.toJson<int>(displayOrder),
      'enabled': serializer.toJson<bool>(enabled),
    };
  }

  QueueTypeRow copyWith({
    String? id,
    String? ownerKey,
    String? englishName,
    String? bengaliName,
    int? startNumber,
    int? endNumber,
    int? displayOrder,
    bool? enabled,
  }) => QueueTypeRow(
    id: id ?? this.id,
    ownerKey: ownerKey ?? this.ownerKey,
    englishName: englishName ?? this.englishName,
    bengaliName: bengaliName ?? this.bengaliName,
    startNumber: startNumber ?? this.startNumber,
    endNumber: endNumber ?? this.endNumber,
    displayOrder: displayOrder ?? this.displayOrder,
    enabled: enabled ?? this.enabled,
  );
  QueueTypeRow copyWithCompanion(QueueTypesCompanion data) {
    return QueueTypeRow(
      id: data.id.present ? data.id.value : this.id,
      ownerKey: data.ownerKey.present ? data.ownerKey.value : this.ownerKey,
      englishName: data.englishName.present
          ? data.englishName.value
          : this.englishName,
      bengaliName: data.bengaliName.present
          ? data.bengaliName.value
          : this.bengaliName,
      startNumber: data.startNumber.present
          ? data.startNumber.value
          : this.startNumber,
      endNumber: data.endNumber.present ? data.endNumber.value : this.endNumber,
      displayOrder: data.displayOrder.present
          ? data.displayOrder.value
          : this.displayOrder,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QueueTypeRow(')
          ..write('id: $id, ')
          ..write('ownerKey: $ownerKey, ')
          ..write('englishName: $englishName, ')
          ..write('bengaliName: $bengaliName, ')
          ..write('startNumber: $startNumber, ')
          ..write('endNumber: $endNumber, ')
          ..write('displayOrder: $displayOrder, ')
          ..write('enabled: $enabled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerKey,
    englishName,
    bengaliName,
    startNumber,
    endNumber,
    displayOrder,
    enabled,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QueueTypeRow &&
          other.id == this.id &&
          other.ownerKey == this.ownerKey &&
          other.englishName == this.englishName &&
          other.bengaliName == this.bengaliName &&
          other.startNumber == this.startNumber &&
          other.endNumber == this.endNumber &&
          other.displayOrder == this.displayOrder &&
          other.enabled == this.enabled);
}

class QueueTypesCompanion extends UpdateCompanion<QueueTypeRow> {
  final Value<String> id;
  final Value<String> ownerKey;
  final Value<String> englishName;
  final Value<String> bengaliName;
  final Value<int> startNumber;
  final Value<int> endNumber;
  final Value<int> displayOrder;
  final Value<bool> enabled;
  final Value<int> rowid;
  const QueueTypesCompanion({
    this.id = const Value.absent(),
    this.ownerKey = const Value.absent(),
    this.englishName = const Value.absent(),
    this.bengaliName = const Value.absent(),
    this.startNumber = const Value.absent(),
    this.endNumber = const Value.absent(),
    this.displayOrder = const Value.absent(),
    this.enabled = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QueueTypesCompanion.insert({
    required String id,
    required String ownerKey,
    required String englishName,
    required String bengaliName,
    required int startNumber,
    required int endNumber,
    required int displayOrder,
    this.enabled = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerKey = Value(ownerKey),
       englishName = Value(englishName),
       bengaliName = Value(bengaliName),
       startNumber = Value(startNumber),
       endNumber = Value(endNumber),
       displayOrder = Value(displayOrder);
  static Insertable<QueueTypeRow> custom({
    Expression<String>? id,
    Expression<String>? ownerKey,
    Expression<String>? englishName,
    Expression<String>? bengaliName,
    Expression<int>? startNumber,
    Expression<int>? endNumber,
    Expression<int>? displayOrder,
    Expression<bool>? enabled,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerKey != null) 'owner_key': ownerKey,
      if (englishName != null) 'english_name': englishName,
      if (bengaliName != null) 'bengali_name': bengaliName,
      if (startNumber != null) 'start_number': startNumber,
      if (endNumber != null) 'end_number': endNumber,
      if (displayOrder != null) 'display_order': displayOrder,
      if (enabled != null) 'enabled': enabled,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QueueTypesCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerKey,
    Value<String>? englishName,
    Value<String>? bengaliName,
    Value<int>? startNumber,
    Value<int>? endNumber,
    Value<int>? displayOrder,
    Value<bool>? enabled,
    Value<int>? rowid,
  }) {
    return QueueTypesCompanion(
      id: id ?? this.id,
      ownerKey: ownerKey ?? this.ownerKey,
      englishName: englishName ?? this.englishName,
      bengaliName: bengaliName ?? this.bengaliName,
      startNumber: startNumber ?? this.startNumber,
      endNumber: endNumber ?? this.endNumber,
      displayOrder: displayOrder ?? this.displayOrder,
      enabled: enabled ?? this.enabled,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerKey.present) {
      map['owner_key'] = Variable<String>(ownerKey.value);
    }
    if (englishName.present) {
      map['english_name'] = Variable<String>(englishName.value);
    }
    if (bengaliName.present) {
      map['bengali_name'] = Variable<String>(bengaliName.value);
    }
    if (startNumber.present) {
      map['start_number'] = Variable<int>(startNumber.value);
    }
    if (endNumber.present) {
      map['end_number'] = Variable<int>(endNumber.value);
    }
    if (displayOrder.present) {
      map['display_order'] = Variable<int>(displayOrder.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QueueTypesCompanion(')
          ..write('id: $id, ')
          ..write('ownerKey: $ownerKey, ')
          ..write('englishName: $englishName, ')
          ..write('bengaliName: $bengaliName, ')
          ..write('startNumber: $startNumber, ')
          ..write('endNumber: $endNumber, ')
          ..write('displayOrder: $displayOrder, ')
          ..write('enabled: $enabled, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QueueSessionsTable extends QueueSessions
    with TableInfo<$QueueSessionsTable, QueueSessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QueueSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chamberIdMeta = const VerificationMeta(
    'chamberId',
  );
  @override
  late final GeneratedColumn<String> chamberId = GeneratedColumn<String>(
    'chamber_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES chambers (id)',
    ),
  );
  static const VerificationMeta _businessDateMeta = const VerificationMeta(
    'businessDate',
  );
  @override
  late final GeneratedColumn<String> businessDate = GeneratedColumn<String>(
    'business_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _openedAtMeta = const VerificationMeta(
    'openedAt',
  );
  @override
  late final GeneratedColumn<int> openedAt = GeneratedColumn<int>(
    'opened_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _openedByAccountIdMeta = const VerificationMeta(
    'openedByAccountId',
  );
  @override
  late final GeneratedColumn<String> openedByAccountId =
      GeneratedColumn<String>(
        'opened_by_account_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _closedAtMeta = const VerificationMeta(
    'closedAt',
  );
  @override
  late final GeneratedColumn<int> closedAt = GeneratedColumn<int>(
    'closed_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _closedByAccountIdMeta = const VerificationMeta(
    'closedByAccountId',
  );
  @override
  late final GeneratedColumn<String> closedByAccountId =
      GeneratedColumn<String>(
        'closed_by_account_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _closeReasonMeta = const VerificationMeta(
    'closeReason',
  );
  @override
  late final GeneratedColumn<String> closeReason = GeneratedColumn<String>(
    'close_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _configSnapshotJsonMeta =
      const VerificationMeta('configSnapshotJson');
  @override
  late final GeneratedColumn<String> configSnapshotJson =
      GeneratedColumn<String>(
        'config_snapshot_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    chamberId,
    businessDate,
    status,
    openedAt,
    openedByAccountId,
    closedAt,
    closedByAccountId,
    closeReason,
    configSnapshotJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'queue_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<QueueSessionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('chamber_id')) {
      context.handle(
        _chamberIdMeta,
        chamberId.isAcceptableOrUnknown(data['chamber_id']!, _chamberIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chamberIdMeta);
    }
    if (data.containsKey('business_date')) {
      context.handle(
        _businessDateMeta,
        businessDate.isAcceptableOrUnknown(
          data['business_date']!,
          _businessDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_businessDateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('opened_at')) {
      context.handle(
        _openedAtMeta,
        openedAt.isAcceptableOrUnknown(data['opened_at']!, _openedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_openedAtMeta);
    }
    if (data.containsKey('opened_by_account_id')) {
      context.handle(
        _openedByAccountIdMeta,
        openedByAccountId.isAcceptableOrUnknown(
          data['opened_by_account_id']!,
          _openedByAccountIdMeta,
        ),
      );
    }
    if (data.containsKey('closed_at')) {
      context.handle(
        _closedAtMeta,
        closedAt.isAcceptableOrUnknown(data['closed_at']!, _closedAtMeta),
      );
    }
    if (data.containsKey('closed_by_account_id')) {
      context.handle(
        _closedByAccountIdMeta,
        closedByAccountId.isAcceptableOrUnknown(
          data['closed_by_account_id']!,
          _closedByAccountIdMeta,
        ),
      );
    }
    if (data.containsKey('close_reason')) {
      context.handle(
        _closeReasonMeta,
        closeReason.isAcceptableOrUnknown(
          data['close_reason']!,
          _closeReasonMeta,
        ),
      );
    }
    if (data.containsKey('config_snapshot_json')) {
      context.handle(
        _configSnapshotJsonMeta,
        configSnapshotJson.isAcceptableOrUnknown(
          data['config_snapshot_json']!,
          _configSnapshotJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_configSnapshotJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QueueSessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QueueSessionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      chamberId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chamber_id'],
      )!,
      businessDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_date'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      openedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}opened_at'],
      )!,
      openedByAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}opened_by_account_id'],
      ),
      closedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}closed_at'],
      ),
      closedByAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}closed_by_account_id'],
      ),
      closeReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}close_reason'],
      ),
      configSnapshotJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}config_snapshot_json'],
      )!,
    );
  }

  @override
  $QueueSessionsTable createAlias(String alias) {
    return $QueueSessionsTable(attachedDatabase, alias);
  }
}

class QueueSessionRow extends DataClass implements Insertable<QueueSessionRow> {
  final String id;
  final String chamberId;
  final String businessDate;
  final String status;
  final int openedAt;
  final String? openedByAccountId;
  final int? closedAt;
  final String? closedByAccountId;
  final String? closeReason;

  /// Effective queue types and policy at open time (JSON).
  final String configSnapshotJson;
  const QueueSessionRow({
    required this.id,
    required this.chamberId,
    required this.businessDate,
    required this.status,
    required this.openedAt,
    this.openedByAccountId,
    this.closedAt,
    this.closedByAccountId,
    this.closeReason,
    required this.configSnapshotJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['chamber_id'] = Variable<String>(chamberId);
    map['business_date'] = Variable<String>(businessDate);
    map['status'] = Variable<String>(status);
    map['opened_at'] = Variable<int>(openedAt);
    if (!nullToAbsent || openedByAccountId != null) {
      map['opened_by_account_id'] = Variable<String>(openedByAccountId);
    }
    if (!nullToAbsent || closedAt != null) {
      map['closed_at'] = Variable<int>(closedAt);
    }
    if (!nullToAbsent || closedByAccountId != null) {
      map['closed_by_account_id'] = Variable<String>(closedByAccountId);
    }
    if (!nullToAbsent || closeReason != null) {
      map['close_reason'] = Variable<String>(closeReason);
    }
    map['config_snapshot_json'] = Variable<String>(configSnapshotJson);
    return map;
  }

  QueueSessionsCompanion toCompanion(bool nullToAbsent) {
    return QueueSessionsCompanion(
      id: Value(id),
      chamberId: Value(chamberId),
      businessDate: Value(businessDate),
      status: Value(status),
      openedAt: Value(openedAt),
      openedByAccountId: openedByAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(openedByAccountId),
      closedAt: closedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(closedAt),
      closedByAccountId: closedByAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(closedByAccountId),
      closeReason: closeReason == null && nullToAbsent
          ? const Value.absent()
          : Value(closeReason),
      configSnapshotJson: Value(configSnapshotJson),
    );
  }

  factory QueueSessionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QueueSessionRow(
      id: serializer.fromJson<String>(json['id']),
      chamberId: serializer.fromJson<String>(json['chamberId']),
      businessDate: serializer.fromJson<String>(json['businessDate']),
      status: serializer.fromJson<String>(json['status']),
      openedAt: serializer.fromJson<int>(json['openedAt']),
      openedByAccountId: serializer.fromJson<String?>(
        json['openedByAccountId'],
      ),
      closedAt: serializer.fromJson<int?>(json['closedAt']),
      closedByAccountId: serializer.fromJson<String?>(
        json['closedByAccountId'],
      ),
      closeReason: serializer.fromJson<String?>(json['closeReason']),
      configSnapshotJson: serializer.fromJson<String>(
        json['configSnapshotJson'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'chamberId': serializer.toJson<String>(chamberId),
      'businessDate': serializer.toJson<String>(businessDate),
      'status': serializer.toJson<String>(status),
      'openedAt': serializer.toJson<int>(openedAt),
      'openedByAccountId': serializer.toJson<String?>(openedByAccountId),
      'closedAt': serializer.toJson<int?>(closedAt),
      'closedByAccountId': serializer.toJson<String?>(closedByAccountId),
      'closeReason': serializer.toJson<String?>(closeReason),
      'configSnapshotJson': serializer.toJson<String>(configSnapshotJson),
    };
  }

  QueueSessionRow copyWith({
    String? id,
    String? chamberId,
    String? businessDate,
    String? status,
    int? openedAt,
    Value<String?> openedByAccountId = const Value.absent(),
    Value<int?> closedAt = const Value.absent(),
    Value<String?> closedByAccountId = const Value.absent(),
    Value<String?> closeReason = const Value.absent(),
    String? configSnapshotJson,
  }) => QueueSessionRow(
    id: id ?? this.id,
    chamberId: chamberId ?? this.chamberId,
    businessDate: businessDate ?? this.businessDate,
    status: status ?? this.status,
    openedAt: openedAt ?? this.openedAt,
    openedByAccountId: openedByAccountId.present
        ? openedByAccountId.value
        : this.openedByAccountId,
    closedAt: closedAt.present ? closedAt.value : this.closedAt,
    closedByAccountId: closedByAccountId.present
        ? closedByAccountId.value
        : this.closedByAccountId,
    closeReason: closeReason.present ? closeReason.value : this.closeReason,
    configSnapshotJson: configSnapshotJson ?? this.configSnapshotJson,
  );
  QueueSessionRow copyWithCompanion(QueueSessionsCompanion data) {
    return QueueSessionRow(
      id: data.id.present ? data.id.value : this.id,
      chamberId: data.chamberId.present ? data.chamberId.value : this.chamberId,
      businessDate: data.businessDate.present
          ? data.businessDate.value
          : this.businessDate,
      status: data.status.present ? data.status.value : this.status,
      openedAt: data.openedAt.present ? data.openedAt.value : this.openedAt,
      openedByAccountId: data.openedByAccountId.present
          ? data.openedByAccountId.value
          : this.openedByAccountId,
      closedAt: data.closedAt.present ? data.closedAt.value : this.closedAt,
      closedByAccountId: data.closedByAccountId.present
          ? data.closedByAccountId.value
          : this.closedByAccountId,
      closeReason: data.closeReason.present
          ? data.closeReason.value
          : this.closeReason,
      configSnapshotJson: data.configSnapshotJson.present
          ? data.configSnapshotJson.value
          : this.configSnapshotJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QueueSessionRow(')
          ..write('id: $id, ')
          ..write('chamberId: $chamberId, ')
          ..write('businessDate: $businessDate, ')
          ..write('status: $status, ')
          ..write('openedAt: $openedAt, ')
          ..write('openedByAccountId: $openedByAccountId, ')
          ..write('closedAt: $closedAt, ')
          ..write('closedByAccountId: $closedByAccountId, ')
          ..write('closeReason: $closeReason, ')
          ..write('configSnapshotJson: $configSnapshotJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    chamberId,
    businessDate,
    status,
    openedAt,
    openedByAccountId,
    closedAt,
    closedByAccountId,
    closeReason,
    configSnapshotJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QueueSessionRow &&
          other.id == this.id &&
          other.chamberId == this.chamberId &&
          other.businessDate == this.businessDate &&
          other.status == this.status &&
          other.openedAt == this.openedAt &&
          other.openedByAccountId == this.openedByAccountId &&
          other.closedAt == this.closedAt &&
          other.closedByAccountId == this.closedByAccountId &&
          other.closeReason == this.closeReason &&
          other.configSnapshotJson == this.configSnapshotJson);
}

class QueueSessionsCompanion extends UpdateCompanion<QueueSessionRow> {
  final Value<String> id;
  final Value<String> chamberId;
  final Value<String> businessDate;
  final Value<String> status;
  final Value<int> openedAt;
  final Value<String?> openedByAccountId;
  final Value<int?> closedAt;
  final Value<String?> closedByAccountId;
  final Value<String?> closeReason;
  final Value<String> configSnapshotJson;
  final Value<int> rowid;
  const QueueSessionsCompanion({
    this.id = const Value.absent(),
    this.chamberId = const Value.absent(),
    this.businessDate = const Value.absent(),
    this.status = const Value.absent(),
    this.openedAt = const Value.absent(),
    this.openedByAccountId = const Value.absent(),
    this.closedAt = const Value.absent(),
    this.closedByAccountId = const Value.absent(),
    this.closeReason = const Value.absent(),
    this.configSnapshotJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QueueSessionsCompanion.insert({
    required String id,
    required String chamberId,
    required String businessDate,
    required String status,
    required int openedAt,
    this.openedByAccountId = const Value.absent(),
    this.closedAt = const Value.absent(),
    this.closedByAccountId = const Value.absent(),
    this.closeReason = const Value.absent(),
    required String configSnapshotJson,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       chamberId = Value(chamberId),
       businessDate = Value(businessDate),
       status = Value(status),
       openedAt = Value(openedAt),
       configSnapshotJson = Value(configSnapshotJson);
  static Insertable<QueueSessionRow> custom({
    Expression<String>? id,
    Expression<String>? chamberId,
    Expression<String>? businessDate,
    Expression<String>? status,
    Expression<int>? openedAt,
    Expression<String>? openedByAccountId,
    Expression<int>? closedAt,
    Expression<String>? closedByAccountId,
    Expression<String>? closeReason,
    Expression<String>? configSnapshotJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (chamberId != null) 'chamber_id': chamberId,
      if (businessDate != null) 'business_date': businessDate,
      if (status != null) 'status': status,
      if (openedAt != null) 'opened_at': openedAt,
      if (openedByAccountId != null) 'opened_by_account_id': openedByAccountId,
      if (closedAt != null) 'closed_at': closedAt,
      if (closedByAccountId != null) 'closed_by_account_id': closedByAccountId,
      if (closeReason != null) 'close_reason': closeReason,
      if (configSnapshotJson != null)
        'config_snapshot_json': configSnapshotJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QueueSessionsCompanion copyWith({
    Value<String>? id,
    Value<String>? chamberId,
    Value<String>? businessDate,
    Value<String>? status,
    Value<int>? openedAt,
    Value<String?>? openedByAccountId,
    Value<int?>? closedAt,
    Value<String?>? closedByAccountId,
    Value<String?>? closeReason,
    Value<String>? configSnapshotJson,
    Value<int>? rowid,
  }) {
    return QueueSessionsCompanion(
      id: id ?? this.id,
      chamberId: chamberId ?? this.chamberId,
      businessDate: businessDate ?? this.businessDate,
      status: status ?? this.status,
      openedAt: openedAt ?? this.openedAt,
      openedByAccountId: openedByAccountId ?? this.openedByAccountId,
      closedAt: closedAt ?? this.closedAt,
      closedByAccountId: closedByAccountId ?? this.closedByAccountId,
      closeReason: closeReason ?? this.closeReason,
      configSnapshotJson: configSnapshotJson ?? this.configSnapshotJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (chamberId.present) {
      map['chamber_id'] = Variable<String>(chamberId.value);
    }
    if (businessDate.present) {
      map['business_date'] = Variable<String>(businessDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (openedAt.present) {
      map['opened_at'] = Variable<int>(openedAt.value);
    }
    if (openedByAccountId.present) {
      map['opened_by_account_id'] = Variable<String>(openedByAccountId.value);
    }
    if (closedAt.present) {
      map['closed_at'] = Variable<int>(closedAt.value);
    }
    if (closedByAccountId.present) {
      map['closed_by_account_id'] = Variable<String>(closedByAccountId.value);
    }
    if (closeReason.present) {
      map['close_reason'] = Variable<String>(closeReason.value);
    }
    if (configSnapshotJson.present) {
      map['config_snapshot_json'] = Variable<String>(configSnapshotJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QueueSessionsCompanion(')
          ..write('id: $id, ')
          ..write('chamberId: $chamberId, ')
          ..write('businessDate: $businessDate, ')
          ..write('status: $status, ')
          ..write('openedAt: $openedAt, ')
          ..write('openedByAccountId: $openedByAccountId, ')
          ..write('closedAt: $closedAt, ')
          ..write('closedByAccountId: $closedByAccountId, ')
          ..write('closeReason: $closeReason, ')
          ..write('configSnapshotJson: $configSnapshotJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionQueueCountersTable extends SessionQueueCounters
    with TableInfo<$SessionQueueCountersTable, SessionQueueCounterRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionQueueCountersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES queue_sessions (id)',
    ),
  );
  static const VerificationMeta _queueTypeIdMeta = const VerificationMeta(
    'queueTypeId',
  );
  @override
  late final GeneratedColumn<String> queueTypeId = GeneratedColumn<String>(
    'queue_type_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nextNumberMeta = const VerificationMeta(
    'nextNumber',
  );
  @override
  late final GeneratedColumn<int> nextNumber = GeneratedColumn<int>(
    'next_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _issuedCountMeta = const VerificationMeta(
    'issuedCount',
  );
  @override
  late final GeneratedColumn<int> issuedCount = GeneratedColumn<int>(
    'issued_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    sessionId,
    queueTypeId,
    nextNumber,
    issuedCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_queue_counters';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionQueueCounterRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('queue_type_id')) {
      context.handle(
        _queueTypeIdMeta,
        queueTypeId.isAcceptableOrUnknown(
          data['queue_type_id']!,
          _queueTypeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_queueTypeIdMeta);
    }
    if (data.containsKey('next_number')) {
      context.handle(
        _nextNumberMeta,
        nextNumber.isAcceptableOrUnknown(data['next_number']!, _nextNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_nextNumberMeta);
    }
    if (data.containsKey('issued_count')) {
      context.handle(
        _issuedCountMeta,
        issuedCount.isAcceptableOrUnknown(
          data['issued_count']!,
          _issuedCountMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sessionId, queueTypeId};
  @override
  SessionQueueCounterRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionQueueCounterRow(
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      queueTypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}queue_type_id'],
      )!,
      nextNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}next_number'],
      )!,
      issuedCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}issued_count'],
      )!,
    );
  }

  @override
  $SessionQueueCountersTable createAlias(String alias) {
    return $SessionQueueCountersTable(attachedDatabase, alias);
  }
}

class SessionQueueCounterRow extends DataClass
    implements Insertable<SessionQueueCounterRow> {
  final String sessionId;
  final String queueTypeId;
  final int nextNumber;
  final int issuedCount;
  const SessionQueueCounterRow({
    required this.sessionId,
    required this.queueTypeId,
    required this.nextNumber,
    required this.issuedCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['session_id'] = Variable<String>(sessionId);
    map['queue_type_id'] = Variable<String>(queueTypeId);
    map['next_number'] = Variable<int>(nextNumber);
    map['issued_count'] = Variable<int>(issuedCount);
    return map;
  }

  SessionQueueCountersCompanion toCompanion(bool nullToAbsent) {
    return SessionQueueCountersCompanion(
      sessionId: Value(sessionId),
      queueTypeId: Value(queueTypeId),
      nextNumber: Value(nextNumber),
      issuedCount: Value(issuedCount),
    );
  }

  factory SessionQueueCounterRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionQueueCounterRow(
      sessionId: serializer.fromJson<String>(json['sessionId']),
      queueTypeId: serializer.fromJson<String>(json['queueTypeId']),
      nextNumber: serializer.fromJson<int>(json['nextNumber']),
      issuedCount: serializer.fromJson<int>(json['issuedCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sessionId': serializer.toJson<String>(sessionId),
      'queueTypeId': serializer.toJson<String>(queueTypeId),
      'nextNumber': serializer.toJson<int>(nextNumber),
      'issuedCount': serializer.toJson<int>(issuedCount),
    };
  }

  SessionQueueCounterRow copyWith({
    String? sessionId,
    String? queueTypeId,
    int? nextNumber,
    int? issuedCount,
  }) => SessionQueueCounterRow(
    sessionId: sessionId ?? this.sessionId,
    queueTypeId: queueTypeId ?? this.queueTypeId,
    nextNumber: nextNumber ?? this.nextNumber,
    issuedCount: issuedCount ?? this.issuedCount,
  );
  SessionQueueCounterRow copyWithCompanion(SessionQueueCountersCompanion data) {
    return SessionQueueCounterRow(
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      queueTypeId: data.queueTypeId.present
          ? data.queueTypeId.value
          : this.queueTypeId,
      nextNumber: data.nextNumber.present
          ? data.nextNumber.value
          : this.nextNumber,
      issuedCount: data.issuedCount.present
          ? data.issuedCount.value
          : this.issuedCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionQueueCounterRow(')
          ..write('sessionId: $sessionId, ')
          ..write('queueTypeId: $queueTypeId, ')
          ..write('nextNumber: $nextNumber, ')
          ..write('issuedCount: $issuedCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(sessionId, queueTypeId, nextNumber, issuedCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionQueueCounterRow &&
          other.sessionId == this.sessionId &&
          other.queueTypeId == this.queueTypeId &&
          other.nextNumber == this.nextNumber &&
          other.issuedCount == this.issuedCount);
}

class SessionQueueCountersCompanion
    extends UpdateCompanion<SessionQueueCounterRow> {
  final Value<String> sessionId;
  final Value<String> queueTypeId;
  final Value<int> nextNumber;
  final Value<int> issuedCount;
  final Value<int> rowid;
  const SessionQueueCountersCompanion({
    this.sessionId = const Value.absent(),
    this.queueTypeId = const Value.absent(),
    this.nextNumber = const Value.absent(),
    this.issuedCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionQueueCountersCompanion.insert({
    required String sessionId,
    required String queueTypeId,
    required int nextNumber,
    this.issuedCount = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : sessionId = Value(sessionId),
       queueTypeId = Value(queueTypeId),
       nextNumber = Value(nextNumber);
  static Insertable<SessionQueueCounterRow> custom({
    Expression<String>? sessionId,
    Expression<String>? queueTypeId,
    Expression<int>? nextNumber,
    Expression<int>? issuedCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sessionId != null) 'session_id': sessionId,
      if (queueTypeId != null) 'queue_type_id': queueTypeId,
      if (nextNumber != null) 'next_number': nextNumber,
      if (issuedCount != null) 'issued_count': issuedCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionQueueCountersCompanion copyWith({
    Value<String>? sessionId,
    Value<String>? queueTypeId,
    Value<int>? nextNumber,
    Value<int>? issuedCount,
    Value<int>? rowid,
  }) {
    return SessionQueueCountersCompanion(
      sessionId: sessionId ?? this.sessionId,
      queueTypeId: queueTypeId ?? this.queueTypeId,
      nextNumber: nextNumber ?? this.nextNumber,
      issuedCount: issuedCount ?? this.issuedCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (queueTypeId.present) {
      map['queue_type_id'] = Variable<String>(queueTypeId.value);
    }
    if (nextNumber.present) {
      map['next_number'] = Variable<int>(nextNumber.value);
    }
    if (issuedCount.present) {
      map['issued_count'] = Variable<int>(issuedCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionQueueCountersCompanion(')
          ..write('sessionId: $sessionId, ')
          ..write('queueTypeId: $queueTypeId, ')
          ..write('nextNumber: $nextNumber, ')
          ..write('issuedCount: $issuedCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PatientsTable extends Patients
    with TableInfo<$PatientsTable, PatientRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PatientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _patientNumberMeta = const VerificationMeta(
    'patientNumber',
  );
  @override
  late final GeneratedColumn<int> patientNumber = GeneratedColumn<int>(
    'patient_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _bengaliNameMeta = const VerificationMeta(
    'bengaliName',
  );
  @override
  late final GeneratedColumn<String> bengaliName = GeneratedColumn<String>(
    'bengali_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _englishNameMeta = const VerificationMeta(
    'englishName',
  );
  @override
  late final GeneratedColumn<String> englishName = GeneratedColumn<String>(
    'english_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneNormalizedMeta = const VerificationMeta(
    'phoneNormalized',
  );
  @override
  late final GeneratedColumn<String> phoneNormalized = GeneratedColumn<String>(
    'phone_normalized',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
    'gender',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateOfBirthMsMeta = const VerificationMeta(
    'dateOfBirthMs',
  );
  @override
  late final GeneratedColumn<int> dateOfBirthMs = GeneratedColumn<int>(
    'date_of_birth_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _birthYearMeta = const VerificationMeta(
    'birthYear',
  );
  @override
  late final GeneratedColumn<int> birthYear = GeneratedColumn<int>(
    'birth_year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _approximateAgeYearsMeta =
      const VerificationMeta('approximateAgeYears');
  @override
  late final GeneratedColumn<int> approximateAgeYears = GeneratedColumn<int>(
    'approximate_age_years',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _approximateAgeRecordedAtMeta =
      const VerificationMeta('approximateAgeRecordedAt');
  @override
  late final GeneratedColumn<int> approximateAgeRecordedAt =
      GeneratedColumn<int>(
        'approximate_age_recorded_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _localityMeta = const VerificationMeta(
    'locality',
  );
  @override
  late final GeneratedColumn<String> locality = GeneratedColumn<String>(
    'locality',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _legacyFileNumberMeta = const VerificationMeta(
    'legacyFileNumber',
  );
  @override
  late final GeneratedColumn<String> legacyFileNumber = GeneratedColumn<String>(
    'legacy_file_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _adminNoteMeta = const VerificationMeta(
    'adminNote',
  );
  @override
  late final GeneratedColumn<String> adminNote = GeneratedColumn<String>(
    'admin_note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hasPaperFileMeta = const VerificationMeta(
    'hasPaperFile',
  );
  @override
  late final GeneratedColumn<bool> hasPaperFile = GeneratedColumn<bool>(
    'has_paper_file',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_paper_file" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    patientNumber,
    bengaliName,
    englishName,
    phoneNormalized,
    gender,
    dateOfBirthMs,
    birthYear,
    approximateAgeYears,
    approximateAgeRecordedAt,
    locality,
    legacyFileNumber,
    adminNote,
    hasPaperFile,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'patients';
  @override
  VerificationContext validateIntegrity(
    Insertable<PatientRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('patient_number')) {
      context.handle(
        _patientNumberMeta,
        patientNumber.isAcceptableOrUnknown(
          data['patient_number']!,
          _patientNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_patientNumberMeta);
    }
    if (data.containsKey('bengali_name')) {
      context.handle(
        _bengaliNameMeta,
        bengaliName.isAcceptableOrUnknown(
          data['bengali_name']!,
          _bengaliNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_bengaliNameMeta);
    }
    if (data.containsKey('english_name')) {
      context.handle(
        _englishNameMeta,
        englishName.isAcceptableOrUnknown(
          data['english_name']!,
          _englishNameMeta,
        ),
      );
    }
    if (data.containsKey('phone_normalized')) {
      context.handle(
        _phoneNormalizedMeta,
        phoneNormalized.isAcceptableOrUnknown(
          data['phone_normalized']!,
          _phoneNormalizedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_phoneNormalizedMeta);
    }
    if (data.containsKey('gender')) {
      context.handle(
        _genderMeta,
        gender.isAcceptableOrUnknown(data['gender']!, _genderMeta),
      );
    }
    if (data.containsKey('date_of_birth_ms')) {
      context.handle(
        _dateOfBirthMsMeta,
        dateOfBirthMs.isAcceptableOrUnknown(
          data['date_of_birth_ms']!,
          _dateOfBirthMsMeta,
        ),
      );
    }
    if (data.containsKey('birth_year')) {
      context.handle(
        _birthYearMeta,
        birthYear.isAcceptableOrUnknown(data['birth_year']!, _birthYearMeta),
      );
    }
    if (data.containsKey('approximate_age_years')) {
      context.handle(
        _approximateAgeYearsMeta,
        approximateAgeYears.isAcceptableOrUnknown(
          data['approximate_age_years']!,
          _approximateAgeYearsMeta,
        ),
      );
    }
    if (data.containsKey('approximate_age_recorded_at')) {
      context.handle(
        _approximateAgeRecordedAtMeta,
        approximateAgeRecordedAt.isAcceptableOrUnknown(
          data['approximate_age_recorded_at']!,
          _approximateAgeRecordedAtMeta,
        ),
      );
    }
    if (data.containsKey('locality')) {
      context.handle(
        _localityMeta,
        locality.isAcceptableOrUnknown(data['locality']!, _localityMeta),
      );
    }
    if (data.containsKey('legacy_file_number')) {
      context.handle(
        _legacyFileNumberMeta,
        legacyFileNumber.isAcceptableOrUnknown(
          data['legacy_file_number']!,
          _legacyFileNumberMeta,
        ),
      );
    }
    if (data.containsKey('admin_note')) {
      context.handle(
        _adminNoteMeta,
        adminNote.isAcceptableOrUnknown(data['admin_note']!, _adminNoteMeta),
      );
    }
    if (data.containsKey('has_paper_file')) {
      context.handle(
        _hasPaperFileMeta,
        hasPaperFile.isAcceptableOrUnknown(
          data['has_paper_file']!,
          _hasPaperFileMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PatientRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PatientRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      patientNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}patient_number'],
      )!,
      bengaliName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bengali_name'],
      )!,
      englishName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}english_name'],
      ),
      phoneNormalized: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone_normalized'],
      )!,
      gender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gender'],
      ),
      dateOfBirthMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}date_of_birth_ms'],
      ),
      birthYear: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}birth_year'],
      ),
      approximateAgeYears: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}approximate_age_years'],
      ),
      approximateAgeRecordedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}approximate_age_recorded_at'],
      ),
      locality: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locality'],
      ),
      legacyFileNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}legacy_file_number'],
      ),
      adminNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}admin_note'],
      ),
      hasPaperFile: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_paper_file'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PatientsTable createAlias(String alias) {
    return $PatientsTable(attachedDatabase, alias);
  }
}

class PatientRow extends DataClass implements Insertable<PatientRow> {
  final String id;
  final int patientNumber;
  final String bengaliName;
  final String? englishName;
  final String phoneNormalized;
  final String? gender;
  final int? dateOfBirthMs;
  final int? birthYear;
  final int? approximateAgeYears;
  final int? approximateAgeRecordedAt;
  final String? locality;
  final String? legacyFileNumber;
  final String? adminNote;
  final bool hasPaperFile;
  final int createdAt;
  const PatientRow({
    required this.id,
    required this.patientNumber,
    required this.bengaliName,
    this.englishName,
    required this.phoneNormalized,
    this.gender,
    this.dateOfBirthMs,
    this.birthYear,
    this.approximateAgeYears,
    this.approximateAgeRecordedAt,
    this.locality,
    this.legacyFileNumber,
    this.adminNote,
    required this.hasPaperFile,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['patient_number'] = Variable<int>(patientNumber);
    map['bengali_name'] = Variable<String>(bengaliName);
    if (!nullToAbsent || englishName != null) {
      map['english_name'] = Variable<String>(englishName);
    }
    map['phone_normalized'] = Variable<String>(phoneNormalized);
    if (!nullToAbsent || gender != null) {
      map['gender'] = Variable<String>(gender);
    }
    if (!nullToAbsent || dateOfBirthMs != null) {
      map['date_of_birth_ms'] = Variable<int>(dateOfBirthMs);
    }
    if (!nullToAbsent || birthYear != null) {
      map['birth_year'] = Variable<int>(birthYear);
    }
    if (!nullToAbsent || approximateAgeYears != null) {
      map['approximate_age_years'] = Variable<int>(approximateAgeYears);
    }
    if (!nullToAbsent || approximateAgeRecordedAt != null) {
      map['approximate_age_recorded_at'] = Variable<int>(
        approximateAgeRecordedAt,
      );
    }
    if (!nullToAbsent || locality != null) {
      map['locality'] = Variable<String>(locality);
    }
    if (!nullToAbsent || legacyFileNumber != null) {
      map['legacy_file_number'] = Variable<String>(legacyFileNumber);
    }
    if (!nullToAbsent || adminNote != null) {
      map['admin_note'] = Variable<String>(adminNote);
    }
    map['has_paper_file'] = Variable<bool>(hasPaperFile);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  PatientsCompanion toCompanion(bool nullToAbsent) {
    return PatientsCompanion(
      id: Value(id),
      patientNumber: Value(patientNumber),
      bengaliName: Value(bengaliName),
      englishName: englishName == null && nullToAbsent
          ? const Value.absent()
          : Value(englishName),
      phoneNormalized: Value(phoneNormalized),
      gender: gender == null && nullToAbsent
          ? const Value.absent()
          : Value(gender),
      dateOfBirthMs: dateOfBirthMs == null && nullToAbsent
          ? const Value.absent()
          : Value(dateOfBirthMs),
      birthYear: birthYear == null && nullToAbsent
          ? const Value.absent()
          : Value(birthYear),
      approximateAgeYears: approximateAgeYears == null && nullToAbsent
          ? const Value.absent()
          : Value(approximateAgeYears),
      approximateAgeRecordedAt: approximateAgeRecordedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(approximateAgeRecordedAt),
      locality: locality == null && nullToAbsent
          ? const Value.absent()
          : Value(locality),
      legacyFileNumber: legacyFileNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(legacyFileNumber),
      adminNote: adminNote == null && nullToAbsent
          ? const Value.absent()
          : Value(adminNote),
      hasPaperFile: Value(hasPaperFile),
      createdAt: Value(createdAt),
    );
  }

  factory PatientRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PatientRow(
      id: serializer.fromJson<String>(json['id']),
      patientNumber: serializer.fromJson<int>(json['patientNumber']),
      bengaliName: serializer.fromJson<String>(json['bengaliName']),
      englishName: serializer.fromJson<String?>(json['englishName']),
      phoneNormalized: serializer.fromJson<String>(json['phoneNormalized']),
      gender: serializer.fromJson<String?>(json['gender']),
      dateOfBirthMs: serializer.fromJson<int?>(json['dateOfBirthMs']),
      birthYear: serializer.fromJson<int?>(json['birthYear']),
      approximateAgeYears: serializer.fromJson<int?>(
        json['approximateAgeYears'],
      ),
      approximateAgeRecordedAt: serializer.fromJson<int?>(
        json['approximateAgeRecordedAt'],
      ),
      locality: serializer.fromJson<String?>(json['locality']),
      legacyFileNumber: serializer.fromJson<String?>(json['legacyFileNumber']),
      adminNote: serializer.fromJson<String?>(json['adminNote']),
      hasPaperFile: serializer.fromJson<bool>(json['hasPaperFile']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'patientNumber': serializer.toJson<int>(patientNumber),
      'bengaliName': serializer.toJson<String>(bengaliName),
      'englishName': serializer.toJson<String?>(englishName),
      'phoneNormalized': serializer.toJson<String>(phoneNormalized),
      'gender': serializer.toJson<String?>(gender),
      'dateOfBirthMs': serializer.toJson<int?>(dateOfBirthMs),
      'birthYear': serializer.toJson<int?>(birthYear),
      'approximateAgeYears': serializer.toJson<int?>(approximateAgeYears),
      'approximateAgeRecordedAt': serializer.toJson<int?>(
        approximateAgeRecordedAt,
      ),
      'locality': serializer.toJson<String?>(locality),
      'legacyFileNumber': serializer.toJson<String?>(legacyFileNumber),
      'adminNote': serializer.toJson<String?>(adminNote),
      'hasPaperFile': serializer.toJson<bool>(hasPaperFile),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  PatientRow copyWith({
    String? id,
    int? patientNumber,
    String? bengaliName,
    Value<String?> englishName = const Value.absent(),
    String? phoneNormalized,
    Value<String?> gender = const Value.absent(),
    Value<int?> dateOfBirthMs = const Value.absent(),
    Value<int?> birthYear = const Value.absent(),
    Value<int?> approximateAgeYears = const Value.absent(),
    Value<int?> approximateAgeRecordedAt = const Value.absent(),
    Value<String?> locality = const Value.absent(),
    Value<String?> legacyFileNumber = const Value.absent(),
    Value<String?> adminNote = const Value.absent(),
    bool? hasPaperFile,
    int? createdAt,
  }) => PatientRow(
    id: id ?? this.id,
    patientNumber: patientNumber ?? this.patientNumber,
    bengaliName: bengaliName ?? this.bengaliName,
    englishName: englishName.present ? englishName.value : this.englishName,
    phoneNormalized: phoneNormalized ?? this.phoneNormalized,
    gender: gender.present ? gender.value : this.gender,
    dateOfBirthMs: dateOfBirthMs.present
        ? dateOfBirthMs.value
        : this.dateOfBirthMs,
    birthYear: birthYear.present ? birthYear.value : this.birthYear,
    approximateAgeYears: approximateAgeYears.present
        ? approximateAgeYears.value
        : this.approximateAgeYears,
    approximateAgeRecordedAt: approximateAgeRecordedAt.present
        ? approximateAgeRecordedAt.value
        : this.approximateAgeRecordedAt,
    locality: locality.present ? locality.value : this.locality,
    legacyFileNumber: legacyFileNumber.present
        ? legacyFileNumber.value
        : this.legacyFileNumber,
    adminNote: adminNote.present ? adminNote.value : this.adminNote,
    hasPaperFile: hasPaperFile ?? this.hasPaperFile,
    createdAt: createdAt ?? this.createdAt,
  );
  PatientRow copyWithCompanion(PatientsCompanion data) {
    return PatientRow(
      id: data.id.present ? data.id.value : this.id,
      patientNumber: data.patientNumber.present
          ? data.patientNumber.value
          : this.patientNumber,
      bengaliName: data.bengaliName.present
          ? data.bengaliName.value
          : this.bengaliName,
      englishName: data.englishName.present
          ? data.englishName.value
          : this.englishName,
      phoneNormalized: data.phoneNormalized.present
          ? data.phoneNormalized.value
          : this.phoneNormalized,
      gender: data.gender.present ? data.gender.value : this.gender,
      dateOfBirthMs: data.dateOfBirthMs.present
          ? data.dateOfBirthMs.value
          : this.dateOfBirthMs,
      birthYear: data.birthYear.present ? data.birthYear.value : this.birthYear,
      approximateAgeYears: data.approximateAgeYears.present
          ? data.approximateAgeYears.value
          : this.approximateAgeYears,
      approximateAgeRecordedAt: data.approximateAgeRecordedAt.present
          ? data.approximateAgeRecordedAt.value
          : this.approximateAgeRecordedAt,
      locality: data.locality.present ? data.locality.value : this.locality,
      legacyFileNumber: data.legacyFileNumber.present
          ? data.legacyFileNumber.value
          : this.legacyFileNumber,
      adminNote: data.adminNote.present ? data.adminNote.value : this.adminNote,
      hasPaperFile: data.hasPaperFile.present
          ? data.hasPaperFile.value
          : this.hasPaperFile,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PatientRow(')
          ..write('id: $id, ')
          ..write('patientNumber: $patientNumber, ')
          ..write('bengaliName: $bengaliName, ')
          ..write('englishName: $englishName, ')
          ..write('phoneNormalized: $phoneNormalized, ')
          ..write('gender: $gender, ')
          ..write('dateOfBirthMs: $dateOfBirthMs, ')
          ..write('birthYear: $birthYear, ')
          ..write('approximateAgeYears: $approximateAgeYears, ')
          ..write('approximateAgeRecordedAt: $approximateAgeRecordedAt, ')
          ..write('locality: $locality, ')
          ..write('legacyFileNumber: $legacyFileNumber, ')
          ..write('adminNote: $adminNote, ')
          ..write('hasPaperFile: $hasPaperFile, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    patientNumber,
    bengaliName,
    englishName,
    phoneNormalized,
    gender,
    dateOfBirthMs,
    birthYear,
    approximateAgeYears,
    approximateAgeRecordedAt,
    locality,
    legacyFileNumber,
    adminNote,
    hasPaperFile,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PatientRow &&
          other.id == this.id &&
          other.patientNumber == this.patientNumber &&
          other.bengaliName == this.bengaliName &&
          other.englishName == this.englishName &&
          other.phoneNormalized == this.phoneNormalized &&
          other.gender == this.gender &&
          other.dateOfBirthMs == this.dateOfBirthMs &&
          other.birthYear == this.birthYear &&
          other.approximateAgeYears == this.approximateAgeYears &&
          other.approximateAgeRecordedAt == this.approximateAgeRecordedAt &&
          other.locality == this.locality &&
          other.legacyFileNumber == this.legacyFileNumber &&
          other.adminNote == this.adminNote &&
          other.hasPaperFile == this.hasPaperFile &&
          other.createdAt == this.createdAt);
}

class PatientsCompanion extends UpdateCompanion<PatientRow> {
  final Value<String> id;
  final Value<int> patientNumber;
  final Value<String> bengaliName;
  final Value<String?> englishName;
  final Value<String> phoneNormalized;
  final Value<String?> gender;
  final Value<int?> dateOfBirthMs;
  final Value<int?> birthYear;
  final Value<int?> approximateAgeYears;
  final Value<int?> approximateAgeRecordedAt;
  final Value<String?> locality;
  final Value<String?> legacyFileNumber;
  final Value<String?> adminNote;
  final Value<bool> hasPaperFile;
  final Value<int> createdAt;
  final Value<int> rowid;
  const PatientsCompanion({
    this.id = const Value.absent(),
    this.patientNumber = const Value.absent(),
    this.bengaliName = const Value.absent(),
    this.englishName = const Value.absent(),
    this.phoneNormalized = const Value.absent(),
    this.gender = const Value.absent(),
    this.dateOfBirthMs = const Value.absent(),
    this.birthYear = const Value.absent(),
    this.approximateAgeYears = const Value.absent(),
    this.approximateAgeRecordedAt = const Value.absent(),
    this.locality = const Value.absent(),
    this.legacyFileNumber = const Value.absent(),
    this.adminNote = const Value.absent(),
    this.hasPaperFile = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PatientsCompanion.insert({
    required String id,
    required int patientNumber,
    required String bengaliName,
    this.englishName = const Value.absent(),
    required String phoneNormalized,
    this.gender = const Value.absent(),
    this.dateOfBirthMs = const Value.absent(),
    this.birthYear = const Value.absent(),
    this.approximateAgeYears = const Value.absent(),
    this.approximateAgeRecordedAt = const Value.absent(),
    this.locality = const Value.absent(),
    this.legacyFileNumber = const Value.absent(),
    this.adminNote = const Value.absent(),
    this.hasPaperFile = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       patientNumber = Value(patientNumber),
       bengaliName = Value(bengaliName),
       phoneNormalized = Value(phoneNormalized),
       createdAt = Value(createdAt);
  static Insertable<PatientRow> custom({
    Expression<String>? id,
    Expression<int>? patientNumber,
    Expression<String>? bengaliName,
    Expression<String>? englishName,
    Expression<String>? phoneNormalized,
    Expression<String>? gender,
    Expression<int>? dateOfBirthMs,
    Expression<int>? birthYear,
    Expression<int>? approximateAgeYears,
    Expression<int>? approximateAgeRecordedAt,
    Expression<String>? locality,
    Expression<String>? legacyFileNumber,
    Expression<String>? adminNote,
    Expression<bool>? hasPaperFile,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (patientNumber != null) 'patient_number': patientNumber,
      if (bengaliName != null) 'bengali_name': bengaliName,
      if (englishName != null) 'english_name': englishName,
      if (phoneNormalized != null) 'phone_normalized': phoneNormalized,
      if (gender != null) 'gender': gender,
      if (dateOfBirthMs != null) 'date_of_birth_ms': dateOfBirthMs,
      if (birthYear != null) 'birth_year': birthYear,
      if (approximateAgeYears != null)
        'approximate_age_years': approximateAgeYears,
      if (approximateAgeRecordedAt != null)
        'approximate_age_recorded_at': approximateAgeRecordedAt,
      if (locality != null) 'locality': locality,
      if (legacyFileNumber != null) 'legacy_file_number': legacyFileNumber,
      if (adminNote != null) 'admin_note': adminNote,
      if (hasPaperFile != null) 'has_paper_file': hasPaperFile,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PatientsCompanion copyWith({
    Value<String>? id,
    Value<int>? patientNumber,
    Value<String>? bengaliName,
    Value<String?>? englishName,
    Value<String>? phoneNormalized,
    Value<String?>? gender,
    Value<int?>? dateOfBirthMs,
    Value<int?>? birthYear,
    Value<int?>? approximateAgeYears,
    Value<int?>? approximateAgeRecordedAt,
    Value<String?>? locality,
    Value<String?>? legacyFileNumber,
    Value<String?>? adminNote,
    Value<bool>? hasPaperFile,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return PatientsCompanion(
      id: id ?? this.id,
      patientNumber: patientNumber ?? this.patientNumber,
      bengaliName: bengaliName ?? this.bengaliName,
      englishName: englishName ?? this.englishName,
      phoneNormalized: phoneNormalized ?? this.phoneNormalized,
      gender: gender ?? this.gender,
      dateOfBirthMs: dateOfBirthMs ?? this.dateOfBirthMs,
      birthYear: birthYear ?? this.birthYear,
      approximateAgeYears: approximateAgeYears ?? this.approximateAgeYears,
      approximateAgeRecordedAt:
          approximateAgeRecordedAt ?? this.approximateAgeRecordedAt,
      locality: locality ?? this.locality,
      legacyFileNumber: legacyFileNumber ?? this.legacyFileNumber,
      adminNote: adminNote ?? this.adminNote,
      hasPaperFile: hasPaperFile ?? this.hasPaperFile,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (patientNumber.present) {
      map['patient_number'] = Variable<int>(patientNumber.value);
    }
    if (bengaliName.present) {
      map['bengali_name'] = Variable<String>(bengaliName.value);
    }
    if (englishName.present) {
      map['english_name'] = Variable<String>(englishName.value);
    }
    if (phoneNormalized.present) {
      map['phone_normalized'] = Variable<String>(phoneNormalized.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (dateOfBirthMs.present) {
      map['date_of_birth_ms'] = Variable<int>(dateOfBirthMs.value);
    }
    if (birthYear.present) {
      map['birth_year'] = Variable<int>(birthYear.value);
    }
    if (approximateAgeYears.present) {
      map['approximate_age_years'] = Variable<int>(approximateAgeYears.value);
    }
    if (approximateAgeRecordedAt.present) {
      map['approximate_age_recorded_at'] = Variable<int>(
        approximateAgeRecordedAt.value,
      );
    }
    if (locality.present) {
      map['locality'] = Variable<String>(locality.value);
    }
    if (legacyFileNumber.present) {
      map['legacy_file_number'] = Variable<String>(legacyFileNumber.value);
    }
    if (adminNote.present) {
      map['admin_note'] = Variable<String>(adminNote.value);
    }
    if (hasPaperFile.present) {
      map['has_paper_file'] = Variable<bool>(hasPaperFile.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PatientsCompanion(')
          ..write('id: $id, ')
          ..write('patientNumber: $patientNumber, ')
          ..write('bengaliName: $bengaliName, ')
          ..write('englishName: $englishName, ')
          ..write('phoneNormalized: $phoneNormalized, ')
          ..write('gender: $gender, ')
          ..write('dateOfBirthMs: $dateOfBirthMs, ')
          ..write('birthYear: $birthYear, ')
          ..write('approximateAgeYears: $approximateAgeYears, ')
          ..write('approximateAgeRecordedAt: $approximateAgeRecordedAt, ')
          ..write('locality: $locality, ')
          ..write('legacyFileNumber: $legacyFileNumber, ')
          ..write('adminNote: $adminNote, ')
          ..write('hasPaperFile: $hasPaperFile, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $IdempotentCommandsTable extends IdempotentCommands
    with TableInfo<$IdempotentCommandsTable, IdempotentCommandRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IdempotentCommandsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _commandIdMeta = const VerificationMeta(
    'commandId',
  );
  @override
  late final GeneratedColumn<String> commandId = GeneratedColumn<String>(
    'command_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resultJsonMeta = const VerificationMeta(
    'resultJson',
  );
  @override
  late final GeneratedColumn<String> resultJson = GeneratedColumn<String>(
    'result_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [commandId, resultJson, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'idempotent_commands';
  @override
  VerificationContext validateIntegrity(
    Insertable<IdempotentCommandRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('command_id')) {
      context.handle(
        _commandIdMeta,
        commandId.isAcceptableOrUnknown(data['command_id']!, _commandIdMeta),
      );
    } else if (isInserting) {
      context.missing(_commandIdMeta);
    }
    if (data.containsKey('result_json')) {
      context.handle(
        _resultJsonMeta,
        resultJson.isAcceptableOrUnknown(data['result_json']!, _resultJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_resultJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {commandId};
  @override
  IdempotentCommandRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IdempotentCommandRow(
      commandId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}command_id'],
      )!,
      resultJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}result_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $IdempotentCommandsTable createAlias(String alias) {
    return $IdempotentCommandsTable(attachedDatabase, alias);
  }
}

class IdempotentCommandRow extends DataClass
    implements Insertable<IdempotentCommandRow> {
  final String commandId;
  final String resultJson;
  final int createdAt;
  const IdempotentCommandRow({
    required this.commandId,
    required this.resultJson,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['command_id'] = Variable<String>(commandId);
    map['result_json'] = Variable<String>(resultJson);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  IdempotentCommandsCompanion toCompanion(bool nullToAbsent) {
    return IdempotentCommandsCompanion(
      commandId: Value(commandId),
      resultJson: Value(resultJson),
      createdAt: Value(createdAt),
    );
  }

  factory IdempotentCommandRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IdempotentCommandRow(
      commandId: serializer.fromJson<String>(json['commandId']),
      resultJson: serializer.fromJson<String>(json['resultJson']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'commandId': serializer.toJson<String>(commandId),
      'resultJson': serializer.toJson<String>(resultJson),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  IdempotentCommandRow copyWith({
    String? commandId,
    String? resultJson,
    int? createdAt,
  }) => IdempotentCommandRow(
    commandId: commandId ?? this.commandId,
    resultJson: resultJson ?? this.resultJson,
    createdAt: createdAt ?? this.createdAt,
  );
  IdempotentCommandRow copyWithCompanion(IdempotentCommandsCompanion data) {
    return IdempotentCommandRow(
      commandId: data.commandId.present ? data.commandId.value : this.commandId,
      resultJson: data.resultJson.present
          ? data.resultJson.value
          : this.resultJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IdempotentCommandRow(')
          ..write('commandId: $commandId, ')
          ..write('resultJson: $resultJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(commandId, resultJson, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IdempotentCommandRow &&
          other.commandId == this.commandId &&
          other.resultJson == this.resultJson &&
          other.createdAt == this.createdAt);
}

class IdempotentCommandsCompanion
    extends UpdateCompanion<IdempotentCommandRow> {
  final Value<String> commandId;
  final Value<String> resultJson;
  final Value<int> createdAt;
  final Value<int> rowid;
  const IdempotentCommandsCompanion({
    this.commandId = const Value.absent(),
    this.resultJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IdempotentCommandsCompanion.insert({
    required String commandId,
    required String resultJson,
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : commandId = Value(commandId),
       resultJson = Value(resultJson),
       createdAt = Value(createdAt);
  static Insertable<IdempotentCommandRow> custom({
    Expression<String>? commandId,
    Expression<String>? resultJson,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (commandId != null) 'command_id': commandId,
      if (resultJson != null) 'result_json': resultJson,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IdempotentCommandsCompanion copyWith({
    Value<String>? commandId,
    Value<String>? resultJson,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return IdempotentCommandsCompanion(
      commandId: commandId ?? this.commandId,
      resultJson: resultJson ?? this.resultJson,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (commandId.present) {
      map['command_id'] = Variable<String>(commandId.value);
    }
    if (resultJson.present) {
      map['result_json'] = Variable<String>(resultJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IdempotentCommandsCompanion(')
          ..write('commandId: $commandId, ')
          ..write('resultJson: $resultJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QueueTokensTable extends QueueTokens
    with TableInfo<$QueueTokensTable, QueueTokenRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QueueTokensTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES queue_sessions (id)',
    ),
  );
  static const VerificationMeta _chamberIdMeta = const VerificationMeta(
    'chamberId',
  );
  @override
  late final GeneratedColumn<String> chamberId = GeneratedColumn<String>(
    'chamber_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES chambers (id)',
    ),
  );
  static const VerificationMeta _patientIdMeta = const VerificationMeta(
    'patientId',
  );
  @override
  late final GeneratedColumn<String> patientId = GeneratedColumn<String>(
    'patient_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES patients (id)',
    ),
  );
  static const VerificationMeta _queueTypeIdMeta = const VerificationMeta(
    'queueTypeId',
  );
  @override
  late final GeneratedColumn<String> queueTypeId = GeneratedColumn<String>(
    'queue_type_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serialMeta = const VerificationMeta('serial');
  @override
  late final GeneratedColumn<int> serial = GeneratedColumn<int>(
    'serial',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _feeBdtMeta = const VerificationMeta('feeBdt');
  @override
  late final GeneratedColumn<int> feeBdt = GeneratedColumn<int>(
    'fee_bdt',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _issuedAtMeta = const VerificationMeta(
    'issuedAt',
  );
  @override
  late final GeneratedColumn<int> issuedAt = GeneratedColumn<int>(
    'issued_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firstCalledAtMeta = const VerificationMeta(
    'firstCalledAt',
  );
  @override
  late final GeneratedColumn<int> firstCalledAt = GeneratedColumn<int>(
    'first_called_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _enteredAtMeta = const VerificationMeta(
    'enteredAt',
  );
  @override
  late final GeneratedColumn<int> enteredAt = GeneratedColumn<int>(
    'entered_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cancelledAtMeta = const VerificationMeta(
    'cancelledAt',
  );
  @override
  late final GeneratedColumn<int> cancelledAt = GeneratedColumn<int>(
    'cancelled_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cancelReasonMeta = const VerificationMeta(
    'cancelReason',
  );
  @override
  late final GeneratedColumn<String> cancelReason = GeneratedColumn<String>(
    'cancel_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _latestPrintStatusMeta = const VerificationMeta(
    'latestPrintStatus',
  );
  @override
  late final GeneratedColumn<String> latestPrintStatus =
      GeneratedColumn<String>(
        'latest_print_status',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    chamberId,
    patientId,
    queueTypeId,
    serial,
    status,
    feeBdt,
    issuedAt,
    firstCalledAt,
    enteredAt,
    cancelledAt,
    cancelReason,
    latestPrintStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'queue_tokens';
  @override
  VerificationContext validateIntegrity(
    Insertable<QueueTokenRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('chamber_id')) {
      context.handle(
        _chamberIdMeta,
        chamberId.isAcceptableOrUnknown(data['chamber_id']!, _chamberIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chamberIdMeta);
    }
    if (data.containsKey('patient_id')) {
      context.handle(
        _patientIdMeta,
        patientId.isAcceptableOrUnknown(data['patient_id']!, _patientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_patientIdMeta);
    }
    if (data.containsKey('queue_type_id')) {
      context.handle(
        _queueTypeIdMeta,
        queueTypeId.isAcceptableOrUnknown(
          data['queue_type_id']!,
          _queueTypeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_queueTypeIdMeta);
    }
    if (data.containsKey('serial')) {
      context.handle(
        _serialMeta,
        serial.isAcceptableOrUnknown(data['serial']!, _serialMeta),
      );
    } else if (isInserting) {
      context.missing(_serialMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('fee_bdt')) {
      context.handle(
        _feeBdtMeta,
        feeBdt.isAcceptableOrUnknown(data['fee_bdt']!, _feeBdtMeta),
      );
    }
    if (data.containsKey('issued_at')) {
      context.handle(
        _issuedAtMeta,
        issuedAt.isAcceptableOrUnknown(data['issued_at']!, _issuedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_issuedAtMeta);
    }
    if (data.containsKey('first_called_at')) {
      context.handle(
        _firstCalledAtMeta,
        firstCalledAt.isAcceptableOrUnknown(
          data['first_called_at']!,
          _firstCalledAtMeta,
        ),
      );
    }
    if (data.containsKey('entered_at')) {
      context.handle(
        _enteredAtMeta,
        enteredAt.isAcceptableOrUnknown(data['entered_at']!, _enteredAtMeta),
      );
    }
    if (data.containsKey('cancelled_at')) {
      context.handle(
        _cancelledAtMeta,
        cancelledAt.isAcceptableOrUnknown(
          data['cancelled_at']!,
          _cancelledAtMeta,
        ),
      );
    }
    if (data.containsKey('cancel_reason')) {
      context.handle(
        _cancelReasonMeta,
        cancelReason.isAcceptableOrUnknown(
          data['cancel_reason']!,
          _cancelReasonMeta,
        ),
      );
    }
    if (data.containsKey('latest_print_status')) {
      context.handle(
        _latestPrintStatusMeta,
        latestPrintStatus.isAcceptableOrUnknown(
          data['latest_print_status']!,
          _latestPrintStatusMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QueueTokenRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QueueTokenRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      chamberId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chamber_id'],
      )!,
      patientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}patient_id'],
      )!,
      queueTypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}queue_type_id'],
      )!,
      serial: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}serial'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      feeBdt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fee_bdt'],
      ),
      issuedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}issued_at'],
      )!,
      firstCalledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}first_called_at'],
      ),
      enteredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}entered_at'],
      ),
      cancelledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cancelled_at'],
      ),
      cancelReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cancel_reason'],
      ),
      latestPrintStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}latest_print_status'],
      ),
    );
  }

  @override
  $QueueTokensTable createAlias(String alias) {
    return $QueueTokensTable(attachedDatabase, alias);
  }
}

class QueueTokenRow extends DataClass implements Insertable<QueueTokenRow> {
  final String id;
  final String sessionId;
  final String chamberId;
  final String patientId;
  final String queueTypeId;
  final int serial;
  final String status;
  final int? feeBdt;
  final int issuedAt;
  final int? firstCalledAt;
  final int? enteredAt;
  final int? cancelledAt;
  final String? cancelReason;
  final String? latestPrintStatus;
  const QueueTokenRow({
    required this.id,
    required this.sessionId,
    required this.chamberId,
    required this.patientId,
    required this.queueTypeId,
    required this.serial,
    required this.status,
    this.feeBdt,
    required this.issuedAt,
    this.firstCalledAt,
    this.enteredAt,
    this.cancelledAt,
    this.cancelReason,
    this.latestPrintStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['chamber_id'] = Variable<String>(chamberId);
    map['patient_id'] = Variable<String>(patientId);
    map['queue_type_id'] = Variable<String>(queueTypeId);
    map['serial'] = Variable<int>(serial);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || feeBdt != null) {
      map['fee_bdt'] = Variable<int>(feeBdt);
    }
    map['issued_at'] = Variable<int>(issuedAt);
    if (!nullToAbsent || firstCalledAt != null) {
      map['first_called_at'] = Variable<int>(firstCalledAt);
    }
    if (!nullToAbsent || enteredAt != null) {
      map['entered_at'] = Variable<int>(enteredAt);
    }
    if (!nullToAbsent || cancelledAt != null) {
      map['cancelled_at'] = Variable<int>(cancelledAt);
    }
    if (!nullToAbsent || cancelReason != null) {
      map['cancel_reason'] = Variable<String>(cancelReason);
    }
    if (!nullToAbsent || latestPrintStatus != null) {
      map['latest_print_status'] = Variable<String>(latestPrintStatus);
    }
    return map;
  }

  QueueTokensCompanion toCompanion(bool nullToAbsent) {
    return QueueTokensCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      chamberId: Value(chamberId),
      patientId: Value(patientId),
      queueTypeId: Value(queueTypeId),
      serial: Value(serial),
      status: Value(status),
      feeBdt: feeBdt == null && nullToAbsent
          ? const Value.absent()
          : Value(feeBdt),
      issuedAt: Value(issuedAt),
      firstCalledAt: firstCalledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(firstCalledAt),
      enteredAt: enteredAt == null && nullToAbsent
          ? const Value.absent()
          : Value(enteredAt),
      cancelledAt: cancelledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(cancelledAt),
      cancelReason: cancelReason == null && nullToAbsent
          ? const Value.absent()
          : Value(cancelReason),
      latestPrintStatus: latestPrintStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(latestPrintStatus),
    );
  }

  factory QueueTokenRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QueueTokenRow(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      chamberId: serializer.fromJson<String>(json['chamberId']),
      patientId: serializer.fromJson<String>(json['patientId']),
      queueTypeId: serializer.fromJson<String>(json['queueTypeId']),
      serial: serializer.fromJson<int>(json['serial']),
      status: serializer.fromJson<String>(json['status']),
      feeBdt: serializer.fromJson<int?>(json['feeBdt']),
      issuedAt: serializer.fromJson<int>(json['issuedAt']),
      firstCalledAt: serializer.fromJson<int?>(json['firstCalledAt']),
      enteredAt: serializer.fromJson<int?>(json['enteredAt']),
      cancelledAt: serializer.fromJson<int?>(json['cancelledAt']),
      cancelReason: serializer.fromJson<String?>(json['cancelReason']),
      latestPrintStatus: serializer.fromJson<String?>(
        json['latestPrintStatus'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'chamberId': serializer.toJson<String>(chamberId),
      'patientId': serializer.toJson<String>(patientId),
      'queueTypeId': serializer.toJson<String>(queueTypeId),
      'serial': serializer.toJson<int>(serial),
      'status': serializer.toJson<String>(status),
      'feeBdt': serializer.toJson<int?>(feeBdt),
      'issuedAt': serializer.toJson<int>(issuedAt),
      'firstCalledAt': serializer.toJson<int?>(firstCalledAt),
      'enteredAt': serializer.toJson<int?>(enteredAt),
      'cancelledAt': serializer.toJson<int?>(cancelledAt),
      'cancelReason': serializer.toJson<String?>(cancelReason),
      'latestPrintStatus': serializer.toJson<String?>(latestPrintStatus),
    };
  }

  QueueTokenRow copyWith({
    String? id,
    String? sessionId,
    String? chamberId,
    String? patientId,
    String? queueTypeId,
    int? serial,
    String? status,
    Value<int?> feeBdt = const Value.absent(),
    int? issuedAt,
    Value<int?> firstCalledAt = const Value.absent(),
    Value<int?> enteredAt = const Value.absent(),
    Value<int?> cancelledAt = const Value.absent(),
    Value<String?> cancelReason = const Value.absent(),
    Value<String?> latestPrintStatus = const Value.absent(),
  }) => QueueTokenRow(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    chamberId: chamberId ?? this.chamberId,
    patientId: patientId ?? this.patientId,
    queueTypeId: queueTypeId ?? this.queueTypeId,
    serial: serial ?? this.serial,
    status: status ?? this.status,
    feeBdt: feeBdt.present ? feeBdt.value : this.feeBdt,
    issuedAt: issuedAt ?? this.issuedAt,
    firstCalledAt: firstCalledAt.present
        ? firstCalledAt.value
        : this.firstCalledAt,
    enteredAt: enteredAt.present ? enteredAt.value : this.enteredAt,
    cancelledAt: cancelledAt.present ? cancelledAt.value : this.cancelledAt,
    cancelReason: cancelReason.present ? cancelReason.value : this.cancelReason,
    latestPrintStatus: latestPrintStatus.present
        ? latestPrintStatus.value
        : this.latestPrintStatus,
  );
  QueueTokenRow copyWithCompanion(QueueTokensCompanion data) {
    return QueueTokenRow(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      chamberId: data.chamberId.present ? data.chamberId.value : this.chamberId,
      patientId: data.patientId.present ? data.patientId.value : this.patientId,
      queueTypeId: data.queueTypeId.present
          ? data.queueTypeId.value
          : this.queueTypeId,
      serial: data.serial.present ? data.serial.value : this.serial,
      status: data.status.present ? data.status.value : this.status,
      feeBdt: data.feeBdt.present ? data.feeBdt.value : this.feeBdt,
      issuedAt: data.issuedAt.present ? data.issuedAt.value : this.issuedAt,
      firstCalledAt: data.firstCalledAt.present
          ? data.firstCalledAt.value
          : this.firstCalledAt,
      enteredAt: data.enteredAt.present ? data.enteredAt.value : this.enteredAt,
      cancelledAt: data.cancelledAt.present
          ? data.cancelledAt.value
          : this.cancelledAt,
      cancelReason: data.cancelReason.present
          ? data.cancelReason.value
          : this.cancelReason,
      latestPrintStatus: data.latestPrintStatus.present
          ? data.latestPrintStatus.value
          : this.latestPrintStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QueueTokenRow(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('chamberId: $chamberId, ')
          ..write('patientId: $patientId, ')
          ..write('queueTypeId: $queueTypeId, ')
          ..write('serial: $serial, ')
          ..write('status: $status, ')
          ..write('feeBdt: $feeBdt, ')
          ..write('issuedAt: $issuedAt, ')
          ..write('firstCalledAt: $firstCalledAt, ')
          ..write('enteredAt: $enteredAt, ')
          ..write('cancelledAt: $cancelledAt, ')
          ..write('cancelReason: $cancelReason, ')
          ..write('latestPrintStatus: $latestPrintStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    chamberId,
    patientId,
    queueTypeId,
    serial,
    status,
    feeBdt,
    issuedAt,
    firstCalledAt,
    enteredAt,
    cancelledAt,
    cancelReason,
    latestPrintStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QueueTokenRow &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.chamberId == this.chamberId &&
          other.patientId == this.patientId &&
          other.queueTypeId == this.queueTypeId &&
          other.serial == this.serial &&
          other.status == this.status &&
          other.feeBdt == this.feeBdt &&
          other.issuedAt == this.issuedAt &&
          other.firstCalledAt == this.firstCalledAt &&
          other.enteredAt == this.enteredAt &&
          other.cancelledAt == this.cancelledAt &&
          other.cancelReason == this.cancelReason &&
          other.latestPrintStatus == this.latestPrintStatus);
}

class QueueTokensCompanion extends UpdateCompanion<QueueTokenRow> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<String> chamberId;
  final Value<String> patientId;
  final Value<String> queueTypeId;
  final Value<int> serial;
  final Value<String> status;
  final Value<int?> feeBdt;
  final Value<int> issuedAt;
  final Value<int?> firstCalledAt;
  final Value<int?> enteredAt;
  final Value<int?> cancelledAt;
  final Value<String?> cancelReason;
  final Value<String?> latestPrintStatus;
  final Value<int> rowid;
  const QueueTokensCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.chamberId = const Value.absent(),
    this.patientId = const Value.absent(),
    this.queueTypeId = const Value.absent(),
    this.serial = const Value.absent(),
    this.status = const Value.absent(),
    this.feeBdt = const Value.absent(),
    this.issuedAt = const Value.absent(),
    this.firstCalledAt = const Value.absent(),
    this.enteredAt = const Value.absent(),
    this.cancelledAt = const Value.absent(),
    this.cancelReason = const Value.absent(),
    this.latestPrintStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QueueTokensCompanion.insert({
    required String id,
    required String sessionId,
    required String chamberId,
    required String patientId,
    required String queueTypeId,
    required int serial,
    required String status,
    this.feeBdt = const Value.absent(),
    required int issuedAt,
    this.firstCalledAt = const Value.absent(),
    this.enteredAt = const Value.absent(),
    this.cancelledAt = const Value.absent(),
    this.cancelReason = const Value.absent(),
    this.latestPrintStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       chamberId = Value(chamberId),
       patientId = Value(patientId),
       queueTypeId = Value(queueTypeId),
       serial = Value(serial),
       status = Value(status),
       issuedAt = Value(issuedAt);
  static Insertable<QueueTokenRow> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? chamberId,
    Expression<String>? patientId,
    Expression<String>? queueTypeId,
    Expression<int>? serial,
    Expression<String>? status,
    Expression<int>? feeBdt,
    Expression<int>? issuedAt,
    Expression<int>? firstCalledAt,
    Expression<int>? enteredAt,
    Expression<int>? cancelledAt,
    Expression<String>? cancelReason,
    Expression<String>? latestPrintStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (chamberId != null) 'chamber_id': chamberId,
      if (patientId != null) 'patient_id': patientId,
      if (queueTypeId != null) 'queue_type_id': queueTypeId,
      if (serial != null) 'serial': serial,
      if (status != null) 'status': status,
      if (feeBdt != null) 'fee_bdt': feeBdt,
      if (issuedAt != null) 'issued_at': issuedAt,
      if (firstCalledAt != null) 'first_called_at': firstCalledAt,
      if (enteredAt != null) 'entered_at': enteredAt,
      if (cancelledAt != null) 'cancelled_at': cancelledAt,
      if (cancelReason != null) 'cancel_reason': cancelReason,
      if (latestPrintStatus != null) 'latest_print_status': latestPrintStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QueueTokensCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionId,
    Value<String>? chamberId,
    Value<String>? patientId,
    Value<String>? queueTypeId,
    Value<int>? serial,
    Value<String>? status,
    Value<int?>? feeBdt,
    Value<int>? issuedAt,
    Value<int?>? firstCalledAt,
    Value<int?>? enteredAt,
    Value<int?>? cancelledAt,
    Value<String?>? cancelReason,
    Value<String?>? latestPrintStatus,
    Value<int>? rowid,
  }) {
    return QueueTokensCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      chamberId: chamberId ?? this.chamberId,
      patientId: patientId ?? this.patientId,
      queueTypeId: queueTypeId ?? this.queueTypeId,
      serial: serial ?? this.serial,
      status: status ?? this.status,
      feeBdt: feeBdt ?? this.feeBdt,
      issuedAt: issuedAt ?? this.issuedAt,
      firstCalledAt: firstCalledAt ?? this.firstCalledAt,
      enteredAt: enteredAt ?? this.enteredAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancelReason: cancelReason ?? this.cancelReason,
      latestPrintStatus: latestPrintStatus ?? this.latestPrintStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (chamberId.present) {
      map['chamber_id'] = Variable<String>(chamberId.value);
    }
    if (patientId.present) {
      map['patient_id'] = Variable<String>(patientId.value);
    }
    if (queueTypeId.present) {
      map['queue_type_id'] = Variable<String>(queueTypeId.value);
    }
    if (serial.present) {
      map['serial'] = Variable<int>(serial.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (feeBdt.present) {
      map['fee_bdt'] = Variable<int>(feeBdt.value);
    }
    if (issuedAt.present) {
      map['issued_at'] = Variable<int>(issuedAt.value);
    }
    if (firstCalledAt.present) {
      map['first_called_at'] = Variable<int>(firstCalledAt.value);
    }
    if (enteredAt.present) {
      map['entered_at'] = Variable<int>(enteredAt.value);
    }
    if (cancelledAt.present) {
      map['cancelled_at'] = Variable<int>(cancelledAt.value);
    }
    if (cancelReason.present) {
      map['cancel_reason'] = Variable<String>(cancelReason.value);
    }
    if (latestPrintStatus.present) {
      map['latest_print_status'] = Variable<String>(latestPrintStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QueueTokensCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('chamberId: $chamberId, ')
          ..write('patientId: $patientId, ')
          ..write('queueTypeId: $queueTypeId, ')
          ..write('serial: $serial, ')
          ..write('status: $status, ')
          ..write('feeBdt: $feeBdt, ')
          ..write('issuedAt: $issuedAt, ')
          ..write('firstCalledAt: $firstCalledAt, ')
          ..write('enteredAt: $enteredAt, ')
          ..write('cancelledAt: $cancelledAt, ')
          ..write('cancelReason: $cancelReason, ')
          ..write('latestPrintStatus: $latestPrintStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TokenPrintAttemptsTable extends TokenPrintAttempts
    with TableInfo<$TokenPrintAttemptsTable, TokenPrintAttemptRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TokenPrintAttemptsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tokenIdMeta = const VerificationMeta(
    'tokenId',
  );
  @override
  late final GeneratedColumn<String> tokenId = GeneratedColumn<String>(
    'token_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES queue_tokens (id)',
    ),
  );
  static const VerificationMeta _attemptNumberMeta = const VerificationMeta(
    'attemptNumber',
  );
  @override
  late final GeneratedColumn<int> attemptNumber = GeneratedColumn<int>(
    'attempt_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actorAccountIdMeta = const VerificationMeta(
    'actorAccountId',
  );
  @override
  late final GeneratedColumn<String> actorAccountId = GeneratedColumn<String>(
    'actor_account_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tokenId,
    attemptNumber,
    status,
    reason,
    actorAccountId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'token_print_attempts';
  @override
  VerificationContext validateIntegrity(
    Insertable<TokenPrintAttemptRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('token_id')) {
      context.handle(
        _tokenIdMeta,
        tokenId.isAcceptableOrUnknown(data['token_id']!, _tokenIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tokenIdMeta);
    }
    if (data.containsKey('attempt_number')) {
      context.handle(
        _attemptNumberMeta,
        attemptNumber.isAcceptableOrUnknown(
          data['attempt_number']!,
          _attemptNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_attemptNumberMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    }
    if (data.containsKey('actor_account_id')) {
      context.handle(
        _actorAccountIdMeta,
        actorAccountId.isAcceptableOrUnknown(
          data['actor_account_id']!,
          _actorAccountIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TokenPrintAttemptRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TokenPrintAttemptRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tokenId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}token_id'],
      )!,
      attemptNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt_number'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      ),
      actorAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}actor_account_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TokenPrintAttemptsTable createAlias(String alias) {
    return $TokenPrintAttemptsTable(attachedDatabase, alias);
  }
}

class TokenPrintAttemptRow extends DataClass
    implements Insertable<TokenPrintAttemptRow> {
  final String id;
  final String tokenId;
  final int attemptNumber;
  final String status;
  final String? reason;
  final String? actorAccountId;
  final int createdAt;
  const TokenPrintAttemptRow({
    required this.id,
    required this.tokenId,
    required this.attemptNumber,
    required this.status,
    this.reason,
    this.actorAccountId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['token_id'] = Variable<String>(tokenId);
    map['attempt_number'] = Variable<int>(attemptNumber);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    if (!nullToAbsent || actorAccountId != null) {
      map['actor_account_id'] = Variable<String>(actorAccountId);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  TokenPrintAttemptsCompanion toCompanion(bool nullToAbsent) {
    return TokenPrintAttemptsCompanion(
      id: Value(id),
      tokenId: Value(tokenId),
      attemptNumber: Value(attemptNumber),
      status: Value(status),
      reason: reason == null && nullToAbsent
          ? const Value.absent()
          : Value(reason),
      actorAccountId: actorAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(actorAccountId),
      createdAt: Value(createdAt),
    );
  }

  factory TokenPrintAttemptRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TokenPrintAttemptRow(
      id: serializer.fromJson<String>(json['id']),
      tokenId: serializer.fromJson<String>(json['tokenId']),
      attemptNumber: serializer.fromJson<int>(json['attemptNumber']),
      status: serializer.fromJson<String>(json['status']),
      reason: serializer.fromJson<String?>(json['reason']),
      actorAccountId: serializer.fromJson<String?>(json['actorAccountId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tokenId': serializer.toJson<String>(tokenId),
      'attemptNumber': serializer.toJson<int>(attemptNumber),
      'status': serializer.toJson<String>(status),
      'reason': serializer.toJson<String?>(reason),
      'actorAccountId': serializer.toJson<String?>(actorAccountId),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  TokenPrintAttemptRow copyWith({
    String? id,
    String? tokenId,
    int? attemptNumber,
    String? status,
    Value<String?> reason = const Value.absent(),
    Value<String?> actorAccountId = const Value.absent(),
    int? createdAt,
  }) => TokenPrintAttemptRow(
    id: id ?? this.id,
    tokenId: tokenId ?? this.tokenId,
    attemptNumber: attemptNumber ?? this.attemptNumber,
    status: status ?? this.status,
    reason: reason.present ? reason.value : this.reason,
    actorAccountId: actorAccountId.present
        ? actorAccountId.value
        : this.actorAccountId,
    createdAt: createdAt ?? this.createdAt,
  );
  TokenPrintAttemptRow copyWithCompanion(TokenPrintAttemptsCompanion data) {
    return TokenPrintAttemptRow(
      id: data.id.present ? data.id.value : this.id,
      tokenId: data.tokenId.present ? data.tokenId.value : this.tokenId,
      attemptNumber: data.attemptNumber.present
          ? data.attemptNumber.value
          : this.attemptNumber,
      status: data.status.present ? data.status.value : this.status,
      reason: data.reason.present ? data.reason.value : this.reason,
      actorAccountId: data.actorAccountId.present
          ? data.actorAccountId.value
          : this.actorAccountId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TokenPrintAttemptRow(')
          ..write('id: $id, ')
          ..write('tokenId: $tokenId, ')
          ..write('attemptNumber: $attemptNumber, ')
          ..write('status: $status, ')
          ..write('reason: $reason, ')
          ..write('actorAccountId: $actorAccountId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tokenId,
    attemptNumber,
    status,
    reason,
    actorAccountId,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TokenPrintAttemptRow &&
          other.id == this.id &&
          other.tokenId == this.tokenId &&
          other.attemptNumber == this.attemptNumber &&
          other.status == this.status &&
          other.reason == this.reason &&
          other.actorAccountId == this.actorAccountId &&
          other.createdAt == this.createdAt);
}

class TokenPrintAttemptsCompanion
    extends UpdateCompanion<TokenPrintAttemptRow> {
  final Value<String> id;
  final Value<String> tokenId;
  final Value<int> attemptNumber;
  final Value<String> status;
  final Value<String?> reason;
  final Value<String?> actorAccountId;
  final Value<int> createdAt;
  final Value<int> rowid;
  const TokenPrintAttemptsCompanion({
    this.id = const Value.absent(),
    this.tokenId = const Value.absent(),
    this.attemptNumber = const Value.absent(),
    this.status = const Value.absent(),
    this.reason = const Value.absent(),
    this.actorAccountId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TokenPrintAttemptsCompanion.insert({
    required String id,
    required String tokenId,
    required int attemptNumber,
    required String status,
    this.reason = const Value.absent(),
    this.actorAccountId = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tokenId = Value(tokenId),
       attemptNumber = Value(attemptNumber),
       status = Value(status),
       createdAt = Value(createdAt);
  static Insertable<TokenPrintAttemptRow> custom({
    Expression<String>? id,
    Expression<String>? tokenId,
    Expression<int>? attemptNumber,
    Expression<String>? status,
    Expression<String>? reason,
    Expression<String>? actorAccountId,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tokenId != null) 'token_id': tokenId,
      if (attemptNumber != null) 'attempt_number': attemptNumber,
      if (status != null) 'status': status,
      if (reason != null) 'reason': reason,
      if (actorAccountId != null) 'actor_account_id': actorAccountId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TokenPrintAttemptsCompanion copyWith({
    Value<String>? id,
    Value<String>? tokenId,
    Value<int>? attemptNumber,
    Value<String>? status,
    Value<String?>? reason,
    Value<String?>? actorAccountId,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return TokenPrintAttemptsCompanion(
      id: id ?? this.id,
      tokenId: tokenId ?? this.tokenId,
      attemptNumber: attemptNumber ?? this.attemptNumber,
      status: status ?? this.status,
      reason: reason ?? this.reason,
      actorAccountId: actorAccountId ?? this.actorAccountId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tokenId.present) {
      map['token_id'] = Variable<String>(tokenId.value);
    }
    if (attemptNumber.present) {
      map['attempt_number'] = Variable<int>(attemptNumber.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (actorAccountId.present) {
      map['actor_account_id'] = Variable<String>(actorAccountId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TokenPrintAttemptsCompanion(')
          ..write('id: $id, ')
          ..write('tokenId: $tokenId, ')
          ..write('attemptNumber: $attemptNumber, ')
          ..write('status: $status, ')
          ..write('reason: $reason, ')
          ..write('actorAccountId: $actorAccountId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DoctorsTable doctors = $DoctorsTable(this);
  late final $ChambersTable chambers = $ChambersTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $UsersTable users = $UsersTable(this);
  late final $UserScopeAssignmentsTable userScopeAssignments =
      $UserScopeAssignmentsTable(this);
  late final $AuthSessionsTable authSessions = $AuthSessionsTable(this);
  late final $AuditEntriesTable auditEntries = $AuditEntriesTable(this);
  late final $PinDevicesTable pinDevices = $PinDevicesTable(this);
  late final $QueueTypesTable queueTypes = $QueueTypesTable(this);
  late final $QueueSessionsTable queueSessions = $QueueSessionsTable(this);
  late final $SessionQueueCountersTable sessionQueueCounters =
      $SessionQueueCountersTable(this);
  late final $PatientsTable patients = $PatientsTable(this);
  late final $IdempotentCommandsTable idempotentCommands =
      $IdempotentCommandsTable(this);
  late final $QueueTokensTable queueTokens = $QueueTokensTable(this);
  late final $TokenPrintAttemptsTable tokenPrintAttempts =
      $TokenPrintAttemptsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    doctors,
    chambers,
    appSettings,
    users,
    userScopeAssignments,
    authSessions,
    auditEntries,
    pinDevices,
    queueTypes,
    queueSessions,
    sessionQueueCounters,
    patients,
    idempotentCommands,
    queueTokens,
    tokenPrintAttempts,
  ];
}

typedef $$DoctorsTableCreateCompanionBuilder = DoctorsCompanion Function({
  required String id,
  required String name,
  Value<String?> specialty,
  Value<String> degrees,
  Value<String?> designation,
  Value<String?> workplace,
  Value<String?> registrationNumber,
  Value<String?> photoPath,
  Value<int> rowid,
});
typedef $$DoctorsTableUpdateCompanionBuilder = DoctorsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> specialty,
  Value<String> degrees,
  Value<String?> designation,
  Value<String?> workplace,
  Value<String?> registrationNumber,
  Value<String?> photoPath,
  Value<int> rowid,
});

final class $$DoctorsTableReferences
    extends BaseReferences<_$AppDatabase, $DoctorsTable, DoctorRow> {
  $$DoctorsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ChambersTable, List<ChamberRow>>
  _chambersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.chambers,
    aliasName: 'doctors__id__chambers__doctor_id',
  );

  $$ChambersTableProcessedTableManager get chambersRefs {
    final manager = $$ChambersTableTableManager(
      $_db,
      $_db.chambers,
    ).filter((f) => f.doctorId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_chambersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DoctorsTableFilterComposer
    extends Composer<_$AppDatabase, $DoctorsTable> {
  $$DoctorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get specialty => $composableBuilder(
    column: $table.specialty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get degrees => $composableBuilder(
    column: $table.degrees,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get designation => $composableBuilder(
    column: $table.designation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workplace => $composableBuilder(
    column: $table.workplace,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get registrationNumber => $composableBuilder(
    column: $table.registrationNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> chambersRefs(
    Expression<bool> Function($$ChambersTableFilterComposer f) f,
  ) {
    final $$ChambersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chambers,
      getReferencedColumn: (t) => t.doctorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChambersTableFilterComposer(
            $db: $db,
            $table: $db.chambers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DoctorsTableOrderingComposer
    extends Composer<_$AppDatabase, $DoctorsTable> {
  $$DoctorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get specialty => $composableBuilder(
    column: $table.specialty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get degrees => $composableBuilder(
    column: $table.degrees,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get designation => $composableBuilder(
    column: $table.designation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workplace => $composableBuilder(
    column: $table.workplace,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get registrationNumber => $composableBuilder(
    column: $table.registrationNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DoctorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DoctorsTable> {
  $$DoctorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get specialty =>
      $composableBuilder(column: $table.specialty, builder: (column) => column);

  GeneratedColumn<String> get degrees =>
      $composableBuilder(column: $table.degrees, builder: (column) => column);

  GeneratedColumn<String> get designation => $composableBuilder(
    column: $table.designation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get workplace =>
      $composableBuilder(column: $table.workplace, builder: (column) => column);

  GeneratedColumn<String> get registrationNumber => $composableBuilder(
    column: $table.registrationNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  Expression<T> chambersRefs<T extends Object>(
    Expression<T> Function($$ChambersTableAnnotationComposer a) f,
  ) {
    final $$ChambersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chambers,
      getReferencedColumn: (t) => t.doctorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChambersTableAnnotationComposer(
            $db: $db,
            $table: $db.chambers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DoctorsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DoctorsTable,
          DoctorRow,
          $$DoctorsTableFilterComposer,
          $$DoctorsTableOrderingComposer,
          $$DoctorsTableAnnotationComposer,
          $$DoctorsTableCreateCompanionBuilder,
          $$DoctorsTableUpdateCompanionBuilder,
          (DoctorRow, $$DoctorsTableReferences),
          DoctorRow,
          PrefetchHooks Function({bool chambersRefs})
        > {
  $$DoctorsTableTableManager(_$AppDatabase db, $DoctorsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DoctorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DoctorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DoctorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> specialty = const Value.absent(),
                Value<String> degrees = const Value.absent(),
                Value<String?> designation = const Value.absent(),
                Value<String?> workplace = const Value.absent(),
                Value<String?> registrationNumber = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DoctorsCompanion(
                id: id,
                name: name,
                specialty: specialty,
                degrees: degrees,
                designation: designation,
                workplace: workplace,
                registrationNumber: registrationNumber,
                photoPath: photoPath,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> specialty = const Value.absent(),
                Value<String> degrees = const Value.absent(),
                Value<String?> designation = const Value.absent(),
                Value<String?> workplace = const Value.absent(),
                Value<String?> registrationNumber = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DoctorsCompanion.insert(
                id: id,
                name: name,
                specialty: specialty,
                degrees: degrees,
                designation: designation,
                workplace: workplace,
                registrationNumber: registrationNumber,
                photoPath: photoPath,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DoctorsTable, DoctorRow>(table),
                  $$DoctorsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({chambersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (chambersRefs) db.chambers],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (chambersRefs)
                    await $_getPrefetchedDataByColumns<
                      DoctorRow,
                      $DoctorsTable,
                      ChamberRow,
                      $ChambersTable
                    >(
                      currentTable: table,
                      referencedTable: $$DoctorsTableReferences
                          ._chambersRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$DoctorsTableReferences(db, table, p0).chambersRefs,
                      currentColumn: 'id',
                      referencedColumn: 'doctor_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$DoctorsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DoctorsTable,
      DoctorRow,
      $$DoctorsTableFilterComposer,
      $$DoctorsTableOrderingComposer,
      $$DoctorsTableAnnotationComposer,
      $$DoctorsTableCreateCompanionBuilder,
      $$DoctorsTableUpdateCompanionBuilder,
      (DoctorRow, $$DoctorsTableReferences),
      DoctorRow,
      PrefetchHooks Function({bool chambersRefs})
    >;
typedef $$ChambersTableCreateCompanionBuilder = ChambersCompanion Function({
  required String id,
  required String doctorId,
  required String name,
  Value<String?> location,
  Value<String?> phone,
  required int createdAt,
  Value<int> rowid,
});
typedef $$ChambersTableUpdateCompanionBuilder = ChambersCompanion Function({
  Value<String> id,
  Value<String> doctorId,
  Value<String> name,
  Value<String?> location,
  Value<String?> phone,
  Value<int> createdAt,
  Value<int> rowid,
});

final class $$ChambersTableReferences
    extends BaseReferences<_$AppDatabase, $ChambersTable, ChamberRow> {
  $$ChambersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DoctorsTable _doctorIdTable(_$AppDatabase db) =>
      db.doctors.createAlias('chambers__doctor_id__doctors__id');

  $$DoctorsTableProcessedTableManager get doctorId {
    final $_column = $_itemColumn<String>('doctor_id')!;

    final manager = $$DoctorsTableTableManager(
      $_db,
      $_db.doctors,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_doctorIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$QueueSessionsTable, List<QueueSessionRow>>
  _queueSessionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.queueSessions,
    aliasName: 'chambers__id__queue_sessions__chamber_id',
  );

  $$QueueSessionsTableProcessedTableManager get queueSessionsRefs {
    final manager = $$QueueSessionsTableTableManager(
      $_db,
      $_db.queueSessions,
    ).filter((f) => f.chamberId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_queueSessionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$QueueTokensTable, List<QueueTokenRow>>
  _queueTokensRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.queueTokens,
    aliasName: 'chambers__id__queue_tokens__chamber_id',
  );

  $$QueueTokensTableProcessedTableManager get queueTokensRefs {
    final manager = $$QueueTokensTableTableManager(
      $_db,
      $_db.queueTokens,
    ).filter((f) => f.chamberId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_queueTokensRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ChambersTableFilterComposer
    extends Composer<_$AppDatabase, $ChambersTable> {
  $$ChambersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$DoctorsTableFilterComposer get doctorId {
    final $$DoctorsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.doctorId,
      referencedTable: $db.doctors,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DoctorsTableFilterComposer(
            $db: $db,
            $table: $db.doctors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> queueSessionsRefs(
    Expression<bool> Function($$QueueSessionsTableFilterComposer f) f,
  ) {
    final $$QueueSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.queueSessions,
      getReferencedColumn: (t) => t.chamberId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QueueSessionsTableFilterComposer(
            $db: $db,
            $table: $db.queueSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> queueTokensRefs(
    Expression<bool> Function($$QueueTokensTableFilterComposer f) f,
  ) {
    final $$QueueTokensTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.queueTokens,
      getReferencedColumn: (t) => t.chamberId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QueueTokensTableFilterComposer(
            $db: $db,
            $table: $db.queueTokens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ChambersTableOrderingComposer
    extends Composer<_$AppDatabase, $ChambersTable> {
  $$ChambersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$DoctorsTableOrderingComposer get doctorId {
    final $$DoctorsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.doctorId,
      referencedTable: $db.doctors,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DoctorsTableOrderingComposer(
            $db: $db,
            $table: $db.doctors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChambersTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChambersTable> {
  $$ChambersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$DoctorsTableAnnotationComposer get doctorId {
    final $$DoctorsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.doctorId,
      referencedTable: $db.doctors,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DoctorsTableAnnotationComposer(
            $db: $db,
            $table: $db.doctors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> queueSessionsRefs<T extends Object>(
    Expression<T> Function($$QueueSessionsTableAnnotationComposer a) f,
  ) {
    final $$QueueSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.queueSessions,
      getReferencedColumn: (t) => t.chamberId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QueueSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.queueSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> queueTokensRefs<T extends Object>(
    Expression<T> Function($$QueueTokensTableAnnotationComposer a) f,
  ) {
    final $$QueueTokensTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.queueTokens,
      getReferencedColumn: (t) => t.chamberId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QueueTokensTableAnnotationComposer(
            $db: $db,
            $table: $db.queueTokens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ChambersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChambersTable,
          ChamberRow,
          $$ChambersTableFilterComposer,
          $$ChambersTableOrderingComposer,
          $$ChambersTableAnnotationComposer,
          $$ChambersTableCreateCompanionBuilder,
          $$ChambersTableUpdateCompanionBuilder,
          (ChamberRow, $$ChambersTableReferences),
          ChamberRow,
          PrefetchHooks Function({
            bool doctorId,
            bool queueSessionsRefs,
            bool queueTokensRefs,
          })
        > {
  $$ChambersTableTableManager(_$AppDatabase db, $ChambersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChambersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChambersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChambersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> doctorId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChambersCompanion(
                id: id,
                doctorId: doctorId,
                name: name,
                location: location,
                phone: phone,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String doctorId,
                required String name,
                Value<String?> location = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ChambersCompanion.insert(
                id: id,
                doctorId: doctorId,
                name: name,
                location: location,
                phone: phone,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ChambersTable, ChamberRow>(table),
                  $$ChambersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                doctorId = false,
                queueSessionsRefs = false,
                queueTokensRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (queueSessionsRefs) db.queueSessions,
                    if (queueTokensRefs) db.queueTokens,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (doctorId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.doctorId,
                            referencedTable: $$ChambersTableReferences
                                ._doctorIdTable(db),
                            referencedColumn: $$ChambersTableReferences
                                ._doctorIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (queueSessionsRefs)
                        await $_getPrefetchedDataByColumns<
                          ChamberRow,
                          $ChambersTable,
                          QueueSessionRow,
                          $QueueSessionsTable
                        >(
                          currentTable: table,
                          referencedTable: $$ChambersTableReferences
                              ._queueSessionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ChambersTableReferences(
                                db,
                                table,
                                p0,
                              ).queueSessionsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'chamber_id',
                          typedResults: items,
                        ),
                      if (queueTokensRefs)
                        await $_getPrefetchedDataByColumns<
                          ChamberRow,
                          $ChambersTable,
                          QueueTokenRow,
                          $QueueTokensTable
                        >(
                          currentTable: table,
                          referencedTable: $$ChambersTableReferences
                              ._queueTokensRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ChambersTableReferences(
                                db,
                                table,
                                p0,
                              ).queueTokensRefs,
                          currentColumn: 'id',
                          referencedColumn: 'chamber_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ChambersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChambersTable,
      ChamberRow,
      $$ChambersTableFilterComposer,
      $$ChambersTableOrderingComposer,
      $$ChambersTableAnnotationComposer,
      $$ChambersTableCreateCompanionBuilder,
      $$ChambersTableUpdateCompanionBuilder,
      (ChamberRow, $$ChambersTableReferences),
      ChamberRow,
      PrefetchHooks Function({
        bool doctorId,
        bool queueSessionsRefs,
        bool queueTokensRefs,
      })
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          SettingRow,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            SettingRow,
            BaseReferences<_$AppDatabase, $AppSettingsTable, SettingRow>,
          ),
          SettingRow,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => AppSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppSettingsTable, SettingRow>(table),
                  BaseReferences<_$AppDatabase, $AppSettingsTable, SettingRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      SettingRow,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        SettingRow,
        BaseReferences<_$AppDatabase, $AppSettingsTable, SettingRow>,
      ),
      SettingRow,
      PrefetchHooks Function()
    >;
typedef $$UsersTableCreateCompanionBuilder = UsersCompanion Function({
  required String id,
  required String username,
  required String displayName,
  Value<String> email,
  Value<String> firstName,
  Value<String> lastName,
  Value<String> phone,
  Value<Uint8List?> photo,
  Value<int> photoVersion,
  required String role,
  required String passwordHash,
  Value<String> status,
  required int createdAt,
  Value<int> rowid,
});
typedef $$UsersTableUpdateCompanionBuilder = UsersCompanion Function({
  Value<String> id,
  Value<String> username,
  Value<String> displayName,
  Value<String> email,
  Value<String> firstName,
  Value<String> lastName,
  Value<String> phone,
  Value<Uint8List?> photo,
  Value<int> photoVersion,
  Value<String> role,
  Value<String> passwordHash,
  Value<String> status,
  Value<int> createdAt,
  Value<int> rowid,
});

final class $$UsersTableReferences
    extends BaseReferences<_$AppDatabase, $UsersTable, UserRow> {
  $$UsersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<
    $UserScopeAssignmentsTable,
    List<UserScopeAssignmentRow>
  >
  _userScopeAssignmentsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.userScopeAssignments,
        aliasName: 'users__id__user_scope_assignments__user_id',
      );

  $$UserScopeAssignmentsTableProcessedTableManager
  get userScopeAssignmentsRefs {
    final manager = $$UserScopeAssignmentsTableTableManager(
      $_db,
      $_db.userScopeAssignments,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _userScopeAssignmentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AuthSessionsTable, List<AuthSessionRow>>
  _authSessionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.authSessions,
    aliasName: 'users__id__auth_sessions__user_id',
  );

  $$AuthSessionsTableProcessedTableManager get authSessionsRefs {
    final manager = $$AuthSessionsTableTableManager(
      $_db,
      $_db.authSessions,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_authSessionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PinDevicesTable, List<PinDeviceRow>>
  _pinDevicesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.pinDevices,
    aliasName: 'users__id__pin_devices__user_id',
  );

  $$PinDevicesTableProcessedTableManager get pinDevicesRefs {
    final manager = $$PinDevicesTableTableManager(
      $_db,
      $_db.pinDevices,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_pinDevicesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get photo => $composableBuilder(
    column: $table.photo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get photoVersion => $composableBuilder(
    column: $table.photoVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> userScopeAssignmentsRefs(
    Expression<bool> Function($$UserScopeAssignmentsTableFilterComposer f) f,
  ) {
    final $$UserScopeAssignmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userScopeAssignments,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserScopeAssignmentsTableFilterComposer(
            $db: $db,
            $table: $db.userScopeAssignments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> authSessionsRefs(
    Expression<bool> Function($$AuthSessionsTableFilterComposer f) f,
  ) {
    final $$AuthSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.authSessions,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AuthSessionsTableFilterComposer(
            $db: $db,
            $table: $db.authSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> pinDevicesRefs(
    Expression<bool> Function($$PinDevicesTableFilterComposer f) f,
  ) {
    final $$PinDevicesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pinDevices,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PinDevicesTableFilterComposer(
            $db: $db,
            $table: $db.pinDevices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get photo => $composableBuilder(
    column: $table.photo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get photoVersion => $composableBuilder(
    column: $table.photoVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get firstName =>
      $composableBuilder(column: $table.firstName, builder: (column) => column);

  GeneratedColumn<String> get lastName =>
      $composableBuilder(column: $table.lastName, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<Uint8List> get photo =>
      $composableBuilder(column: $table.photo, builder: (column) => column);

  GeneratedColumn<int> get photoVersion => $composableBuilder(
    column: $table.photoVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> userScopeAssignmentsRefs<T extends Object>(
    Expression<T> Function($$UserScopeAssignmentsTableAnnotationComposer a) f,
  ) {
    final $$UserScopeAssignmentsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.userScopeAssignments,
          getReferencedColumn: (t) => t.userId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$UserScopeAssignmentsTableAnnotationComposer(
                $db: $db,
                $table: $db.userScopeAssignments,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> authSessionsRefs<T extends Object>(
    Expression<T> Function($$AuthSessionsTableAnnotationComposer a) f,
  ) {
    final $$AuthSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.authSessions,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AuthSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.authSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> pinDevicesRefs<T extends Object>(
    Expression<T> Function($$PinDevicesTableAnnotationComposer a) f,
  ) {
    final $$PinDevicesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pinDevices,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PinDevicesTableAnnotationComposer(
            $db: $db,
            $table: $db.pinDevices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersTable,
          UserRow,
          $$UsersTableFilterComposer,
          $$UsersTableOrderingComposer,
          $$UsersTableAnnotationComposer,
          $$UsersTableCreateCompanionBuilder,
          $$UsersTableUpdateCompanionBuilder,
          (UserRow, $$UsersTableReferences),
          UserRow,
          PrefetchHooks Function({
            bool userScopeAssignmentsRefs,
            bool authSessionsRefs,
            bool pinDevicesRefs,
          })
        > {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> username = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> firstName = const Value.absent(),
                Value<String> lastName = const Value.absent(),
                Value<String> phone = const Value.absent(),
                Value<Uint8List?> photo = const Value.absent(),
                Value<int> photoVersion = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> passwordHash = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion(
                id: id,
                username: username,
                displayName: displayName,
                email: email,
                firstName: firstName,
                lastName: lastName,
                phone: phone,
                photo: photo,
                photoVersion: photoVersion,
                role: role,
                passwordHash: passwordHash,
                status: status,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String username,
                required String displayName,
                Value<String> email = const Value.absent(),
                Value<String> firstName = const Value.absent(),
                Value<String> lastName = const Value.absent(),
                Value<String> phone = const Value.absent(),
                Value<Uint8List?> photo = const Value.absent(),
                Value<int> photoVersion = const Value.absent(),
                required String role,
                required String passwordHash,
                Value<String> status = const Value.absent(),
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion.insert(
                id: id,
                username: username,
                displayName: displayName,
                email: email,
                firstName: firstName,
                lastName: lastName,
                phone: phone,
                photo: photo,
                photoVersion: photoVersion,
                role: role,
                passwordHash: passwordHash,
                status: status,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UsersTable, UserRow>(table),
                  $$UsersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                userScopeAssignmentsRefs = false,
                authSessionsRefs = false,
                pinDevicesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (userScopeAssignmentsRefs) db.userScopeAssignments,
                    if (authSessionsRefs) db.authSessions,
                    if (pinDevicesRefs) db.pinDevices,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (userScopeAssignmentsRefs)
                        await $_getPrefetchedDataByColumns<
                          UserRow,
                          $UsersTable,
                          UserScopeAssignmentRow,
                          $UserScopeAssignmentsTable
                        >(
                          currentTable: table,
                          referencedTable: $$UsersTableReferences
                              ._userScopeAssignmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsersTableReferences(
                                db,
                                table,
                                p0,
                              ).userScopeAssignmentsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'user_id',
                          typedResults: items,
                        ),
                      if (authSessionsRefs)
                        await $_getPrefetchedDataByColumns<
                          UserRow,
                          $UsersTable,
                          AuthSessionRow,
                          $AuthSessionsTable
                        >(
                          currentTable: table,
                          referencedTable: $$UsersTableReferences
                              ._authSessionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsersTableReferences(
                                db,
                                table,
                                p0,
                              ).authSessionsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'user_id',
                          typedResults: items,
                        ),
                      if (pinDevicesRefs)
                        await $_getPrefetchedDataByColumns<
                          UserRow,
                          $UsersTable,
                          PinDeviceRow,
                          $PinDevicesTable
                        >(
                          currentTable: table,
                          referencedTable: $$UsersTableReferences
                              ._pinDevicesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsersTableReferences(
                                db,
                                table,
                                p0,
                              ).pinDevicesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'user_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$UsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersTable,
      UserRow,
      $$UsersTableFilterComposer,
      $$UsersTableOrderingComposer,
      $$UsersTableAnnotationComposer,
      $$UsersTableCreateCompanionBuilder,
      $$UsersTableUpdateCompanionBuilder,
      (UserRow, $$UsersTableReferences),
      UserRow,
      PrefetchHooks Function({
        bool userScopeAssignmentsRefs,
        bool authSessionsRefs,
        bool pinDevicesRefs,
      })
    >;
typedef $$UserScopeAssignmentsTableCreateCompanionBuilder =
    UserScopeAssignmentsCompanion Function({
      required String userId,
      required String scopeId,
      Value<int> rowid,
    });
typedef $$UserScopeAssignmentsTableUpdateCompanionBuilder =
    UserScopeAssignmentsCompanion Function({
      Value<String> userId,
      Value<String> scopeId,
      Value<int> rowid,
    });

final class $$UserScopeAssignmentsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $UserScopeAssignmentsTable,
          UserScopeAssignmentRow
        > {
  $$UserScopeAssignmentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $UsersTable _userIdTable(_$AppDatabase db) =>
      db.users.createAlias('user_scope_assignments__user_id__users__id');

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$UserScopeAssignmentsTableFilterComposer
    extends Composer<_$AppDatabase, $UserScopeAssignmentsTable> {
  $$UserScopeAssignmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get scopeId => $composableBuilder(
    column: $table.scopeId,
    builder: (column) => ColumnFilters(column),
  );

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableFilterComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserScopeAssignmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserScopeAssignmentsTable> {
  $$UserScopeAssignmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get scopeId => $composableBuilder(
    column: $table.scopeId,
    builder: (column) => ColumnOrderings(column),
  );

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserScopeAssignmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserScopeAssignmentsTable> {
  $$UserScopeAssignmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get scopeId =>
      $composableBuilder(column: $table.scopeId, builder: (column) => column);

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableAnnotationComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserScopeAssignmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserScopeAssignmentsTable,
          UserScopeAssignmentRow,
          $$UserScopeAssignmentsTableFilterComposer,
          $$UserScopeAssignmentsTableOrderingComposer,
          $$UserScopeAssignmentsTableAnnotationComposer,
          $$UserScopeAssignmentsTableCreateCompanionBuilder,
          $$UserScopeAssignmentsTableUpdateCompanionBuilder,
          (UserScopeAssignmentRow, $$UserScopeAssignmentsTableReferences),
          UserScopeAssignmentRow,
          PrefetchHooks Function({bool userId})
        > {
  $$UserScopeAssignmentsTableTableManager(
    _$AppDatabase db,
    $UserScopeAssignmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserScopeAssignmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserScopeAssignmentsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$UserScopeAssignmentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String> scopeId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserScopeAssignmentsCompanion(
                userId: userId,
                scopeId: scopeId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                required String scopeId,
                Value<int> rowid = const Value.absent(),
              }) => UserScopeAssignmentsCompanion.insert(
                userId: userId,
                scopeId: scopeId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $UserScopeAssignmentsTable,
                    UserScopeAssignmentRow
                  >(table),
                  $$UserScopeAssignmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (userId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.userId,
                        referencedTable: $$UserScopeAssignmentsTableReferences
                            ._userIdTable(db),
                        referencedColumn: $$UserScopeAssignmentsTableReferences
                            ._userIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$UserScopeAssignmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserScopeAssignmentsTable,
      UserScopeAssignmentRow,
      $$UserScopeAssignmentsTableFilterComposer,
      $$UserScopeAssignmentsTableOrderingComposer,
      $$UserScopeAssignmentsTableAnnotationComposer,
      $$UserScopeAssignmentsTableCreateCompanionBuilder,
      $$UserScopeAssignmentsTableUpdateCompanionBuilder,
      (UserScopeAssignmentRow, $$UserScopeAssignmentsTableReferences),
      UserScopeAssignmentRow,
      PrefetchHooks Function({bool userId})
    >;
typedef $$AuthSessionsTableCreateCompanionBuilder =
    AuthSessionsCompanion Function({
      required String id,
      required String userId,
      required String tokenHash,
      required int createdAt,
      required int expiresAt,
      Value<bool> revoked,
      Value<int> rowid,
    });
typedef $$AuthSessionsTableUpdateCompanionBuilder =
    AuthSessionsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> tokenHash,
      Value<int> createdAt,
      Value<int> expiresAt,
      Value<bool> revoked,
      Value<int> rowid,
    });

final class $$AuthSessionsTableReferences
    extends BaseReferences<_$AppDatabase, $AuthSessionsTable, AuthSessionRow> {
  $$AuthSessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _userIdTable(_$AppDatabase db) =>
      db.users.createAlias('auth_sessions__user_id__users__id');

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AuthSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $AuthSessionsTable> {
  $$AuthSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tokenHash => $composableBuilder(
    column: $table.tokenHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get revoked => $composableBuilder(
    column: $table.revoked,
    builder: (column) => ColumnFilters(column),
  );

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableFilterComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AuthSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $AuthSessionsTable> {
  $$AuthSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tokenHash => $composableBuilder(
    column: $table.tokenHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get revoked => $composableBuilder(
    column: $table.revoked,
    builder: (column) => ColumnOrderings(column),
  );

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AuthSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AuthSessionsTable> {
  $$AuthSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tokenHash =>
      $composableBuilder(column: $table.tokenHash, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);

  GeneratedColumn<bool> get revoked =>
      $composableBuilder(column: $table.revoked, builder: (column) => column);

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableAnnotationComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AuthSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AuthSessionsTable,
          AuthSessionRow,
          $$AuthSessionsTableFilterComposer,
          $$AuthSessionsTableOrderingComposer,
          $$AuthSessionsTableAnnotationComposer,
          $$AuthSessionsTableCreateCompanionBuilder,
          $$AuthSessionsTableUpdateCompanionBuilder,
          (AuthSessionRow, $$AuthSessionsTableReferences),
          AuthSessionRow,
          PrefetchHooks Function({bool userId})
        > {
  $$AuthSessionsTableTableManager(_$AppDatabase db, $AuthSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AuthSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AuthSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AuthSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> tokenHash = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> expiresAt = const Value.absent(),
                Value<bool> revoked = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AuthSessionsCompanion(
                id: id,
                userId: userId,
                tokenHash: tokenHash,
                createdAt: createdAt,
                expiresAt: expiresAt,
                revoked: revoked,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String tokenHash,
                required int createdAt,
                required int expiresAt,
                Value<bool> revoked = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AuthSessionsCompanion.insert(
                id: id,
                userId: userId,
                tokenHash: tokenHash,
                createdAt: createdAt,
                expiresAt: expiresAt,
                revoked: revoked,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AuthSessionsTable, AuthSessionRow>(table),
                  $$AuthSessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (userId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.userId,
                        referencedTable: $$AuthSessionsTableReferences
                            ._userIdTable(db),
                        referencedColumn: $$AuthSessionsTableReferences
                            ._userIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AuthSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AuthSessionsTable,
      AuthSessionRow,
      $$AuthSessionsTableFilterComposer,
      $$AuthSessionsTableOrderingComposer,
      $$AuthSessionsTableAnnotationComposer,
      $$AuthSessionsTableCreateCompanionBuilder,
      $$AuthSessionsTableUpdateCompanionBuilder,
      (AuthSessionRow, $$AuthSessionsTableReferences),
      AuthSessionRow,
      PrefetchHooks Function({bool userId})
    >;
typedef $$AuditEntriesTableCreateCompanionBuilder =
    AuditEntriesCompanion Function({
      Value<int> seq,
      required int at,
      Value<String?> actorId,
      required String action,
      Value<String?> detail,
      required String prevHash,
      required String hash,
    });
typedef $$AuditEntriesTableUpdateCompanionBuilder =
    AuditEntriesCompanion Function({
      Value<int> seq,
      Value<int> at,
      Value<String?> actorId,
      Value<String> action,
      Value<String?> detail,
      Value<String> prevHash,
      Value<String> hash,
    });

class $$AuditEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $AuditEntriesTable> {
  $$AuditEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actorId => $composableBuilder(
    column: $table.actorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get detail => $composableBuilder(
    column: $table.detail,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get prevHash => $composableBuilder(
    column: $table.prevHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hash => $composableBuilder(
    column: $table.hash,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AuditEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $AuditEntriesTable> {
  $$AuditEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actorId => $composableBuilder(
    column: $table.actorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get detail => $composableBuilder(
    column: $table.detail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get prevHash => $composableBuilder(
    column: $table.prevHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hash => $composableBuilder(
    column: $table.hash,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AuditEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AuditEntriesTable> {
  $$AuditEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumn<int> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  GeneratedColumn<String> get actorId =>
      $composableBuilder(column: $table.actorId, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get detail =>
      $composableBuilder(column: $table.detail, builder: (column) => column);

  GeneratedColumn<String> get prevHash =>
      $composableBuilder(column: $table.prevHash, builder: (column) => column);

  GeneratedColumn<String> get hash =>
      $composableBuilder(column: $table.hash, builder: (column) => column);
}

class $$AuditEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AuditEntriesTable,
          AuditEntryRow,
          $$AuditEntriesTableFilterComposer,
          $$AuditEntriesTableOrderingComposer,
          $$AuditEntriesTableAnnotationComposer,
          $$AuditEntriesTableCreateCompanionBuilder,
          $$AuditEntriesTableUpdateCompanionBuilder,
          (
            AuditEntryRow,
            BaseReferences<_$AppDatabase, $AuditEntriesTable, AuditEntryRow>,
          ),
          AuditEntryRow,
          PrefetchHooks Function()
        > {
  $$AuditEntriesTableTableManager(_$AppDatabase db, $AuditEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AuditEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AuditEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AuditEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> seq = const Value.absent(),
                Value<int> at = const Value.absent(),
                Value<String?> actorId = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String?> detail = const Value.absent(),
                Value<String> prevHash = const Value.absent(),
                Value<String> hash = const Value.absent(),
              }) => AuditEntriesCompanion(
                seq: seq,
                at: at,
                actorId: actorId,
                action: action,
                detail: detail,
                prevHash: prevHash,
                hash: hash,
              ),
          createCompanionCallback:
              ({
                Value<int> seq = const Value.absent(),
                required int at,
                Value<String?> actorId = const Value.absent(),
                required String action,
                Value<String?> detail = const Value.absent(),
                required String prevHash,
                required String hash,
              }) => AuditEntriesCompanion.insert(
                seq: seq,
                at: at,
                actorId: actorId,
                action: action,
                detail: detail,
                prevHash: prevHash,
                hash: hash,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AuditEntriesTable, AuditEntryRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AuditEntriesTable,
                    AuditEntryRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AuditEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AuditEntriesTable,
      AuditEntryRow,
      $$AuditEntriesTableFilterComposer,
      $$AuditEntriesTableOrderingComposer,
      $$AuditEntriesTableAnnotationComposer,
      $$AuditEntriesTableCreateCompanionBuilder,
      $$AuditEntriesTableUpdateCompanionBuilder,
      (
        AuditEntryRow,
        BaseReferences<_$AppDatabase, $AuditEntriesTable, AuditEntryRow>,
      ),
      AuditEntryRow,
      PrefetchHooks Function()
    >;
typedef $$PinDevicesTableCreateCompanionBuilder = PinDevicesCompanion Function({
  required String id,
  required String userId,
  required String tokenHash,
  required String pinHash,
  Value<String> label,
  required int createdAt,
  Value<int> lastUsedAt,
  Value<int> failures,
  Value<int> rowid,
});
typedef $$PinDevicesTableUpdateCompanionBuilder = PinDevicesCompanion Function({
  Value<String> id,
  Value<String> userId,
  Value<String> tokenHash,
  Value<String> pinHash,
  Value<String> label,
  Value<int> createdAt,
  Value<int> lastUsedAt,
  Value<int> failures,
  Value<int> rowid,
});

final class $$PinDevicesTableReferences
    extends BaseReferences<_$AppDatabase, $PinDevicesTable, PinDeviceRow> {
  $$PinDevicesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _userIdTable(_$AppDatabase db) =>
      db.users.createAlias('pin_devices__user_id__users__id');

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PinDevicesTableFilterComposer
    extends Composer<_$AppDatabase, $PinDevicesTable> {
  $$PinDevicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tokenHash => $composableBuilder(
    column: $table.tokenHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pinHash => $composableBuilder(
    column: $table.pinHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get failures => $composableBuilder(
    column: $table.failures,
    builder: (column) => ColumnFilters(column),
  );

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableFilterComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PinDevicesTableOrderingComposer
    extends Composer<_$AppDatabase, $PinDevicesTable> {
  $$PinDevicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tokenHash => $composableBuilder(
    column: $table.tokenHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pinHash => $composableBuilder(
    column: $table.pinHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get failures => $composableBuilder(
    column: $table.failures,
    builder: (column) => ColumnOrderings(column),
  );

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PinDevicesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PinDevicesTable> {
  $$PinDevicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tokenHash =>
      $composableBuilder(column: $table.tokenHash, builder: (column) => column);

  GeneratedColumn<String> get pinHash =>
      $composableBuilder(column: $table.pinHash, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get failures =>
      $composableBuilder(column: $table.failures, builder: (column) => column);

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableAnnotationComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PinDevicesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PinDevicesTable,
          PinDeviceRow,
          $$PinDevicesTableFilterComposer,
          $$PinDevicesTableOrderingComposer,
          $$PinDevicesTableAnnotationComposer,
          $$PinDevicesTableCreateCompanionBuilder,
          $$PinDevicesTableUpdateCompanionBuilder,
          (PinDeviceRow, $$PinDevicesTableReferences),
          PinDeviceRow,
          PrefetchHooks Function({bool userId})
        > {
  $$PinDevicesTableTableManager(_$AppDatabase db, $PinDevicesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PinDevicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PinDevicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PinDevicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> tokenHash = const Value.absent(),
                Value<String> pinHash = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> lastUsedAt = const Value.absent(),
                Value<int> failures = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PinDevicesCompanion(
                id: id,
                userId: userId,
                tokenHash: tokenHash,
                pinHash: pinHash,
                label: label,
                createdAt: createdAt,
                lastUsedAt: lastUsedAt,
                failures: failures,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String tokenHash,
                required String pinHash,
                Value<String> label = const Value.absent(),
                required int createdAt,
                Value<int> lastUsedAt = const Value.absent(),
                Value<int> failures = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PinDevicesCompanion.insert(
                id: id,
                userId: userId,
                tokenHash: tokenHash,
                pinHash: pinHash,
                label: label,
                createdAt: createdAt,
                lastUsedAt: lastUsedAt,
                failures: failures,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PinDevicesTable, PinDeviceRow>(table),
                  $$PinDevicesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (userId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.userId,
                        referencedTable: $$PinDevicesTableReferences
                            ._userIdTable(db),
                        referencedColumn: $$PinDevicesTableReferences
                            ._userIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PinDevicesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PinDevicesTable,
      PinDeviceRow,
      $$PinDevicesTableFilterComposer,
      $$PinDevicesTableOrderingComposer,
      $$PinDevicesTableAnnotationComposer,
      $$PinDevicesTableCreateCompanionBuilder,
      $$PinDevicesTableUpdateCompanionBuilder,
      (PinDeviceRow, $$PinDevicesTableReferences),
      PinDeviceRow,
      PrefetchHooks Function({bool userId})
    >;
typedef $$QueueTypesTableCreateCompanionBuilder = QueueTypesCompanion Function({
  required String id,
  required String ownerKey,
  required String englishName,
  required String bengaliName,
  required int startNumber,
  required int endNumber,
  required int displayOrder,
  Value<bool> enabled,
  Value<int> rowid,
});
typedef $$QueueTypesTableUpdateCompanionBuilder = QueueTypesCompanion Function({
  Value<String> id,
  Value<String> ownerKey,
  Value<String> englishName,
  Value<String> bengaliName,
  Value<int> startNumber,
  Value<int> endNumber,
  Value<int> displayOrder,
  Value<bool> enabled,
  Value<int> rowid,
});

class $$QueueTypesTableFilterComposer
    extends Composer<_$AppDatabase, $QueueTypesTable> {
  $$QueueTypesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerKey => $composableBuilder(
    column: $table.ownerKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get englishName => $composableBuilder(
    column: $table.englishName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bengaliName => $composableBuilder(
    column: $table.bengaliName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startNumber => $composableBuilder(
    column: $table.startNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endNumber => $composableBuilder(
    column: $table.endNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get displayOrder => $composableBuilder(
    column: $table.displayOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );
}

class $$QueueTypesTableOrderingComposer
    extends Composer<_$AppDatabase, $QueueTypesTable> {
  $$QueueTypesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerKey => $composableBuilder(
    column: $table.ownerKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get englishName => $composableBuilder(
    column: $table.englishName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bengaliName => $composableBuilder(
    column: $table.bengaliName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startNumber => $composableBuilder(
    column: $table.startNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endNumber => $composableBuilder(
    column: $table.endNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get displayOrder => $composableBuilder(
    column: $table.displayOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$QueueTypesTableAnnotationComposer
    extends Composer<_$AppDatabase, $QueueTypesTable> {
  $$QueueTypesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerKey =>
      $composableBuilder(column: $table.ownerKey, builder: (column) => column);

  GeneratedColumn<String> get englishName => $composableBuilder(
    column: $table.englishName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bengaliName => $composableBuilder(
    column: $table.bengaliName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startNumber => $composableBuilder(
    column: $table.startNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endNumber =>
      $composableBuilder(column: $table.endNumber, builder: (column) => column);

  GeneratedColumn<int> get displayOrder => $composableBuilder(
    column: $table.displayOrder,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);
}

class $$QueueTypesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QueueTypesTable,
          QueueTypeRow,
          $$QueueTypesTableFilterComposer,
          $$QueueTypesTableOrderingComposer,
          $$QueueTypesTableAnnotationComposer,
          $$QueueTypesTableCreateCompanionBuilder,
          $$QueueTypesTableUpdateCompanionBuilder,
          (
            QueueTypeRow,
            BaseReferences<_$AppDatabase, $QueueTypesTable, QueueTypeRow>,
          ),
          QueueTypeRow,
          PrefetchHooks Function()
        > {
  $$QueueTypesTableTableManager(_$AppDatabase db, $QueueTypesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QueueTypesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QueueTypesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QueueTypesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerKey = const Value.absent(),
                Value<String> englishName = const Value.absent(),
                Value<String> bengaliName = const Value.absent(),
                Value<int> startNumber = const Value.absent(),
                Value<int> endNumber = const Value.absent(),
                Value<int> displayOrder = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QueueTypesCompanion(
                id: id,
                ownerKey: ownerKey,
                englishName: englishName,
                bengaliName: bengaliName,
                startNumber: startNumber,
                endNumber: endNumber,
                displayOrder: displayOrder,
                enabled: enabled,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ownerKey,
                required String englishName,
                required String bengaliName,
                required int startNumber,
                required int endNumber,
                required int displayOrder,
                Value<bool> enabled = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QueueTypesCompanion.insert(
                id: id,
                ownerKey: ownerKey,
                englishName: englishName,
                bengaliName: bengaliName,
                startNumber: startNumber,
                endNumber: endNumber,
                displayOrder: displayOrder,
                enabled: enabled,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$QueueTypesTable, QueueTypeRow>(table),
                  BaseReferences<_$AppDatabase, $QueueTypesTable, QueueTypeRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$QueueTypesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QueueTypesTable,
      QueueTypeRow,
      $$QueueTypesTableFilterComposer,
      $$QueueTypesTableOrderingComposer,
      $$QueueTypesTableAnnotationComposer,
      $$QueueTypesTableCreateCompanionBuilder,
      $$QueueTypesTableUpdateCompanionBuilder,
      (
        QueueTypeRow,
        BaseReferences<_$AppDatabase, $QueueTypesTable, QueueTypeRow>,
      ),
      QueueTypeRow,
      PrefetchHooks Function()
    >;
typedef $$QueueSessionsTableCreateCompanionBuilder =
    QueueSessionsCompanion Function({
      required String id,
      required String chamberId,
      required String businessDate,
      required String status,
      required int openedAt,
      Value<String?> openedByAccountId,
      Value<int?> closedAt,
      Value<String?> closedByAccountId,
      Value<String?> closeReason,
      required String configSnapshotJson,
      Value<int> rowid,
    });
typedef $$QueueSessionsTableUpdateCompanionBuilder =
    QueueSessionsCompanion Function({
      Value<String> id,
      Value<String> chamberId,
      Value<String> businessDate,
      Value<String> status,
      Value<int> openedAt,
      Value<String?> openedByAccountId,
      Value<int?> closedAt,
      Value<String?> closedByAccountId,
      Value<String?> closeReason,
      Value<String> configSnapshotJson,
      Value<int> rowid,
    });

final class $$QueueSessionsTableReferences
    extends
        BaseReferences<_$AppDatabase, $QueueSessionsTable, QueueSessionRow> {
  $$QueueSessionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ChambersTable _chamberIdTable(_$AppDatabase db) =>
      db.chambers.createAlias('queue_sessions__chamber_id__chambers__id');

  $$ChambersTableProcessedTableManager get chamberId {
    final $_column = $_itemColumn<String>('chamber_id')!;

    final manager = $$ChambersTableTableManager(
      $_db,
      $_db.chambers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_chamberIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $SessionQueueCountersTable,
    List<SessionQueueCounterRow>
  >
  _sessionQueueCountersRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.sessionQueueCounters,
        aliasName: 'queue_sessions__id__session_queue_counters__session_id',
      );

  $$SessionQueueCountersTableProcessedTableManager
  get sessionQueueCountersRefs {
    final manager = $$SessionQueueCountersTableTableManager(
      $_db,
      $_db.sessionQueueCounters,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _sessionQueueCountersRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$QueueTokensTable, List<QueueTokenRow>>
  _queueTokensRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.queueTokens,
    aliasName: 'queue_sessions__id__queue_tokens__session_id',
  );

  $$QueueTokensTableProcessedTableManager get queueTokensRefs {
    final manager = $$QueueTokensTableTableManager(
      $_db,
      $_db.queueTokens,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_queueTokensRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$QueueSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $QueueSessionsTable> {
  $$QueueSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get openedAt => $composableBuilder(
    column: $table.openedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get openedByAccountId => $composableBuilder(
    column: $table.openedByAccountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get closedAt => $composableBuilder(
    column: $table.closedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get closedByAccountId => $composableBuilder(
    column: $table.closedByAccountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get closeReason => $composableBuilder(
    column: $table.closeReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get configSnapshotJson => $composableBuilder(
    column: $table.configSnapshotJson,
    builder: (column) => ColumnFilters(column),
  );

  $$ChambersTableFilterComposer get chamberId {
    final $$ChambersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chamberId,
      referencedTable: $db.chambers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChambersTableFilterComposer(
            $db: $db,
            $table: $db.chambers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> sessionQueueCountersRefs(
    Expression<bool> Function($$SessionQueueCountersTableFilterComposer f) f,
  ) {
    final $$SessionQueueCountersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessionQueueCounters,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionQueueCountersTableFilterComposer(
            $db: $db,
            $table: $db.sessionQueueCounters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> queueTokensRefs(
    Expression<bool> Function($$QueueTokensTableFilterComposer f) f,
  ) {
    final $$QueueTokensTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.queueTokens,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QueueTokensTableFilterComposer(
            $db: $db,
            $table: $db.queueTokens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$QueueSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $QueueSessionsTable> {
  $$QueueSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get openedAt => $composableBuilder(
    column: $table.openedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get openedByAccountId => $composableBuilder(
    column: $table.openedByAccountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get closedAt => $composableBuilder(
    column: $table.closedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get closedByAccountId => $composableBuilder(
    column: $table.closedByAccountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get closeReason => $composableBuilder(
    column: $table.closeReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get configSnapshotJson => $composableBuilder(
    column: $table.configSnapshotJson,
    builder: (column) => ColumnOrderings(column),
  );

  $$ChambersTableOrderingComposer get chamberId {
    final $$ChambersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chamberId,
      referencedTable: $db.chambers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChambersTableOrderingComposer(
            $db: $db,
            $table: $db.chambers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QueueSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $QueueSessionsTable> {
  $$QueueSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get openedAt =>
      $composableBuilder(column: $table.openedAt, builder: (column) => column);

  GeneratedColumn<String> get openedByAccountId => $composableBuilder(
    column: $table.openedByAccountId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get closedAt =>
      $composableBuilder(column: $table.closedAt, builder: (column) => column);

  GeneratedColumn<String> get closedByAccountId => $composableBuilder(
    column: $table.closedByAccountId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get closeReason => $composableBuilder(
    column: $table.closeReason,
    builder: (column) => column,
  );

  GeneratedColumn<String> get configSnapshotJson => $composableBuilder(
    column: $table.configSnapshotJson,
    builder: (column) => column,
  );

  $$ChambersTableAnnotationComposer get chamberId {
    final $$ChambersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chamberId,
      referencedTable: $db.chambers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChambersTableAnnotationComposer(
            $db: $db,
            $table: $db.chambers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> sessionQueueCountersRefs<T extends Object>(
    Expression<T> Function($$SessionQueueCountersTableAnnotationComposer a) f,
  ) {
    final $$SessionQueueCountersTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.sessionQueueCounters,
          getReferencedColumn: (t) => t.sessionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SessionQueueCountersTableAnnotationComposer(
                $db: $db,
                $table: $db.sessionQueueCounters,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> queueTokensRefs<T extends Object>(
    Expression<T> Function($$QueueTokensTableAnnotationComposer a) f,
  ) {
    final $$QueueTokensTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.queueTokens,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QueueTokensTableAnnotationComposer(
            $db: $db,
            $table: $db.queueTokens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$QueueSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QueueSessionsTable,
          QueueSessionRow,
          $$QueueSessionsTableFilterComposer,
          $$QueueSessionsTableOrderingComposer,
          $$QueueSessionsTableAnnotationComposer,
          $$QueueSessionsTableCreateCompanionBuilder,
          $$QueueSessionsTableUpdateCompanionBuilder,
          (QueueSessionRow, $$QueueSessionsTableReferences),
          QueueSessionRow,
          PrefetchHooks Function({
            bool chamberId,
            bool sessionQueueCountersRefs,
            bool queueTokensRefs,
          })
        > {
  $$QueueSessionsTableTableManager(_$AppDatabase db, $QueueSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QueueSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QueueSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QueueSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> chamberId = const Value.absent(),
                Value<String> businessDate = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> openedAt = const Value.absent(),
                Value<String?> openedByAccountId = const Value.absent(),
                Value<int?> closedAt = const Value.absent(),
                Value<String?> closedByAccountId = const Value.absent(),
                Value<String?> closeReason = const Value.absent(),
                Value<String> configSnapshotJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QueueSessionsCompanion(
                id: id,
                chamberId: chamberId,
                businessDate: businessDate,
                status: status,
                openedAt: openedAt,
                openedByAccountId: openedByAccountId,
                closedAt: closedAt,
                closedByAccountId: closedByAccountId,
                closeReason: closeReason,
                configSnapshotJson: configSnapshotJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String chamberId,
                required String businessDate,
                required String status,
                required int openedAt,
                Value<String?> openedByAccountId = const Value.absent(),
                Value<int?> closedAt = const Value.absent(),
                Value<String?> closedByAccountId = const Value.absent(),
                Value<String?> closeReason = const Value.absent(),
                required String configSnapshotJson,
                Value<int> rowid = const Value.absent(),
              }) => QueueSessionsCompanion.insert(
                id: id,
                chamberId: chamberId,
                businessDate: businessDate,
                status: status,
                openedAt: openedAt,
                openedByAccountId: openedByAccountId,
                closedAt: closedAt,
                closedByAccountId: closedByAccountId,
                closeReason: closeReason,
                configSnapshotJson: configSnapshotJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$QueueSessionsTable, QueueSessionRow>(table),
                  $$QueueSessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                chamberId = false,
                sessionQueueCountersRefs = false,
                queueTokensRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (sessionQueueCountersRefs) db.sessionQueueCounters,
                    if (queueTokensRefs) db.queueTokens,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (chamberId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.chamberId,
                            referencedTable: $$QueueSessionsTableReferences
                                ._chamberIdTable(db),
                            referencedColumn: $$QueueSessionsTableReferences
                                ._chamberIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (sessionQueueCountersRefs)
                        await $_getPrefetchedDataByColumns<
                          QueueSessionRow,
                          $QueueSessionsTable,
                          SessionQueueCounterRow,
                          $SessionQueueCountersTable
                        >(
                          currentTable: table,
                          referencedTable: $$QueueSessionsTableReferences
                              ._sessionQueueCountersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$QueueSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).sessionQueueCountersRefs,
                          currentColumn: 'id',
                          referencedColumn: 'session_id',
                          typedResults: items,
                        ),
                      if (queueTokensRefs)
                        await $_getPrefetchedDataByColumns<
                          QueueSessionRow,
                          $QueueSessionsTable,
                          QueueTokenRow,
                          $QueueTokensTable
                        >(
                          currentTable: table,
                          referencedTable: $$QueueSessionsTableReferences
                              ._queueTokensRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$QueueSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).queueTokensRefs,
                          currentColumn: 'id',
                          referencedColumn: 'session_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$QueueSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QueueSessionsTable,
      QueueSessionRow,
      $$QueueSessionsTableFilterComposer,
      $$QueueSessionsTableOrderingComposer,
      $$QueueSessionsTableAnnotationComposer,
      $$QueueSessionsTableCreateCompanionBuilder,
      $$QueueSessionsTableUpdateCompanionBuilder,
      (QueueSessionRow, $$QueueSessionsTableReferences),
      QueueSessionRow,
      PrefetchHooks Function({
        bool chamberId,
        bool sessionQueueCountersRefs,
        bool queueTokensRefs,
      })
    >;
typedef $$SessionQueueCountersTableCreateCompanionBuilder =
    SessionQueueCountersCompanion Function({
      required String sessionId,
      required String queueTypeId,
      required int nextNumber,
      Value<int> issuedCount,
      Value<int> rowid,
    });
typedef $$SessionQueueCountersTableUpdateCompanionBuilder =
    SessionQueueCountersCompanion Function({
      Value<String> sessionId,
      Value<String> queueTypeId,
      Value<int> nextNumber,
      Value<int> issuedCount,
      Value<int> rowid,
    });

final class $$SessionQueueCountersTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $SessionQueueCountersTable,
          SessionQueueCounterRow
        > {
  $$SessionQueueCountersTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $QueueSessionsTable _sessionIdTable(_$AppDatabase db) => db
      .queueSessions
      .createAlias('session_queue_counters__session_id__queue_sessions__id');

  $$QueueSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$QueueSessionsTableTableManager(
      $_db,
      $_db.queueSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SessionQueueCountersTableFilterComposer
    extends Composer<_$AppDatabase, $SessionQueueCountersTable> {
  $$SessionQueueCountersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get queueTypeId => $composableBuilder(
    column: $table.queueTypeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nextNumber => $composableBuilder(
    column: $table.nextNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get issuedCount => $composableBuilder(
    column: $table.issuedCount,
    builder: (column) => ColumnFilters(column),
  );

  $$QueueSessionsTableFilterComposer get sessionId {
    final $$QueueSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.queueSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QueueSessionsTableFilterComposer(
            $db: $db,
            $table: $db.queueSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionQueueCountersTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionQueueCountersTable> {
  $$SessionQueueCountersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get queueTypeId => $composableBuilder(
    column: $table.queueTypeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nextNumber => $composableBuilder(
    column: $table.nextNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get issuedCount => $composableBuilder(
    column: $table.issuedCount,
    builder: (column) => ColumnOrderings(column),
  );

  $$QueueSessionsTableOrderingComposer get sessionId {
    final $$QueueSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.queueSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QueueSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.queueSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionQueueCountersTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionQueueCountersTable> {
  $$SessionQueueCountersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get queueTypeId => $composableBuilder(
    column: $table.queueTypeId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get nextNumber => $composableBuilder(
    column: $table.nextNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get issuedCount => $composableBuilder(
    column: $table.issuedCount,
    builder: (column) => column,
  );

  $$QueueSessionsTableAnnotationComposer get sessionId {
    final $$QueueSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.queueSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QueueSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.queueSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionQueueCountersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionQueueCountersTable,
          SessionQueueCounterRow,
          $$SessionQueueCountersTableFilterComposer,
          $$SessionQueueCountersTableOrderingComposer,
          $$SessionQueueCountersTableAnnotationComposer,
          $$SessionQueueCountersTableCreateCompanionBuilder,
          $$SessionQueueCountersTableUpdateCompanionBuilder,
          (SessionQueueCounterRow, $$SessionQueueCountersTableReferences),
          SessionQueueCounterRow,
          PrefetchHooks Function({bool sessionId})
        > {
  $$SessionQueueCountersTableTableManager(
    _$AppDatabase db,
    $SessionQueueCountersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionQueueCountersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionQueueCountersTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SessionQueueCountersTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> sessionId = const Value.absent(),
                Value<String> queueTypeId = const Value.absent(),
                Value<int> nextNumber = const Value.absent(),
                Value<int> issuedCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionQueueCountersCompanion(
                sessionId: sessionId,
                queueTypeId: queueTypeId,
                nextNumber: nextNumber,
                issuedCount: issuedCount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sessionId,
                required String queueTypeId,
                required int nextNumber,
                Value<int> issuedCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionQueueCountersCompanion.insert(
                sessionId: sessionId,
                queueTypeId: queueTypeId,
                nextNumber: nextNumber,
                issuedCount: issuedCount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $SessionQueueCountersTable,
                    SessionQueueCounterRow
                  >(table),
                  $$SessionQueueCountersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sessionId,
                        referencedTable: $$SessionQueueCountersTableReferences
                            ._sessionIdTable(db),
                        referencedColumn: $$SessionQueueCountersTableReferences
                            ._sessionIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SessionQueueCountersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionQueueCountersTable,
      SessionQueueCounterRow,
      $$SessionQueueCountersTableFilterComposer,
      $$SessionQueueCountersTableOrderingComposer,
      $$SessionQueueCountersTableAnnotationComposer,
      $$SessionQueueCountersTableCreateCompanionBuilder,
      $$SessionQueueCountersTableUpdateCompanionBuilder,
      (SessionQueueCounterRow, $$SessionQueueCountersTableReferences),
      SessionQueueCounterRow,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$PatientsTableCreateCompanionBuilder = PatientsCompanion Function({
  required String id,
  required int patientNumber,
  required String bengaliName,
  Value<String?> englishName,
  required String phoneNormalized,
  Value<String?> gender,
  Value<int?> dateOfBirthMs,
  Value<int?> birthYear,
  Value<int?> approximateAgeYears,
  Value<int?> approximateAgeRecordedAt,
  Value<String?> locality,
  Value<String?> legacyFileNumber,
  Value<String?> adminNote,
  Value<bool> hasPaperFile,
  required int createdAt,
  Value<int> rowid,
});
typedef $$PatientsTableUpdateCompanionBuilder = PatientsCompanion Function({
  Value<String> id,
  Value<int> patientNumber,
  Value<String> bengaliName,
  Value<String?> englishName,
  Value<String> phoneNormalized,
  Value<String?> gender,
  Value<int?> dateOfBirthMs,
  Value<int?> birthYear,
  Value<int?> approximateAgeYears,
  Value<int?> approximateAgeRecordedAt,
  Value<String?> locality,
  Value<String?> legacyFileNumber,
  Value<String?> adminNote,
  Value<bool> hasPaperFile,
  Value<int> createdAt,
  Value<int> rowid,
});

final class $$PatientsTableReferences
    extends BaseReferences<_$AppDatabase, $PatientsTable, PatientRow> {
  $$PatientsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$QueueTokensTable, List<QueueTokenRow>>
  _queueTokensRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.queueTokens,
    aliasName: 'patients__id__queue_tokens__patient_id',
  );

  $$QueueTokensTableProcessedTableManager get queueTokensRefs {
    final manager = $$QueueTokensTableTableManager(
      $_db,
      $_db.queueTokens,
    ).filter((f) => f.patientId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_queueTokensRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PatientsTableFilterComposer
    extends Composer<_$AppDatabase, $PatientsTable> {
  $$PatientsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get patientNumber => $composableBuilder(
    column: $table.patientNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bengaliName => $composableBuilder(
    column: $table.bengaliName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get englishName => $composableBuilder(
    column: $table.englishName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phoneNormalized => $composableBuilder(
    column: $table.phoneNormalized,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dateOfBirthMs => $composableBuilder(
    column: $table.dateOfBirthMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get birthYear => $composableBuilder(
    column: $table.birthYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get approximateAgeYears => $composableBuilder(
    column: $table.approximateAgeYears,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get approximateAgeRecordedAt => $composableBuilder(
    column: $table.approximateAgeRecordedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locality => $composableBuilder(
    column: $table.locality,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get legacyFileNumber => $composableBuilder(
    column: $table.legacyFileNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get adminNote => $composableBuilder(
    column: $table.adminNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasPaperFile => $composableBuilder(
    column: $table.hasPaperFile,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> queueTokensRefs(
    Expression<bool> Function($$QueueTokensTableFilterComposer f) f,
  ) {
    final $$QueueTokensTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.queueTokens,
      getReferencedColumn: (t) => t.patientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QueueTokensTableFilterComposer(
            $db: $db,
            $table: $db.queueTokens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PatientsTableOrderingComposer
    extends Composer<_$AppDatabase, $PatientsTable> {
  $$PatientsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get patientNumber => $composableBuilder(
    column: $table.patientNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bengaliName => $composableBuilder(
    column: $table.bengaliName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get englishName => $composableBuilder(
    column: $table.englishName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phoneNormalized => $composableBuilder(
    column: $table.phoneNormalized,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dateOfBirthMs => $composableBuilder(
    column: $table.dateOfBirthMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get birthYear => $composableBuilder(
    column: $table.birthYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get approximateAgeYears => $composableBuilder(
    column: $table.approximateAgeYears,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get approximateAgeRecordedAt => $composableBuilder(
    column: $table.approximateAgeRecordedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locality => $composableBuilder(
    column: $table.locality,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get legacyFileNumber => $composableBuilder(
    column: $table.legacyFileNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get adminNote => $composableBuilder(
    column: $table.adminNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasPaperFile => $composableBuilder(
    column: $table.hasPaperFile,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PatientsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PatientsTable> {
  $$PatientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get patientNumber => $composableBuilder(
    column: $table.patientNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bengaliName => $composableBuilder(
    column: $table.bengaliName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get englishName => $composableBuilder(
    column: $table.englishName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get phoneNormalized => $composableBuilder(
    column: $table.phoneNormalized,
    builder: (column) => column,
  );

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<int> get dateOfBirthMs => $composableBuilder(
    column: $table.dateOfBirthMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get birthYear =>
      $composableBuilder(column: $table.birthYear, builder: (column) => column);

  GeneratedColumn<int> get approximateAgeYears => $composableBuilder(
    column: $table.approximateAgeYears,
    builder: (column) => column,
  );

  GeneratedColumn<int> get approximateAgeRecordedAt => $composableBuilder(
    column: $table.approximateAgeRecordedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get locality =>
      $composableBuilder(column: $table.locality, builder: (column) => column);

  GeneratedColumn<String> get legacyFileNumber => $composableBuilder(
    column: $table.legacyFileNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get adminNote =>
      $composableBuilder(column: $table.adminNote, builder: (column) => column);

  GeneratedColumn<bool> get hasPaperFile => $composableBuilder(
    column: $table.hasPaperFile,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> queueTokensRefs<T extends Object>(
    Expression<T> Function($$QueueTokensTableAnnotationComposer a) f,
  ) {
    final $$QueueTokensTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.queueTokens,
      getReferencedColumn: (t) => t.patientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QueueTokensTableAnnotationComposer(
            $db: $db,
            $table: $db.queueTokens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PatientsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PatientsTable,
          PatientRow,
          $$PatientsTableFilterComposer,
          $$PatientsTableOrderingComposer,
          $$PatientsTableAnnotationComposer,
          $$PatientsTableCreateCompanionBuilder,
          $$PatientsTableUpdateCompanionBuilder,
          (PatientRow, $$PatientsTableReferences),
          PatientRow,
          PrefetchHooks Function({bool queueTokensRefs})
        > {
  $$PatientsTableTableManager(_$AppDatabase db, $PatientsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PatientsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PatientsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PatientsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> patientNumber = const Value.absent(),
                Value<String> bengaliName = const Value.absent(),
                Value<String?> englishName = const Value.absent(),
                Value<String> phoneNormalized = const Value.absent(),
                Value<String?> gender = const Value.absent(),
                Value<int?> dateOfBirthMs = const Value.absent(),
                Value<int?> birthYear = const Value.absent(),
                Value<int?> approximateAgeYears = const Value.absent(),
                Value<int?> approximateAgeRecordedAt = const Value.absent(),
                Value<String?> locality = const Value.absent(),
                Value<String?> legacyFileNumber = const Value.absent(),
                Value<String?> adminNote = const Value.absent(),
                Value<bool> hasPaperFile = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PatientsCompanion(
                id: id,
                patientNumber: patientNumber,
                bengaliName: bengaliName,
                englishName: englishName,
                phoneNormalized: phoneNormalized,
                gender: gender,
                dateOfBirthMs: dateOfBirthMs,
                birthYear: birthYear,
                approximateAgeYears: approximateAgeYears,
                approximateAgeRecordedAt: approximateAgeRecordedAt,
                locality: locality,
                legacyFileNumber: legacyFileNumber,
                adminNote: adminNote,
                hasPaperFile: hasPaperFile,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int patientNumber,
                required String bengaliName,
                Value<String?> englishName = const Value.absent(),
                required String phoneNormalized,
                Value<String?> gender = const Value.absent(),
                Value<int?> dateOfBirthMs = const Value.absent(),
                Value<int?> birthYear = const Value.absent(),
                Value<int?> approximateAgeYears = const Value.absent(),
                Value<int?> approximateAgeRecordedAt = const Value.absent(),
                Value<String?> locality = const Value.absent(),
                Value<String?> legacyFileNumber = const Value.absent(),
                Value<String?> adminNote = const Value.absent(),
                Value<bool> hasPaperFile = const Value.absent(),
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => PatientsCompanion.insert(
                id: id,
                patientNumber: patientNumber,
                bengaliName: bengaliName,
                englishName: englishName,
                phoneNormalized: phoneNormalized,
                gender: gender,
                dateOfBirthMs: dateOfBirthMs,
                birthYear: birthYear,
                approximateAgeYears: approximateAgeYears,
                approximateAgeRecordedAt: approximateAgeRecordedAt,
                locality: locality,
                legacyFileNumber: legacyFileNumber,
                adminNote: adminNote,
                hasPaperFile: hasPaperFile,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PatientsTable, PatientRow>(table),
                  $$PatientsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({queueTokensRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (queueTokensRefs) db.queueTokens],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (queueTokensRefs)
                    await $_getPrefetchedDataByColumns<
                      PatientRow,
                      $PatientsTable,
                      QueueTokenRow,
                      $QueueTokensTable
                    >(
                      currentTable: table,
                      referencedTable: $$PatientsTableReferences
                          ._queueTokensRefsTable(db),
                      managerFromTypedResult: (p0) => $$PatientsTableReferences(
                        db,
                        table,
                        p0,
                      ).queueTokensRefs,
                      currentColumn: 'id',
                      referencedColumn: 'patient_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PatientsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PatientsTable,
      PatientRow,
      $$PatientsTableFilterComposer,
      $$PatientsTableOrderingComposer,
      $$PatientsTableAnnotationComposer,
      $$PatientsTableCreateCompanionBuilder,
      $$PatientsTableUpdateCompanionBuilder,
      (PatientRow, $$PatientsTableReferences),
      PatientRow,
      PrefetchHooks Function({bool queueTokensRefs})
    >;
typedef $$IdempotentCommandsTableCreateCompanionBuilder =
    IdempotentCommandsCompanion Function({
      required String commandId,
      required String resultJson,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$IdempotentCommandsTableUpdateCompanionBuilder =
    IdempotentCommandsCompanion Function({
      Value<String> commandId,
      Value<String> resultJson,
      Value<int> createdAt,
      Value<int> rowid,
    });

class $$IdempotentCommandsTableFilterComposer
    extends Composer<_$AppDatabase, $IdempotentCommandsTable> {
  $$IdempotentCommandsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get commandId => $composableBuilder(
    column: $table.commandId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resultJson => $composableBuilder(
    column: $table.resultJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$IdempotentCommandsTableOrderingComposer
    extends Composer<_$AppDatabase, $IdempotentCommandsTable> {
  $$IdempotentCommandsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get commandId => $composableBuilder(
    column: $table.commandId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resultJson => $composableBuilder(
    column: $table.resultJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$IdempotentCommandsTableAnnotationComposer
    extends Composer<_$AppDatabase, $IdempotentCommandsTable> {
  $$IdempotentCommandsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get commandId =>
      $composableBuilder(column: $table.commandId, builder: (column) => column);

  GeneratedColumn<String> get resultJson => $composableBuilder(
    column: $table.resultJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$IdempotentCommandsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IdempotentCommandsTable,
          IdempotentCommandRow,
          $$IdempotentCommandsTableFilterComposer,
          $$IdempotentCommandsTableOrderingComposer,
          $$IdempotentCommandsTableAnnotationComposer,
          $$IdempotentCommandsTableCreateCompanionBuilder,
          $$IdempotentCommandsTableUpdateCompanionBuilder,
          (
            IdempotentCommandRow,
            BaseReferences<
              _$AppDatabase,
              $IdempotentCommandsTable,
              IdempotentCommandRow
            >,
          ),
          IdempotentCommandRow,
          PrefetchHooks Function()
        > {
  $$IdempotentCommandsTableTableManager(
    _$AppDatabase db,
    $IdempotentCommandsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IdempotentCommandsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IdempotentCommandsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IdempotentCommandsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> commandId = const Value.absent(),
                Value<String> resultJson = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IdempotentCommandsCompanion(
                commandId: commandId,
                resultJson: resultJson,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String commandId,
                required String resultJson,
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => IdempotentCommandsCompanion.insert(
                commandId: commandId,
                resultJson: resultJson,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$IdempotentCommandsTable, IdempotentCommandRow>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $IdempotentCommandsTable,
                    IdempotentCommandRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$IdempotentCommandsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IdempotentCommandsTable,
      IdempotentCommandRow,
      $$IdempotentCommandsTableFilterComposer,
      $$IdempotentCommandsTableOrderingComposer,
      $$IdempotentCommandsTableAnnotationComposer,
      $$IdempotentCommandsTableCreateCompanionBuilder,
      $$IdempotentCommandsTableUpdateCompanionBuilder,
      (
        IdempotentCommandRow,
        BaseReferences<
          _$AppDatabase,
          $IdempotentCommandsTable,
          IdempotentCommandRow
        >,
      ),
      IdempotentCommandRow,
      PrefetchHooks Function()
    >;
typedef $$QueueTokensTableCreateCompanionBuilder =
    QueueTokensCompanion Function({
      required String id,
      required String sessionId,
      required String chamberId,
      required String patientId,
      required String queueTypeId,
      required int serial,
      required String status,
      Value<int?> feeBdt,
      required int issuedAt,
      Value<int?> firstCalledAt,
      Value<int?> enteredAt,
      Value<int?> cancelledAt,
      Value<String?> cancelReason,
      Value<String?> latestPrintStatus,
      Value<int> rowid,
    });
typedef $$QueueTokensTableUpdateCompanionBuilder =
    QueueTokensCompanion Function({
      Value<String> id,
      Value<String> sessionId,
      Value<String> chamberId,
      Value<String> patientId,
      Value<String> queueTypeId,
      Value<int> serial,
      Value<String> status,
      Value<int?> feeBdt,
      Value<int> issuedAt,
      Value<int?> firstCalledAt,
      Value<int?> enteredAt,
      Value<int?> cancelledAt,
      Value<String?> cancelReason,
      Value<String?> latestPrintStatus,
      Value<int> rowid,
    });

final class $$QueueTokensTableReferences
    extends BaseReferences<_$AppDatabase, $QueueTokensTable, QueueTokenRow> {
  $$QueueTokensTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $QueueSessionsTable _sessionIdTable(_$AppDatabase db) => db
      .queueSessions
      .createAlias('queue_tokens__session_id__queue_sessions__id');

  $$QueueSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$QueueSessionsTableTableManager(
      $_db,
      $_db.queueSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ChambersTable _chamberIdTable(_$AppDatabase db) =>
      db.chambers.createAlias('queue_tokens__chamber_id__chambers__id');

  $$ChambersTableProcessedTableManager get chamberId {
    final $_column = $_itemColumn<String>('chamber_id')!;

    final manager = $$ChambersTableTableManager(
      $_db,
      $_db.chambers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_chamberIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PatientsTable _patientIdTable(_$AppDatabase db) =>
      db.patients.createAlias('queue_tokens__patient_id__patients__id');

  $$PatientsTableProcessedTableManager get patientId {
    final $_column = $_itemColumn<String>('patient_id')!;

    final manager = $$PatientsTableTableManager(
      $_db,
      $_db.patients,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_patientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $TokenPrintAttemptsTable,
    List<TokenPrintAttemptRow>
  >
  _tokenPrintAttemptsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.tokenPrintAttempts,
        aliasName: 'queue_tokens__id__token_print_attempts__token_id',
      );

  $$TokenPrintAttemptsTableProcessedTableManager get tokenPrintAttemptsRefs {
    final manager = $$TokenPrintAttemptsTableTableManager(
      $_db,
      $_db.tokenPrintAttempts,
    ).filter((f) => f.tokenId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _tokenPrintAttemptsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$QueueTokensTableFilterComposer
    extends Composer<_$AppDatabase, $QueueTokensTable> {
  $$QueueTokensTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get queueTypeId => $composableBuilder(
    column: $table.queueTypeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serial => $composableBuilder(
    column: $table.serial,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get feeBdt => $composableBuilder(
    column: $table.feeBdt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get issuedAt => $composableBuilder(
    column: $table.issuedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get firstCalledAt => $composableBuilder(
    column: $table.firstCalledAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get enteredAt => $composableBuilder(
    column: $table.enteredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cancelledAt => $composableBuilder(
    column: $table.cancelledAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cancelReason => $composableBuilder(
    column: $table.cancelReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get latestPrintStatus => $composableBuilder(
    column: $table.latestPrintStatus,
    builder: (column) => ColumnFilters(column),
  );

  $$QueueSessionsTableFilterComposer get sessionId {
    final $$QueueSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.queueSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QueueSessionsTableFilterComposer(
            $db: $db,
            $table: $db.queueSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ChambersTableFilterComposer get chamberId {
    final $$ChambersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chamberId,
      referencedTable: $db.chambers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChambersTableFilterComposer(
            $db: $db,
            $table: $db.chambers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PatientsTableFilterComposer get patientId {
    final $$PatientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableFilterComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> tokenPrintAttemptsRefs(
    Expression<bool> Function($$TokenPrintAttemptsTableFilterComposer f) f,
  ) {
    final $$TokenPrintAttemptsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tokenPrintAttempts,
      getReferencedColumn: (t) => t.tokenId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TokenPrintAttemptsTableFilterComposer(
            $db: $db,
            $table: $db.tokenPrintAttempts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$QueueTokensTableOrderingComposer
    extends Composer<_$AppDatabase, $QueueTokensTable> {
  $$QueueTokensTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get queueTypeId => $composableBuilder(
    column: $table.queueTypeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serial => $composableBuilder(
    column: $table.serial,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get feeBdt => $composableBuilder(
    column: $table.feeBdt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get issuedAt => $composableBuilder(
    column: $table.issuedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get firstCalledAt => $composableBuilder(
    column: $table.firstCalledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get enteredAt => $composableBuilder(
    column: $table.enteredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cancelledAt => $composableBuilder(
    column: $table.cancelledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cancelReason => $composableBuilder(
    column: $table.cancelReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get latestPrintStatus => $composableBuilder(
    column: $table.latestPrintStatus,
    builder: (column) => ColumnOrderings(column),
  );

  $$QueueSessionsTableOrderingComposer get sessionId {
    final $$QueueSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.queueSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QueueSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.queueSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ChambersTableOrderingComposer get chamberId {
    final $$ChambersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chamberId,
      referencedTable: $db.chambers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChambersTableOrderingComposer(
            $db: $db,
            $table: $db.chambers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PatientsTableOrderingComposer get patientId {
    final $$PatientsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableOrderingComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QueueTokensTableAnnotationComposer
    extends Composer<_$AppDatabase, $QueueTokensTable> {
  $$QueueTokensTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get queueTypeId => $composableBuilder(
    column: $table.queueTypeId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get serial =>
      $composableBuilder(column: $table.serial, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get feeBdt =>
      $composableBuilder(column: $table.feeBdt, builder: (column) => column);

  GeneratedColumn<int> get issuedAt =>
      $composableBuilder(column: $table.issuedAt, builder: (column) => column);

  GeneratedColumn<int> get firstCalledAt => $composableBuilder(
    column: $table.firstCalledAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get enteredAt =>
      $composableBuilder(column: $table.enteredAt, builder: (column) => column);

  GeneratedColumn<int> get cancelledAt => $composableBuilder(
    column: $table.cancelledAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cancelReason => $composableBuilder(
    column: $table.cancelReason,
    builder: (column) => column,
  );

  GeneratedColumn<String> get latestPrintStatus => $composableBuilder(
    column: $table.latestPrintStatus,
    builder: (column) => column,
  );

  $$QueueSessionsTableAnnotationComposer get sessionId {
    final $$QueueSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.queueSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QueueSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.queueSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ChambersTableAnnotationComposer get chamberId {
    final $$ChambersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chamberId,
      referencedTable: $db.chambers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChambersTableAnnotationComposer(
            $db: $db,
            $table: $db.chambers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PatientsTableAnnotationComposer get patientId {
    final $$PatientsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableAnnotationComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> tokenPrintAttemptsRefs<T extends Object>(
    Expression<T> Function($$TokenPrintAttemptsTableAnnotationComposer a) f,
  ) {
    final $$TokenPrintAttemptsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.tokenPrintAttempts,
          getReferencedColumn: (t) => t.tokenId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TokenPrintAttemptsTableAnnotationComposer(
                $db: $db,
                $table: $db.tokenPrintAttempts,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$QueueTokensTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QueueTokensTable,
          QueueTokenRow,
          $$QueueTokensTableFilterComposer,
          $$QueueTokensTableOrderingComposer,
          $$QueueTokensTableAnnotationComposer,
          $$QueueTokensTableCreateCompanionBuilder,
          $$QueueTokensTableUpdateCompanionBuilder,
          (QueueTokenRow, $$QueueTokensTableReferences),
          QueueTokenRow,
          PrefetchHooks Function({
            bool sessionId,
            bool chamberId,
            bool patientId,
            bool tokenPrintAttemptsRefs,
          })
        > {
  $$QueueTokensTableTableManager(_$AppDatabase db, $QueueTokensTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QueueTokensTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QueueTokensTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QueueTokensTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String> chamberId = const Value.absent(),
                Value<String> patientId = const Value.absent(),
                Value<String> queueTypeId = const Value.absent(),
                Value<int> serial = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> feeBdt = const Value.absent(),
                Value<int> issuedAt = const Value.absent(),
                Value<int?> firstCalledAt = const Value.absent(),
                Value<int?> enteredAt = const Value.absent(),
                Value<int?> cancelledAt = const Value.absent(),
                Value<String?> cancelReason = const Value.absent(),
                Value<String?> latestPrintStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QueueTokensCompanion(
                id: id,
                sessionId: sessionId,
                chamberId: chamberId,
                patientId: patientId,
                queueTypeId: queueTypeId,
                serial: serial,
                status: status,
                feeBdt: feeBdt,
                issuedAt: issuedAt,
                firstCalledAt: firstCalledAt,
                enteredAt: enteredAt,
                cancelledAt: cancelledAt,
                cancelReason: cancelReason,
                latestPrintStatus: latestPrintStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sessionId,
                required String chamberId,
                required String patientId,
                required String queueTypeId,
                required int serial,
                required String status,
                Value<int?> feeBdt = const Value.absent(),
                required int issuedAt,
                Value<int?> firstCalledAt = const Value.absent(),
                Value<int?> enteredAt = const Value.absent(),
                Value<int?> cancelledAt = const Value.absent(),
                Value<String?> cancelReason = const Value.absent(),
                Value<String?> latestPrintStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QueueTokensCompanion.insert(
                id: id,
                sessionId: sessionId,
                chamberId: chamberId,
                patientId: patientId,
                queueTypeId: queueTypeId,
                serial: serial,
                status: status,
                feeBdt: feeBdt,
                issuedAt: issuedAt,
                firstCalledAt: firstCalledAt,
                enteredAt: enteredAt,
                cancelledAt: cancelledAt,
                cancelReason: cancelReason,
                latestPrintStatus: latestPrintStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$QueueTokensTable, QueueTokenRow>(table),
                  $$QueueTokensTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                sessionId = false,
                chamberId = false,
                patientId = false,
                tokenPrintAttemptsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (tokenPrintAttemptsRefs) db.tokenPrintAttempts,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (sessionId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.sessionId,
                            referencedTable: $$QueueTokensTableReferences
                                ._sessionIdTable(db),
                            referencedColumn: $$QueueTokensTableReferences
                                ._sessionIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (chamberId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.chamberId,
                            referencedTable: $$QueueTokensTableReferences
                                ._chamberIdTable(db),
                            referencedColumn: $$QueueTokensTableReferences
                                ._chamberIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (patientId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.patientId,
                            referencedTable: $$QueueTokensTableReferences
                                ._patientIdTable(db),
                            referencedColumn: $$QueueTokensTableReferences
                                ._patientIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (tokenPrintAttemptsRefs)
                        await $_getPrefetchedDataByColumns<
                          QueueTokenRow,
                          $QueueTokensTable,
                          TokenPrintAttemptRow,
                          $TokenPrintAttemptsTable
                        >(
                          currentTable: table,
                          referencedTable: $$QueueTokensTableReferences
                              ._tokenPrintAttemptsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$QueueTokensTableReferences(
                                db,
                                table,
                                p0,
                              ).tokenPrintAttemptsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'token_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$QueueTokensTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QueueTokensTable,
      QueueTokenRow,
      $$QueueTokensTableFilterComposer,
      $$QueueTokensTableOrderingComposer,
      $$QueueTokensTableAnnotationComposer,
      $$QueueTokensTableCreateCompanionBuilder,
      $$QueueTokensTableUpdateCompanionBuilder,
      (QueueTokenRow, $$QueueTokensTableReferences),
      QueueTokenRow,
      PrefetchHooks Function({
        bool sessionId,
        bool chamberId,
        bool patientId,
        bool tokenPrintAttemptsRefs,
      })
    >;
typedef $$TokenPrintAttemptsTableCreateCompanionBuilder =
    TokenPrintAttemptsCompanion Function({
      required String id,
      required String tokenId,
      required int attemptNumber,
      required String status,
      Value<String?> reason,
      Value<String?> actorAccountId,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$TokenPrintAttemptsTableUpdateCompanionBuilder =
    TokenPrintAttemptsCompanion Function({
      Value<String> id,
      Value<String> tokenId,
      Value<int> attemptNumber,
      Value<String> status,
      Value<String?> reason,
      Value<String?> actorAccountId,
      Value<int> createdAt,
      Value<int> rowid,
    });

final class $$TokenPrintAttemptsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $TokenPrintAttemptsTable,
          TokenPrintAttemptRow
        > {
  $$TokenPrintAttemptsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $QueueTokensTable _tokenIdTable(_$AppDatabase db) => db.queueTokens
      .createAlias('token_print_attempts__token_id__queue_tokens__id');

  $$QueueTokensTableProcessedTableManager get tokenId {
    final $_column = $_itemColumn<String>('token_id')!;

    final manager = $$QueueTokensTableTableManager(
      $_db,
      $_db.queueTokens,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tokenIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TokenPrintAttemptsTableFilterComposer
    extends Composer<_$AppDatabase, $TokenPrintAttemptsTable> {
  $$TokenPrintAttemptsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attemptNumber => $composableBuilder(
    column: $table.attemptNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actorAccountId => $composableBuilder(
    column: $table.actorAccountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$QueueTokensTableFilterComposer get tokenId {
    final $$QueueTokensTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tokenId,
      referencedTable: $db.queueTokens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QueueTokensTableFilterComposer(
            $db: $db,
            $table: $db.queueTokens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TokenPrintAttemptsTableOrderingComposer
    extends Composer<_$AppDatabase, $TokenPrintAttemptsTable> {
  $$TokenPrintAttemptsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attemptNumber => $composableBuilder(
    column: $table.attemptNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actorAccountId => $composableBuilder(
    column: $table.actorAccountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$QueueTokensTableOrderingComposer get tokenId {
    final $$QueueTokensTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tokenId,
      referencedTable: $db.queueTokens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QueueTokensTableOrderingComposer(
            $db: $db,
            $table: $db.queueTokens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TokenPrintAttemptsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TokenPrintAttemptsTable> {
  $$TokenPrintAttemptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get attemptNumber => $composableBuilder(
    column: $table.attemptNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get actorAccountId => $composableBuilder(
    column: $table.actorAccountId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$QueueTokensTableAnnotationComposer get tokenId {
    final $$QueueTokensTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tokenId,
      referencedTable: $db.queueTokens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QueueTokensTableAnnotationComposer(
            $db: $db,
            $table: $db.queueTokens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TokenPrintAttemptsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TokenPrintAttemptsTable,
          TokenPrintAttemptRow,
          $$TokenPrintAttemptsTableFilterComposer,
          $$TokenPrintAttemptsTableOrderingComposer,
          $$TokenPrintAttemptsTableAnnotationComposer,
          $$TokenPrintAttemptsTableCreateCompanionBuilder,
          $$TokenPrintAttemptsTableUpdateCompanionBuilder,
          (TokenPrintAttemptRow, $$TokenPrintAttemptsTableReferences),
          TokenPrintAttemptRow,
          PrefetchHooks Function({bool tokenId})
        > {
  $$TokenPrintAttemptsTableTableManager(
    _$AppDatabase db,
    $TokenPrintAttemptsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TokenPrintAttemptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TokenPrintAttemptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TokenPrintAttemptsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tokenId = const Value.absent(),
                Value<int> attemptNumber = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                Value<String?> actorAccountId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TokenPrintAttemptsCompanion(
                id: id,
                tokenId: tokenId,
                attemptNumber: attemptNumber,
                status: status,
                reason: reason,
                actorAccountId: actorAccountId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tokenId,
                required int attemptNumber,
                required String status,
                Value<String?> reason = const Value.absent(),
                Value<String?> actorAccountId = const Value.absent(),
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => TokenPrintAttemptsCompanion.insert(
                id: id,
                tokenId: tokenId,
                attemptNumber: attemptNumber,
                status: status,
                reason: reason,
                actorAccountId: actorAccountId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TokenPrintAttemptsTable, TokenPrintAttemptRow>(
                    table,
                  ),
                  $$TokenPrintAttemptsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({tokenId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (tokenId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.tokenId,
                        referencedTable: $$TokenPrintAttemptsTableReferences
                            ._tokenIdTable(db),
                        referencedColumn: $$TokenPrintAttemptsTableReferences
                            ._tokenIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TokenPrintAttemptsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TokenPrintAttemptsTable,
      TokenPrintAttemptRow,
      $$TokenPrintAttemptsTableFilterComposer,
      $$TokenPrintAttemptsTableOrderingComposer,
      $$TokenPrintAttemptsTableAnnotationComposer,
      $$TokenPrintAttemptsTableCreateCompanionBuilder,
      $$TokenPrintAttemptsTableUpdateCompanionBuilder,
      (TokenPrintAttemptRow, $$TokenPrintAttemptsTableReferences),
      TokenPrintAttemptRow,
      PrefetchHooks Function({bool tokenId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DoctorsTableTableManager get doctors =>
      $$DoctorsTableTableManager(_db, _db.doctors);
  $$ChambersTableTableManager get chambers =>
      $$ChambersTableTableManager(_db, _db.chambers);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$UserScopeAssignmentsTableTableManager get userScopeAssignments =>
      $$UserScopeAssignmentsTableTableManager(_db, _db.userScopeAssignments);
  $$AuthSessionsTableTableManager get authSessions =>
      $$AuthSessionsTableTableManager(_db, _db.authSessions);
  $$AuditEntriesTableTableManager get auditEntries =>
      $$AuditEntriesTableTableManager(_db, _db.auditEntries);
  $$PinDevicesTableTableManager get pinDevices =>
      $$PinDevicesTableTableManager(_db, _db.pinDevices);
  $$QueueTypesTableTableManager get queueTypes =>
      $$QueueTypesTableTableManager(_db, _db.queueTypes);
  $$QueueSessionsTableTableManager get queueSessions =>
      $$QueueSessionsTableTableManager(_db, _db.queueSessions);
  $$SessionQueueCountersTableTableManager get sessionQueueCounters =>
      $$SessionQueueCountersTableTableManager(_db, _db.sessionQueueCounters);
  $$PatientsTableTableManager get patients =>
      $$PatientsTableTableManager(_db, _db.patients);
  $$IdempotentCommandsTableTableManager get idempotentCommands =>
      $$IdempotentCommandsTableTableManager(_db, _db.idempotentCommands);
  $$QueueTokensTableTableManager get queueTokens =>
      $$QueueTokensTableTableManager(_db, _db.queueTokens);
  $$TokenPrintAttemptsTableTableManager get tokenPrintAttempts =>
      $$TokenPrintAttemptsTableTableManager(_db, _db.tokenPrintAttempts);
}
