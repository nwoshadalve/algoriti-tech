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
          PrefetchHooks Function({bool doctorId})
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
          prefetchHooksCallback: ({doctorId = false}) {
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
                return [];
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
      PrefetchHooks Function({bool doctorId})
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
}
