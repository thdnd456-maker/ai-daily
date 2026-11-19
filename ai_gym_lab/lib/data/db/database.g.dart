// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(Insertable<User> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class User extends DataClass implements Insertable<User> {
  final int id;
  final DateTime createdAt;
  const User({required this.id, required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(id: Value(id), createdAt: Value(createdAt));
  }

  factory User.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(id: serializer.fromJson<int>(json['id']), createdAt: serializer.fromJson<DateTime>(json['createdAt']));
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'id': serializer.toJson<int>(id), 'createdAt': serializer.toJson<DateTime>(createdAt)};
  }

  User copyWith({int? id, DateTime? createdAt}) => User(id: id ?? this.id, createdAt: createdAt ?? this.createdAt);
  User copyWithCompanion(UsersCompanion data) {
    return User(id: data.id.present ? data.id.value : this.id, createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt);
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, createdAt);
  @override
  bool operator ==(Object other) => identical(this, other) || (other is User && other.id == this.id && other.createdAt == this.createdAt);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<int> id;
  final Value<DateTime> createdAt;
  const UsersCompanion({this.id = const Value.absent(), this.createdAt = const Value.absent()});
  UsersCompanion.insert({this.id = const Value.absent(), this.createdAt = const Value.absent()});
  static Insertable<User> custom({Expression<int>? id, Expression<DateTime>? createdAt}) {
    return RawValuesInsertable({if (id != null) 'id': id, if (createdAt != null) 'created_at': createdAt});
  }

  UsersCompanion copyWith({Value<int>? id, Value<DateTime>? createdAt}) {
    return UsersCompanion(id: id ?? this.id, createdAt: createdAt ?? this.createdAt);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $UserProfilesTable extends UserProfiles with TableInfo<$UserProfilesTable, UserProfileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES users (id)'),
  );
  static const VerificationMeta _sexMeta = const VerificationMeta('sex');
  @override
  late final GeneratedColumn<String> sex = GeneratedColumn<String>('sex', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ageMeta = const VerificationMeta('age');
  @override
  late final GeneratedColumn<int> age = GeneratedColumn<int>('age', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _heightCmMeta = const VerificationMeta('heightCm');
  @override
  late final GeneratedColumn<double> heightCm = GeneratedColumn<double>('height_cm', aliasedName, false, type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _weightKgMeta = const VerificationMeta('weightKg');
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>('weight_kg', aliasedName, false, type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _targetWeightKgMeta = const VerificationMeta('targetWeightKg');
  @override
  late final GeneratedColumn<double> targetWeightKg = GeneratedColumn<double>(
    'target_weight_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bodyFatPctMeta = const VerificationMeta('bodyFatPct');
  @override
  late final GeneratedColumn<double> bodyFatPct = GeneratedColumn<double>(
    'body_fat_pct',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _skeletalMuscleKgMeta = const VerificationMeta('skeletalMuscleKg');
  @override
  late final GeneratedColumn<double> skeletalMuscleKg = GeneratedColumn<double>(
    'skeletal_muscle_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _experienceMeta = const VerificationMeta('experience');
  @override
  late final GeneratedColumn<String> experience = GeneratedColumn<String>(
    'experience',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _daysPerWeekMeta = const VerificationMeta('daysPerWeek');
  @override
  late final GeneratedColumn<int> daysPerWeek = GeneratedColumn<int>('days_per_week', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _sessionMinutesMeta = const VerificationMeta('sessionMinutes');
  @override
  late final GeneratedColumn<int> sessionMinutes = GeneratedColumn<int>(
    'session_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _environmentMeta = const VerificationMeta('environment');
  @override
  late final GeneratedColumn<String> environment = GeneratedColumn<String>(
    'environment',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    sex,
    age,
    heightCm,
    weightKg,
    targetWeightKg,
    bodyFatPct,
    skeletalMuscleKg,
    experience,
    daysPerWeek,
    sessionMinutes,
    environment,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_profiles';
  @override
  VerificationContext validateIntegrity(Insertable<UserProfileRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta, userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    }
    if (data.containsKey('sex')) {
      context.handle(_sexMeta, sex.isAcceptableOrUnknown(data['sex']!, _sexMeta));
    } else if (isInserting) {
      context.missing(_sexMeta);
    }
    if (data.containsKey('age')) {
      context.handle(_ageMeta, age.isAcceptableOrUnknown(data['age']!, _ageMeta));
    } else if (isInserting) {
      context.missing(_ageMeta);
    }
    if (data.containsKey('height_cm')) {
      context.handle(_heightCmMeta, heightCm.isAcceptableOrUnknown(data['height_cm']!, _heightCmMeta));
    } else if (isInserting) {
      context.missing(_heightCmMeta);
    }
    if (data.containsKey('weight_kg')) {
      context.handle(_weightKgMeta, weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta));
    } else if (isInserting) {
      context.missing(_weightKgMeta);
    }
    if (data.containsKey('target_weight_kg')) {
      context.handle(_targetWeightKgMeta, targetWeightKg.isAcceptableOrUnknown(data['target_weight_kg']!, _targetWeightKgMeta));
    }
    if (data.containsKey('body_fat_pct')) {
      context.handle(_bodyFatPctMeta, bodyFatPct.isAcceptableOrUnknown(data['body_fat_pct']!, _bodyFatPctMeta));
    }
    if (data.containsKey('skeletal_muscle_kg')) {
      context.handle(_skeletalMuscleKgMeta, skeletalMuscleKg.isAcceptableOrUnknown(data['skeletal_muscle_kg']!, _skeletalMuscleKgMeta));
    }
    if (data.containsKey('experience')) {
      context.handle(_experienceMeta, experience.isAcceptableOrUnknown(data['experience']!, _experienceMeta));
    } else if (isInserting) {
      context.missing(_experienceMeta);
    }
    if (data.containsKey('days_per_week')) {
      context.handle(_daysPerWeekMeta, daysPerWeek.isAcceptableOrUnknown(data['days_per_week']!, _daysPerWeekMeta));
    } else if (isInserting) {
      context.missing(_daysPerWeekMeta);
    }
    if (data.containsKey('session_minutes')) {
      context.handle(_sessionMinutesMeta, sessionMinutes.isAcceptableOrUnknown(data['session_minutes']!, _sessionMinutesMeta));
    } else if (isInserting) {
      context.missing(_sessionMinutesMeta);
    }
    if (data.containsKey('environment')) {
      context.handle(_environmentMeta, environment.isAcceptableOrUnknown(data['environment']!, _environmentMeta));
    } else if (isInserting) {
      context.missing(_environmentMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta, updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId};
  @override
  UserProfileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfileRow(
      userId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}user_id'])!,
      sex: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}sex'])!,
      age: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}age'])!,
      heightCm: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}height_cm'])!,
      weightKg: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}weight_kg'])!,
      targetWeightKg: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}target_weight_kg']),
      bodyFatPct: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}body_fat_pct']),
      skeletalMuscleKg: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}skeletal_muscle_kg']),
      experience: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}experience'])!,
      daysPerWeek: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}days_per_week'])!,
      sessionMinutes: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}session_minutes'])!,
      environment: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}environment'])!,
      updatedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $UserProfilesTable createAlias(String alias) {
    return $UserProfilesTable(attachedDatabase, alias);
  }
}

class UserProfileRow extends DataClass implements Insertable<UserProfileRow> {
  final int userId;
  final String sex;
  final int age;
  final double heightCm;
  final double weightKg;
  final double? targetWeightKg;
  final double? bodyFatPct;
  final double? skeletalMuscleKg;
  final String experience;
  final int daysPerWeek;
  final int sessionMinutes;
  final String environment;
  final DateTime updatedAt;
  const UserProfileRow({
    required this.userId,
    required this.sex,
    required this.age,
    required this.heightCm,
    required this.weightKg,
    this.targetWeightKg,
    this.bodyFatPct,
    this.skeletalMuscleKg,
    required this.experience,
    required this.daysPerWeek,
    required this.sessionMinutes,
    required this.environment,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<int>(userId);
    map['sex'] = Variable<String>(sex);
    map['age'] = Variable<int>(age);
    map['height_cm'] = Variable<double>(heightCm);
    map['weight_kg'] = Variable<double>(weightKg);
    if (!nullToAbsent || targetWeightKg != null) {
      map['target_weight_kg'] = Variable<double>(targetWeightKg);
    }
    if (!nullToAbsent || bodyFatPct != null) {
      map['body_fat_pct'] = Variable<double>(bodyFatPct);
    }
    if (!nullToAbsent || skeletalMuscleKg != null) {
      map['skeletal_muscle_kg'] = Variable<double>(skeletalMuscleKg);
    }
    map['experience'] = Variable<String>(experience);
    map['days_per_week'] = Variable<int>(daysPerWeek);
    map['session_minutes'] = Variable<int>(sessionMinutes);
    map['environment'] = Variable<String>(environment);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UserProfilesCompanion toCompanion(bool nullToAbsent) {
    return UserProfilesCompanion(
      userId: Value(userId),
      sex: Value(sex),
      age: Value(age),
      heightCm: Value(heightCm),
      weightKg: Value(weightKg),
      targetWeightKg: targetWeightKg == null && nullToAbsent ? const Value.absent() : Value(targetWeightKg),
      bodyFatPct: bodyFatPct == null && nullToAbsent ? const Value.absent() : Value(bodyFatPct),
      skeletalMuscleKg: skeletalMuscleKg == null && nullToAbsent ? const Value.absent() : Value(skeletalMuscleKg),
      experience: Value(experience),
      daysPerWeek: Value(daysPerWeek),
      sessionMinutes: Value(sessionMinutes),
      environment: Value(environment),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserProfileRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfileRow(
      userId: serializer.fromJson<int>(json['userId']),
      sex: serializer.fromJson<String>(json['sex']),
      age: serializer.fromJson<int>(json['age']),
      heightCm: serializer.fromJson<double>(json['heightCm']),
      weightKg: serializer.fromJson<double>(json['weightKg']),
      targetWeightKg: serializer.fromJson<double?>(json['targetWeightKg']),
      bodyFatPct: serializer.fromJson<double?>(json['bodyFatPct']),
      skeletalMuscleKg: serializer.fromJson<double?>(json['skeletalMuscleKg']),
      experience: serializer.fromJson<String>(json['experience']),
      daysPerWeek: serializer.fromJson<int>(json['daysPerWeek']),
      sessionMinutes: serializer.fromJson<int>(json['sessionMinutes']),
      environment: serializer.fromJson<String>(json['environment']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<int>(userId),
      'sex': serializer.toJson<String>(sex),
      'age': serializer.toJson<int>(age),
      'heightCm': serializer.toJson<double>(heightCm),
      'weightKg': serializer.toJson<double>(weightKg),
      'targetWeightKg': serializer.toJson<double?>(targetWeightKg),
      'bodyFatPct': serializer.toJson<double?>(bodyFatPct),
      'skeletalMuscleKg': serializer.toJson<double?>(skeletalMuscleKg),
      'experience': serializer.toJson<String>(experience),
      'daysPerWeek': serializer.toJson<int>(daysPerWeek),
      'sessionMinutes': serializer.toJson<int>(sessionMinutes),
      'environment': serializer.toJson<String>(environment),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UserProfileRow copyWith({
    int? userId,
    String? sex,
    int? age,
    double? heightCm,
    double? weightKg,
    Value<double?> targetWeightKg = const Value.absent(),
    Value<double?> bodyFatPct = const Value.absent(),
    Value<double?> skeletalMuscleKg = const Value.absent(),
    String? experience,
    int? daysPerWeek,
    int? sessionMinutes,
    String? environment,
    DateTime? updatedAt,
  }) => UserProfileRow(
    userId: userId ?? this.userId,
    sex: sex ?? this.sex,
    age: age ?? this.age,
    heightCm: heightCm ?? this.heightCm,
    weightKg: weightKg ?? this.weightKg,
    targetWeightKg: targetWeightKg.present ? targetWeightKg.value : this.targetWeightKg,
    bodyFatPct: bodyFatPct.present ? bodyFatPct.value : this.bodyFatPct,
    skeletalMuscleKg: skeletalMuscleKg.present ? skeletalMuscleKg.value : this.skeletalMuscleKg,
    experience: experience ?? this.experience,
    daysPerWeek: daysPerWeek ?? this.daysPerWeek,
    sessionMinutes: sessionMinutes ?? this.sessionMinutes,
    environment: environment ?? this.environment,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  UserProfileRow copyWithCompanion(UserProfilesCompanion data) {
    return UserProfileRow(
      userId: data.userId.present ? data.userId.value : this.userId,
      sex: data.sex.present ? data.sex.value : this.sex,
      age: data.age.present ? data.age.value : this.age,
      heightCm: data.heightCm.present ? data.heightCm.value : this.heightCm,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      targetWeightKg: data.targetWeightKg.present ? data.targetWeightKg.value : this.targetWeightKg,
      bodyFatPct: data.bodyFatPct.present ? data.bodyFatPct.value : this.bodyFatPct,
      skeletalMuscleKg: data.skeletalMuscleKg.present ? data.skeletalMuscleKg.value : this.skeletalMuscleKg,
      experience: data.experience.present ? data.experience.value : this.experience,
      daysPerWeek: data.daysPerWeek.present ? data.daysPerWeek.value : this.daysPerWeek,
      sessionMinutes: data.sessionMinutes.present ? data.sessionMinutes.value : this.sessionMinutes,
      environment: data.environment.present ? data.environment.value : this.environment,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProfileRow(')
          ..write('userId: $userId, ')
          ..write('sex: $sex, ')
          ..write('age: $age, ')
          ..write('heightCm: $heightCm, ')
          ..write('weightKg: $weightKg, ')
          ..write('targetWeightKg: $targetWeightKg, ')
          ..write('bodyFatPct: $bodyFatPct, ')
          ..write('skeletalMuscleKg: $skeletalMuscleKg, ')
          ..write('experience: $experience, ')
          ..write('daysPerWeek: $daysPerWeek, ')
          ..write('sessionMinutes: $sessionMinutes, ')
          ..write('environment: $environment, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    userId,
    sex,
    age,
    heightCm,
    weightKg,
    targetWeightKg,
    bodyFatPct,
    skeletalMuscleKg,
    experience,
    daysPerWeek,
    sessionMinutes,
    environment,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfileRow &&
          other.userId == this.userId &&
          other.sex == this.sex &&
          other.age == this.age &&
          other.heightCm == this.heightCm &&
          other.weightKg == this.weightKg &&
          other.targetWeightKg == this.targetWeightKg &&
          other.bodyFatPct == this.bodyFatPct &&
          other.skeletalMuscleKg == this.skeletalMuscleKg &&
          other.experience == this.experience &&
          other.daysPerWeek == this.daysPerWeek &&
          other.sessionMinutes == this.sessionMinutes &&
          other.environment == this.environment &&
          other.updatedAt == this.updatedAt);
}

class UserProfilesCompanion extends UpdateCompanion<UserProfileRow> {
  final Value<int> userId;
  final Value<String> sex;
  final Value<int> age;
  final Value<double> heightCm;
  final Value<double> weightKg;
  final Value<double?> targetWeightKg;
  final Value<double?> bodyFatPct;
  final Value<double?> skeletalMuscleKg;
  final Value<String> experience;
  final Value<int> daysPerWeek;
  final Value<int> sessionMinutes;
  final Value<String> environment;
  final Value<DateTime> updatedAt;
  const UserProfilesCompanion({
    this.userId = const Value.absent(),
    this.sex = const Value.absent(),
    this.age = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.targetWeightKg = const Value.absent(),
    this.bodyFatPct = const Value.absent(),
    this.skeletalMuscleKg = const Value.absent(),
    this.experience = const Value.absent(),
    this.daysPerWeek = const Value.absent(),
    this.sessionMinutes = const Value.absent(),
    this.environment = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  UserProfilesCompanion.insert({
    this.userId = const Value.absent(),
    required String sex,
    required int age,
    required double heightCm,
    required double weightKg,
    this.targetWeightKg = const Value.absent(),
    this.bodyFatPct = const Value.absent(),
    this.skeletalMuscleKg = const Value.absent(),
    required String experience,
    required int daysPerWeek,
    required int sessionMinutes,
    required String environment,
    this.updatedAt = const Value.absent(),
  }) : sex = Value(sex),
       age = Value(age),
       heightCm = Value(heightCm),
       weightKg = Value(weightKg),
       experience = Value(experience),
       daysPerWeek = Value(daysPerWeek),
       sessionMinutes = Value(sessionMinutes),
       environment = Value(environment);
  static Insertable<UserProfileRow> custom({
    Expression<int>? userId,
    Expression<String>? sex,
    Expression<int>? age,
    Expression<double>? heightCm,
    Expression<double>? weightKg,
    Expression<double>? targetWeightKg,
    Expression<double>? bodyFatPct,
    Expression<double>? skeletalMuscleKg,
    Expression<String>? experience,
    Expression<int>? daysPerWeek,
    Expression<int>? sessionMinutes,
    Expression<String>? environment,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (sex != null) 'sex': sex,
      if (age != null) 'age': age,
      if (heightCm != null) 'height_cm': heightCm,
      if (weightKg != null) 'weight_kg': weightKg,
      if (targetWeightKg != null) 'target_weight_kg': targetWeightKg,
      if (bodyFatPct != null) 'body_fat_pct': bodyFatPct,
      if (skeletalMuscleKg != null) 'skeletal_muscle_kg': skeletalMuscleKg,
      if (experience != null) 'experience': experience,
      if (daysPerWeek != null) 'days_per_week': daysPerWeek,
      if (sessionMinutes != null) 'session_minutes': sessionMinutes,
      if (environment != null) 'environment': environment,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  UserProfilesCompanion copyWith({
    Value<int>? userId,
    Value<String>? sex,
    Value<int>? age,
    Value<double>? heightCm,
    Value<double>? weightKg,
    Value<double?>? targetWeightKg,
    Value<double?>? bodyFatPct,
    Value<double?>? skeletalMuscleKg,
    Value<String>? experience,
    Value<int>? daysPerWeek,
    Value<int>? sessionMinutes,
    Value<String>? environment,
    Value<DateTime>? updatedAt,
  }) {
    return UserProfilesCompanion(
      userId: userId ?? this.userId,
      sex: sex ?? this.sex,
      age: age ?? this.age,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      bodyFatPct: bodyFatPct ?? this.bodyFatPct,
      skeletalMuscleKg: skeletalMuscleKg ?? this.skeletalMuscleKg,
      experience: experience ?? this.experience,
      daysPerWeek: daysPerWeek ?? this.daysPerWeek,
      sessionMinutes: sessionMinutes ?? this.sessionMinutes,
      environment: environment ?? this.environment,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (sex.present) {
      map['sex'] = Variable<String>(sex.value);
    }
    if (age.present) {
      map['age'] = Variable<int>(age.value);
    }
    if (heightCm.present) {
      map['height_cm'] = Variable<double>(heightCm.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (targetWeightKg.present) {
      map['target_weight_kg'] = Variable<double>(targetWeightKg.value);
    }
    if (bodyFatPct.present) {
      map['body_fat_pct'] = Variable<double>(bodyFatPct.value);
    }
    if (skeletalMuscleKg.present) {
      map['skeletal_muscle_kg'] = Variable<double>(skeletalMuscleKg.value);
    }
    if (experience.present) {
      map['experience'] = Variable<String>(experience.value);
    }
    if (daysPerWeek.present) {
      map['days_per_week'] = Variable<int>(daysPerWeek.value);
    }
    if (sessionMinutes.present) {
      map['session_minutes'] = Variable<int>(sessionMinutes.value);
    }
    if (environment.present) {
      map['environment'] = Variable<String>(environment.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProfilesCompanion(')
          ..write('userId: $userId, ')
          ..write('sex: $sex, ')
          ..write('age: $age, ')
          ..write('heightCm: $heightCm, ')
          ..write('weightKg: $weightKg, ')
          ..write('targetWeightKg: $targetWeightKg, ')
          ..write('bodyFatPct: $bodyFatPct, ')
          ..write('skeletalMuscleKg: $skeletalMuscleKg, ')
          ..write('experience: $experience, ')
          ..write('daysPerWeek: $daysPerWeek, ')
          ..write('sessionMinutes: $sessionMinutes, ')
          ..write('environment: $environment, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $UserGoalsTable extends UserGoals with TableInfo<$UserGoalsTable, UserGoal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserGoalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES users (id)'),
  );
  static const VerificationMeta _goalMeta = const VerificationMeta('goal');
  @override
  late final GeneratedColumn<String> goal = GeneratedColumn<String>('goal', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _priorityMeta = const VerificationMeta('priority');
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>('priority', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, userId, goal, priority];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_goals';
  @override
  VerificationContext validateIntegrity(Insertable<UserGoal> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta, userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('goal')) {
      context.handle(_goalMeta, goal.isAcceptableOrUnknown(data['goal']!, _goalMeta));
    } else if (isInserting) {
      context.missing(_goalMeta);
    }
    if (data.containsKey('priority')) {
      context.handle(_priorityMeta, priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta));
    } else if (isInserting) {
      context.missing(_priorityMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserGoal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserGoal(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}user_id'])!,
      goal: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}goal'])!,
      priority: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}priority'])!,
    );
  }

  @override
  $UserGoalsTable createAlias(String alias) {
    return $UserGoalsTable(attachedDatabase, alias);
  }
}

class UserGoal extends DataClass implements Insertable<UserGoal> {
  final int id;
  final int userId;
  final String goal;
  final int priority;
  const UserGoal({required this.id, required this.userId, required this.goal, required this.priority});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<int>(userId);
    map['goal'] = Variable<String>(goal);
    map['priority'] = Variable<int>(priority);
    return map;
  }

  UserGoalsCompanion toCompanion(bool nullToAbsent) {
    return UserGoalsCompanion(id: Value(id), userId: Value(userId), goal: Value(goal), priority: Value(priority));
  }

  factory UserGoal.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserGoal(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<int>(json['userId']),
      goal: serializer.fromJson<String>(json['goal']),
      priority: serializer.fromJson<int>(json['priority']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<int>(userId),
      'goal': serializer.toJson<String>(goal),
      'priority': serializer.toJson<int>(priority),
    };
  }

  UserGoal copyWith({int? id, int? userId, String? goal, int? priority}) =>
      UserGoal(id: id ?? this.id, userId: userId ?? this.userId, goal: goal ?? this.goal, priority: priority ?? this.priority);
  UserGoal copyWithCompanion(UserGoalsCompanion data) {
    return UserGoal(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      goal: data.goal.present ? data.goal.value : this.goal,
      priority: data.priority.present ? data.priority.value : this.priority,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserGoal(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('goal: $goal, ')
          ..write('priority: $priority')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, goal, priority);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserGoal && other.id == this.id && other.userId == this.userId && other.goal == this.goal && other.priority == this.priority);
}

class UserGoalsCompanion extends UpdateCompanion<UserGoal> {
  final Value<int> id;
  final Value<int> userId;
  final Value<String> goal;
  final Value<int> priority;
  const UserGoalsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.goal = const Value.absent(),
    this.priority = const Value.absent(),
  });
  UserGoalsCompanion.insert({this.id = const Value.absent(), required int userId, required String goal, required int priority})
    : userId = Value(userId),
      goal = Value(goal),
      priority = Value(priority);
  static Insertable<UserGoal> custom({Expression<int>? id, Expression<int>? userId, Expression<String>? goal, Expression<int>? priority}) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (goal != null) 'goal': goal,
      if (priority != null) 'priority': priority,
    });
  }

  UserGoalsCompanion copyWith({Value<int>? id, Value<int>? userId, Value<String>? goal, Value<int>? priority}) {
    return UserGoalsCompanion(id: id ?? this.id, userId: userId ?? this.userId, goal: goal ?? this.goal, priority: priority ?? this.priority);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (goal.present) {
      map['goal'] = Variable<String>(goal.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserGoalsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('goal: $goal, ')
          ..write('priority: $priority')
          ..write(')'))
        .toString();
  }
}

class $UserEquipmentTable extends UserEquipment with TableInfo<$UserEquipmentTable, UserEquipmentData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserEquipmentTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES users (id)'),
  );
  static const VerificationMeta _equipmentMeta = const VerificationMeta('equipment');
  @override
  late final GeneratedColumn<String> equipment = GeneratedColumn<String>(
    'equipment',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [userId, equipment];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_equipment';
  @override
  VerificationContext validateIntegrity(Insertable<UserEquipmentData> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta, userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('equipment')) {
      context.handle(_equipmentMeta, equipment.isAcceptableOrUnknown(data['equipment']!, _equipmentMeta));
    } else if (isInserting) {
      context.missing(_equipmentMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, equipment};
  @override
  UserEquipmentData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserEquipmentData(
      userId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}user_id'])!,
      equipment: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}equipment'])!,
    );
  }

  @override
  $UserEquipmentTable createAlias(String alias) {
    return $UserEquipmentTable(attachedDatabase, alias);
  }
}

class UserEquipmentData extends DataClass implements Insertable<UserEquipmentData> {
  final int userId;
  final String equipment;
  const UserEquipmentData({required this.userId, required this.equipment});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<int>(userId);
    map['equipment'] = Variable<String>(equipment);
    return map;
  }

  UserEquipmentCompanion toCompanion(bool nullToAbsent) {
    return UserEquipmentCompanion(userId: Value(userId), equipment: Value(equipment));
  }

  factory UserEquipmentData.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserEquipmentData(userId: serializer.fromJson<int>(json['userId']), equipment: serializer.fromJson<String>(json['equipment']));
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'userId': serializer.toJson<int>(userId), 'equipment': serializer.toJson<String>(equipment)};
  }

  UserEquipmentData copyWith({int? userId, String? equipment}) => UserEquipmentData(userId: userId ?? this.userId, equipment: equipment ?? this.equipment);
  UserEquipmentData copyWithCompanion(UserEquipmentCompanion data) {
    return UserEquipmentData(
      userId: data.userId.present ? data.userId.value : this.userId,
      equipment: data.equipment.present ? data.equipment.value : this.equipment,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserEquipmentData(')
          ..write('userId: $userId, ')
          ..write('equipment: $equipment')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(userId, equipment);
  @override
  bool operator ==(Object other) => identical(this, other) || (other is UserEquipmentData && other.userId == this.userId && other.equipment == this.equipment);
}

class UserEquipmentCompanion extends UpdateCompanion<UserEquipmentData> {
  final Value<int> userId;
  final Value<String> equipment;
  final Value<int> rowid;
  const UserEquipmentCompanion({this.userId = const Value.absent(), this.equipment = const Value.absent(), this.rowid = const Value.absent()});
  UserEquipmentCompanion.insert({required int userId, required String equipment, this.rowid = const Value.absent()})
    : userId = Value(userId),
      equipment = Value(equipment);
  static Insertable<UserEquipmentData> custom({Expression<int>? userId, Expression<String>? equipment, Expression<int>? rowid}) {
    return RawValuesInsertable({if (userId != null) 'user_id': userId, if (equipment != null) 'equipment': equipment, if (rowid != null) 'rowid': rowid});
  }

  UserEquipmentCompanion copyWith({Value<int>? userId, Value<String>? equipment, Value<int>? rowid}) {
    return UserEquipmentCompanion(userId: userId ?? this.userId, equipment: equipment ?? this.equipment, rowid: rowid ?? this.rowid);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (equipment.present) {
      map['equipment'] = Variable<String>(equipment.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserEquipmentCompanion(')
          ..write('userId: $userId, ')
          ..write('equipment: $equipment, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserLimitationsTable extends UserLimitations with TableInfo<$UserLimitationsTable, UserLimitation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserLimitationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES users (id)'),
  );
  static const VerificationMeta _areaMeta = const VerificationMeta('area');
  @override
  late final GeneratedColumn<String> area = GeneratedColumn<String>('area', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _severityMeta = const VerificationMeta('severity');
  @override
  late final GeneratedColumn<int> severity = GeneratedColumn<int>('severity', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _timingMeta = const VerificationMeta('timing');
  @override
  late final GeneratedColumn<String> timing = GeneratedColumn<String>(
    'timing',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("active" IN (0, 1))'),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [id, userId, area, severity, timing, notes, active];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_limitations';
  @override
  VerificationContext validateIntegrity(Insertable<UserLimitation> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta, userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('area')) {
      context.handle(_areaMeta, area.isAcceptableOrUnknown(data['area']!, _areaMeta));
    } else if (isInserting) {
      context.missing(_areaMeta);
    }
    if (data.containsKey('severity')) {
      context.handle(_severityMeta, severity.isAcceptableOrUnknown(data['severity']!, _severityMeta));
    } else if (isInserting) {
      context.missing(_severityMeta);
    }
    if (data.containsKey('timing')) {
      context.handle(_timingMeta, timing.isAcceptableOrUnknown(data['timing']!, _timingMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(_notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('active')) {
      context.handle(_activeMeta, active.isAcceptableOrUnknown(data['active']!, _activeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserLimitation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserLimitation(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}user_id'])!,
      area: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}area'])!,
      severity: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}severity'])!,
      timing: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}timing'])!,
      notes: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}notes'])!,
      active: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}active'])!,
    );
  }

  @override
  $UserLimitationsTable createAlias(String alias) {
    return $UserLimitationsTable(attachedDatabase, alias);
  }
}

class UserLimitation extends DataClass implements Insertable<UserLimitation> {
  final int id;
  final int userId;
  final String area;
  final int severity;
  final String timing;
  final String notes;
  final bool active;
  const UserLimitation({
    required this.id,
    required this.userId,
    required this.area,
    required this.severity,
    required this.timing,
    required this.notes,
    required this.active,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<int>(userId);
    map['area'] = Variable<String>(area);
    map['severity'] = Variable<int>(severity);
    map['timing'] = Variable<String>(timing);
    map['notes'] = Variable<String>(notes);
    map['active'] = Variable<bool>(active);
    return map;
  }

  UserLimitationsCompanion toCompanion(bool nullToAbsent) {
    return UserLimitationsCompanion(
      id: Value(id),
      userId: Value(userId),
      area: Value(area),
      severity: Value(severity),
      timing: Value(timing),
      notes: Value(notes),
      active: Value(active),
    );
  }

  factory UserLimitation.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserLimitation(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<int>(json['userId']),
      area: serializer.fromJson<String>(json['area']),
      severity: serializer.fromJson<int>(json['severity']),
      timing: serializer.fromJson<String>(json['timing']),
      notes: serializer.fromJson<String>(json['notes']),
      active: serializer.fromJson<bool>(json['active']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<int>(userId),
      'area': serializer.toJson<String>(area),
      'severity': serializer.toJson<int>(severity),
      'timing': serializer.toJson<String>(timing),
      'notes': serializer.toJson<String>(notes),
      'active': serializer.toJson<bool>(active),
    };
  }

  UserLimitation copyWith({int? id, int? userId, String? area, int? severity, String? timing, String? notes, bool? active}) => UserLimitation(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    area: area ?? this.area,
    severity: severity ?? this.severity,
    timing: timing ?? this.timing,
    notes: notes ?? this.notes,
    active: active ?? this.active,
  );
  UserLimitation copyWithCompanion(UserLimitationsCompanion data) {
    return UserLimitation(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      area: data.area.present ? data.area.value : this.area,
      severity: data.severity.present ? data.severity.value : this.severity,
      timing: data.timing.present ? data.timing.value : this.timing,
      notes: data.notes.present ? data.notes.value : this.notes,
      active: data.active.present ? data.active.value : this.active,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserLimitation(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('area: $area, ')
          ..write('severity: $severity, ')
          ..write('timing: $timing, ')
          ..write('notes: $notes, ')
          ..write('active: $active')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, area, severity, timing, notes, active);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserLimitation &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.area == this.area &&
          other.severity == this.severity &&
          other.timing == this.timing &&
          other.notes == this.notes &&
          other.active == this.active);
}

class UserLimitationsCompanion extends UpdateCompanion<UserLimitation> {
  final Value<int> id;
  final Value<int> userId;
  final Value<String> area;
  final Value<int> severity;
  final Value<String> timing;
  final Value<String> notes;
  final Value<bool> active;
  const UserLimitationsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.area = const Value.absent(),
    this.severity = const Value.absent(),
    this.timing = const Value.absent(),
    this.notes = const Value.absent(),
    this.active = const Value.absent(),
  });
  UserLimitationsCompanion.insert({
    this.id = const Value.absent(),
    required int userId,
    required String area,
    required int severity,
    this.timing = const Value.absent(),
    this.notes = const Value.absent(),
    this.active = const Value.absent(),
  }) : userId = Value(userId),
       area = Value(area),
       severity = Value(severity);
  static Insertable<UserLimitation> custom({
    Expression<int>? id,
    Expression<int>? userId,
    Expression<String>? area,
    Expression<int>? severity,
    Expression<String>? timing,
    Expression<String>? notes,
    Expression<bool>? active,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (area != null) 'area': area,
      if (severity != null) 'severity': severity,
      if (timing != null) 'timing': timing,
      if (notes != null) 'notes': notes,
      if (active != null) 'active': active,
    });
  }

  UserLimitationsCompanion copyWith({
    Value<int>? id,
    Value<int>? userId,
    Value<String>? area,
    Value<int>? severity,
    Value<String>? timing,
    Value<String>? notes,
    Value<bool>? active,
  }) {
    return UserLimitationsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      area: area ?? this.area,
      severity: severity ?? this.severity,
      timing: timing ?? this.timing,
      notes: notes ?? this.notes,
      active: active ?? this.active,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (area.present) {
      map['area'] = Variable<String>(area.value);
    }
    if (severity.present) {
      map['severity'] = Variable<int>(severity.value);
    }
    if (timing.present) {
      map['timing'] = Variable<String>(timing.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserLimitationsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('area: $area, ')
          ..write('severity: $severity, ')
          ..write('timing: $timing, ')
          ..write('notes: $notes, ')
          ..write('active: $active')
          ..write(')'))
        .toString();
  }
}

class $ExercisesTable extends Exercises with TableInfo<$ExercisesTable, ExerciseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>('id', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameKoMeta = const VerificationMeta('nameKo');
  @override
  late final GeneratedColumn<String> nameKo = GeneratedColumn<String>('name_ko', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameEnMeta = const VerificationMeta('nameEn');
  @override
  late final GeneratedColumn<String> nameEn = GeneratedColumn<String>('name_en', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _equipmentMeta = const VerificationMeta('equipment');
  @override
  late final GeneratedColumn<String> equipment = GeneratedColumn<String>(
    'equipment',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>('type', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _patternMeta = const VerificationMeta('pattern');
  @override
  late final GeneratedColumn<String> pattern = GeneratedColumn<String>('pattern', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _difficultyMeta = const VerificationMeta('difficulty');
  @override
  late final GeneratedColumn<int> difficulty = GeneratedColumn<int>('difficulty', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _repMinMeta = const VerificationMeta('repMin');
  @override
  late final GeneratedColumn<int> repMin = GeneratedColumn<int>('rep_min', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _repMaxMeta = const VerificationMeta('repMax');
  @override
  late final GeneratedColumn<int> repMax = GeneratedColumn<int>('rep_max', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _restSecMeta = const VerificationMeta('restSec');
  @override
  late final GeneratedColumn<int> restSec = GeneratedColumn<int>('rest_sec', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta = const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cuesMeta = const VerificationMeta('cues');
  @override
  late final GeneratedColumn<String> cues = GeneratedColumn<String>('cues', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _mistakesMeta = const VerificationMeta('mistakes');
  @override
  late final GeneratedColumn<String> mistakes = GeneratedColumn<String>('mistakes', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cautionsMeta = const VerificationMeta('cautions');
  @override
  late final GeneratedColumn<String> cautions = GeneratedColumn<String>('cautions', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _jointStressMeta = const VerificationMeta('jointStress');
  @override
  late final GeneratedColumn<String> jointStress = GeneratedColumn<String>(
    'joint_stress',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _referenceIdsMeta = const VerificationMeta('referenceIds');
  @override
  late final GeneratedColumn<String> referenceIds = GeneratedColumn<String>(
    'reference_ids',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _videoUrlMeta = const VerificationMeta('videoUrl');
  @override
  late final GeneratedColumn<String> videoUrl = GeneratedColumn<String>('video_url', aliasedName, true, type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _assistedMeta = const VerificationMeta('assisted');
  @override
  late final GeneratedColumn<bool> assisted = GeneratedColumn<bool>(
    'assisted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("assisted" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _bodyweightMeta = const VerificationMeta('bodyweight');
  @override
  late final GeneratedColumn<bool> bodyweight = GeneratedColumn<bool>(
    'bodyweight',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("bodyweight" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _timedMeta = const VerificationMeta('timed');
  @override
  late final GeneratedColumn<bool> timed = GeneratedColumn<bool>(
    'timed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("timed" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isCustomMeta = const VerificationMeta('isCustom');
  @override
  late final GeneratedColumn<bool> isCustom = GeneratedColumn<bool>(
    'is_custom',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("is_custom" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nameKo,
    nameEn,
    equipment,
    type,
    pattern,
    difficulty,
    repMin,
    repMax,
    restSec,
    description,
    cues,
    mistakes,
    cautions,
    jointStress,
    referenceIds,
    videoUrl,
    assisted,
    bodyweight,
    timed,
    isCustom,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercises';
  @override
  VerificationContext validateIntegrity(Insertable<ExerciseRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name_ko')) {
      context.handle(_nameKoMeta, nameKo.isAcceptableOrUnknown(data['name_ko']!, _nameKoMeta));
    } else if (isInserting) {
      context.missing(_nameKoMeta);
    }
    if (data.containsKey('name_en')) {
      context.handle(_nameEnMeta, nameEn.isAcceptableOrUnknown(data['name_en']!, _nameEnMeta));
    } else if (isInserting) {
      context.missing(_nameEnMeta);
    }
    if (data.containsKey('equipment')) {
      context.handle(_equipmentMeta, equipment.isAcceptableOrUnknown(data['equipment']!, _equipmentMeta));
    } else if (isInserting) {
      context.missing(_equipmentMeta);
    }
    if (data.containsKey('type')) {
      context.handle(_typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('pattern')) {
      context.handle(_patternMeta, pattern.isAcceptableOrUnknown(data['pattern']!, _patternMeta));
    } else if (isInserting) {
      context.missing(_patternMeta);
    }
    if (data.containsKey('difficulty')) {
      context.handle(_difficultyMeta, difficulty.isAcceptableOrUnknown(data['difficulty']!, _difficultyMeta));
    } else if (isInserting) {
      context.missing(_difficultyMeta);
    }
    if (data.containsKey('rep_min')) {
      context.handle(_repMinMeta, repMin.isAcceptableOrUnknown(data['rep_min']!, _repMinMeta));
    } else if (isInserting) {
      context.missing(_repMinMeta);
    }
    if (data.containsKey('rep_max')) {
      context.handle(_repMaxMeta, repMax.isAcceptableOrUnknown(data['rep_max']!, _repMaxMeta));
    } else if (isInserting) {
      context.missing(_repMaxMeta);
    }
    if (data.containsKey('rest_sec')) {
      context.handle(_restSecMeta, restSec.isAcceptableOrUnknown(data['rest_sec']!, _restSecMeta));
    } else if (isInserting) {
      context.missing(_restSecMeta);
    }
    if (data.containsKey('description')) {
      context.handle(_descriptionMeta, description.isAcceptableOrUnknown(data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('cues')) {
      context.handle(_cuesMeta, cues.isAcceptableOrUnknown(data['cues']!, _cuesMeta));
    } else if (isInserting) {
      context.missing(_cuesMeta);
    }
    if (data.containsKey('mistakes')) {
      context.handle(_mistakesMeta, mistakes.isAcceptableOrUnknown(data['mistakes']!, _mistakesMeta));
    } else if (isInserting) {
      context.missing(_mistakesMeta);
    }
    if (data.containsKey('cautions')) {
      context.handle(_cautionsMeta, cautions.isAcceptableOrUnknown(data['cautions']!, _cautionsMeta));
    } else if (isInserting) {
      context.missing(_cautionsMeta);
    }
    if (data.containsKey('joint_stress')) {
      context.handle(_jointStressMeta, jointStress.isAcceptableOrUnknown(data['joint_stress']!, _jointStressMeta));
    } else if (isInserting) {
      context.missing(_jointStressMeta);
    }
    if (data.containsKey('reference_ids')) {
      context.handle(_referenceIdsMeta, referenceIds.isAcceptableOrUnknown(data['reference_ids']!, _referenceIdsMeta));
    } else if (isInserting) {
      context.missing(_referenceIdsMeta);
    }
    if (data.containsKey('video_url')) {
      context.handle(_videoUrlMeta, videoUrl.isAcceptableOrUnknown(data['video_url']!, _videoUrlMeta));
    }
    if (data.containsKey('assisted')) {
      context.handle(_assistedMeta, assisted.isAcceptableOrUnknown(data['assisted']!, _assistedMeta));
    }
    if (data.containsKey('bodyweight')) {
      context.handle(_bodyweightMeta, bodyweight.isAcceptableOrUnknown(data['bodyweight']!, _bodyweightMeta));
    }
    if (data.containsKey('timed')) {
      context.handle(_timedMeta, timed.isAcceptableOrUnknown(data['timed']!, _timedMeta));
    }
    if (data.containsKey('is_custom')) {
      context.handle(_isCustomMeta, isCustom.isAcceptableOrUnknown(data['is_custom']!, _isCustomMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExerciseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExerciseRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      nameKo: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name_ko'])!,
      nameEn: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name_en'])!,
      equipment: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}equipment'])!,
      type: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      pattern: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}pattern'])!,
      difficulty: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}difficulty'])!,
      repMin: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}rep_min'])!,
      repMax: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}rep_max'])!,
      restSec: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}rest_sec'])!,
      description: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      cues: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}cues'])!,
      mistakes: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}mistakes'])!,
      cautions: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}cautions'])!,
      jointStress: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}joint_stress'])!,
      referenceIds: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}reference_ids'])!,
      videoUrl: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}video_url']),
      assisted: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}assisted'])!,
      bodyweight: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}bodyweight'])!,
      timed: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}timed'])!,
      isCustom: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}is_custom'])!,
    );
  }

  @override
  $ExercisesTable createAlias(String alias) {
    return $ExercisesTable(attachedDatabase, alias);
  }
}

class ExerciseRow extends DataClass implements Insertable<ExerciseRow> {
  final String id;
  final String nameKo;
  final String nameEn;
  final String equipment;
  final String type;
  final String pattern;
  final int difficulty;
  final int repMin;
  final int repMax;
  final int restSec;
  final String description;
  final String cues;
  final String mistakes;
  final String cautions;
  final String jointStress;
  final String referenceIds;
  final String? videoUrl;
  final bool assisted;
  final bool bodyweight;
  final bool timed;
  final bool isCustom;
  const ExerciseRow({
    required this.id,
    required this.nameKo,
    required this.nameEn,
    required this.equipment,
    required this.type,
    required this.pattern,
    required this.difficulty,
    required this.repMin,
    required this.repMax,
    required this.restSec,
    required this.description,
    required this.cues,
    required this.mistakes,
    required this.cautions,
    required this.jointStress,
    required this.referenceIds,
    this.videoUrl,
    required this.assisted,
    required this.bodyweight,
    required this.timed,
    required this.isCustom,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name_ko'] = Variable<String>(nameKo);
    map['name_en'] = Variable<String>(nameEn);
    map['equipment'] = Variable<String>(equipment);
    map['type'] = Variable<String>(type);
    map['pattern'] = Variable<String>(pattern);
    map['difficulty'] = Variable<int>(difficulty);
    map['rep_min'] = Variable<int>(repMin);
    map['rep_max'] = Variable<int>(repMax);
    map['rest_sec'] = Variable<int>(restSec);
    map['description'] = Variable<String>(description);
    map['cues'] = Variable<String>(cues);
    map['mistakes'] = Variable<String>(mistakes);
    map['cautions'] = Variable<String>(cautions);
    map['joint_stress'] = Variable<String>(jointStress);
    map['reference_ids'] = Variable<String>(referenceIds);
    if (!nullToAbsent || videoUrl != null) {
      map['video_url'] = Variable<String>(videoUrl);
    }
    map['assisted'] = Variable<bool>(assisted);
    map['bodyweight'] = Variable<bool>(bodyweight);
    map['timed'] = Variable<bool>(timed);
    map['is_custom'] = Variable<bool>(isCustom);
    return map;
  }

  ExercisesCompanion toCompanion(bool nullToAbsent) {
    return ExercisesCompanion(
      id: Value(id),
      nameKo: Value(nameKo),
      nameEn: Value(nameEn),
      equipment: Value(equipment),
      type: Value(type),
      pattern: Value(pattern),
      difficulty: Value(difficulty),
      repMin: Value(repMin),
      repMax: Value(repMax),
      restSec: Value(restSec),
      description: Value(description),
      cues: Value(cues),
      mistakes: Value(mistakes),
      cautions: Value(cautions),
      jointStress: Value(jointStress),
      referenceIds: Value(referenceIds),
      videoUrl: videoUrl == null && nullToAbsent ? const Value.absent() : Value(videoUrl),
      assisted: Value(assisted),
      bodyweight: Value(bodyweight),
      timed: Value(timed),
      isCustom: Value(isCustom),
    );
  }

  factory ExerciseRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExerciseRow(
      id: serializer.fromJson<String>(json['id']),
      nameKo: serializer.fromJson<String>(json['nameKo']),
      nameEn: serializer.fromJson<String>(json['nameEn']),
      equipment: serializer.fromJson<String>(json['equipment']),
      type: serializer.fromJson<String>(json['type']),
      pattern: serializer.fromJson<String>(json['pattern']),
      difficulty: serializer.fromJson<int>(json['difficulty']),
      repMin: serializer.fromJson<int>(json['repMin']),
      repMax: serializer.fromJson<int>(json['repMax']),
      restSec: serializer.fromJson<int>(json['restSec']),
      description: serializer.fromJson<String>(json['description']),
      cues: serializer.fromJson<String>(json['cues']),
      mistakes: serializer.fromJson<String>(json['mistakes']),
      cautions: serializer.fromJson<String>(json['cautions']),
      jointStress: serializer.fromJson<String>(json['jointStress']),
      referenceIds: serializer.fromJson<String>(json['referenceIds']),
      videoUrl: serializer.fromJson<String?>(json['videoUrl']),
      assisted: serializer.fromJson<bool>(json['assisted']),
      bodyweight: serializer.fromJson<bool>(json['bodyweight']),
      timed: serializer.fromJson<bool>(json['timed']),
      isCustom: serializer.fromJson<bool>(json['isCustom']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'nameKo': serializer.toJson<String>(nameKo),
      'nameEn': serializer.toJson<String>(nameEn),
      'equipment': serializer.toJson<String>(equipment),
      'type': serializer.toJson<String>(type),
      'pattern': serializer.toJson<String>(pattern),
      'difficulty': serializer.toJson<int>(difficulty),
      'repMin': serializer.toJson<int>(repMin),
      'repMax': serializer.toJson<int>(repMax),
      'restSec': serializer.toJson<int>(restSec),
      'description': serializer.toJson<String>(description),
      'cues': serializer.toJson<String>(cues),
      'mistakes': serializer.toJson<String>(mistakes),
      'cautions': serializer.toJson<String>(cautions),
      'jointStress': serializer.toJson<String>(jointStress),
      'referenceIds': serializer.toJson<String>(referenceIds),
      'videoUrl': serializer.toJson<String?>(videoUrl),
      'assisted': serializer.toJson<bool>(assisted),
      'bodyweight': serializer.toJson<bool>(bodyweight),
      'timed': serializer.toJson<bool>(timed),
      'isCustom': serializer.toJson<bool>(isCustom),
    };
  }

  ExerciseRow copyWith({
    String? id,
    String? nameKo,
    String? nameEn,
    String? equipment,
    String? type,
    String? pattern,
    int? difficulty,
    int? repMin,
    int? repMax,
    int? restSec,
    String? description,
    String? cues,
    String? mistakes,
    String? cautions,
    String? jointStress,
    String? referenceIds,
    Value<String?> videoUrl = const Value.absent(),
    bool? assisted,
    bool? bodyweight,
    bool? timed,
    bool? isCustom,
  }) => ExerciseRow(
    id: id ?? this.id,
    nameKo: nameKo ?? this.nameKo,
    nameEn: nameEn ?? this.nameEn,
    equipment: equipment ?? this.equipment,
    type: type ?? this.type,
    pattern: pattern ?? this.pattern,
    difficulty: difficulty ?? this.difficulty,
    repMin: repMin ?? this.repMin,
    repMax: repMax ?? this.repMax,
    restSec: restSec ?? this.restSec,
    description: description ?? this.description,
    cues: cues ?? this.cues,
    mistakes: mistakes ?? this.mistakes,
    cautions: cautions ?? this.cautions,
    jointStress: jointStress ?? this.jointStress,
    referenceIds: referenceIds ?? this.referenceIds,
    videoUrl: videoUrl.present ? videoUrl.value : this.videoUrl,
    assisted: assisted ?? this.assisted,
    bodyweight: bodyweight ?? this.bodyweight,
    timed: timed ?? this.timed,
    isCustom: isCustom ?? this.isCustom,
  );
  ExerciseRow copyWithCompanion(ExercisesCompanion data) {
    return ExerciseRow(
      id: data.id.present ? data.id.value : this.id,
      nameKo: data.nameKo.present ? data.nameKo.value : this.nameKo,
      nameEn: data.nameEn.present ? data.nameEn.value : this.nameEn,
      equipment: data.equipment.present ? data.equipment.value : this.equipment,
      type: data.type.present ? data.type.value : this.type,
      pattern: data.pattern.present ? data.pattern.value : this.pattern,
      difficulty: data.difficulty.present ? data.difficulty.value : this.difficulty,
      repMin: data.repMin.present ? data.repMin.value : this.repMin,
      repMax: data.repMax.present ? data.repMax.value : this.repMax,
      restSec: data.restSec.present ? data.restSec.value : this.restSec,
      description: data.description.present ? data.description.value : this.description,
      cues: data.cues.present ? data.cues.value : this.cues,
      mistakes: data.mistakes.present ? data.mistakes.value : this.mistakes,
      cautions: data.cautions.present ? data.cautions.value : this.cautions,
      jointStress: data.jointStress.present ? data.jointStress.value : this.jointStress,
      referenceIds: data.referenceIds.present ? data.referenceIds.value : this.referenceIds,
      videoUrl: data.videoUrl.present ? data.videoUrl.value : this.videoUrl,
      assisted: data.assisted.present ? data.assisted.value : this.assisted,
      bodyweight: data.bodyweight.present ? data.bodyweight.value : this.bodyweight,
      timed: data.timed.present ? data.timed.value : this.timed,
      isCustom: data.isCustom.present ? data.isCustom.value : this.isCustom,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseRow(')
          ..write('id: $id, ')
          ..write('nameKo: $nameKo, ')
          ..write('nameEn: $nameEn, ')
          ..write('equipment: $equipment, ')
          ..write('type: $type, ')
          ..write('pattern: $pattern, ')
          ..write('difficulty: $difficulty, ')
          ..write('repMin: $repMin, ')
          ..write('repMax: $repMax, ')
          ..write('restSec: $restSec, ')
          ..write('description: $description, ')
          ..write('cues: $cues, ')
          ..write('mistakes: $mistakes, ')
          ..write('cautions: $cautions, ')
          ..write('jointStress: $jointStress, ')
          ..write('referenceIds: $referenceIds, ')
          ..write('videoUrl: $videoUrl, ')
          ..write('assisted: $assisted, ')
          ..write('bodyweight: $bodyweight, ')
          ..write('timed: $timed, ')
          ..write('isCustom: $isCustom')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    nameKo,
    nameEn,
    equipment,
    type,
    pattern,
    difficulty,
    repMin,
    repMax,
    restSec,
    description,
    cues,
    mistakes,
    cautions,
    jointStress,
    referenceIds,
    videoUrl,
    assisted,
    bodyweight,
    timed,
    isCustom,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExerciseRow &&
          other.id == this.id &&
          other.nameKo == this.nameKo &&
          other.nameEn == this.nameEn &&
          other.equipment == this.equipment &&
          other.type == this.type &&
          other.pattern == this.pattern &&
          other.difficulty == this.difficulty &&
          other.repMin == this.repMin &&
          other.repMax == this.repMax &&
          other.restSec == this.restSec &&
          other.description == this.description &&
          other.cues == this.cues &&
          other.mistakes == this.mistakes &&
          other.cautions == this.cautions &&
          other.jointStress == this.jointStress &&
          other.referenceIds == this.referenceIds &&
          other.videoUrl == this.videoUrl &&
          other.assisted == this.assisted &&
          other.bodyweight == this.bodyweight &&
          other.timed == this.timed &&
          other.isCustom == this.isCustom);
}

class ExercisesCompanion extends UpdateCompanion<ExerciseRow> {
  final Value<String> id;
  final Value<String> nameKo;
  final Value<String> nameEn;
  final Value<String> equipment;
  final Value<String> type;
  final Value<String> pattern;
  final Value<int> difficulty;
  final Value<int> repMin;
  final Value<int> repMax;
  final Value<int> restSec;
  final Value<String> description;
  final Value<String> cues;
  final Value<String> mistakes;
  final Value<String> cautions;
  final Value<String> jointStress;
  final Value<String> referenceIds;
  final Value<String?> videoUrl;
  final Value<bool> assisted;
  final Value<bool> bodyweight;
  final Value<bool> timed;
  final Value<bool> isCustom;
  final Value<int> rowid;
  const ExercisesCompanion({
    this.id = const Value.absent(),
    this.nameKo = const Value.absent(),
    this.nameEn = const Value.absent(),
    this.equipment = const Value.absent(),
    this.type = const Value.absent(),
    this.pattern = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.repMin = const Value.absent(),
    this.repMax = const Value.absent(),
    this.restSec = const Value.absent(),
    this.description = const Value.absent(),
    this.cues = const Value.absent(),
    this.mistakes = const Value.absent(),
    this.cautions = const Value.absent(),
    this.jointStress = const Value.absent(),
    this.referenceIds = const Value.absent(),
    this.videoUrl = const Value.absent(),
    this.assisted = const Value.absent(),
    this.bodyweight = const Value.absent(),
    this.timed = const Value.absent(),
    this.isCustom = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExercisesCompanion.insert({
    required String id,
    required String nameKo,
    required String nameEn,
    required String equipment,
    required String type,
    required String pattern,
    required int difficulty,
    required int repMin,
    required int repMax,
    required int restSec,
    required String description,
    required String cues,
    required String mistakes,
    required String cautions,
    required String jointStress,
    required String referenceIds,
    this.videoUrl = const Value.absent(),
    this.assisted = const Value.absent(),
    this.bodyweight = const Value.absent(),
    this.timed = const Value.absent(),
    this.isCustom = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       nameKo = Value(nameKo),
       nameEn = Value(nameEn),
       equipment = Value(equipment),
       type = Value(type),
       pattern = Value(pattern),
       difficulty = Value(difficulty),
       repMin = Value(repMin),
       repMax = Value(repMax),
       restSec = Value(restSec),
       description = Value(description),
       cues = Value(cues),
       mistakes = Value(mistakes),
       cautions = Value(cautions),
       jointStress = Value(jointStress),
       referenceIds = Value(referenceIds);
  static Insertable<ExerciseRow> custom({
    Expression<String>? id,
    Expression<String>? nameKo,
    Expression<String>? nameEn,
    Expression<String>? equipment,
    Expression<String>? type,
    Expression<String>? pattern,
    Expression<int>? difficulty,
    Expression<int>? repMin,
    Expression<int>? repMax,
    Expression<int>? restSec,
    Expression<String>? description,
    Expression<String>? cues,
    Expression<String>? mistakes,
    Expression<String>? cautions,
    Expression<String>? jointStress,
    Expression<String>? referenceIds,
    Expression<String>? videoUrl,
    Expression<bool>? assisted,
    Expression<bool>? bodyweight,
    Expression<bool>? timed,
    Expression<bool>? isCustom,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nameKo != null) 'name_ko': nameKo,
      if (nameEn != null) 'name_en': nameEn,
      if (equipment != null) 'equipment': equipment,
      if (type != null) 'type': type,
      if (pattern != null) 'pattern': pattern,
      if (difficulty != null) 'difficulty': difficulty,
      if (repMin != null) 'rep_min': repMin,
      if (repMax != null) 'rep_max': repMax,
      if (restSec != null) 'rest_sec': restSec,
      if (description != null) 'description': description,
      if (cues != null) 'cues': cues,
      if (mistakes != null) 'mistakes': mistakes,
      if (cautions != null) 'cautions': cautions,
      if (jointStress != null) 'joint_stress': jointStress,
      if (referenceIds != null) 'reference_ids': referenceIds,
      if (videoUrl != null) 'video_url': videoUrl,
      if (assisted != null) 'assisted': assisted,
      if (bodyweight != null) 'bodyweight': bodyweight,
      if (timed != null) 'timed': timed,
      if (isCustom != null) 'is_custom': isCustom,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExercisesCompanion copyWith({
    Value<String>? id,
    Value<String>? nameKo,
    Value<String>? nameEn,
    Value<String>? equipment,
    Value<String>? type,
    Value<String>? pattern,
    Value<int>? difficulty,
    Value<int>? repMin,
    Value<int>? repMax,
    Value<int>? restSec,
    Value<String>? description,
    Value<String>? cues,
    Value<String>? mistakes,
    Value<String>? cautions,
    Value<String>? jointStress,
    Value<String>? referenceIds,
    Value<String?>? videoUrl,
    Value<bool>? assisted,
    Value<bool>? bodyweight,
    Value<bool>? timed,
    Value<bool>? isCustom,
    Value<int>? rowid,
  }) {
    return ExercisesCompanion(
      id: id ?? this.id,
      nameKo: nameKo ?? this.nameKo,
      nameEn: nameEn ?? this.nameEn,
      equipment: equipment ?? this.equipment,
      type: type ?? this.type,
      pattern: pattern ?? this.pattern,
      difficulty: difficulty ?? this.difficulty,
      repMin: repMin ?? this.repMin,
      repMax: repMax ?? this.repMax,
      restSec: restSec ?? this.restSec,
      description: description ?? this.description,
      cues: cues ?? this.cues,
      mistakes: mistakes ?? this.mistakes,
      cautions: cautions ?? this.cautions,
      jointStress: jointStress ?? this.jointStress,
      referenceIds: referenceIds ?? this.referenceIds,
      videoUrl: videoUrl ?? this.videoUrl,
      assisted: assisted ?? this.assisted,
      bodyweight: bodyweight ?? this.bodyweight,
      timed: timed ?? this.timed,
      isCustom: isCustom ?? this.isCustom,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (nameKo.present) {
      map['name_ko'] = Variable<String>(nameKo.value);
    }
    if (nameEn.present) {
      map['name_en'] = Variable<String>(nameEn.value);
    }
    if (equipment.present) {
      map['equipment'] = Variable<String>(equipment.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (pattern.present) {
      map['pattern'] = Variable<String>(pattern.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<int>(difficulty.value);
    }
    if (repMin.present) {
      map['rep_min'] = Variable<int>(repMin.value);
    }
    if (repMax.present) {
      map['rep_max'] = Variable<int>(repMax.value);
    }
    if (restSec.present) {
      map['rest_sec'] = Variable<int>(restSec.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (cues.present) {
      map['cues'] = Variable<String>(cues.value);
    }
    if (mistakes.present) {
      map['mistakes'] = Variable<String>(mistakes.value);
    }
    if (cautions.present) {
      map['cautions'] = Variable<String>(cautions.value);
    }
    if (jointStress.present) {
      map['joint_stress'] = Variable<String>(jointStress.value);
    }
    if (referenceIds.present) {
      map['reference_ids'] = Variable<String>(referenceIds.value);
    }
    if (videoUrl.present) {
      map['video_url'] = Variable<String>(videoUrl.value);
    }
    if (assisted.present) {
      map['assisted'] = Variable<bool>(assisted.value);
    }
    if (bodyweight.present) {
      map['bodyweight'] = Variable<bool>(bodyweight.value);
    }
    if (timed.present) {
      map['timed'] = Variable<bool>(timed.value);
    }
    if (isCustom.present) {
      map['is_custom'] = Variable<bool>(isCustom.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExercisesCompanion(')
          ..write('id: $id, ')
          ..write('nameKo: $nameKo, ')
          ..write('nameEn: $nameEn, ')
          ..write('equipment: $equipment, ')
          ..write('type: $type, ')
          ..write('pattern: $pattern, ')
          ..write('difficulty: $difficulty, ')
          ..write('repMin: $repMin, ')
          ..write('repMax: $repMax, ')
          ..write('restSec: $restSec, ')
          ..write('description: $description, ')
          ..write('cues: $cues, ')
          ..write('mistakes: $mistakes, ')
          ..write('cautions: $cautions, ')
          ..write('jointStress: $jointStress, ')
          ..write('referenceIds: $referenceIds, ')
          ..write('videoUrl: $videoUrl, ')
          ..write('assisted: $assisted, ')
          ..write('bodyweight: $bodyweight, ')
          ..write('timed: $timed, ')
          ..write('isCustom: $isCustom, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExerciseMusclesTable extends ExerciseMuscles with TableInfo<$ExerciseMusclesTable, ExerciseMuscle> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExerciseMusclesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta('exerciseId');
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES exercises (id)'),
  );
  static const VerificationMeta _muscleMeta = const VerificationMeta('muscle');
  @override
  late final GeneratedColumn<String> muscle = GeneratedColumn<String>('muscle', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>('role', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [exerciseId, muscle, role];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercise_muscles';
  @override
  VerificationContext validateIntegrity(Insertable<ExerciseMuscle> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('exercise_id')) {
      context.handle(_exerciseIdMeta, exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta));
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('muscle')) {
      context.handle(_muscleMeta, muscle.isAcceptableOrUnknown(data['muscle']!, _muscleMeta));
    } else if (isInserting) {
      context.missing(_muscleMeta);
    }
    if (data.containsKey('role')) {
      context.handle(_roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {exerciseId, muscle, role};
  @override
  ExerciseMuscle map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExerciseMuscle(
      exerciseId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}exercise_id'])!,
      muscle: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}muscle'])!,
      role: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}role'])!,
    );
  }

  @override
  $ExerciseMusclesTable createAlias(String alias) {
    return $ExerciseMusclesTable(attachedDatabase, alias);
  }
}

class ExerciseMuscle extends DataClass implements Insertable<ExerciseMuscle> {
  final String exerciseId;
  final String muscle;
  final String role;
  const ExerciseMuscle({required this.exerciseId, required this.muscle, required this.role});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['exercise_id'] = Variable<String>(exerciseId);
    map['muscle'] = Variable<String>(muscle);
    map['role'] = Variable<String>(role);
    return map;
  }

  ExerciseMusclesCompanion toCompanion(bool nullToAbsent) {
    return ExerciseMusclesCompanion(exerciseId: Value(exerciseId), muscle: Value(muscle), role: Value(role));
  }

  factory ExerciseMuscle.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExerciseMuscle(
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      muscle: serializer.fromJson<String>(json['muscle']),
      role: serializer.fromJson<String>(json['role']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'exerciseId': serializer.toJson<String>(exerciseId),
      'muscle': serializer.toJson<String>(muscle),
      'role': serializer.toJson<String>(role),
    };
  }

  ExerciseMuscle copyWith({String? exerciseId, String? muscle, String? role}) =>
      ExerciseMuscle(exerciseId: exerciseId ?? this.exerciseId, muscle: muscle ?? this.muscle, role: role ?? this.role);
  ExerciseMuscle copyWithCompanion(ExerciseMusclesCompanion data) {
    return ExerciseMuscle(
      exerciseId: data.exerciseId.present ? data.exerciseId.value : this.exerciseId,
      muscle: data.muscle.present ? data.muscle.value : this.muscle,
      role: data.role.present ? data.role.value : this.role,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseMuscle(')
          ..write('exerciseId: $exerciseId, ')
          ..write('muscle: $muscle, ')
          ..write('role: $role')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(exerciseId, muscle, role);
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is ExerciseMuscle && other.exerciseId == this.exerciseId && other.muscle == this.muscle && other.role == this.role);
}

class ExerciseMusclesCompanion extends UpdateCompanion<ExerciseMuscle> {
  final Value<String> exerciseId;
  final Value<String> muscle;
  final Value<String> role;
  final Value<int> rowid;
  const ExerciseMusclesCompanion({
    this.exerciseId = const Value.absent(),
    this.muscle = const Value.absent(),
    this.role = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExerciseMusclesCompanion.insert({required String exerciseId, required String muscle, required String role, this.rowid = const Value.absent()})
    : exerciseId = Value(exerciseId),
      muscle = Value(muscle),
      role = Value(role);
  static Insertable<ExerciseMuscle> custom({Expression<String>? exerciseId, Expression<String>? muscle, Expression<String>? role, Expression<int>? rowid}) {
    return RawValuesInsertable({
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (muscle != null) 'muscle': muscle,
      if (role != null) 'role': role,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExerciseMusclesCompanion copyWith({Value<String>? exerciseId, Value<String>? muscle, Value<String>? role, Value<int>? rowid}) {
    return ExerciseMusclesCompanion(
      exerciseId: exerciseId ?? this.exerciseId,
      muscle: muscle ?? this.muscle,
      role: role ?? this.role,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (muscle.present) {
      map['muscle'] = Variable<String>(muscle.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseMusclesCompanion(')
          ..write('exerciseId: $exerciseId, ')
          ..write('muscle: $muscle, ')
          ..write('role: $role, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExerciseAlternativesTable extends ExerciseAlternatives with TableInfo<$ExerciseAlternativesTable, ExerciseAlternative> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExerciseAlternativesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta('exerciseId');
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES exercises (id)'),
  );
  static const VerificationMeta _alternativeIdMeta = const VerificationMeta('alternativeId');
  @override
  late final GeneratedColumn<String> alternativeId = GeneratedColumn<String>(
    'alternative_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES exercises (id)'),
  );
  static const VerificationMeta _rankMeta = const VerificationMeta('rank');
  @override
  late final GeneratedColumn<int> rank = GeneratedColumn<int>('rank', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [exerciseId, alternativeId, rank];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercise_alternatives';
  @override
  VerificationContext validateIntegrity(Insertable<ExerciseAlternative> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('exercise_id')) {
      context.handle(_exerciseIdMeta, exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta));
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('alternative_id')) {
      context.handle(_alternativeIdMeta, alternativeId.isAcceptableOrUnknown(data['alternative_id']!, _alternativeIdMeta));
    } else if (isInserting) {
      context.missing(_alternativeIdMeta);
    }
    if (data.containsKey('rank')) {
      context.handle(_rankMeta, rank.isAcceptableOrUnknown(data['rank']!, _rankMeta));
    } else if (isInserting) {
      context.missing(_rankMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {exerciseId, alternativeId};
  @override
  ExerciseAlternative map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExerciseAlternative(
      exerciseId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}exercise_id'])!,
      alternativeId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}alternative_id'])!,
      rank: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}rank'])!,
    );
  }

  @override
  $ExerciseAlternativesTable createAlias(String alias) {
    return $ExerciseAlternativesTable(attachedDatabase, alias);
  }
}

class ExerciseAlternative extends DataClass implements Insertable<ExerciseAlternative> {
  final String exerciseId;
  final String alternativeId;
  final int rank;
  const ExerciseAlternative({required this.exerciseId, required this.alternativeId, required this.rank});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['exercise_id'] = Variable<String>(exerciseId);
    map['alternative_id'] = Variable<String>(alternativeId);
    map['rank'] = Variable<int>(rank);
    return map;
  }

  ExerciseAlternativesCompanion toCompanion(bool nullToAbsent) {
    return ExerciseAlternativesCompanion(exerciseId: Value(exerciseId), alternativeId: Value(alternativeId), rank: Value(rank));
  }

  factory ExerciseAlternative.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExerciseAlternative(
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      alternativeId: serializer.fromJson<String>(json['alternativeId']),
      rank: serializer.fromJson<int>(json['rank']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'exerciseId': serializer.toJson<String>(exerciseId),
      'alternativeId': serializer.toJson<String>(alternativeId),
      'rank': serializer.toJson<int>(rank),
    };
  }

  ExerciseAlternative copyWith({String? exerciseId, String? alternativeId, int? rank}) =>
      ExerciseAlternative(exerciseId: exerciseId ?? this.exerciseId, alternativeId: alternativeId ?? this.alternativeId, rank: rank ?? this.rank);
  ExerciseAlternative copyWithCompanion(ExerciseAlternativesCompanion data) {
    return ExerciseAlternative(
      exerciseId: data.exerciseId.present ? data.exerciseId.value : this.exerciseId,
      alternativeId: data.alternativeId.present ? data.alternativeId.value : this.alternativeId,
      rank: data.rank.present ? data.rank.value : this.rank,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseAlternative(')
          ..write('exerciseId: $exerciseId, ')
          ..write('alternativeId: $alternativeId, ')
          ..write('rank: $rank')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(exerciseId, alternativeId, rank);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExerciseAlternative && other.exerciseId == this.exerciseId && other.alternativeId == this.alternativeId && other.rank == this.rank);
}

class ExerciseAlternativesCompanion extends UpdateCompanion<ExerciseAlternative> {
  final Value<String> exerciseId;
  final Value<String> alternativeId;
  final Value<int> rank;
  final Value<int> rowid;
  const ExerciseAlternativesCompanion({
    this.exerciseId = const Value.absent(),
    this.alternativeId = const Value.absent(),
    this.rank = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExerciseAlternativesCompanion.insert({required String exerciseId, required String alternativeId, required int rank, this.rowid = const Value.absent()})
    : exerciseId = Value(exerciseId),
      alternativeId = Value(alternativeId),
      rank = Value(rank);
  static Insertable<ExerciseAlternative> custom({
    Expression<String>? exerciseId,
    Expression<String>? alternativeId,
    Expression<int>? rank,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (alternativeId != null) 'alternative_id': alternativeId,
      if (rank != null) 'rank': rank,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExerciseAlternativesCompanion copyWith({Value<String>? exerciseId, Value<String>? alternativeId, Value<int>? rank, Value<int>? rowid}) {
    return ExerciseAlternativesCompanion(
      exerciseId: exerciseId ?? this.exerciseId,
      alternativeId: alternativeId ?? this.alternativeId,
      rank: rank ?? this.rank,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (alternativeId.present) {
      map['alternative_id'] = Variable<String>(alternativeId.value);
    }
    if (rank.present) {
      map['rank'] = Variable<int>(rank.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseAlternativesCompanion(')
          ..write('exerciseId: $exerciseId, ')
          ..write('alternativeId: $alternativeId, ')
          ..write('rank: $rank, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkoutProgramsTable extends WorkoutPrograms with TableInfo<$WorkoutProgramsTable, WorkoutProgram> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutProgramsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES users (id)'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>('name', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _splitMeta = const VerificationMeta('split');
  @override
  late final GeneratedColumn<String> split = GeneratedColumn<String>('split', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>('source', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isActiveMeta = const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _basedOnProgramIdMeta = const VerificationMeta('basedOnProgramId');
  @override
  late final GeneratedColumn<int> basedOnProgramId = GeneratedColumn<int>(
    'based_on_program_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rationaleMeta = const VerificationMeta('rationale');
  @override
  late final GeneratedColumn<String> rationale = GeneratedColumn<String>(
    'rationale',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, userId, name, split, source, isActive, basedOnProgramId, rationale, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_programs';
  @override
  VerificationContext validateIntegrity(Insertable<WorkoutProgram> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta, userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('split')) {
      context.handle(_splitMeta, split.isAcceptableOrUnknown(data['split']!, _splitMeta));
    } else if (isInserting) {
      context.missing(_splitMeta);
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta, source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta, isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('based_on_program_id')) {
      context.handle(_basedOnProgramIdMeta, basedOnProgramId.isAcceptableOrUnknown(data['based_on_program_id']!, _basedOnProgramIdMeta));
    }
    if (data.containsKey('rationale')) {
      context.handle(_rationaleMeta, rationale.isAcceptableOrUnknown(data['rationale']!, _rationaleMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta, updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutProgram map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutProgram(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}user_id'])!,
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      split: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}split'])!,
      source: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}source'])!,
      isActive: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      basedOnProgramId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}based_on_program_id']),
      rationale: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}rationale'])!,
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $WorkoutProgramsTable createAlias(String alias) {
    return $WorkoutProgramsTable(attachedDatabase, alias);
  }
}

class WorkoutProgram extends DataClass implements Insertable<WorkoutProgram> {
  final int id;
  final int userId;
  final String name;
  final String split;
  final String source;
  final bool isActive;
  final int? basedOnProgramId;
  final String rationale;
  final DateTime createdAt;
  final DateTime updatedAt;
  const WorkoutProgram({
    required this.id,
    required this.userId,
    required this.name,
    required this.split,
    required this.source,
    required this.isActive,
    this.basedOnProgramId,
    required this.rationale,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<int>(userId);
    map['name'] = Variable<String>(name);
    map['split'] = Variable<String>(split);
    map['source'] = Variable<String>(source);
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || basedOnProgramId != null) {
      map['based_on_program_id'] = Variable<int>(basedOnProgramId);
    }
    map['rationale'] = Variable<String>(rationale);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  WorkoutProgramsCompanion toCompanion(bool nullToAbsent) {
    return WorkoutProgramsCompanion(
      id: Value(id),
      userId: Value(userId),
      name: Value(name),
      split: Value(split),
      source: Value(source),
      isActive: Value(isActive),
      basedOnProgramId: basedOnProgramId == null && nullToAbsent ? const Value.absent() : Value(basedOnProgramId),
      rationale: Value(rationale),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory WorkoutProgram.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutProgram(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<int>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      split: serializer.fromJson<String>(json['split']),
      source: serializer.fromJson<String>(json['source']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      basedOnProgramId: serializer.fromJson<int?>(json['basedOnProgramId']),
      rationale: serializer.fromJson<String>(json['rationale']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<int>(userId),
      'name': serializer.toJson<String>(name),
      'split': serializer.toJson<String>(split),
      'source': serializer.toJson<String>(source),
      'isActive': serializer.toJson<bool>(isActive),
      'basedOnProgramId': serializer.toJson<int?>(basedOnProgramId),
      'rationale': serializer.toJson<String>(rationale),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  WorkoutProgram copyWith({
    int? id,
    int? userId,
    String? name,
    String? split,
    String? source,
    bool? isActive,
    Value<int?> basedOnProgramId = const Value.absent(),
    String? rationale,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => WorkoutProgram(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    name: name ?? this.name,
    split: split ?? this.split,
    source: source ?? this.source,
    isActive: isActive ?? this.isActive,
    basedOnProgramId: basedOnProgramId.present ? basedOnProgramId.value : this.basedOnProgramId,
    rationale: rationale ?? this.rationale,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  WorkoutProgram copyWithCompanion(WorkoutProgramsCompanion data) {
    return WorkoutProgram(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      split: data.split.present ? data.split.value : this.split,
      source: data.source.present ? data.source.value : this.source,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      basedOnProgramId: data.basedOnProgramId.present ? data.basedOnProgramId.value : this.basedOnProgramId,
      rationale: data.rationale.present ? data.rationale.value : this.rationale,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutProgram(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('split: $split, ')
          ..write('source: $source, ')
          ..write('isActive: $isActive, ')
          ..write('basedOnProgramId: $basedOnProgramId, ')
          ..write('rationale: $rationale, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, name, split, source, isActive, basedOnProgramId, rationale, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutProgram &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.split == this.split &&
          other.source == this.source &&
          other.isActive == this.isActive &&
          other.basedOnProgramId == this.basedOnProgramId &&
          other.rationale == this.rationale &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class WorkoutProgramsCompanion extends UpdateCompanion<WorkoutProgram> {
  final Value<int> id;
  final Value<int> userId;
  final Value<String> name;
  final Value<String> split;
  final Value<String> source;
  final Value<bool> isActive;
  final Value<int?> basedOnProgramId;
  final Value<String> rationale;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const WorkoutProgramsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.split = const Value.absent(),
    this.source = const Value.absent(),
    this.isActive = const Value.absent(),
    this.basedOnProgramId = const Value.absent(),
    this.rationale = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  WorkoutProgramsCompanion.insert({
    this.id = const Value.absent(),
    required int userId,
    required String name,
    required String split,
    required String source,
    this.isActive = const Value.absent(),
    this.basedOnProgramId = const Value.absent(),
    this.rationale = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : userId = Value(userId),
       name = Value(name),
       split = Value(split),
       source = Value(source);
  static Insertable<WorkoutProgram> custom({
    Expression<int>? id,
    Expression<int>? userId,
    Expression<String>? name,
    Expression<String>? split,
    Expression<String>? source,
    Expression<bool>? isActive,
    Expression<int>? basedOnProgramId,
    Expression<String>? rationale,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (split != null) 'split': split,
      if (source != null) 'source': source,
      if (isActive != null) 'is_active': isActive,
      if (basedOnProgramId != null) 'based_on_program_id': basedOnProgramId,
      if (rationale != null) 'rationale': rationale,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  WorkoutProgramsCompanion copyWith({
    Value<int>? id,
    Value<int>? userId,
    Value<String>? name,
    Value<String>? split,
    Value<String>? source,
    Value<bool>? isActive,
    Value<int?>? basedOnProgramId,
    Value<String>? rationale,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return WorkoutProgramsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      split: split ?? this.split,
      source: source ?? this.source,
      isActive: isActive ?? this.isActive,
      basedOnProgramId: basedOnProgramId ?? this.basedOnProgramId,
      rationale: rationale ?? this.rationale,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (split.present) {
      map['split'] = Variable<String>(split.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (basedOnProgramId.present) {
      map['based_on_program_id'] = Variable<int>(basedOnProgramId.value);
    }
    if (rationale.present) {
      map['rationale'] = Variable<String>(rationale.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutProgramsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('split: $split, ')
          ..write('source: $source, ')
          ..write('isActive: $isActive, ')
          ..write('basedOnProgramId: $basedOnProgramId, ')
          ..write('rationale: $rationale, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $WorkoutDaysTable extends WorkoutDays with TableInfo<$WorkoutDaysTable, WorkoutDay> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutDaysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _programIdMeta = const VerificationMeta('programId');
  @override
  late final GeneratedColumn<int> programId = GeneratedColumn<int>(
    'program_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES workout_programs (id) ON DELETE CASCADE'),
  );
  static const VerificationMeta _dayIndexMeta = const VerificationMeta('dayIndex');
  @override
  late final GeneratedColumn<int> dayIndex = GeneratedColumn<int>('day_index', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _weekdayMeta = const VerificationMeta('weekday');
  @override
  late final GeneratedColumn<int> weekday = GeneratedColumn<int>('weekday', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>('name', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, programId, dayIndex, weekday, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_days';
  @override
  VerificationContext validateIntegrity(Insertable<WorkoutDay> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('program_id')) {
      context.handle(_programIdMeta, programId.isAcceptableOrUnknown(data['program_id']!, _programIdMeta));
    } else if (isInserting) {
      context.missing(_programIdMeta);
    }
    if (data.containsKey('day_index')) {
      context.handle(_dayIndexMeta, dayIndex.isAcceptableOrUnknown(data['day_index']!, _dayIndexMeta));
    } else if (isInserting) {
      context.missing(_dayIndexMeta);
    }
    if (data.containsKey('weekday')) {
      context.handle(_weekdayMeta, weekday.isAcceptableOrUnknown(data['weekday']!, _weekdayMeta));
    } else if (isInserting) {
      context.missing(_weekdayMeta);
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutDay map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutDay(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      programId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}program_id'])!,
      dayIndex: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}day_index'])!,
      weekday: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}weekday'])!,
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
    );
  }

  @override
  $WorkoutDaysTable createAlias(String alias) {
    return $WorkoutDaysTable(attachedDatabase, alias);
  }
}

class WorkoutDay extends DataClass implements Insertable<WorkoutDay> {
  final int id;
  final int programId;
  final int dayIndex;
  final int weekday;
  final String name;
  const WorkoutDay({required this.id, required this.programId, required this.dayIndex, required this.weekday, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['program_id'] = Variable<int>(programId);
    map['day_index'] = Variable<int>(dayIndex);
    map['weekday'] = Variable<int>(weekday);
    map['name'] = Variable<String>(name);
    return map;
  }

  WorkoutDaysCompanion toCompanion(bool nullToAbsent) {
    return WorkoutDaysCompanion(id: Value(id), programId: Value(programId), dayIndex: Value(dayIndex), weekday: Value(weekday), name: Value(name));
  }

  factory WorkoutDay.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutDay(
      id: serializer.fromJson<int>(json['id']),
      programId: serializer.fromJson<int>(json['programId']),
      dayIndex: serializer.fromJson<int>(json['dayIndex']),
      weekday: serializer.fromJson<int>(json['weekday']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'programId': serializer.toJson<int>(programId),
      'dayIndex': serializer.toJson<int>(dayIndex),
      'weekday': serializer.toJson<int>(weekday),
      'name': serializer.toJson<String>(name),
    };
  }

  WorkoutDay copyWith({int? id, int? programId, int? dayIndex, int? weekday, String? name}) => WorkoutDay(
    id: id ?? this.id,
    programId: programId ?? this.programId,
    dayIndex: dayIndex ?? this.dayIndex,
    weekday: weekday ?? this.weekday,
    name: name ?? this.name,
  );
  WorkoutDay copyWithCompanion(WorkoutDaysCompanion data) {
    return WorkoutDay(
      id: data.id.present ? data.id.value : this.id,
      programId: data.programId.present ? data.programId.value : this.programId,
      dayIndex: data.dayIndex.present ? data.dayIndex.value : this.dayIndex,
      weekday: data.weekday.present ? data.weekday.value : this.weekday,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutDay(')
          ..write('id: $id, ')
          ..write('programId: $programId, ')
          ..write('dayIndex: $dayIndex, ')
          ..write('weekday: $weekday, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, programId, dayIndex, weekday, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutDay &&
          other.id == this.id &&
          other.programId == this.programId &&
          other.dayIndex == this.dayIndex &&
          other.weekday == this.weekday &&
          other.name == this.name);
}

class WorkoutDaysCompanion extends UpdateCompanion<WorkoutDay> {
  final Value<int> id;
  final Value<int> programId;
  final Value<int> dayIndex;
  final Value<int> weekday;
  final Value<String> name;
  const WorkoutDaysCompanion({
    this.id = const Value.absent(),
    this.programId = const Value.absent(),
    this.dayIndex = const Value.absent(),
    this.weekday = const Value.absent(),
    this.name = const Value.absent(),
  });
  WorkoutDaysCompanion.insert({this.id = const Value.absent(), required int programId, required int dayIndex, required int weekday, required String name})
    : programId = Value(programId),
      dayIndex = Value(dayIndex),
      weekday = Value(weekday),
      name = Value(name);
  static Insertable<WorkoutDay> custom({
    Expression<int>? id,
    Expression<int>? programId,
    Expression<int>? dayIndex,
    Expression<int>? weekday,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (programId != null) 'program_id': programId,
      if (dayIndex != null) 'day_index': dayIndex,
      if (weekday != null) 'weekday': weekday,
      if (name != null) 'name': name,
    });
  }

  WorkoutDaysCompanion copyWith({Value<int>? id, Value<int>? programId, Value<int>? dayIndex, Value<int>? weekday, Value<String>? name}) {
    return WorkoutDaysCompanion(
      id: id ?? this.id,
      programId: programId ?? this.programId,
      dayIndex: dayIndex ?? this.dayIndex,
      weekday: weekday ?? this.weekday,
      name: name ?? this.name,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (programId.present) {
      map['program_id'] = Variable<int>(programId.value);
    }
    if (dayIndex.present) {
      map['day_index'] = Variable<int>(dayIndex.value);
    }
    if (weekday.present) {
      map['weekday'] = Variable<int>(weekday.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutDaysCompanion(')
          ..write('id: $id, ')
          ..write('programId: $programId, ')
          ..write('dayIndex: $dayIndex, ')
          ..write('weekday: $weekday, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $WorkoutExercisesTable extends WorkoutExercises with TableInfo<$WorkoutExercisesTable, WorkoutExercise> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _dayIdMeta = const VerificationMeta('dayId');
  @override
  late final GeneratedColumn<int> dayId = GeneratedColumn<int>(
    'day_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES workout_days (id) ON DELETE CASCADE'),
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta('exerciseId');
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES exercises (id)'),
  );
  static const VerificationMeta _orderIndexMeta = const VerificationMeta('orderIndex');
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>('order_index', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _setsMeta = const VerificationMeta('sets');
  @override
  late final GeneratedColumn<int> sets = GeneratedColumn<int>('sets', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _repMinMeta = const VerificationMeta('repMin');
  @override
  late final GeneratedColumn<int> repMin = GeneratedColumn<int>('rep_min', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _repMaxMeta = const VerificationMeta('repMax');
  @override
  late final GeneratedColumn<int> repMax = GeneratedColumn<int>('rep_max', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _targetRirMeta = const VerificationMeta('targetRir');
  @override
  late final GeneratedColumn<int> targetRir = GeneratedColumn<int>('target_rir', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _restSecMeta = const VerificationMeta('restSec');
  @override
  late final GeneratedColumn<int> restSec = GeneratedColumn<int>('rest_sec', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _startWeightMeta = const VerificationMeta('startWeight');
  @override
  late final GeneratedColumn<double> startWeight = GeneratedColumn<double>(
    'start_weight',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _incrementKgMeta = const VerificationMeta('incrementKg');
  @override
  late final GeneratedColumn<double> incrementKg = GeneratedColumn<double>(
    'increment_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [id, dayId, exerciseId, orderIndex, sets, repMin, repMax, targetRir, restSec, startWeight, incrementKg, notes];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_exercises';
  @override
  VerificationContext validateIntegrity(Insertable<WorkoutExercise> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('day_id')) {
      context.handle(_dayIdMeta, dayId.isAcceptableOrUnknown(data['day_id']!, _dayIdMeta));
    } else if (isInserting) {
      context.missing(_dayIdMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(_exerciseIdMeta, exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta));
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('order_index')) {
      context.handle(_orderIndexMeta, orderIndex.isAcceptableOrUnknown(data['order_index']!, _orderIndexMeta));
    } else if (isInserting) {
      context.missing(_orderIndexMeta);
    }
    if (data.containsKey('sets')) {
      context.handle(_setsMeta, sets.isAcceptableOrUnknown(data['sets']!, _setsMeta));
    } else if (isInserting) {
      context.missing(_setsMeta);
    }
    if (data.containsKey('rep_min')) {
      context.handle(_repMinMeta, repMin.isAcceptableOrUnknown(data['rep_min']!, _repMinMeta));
    } else if (isInserting) {
      context.missing(_repMinMeta);
    }
    if (data.containsKey('rep_max')) {
      context.handle(_repMaxMeta, repMax.isAcceptableOrUnknown(data['rep_max']!, _repMaxMeta));
    } else if (isInserting) {
      context.missing(_repMaxMeta);
    }
    if (data.containsKey('target_rir')) {
      context.handle(_targetRirMeta, targetRir.isAcceptableOrUnknown(data['target_rir']!, _targetRirMeta));
    } else if (isInserting) {
      context.missing(_targetRirMeta);
    }
    if (data.containsKey('rest_sec')) {
      context.handle(_restSecMeta, restSec.isAcceptableOrUnknown(data['rest_sec']!, _restSecMeta));
    } else if (isInserting) {
      context.missing(_restSecMeta);
    }
    if (data.containsKey('start_weight')) {
      context.handle(_startWeightMeta, startWeight.isAcceptableOrUnknown(data['start_weight']!, _startWeightMeta));
    }
    if (data.containsKey('increment_kg')) {
      context.handle(_incrementKgMeta, incrementKg.isAcceptableOrUnknown(data['increment_kg']!, _incrementKgMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(_notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutExercise map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutExercise(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      dayId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}day_id'])!,
      exerciseId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}exercise_id'])!,
      orderIndex: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}order_index'])!,
      sets: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}sets'])!,
      repMin: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}rep_min'])!,
      repMax: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}rep_max'])!,
      targetRir: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}target_rir'])!,
      restSec: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}rest_sec'])!,
      startWeight: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}start_weight']),
      incrementKg: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}increment_kg']),
      notes: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}notes'])!,
    );
  }

  @override
  $WorkoutExercisesTable createAlias(String alias) {
    return $WorkoutExercisesTable(attachedDatabase, alias);
  }
}

class WorkoutExercise extends DataClass implements Insertable<WorkoutExercise> {
  final int id;
  final int dayId;
  final String exerciseId;
  final int orderIndex;
  final int sets;
  final int repMin;
  final int repMax;
  final int targetRir;
  final int restSec;
  final double? startWeight;
  final double? incrementKg;
  final String notes;
  const WorkoutExercise({
    required this.id,
    required this.dayId,
    required this.exerciseId,
    required this.orderIndex,
    required this.sets,
    required this.repMin,
    required this.repMax,
    required this.targetRir,
    required this.restSec,
    this.startWeight,
    this.incrementKg,
    required this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['day_id'] = Variable<int>(dayId);
    map['exercise_id'] = Variable<String>(exerciseId);
    map['order_index'] = Variable<int>(orderIndex);
    map['sets'] = Variable<int>(sets);
    map['rep_min'] = Variable<int>(repMin);
    map['rep_max'] = Variable<int>(repMax);
    map['target_rir'] = Variable<int>(targetRir);
    map['rest_sec'] = Variable<int>(restSec);
    if (!nullToAbsent || startWeight != null) {
      map['start_weight'] = Variable<double>(startWeight);
    }
    if (!nullToAbsent || incrementKg != null) {
      map['increment_kg'] = Variable<double>(incrementKg);
    }
    map['notes'] = Variable<String>(notes);
    return map;
  }

  WorkoutExercisesCompanion toCompanion(bool nullToAbsent) {
    return WorkoutExercisesCompanion(
      id: Value(id),
      dayId: Value(dayId),
      exerciseId: Value(exerciseId),
      orderIndex: Value(orderIndex),
      sets: Value(sets),
      repMin: Value(repMin),
      repMax: Value(repMax),
      targetRir: Value(targetRir),
      restSec: Value(restSec),
      startWeight: startWeight == null && nullToAbsent ? const Value.absent() : Value(startWeight),
      incrementKg: incrementKg == null && nullToAbsent ? const Value.absent() : Value(incrementKg),
      notes: Value(notes),
    );
  }

  factory WorkoutExercise.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutExercise(
      id: serializer.fromJson<int>(json['id']),
      dayId: serializer.fromJson<int>(json['dayId']),
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
      sets: serializer.fromJson<int>(json['sets']),
      repMin: serializer.fromJson<int>(json['repMin']),
      repMax: serializer.fromJson<int>(json['repMax']),
      targetRir: serializer.fromJson<int>(json['targetRir']),
      restSec: serializer.fromJson<int>(json['restSec']),
      startWeight: serializer.fromJson<double?>(json['startWeight']),
      incrementKg: serializer.fromJson<double?>(json['incrementKg']),
      notes: serializer.fromJson<String>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'dayId': serializer.toJson<int>(dayId),
      'exerciseId': serializer.toJson<String>(exerciseId),
      'orderIndex': serializer.toJson<int>(orderIndex),
      'sets': serializer.toJson<int>(sets),
      'repMin': serializer.toJson<int>(repMin),
      'repMax': serializer.toJson<int>(repMax),
      'targetRir': serializer.toJson<int>(targetRir),
      'restSec': serializer.toJson<int>(restSec),
      'startWeight': serializer.toJson<double?>(startWeight),
      'incrementKg': serializer.toJson<double?>(incrementKg),
      'notes': serializer.toJson<String>(notes),
    };
  }

  WorkoutExercise copyWith({
    int? id,
    int? dayId,
    String? exerciseId,
    int? orderIndex,
    int? sets,
    int? repMin,
    int? repMax,
    int? targetRir,
    int? restSec,
    Value<double?> startWeight = const Value.absent(),
    Value<double?> incrementKg = const Value.absent(),
    String? notes,
  }) => WorkoutExercise(
    id: id ?? this.id,
    dayId: dayId ?? this.dayId,
    exerciseId: exerciseId ?? this.exerciseId,
    orderIndex: orderIndex ?? this.orderIndex,
    sets: sets ?? this.sets,
    repMin: repMin ?? this.repMin,
    repMax: repMax ?? this.repMax,
    targetRir: targetRir ?? this.targetRir,
    restSec: restSec ?? this.restSec,
    startWeight: startWeight.present ? startWeight.value : this.startWeight,
    incrementKg: incrementKg.present ? incrementKg.value : this.incrementKg,
    notes: notes ?? this.notes,
  );
  WorkoutExercise copyWithCompanion(WorkoutExercisesCompanion data) {
    return WorkoutExercise(
      id: data.id.present ? data.id.value : this.id,
      dayId: data.dayId.present ? data.dayId.value : this.dayId,
      exerciseId: data.exerciseId.present ? data.exerciseId.value : this.exerciseId,
      orderIndex: data.orderIndex.present ? data.orderIndex.value : this.orderIndex,
      sets: data.sets.present ? data.sets.value : this.sets,
      repMin: data.repMin.present ? data.repMin.value : this.repMin,
      repMax: data.repMax.present ? data.repMax.value : this.repMax,
      targetRir: data.targetRir.present ? data.targetRir.value : this.targetRir,
      restSec: data.restSec.present ? data.restSec.value : this.restSec,
      startWeight: data.startWeight.present ? data.startWeight.value : this.startWeight,
      incrementKg: data.incrementKg.present ? data.incrementKg.value : this.incrementKg,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutExercise(')
          ..write('id: $id, ')
          ..write('dayId: $dayId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('sets: $sets, ')
          ..write('repMin: $repMin, ')
          ..write('repMax: $repMax, ')
          ..write('targetRir: $targetRir, ')
          ..write('restSec: $restSec, ')
          ..write('startWeight: $startWeight, ')
          ..write('incrementKg: $incrementKg, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, dayId, exerciseId, orderIndex, sets, repMin, repMax, targetRir, restSec, startWeight, incrementKg, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutExercise &&
          other.id == this.id &&
          other.dayId == this.dayId &&
          other.exerciseId == this.exerciseId &&
          other.orderIndex == this.orderIndex &&
          other.sets == this.sets &&
          other.repMin == this.repMin &&
          other.repMax == this.repMax &&
          other.targetRir == this.targetRir &&
          other.restSec == this.restSec &&
          other.startWeight == this.startWeight &&
          other.incrementKg == this.incrementKg &&
          other.notes == this.notes);
}

class WorkoutExercisesCompanion extends UpdateCompanion<WorkoutExercise> {
  final Value<int> id;
  final Value<int> dayId;
  final Value<String> exerciseId;
  final Value<int> orderIndex;
  final Value<int> sets;
  final Value<int> repMin;
  final Value<int> repMax;
  final Value<int> targetRir;
  final Value<int> restSec;
  final Value<double?> startWeight;
  final Value<double?> incrementKg;
  final Value<String> notes;
  const WorkoutExercisesCompanion({
    this.id = const Value.absent(),
    this.dayId = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.sets = const Value.absent(),
    this.repMin = const Value.absent(),
    this.repMax = const Value.absent(),
    this.targetRir = const Value.absent(),
    this.restSec = const Value.absent(),
    this.startWeight = const Value.absent(),
    this.incrementKg = const Value.absent(),
    this.notes = const Value.absent(),
  });
  WorkoutExercisesCompanion.insert({
    this.id = const Value.absent(),
    required int dayId,
    required String exerciseId,
    required int orderIndex,
    required int sets,
    required int repMin,
    required int repMax,
    required int targetRir,
    required int restSec,
    this.startWeight = const Value.absent(),
    this.incrementKg = const Value.absent(),
    this.notes = const Value.absent(),
  }) : dayId = Value(dayId),
       exerciseId = Value(exerciseId),
       orderIndex = Value(orderIndex),
       sets = Value(sets),
       repMin = Value(repMin),
       repMax = Value(repMax),
       targetRir = Value(targetRir),
       restSec = Value(restSec);
  static Insertable<WorkoutExercise> custom({
    Expression<int>? id,
    Expression<int>? dayId,
    Expression<String>? exerciseId,
    Expression<int>? orderIndex,
    Expression<int>? sets,
    Expression<int>? repMin,
    Expression<int>? repMax,
    Expression<int>? targetRir,
    Expression<int>? restSec,
    Expression<double>? startWeight,
    Expression<double>? incrementKg,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dayId != null) 'day_id': dayId,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (orderIndex != null) 'order_index': orderIndex,
      if (sets != null) 'sets': sets,
      if (repMin != null) 'rep_min': repMin,
      if (repMax != null) 'rep_max': repMax,
      if (targetRir != null) 'target_rir': targetRir,
      if (restSec != null) 'rest_sec': restSec,
      if (startWeight != null) 'start_weight': startWeight,
      if (incrementKg != null) 'increment_kg': incrementKg,
      if (notes != null) 'notes': notes,
    });
  }

  WorkoutExercisesCompanion copyWith({
    Value<int>? id,
    Value<int>? dayId,
    Value<String>? exerciseId,
    Value<int>? orderIndex,
    Value<int>? sets,
    Value<int>? repMin,
    Value<int>? repMax,
    Value<int>? targetRir,
    Value<int>? restSec,
    Value<double?>? startWeight,
    Value<double?>? incrementKg,
    Value<String>? notes,
  }) {
    return WorkoutExercisesCompanion(
      id: id ?? this.id,
      dayId: dayId ?? this.dayId,
      exerciseId: exerciseId ?? this.exerciseId,
      orderIndex: orderIndex ?? this.orderIndex,
      sets: sets ?? this.sets,
      repMin: repMin ?? this.repMin,
      repMax: repMax ?? this.repMax,
      targetRir: targetRir ?? this.targetRir,
      restSec: restSec ?? this.restSec,
      startWeight: startWeight ?? this.startWeight,
      incrementKg: incrementKg ?? this.incrementKg,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (dayId.present) {
      map['day_id'] = Variable<int>(dayId.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (sets.present) {
      map['sets'] = Variable<int>(sets.value);
    }
    if (repMin.present) {
      map['rep_min'] = Variable<int>(repMin.value);
    }
    if (repMax.present) {
      map['rep_max'] = Variable<int>(repMax.value);
    }
    if (targetRir.present) {
      map['target_rir'] = Variable<int>(targetRir.value);
    }
    if (restSec.present) {
      map['rest_sec'] = Variable<int>(restSec.value);
    }
    if (startWeight.present) {
      map['start_weight'] = Variable<double>(startWeight.value);
    }
    if (incrementKg.present) {
      map['increment_kg'] = Variable<double>(incrementKg.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutExercisesCompanion(')
          ..write('id: $id, ')
          ..write('dayId: $dayId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('sets: $sets, ')
          ..write('repMin: $repMin, ')
          ..write('repMax: $repMax, ')
          ..write('targetRir: $targetRir, ')
          ..write('restSec: $restSec, ')
          ..write('startWeight: $startWeight, ')
          ..write('incrementKg: $incrementKg, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $WorkoutSessionsTable extends WorkoutSessions with TableInfo<$WorkoutSessionsTable, WorkoutSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _programIdMeta = const VerificationMeta('programId');
  @override
  late final GeneratedColumn<int> programId = GeneratedColumn<int>('program_id', aliasedName, true, type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _dayIndexMeta = const VerificationMeta('dayIndex');
  @override
  late final GeneratedColumn<int> dayIndex = GeneratedColumn<int>('day_index', aliasedName, true, type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _dayNameMeta = const VerificationMeta('dayName');
  @override
  late final GeneratedColumn<String> dayName = GeneratedColumn<String>('day_name', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _startedAtMeta = const VerificationMeta('startedAt');
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _finishedAtMeta = const VerificationMeta('finishedAt');
  @override
  late final GeneratedColumn<DateTime> finishedAt = GeneratedColumn<DateTime>(
    'finished_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>('status', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _readinessScoreMeta = const VerificationMeta('readinessScore');
  @override
  late final GeneratedColumn<int> readinessScore = GeneratedColumn<int>(
    'readiness_score',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _readinessMeta = const VerificationMeta('readiness');
  @override
  late final GeneratedColumn<String> readiness = GeneratedColumn<String>(
    'readiness',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [id, programId, dayIndex, dayName, startedAt, finishedAt, status, readinessScore, readiness, notes];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_sessions';
  @override
  VerificationContext validateIntegrity(Insertable<WorkoutSession> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('program_id')) {
      context.handle(_programIdMeta, programId.isAcceptableOrUnknown(data['program_id']!, _programIdMeta));
    }
    if (data.containsKey('day_index')) {
      context.handle(_dayIndexMeta, dayIndex.isAcceptableOrUnknown(data['day_index']!, _dayIndexMeta));
    }
    if (data.containsKey('day_name')) {
      context.handle(_dayNameMeta, dayName.isAcceptableOrUnknown(data['day_name']!, _dayNameMeta));
    } else if (isInserting) {
      context.missing(_dayNameMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(_startedAtMeta, startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta));
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('finished_at')) {
      context.handle(_finishedAtMeta, finishedAt.isAcceptableOrUnknown(data['finished_at']!, _finishedAtMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta, status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('readiness_score')) {
      context.handle(_readinessScoreMeta, readinessScore.isAcceptableOrUnknown(data['readiness_score']!, _readinessScoreMeta));
    }
    if (data.containsKey('readiness')) {
      context.handle(_readinessMeta, readiness.isAcceptableOrUnknown(data['readiness']!, _readinessMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(_notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutSession(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      programId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}program_id']),
      dayIndex: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}day_index']),
      dayName: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}day_name'])!,
      startedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}started_at'])!,
      finishedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}finished_at']),
      status: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      readinessScore: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}readiness_score']),
      readiness: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}readiness']),
      notes: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}notes'])!,
    );
  }

  @override
  $WorkoutSessionsTable createAlias(String alias) {
    return $WorkoutSessionsTable(attachedDatabase, alias);
  }
}

class WorkoutSession extends DataClass implements Insertable<WorkoutSession> {
  final int id;
  final int? programId;
  final int? dayIndex;
  final String dayName;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final String status;
  final int? readinessScore;
  final String? readiness;
  final String notes;
  const WorkoutSession({
    required this.id,
    this.programId,
    this.dayIndex,
    required this.dayName,
    required this.startedAt,
    this.finishedAt,
    required this.status,
    this.readinessScore,
    this.readiness,
    required this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || programId != null) {
      map['program_id'] = Variable<int>(programId);
    }
    if (!nullToAbsent || dayIndex != null) {
      map['day_index'] = Variable<int>(dayIndex);
    }
    map['day_name'] = Variable<String>(dayName);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || finishedAt != null) {
      map['finished_at'] = Variable<DateTime>(finishedAt);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || readinessScore != null) {
      map['readiness_score'] = Variable<int>(readinessScore);
    }
    if (!nullToAbsent || readiness != null) {
      map['readiness'] = Variable<String>(readiness);
    }
    map['notes'] = Variable<String>(notes);
    return map;
  }

  WorkoutSessionsCompanion toCompanion(bool nullToAbsent) {
    return WorkoutSessionsCompanion(
      id: Value(id),
      programId: programId == null && nullToAbsent ? const Value.absent() : Value(programId),
      dayIndex: dayIndex == null && nullToAbsent ? const Value.absent() : Value(dayIndex),
      dayName: Value(dayName),
      startedAt: Value(startedAt),
      finishedAt: finishedAt == null && nullToAbsent ? const Value.absent() : Value(finishedAt),
      status: Value(status),
      readinessScore: readinessScore == null && nullToAbsent ? const Value.absent() : Value(readinessScore),
      readiness: readiness == null && nullToAbsent ? const Value.absent() : Value(readiness),
      notes: Value(notes),
    );
  }

  factory WorkoutSession.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutSession(
      id: serializer.fromJson<int>(json['id']),
      programId: serializer.fromJson<int?>(json['programId']),
      dayIndex: serializer.fromJson<int?>(json['dayIndex']),
      dayName: serializer.fromJson<String>(json['dayName']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      finishedAt: serializer.fromJson<DateTime?>(json['finishedAt']),
      status: serializer.fromJson<String>(json['status']),
      readinessScore: serializer.fromJson<int?>(json['readinessScore']),
      readiness: serializer.fromJson<String?>(json['readiness']),
      notes: serializer.fromJson<String>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'programId': serializer.toJson<int?>(programId),
      'dayIndex': serializer.toJson<int?>(dayIndex),
      'dayName': serializer.toJson<String>(dayName),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'finishedAt': serializer.toJson<DateTime?>(finishedAt),
      'status': serializer.toJson<String>(status),
      'readinessScore': serializer.toJson<int?>(readinessScore),
      'readiness': serializer.toJson<String?>(readiness),
      'notes': serializer.toJson<String>(notes),
    };
  }

  WorkoutSession copyWith({
    int? id,
    Value<int?> programId = const Value.absent(),
    Value<int?> dayIndex = const Value.absent(),
    String? dayName,
    DateTime? startedAt,
    Value<DateTime?> finishedAt = const Value.absent(),
    String? status,
    Value<int?> readinessScore = const Value.absent(),
    Value<String?> readiness = const Value.absent(),
    String? notes,
  }) => WorkoutSession(
    id: id ?? this.id,
    programId: programId.present ? programId.value : this.programId,
    dayIndex: dayIndex.present ? dayIndex.value : this.dayIndex,
    dayName: dayName ?? this.dayName,
    startedAt: startedAt ?? this.startedAt,
    finishedAt: finishedAt.present ? finishedAt.value : this.finishedAt,
    status: status ?? this.status,
    readinessScore: readinessScore.present ? readinessScore.value : this.readinessScore,
    readiness: readiness.present ? readiness.value : this.readiness,
    notes: notes ?? this.notes,
  );
  WorkoutSession copyWithCompanion(WorkoutSessionsCompanion data) {
    return WorkoutSession(
      id: data.id.present ? data.id.value : this.id,
      programId: data.programId.present ? data.programId.value : this.programId,
      dayIndex: data.dayIndex.present ? data.dayIndex.value : this.dayIndex,
      dayName: data.dayName.present ? data.dayName.value : this.dayName,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      finishedAt: data.finishedAt.present ? data.finishedAt.value : this.finishedAt,
      status: data.status.present ? data.status.value : this.status,
      readinessScore: data.readinessScore.present ? data.readinessScore.value : this.readinessScore,
      readiness: data.readiness.present ? data.readiness.value : this.readiness,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSession(')
          ..write('id: $id, ')
          ..write('programId: $programId, ')
          ..write('dayIndex: $dayIndex, ')
          ..write('dayName: $dayName, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('status: $status, ')
          ..write('readinessScore: $readinessScore, ')
          ..write('readiness: $readiness, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, programId, dayIndex, dayName, startedAt, finishedAt, status, readinessScore, readiness, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutSession &&
          other.id == this.id &&
          other.programId == this.programId &&
          other.dayIndex == this.dayIndex &&
          other.dayName == this.dayName &&
          other.startedAt == this.startedAt &&
          other.finishedAt == this.finishedAt &&
          other.status == this.status &&
          other.readinessScore == this.readinessScore &&
          other.readiness == this.readiness &&
          other.notes == this.notes);
}

class WorkoutSessionsCompanion extends UpdateCompanion<WorkoutSession> {
  final Value<int> id;
  final Value<int?> programId;
  final Value<int?> dayIndex;
  final Value<String> dayName;
  final Value<DateTime> startedAt;
  final Value<DateTime?> finishedAt;
  final Value<String> status;
  final Value<int?> readinessScore;
  final Value<String?> readiness;
  final Value<String> notes;
  const WorkoutSessionsCompanion({
    this.id = const Value.absent(),
    this.programId = const Value.absent(),
    this.dayIndex = const Value.absent(),
    this.dayName = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.status = const Value.absent(),
    this.readinessScore = const Value.absent(),
    this.readiness = const Value.absent(),
    this.notes = const Value.absent(),
  });
  WorkoutSessionsCompanion.insert({
    this.id = const Value.absent(),
    this.programId = const Value.absent(),
    this.dayIndex = const Value.absent(),
    required String dayName,
    required DateTime startedAt,
    this.finishedAt = const Value.absent(),
    required String status,
    this.readinessScore = const Value.absent(),
    this.readiness = const Value.absent(),
    this.notes = const Value.absent(),
  }) : dayName = Value(dayName),
       startedAt = Value(startedAt),
       status = Value(status);
  static Insertable<WorkoutSession> custom({
    Expression<int>? id,
    Expression<int>? programId,
    Expression<int>? dayIndex,
    Expression<String>? dayName,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? finishedAt,
    Expression<String>? status,
    Expression<int>? readinessScore,
    Expression<String>? readiness,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (programId != null) 'program_id': programId,
      if (dayIndex != null) 'day_index': dayIndex,
      if (dayName != null) 'day_name': dayName,
      if (startedAt != null) 'started_at': startedAt,
      if (finishedAt != null) 'finished_at': finishedAt,
      if (status != null) 'status': status,
      if (readinessScore != null) 'readiness_score': readinessScore,
      if (readiness != null) 'readiness': readiness,
      if (notes != null) 'notes': notes,
    });
  }

  WorkoutSessionsCompanion copyWith({
    Value<int>? id,
    Value<int?>? programId,
    Value<int?>? dayIndex,
    Value<String>? dayName,
    Value<DateTime>? startedAt,
    Value<DateTime?>? finishedAt,
    Value<String>? status,
    Value<int?>? readinessScore,
    Value<String?>? readiness,
    Value<String>? notes,
  }) {
    return WorkoutSessionsCompanion(
      id: id ?? this.id,
      programId: programId ?? this.programId,
      dayIndex: dayIndex ?? this.dayIndex,
      dayName: dayName ?? this.dayName,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      status: status ?? this.status,
      readinessScore: readinessScore ?? this.readinessScore,
      readiness: readiness ?? this.readiness,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (programId.present) {
      map['program_id'] = Variable<int>(programId.value);
    }
    if (dayIndex.present) {
      map['day_index'] = Variable<int>(dayIndex.value);
    }
    if (dayName.present) {
      map['day_name'] = Variable<String>(dayName.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (finishedAt.present) {
      map['finished_at'] = Variable<DateTime>(finishedAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (readinessScore.present) {
      map['readiness_score'] = Variable<int>(readinessScore.value);
    }
    if (readiness.present) {
      map['readiness'] = Variable<String>(readiness.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSessionsCompanion(')
          ..write('id: $id, ')
          ..write('programId: $programId, ')
          ..write('dayIndex: $dayIndex, ')
          ..write('dayName: $dayName, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('status: $status, ')
          ..write('readinessScore: $readinessScore, ')
          ..write('readiness: $readiness, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $WorkoutSessionExercisesTable extends WorkoutSessionExercises with TableInfo<$WorkoutSessionExercisesTable, SessionExercise> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutSessionExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta('sessionId');
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES workout_sessions (id) ON DELETE CASCADE'),
  );
  static const VerificationMeta _workoutExerciseIdMeta = const VerificationMeta('workoutExerciseId');
  @override
  late final GeneratedColumn<int> workoutExerciseId = GeneratedColumn<int>(
    'workout_exercise_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta('exerciseId');
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES exercises (id)'),
  );
  static const VerificationMeta _orderIndexMeta = const VerificationMeta('orderIndex');
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>('order_index', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _targetSetsMeta = const VerificationMeta('targetSets');
  @override
  late final GeneratedColumn<int> targetSets = GeneratedColumn<int>('target_sets', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _repMinMeta = const VerificationMeta('repMin');
  @override
  late final GeneratedColumn<int> repMin = GeneratedColumn<int>('rep_min', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _repMaxMeta = const VerificationMeta('repMax');
  @override
  late final GeneratedColumn<int> repMax = GeneratedColumn<int>('rep_max', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _targetRirMeta = const VerificationMeta('targetRir');
  @override
  late final GeneratedColumn<int> targetRir = GeneratedColumn<int>('target_rir', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _restSecMeta = const VerificationMeta('restSec');
  @override
  late final GeneratedColumn<int> restSec = GeneratedColumn<int>('rest_sec', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _substitutedFromMeta = const VerificationMeta('substitutedFrom');
  @override
  late final GeneratedColumn<String> substitutedFrom = GeneratedColumn<String>(
    'substituted_from',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _painMeta = const VerificationMeta('pain');
  @override
  late final GeneratedColumn<bool> pain = GeneratedColumn<bool>(
    'pain',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("pain" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _formUnstableMeta = const VerificationMeta('formUnstable');
  @override
  late final GeneratedColumn<bool> formUnstable = GeneratedColumn<bool>(
    'form_unstable',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("form_unstable" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _recommendationIdMeta = const VerificationMeta('recommendationId');
  @override
  late final GeneratedColumn<int> recommendationId = GeneratedColumn<int>(
    'recommendation_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    workoutExerciseId,
    exerciseId,
    orderIndex,
    targetSets,
    repMin,
    repMax,
    targetRir,
    restSec,
    substitutedFrom,
    pain,
    formUnstable,
    recommendationId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_session_exercises';
  @override
  VerificationContext validateIntegrity(Insertable<SessionExercise> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(_sessionIdMeta, sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta));
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('workout_exercise_id')) {
      context.handle(_workoutExerciseIdMeta, workoutExerciseId.isAcceptableOrUnknown(data['workout_exercise_id']!, _workoutExerciseIdMeta));
    }
    if (data.containsKey('exercise_id')) {
      context.handle(_exerciseIdMeta, exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta));
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('order_index')) {
      context.handle(_orderIndexMeta, orderIndex.isAcceptableOrUnknown(data['order_index']!, _orderIndexMeta));
    } else if (isInserting) {
      context.missing(_orderIndexMeta);
    }
    if (data.containsKey('target_sets')) {
      context.handle(_targetSetsMeta, targetSets.isAcceptableOrUnknown(data['target_sets']!, _targetSetsMeta));
    } else if (isInserting) {
      context.missing(_targetSetsMeta);
    }
    if (data.containsKey('rep_min')) {
      context.handle(_repMinMeta, repMin.isAcceptableOrUnknown(data['rep_min']!, _repMinMeta));
    } else if (isInserting) {
      context.missing(_repMinMeta);
    }
    if (data.containsKey('rep_max')) {
      context.handle(_repMaxMeta, repMax.isAcceptableOrUnknown(data['rep_max']!, _repMaxMeta));
    } else if (isInserting) {
      context.missing(_repMaxMeta);
    }
    if (data.containsKey('target_rir')) {
      context.handle(_targetRirMeta, targetRir.isAcceptableOrUnknown(data['target_rir']!, _targetRirMeta));
    } else if (isInserting) {
      context.missing(_targetRirMeta);
    }
    if (data.containsKey('rest_sec')) {
      context.handle(_restSecMeta, restSec.isAcceptableOrUnknown(data['rest_sec']!, _restSecMeta));
    } else if (isInserting) {
      context.missing(_restSecMeta);
    }
    if (data.containsKey('substituted_from')) {
      context.handle(_substitutedFromMeta, substitutedFrom.isAcceptableOrUnknown(data['substituted_from']!, _substitutedFromMeta));
    }
    if (data.containsKey('pain')) {
      context.handle(_painMeta, pain.isAcceptableOrUnknown(data['pain']!, _painMeta));
    }
    if (data.containsKey('form_unstable')) {
      context.handle(_formUnstableMeta, formUnstable.isAcceptableOrUnknown(data['form_unstable']!, _formUnstableMeta));
    }
    if (data.containsKey('recommendation_id')) {
      context.handle(_recommendationIdMeta, recommendationId.isAcceptableOrUnknown(data['recommendation_id']!, _recommendationIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessionExercise map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionExercise(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      sessionId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}session_id'])!,
      workoutExerciseId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}workout_exercise_id']),
      exerciseId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}exercise_id'])!,
      orderIndex: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}order_index'])!,
      targetSets: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}target_sets'])!,
      repMin: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}rep_min'])!,
      repMax: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}rep_max'])!,
      targetRir: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}target_rir'])!,
      restSec: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}rest_sec'])!,
      substitutedFrom: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}substituted_from']),
      pain: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}pain'])!,
      formUnstable: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}form_unstable'])!,
      recommendationId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}recommendation_id']),
    );
  }

  @override
  $WorkoutSessionExercisesTable createAlias(String alias) {
    return $WorkoutSessionExercisesTable(attachedDatabase, alias);
  }
}

class SessionExercise extends DataClass implements Insertable<SessionExercise> {
  final int id;
  final int sessionId;
  final int? workoutExerciseId;
  final String exerciseId;
  final int orderIndex;
  final int targetSets;
  final int repMin;
  final int repMax;
  final int targetRir;
  final int restSec;
  final String? substitutedFrom;
  final bool pain;
  final bool formUnstable;
  final int? recommendationId;
  const SessionExercise({
    required this.id,
    required this.sessionId,
    this.workoutExerciseId,
    required this.exerciseId,
    required this.orderIndex,
    required this.targetSets,
    required this.repMin,
    required this.repMax,
    required this.targetRir,
    required this.restSec,
    this.substitutedFrom,
    required this.pain,
    required this.formUnstable,
    this.recommendationId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    if (!nullToAbsent || workoutExerciseId != null) {
      map['workout_exercise_id'] = Variable<int>(workoutExerciseId);
    }
    map['exercise_id'] = Variable<String>(exerciseId);
    map['order_index'] = Variable<int>(orderIndex);
    map['target_sets'] = Variable<int>(targetSets);
    map['rep_min'] = Variable<int>(repMin);
    map['rep_max'] = Variable<int>(repMax);
    map['target_rir'] = Variable<int>(targetRir);
    map['rest_sec'] = Variable<int>(restSec);
    if (!nullToAbsent || substitutedFrom != null) {
      map['substituted_from'] = Variable<String>(substitutedFrom);
    }
    map['pain'] = Variable<bool>(pain);
    map['form_unstable'] = Variable<bool>(formUnstable);
    if (!nullToAbsent || recommendationId != null) {
      map['recommendation_id'] = Variable<int>(recommendationId);
    }
    return map;
  }

  WorkoutSessionExercisesCompanion toCompanion(bool nullToAbsent) {
    return WorkoutSessionExercisesCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      workoutExerciseId: workoutExerciseId == null && nullToAbsent ? const Value.absent() : Value(workoutExerciseId),
      exerciseId: Value(exerciseId),
      orderIndex: Value(orderIndex),
      targetSets: Value(targetSets),
      repMin: Value(repMin),
      repMax: Value(repMax),
      targetRir: Value(targetRir),
      restSec: Value(restSec),
      substitutedFrom: substitutedFrom == null && nullToAbsent ? const Value.absent() : Value(substitutedFrom),
      pain: Value(pain),
      formUnstable: Value(formUnstable),
      recommendationId: recommendationId == null && nullToAbsent ? const Value.absent() : Value(recommendationId),
    );
  }

  factory SessionExercise.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionExercise(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      workoutExerciseId: serializer.fromJson<int?>(json['workoutExerciseId']),
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
      targetSets: serializer.fromJson<int>(json['targetSets']),
      repMin: serializer.fromJson<int>(json['repMin']),
      repMax: serializer.fromJson<int>(json['repMax']),
      targetRir: serializer.fromJson<int>(json['targetRir']),
      restSec: serializer.fromJson<int>(json['restSec']),
      substitutedFrom: serializer.fromJson<String?>(json['substitutedFrom']),
      pain: serializer.fromJson<bool>(json['pain']),
      formUnstable: serializer.fromJson<bool>(json['formUnstable']),
      recommendationId: serializer.fromJson<int?>(json['recommendationId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'workoutExerciseId': serializer.toJson<int?>(workoutExerciseId),
      'exerciseId': serializer.toJson<String>(exerciseId),
      'orderIndex': serializer.toJson<int>(orderIndex),
      'targetSets': serializer.toJson<int>(targetSets),
      'repMin': serializer.toJson<int>(repMin),
      'repMax': serializer.toJson<int>(repMax),
      'targetRir': serializer.toJson<int>(targetRir),
      'restSec': serializer.toJson<int>(restSec),
      'substitutedFrom': serializer.toJson<String?>(substitutedFrom),
      'pain': serializer.toJson<bool>(pain),
      'formUnstable': serializer.toJson<bool>(formUnstable),
      'recommendationId': serializer.toJson<int?>(recommendationId),
    };
  }

  SessionExercise copyWith({
    int? id,
    int? sessionId,
    Value<int?> workoutExerciseId = const Value.absent(),
    String? exerciseId,
    int? orderIndex,
    int? targetSets,
    int? repMin,
    int? repMax,
    int? targetRir,
    int? restSec,
    Value<String?> substitutedFrom = const Value.absent(),
    bool? pain,
    bool? formUnstable,
    Value<int?> recommendationId = const Value.absent(),
  }) => SessionExercise(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    workoutExerciseId: workoutExerciseId.present ? workoutExerciseId.value : this.workoutExerciseId,
    exerciseId: exerciseId ?? this.exerciseId,
    orderIndex: orderIndex ?? this.orderIndex,
    targetSets: targetSets ?? this.targetSets,
    repMin: repMin ?? this.repMin,
    repMax: repMax ?? this.repMax,
    targetRir: targetRir ?? this.targetRir,
    restSec: restSec ?? this.restSec,
    substitutedFrom: substitutedFrom.present ? substitutedFrom.value : this.substitutedFrom,
    pain: pain ?? this.pain,
    formUnstable: formUnstable ?? this.formUnstable,
    recommendationId: recommendationId.present ? recommendationId.value : this.recommendationId,
  );
  SessionExercise copyWithCompanion(WorkoutSessionExercisesCompanion data) {
    return SessionExercise(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      workoutExerciseId: data.workoutExerciseId.present ? data.workoutExerciseId.value : this.workoutExerciseId,
      exerciseId: data.exerciseId.present ? data.exerciseId.value : this.exerciseId,
      orderIndex: data.orderIndex.present ? data.orderIndex.value : this.orderIndex,
      targetSets: data.targetSets.present ? data.targetSets.value : this.targetSets,
      repMin: data.repMin.present ? data.repMin.value : this.repMin,
      repMax: data.repMax.present ? data.repMax.value : this.repMax,
      targetRir: data.targetRir.present ? data.targetRir.value : this.targetRir,
      restSec: data.restSec.present ? data.restSec.value : this.restSec,
      substitutedFrom: data.substitutedFrom.present ? data.substitutedFrom.value : this.substitutedFrom,
      pain: data.pain.present ? data.pain.value : this.pain,
      formUnstable: data.formUnstable.present ? data.formUnstable.value : this.formUnstable,
      recommendationId: data.recommendationId.present ? data.recommendationId.value : this.recommendationId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionExercise(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('workoutExerciseId: $workoutExerciseId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('targetSets: $targetSets, ')
          ..write('repMin: $repMin, ')
          ..write('repMax: $repMax, ')
          ..write('targetRir: $targetRir, ')
          ..write('restSec: $restSec, ')
          ..write('substitutedFrom: $substitutedFrom, ')
          ..write('pain: $pain, ')
          ..write('formUnstable: $formUnstable, ')
          ..write('recommendationId: $recommendationId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    workoutExerciseId,
    exerciseId,
    orderIndex,
    targetSets,
    repMin,
    repMax,
    targetRir,
    restSec,
    substitutedFrom,
    pain,
    formUnstable,
    recommendationId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionExercise &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.workoutExerciseId == this.workoutExerciseId &&
          other.exerciseId == this.exerciseId &&
          other.orderIndex == this.orderIndex &&
          other.targetSets == this.targetSets &&
          other.repMin == this.repMin &&
          other.repMax == this.repMax &&
          other.targetRir == this.targetRir &&
          other.restSec == this.restSec &&
          other.substitutedFrom == this.substitutedFrom &&
          other.pain == this.pain &&
          other.formUnstable == this.formUnstable &&
          other.recommendationId == this.recommendationId);
}

class WorkoutSessionExercisesCompanion extends UpdateCompanion<SessionExercise> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<int?> workoutExerciseId;
  final Value<String> exerciseId;
  final Value<int> orderIndex;
  final Value<int> targetSets;
  final Value<int> repMin;
  final Value<int> repMax;
  final Value<int> targetRir;
  final Value<int> restSec;
  final Value<String?> substitutedFrom;
  final Value<bool> pain;
  final Value<bool> formUnstable;
  final Value<int?> recommendationId;
  const WorkoutSessionExercisesCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.workoutExerciseId = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.targetSets = const Value.absent(),
    this.repMin = const Value.absent(),
    this.repMax = const Value.absent(),
    this.targetRir = const Value.absent(),
    this.restSec = const Value.absent(),
    this.substitutedFrom = const Value.absent(),
    this.pain = const Value.absent(),
    this.formUnstable = const Value.absent(),
    this.recommendationId = const Value.absent(),
  });
  WorkoutSessionExercisesCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    this.workoutExerciseId = const Value.absent(),
    required String exerciseId,
    required int orderIndex,
    required int targetSets,
    required int repMin,
    required int repMax,
    required int targetRir,
    required int restSec,
    this.substitutedFrom = const Value.absent(),
    this.pain = const Value.absent(),
    this.formUnstable = const Value.absent(),
    this.recommendationId = const Value.absent(),
  }) : sessionId = Value(sessionId),
       exerciseId = Value(exerciseId),
       orderIndex = Value(orderIndex),
       targetSets = Value(targetSets),
       repMin = Value(repMin),
       repMax = Value(repMax),
       targetRir = Value(targetRir),
       restSec = Value(restSec);
  static Insertable<SessionExercise> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<int>? workoutExerciseId,
    Expression<String>? exerciseId,
    Expression<int>? orderIndex,
    Expression<int>? targetSets,
    Expression<int>? repMin,
    Expression<int>? repMax,
    Expression<int>? targetRir,
    Expression<int>? restSec,
    Expression<String>? substitutedFrom,
    Expression<bool>? pain,
    Expression<bool>? formUnstable,
    Expression<int>? recommendationId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (workoutExerciseId != null) 'workout_exercise_id': workoutExerciseId,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (orderIndex != null) 'order_index': orderIndex,
      if (targetSets != null) 'target_sets': targetSets,
      if (repMin != null) 'rep_min': repMin,
      if (repMax != null) 'rep_max': repMax,
      if (targetRir != null) 'target_rir': targetRir,
      if (restSec != null) 'rest_sec': restSec,
      if (substitutedFrom != null) 'substituted_from': substitutedFrom,
      if (pain != null) 'pain': pain,
      if (formUnstable != null) 'form_unstable': formUnstable,
      if (recommendationId != null) 'recommendation_id': recommendationId,
    });
  }

  WorkoutSessionExercisesCompanion copyWith({
    Value<int>? id,
    Value<int>? sessionId,
    Value<int?>? workoutExerciseId,
    Value<String>? exerciseId,
    Value<int>? orderIndex,
    Value<int>? targetSets,
    Value<int>? repMin,
    Value<int>? repMax,
    Value<int>? targetRir,
    Value<int>? restSec,
    Value<String?>? substitutedFrom,
    Value<bool>? pain,
    Value<bool>? formUnstable,
    Value<int?>? recommendationId,
  }) {
    return WorkoutSessionExercisesCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      workoutExerciseId: workoutExerciseId ?? this.workoutExerciseId,
      exerciseId: exerciseId ?? this.exerciseId,
      orderIndex: orderIndex ?? this.orderIndex,
      targetSets: targetSets ?? this.targetSets,
      repMin: repMin ?? this.repMin,
      repMax: repMax ?? this.repMax,
      targetRir: targetRir ?? this.targetRir,
      restSec: restSec ?? this.restSec,
      substitutedFrom: substitutedFrom ?? this.substitutedFrom,
      pain: pain ?? this.pain,
      formUnstable: formUnstable ?? this.formUnstable,
      recommendationId: recommendationId ?? this.recommendationId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (workoutExerciseId.present) {
      map['workout_exercise_id'] = Variable<int>(workoutExerciseId.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (targetSets.present) {
      map['target_sets'] = Variable<int>(targetSets.value);
    }
    if (repMin.present) {
      map['rep_min'] = Variable<int>(repMin.value);
    }
    if (repMax.present) {
      map['rep_max'] = Variable<int>(repMax.value);
    }
    if (targetRir.present) {
      map['target_rir'] = Variable<int>(targetRir.value);
    }
    if (restSec.present) {
      map['rest_sec'] = Variable<int>(restSec.value);
    }
    if (substitutedFrom.present) {
      map['substituted_from'] = Variable<String>(substitutedFrom.value);
    }
    if (pain.present) {
      map['pain'] = Variable<bool>(pain.value);
    }
    if (formUnstable.present) {
      map['form_unstable'] = Variable<bool>(formUnstable.value);
    }
    if (recommendationId.present) {
      map['recommendation_id'] = Variable<int>(recommendationId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSessionExercisesCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('workoutExerciseId: $workoutExerciseId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('targetSets: $targetSets, ')
          ..write('repMin: $repMin, ')
          ..write('repMax: $repMax, ')
          ..write('targetRir: $targetRir, ')
          ..write('restSec: $restSec, ')
          ..write('substitutedFrom: $substitutedFrom, ')
          ..write('pain: $pain, ')
          ..write('formUnstable: $formUnstable, ')
          ..write('recommendationId: $recommendationId')
          ..write(')'))
        .toString();
  }
}

class $WorkoutSetsTable extends WorkoutSets with TableInfo<$WorkoutSetsTable, WorkoutSet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutSetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta('sessionId');
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES workout_sessions (id) ON DELETE CASCADE'),
  );
  static const VerificationMeta _sessionExerciseIdMeta = const VerificationMeta('sessionExerciseId');
  @override
  late final GeneratedColumn<int> sessionExerciseId = GeneratedColumn<int>(
    'session_exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES workout_session_exercises (id) ON DELETE CASCADE'),
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta('exerciseId');
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _setNumberMeta = const VerificationMeta('setNumber');
  @override
  late final GeneratedColumn<int> setNumber = GeneratedColumn<int>('set_number', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _targetWeightMeta = const VerificationMeta('targetWeight');
  @override
  late final GeneratedColumn<double> targetWeight = GeneratedColumn<double>(
    'target_weight',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actualWeightMeta = const VerificationMeta('actualWeight');
  @override
  late final GeneratedColumn<double> actualWeight = GeneratedColumn<double>(
    'actual_weight',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetRepsMeta = const VerificationMeta('targetReps');
  @override
  late final GeneratedColumn<int> targetReps = GeneratedColumn<int>('target_reps', aliasedName, true, type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _actualRepsMeta = const VerificationMeta('actualReps');
  @override
  late final GeneratedColumn<int> actualReps = GeneratedColumn<int>('actual_reps', aliasedName, true, type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _rirMeta = const VerificationMeta('rir');
  @override
  late final GeneratedColumn<int> rir = GeneratedColumn<int>('rir', aliasedName, true, type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _completedMeta = const VerificationMeta('completed');
  @override
  late final GeneratedColumn<bool> completed = GeneratedColumn<bool>(
    'completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("completed" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    sessionExerciseId,
    exerciseId,
    setNumber,
    targetWeight,
    actualWeight,
    targetReps,
    actualReps,
    rir,
    completed,
    completedAt,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_sets';
  @override
  VerificationContext validateIntegrity(Insertable<WorkoutSet> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(_sessionIdMeta, sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta));
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('session_exercise_id')) {
      context.handle(_sessionExerciseIdMeta, sessionExerciseId.isAcceptableOrUnknown(data['session_exercise_id']!, _sessionExerciseIdMeta));
    } else if (isInserting) {
      context.missing(_sessionExerciseIdMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(_exerciseIdMeta, exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta));
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('set_number')) {
      context.handle(_setNumberMeta, setNumber.isAcceptableOrUnknown(data['set_number']!, _setNumberMeta));
    } else if (isInserting) {
      context.missing(_setNumberMeta);
    }
    if (data.containsKey('target_weight')) {
      context.handle(_targetWeightMeta, targetWeight.isAcceptableOrUnknown(data['target_weight']!, _targetWeightMeta));
    }
    if (data.containsKey('actual_weight')) {
      context.handle(_actualWeightMeta, actualWeight.isAcceptableOrUnknown(data['actual_weight']!, _actualWeightMeta));
    }
    if (data.containsKey('target_reps')) {
      context.handle(_targetRepsMeta, targetReps.isAcceptableOrUnknown(data['target_reps']!, _targetRepsMeta));
    }
    if (data.containsKey('actual_reps')) {
      context.handle(_actualRepsMeta, actualReps.isAcceptableOrUnknown(data['actual_reps']!, _actualRepsMeta));
    }
    if (data.containsKey('rir')) {
      context.handle(_rirMeta, rir.isAcceptableOrUnknown(data['rir']!, _rirMeta));
    }
    if (data.containsKey('completed')) {
      context.handle(_completedMeta, completed.isAcceptableOrUnknown(data['completed']!, _completedMeta));
    }
    if (data.containsKey('completed_at')) {
      context.handle(_completedAtMeta, completedAt.isAcceptableOrUnknown(data['completed_at']!, _completedAtMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(_notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {sessionExerciseId, setNumber},
  ];
  @override
  WorkoutSet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutSet(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      sessionId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}session_id'])!,
      sessionExerciseId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}session_exercise_id'])!,
      exerciseId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}exercise_id'])!,
      setNumber: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}set_number'])!,
      targetWeight: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}target_weight']),
      actualWeight: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}actual_weight']),
      targetReps: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}target_reps']),
      actualReps: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}actual_reps']),
      rir: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}rir']),
      completed: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}completed'])!,
      completedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at']),
      notes: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}notes'])!,
    );
  }

  @override
  $WorkoutSetsTable createAlias(String alias) {
    return $WorkoutSetsTable(attachedDatabase, alias);
  }
}

class WorkoutSet extends DataClass implements Insertable<WorkoutSet> {
  final int id;
  final int sessionId;
  final int sessionExerciseId;
  final String exerciseId;
  final int setNumber;
  final double? targetWeight;
  final double? actualWeight;
  final int? targetReps;
  final int? actualReps;
  final int? rir;
  final bool completed;
  final DateTime? completedAt;
  final String notes;
  const WorkoutSet({
    required this.id,
    required this.sessionId,
    required this.sessionExerciseId,
    required this.exerciseId,
    required this.setNumber,
    this.targetWeight,
    this.actualWeight,
    this.targetReps,
    this.actualReps,
    this.rir,
    required this.completed,
    this.completedAt,
    required this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    map['session_exercise_id'] = Variable<int>(sessionExerciseId);
    map['exercise_id'] = Variable<String>(exerciseId);
    map['set_number'] = Variable<int>(setNumber);
    if (!nullToAbsent || targetWeight != null) {
      map['target_weight'] = Variable<double>(targetWeight);
    }
    if (!nullToAbsent || actualWeight != null) {
      map['actual_weight'] = Variable<double>(actualWeight);
    }
    if (!nullToAbsent || targetReps != null) {
      map['target_reps'] = Variable<int>(targetReps);
    }
    if (!nullToAbsent || actualReps != null) {
      map['actual_reps'] = Variable<int>(actualReps);
    }
    if (!nullToAbsent || rir != null) {
      map['rir'] = Variable<int>(rir);
    }
    map['completed'] = Variable<bool>(completed);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['notes'] = Variable<String>(notes);
    return map;
  }

  WorkoutSetsCompanion toCompanion(bool nullToAbsent) {
    return WorkoutSetsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      sessionExerciseId: Value(sessionExerciseId),
      exerciseId: Value(exerciseId),
      setNumber: Value(setNumber),
      targetWeight: targetWeight == null && nullToAbsent ? const Value.absent() : Value(targetWeight),
      actualWeight: actualWeight == null && nullToAbsent ? const Value.absent() : Value(actualWeight),
      targetReps: targetReps == null && nullToAbsent ? const Value.absent() : Value(targetReps),
      actualReps: actualReps == null && nullToAbsent ? const Value.absent() : Value(actualReps),
      rir: rir == null && nullToAbsent ? const Value.absent() : Value(rir),
      completed: Value(completed),
      completedAt: completedAt == null && nullToAbsent ? const Value.absent() : Value(completedAt),
      notes: Value(notes),
    );
  }

  factory WorkoutSet.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutSet(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      sessionExerciseId: serializer.fromJson<int>(json['sessionExerciseId']),
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      setNumber: serializer.fromJson<int>(json['setNumber']),
      targetWeight: serializer.fromJson<double?>(json['targetWeight']),
      actualWeight: serializer.fromJson<double?>(json['actualWeight']),
      targetReps: serializer.fromJson<int?>(json['targetReps']),
      actualReps: serializer.fromJson<int?>(json['actualReps']),
      rir: serializer.fromJson<int?>(json['rir']),
      completed: serializer.fromJson<bool>(json['completed']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      notes: serializer.fromJson<String>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'sessionExerciseId': serializer.toJson<int>(sessionExerciseId),
      'exerciseId': serializer.toJson<String>(exerciseId),
      'setNumber': serializer.toJson<int>(setNumber),
      'targetWeight': serializer.toJson<double?>(targetWeight),
      'actualWeight': serializer.toJson<double?>(actualWeight),
      'targetReps': serializer.toJson<int?>(targetReps),
      'actualReps': serializer.toJson<int?>(actualReps),
      'rir': serializer.toJson<int?>(rir),
      'completed': serializer.toJson<bool>(completed),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'notes': serializer.toJson<String>(notes),
    };
  }

  WorkoutSet copyWith({
    int? id,
    int? sessionId,
    int? sessionExerciseId,
    String? exerciseId,
    int? setNumber,
    Value<double?> targetWeight = const Value.absent(),
    Value<double?> actualWeight = const Value.absent(),
    Value<int?> targetReps = const Value.absent(),
    Value<int?> actualReps = const Value.absent(),
    Value<int?> rir = const Value.absent(),
    bool? completed,
    Value<DateTime?> completedAt = const Value.absent(),
    String? notes,
  }) => WorkoutSet(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    sessionExerciseId: sessionExerciseId ?? this.sessionExerciseId,
    exerciseId: exerciseId ?? this.exerciseId,
    setNumber: setNumber ?? this.setNumber,
    targetWeight: targetWeight.present ? targetWeight.value : this.targetWeight,
    actualWeight: actualWeight.present ? actualWeight.value : this.actualWeight,
    targetReps: targetReps.present ? targetReps.value : this.targetReps,
    actualReps: actualReps.present ? actualReps.value : this.actualReps,
    rir: rir.present ? rir.value : this.rir,
    completed: completed ?? this.completed,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    notes: notes ?? this.notes,
  );
  WorkoutSet copyWithCompanion(WorkoutSetsCompanion data) {
    return WorkoutSet(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      sessionExerciseId: data.sessionExerciseId.present ? data.sessionExerciseId.value : this.sessionExerciseId,
      exerciseId: data.exerciseId.present ? data.exerciseId.value : this.exerciseId,
      setNumber: data.setNumber.present ? data.setNumber.value : this.setNumber,
      targetWeight: data.targetWeight.present ? data.targetWeight.value : this.targetWeight,
      actualWeight: data.actualWeight.present ? data.actualWeight.value : this.actualWeight,
      targetReps: data.targetReps.present ? data.targetReps.value : this.targetReps,
      actualReps: data.actualReps.present ? data.actualReps.value : this.actualReps,
      rir: data.rir.present ? data.rir.value : this.rir,
      completed: data.completed.present ? data.completed.value : this.completed,
      completedAt: data.completedAt.present ? data.completedAt.value : this.completedAt,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSet(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('sessionExerciseId: $sessionExerciseId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('setNumber: $setNumber, ')
          ..write('targetWeight: $targetWeight, ')
          ..write('actualWeight: $actualWeight, ')
          ..write('targetReps: $targetReps, ')
          ..write('actualReps: $actualReps, ')
          ..write('rir: $rir, ')
          ..write('completed: $completed, ')
          ..write('completedAt: $completedAt, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    sessionExerciseId,
    exerciseId,
    setNumber,
    targetWeight,
    actualWeight,
    targetReps,
    actualReps,
    rir,
    completed,
    completedAt,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutSet &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.sessionExerciseId == this.sessionExerciseId &&
          other.exerciseId == this.exerciseId &&
          other.setNumber == this.setNumber &&
          other.targetWeight == this.targetWeight &&
          other.actualWeight == this.actualWeight &&
          other.targetReps == this.targetReps &&
          other.actualReps == this.actualReps &&
          other.rir == this.rir &&
          other.completed == this.completed &&
          other.completedAt == this.completedAt &&
          other.notes == this.notes);
}

class WorkoutSetsCompanion extends UpdateCompanion<WorkoutSet> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<int> sessionExerciseId;
  final Value<String> exerciseId;
  final Value<int> setNumber;
  final Value<double?> targetWeight;
  final Value<double?> actualWeight;
  final Value<int?> targetReps;
  final Value<int?> actualReps;
  final Value<int?> rir;
  final Value<bool> completed;
  final Value<DateTime?> completedAt;
  final Value<String> notes;
  const WorkoutSetsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.sessionExerciseId = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.setNumber = const Value.absent(),
    this.targetWeight = const Value.absent(),
    this.actualWeight = const Value.absent(),
    this.targetReps = const Value.absent(),
    this.actualReps = const Value.absent(),
    this.rir = const Value.absent(),
    this.completed = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.notes = const Value.absent(),
  });
  WorkoutSetsCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    required int sessionExerciseId,
    required String exerciseId,
    required int setNumber,
    this.targetWeight = const Value.absent(),
    this.actualWeight = const Value.absent(),
    this.targetReps = const Value.absent(),
    this.actualReps = const Value.absent(),
    this.rir = const Value.absent(),
    this.completed = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.notes = const Value.absent(),
  }) : sessionId = Value(sessionId),
       sessionExerciseId = Value(sessionExerciseId),
       exerciseId = Value(exerciseId),
       setNumber = Value(setNumber);
  static Insertable<WorkoutSet> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<int>? sessionExerciseId,
    Expression<String>? exerciseId,
    Expression<int>? setNumber,
    Expression<double>? targetWeight,
    Expression<double>? actualWeight,
    Expression<int>? targetReps,
    Expression<int>? actualReps,
    Expression<int>? rir,
    Expression<bool>? completed,
    Expression<DateTime>? completedAt,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (sessionExerciseId != null) 'session_exercise_id': sessionExerciseId,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (setNumber != null) 'set_number': setNumber,
      if (targetWeight != null) 'target_weight': targetWeight,
      if (actualWeight != null) 'actual_weight': actualWeight,
      if (targetReps != null) 'target_reps': targetReps,
      if (actualReps != null) 'actual_reps': actualReps,
      if (rir != null) 'rir': rir,
      if (completed != null) 'completed': completed,
      if (completedAt != null) 'completed_at': completedAt,
      if (notes != null) 'notes': notes,
    });
  }

  WorkoutSetsCompanion copyWith({
    Value<int>? id,
    Value<int>? sessionId,
    Value<int>? sessionExerciseId,
    Value<String>? exerciseId,
    Value<int>? setNumber,
    Value<double?>? targetWeight,
    Value<double?>? actualWeight,
    Value<int?>? targetReps,
    Value<int?>? actualReps,
    Value<int?>? rir,
    Value<bool>? completed,
    Value<DateTime?>? completedAt,
    Value<String>? notes,
  }) {
    return WorkoutSetsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      sessionExerciseId: sessionExerciseId ?? this.sessionExerciseId,
      exerciseId: exerciseId ?? this.exerciseId,
      setNumber: setNumber ?? this.setNumber,
      targetWeight: targetWeight ?? this.targetWeight,
      actualWeight: actualWeight ?? this.actualWeight,
      targetReps: targetReps ?? this.targetReps,
      actualReps: actualReps ?? this.actualReps,
      rir: rir ?? this.rir,
      completed: completed ?? this.completed,
      completedAt: completedAt ?? this.completedAt,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (sessionExerciseId.present) {
      map['session_exercise_id'] = Variable<int>(sessionExerciseId.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (setNumber.present) {
      map['set_number'] = Variable<int>(setNumber.value);
    }
    if (targetWeight.present) {
      map['target_weight'] = Variable<double>(targetWeight.value);
    }
    if (actualWeight.present) {
      map['actual_weight'] = Variable<double>(actualWeight.value);
    }
    if (targetReps.present) {
      map['target_reps'] = Variable<int>(targetReps.value);
    }
    if (actualReps.present) {
      map['actual_reps'] = Variable<int>(actualReps.value);
    }
    if (rir.present) {
      map['rir'] = Variable<int>(rir.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSetsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('sessionExerciseId: $sessionExerciseId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('setNumber: $setNumber, ')
          ..write('targetWeight: $targetWeight, ')
          ..write('actualWeight: $actualWeight, ')
          ..write('targetReps: $targetReps, ')
          ..write('actualReps: $actualReps, ')
          ..write('rir: $rir, ')
          ..write('completed: $completed, ')
          ..write('completedAt: $completedAt, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $BodyMeasurementsTable extends BodyMeasurements with TableInfo<$BodyMeasurementsTable, BodyMeasurement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BodyMeasurementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>('date', aliasedName, false, type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _weightKgMeta = const VerificationMeta('weightKg');
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>('weight_kg', aliasedName, true, type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _bodyFatPctMeta = const VerificationMeta('bodyFatPct');
  @override
  late final GeneratedColumn<double> bodyFatPct = GeneratedColumn<double>(
    'body_fat_pct',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _skeletalMuscleKgMeta = const VerificationMeta('skeletalMuscleKg');
  @override
  late final GeneratedColumn<double> skeletalMuscleKg = GeneratedColumn<double>(
    'skeletal_muscle_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _waistCmMeta = const VerificationMeta('waistCm');
  @override
  late final GeneratedColumn<double> waistCm = GeneratedColumn<double>('waist_cm', aliasedName, true, type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [id, date, weightKg, bodyFatPct, skeletalMuscleKg, waistCm, notes];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'body_measurements';
  @override
  VerificationContext validateIntegrity(Insertable<BodyMeasurement> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(_dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('weight_kg')) {
      context.handle(_weightKgMeta, weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta));
    }
    if (data.containsKey('body_fat_pct')) {
      context.handle(_bodyFatPctMeta, bodyFatPct.isAcceptableOrUnknown(data['body_fat_pct']!, _bodyFatPctMeta));
    }
    if (data.containsKey('skeletal_muscle_kg')) {
      context.handle(_skeletalMuscleKgMeta, skeletalMuscleKg.isAcceptableOrUnknown(data['skeletal_muscle_kg']!, _skeletalMuscleKgMeta));
    }
    if (data.containsKey('waist_cm')) {
      context.handle(_waistCmMeta, waistCm.isAcceptableOrUnknown(data['waist_cm']!, _waistCmMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(_notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BodyMeasurement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BodyMeasurement(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      date: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      weightKg: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}weight_kg']),
      bodyFatPct: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}body_fat_pct']),
      skeletalMuscleKg: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}skeletal_muscle_kg']),
      waistCm: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}waist_cm']),
      notes: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}notes'])!,
    );
  }

  @override
  $BodyMeasurementsTable createAlias(String alias) {
    return $BodyMeasurementsTable(attachedDatabase, alias);
  }
}

class BodyMeasurement extends DataClass implements Insertable<BodyMeasurement> {
  final int id;
  final DateTime date;
  final double? weightKg;
  final double? bodyFatPct;
  final double? skeletalMuscleKg;
  final double? waistCm;
  final String notes;
  const BodyMeasurement({required this.id, required this.date, this.weightKg, this.bodyFatPct, this.skeletalMuscleKg, this.waistCm, required this.notes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || weightKg != null) {
      map['weight_kg'] = Variable<double>(weightKg);
    }
    if (!nullToAbsent || bodyFatPct != null) {
      map['body_fat_pct'] = Variable<double>(bodyFatPct);
    }
    if (!nullToAbsent || skeletalMuscleKg != null) {
      map['skeletal_muscle_kg'] = Variable<double>(skeletalMuscleKg);
    }
    if (!nullToAbsent || waistCm != null) {
      map['waist_cm'] = Variable<double>(waistCm);
    }
    map['notes'] = Variable<String>(notes);
    return map;
  }

  BodyMeasurementsCompanion toCompanion(bool nullToAbsent) {
    return BodyMeasurementsCompanion(
      id: Value(id),
      date: Value(date),
      weightKg: weightKg == null && nullToAbsent ? const Value.absent() : Value(weightKg),
      bodyFatPct: bodyFatPct == null && nullToAbsent ? const Value.absent() : Value(bodyFatPct),
      skeletalMuscleKg: skeletalMuscleKg == null && nullToAbsent ? const Value.absent() : Value(skeletalMuscleKg),
      waistCm: waistCm == null && nullToAbsent ? const Value.absent() : Value(waistCm),
      notes: Value(notes),
    );
  }

  factory BodyMeasurement.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BodyMeasurement(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      weightKg: serializer.fromJson<double?>(json['weightKg']),
      bodyFatPct: serializer.fromJson<double?>(json['bodyFatPct']),
      skeletalMuscleKg: serializer.fromJson<double?>(json['skeletalMuscleKg']),
      waistCm: serializer.fromJson<double?>(json['waistCm']),
      notes: serializer.fromJson<String>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'weightKg': serializer.toJson<double?>(weightKg),
      'bodyFatPct': serializer.toJson<double?>(bodyFatPct),
      'skeletalMuscleKg': serializer.toJson<double?>(skeletalMuscleKg),
      'waistCm': serializer.toJson<double?>(waistCm),
      'notes': serializer.toJson<String>(notes),
    };
  }

  BodyMeasurement copyWith({
    int? id,
    DateTime? date,
    Value<double?> weightKg = const Value.absent(),
    Value<double?> bodyFatPct = const Value.absent(),
    Value<double?> skeletalMuscleKg = const Value.absent(),
    Value<double?> waistCm = const Value.absent(),
    String? notes,
  }) => BodyMeasurement(
    id: id ?? this.id,
    date: date ?? this.date,
    weightKg: weightKg.present ? weightKg.value : this.weightKg,
    bodyFatPct: bodyFatPct.present ? bodyFatPct.value : this.bodyFatPct,
    skeletalMuscleKg: skeletalMuscleKg.present ? skeletalMuscleKg.value : this.skeletalMuscleKg,
    waistCm: waistCm.present ? waistCm.value : this.waistCm,
    notes: notes ?? this.notes,
  );
  BodyMeasurement copyWithCompanion(BodyMeasurementsCompanion data) {
    return BodyMeasurement(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      bodyFatPct: data.bodyFatPct.present ? data.bodyFatPct.value : this.bodyFatPct,
      skeletalMuscleKg: data.skeletalMuscleKg.present ? data.skeletalMuscleKg.value : this.skeletalMuscleKg,
      waistCm: data.waistCm.present ? data.waistCm.value : this.waistCm,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BodyMeasurement(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('weightKg: $weightKg, ')
          ..write('bodyFatPct: $bodyFatPct, ')
          ..write('skeletalMuscleKg: $skeletalMuscleKg, ')
          ..write('waistCm: $waistCm, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, weightKg, bodyFatPct, skeletalMuscleKg, waistCm, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BodyMeasurement &&
          other.id == this.id &&
          other.date == this.date &&
          other.weightKg == this.weightKg &&
          other.bodyFatPct == this.bodyFatPct &&
          other.skeletalMuscleKg == this.skeletalMuscleKg &&
          other.waistCm == this.waistCm &&
          other.notes == this.notes);
}

class BodyMeasurementsCompanion extends UpdateCompanion<BodyMeasurement> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<double?> weightKg;
  final Value<double?> bodyFatPct;
  final Value<double?> skeletalMuscleKg;
  final Value<double?> waistCm;
  final Value<String> notes;
  const BodyMeasurementsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.bodyFatPct = const Value.absent(),
    this.skeletalMuscleKg = const Value.absent(),
    this.waistCm = const Value.absent(),
    this.notes = const Value.absent(),
  });
  BodyMeasurementsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    this.weightKg = const Value.absent(),
    this.bodyFatPct = const Value.absent(),
    this.skeletalMuscleKg = const Value.absent(),
    this.waistCm = const Value.absent(),
    this.notes = const Value.absent(),
  }) : date = Value(date);
  static Insertable<BodyMeasurement> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<double>? weightKg,
    Expression<double>? bodyFatPct,
    Expression<double>? skeletalMuscleKg,
    Expression<double>? waistCm,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (weightKg != null) 'weight_kg': weightKg,
      if (bodyFatPct != null) 'body_fat_pct': bodyFatPct,
      if (skeletalMuscleKg != null) 'skeletal_muscle_kg': skeletalMuscleKg,
      if (waistCm != null) 'waist_cm': waistCm,
      if (notes != null) 'notes': notes,
    });
  }

  BodyMeasurementsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? date,
    Value<double?>? weightKg,
    Value<double?>? bodyFatPct,
    Value<double?>? skeletalMuscleKg,
    Value<double?>? waistCm,
    Value<String>? notes,
  }) {
    return BodyMeasurementsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      weightKg: weightKg ?? this.weightKg,
      bodyFatPct: bodyFatPct ?? this.bodyFatPct,
      skeletalMuscleKg: skeletalMuscleKg ?? this.skeletalMuscleKg,
      waistCm: waistCm ?? this.waistCm,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (bodyFatPct.present) {
      map['body_fat_pct'] = Variable<double>(bodyFatPct.value);
    }
    if (skeletalMuscleKg.present) {
      map['skeletal_muscle_kg'] = Variable<double>(skeletalMuscleKg.value);
    }
    if (waistCm.present) {
      map['waist_cm'] = Variable<double>(waistCm.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BodyMeasurementsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('weightKg: $weightKg, ')
          ..write('bodyFatPct: $bodyFatPct, ')
          ..write('skeletalMuscleKg: $skeletalMuscleKg, ')
          ..write('waistCm: $waistCm, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $RecoveryLogsTable extends RecoveryLogs with TableInfo<$RecoveryLogsTable, RecoveryLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecoveryLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>('date', aliasedName, false, type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _sleepHoursMeta = const VerificationMeta('sleepHours');
  @override
  late final GeneratedColumn<double> sleepHours = GeneratedColumn<double>(
    'sleep_hours',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fatigueMeta = const VerificationMeta('fatigue');
  @override
  late final GeneratedColumn<int> fatigue = GeneratedColumn<int>('fatigue', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _sorenessMeta = const VerificationMeta('soreness');
  @override
  late final GeneratedColumn<int> soreness = GeneratedColumn<int>('soreness', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _motivationMeta = const VerificationMeta('motivation');
  @override
  late final GeneratedColumn<int> motivation = GeneratedColumn<int>('motivation', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _jointPainMeta = const VerificationMeta('jointPain');
  @override
  late final GeneratedColumn<bool> jointPain = GeneratedColumn<bool>(
    'joint_pain',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("joint_pain" IN (0, 1))'),
  );
  static const VerificationMeta _painAreaMeta = const VerificationMeta('painArea');
  @override
  late final GeneratedColumn<String> painArea = GeneratedColumn<String>('pain_area', aliasedName, true, type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<int> score = GeneratedColumn<int>('score', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _readinessMeta = const VerificationMeta('readiness');
  @override
  late final GeneratedColumn<String> readiness = GeneratedColumn<String>(
    'readiness',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta('sessionId');
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>('session_id', aliasedName, true, type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, date, sleepHours, fatigue, soreness, motivation, jointPain, painArea, score, readiness, sessionId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recovery_logs';
  @override
  VerificationContext validateIntegrity(Insertable<RecoveryLog> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(_dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('sleep_hours')) {
      context.handle(_sleepHoursMeta, sleepHours.isAcceptableOrUnknown(data['sleep_hours']!, _sleepHoursMeta));
    } else if (isInserting) {
      context.missing(_sleepHoursMeta);
    }
    if (data.containsKey('fatigue')) {
      context.handle(_fatigueMeta, fatigue.isAcceptableOrUnknown(data['fatigue']!, _fatigueMeta));
    } else if (isInserting) {
      context.missing(_fatigueMeta);
    }
    if (data.containsKey('soreness')) {
      context.handle(_sorenessMeta, soreness.isAcceptableOrUnknown(data['soreness']!, _sorenessMeta));
    } else if (isInserting) {
      context.missing(_sorenessMeta);
    }
    if (data.containsKey('motivation')) {
      context.handle(_motivationMeta, motivation.isAcceptableOrUnknown(data['motivation']!, _motivationMeta));
    } else if (isInserting) {
      context.missing(_motivationMeta);
    }
    if (data.containsKey('joint_pain')) {
      context.handle(_jointPainMeta, jointPain.isAcceptableOrUnknown(data['joint_pain']!, _jointPainMeta));
    } else if (isInserting) {
      context.missing(_jointPainMeta);
    }
    if (data.containsKey('pain_area')) {
      context.handle(_painAreaMeta, painArea.isAcceptableOrUnknown(data['pain_area']!, _painAreaMeta));
    }
    if (data.containsKey('score')) {
      context.handle(_scoreMeta, score.isAcceptableOrUnknown(data['score']!, _scoreMeta));
    } else if (isInserting) {
      context.missing(_scoreMeta);
    }
    if (data.containsKey('readiness')) {
      context.handle(_readinessMeta, readiness.isAcceptableOrUnknown(data['readiness']!, _readinessMeta));
    } else if (isInserting) {
      context.missing(_readinessMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(_sessionIdMeta, sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecoveryLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecoveryLog(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      date: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      sleepHours: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}sleep_hours'])!,
      fatigue: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}fatigue'])!,
      soreness: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}soreness'])!,
      motivation: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}motivation'])!,
      jointPain: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}joint_pain'])!,
      painArea: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}pain_area']),
      score: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}score'])!,
      readiness: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}readiness'])!,
      sessionId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}session_id']),
    );
  }

  @override
  $RecoveryLogsTable createAlias(String alias) {
    return $RecoveryLogsTable(attachedDatabase, alias);
  }
}

class RecoveryLog extends DataClass implements Insertable<RecoveryLog> {
  final int id;
  final DateTime date;
  final double sleepHours;
  final int fatigue;
  final int soreness;
  final int motivation;
  final bool jointPain;
  final String? painArea;
  final int score;
  final String readiness;
  final int? sessionId;
  const RecoveryLog({
    required this.id,
    required this.date,
    required this.sleepHours,
    required this.fatigue,
    required this.soreness,
    required this.motivation,
    required this.jointPain,
    this.painArea,
    required this.score,
    required this.readiness,
    this.sessionId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    map['sleep_hours'] = Variable<double>(sleepHours);
    map['fatigue'] = Variable<int>(fatigue);
    map['soreness'] = Variable<int>(soreness);
    map['motivation'] = Variable<int>(motivation);
    map['joint_pain'] = Variable<bool>(jointPain);
    if (!nullToAbsent || painArea != null) {
      map['pain_area'] = Variable<String>(painArea);
    }
    map['score'] = Variable<int>(score);
    map['readiness'] = Variable<String>(readiness);
    if (!nullToAbsent || sessionId != null) {
      map['session_id'] = Variable<int>(sessionId);
    }
    return map;
  }

  RecoveryLogsCompanion toCompanion(bool nullToAbsent) {
    return RecoveryLogsCompanion(
      id: Value(id),
      date: Value(date),
      sleepHours: Value(sleepHours),
      fatigue: Value(fatigue),
      soreness: Value(soreness),
      motivation: Value(motivation),
      jointPain: Value(jointPain),
      painArea: painArea == null && nullToAbsent ? const Value.absent() : Value(painArea),
      score: Value(score),
      readiness: Value(readiness),
      sessionId: sessionId == null && nullToAbsent ? const Value.absent() : Value(sessionId),
    );
  }

  factory RecoveryLog.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecoveryLog(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      sleepHours: serializer.fromJson<double>(json['sleepHours']),
      fatigue: serializer.fromJson<int>(json['fatigue']),
      soreness: serializer.fromJson<int>(json['soreness']),
      motivation: serializer.fromJson<int>(json['motivation']),
      jointPain: serializer.fromJson<bool>(json['jointPain']),
      painArea: serializer.fromJson<String?>(json['painArea']),
      score: serializer.fromJson<int>(json['score']),
      readiness: serializer.fromJson<String>(json['readiness']),
      sessionId: serializer.fromJson<int?>(json['sessionId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'sleepHours': serializer.toJson<double>(sleepHours),
      'fatigue': serializer.toJson<int>(fatigue),
      'soreness': serializer.toJson<int>(soreness),
      'motivation': serializer.toJson<int>(motivation),
      'jointPain': serializer.toJson<bool>(jointPain),
      'painArea': serializer.toJson<String?>(painArea),
      'score': serializer.toJson<int>(score),
      'readiness': serializer.toJson<String>(readiness),
      'sessionId': serializer.toJson<int?>(sessionId),
    };
  }

  RecoveryLog copyWith({
    int? id,
    DateTime? date,
    double? sleepHours,
    int? fatigue,
    int? soreness,
    int? motivation,
    bool? jointPain,
    Value<String?> painArea = const Value.absent(),
    int? score,
    String? readiness,
    Value<int?> sessionId = const Value.absent(),
  }) => RecoveryLog(
    id: id ?? this.id,
    date: date ?? this.date,
    sleepHours: sleepHours ?? this.sleepHours,
    fatigue: fatigue ?? this.fatigue,
    soreness: soreness ?? this.soreness,
    motivation: motivation ?? this.motivation,
    jointPain: jointPain ?? this.jointPain,
    painArea: painArea.present ? painArea.value : this.painArea,
    score: score ?? this.score,
    readiness: readiness ?? this.readiness,
    sessionId: sessionId.present ? sessionId.value : this.sessionId,
  );
  RecoveryLog copyWithCompanion(RecoveryLogsCompanion data) {
    return RecoveryLog(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      sleepHours: data.sleepHours.present ? data.sleepHours.value : this.sleepHours,
      fatigue: data.fatigue.present ? data.fatigue.value : this.fatigue,
      soreness: data.soreness.present ? data.soreness.value : this.soreness,
      motivation: data.motivation.present ? data.motivation.value : this.motivation,
      jointPain: data.jointPain.present ? data.jointPain.value : this.jointPain,
      painArea: data.painArea.present ? data.painArea.value : this.painArea,
      score: data.score.present ? data.score.value : this.score,
      readiness: data.readiness.present ? data.readiness.value : this.readiness,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecoveryLog(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('sleepHours: $sleepHours, ')
          ..write('fatigue: $fatigue, ')
          ..write('soreness: $soreness, ')
          ..write('motivation: $motivation, ')
          ..write('jointPain: $jointPain, ')
          ..write('painArea: $painArea, ')
          ..write('score: $score, ')
          ..write('readiness: $readiness, ')
          ..write('sessionId: $sessionId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, sleepHours, fatigue, soreness, motivation, jointPain, painArea, score, readiness, sessionId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecoveryLog &&
          other.id == this.id &&
          other.date == this.date &&
          other.sleepHours == this.sleepHours &&
          other.fatigue == this.fatigue &&
          other.soreness == this.soreness &&
          other.motivation == this.motivation &&
          other.jointPain == this.jointPain &&
          other.painArea == this.painArea &&
          other.score == this.score &&
          other.readiness == this.readiness &&
          other.sessionId == this.sessionId);
}

class RecoveryLogsCompanion extends UpdateCompanion<RecoveryLog> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<double> sleepHours;
  final Value<int> fatigue;
  final Value<int> soreness;
  final Value<int> motivation;
  final Value<bool> jointPain;
  final Value<String?> painArea;
  final Value<int> score;
  final Value<String> readiness;
  final Value<int?> sessionId;
  const RecoveryLogsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.sleepHours = const Value.absent(),
    this.fatigue = const Value.absent(),
    this.soreness = const Value.absent(),
    this.motivation = const Value.absent(),
    this.jointPain = const Value.absent(),
    this.painArea = const Value.absent(),
    this.score = const Value.absent(),
    this.readiness = const Value.absent(),
    this.sessionId = const Value.absent(),
  });
  RecoveryLogsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    required double sleepHours,
    required int fatigue,
    required int soreness,
    required int motivation,
    required bool jointPain,
    this.painArea = const Value.absent(),
    required int score,
    required String readiness,
    this.sessionId = const Value.absent(),
  }) : date = Value(date),
       sleepHours = Value(sleepHours),
       fatigue = Value(fatigue),
       soreness = Value(soreness),
       motivation = Value(motivation),
       jointPain = Value(jointPain),
       score = Value(score),
       readiness = Value(readiness);
  static Insertable<RecoveryLog> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<double>? sleepHours,
    Expression<int>? fatigue,
    Expression<int>? soreness,
    Expression<int>? motivation,
    Expression<bool>? jointPain,
    Expression<String>? painArea,
    Expression<int>? score,
    Expression<String>? readiness,
    Expression<int>? sessionId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (sleepHours != null) 'sleep_hours': sleepHours,
      if (fatigue != null) 'fatigue': fatigue,
      if (soreness != null) 'soreness': soreness,
      if (motivation != null) 'motivation': motivation,
      if (jointPain != null) 'joint_pain': jointPain,
      if (painArea != null) 'pain_area': painArea,
      if (score != null) 'score': score,
      if (readiness != null) 'readiness': readiness,
      if (sessionId != null) 'session_id': sessionId,
    });
  }

  RecoveryLogsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? date,
    Value<double>? sleepHours,
    Value<int>? fatigue,
    Value<int>? soreness,
    Value<int>? motivation,
    Value<bool>? jointPain,
    Value<String?>? painArea,
    Value<int>? score,
    Value<String>? readiness,
    Value<int?>? sessionId,
  }) {
    return RecoveryLogsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      sleepHours: sleepHours ?? this.sleepHours,
      fatigue: fatigue ?? this.fatigue,
      soreness: soreness ?? this.soreness,
      motivation: motivation ?? this.motivation,
      jointPain: jointPain ?? this.jointPain,
      painArea: painArea ?? this.painArea,
      score: score ?? this.score,
      readiness: readiness ?? this.readiness,
      sessionId: sessionId ?? this.sessionId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (sleepHours.present) {
      map['sleep_hours'] = Variable<double>(sleepHours.value);
    }
    if (fatigue.present) {
      map['fatigue'] = Variable<int>(fatigue.value);
    }
    if (soreness.present) {
      map['soreness'] = Variable<int>(soreness.value);
    }
    if (motivation.present) {
      map['motivation'] = Variable<int>(motivation.value);
    }
    if (jointPain.present) {
      map['joint_pain'] = Variable<bool>(jointPain.value);
    }
    if (painArea.present) {
      map['pain_area'] = Variable<String>(painArea.value);
    }
    if (score.present) {
      map['score'] = Variable<int>(score.value);
    }
    if (readiness.present) {
      map['readiness'] = Variable<String>(readiness.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecoveryLogsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('sleepHours: $sleepHours, ')
          ..write('fatigue: $fatigue, ')
          ..write('soreness: $soreness, ')
          ..write('motivation: $motivation, ')
          ..write('jointPain: $jointPain, ')
          ..write('painArea: $painArea, ')
          ..write('score: $score, ')
          ..write('readiness: $readiness, ')
          ..write('sessionId: $sessionId')
          ..write(')'))
        .toString();
  }
}

class $ProgressionRecommendationsTable extends ProgressionRecommendations with TableInfo<$ProgressionRecommendationsTable, ProgressionRecommendationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProgressionRecommendationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>('user_id', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta('exerciseId');
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta('sessionId');
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>('session_id', aliasedName, true, type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _previousWeightMeta = const VerificationMeta('previousWeight');
  @override
  late final GeneratedColumn<double> previousWeight = GeneratedColumn<double>(
    'previous_weight',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recommendedWeightMeta = const VerificationMeta('recommendedWeight');
  @override
  late final GeneratedColumn<double> recommendedWeight = GeneratedColumn<double>(
    'recommended_weight',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recommendedRepsMeta = const VerificationMeta('recommendedReps');
  @override
  late final GeneratedColumn<String> recommendedReps = GeneratedColumn<String>(
    'recommended_reps',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recommendedSetsMeta = const VerificationMeta('recommendedSets');
  @override
  late final GeneratedColumn<int> recommendedSets = GeneratedColumn<int>(
    'recommended_sets',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>('action', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>('reason', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _confidenceLevelMeta = const VerificationMeta('confidenceLevel');
  @override
  late final GeneratedColumn<String> confidenceLevel = GeneratedColumn<String>(
    'confidence_level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _acceptedMeta = const VerificationMeta('accepted');
  @override
  late final GeneratedColumn<bool> accepted = GeneratedColumn<bool>(
    'accepted',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("accepted" IN (0, 1))'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    exerciseId,
    sessionId,
    previousWeight,
    recommendedWeight,
    recommendedReps,
    recommendedSets,
    action,
    reason,
    confidenceLevel,
    createdAt,
    accepted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'progression_recommendations';
  @override
  VerificationContext validateIntegrity(Insertable<ProgressionRecommendationRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta, userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(_exerciseIdMeta, exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta));
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(_sessionIdMeta, sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta));
    }
    if (data.containsKey('previous_weight')) {
      context.handle(_previousWeightMeta, previousWeight.isAcceptableOrUnknown(data['previous_weight']!, _previousWeightMeta));
    }
    if (data.containsKey('recommended_weight')) {
      context.handle(_recommendedWeightMeta, recommendedWeight.isAcceptableOrUnknown(data['recommended_weight']!, _recommendedWeightMeta));
    }
    if (data.containsKey('recommended_reps')) {
      context.handle(_recommendedRepsMeta, recommendedReps.isAcceptableOrUnknown(data['recommended_reps']!, _recommendedRepsMeta));
    } else if (isInserting) {
      context.missing(_recommendedRepsMeta);
    }
    if (data.containsKey('recommended_sets')) {
      context.handle(_recommendedSetsMeta, recommendedSets.isAcceptableOrUnknown(data['recommended_sets']!, _recommendedSetsMeta));
    } else if (isInserting) {
      context.missing(_recommendedSetsMeta);
    }
    if (data.containsKey('action')) {
      context.handle(_actionMeta, action.isAcceptableOrUnknown(data['action']!, _actionMeta));
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(_reasonMeta, reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta));
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('confidence_level')) {
      context.handle(_confidenceLevelMeta, confidenceLevel.isAcceptableOrUnknown(data['confidence_level']!, _confidenceLevelMeta));
    } else if (isInserting) {
      context.missing(_confidenceLevelMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('accepted')) {
      context.handle(_acceptedMeta, accepted.isAcceptableOrUnknown(data['accepted']!, _acceptedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProgressionRecommendationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProgressionRecommendationRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}user_id'])!,
      exerciseId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}exercise_id'])!,
      sessionId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}session_id']),
      previousWeight: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}previous_weight']),
      recommendedWeight: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}recommended_weight']),
      recommendedReps: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}recommended_reps'])!,
      recommendedSets: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}recommended_sets'])!,
      action: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}action'])!,
      reason: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}reason'])!,
      confidenceLevel: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}confidence_level'])!,
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      accepted: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}accepted']),
    );
  }

  @override
  $ProgressionRecommendationsTable createAlias(String alias) {
    return $ProgressionRecommendationsTable(attachedDatabase, alias);
  }
}

class ProgressionRecommendationRow extends DataClass implements Insertable<ProgressionRecommendationRow> {
  final int id;
  final int userId;
  final String exerciseId;
  final int? sessionId;
  final double? previousWeight;
  final double? recommendedWeight;
  final String recommendedReps;
  final int recommendedSets;
  final String action;
  final String reason;
  final String confidenceLevel;
  final DateTime createdAt;
  final bool? accepted;
  const ProgressionRecommendationRow({
    required this.id,
    required this.userId,
    required this.exerciseId,
    this.sessionId,
    this.previousWeight,
    this.recommendedWeight,
    required this.recommendedReps,
    required this.recommendedSets,
    required this.action,
    required this.reason,
    required this.confidenceLevel,
    required this.createdAt,
    this.accepted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<int>(userId);
    map['exercise_id'] = Variable<String>(exerciseId);
    if (!nullToAbsent || sessionId != null) {
      map['session_id'] = Variable<int>(sessionId);
    }
    if (!nullToAbsent || previousWeight != null) {
      map['previous_weight'] = Variable<double>(previousWeight);
    }
    if (!nullToAbsent || recommendedWeight != null) {
      map['recommended_weight'] = Variable<double>(recommendedWeight);
    }
    map['recommended_reps'] = Variable<String>(recommendedReps);
    map['recommended_sets'] = Variable<int>(recommendedSets);
    map['action'] = Variable<String>(action);
    map['reason'] = Variable<String>(reason);
    map['confidence_level'] = Variable<String>(confidenceLevel);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || accepted != null) {
      map['accepted'] = Variable<bool>(accepted);
    }
    return map;
  }

  ProgressionRecommendationsCompanion toCompanion(bool nullToAbsent) {
    return ProgressionRecommendationsCompanion(
      id: Value(id),
      userId: Value(userId),
      exerciseId: Value(exerciseId),
      sessionId: sessionId == null && nullToAbsent ? const Value.absent() : Value(sessionId),
      previousWeight: previousWeight == null && nullToAbsent ? const Value.absent() : Value(previousWeight),
      recommendedWeight: recommendedWeight == null && nullToAbsent ? const Value.absent() : Value(recommendedWeight),
      recommendedReps: Value(recommendedReps),
      recommendedSets: Value(recommendedSets),
      action: Value(action),
      reason: Value(reason),
      confidenceLevel: Value(confidenceLevel),
      createdAt: Value(createdAt),
      accepted: accepted == null && nullToAbsent ? const Value.absent() : Value(accepted),
    );
  }

  factory ProgressionRecommendationRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProgressionRecommendationRow(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<int>(json['userId']),
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      sessionId: serializer.fromJson<int?>(json['sessionId']),
      previousWeight: serializer.fromJson<double?>(json['previousWeight']),
      recommendedWeight: serializer.fromJson<double?>(json['recommendedWeight']),
      recommendedReps: serializer.fromJson<String>(json['recommendedReps']),
      recommendedSets: serializer.fromJson<int>(json['recommendedSets']),
      action: serializer.fromJson<String>(json['action']),
      reason: serializer.fromJson<String>(json['reason']),
      confidenceLevel: serializer.fromJson<String>(json['confidenceLevel']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      accepted: serializer.fromJson<bool?>(json['accepted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<int>(userId),
      'exerciseId': serializer.toJson<String>(exerciseId),
      'sessionId': serializer.toJson<int?>(sessionId),
      'previousWeight': serializer.toJson<double?>(previousWeight),
      'recommendedWeight': serializer.toJson<double?>(recommendedWeight),
      'recommendedReps': serializer.toJson<String>(recommendedReps),
      'recommendedSets': serializer.toJson<int>(recommendedSets),
      'action': serializer.toJson<String>(action),
      'reason': serializer.toJson<String>(reason),
      'confidenceLevel': serializer.toJson<String>(confidenceLevel),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'accepted': serializer.toJson<bool?>(accepted),
    };
  }

  ProgressionRecommendationRow copyWith({
    int? id,
    int? userId,
    String? exerciseId,
    Value<int?> sessionId = const Value.absent(),
    Value<double?> previousWeight = const Value.absent(),
    Value<double?> recommendedWeight = const Value.absent(),
    String? recommendedReps,
    int? recommendedSets,
    String? action,
    String? reason,
    String? confidenceLevel,
    DateTime? createdAt,
    Value<bool?> accepted = const Value.absent(),
  }) => ProgressionRecommendationRow(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    exerciseId: exerciseId ?? this.exerciseId,
    sessionId: sessionId.present ? sessionId.value : this.sessionId,
    previousWeight: previousWeight.present ? previousWeight.value : this.previousWeight,
    recommendedWeight: recommendedWeight.present ? recommendedWeight.value : this.recommendedWeight,
    recommendedReps: recommendedReps ?? this.recommendedReps,
    recommendedSets: recommendedSets ?? this.recommendedSets,
    action: action ?? this.action,
    reason: reason ?? this.reason,
    confidenceLevel: confidenceLevel ?? this.confidenceLevel,
    createdAt: createdAt ?? this.createdAt,
    accepted: accepted.present ? accepted.value : this.accepted,
  );
  ProgressionRecommendationRow copyWithCompanion(ProgressionRecommendationsCompanion data) {
    return ProgressionRecommendationRow(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      exerciseId: data.exerciseId.present ? data.exerciseId.value : this.exerciseId,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      previousWeight: data.previousWeight.present ? data.previousWeight.value : this.previousWeight,
      recommendedWeight: data.recommendedWeight.present ? data.recommendedWeight.value : this.recommendedWeight,
      recommendedReps: data.recommendedReps.present ? data.recommendedReps.value : this.recommendedReps,
      recommendedSets: data.recommendedSets.present ? data.recommendedSets.value : this.recommendedSets,
      action: data.action.present ? data.action.value : this.action,
      reason: data.reason.present ? data.reason.value : this.reason,
      confidenceLevel: data.confidenceLevel.present ? data.confidenceLevel.value : this.confidenceLevel,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      accepted: data.accepted.present ? data.accepted.value : this.accepted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProgressionRecommendationRow(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('sessionId: $sessionId, ')
          ..write('previousWeight: $previousWeight, ')
          ..write('recommendedWeight: $recommendedWeight, ')
          ..write('recommendedReps: $recommendedReps, ')
          ..write('recommendedSets: $recommendedSets, ')
          ..write('action: $action, ')
          ..write('reason: $reason, ')
          ..write('confidenceLevel: $confidenceLevel, ')
          ..write('createdAt: $createdAt, ')
          ..write('accepted: $accepted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    exerciseId,
    sessionId,
    previousWeight,
    recommendedWeight,
    recommendedReps,
    recommendedSets,
    action,
    reason,
    confidenceLevel,
    createdAt,
    accepted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProgressionRecommendationRow &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.exerciseId == this.exerciseId &&
          other.sessionId == this.sessionId &&
          other.previousWeight == this.previousWeight &&
          other.recommendedWeight == this.recommendedWeight &&
          other.recommendedReps == this.recommendedReps &&
          other.recommendedSets == this.recommendedSets &&
          other.action == this.action &&
          other.reason == this.reason &&
          other.confidenceLevel == this.confidenceLevel &&
          other.createdAt == this.createdAt &&
          other.accepted == this.accepted);
}

class ProgressionRecommendationsCompanion extends UpdateCompanion<ProgressionRecommendationRow> {
  final Value<int> id;
  final Value<int> userId;
  final Value<String> exerciseId;
  final Value<int?> sessionId;
  final Value<double?> previousWeight;
  final Value<double?> recommendedWeight;
  final Value<String> recommendedReps;
  final Value<int> recommendedSets;
  final Value<String> action;
  final Value<String> reason;
  final Value<String> confidenceLevel;
  final Value<DateTime> createdAt;
  final Value<bool?> accepted;
  const ProgressionRecommendationsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.previousWeight = const Value.absent(),
    this.recommendedWeight = const Value.absent(),
    this.recommendedReps = const Value.absent(),
    this.recommendedSets = const Value.absent(),
    this.action = const Value.absent(),
    this.reason = const Value.absent(),
    this.confidenceLevel = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.accepted = const Value.absent(),
  });
  ProgressionRecommendationsCompanion.insert({
    this.id = const Value.absent(),
    required int userId,
    required String exerciseId,
    this.sessionId = const Value.absent(),
    this.previousWeight = const Value.absent(),
    this.recommendedWeight = const Value.absent(),
    required String recommendedReps,
    required int recommendedSets,
    required String action,
    required String reason,
    required String confidenceLevel,
    this.createdAt = const Value.absent(),
    this.accepted = const Value.absent(),
  }) : userId = Value(userId),
       exerciseId = Value(exerciseId),
       recommendedReps = Value(recommendedReps),
       recommendedSets = Value(recommendedSets),
       action = Value(action),
       reason = Value(reason),
       confidenceLevel = Value(confidenceLevel);
  static Insertable<ProgressionRecommendationRow> custom({
    Expression<int>? id,
    Expression<int>? userId,
    Expression<String>? exerciseId,
    Expression<int>? sessionId,
    Expression<double>? previousWeight,
    Expression<double>? recommendedWeight,
    Expression<String>? recommendedReps,
    Expression<int>? recommendedSets,
    Expression<String>? action,
    Expression<String>? reason,
    Expression<String>? confidenceLevel,
    Expression<DateTime>? createdAt,
    Expression<bool>? accepted,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (sessionId != null) 'session_id': sessionId,
      if (previousWeight != null) 'previous_weight': previousWeight,
      if (recommendedWeight != null) 'recommended_weight': recommendedWeight,
      if (recommendedReps != null) 'recommended_reps': recommendedReps,
      if (recommendedSets != null) 'recommended_sets': recommendedSets,
      if (action != null) 'action': action,
      if (reason != null) 'reason': reason,
      if (confidenceLevel != null) 'confidence_level': confidenceLevel,
      if (createdAt != null) 'created_at': createdAt,
      if (accepted != null) 'accepted': accepted,
    });
  }

  ProgressionRecommendationsCompanion copyWith({
    Value<int>? id,
    Value<int>? userId,
    Value<String>? exerciseId,
    Value<int?>? sessionId,
    Value<double?>? previousWeight,
    Value<double?>? recommendedWeight,
    Value<String>? recommendedReps,
    Value<int>? recommendedSets,
    Value<String>? action,
    Value<String>? reason,
    Value<String>? confidenceLevel,
    Value<DateTime>? createdAt,
    Value<bool?>? accepted,
  }) {
    return ProgressionRecommendationsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      exerciseId: exerciseId ?? this.exerciseId,
      sessionId: sessionId ?? this.sessionId,
      previousWeight: previousWeight ?? this.previousWeight,
      recommendedWeight: recommendedWeight ?? this.recommendedWeight,
      recommendedReps: recommendedReps ?? this.recommendedReps,
      recommendedSets: recommendedSets ?? this.recommendedSets,
      action: action ?? this.action,
      reason: reason ?? this.reason,
      confidenceLevel: confidenceLevel ?? this.confidenceLevel,
      createdAt: createdAt ?? this.createdAt,
      accepted: accepted ?? this.accepted,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (previousWeight.present) {
      map['previous_weight'] = Variable<double>(previousWeight.value);
    }
    if (recommendedWeight.present) {
      map['recommended_weight'] = Variable<double>(recommendedWeight.value);
    }
    if (recommendedReps.present) {
      map['recommended_reps'] = Variable<String>(recommendedReps.value);
    }
    if (recommendedSets.present) {
      map['recommended_sets'] = Variable<int>(recommendedSets.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (confidenceLevel.present) {
      map['confidence_level'] = Variable<String>(confidenceLevel.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (accepted.present) {
      map['accepted'] = Variable<bool>(accepted.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProgressionRecommendationsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('sessionId: $sessionId, ')
          ..write('previousWeight: $previousWeight, ')
          ..write('recommendedWeight: $recommendedWeight, ')
          ..write('recommendedReps: $recommendedReps, ')
          ..write('recommendedSets: $recommendedSets, ')
          ..write('action: $action, ')
          ..write('reason: $reason, ')
          ..write('confidenceLevel: $confidenceLevel, ')
          ..write('createdAt: $createdAt, ')
          ..write('accepted: $accepted')
          ..write(')'))
        .toString();
  }
}

class $AiRecommendationsTable extends AiRecommendations with TableInfo<$AiRecommendationsTable, AiRecommendation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AiRecommendationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>('kind', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>('title', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>('body', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadMeta = const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>('payload', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  @override
  List<GeneratedColumn> get $columns => [id, createdAt, kind, title, body, payload, status];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ai_recommendations';
  @override
  VerificationContext validateIntegrity(Insertable<AiRecommendation> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('kind')) {
      context.handle(_kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('title')) {
      context.handle(_titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('body')) {
      context.handle(_bodyMeta, body.isAcceptableOrUnknown(data['body']!, _bodyMeta));
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta, payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta, status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AiRecommendation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AiRecommendation(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      kind: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      title: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      body: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}body'])!,
      payload: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      status: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}status'])!,
    );
  }

  @override
  $AiRecommendationsTable createAlias(String alias) {
    return $AiRecommendationsTable(attachedDatabase, alias);
  }
}

class AiRecommendation extends DataClass implements Insertable<AiRecommendation> {
  final int id;
  final DateTime createdAt;
  final String kind;
  final String title;
  final String body;
  final String payload;
  final String status;
  const AiRecommendation({
    required this.id,
    required this.createdAt,
    required this.kind,
    required this.title,
    required this.body,
    required this.payload,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['kind'] = Variable<String>(kind);
    map['title'] = Variable<String>(title);
    map['body'] = Variable<String>(body);
    map['payload'] = Variable<String>(payload);
    map['status'] = Variable<String>(status);
    return map;
  }

  AiRecommendationsCompanion toCompanion(bool nullToAbsent) {
    return AiRecommendationsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      kind: Value(kind),
      title: Value(title),
      body: Value(body),
      payload: Value(payload),
      status: Value(status),
    );
  }

  factory AiRecommendation.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AiRecommendation(
      id: serializer.fromJson<int>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      kind: serializer.fromJson<String>(json['kind']),
      title: serializer.fromJson<String>(json['title']),
      body: serializer.fromJson<String>(json['body']),
      payload: serializer.fromJson<String>(json['payload']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'kind': serializer.toJson<String>(kind),
      'title': serializer.toJson<String>(title),
      'body': serializer.toJson<String>(body),
      'payload': serializer.toJson<String>(payload),
      'status': serializer.toJson<String>(status),
    };
  }

  AiRecommendation copyWith({int? id, DateTime? createdAt, String? kind, String? title, String? body, String? payload, String? status}) => AiRecommendation(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    kind: kind ?? this.kind,
    title: title ?? this.title,
    body: body ?? this.body,
    payload: payload ?? this.payload,
    status: status ?? this.status,
  );
  AiRecommendation copyWithCompanion(AiRecommendationsCompanion data) {
    return AiRecommendation(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      kind: data.kind.present ? data.kind.value : this.kind,
      title: data.title.present ? data.title.value : this.title,
      body: data.body.present ? data.body.value : this.body,
      payload: data.payload.present ? data.payload.value : this.payload,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AiRecommendation(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('kind: $kind, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('payload: $payload, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, createdAt, kind, title, body, payload, status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AiRecommendation &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.kind == this.kind &&
          other.title == this.title &&
          other.body == this.body &&
          other.payload == this.payload &&
          other.status == this.status);
}

class AiRecommendationsCompanion extends UpdateCompanion<AiRecommendation> {
  final Value<int> id;
  final Value<DateTime> createdAt;
  final Value<String> kind;
  final Value<String> title;
  final Value<String> body;
  final Value<String> payload;
  final Value<String> status;
  const AiRecommendationsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.kind = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.payload = const Value.absent(),
    this.status = const Value.absent(),
  });
  AiRecommendationsCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    required String kind,
    required String title,
    required String body,
    required String payload,
    this.status = const Value.absent(),
  }) : kind = Value(kind),
       title = Value(title),
       body = Value(body),
       payload = Value(payload);
  static Insertable<AiRecommendation> custom({
    Expression<int>? id,
    Expression<DateTime>? createdAt,
    Expression<String>? kind,
    Expression<String>? title,
    Expression<String>? body,
    Expression<String>? payload,
    Expression<String>? status,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (kind != null) 'kind': kind,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (payload != null) 'payload': payload,
      if (status != null) 'status': status,
    });
  }

  AiRecommendationsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? createdAt,
    Value<String>? kind,
    Value<String>? title,
    Value<String>? body,
    Value<String>? payload,
    Value<String>? status,
  }) {
    return AiRecommendationsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      kind: kind ?? this.kind,
      title: title ?? this.title,
      body: body ?? this.body,
      payload: payload ?? this.payload,
      status: status ?? this.status,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AiRecommendationsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('kind: $kind, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('payload: $payload, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }
}

class $ResearchReferencesTable extends ResearchReferences with TableInfo<$ResearchReferencesTable, ResearchReferenceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ResearchReferencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>('id', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>('title', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _authorsMeta = const VerificationMeta('authors');
  @override
  late final GeneratedColumn<String> authors = GeneratedColumn<String>('authors', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>('year', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _journalMeta = const VerificationMeta('journal');
  @override
  late final GeneratedColumn<String> journal = GeneratedColumn<String>('journal', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _studyTypeMeta = const VerificationMeta('studyType');
  @override
  late final GeneratedColumn<String> studyType = GeneratedColumn<String>(
    'study_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _populationMeta = const VerificationMeta('population');
  @override
  late final GeneratedColumn<String> population = GeneratedColumn<String>(
    'population',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _keyFindingsMeta = const VerificationMeta('keyFindings');
  @override
  late final GeneratedColumn<String> keyFindings = GeneratedColumn<String>(
    'key_findings',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _limitationsMeta = const VerificationMeta('limitations');
  @override
  late final GeneratedColumn<String> limitations = GeneratedColumn<String>(
    'limitations',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _appliedInMeta = const VerificationMeta('appliedIn');
  @override
  late final GeneratedColumn<String> appliedIn = GeneratedColumn<String>(
    'applied_in',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, title, authors, year, journal, studyType, population, keyFindings, limitations, appliedIn];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'research_references';
  @override
  VerificationContext validateIntegrity(Insertable<ResearchReferenceRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(_titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('authors')) {
      context.handle(_authorsMeta, authors.isAcceptableOrUnknown(data['authors']!, _authorsMeta));
    } else if (isInserting) {
      context.missing(_authorsMeta);
    }
    if (data.containsKey('year')) {
      context.handle(_yearMeta, year.isAcceptableOrUnknown(data['year']!, _yearMeta));
    } else if (isInserting) {
      context.missing(_yearMeta);
    }
    if (data.containsKey('journal')) {
      context.handle(_journalMeta, journal.isAcceptableOrUnknown(data['journal']!, _journalMeta));
    } else if (isInserting) {
      context.missing(_journalMeta);
    }
    if (data.containsKey('study_type')) {
      context.handle(_studyTypeMeta, studyType.isAcceptableOrUnknown(data['study_type']!, _studyTypeMeta));
    } else if (isInserting) {
      context.missing(_studyTypeMeta);
    }
    if (data.containsKey('population')) {
      context.handle(_populationMeta, population.isAcceptableOrUnknown(data['population']!, _populationMeta));
    } else if (isInserting) {
      context.missing(_populationMeta);
    }
    if (data.containsKey('key_findings')) {
      context.handle(_keyFindingsMeta, keyFindings.isAcceptableOrUnknown(data['key_findings']!, _keyFindingsMeta));
    } else if (isInserting) {
      context.missing(_keyFindingsMeta);
    }
    if (data.containsKey('limitations')) {
      context.handle(_limitationsMeta, limitations.isAcceptableOrUnknown(data['limitations']!, _limitationsMeta));
    } else if (isInserting) {
      context.missing(_limitationsMeta);
    }
    if (data.containsKey('applied_in')) {
      context.handle(_appliedInMeta, appliedIn.isAcceptableOrUnknown(data['applied_in']!, _appliedInMeta));
    } else if (isInserting) {
      context.missing(_appliedInMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ResearchReferenceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ResearchReferenceRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      authors: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}authors'])!,
      year: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}year'])!,
      journal: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}journal'])!,
      studyType: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}study_type'])!,
      population: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}population'])!,
      keyFindings: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}key_findings'])!,
      limitations: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}limitations'])!,
      appliedIn: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}applied_in'])!,
    );
  }

  @override
  $ResearchReferencesTable createAlias(String alias) {
    return $ResearchReferencesTable(attachedDatabase, alias);
  }
}

class ResearchReferenceRow extends DataClass implements Insertable<ResearchReferenceRow> {
  final String id;
  final String title;
  final String authors;
  final int year;
  final String journal;
  final String studyType;
  final String population;
  final String keyFindings;
  final String limitations;
  final String appliedIn;
  const ResearchReferenceRow({
    required this.id,
    required this.title,
    required this.authors,
    required this.year,
    required this.journal,
    required this.studyType,
    required this.population,
    required this.keyFindings,
    required this.limitations,
    required this.appliedIn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['authors'] = Variable<String>(authors);
    map['year'] = Variable<int>(year);
    map['journal'] = Variable<String>(journal);
    map['study_type'] = Variable<String>(studyType);
    map['population'] = Variable<String>(population);
    map['key_findings'] = Variable<String>(keyFindings);
    map['limitations'] = Variable<String>(limitations);
    map['applied_in'] = Variable<String>(appliedIn);
    return map;
  }

  ResearchReferencesCompanion toCompanion(bool nullToAbsent) {
    return ResearchReferencesCompanion(
      id: Value(id),
      title: Value(title),
      authors: Value(authors),
      year: Value(year),
      journal: Value(journal),
      studyType: Value(studyType),
      population: Value(population),
      keyFindings: Value(keyFindings),
      limitations: Value(limitations),
      appliedIn: Value(appliedIn),
    );
  }

  factory ResearchReferenceRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ResearchReferenceRow(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      authors: serializer.fromJson<String>(json['authors']),
      year: serializer.fromJson<int>(json['year']),
      journal: serializer.fromJson<String>(json['journal']),
      studyType: serializer.fromJson<String>(json['studyType']),
      population: serializer.fromJson<String>(json['population']),
      keyFindings: serializer.fromJson<String>(json['keyFindings']),
      limitations: serializer.fromJson<String>(json['limitations']),
      appliedIn: serializer.fromJson<String>(json['appliedIn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'authors': serializer.toJson<String>(authors),
      'year': serializer.toJson<int>(year),
      'journal': serializer.toJson<String>(journal),
      'studyType': serializer.toJson<String>(studyType),
      'population': serializer.toJson<String>(population),
      'keyFindings': serializer.toJson<String>(keyFindings),
      'limitations': serializer.toJson<String>(limitations),
      'appliedIn': serializer.toJson<String>(appliedIn),
    };
  }

  ResearchReferenceRow copyWith({
    String? id,
    String? title,
    String? authors,
    int? year,
    String? journal,
    String? studyType,
    String? population,
    String? keyFindings,
    String? limitations,
    String? appliedIn,
  }) => ResearchReferenceRow(
    id: id ?? this.id,
    title: title ?? this.title,
    authors: authors ?? this.authors,
    year: year ?? this.year,
    journal: journal ?? this.journal,
    studyType: studyType ?? this.studyType,
    population: population ?? this.population,
    keyFindings: keyFindings ?? this.keyFindings,
    limitations: limitations ?? this.limitations,
    appliedIn: appliedIn ?? this.appliedIn,
  );
  ResearchReferenceRow copyWithCompanion(ResearchReferencesCompanion data) {
    return ResearchReferenceRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      authors: data.authors.present ? data.authors.value : this.authors,
      year: data.year.present ? data.year.value : this.year,
      journal: data.journal.present ? data.journal.value : this.journal,
      studyType: data.studyType.present ? data.studyType.value : this.studyType,
      population: data.population.present ? data.population.value : this.population,
      keyFindings: data.keyFindings.present ? data.keyFindings.value : this.keyFindings,
      limitations: data.limitations.present ? data.limitations.value : this.limitations,
      appliedIn: data.appliedIn.present ? data.appliedIn.value : this.appliedIn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ResearchReferenceRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('authors: $authors, ')
          ..write('year: $year, ')
          ..write('journal: $journal, ')
          ..write('studyType: $studyType, ')
          ..write('population: $population, ')
          ..write('keyFindings: $keyFindings, ')
          ..write('limitations: $limitations, ')
          ..write('appliedIn: $appliedIn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, authors, year, journal, studyType, population, keyFindings, limitations, appliedIn);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ResearchReferenceRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.authors == this.authors &&
          other.year == this.year &&
          other.journal == this.journal &&
          other.studyType == this.studyType &&
          other.population == this.population &&
          other.keyFindings == this.keyFindings &&
          other.limitations == this.limitations &&
          other.appliedIn == this.appliedIn);
}

class ResearchReferencesCompanion extends UpdateCompanion<ResearchReferenceRow> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> authors;
  final Value<int> year;
  final Value<String> journal;
  final Value<String> studyType;
  final Value<String> population;
  final Value<String> keyFindings;
  final Value<String> limitations;
  final Value<String> appliedIn;
  final Value<int> rowid;
  const ResearchReferencesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.authors = const Value.absent(),
    this.year = const Value.absent(),
    this.journal = const Value.absent(),
    this.studyType = const Value.absent(),
    this.population = const Value.absent(),
    this.keyFindings = const Value.absent(),
    this.limitations = const Value.absent(),
    this.appliedIn = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ResearchReferencesCompanion.insert({
    required String id,
    required String title,
    required String authors,
    required int year,
    required String journal,
    required String studyType,
    required String population,
    required String keyFindings,
    required String limitations,
    required String appliedIn,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       authors = Value(authors),
       year = Value(year),
       journal = Value(journal),
       studyType = Value(studyType),
       population = Value(population),
       keyFindings = Value(keyFindings),
       limitations = Value(limitations),
       appliedIn = Value(appliedIn);
  static Insertable<ResearchReferenceRow> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? authors,
    Expression<int>? year,
    Expression<String>? journal,
    Expression<String>? studyType,
    Expression<String>? population,
    Expression<String>? keyFindings,
    Expression<String>? limitations,
    Expression<String>? appliedIn,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (authors != null) 'authors': authors,
      if (year != null) 'year': year,
      if (journal != null) 'journal': journal,
      if (studyType != null) 'study_type': studyType,
      if (population != null) 'population': population,
      if (keyFindings != null) 'key_findings': keyFindings,
      if (limitations != null) 'limitations': limitations,
      if (appliedIn != null) 'applied_in': appliedIn,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ResearchReferencesCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? authors,
    Value<int>? year,
    Value<String>? journal,
    Value<String>? studyType,
    Value<String>? population,
    Value<String>? keyFindings,
    Value<String>? limitations,
    Value<String>? appliedIn,
    Value<int>? rowid,
  }) {
    return ResearchReferencesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      authors: authors ?? this.authors,
      year: year ?? this.year,
      journal: journal ?? this.journal,
      studyType: studyType ?? this.studyType,
      population: population ?? this.population,
      keyFindings: keyFindings ?? this.keyFindings,
      limitations: limitations ?? this.limitations,
      appliedIn: appliedIn ?? this.appliedIn,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (authors.present) {
      map['authors'] = Variable<String>(authors.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (journal.present) {
      map['journal'] = Variable<String>(journal.value);
    }
    if (studyType.present) {
      map['study_type'] = Variable<String>(studyType.value);
    }
    if (population.present) {
      map['population'] = Variable<String>(population.value);
    }
    if (keyFindings.present) {
      map['key_findings'] = Variable<String>(keyFindings.value);
    }
    if (limitations.present) {
      map['limitations'] = Variable<String>(limitations.value);
    }
    if (appliedIn.present) {
      map['applied_in'] = Variable<String>(appliedIn.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ResearchReferencesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('authors: $authors, ')
          ..write('year: $year, ')
          ..write('journal: $journal, ')
          ..write('studyType: $studyType, ')
          ..write('population: $population, ')
          ..write('keyFindings: $keyFindings, ')
          ..write('limitations: $limitations, ')
          ..write('appliedIn: $appliedIn, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>('key', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>('value', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(Insertable<AppSetting> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(_keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(_valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String value;
  const AppSetting({required this.key, required this.value});
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

  factory AppSetting.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(key: serializer.fromJson<String>(json['key']), value: serializer.fromJson<String>(json['value']));
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'key': serializer.toJson<String>(key), 'value': serializer.toJson<String>(value)};
  }

  AppSetting copyWith({String? key, String? value}) => AppSetting(key: key ?? this.key, value: value ?? this.value);
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(key: data.key.present ? data.key.value : this.key, value: data.value.present ? data.value.value : this.value);
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) => identical(this, other) || (other is AppSetting && other.key == this.key && other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({this.key = const Value.absent(), this.value = const Value.absent(), this.rowid = const Value.absent()});
  AppSettingsCompanion.insert({required String key, required String value, this.rowid = const Value.absent()}) : key = Value(key), value = Value(value);
  static Insertable<AppSetting> custom({Expression<String>? key, Expression<String>? value, Expression<int>? rowid}) {
    return RawValuesInsertable({if (key != null) 'key': key, if (value != null) 'value': value, if (rowid != null) 'rowid': rowid});
  }

  AppSettingsCompanion copyWith({Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return AppSettingsCompanion(key: key ?? this.key, value: value ?? this.value, rowid: rowid ?? this.rowid);
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

class $ChatMessagesTable extends ChatMessages with TableInfo<$ChatMessagesTable, ChatMessage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>('role', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contentMeta = const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>('content', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _providerMeta = const VerificationMeta('provider');
  @override
  late final GeneratedColumn<String> provider = GeneratedColumn<String>('provider', aliasedName, true, type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _recommendationIdMeta = const VerificationMeta('recommendationId');
  @override
  late final GeneratedColumn<int> recommendationId = GeneratedColumn<int>(
    'recommendation_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, createdAt, role, content, provider, recommendationId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_messages';
  @override
  VerificationContext validateIntegrity(Insertable<ChatMessage> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('role')) {
      context.handle(_roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta, content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('provider')) {
      context.handle(_providerMeta, provider.isAcceptableOrUnknown(data['provider']!, _providerMeta));
    }
    if (data.containsKey('recommendation_id')) {
      context.handle(_recommendationIdMeta, recommendationId.isAcceptableOrUnknown(data['recommendation_id']!, _recommendationIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChatMessage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatMessage(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      role: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      content: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      provider: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}provider']),
      recommendationId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}recommendation_id']),
    );
  }

  @override
  $ChatMessagesTable createAlias(String alias) {
    return $ChatMessagesTable(attachedDatabase, alias);
  }
}

class ChatMessage extends DataClass implements Insertable<ChatMessage> {
  final int id;
  final DateTime createdAt;
  final String role;
  final String content;
  final String? provider;
  final int? recommendationId;
  const ChatMessage({required this.id, required this.createdAt, required this.role, required this.content, this.provider, this.recommendationId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['role'] = Variable<String>(role);
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || provider != null) {
      map['provider'] = Variable<String>(provider);
    }
    if (!nullToAbsent || recommendationId != null) {
      map['recommendation_id'] = Variable<int>(recommendationId);
    }
    return map;
  }

  ChatMessagesCompanion toCompanion(bool nullToAbsent) {
    return ChatMessagesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      role: Value(role),
      content: Value(content),
      provider: provider == null && nullToAbsent ? const Value.absent() : Value(provider),
      recommendationId: recommendationId == null && nullToAbsent ? const Value.absent() : Value(recommendationId),
    );
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatMessage(
      id: serializer.fromJson<int>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      role: serializer.fromJson<String>(json['role']),
      content: serializer.fromJson<String>(json['content']),
      provider: serializer.fromJson<String?>(json['provider']),
      recommendationId: serializer.fromJson<int?>(json['recommendationId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'role': serializer.toJson<String>(role),
      'content': serializer.toJson<String>(content),
      'provider': serializer.toJson<String?>(provider),
      'recommendationId': serializer.toJson<int?>(recommendationId),
    };
  }

  ChatMessage copyWith({
    int? id,
    DateTime? createdAt,
    String? role,
    String? content,
    Value<String?> provider = const Value.absent(),
    Value<int?> recommendationId = const Value.absent(),
  }) => ChatMessage(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    role: role ?? this.role,
    content: content ?? this.content,
    provider: provider.present ? provider.value : this.provider,
    recommendationId: recommendationId.present ? recommendationId.value : this.recommendationId,
  );
  ChatMessage copyWithCompanion(ChatMessagesCompanion data) {
    return ChatMessage(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      role: data.role.present ? data.role.value : this.role,
      content: data.content.present ? data.content.value : this.content,
      provider: data.provider.present ? data.provider.value : this.provider,
      recommendationId: data.recommendationId.present ? data.recommendationId.value : this.recommendationId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessage(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('provider: $provider, ')
          ..write('recommendationId: $recommendationId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, createdAt, role, content, provider, recommendationId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatMessage &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.role == this.role &&
          other.content == this.content &&
          other.provider == this.provider &&
          other.recommendationId == this.recommendationId);
}

class ChatMessagesCompanion extends UpdateCompanion<ChatMessage> {
  final Value<int> id;
  final Value<DateTime> createdAt;
  final Value<String> role;
  final Value<String> content;
  final Value<String?> provider;
  final Value<int?> recommendationId;
  const ChatMessagesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.role = const Value.absent(),
    this.content = const Value.absent(),
    this.provider = const Value.absent(),
    this.recommendationId = const Value.absent(),
  });
  ChatMessagesCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    required String role,
    required String content,
    this.provider = const Value.absent(),
    this.recommendationId = const Value.absent(),
  }) : role = Value(role),
       content = Value(content);
  static Insertable<ChatMessage> custom({
    Expression<int>? id,
    Expression<DateTime>? createdAt,
    Expression<String>? role,
    Expression<String>? content,
    Expression<String>? provider,
    Expression<int>? recommendationId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (role != null) 'role': role,
      if (content != null) 'content': content,
      if (provider != null) 'provider': provider,
      if (recommendationId != null) 'recommendation_id': recommendationId,
    });
  }

  ChatMessagesCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? createdAt,
    Value<String>? role,
    Value<String>? content,
    Value<String?>? provider,
    Value<int?>? recommendationId,
  }) {
    return ChatMessagesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      role: role ?? this.role,
      content: content ?? this.content,
      provider: provider ?? this.provider,
      recommendationId: recommendationId ?? this.recommendationId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (provider.present) {
      map['provider'] = Variable<String>(provider.value);
    }
    if (recommendationId.present) {
      map['recommendation_id'] = Variable<int>(recommendationId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessagesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('provider: $provider, ')
          ..write('recommendationId: $recommendationId')
          ..write(')'))
        .toString();
  }
}

class $AiUsageLogsTable extends AiUsageLogs with TableInfo<$AiUsageLogsTable, AiUsageLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AiUsageLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _providerMeta = const VerificationMeta('provider');
  @override
  late final GeneratedColumn<String> provider = GeneratedColumn<String>('provider', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>('model', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _inputTokensMeta = const VerificationMeta('inputTokens');
  @override
  late final GeneratedColumn<int> inputTokens = GeneratedColumn<int>(
    'input_tokens',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _outputTokensMeta = const VerificationMeta('outputTokens');
  @override
  late final GeneratedColumn<int> outputTokens = GeneratedColumn<int>(
    'output_tokens',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, createdAt, provider, model, inputTokens, outputTokens];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ai_usage_logs';
  @override
  VerificationContext validateIntegrity(Insertable<AiUsageLog> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('provider')) {
      context.handle(_providerMeta, provider.isAcceptableOrUnknown(data['provider']!, _providerMeta));
    } else if (isInserting) {
      context.missing(_providerMeta);
    }
    if (data.containsKey('model')) {
      context.handle(_modelMeta, model.isAcceptableOrUnknown(data['model']!, _modelMeta));
    } else if (isInserting) {
      context.missing(_modelMeta);
    }
    if (data.containsKey('input_tokens')) {
      context.handle(_inputTokensMeta, inputTokens.isAcceptableOrUnknown(data['input_tokens']!, _inputTokensMeta));
    }
    if (data.containsKey('output_tokens')) {
      context.handle(_outputTokensMeta, outputTokens.isAcceptableOrUnknown(data['output_tokens']!, _outputTokensMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AiUsageLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AiUsageLog(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      provider: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}provider'])!,
      model: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}model'])!,
      inputTokens: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}input_tokens'])!,
      outputTokens: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}output_tokens'])!,
    );
  }

  @override
  $AiUsageLogsTable createAlias(String alias) {
    return $AiUsageLogsTable(attachedDatabase, alias);
  }
}

class AiUsageLog extends DataClass implements Insertable<AiUsageLog> {
  final int id;
  final DateTime createdAt;
  final String provider;
  final String model;
  final int inputTokens;
  final int outputTokens;
  const AiUsageLog({
    required this.id,
    required this.createdAt,
    required this.provider,
    required this.model,
    required this.inputTokens,
    required this.outputTokens,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['provider'] = Variable<String>(provider);
    map['model'] = Variable<String>(model);
    map['input_tokens'] = Variable<int>(inputTokens);
    map['output_tokens'] = Variable<int>(outputTokens);
    return map;
  }

  AiUsageLogsCompanion toCompanion(bool nullToAbsent) {
    return AiUsageLogsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      provider: Value(provider),
      model: Value(model),
      inputTokens: Value(inputTokens),
      outputTokens: Value(outputTokens),
    );
  }

  factory AiUsageLog.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AiUsageLog(
      id: serializer.fromJson<int>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      provider: serializer.fromJson<String>(json['provider']),
      model: serializer.fromJson<String>(json['model']),
      inputTokens: serializer.fromJson<int>(json['inputTokens']),
      outputTokens: serializer.fromJson<int>(json['outputTokens']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'provider': serializer.toJson<String>(provider),
      'model': serializer.toJson<String>(model),
      'inputTokens': serializer.toJson<int>(inputTokens),
      'outputTokens': serializer.toJson<int>(outputTokens),
    };
  }

  AiUsageLog copyWith({int? id, DateTime? createdAt, String? provider, String? model, int? inputTokens, int? outputTokens}) => AiUsageLog(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    provider: provider ?? this.provider,
    model: model ?? this.model,
    inputTokens: inputTokens ?? this.inputTokens,
    outputTokens: outputTokens ?? this.outputTokens,
  );
  AiUsageLog copyWithCompanion(AiUsageLogsCompanion data) {
    return AiUsageLog(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      provider: data.provider.present ? data.provider.value : this.provider,
      model: data.model.present ? data.model.value : this.model,
      inputTokens: data.inputTokens.present ? data.inputTokens.value : this.inputTokens,
      outputTokens: data.outputTokens.present ? data.outputTokens.value : this.outputTokens,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AiUsageLog(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('provider: $provider, ')
          ..write('model: $model, ')
          ..write('inputTokens: $inputTokens, ')
          ..write('outputTokens: $outputTokens')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, createdAt, provider, model, inputTokens, outputTokens);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AiUsageLog &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.provider == this.provider &&
          other.model == this.model &&
          other.inputTokens == this.inputTokens &&
          other.outputTokens == this.outputTokens);
}

class AiUsageLogsCompanion extends UpdateCompanion<AiUsageLog> {
  final Value<int> id;
  final Value<DateTime> createdAt;
  final Value<String> provider;
  final Value<String> model;
  final Value<int> inputTokens;
  final Value<int> outputTokens;
  const AiUsageLogsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.provider = const Value.absent(),
    this.model = const Value.absent(),
    this.inputTokens = const Value.absent(),
    this.outputTokens = const Value.absent(),
  });
  AiUsageLogsCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    required String provider,
    required String model,
    this.inputTokens = const Value.absent(),
    this.outputTokens = const Value.absent(),
  }) : provider = Value(provider),
       model = Value(model);
  static Insertable<AiUsageLog> custom({
    Expression<int>? id,
    Expression<DateTime>? createdAt,
    Expression<String>? provider,
    Expression<String>? model,
    Expression<int>? inputTokens,
    Expression<int>? outputTokens,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (provider != null) 'provider': provider,
      if (model != null) 'model': model,
      if (inputTokens != null) 'input_tokens': inputTokens,
      if (outputTokens != null) 'output_tokens': outputTokens,
    });
  }

  AiUsageLogsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? createdAt,
    Value<String>? provider,
    Value<String>? model,
    Value<int>? inputTokens,
    Value<int>? outputTokens,
  }) {
    return AiUsageLogsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      provider: provider ?? this.provider,
      model: model ?? this.model,
      inputTokens: inputTokens ?? this.inputTokens,
      outputTokens: outputTokens ?? this.outputTokens,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (provider.present) {
      map['provider'] = Variable<String>(provider.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (inputTokens.present) {
      map['input_tokens'] = Variable<int>(inputTokens.value);
    }
    if (outputTokens.present) {
      map['output_tokens'] = Variable<int>(outputTokens.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AiUsageLogsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('provider: $provider, ')
          ..write('model: $model, ')
          ..write('inputTokens: $inputTokens, ')
          ..write('outputTokens: $outputTokens')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $UserProfilesTable userProfiles = $UserProfilesTable(this);
  late final $UserGoalsTable userGoals = $UserGoalsTable(this);
  late final $UserEquipmentTable userEquipment = $UserEquipmentTable(this);
  late final $UserLimitationsTable userLimitations = $UserLimitationsTable(this);
  late final $ExercisesTable exercises = $ExercisesTable(this);
  late final $ExerciseMusclesTable exerciseMuscles = $ExerciseMusclesTable(this);
  late final $ExerciseAlternativesTable exerciseAlternatives = $ExerciseAlternativesTable(this);
  late final $WorkoutProgramsTable workoutPrograms = $WorkoutProgramsTable(this);
  late final $WorkoutDaysTable workoutDays = $WorkoutDaysTable(this);
  late final $WorkoutExercisesTable workoutExercises = $WorkoutExercisesTable(this);
  late final $WorkoutSessionsTable workoutSessions = $WorkoutSessionsTable(this);
  late final $WorkoutSessionExercisesTable workoutSessionExercises = $WorkoutSessionExercisesTable(this);
  late final $WorkoutSetsTable workoutSets = $WorkoutSetsTable(this);
  late final $BodyMeasurementsTable bodyMeasurements = $BodyMeasurementsTable(this);
  late final $RecoveryLogsTable recoveryLogs = $RecoveryLogsTable(this);
  late final $ProgressionRecommendationsTable progressionRecommendations = $ProgressionRecommendationsTable(this);
  late final $AiRecommendationsTable aiRecommendations = $AiRecommendationsTable(this);
  late final $ResearchReferencesTable researchReferences = $ResearchReferencesTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $ChatMessagesTable chatMessages = $ChatMessagesTable(this);
  late final $AiUsageLogsTable aiUsageLogs = $AiUsageLogsTable(this);
  late final Index idxSetsExercise = Index('idx_sets_exercise', 'CREATE INDEX idx_sets_exercise ON workout_sets (exercise_id)');
  @override
  Iterable<TableInfo<Table, Object?>> get allTables => allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    users,
    userProfiles,
    userGoals,
    userEquipment,
    userLimitations,
    exercises,
    exerciseMuscles,
    exerciseAlternatives,
    workoutPrograms,
    workoutDays,
    workoutExercises,
    workoutSessions,
    workoutSessionExercises,
    workoutSets,
    bodyMeasurements,
    recoveryLogs,
    progressionRecommendations,
    aiRecommendations,
    researchReferences,
    appSettings,
    chatMessages,
    aiUsageLogs,
    idxSetsExercise,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName('workout_programs', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('workout_days', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName('workout_days', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('workout_exercises', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName('workout_sessions', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('workout_session_exercises', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName('workout_sessions', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('workout_sets', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName('workout_session_exercises', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('workout_sets', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$UsersTableCreateCompanionBuilder = UsersCompanion Function({Value<int> id, Value<DateTime> createdAt});
typedef $$UsersTableUpdateCompanionBuilder = UsersCompanion Function({Value<int> id, Value<DateTime> createdAt});

final class $$UsersTableReferences extends BaseReferences<_$AppDatabase, $UsersTable, User> {
  $$UsersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$UserProfilesTable, List<UserProfileRow>> _userProfilesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.userProfiles, aliasName: 'users__id__user_profiles__user_id');

  $$UserProfilesTableProcessedTableManager get userProfilesRefs {
    final manager = $$UserProfilesTableTableManager($_db, $_db.userProfiles).filter((f) => f.userId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_userProfilesRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$UserGoalsTable, List<UserGoal>> _userGoalsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.userGoals, aliasName: 'users__id__user_goals__user_id');

  $$UserGoalsTableProcessedTableManager get userGoalsRefs {
    final manager = $$UserGoalsTableTableManager($_db, $_db.userGoals).filter((f) => f.userId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_userGoalsRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$UserEquipmentTable, List<UserEquipmentData>> _userEquipmentRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.userEquipment, aliasName: 'users__id__user_equipment__user_id');

  $$UserEquipmentTableProcessedTableManager get userEquipmentRefs {
    final manager = $$UserEquipmentTableTableManager($_db, $_db.userEquipment).filter((f) => f.userId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_userEquipmentRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$UserLimitationsTable, List<UserLimitation>> _userLimitationsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.userLimitations, aliasName: 'users__id__user_limitations__user_id');

  $$UserLimitationsTableProcessedTableManager get userLimitationsRefs {
    final manager = $$UserLimitationsTableTableManager($_db, $_db.userLimitations).filter((f) => f.userId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_userLimitationsRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$WorkoutProgramsTable, List<WorkoutProgram>> _workoutProgramsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.workoutPrograms, aliasName: 'users__id__workout_programs__user_id');

  $$WorkoutProgramsTableProcessedTableManager get workoutProgramsRefs {
    final manager = $$WorkoutProgramsTableTableManager($_db, $_db.workoutPrograms).filter((f) => f.userId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_workoutProgramsRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
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
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  Expression<bool> userProfilesRefs(Expression<bool> Function($$UserProfilesTableFilterComposer f) f) {
    final $$UserProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userProfiles,
      getReferencedColumn: (t) => t.userId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$UserProfilesTableFilterComposer(
        $db: $db,
        $table: $db.userProfiles,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return f(composer);
  }

  Expression<bool> userGoalsRefs(Expression<bool> Function($$UserGoalsTableFilterComposer f) f) {
    final $$UserGoalsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userGoals,
      getReferencedColumn: (t) => t.userId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$UserGoalsTableFilterComposer(
        $db: $db,
        $table: $db.userGoals,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return f(composer);
  }

  Expression<bool> userEquipmentRefs(Expression<bool> Function($$UserEquipmentTableFilterComposer f) f) {
    final $$UserEquipmentTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userEquipment,
      getReferencedColumn: (t) => t.userId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$UserEquipmentTableFilterComposer(
        $db: $db,
        $table: $db.userEquipment,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return f(composer);
  }

  Expression<bool> userLimitationsRefs(Expression<bool> Function($$UserLimitationsTableFilterComposer f) f) {
    final $$UserLimitationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userLimitations,
      getReferencedColumn: (t) => t.userId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$UserLimitationsTableFilterComposer(
        $db: $db,
        $table: $db.userLimitations,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return f(composer);
  }

  Expression<bool> workoutProgramsRefs(Expression<bool> Function($$WorkoutProgramsTableFilterComposer f) f) {
    final $$WorkoutProgramsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutPrograms,
      getReferencedColumn: (t) => t.userId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$WorkoutProgramsTableFilterComposer(
        $db: $db,
        $table: $db.workoutPrograms,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return f(composer);
  }
}

class $$UsersTableOrderingComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$UsersTableAnnotationComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> userProfilesRefs<T extends Object>(Expression<T> Function($$UserProfilesTableAnnotationComposer a) f) {
    final $$UserProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userProfiles,
      getReferencedColumn: (t) => t.userId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$UserProfilesTableAnnotationComposer(
        $db: $db,
        $table: $db.userProfiles,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return f(composer);
  }

  Expression<T> userGoalsRefs<T extends Object>(Expression<T> Function($$UserGoalsTableAnnotationComposer a) f) {
    final $$UserGoalsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userGoals,
      getReferencedColumn: (t) => t.userId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$UserGoalsTableAnnotationComposer(
        $db: $db,
        $table: $db.userGoals,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return f(composer);
  }

  Expression<T> userEquipmentRefs<T extends Object>(Expression<T> Function($$UserEquipmentTableAnnotationComposer a) f) {
    final $$UserEquipmentTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userEquipment,
      getReferencedColumn: (t) => t.userId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$UserEquipmentTableAnnotationComposer(
        $db: $db,
        $table: $db.userEquipment,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return f(composer);
  }

  Expression<T> userLimitationsRefs<T extends Object>(Expression<T> Function($$UserLimitationsTableAnnotationComposer a) f) {
    final $$UserLimitationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userLimitations,
      getReferencedColumn: (t) => t.userId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$UserLimitationsTableAnnotationComposer(
        $db: $db,
        $table: $db.userLimitations,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return f(composer);
  }

  Expression<T> workoutProgramsRefs<T extends Object>(Expression<T> Function($$WorkoutProgramsTableAnnotationComposer a) f) {
    final $$WorkoutProgramsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutPrograms,
      getReferencedColumn: (t) => t.userId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$WorkoutProgramsTableAnnotationComposer(
        $db: $db,
        $table: $db.workoutPrograms,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
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
          User,
          $$UsersTableFilterComposer,
          $$UsersTableOrderingComposer,
          $$UsersTableAnnotationComposer,
          $$UsersTableCreateCompanionBuilder,
          $$UsersTableUpdateCompanionBuilder,
          (User, $$UsersTableReferences),
          User,
          PrefetchHooks Function({bool userProfilesRefs, bool userGoalsRefs, bool userEquipmentRefs, bool userLimitationsRefs, bool workoutProgramsRefs})
        > {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({Value<int> id = const Value.absent(), Value<DateTime> createdAt = const Value.absent()}) =>
              UsersCompanion(id: id, createdAt: createdAt),
          createCompanionCallback: ({Value<int> id = const Value.absent(), Value<DateTime> createdAt = const Value.absent()}) =>
              UsersCompanion.insert(id: id, createdAt: createdAt),
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable<$UsersTable, User>(table), $$UsersTableReferences(db, table, e))).toList(),
          prefetchHooksCallback:
              ({userProfilesRefs = false, userGoalsRefs = false, userEquipmentRefs = false, userLimitationsRefs = false, workoutProgramsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (userProfilesRefs) db.userProfiles,
                    if (userGoalsRefs) db.userGoals,
                    if (userEquipmentRefs) db.userEquipment,
                    if (userLimitationsRefs) db.userLimitations,
                    if (workoutProgramsRefs) db.workoutPrograms,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (userProfilesRefs)
                        await $_getPrefetchedDataByColumns<User, $UsersTable, UserProfileRow, $UserProfilesTable>(
                          currentTable: table,
                          referencedTable: $$UsersTableReferences._userProfilesRefsTable(db),
                          managerFromTypedResult: (p0) => $$UsersTableReferences(db, table, p0).userProfilesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'user_id',
                          typedResults: items,
                        ),
                      if (userGoalsRefs)
                        await $_getPrefetchedDataByColumns<User, $UsersTable, UserGoal, $UserGoalsTable>(
                          currentTable: table,
                          referencedTable: $$UsersTableReferences._userGoalsRefsTable(db),
                          managerFromTypedResult: (p0) => $$UsersTableReferences(db, table, p0).userGoalsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'user_id',
                          typedResults: items,
                        ),
                      if (userEquipmentRefs)
                        await $_getPrefetchedDataByColumns<User, $UsersTable, UserEquipmentData, $UserEquipmentTable>(
                          currentTable: table,
                          referencedTable: $$UsersTableReferences._userEquipmentRefsTable(db),
                          managerFromTypedResult: (p0) => $$UsersTableReferences(db, table, p0).userEquipmentRefs,
                          currentColumn: 'id',
                          referencedColumn: 'user_id',
                          typedResults: items,
                        ),
                      if (userLimitationsRefs)
                        await $_getPrefetchedDataByColumns<User, $UsersTable, UserLimitation, $UserLimitationsTable>(
                          currentTable: table,
                          referencedTable: $$UsersTableReferences._userLimitationsRefsTable(db),
                          managerFromTypedResult: (p0) => $$UsersTableReferences(db, table, p0).userLimitationsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'user_id',
                          typedResults: items,
                        ),
                      if (workoutProgramsRefs)
                        await $_getPrefetchedDataByColumns<User, $UsersTable, WorkoutProgram, $WorkoutProgramsTable>(
                          currentTable: table,
                          referencedTable: $$UsersTableReferences._workoutProgramsRefsTable(db),
                          managerFromTypedResult: (p0) => $$UsersTableReferences(db, table, p0).workoutProgramsRefs,
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
      User,
      $$UsersTableFilterComposer,
      $$UsersTableOrderingComposer,
      $$UsersTableAnnotationComposer,
      $$UsersTableCreateCompanionBuilder,
      $$UsersTableUpdateCompanionBuilder,
      (User, $$UsersTableReferences),
      User,
      PrefetchHooks Function({bool userProfilesRefs, bool userGoalsRefs, bool userEquipmentRefs, bool userLimitationsRefs, bool workoutProgramsRefs})
    >;
typedef $$UserProfilesTableCreateCompanionBuilder = UserProfilesCompanion Function({
  Value<int> userId,
  required String sex,
  required int age,
  required double heightCm,
  required double weightKg,
  Value<double?> targetWeightKg,
  Value<double?> bodyFatPct,
  Value<double?> skeletalMuscleKg,
  required String experience,
  required int daysPerWeek,
  required int sessionMinutes,
  required String environment,
  Value<DateTime> updatedAt,
});
typedef $$UserProfilesTableUpdateCompanionBuilder = UserProfilesCompanion Function({
  Value<int> userId,
  Value<String> sex,
  Value<int> age,
  Value<double> heightCm,
  Value<double> weightKg,
  Value<double?> targetWeightKg,
  Value<double?> bodyFatPct,
  Value<double?> skeletalMuscleKg,
  Value<String> experience,
  Value<int> daysPerWeek,
  Value<int> sessionMinutes,
  Value<String> environment,
  Value<DateTime> updatedAt,
});

final class $$UserProfilesTableReferences extends BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfileRow> {
  $$UserProfilesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _userIdTable(_$AppDatabase db) => db.users.createAlias('user_profiles__user_id__users__id');

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<int>('user_id')!;

    final manager = $$UsersTableTableManager($_db, $_db.users).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$UserProfilesTableFilterComposer extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get sex => $composableBuilder(column: $table.sex, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get age => $composableBuilder(column: $table.age, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get heightCm => $composableBuilder(column: $table.heightCm, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get weightKg => $composableBuilder(column: $table.weightKg, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get targetWeightKg => $composableBuilder(column: $table.targetWeightKg, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get bodyFatPct => $composableBuilder(column: $table.bodyFatPct, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get skeletalMuscleKg => $composableBuilder(column: $table.skeletalMuscleKg, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get experience => $composableBuilder(column: $table.experience, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get daysPerWeek => $composableBuilder(column: $table.daysPerWeek, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sessionMinutes => $composableBuilder(column: $table.sessionMinutes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get environment => $composableBuilder(column: $table.environment, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$UsersTableFilterComposer(
        $db: $db,
        $table: $db.users,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return composer;
  }
}

class $$UserProfilesTableOrderingComposer extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get sex => $composableBuilder(column: $table.sex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get age => $composableBuilder(column: $table.age, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get heightCm => $composableBuilder(column: $table.heightCm, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get weightKg => $composableBuilder(column: $table.weightKg, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get targetWeightKg => $composableBuilder(column: $table.targetWeightKg, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get bodyFatPct => $composableBuilder(column: $table.bodyFatPct, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get skeletalMuscleKg => $composableBuilder(column: $table.skeletalMuscleKg, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get experience => $composableBuilder(column: $table.experience, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get daysPerWeek => $composableBuilder(column: $table.daysPerWeek, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sessionMinutes => $composableBuilder(column: $table.sessionMinutes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get environment => $composableBuilder(column: $table.environment, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$UsersTableOrderingComposer(
        $db: $db,
        $table: $db.users,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return composer;
  }
}

class $$UserProfilesTableAnnotationComposer extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get sex => $composableBuilder(column: $table.sex, builder: (column) => column);

  GeneratedColumn<int> get age => $composableBuilder(column: $table.age, builder: (column) => column);

  GeneratedColumn<double> get heightCm => $composableBuilder(column: $table.heightCm, builder: (column) => column);

  GeneratedColumn<double> get weightKg => $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<double> get targetWeightKg => $composableBuilder(column: $table.targetWeightKg, builder: (column) => column);

  GeneratedColumn<double> get bodyFatPct => $composableBuilder(column: $table.bodyFatPct, builder: (column) => column);

  GeneratedColumn<double> get skeletalMuscleKg => $composableBuilder(column: $table.skeletalMuscleKg, builder: (column) => column);

  GeneratedColumn<String> get experience => $composableBuilder(column: $table.experience, builder: (column) => column);

  GeneratedColumn<int> get daysPerWeek => $composableBuilder(column: $table.daysPerWeek, builder: (column) => column);

  GeneratedColumn<int> get sessionMinutes => $composableBuilder(column: $table.sessionMinutes, builder: (column) => column);

  GeneratedColumn<String> get environment => $composableBuilder(column: $table.environment, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt => $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$UsersTableAnnotationComposer(
        $db: $db,
        $table: $db.users,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return composer;
  }
}

class $$UserProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserProfilesTable,
          UserProfileRow,
          $$UserProfilesTableFilterComposer,
          $$UserProfilesTableOrderingComposer,
          $$UserProfilesTableAnnotationComposer,
          $$UserProfilesTableCreateCompanionBuilder,
          $$UserProfilesTableUpdateCompanionBuilder,
          (UserProfileRow, $$UserProfilesTableReferences),
          UserProfileRow,
          PrefetchHooks Function({bool userId})
        > {
  $$UserProfilesTableTableManager(_$AppDatabase db, $UserProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$UserProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$UserProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$UserProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> userId = const Value.absent(),
                Value<String> sex = const Value.absent(),
                Value<int> age = const Value.absent(),
                Value<double> heightCm = const Value.absent(),
                Value<double> weightKg = const Value.absent(),
                Value<double?> targetWeightKg = const Value.absent(),
                Value<double?> bodyFatPct = const Value.absent(),
                Value<double?> skeletalMuscleKg = const Value.absent(),
                Value<String> experience = const Value.absent(),
                Value<int> daysPerWeek = const Value.absent(),
                Value<int> sessionMinutes = const Value.absent(),
                Value<String> environment = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => UserProfilesCompanion(
                userId: userId,
                sex: sex,
                age: age,
                heightCm: heightCm,
                weightKg: weightKg,
                targetWeightKg: targetWeightKg,
                bodyFatPct: bodyFatPct,
                skeletalMuscleKg: skeletalMuscleKg,
                experience: experience,
                daysPerWeek: daysPerWeek,
                sessionMinutes: sessionMinutes,
                environment: environment,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> userId = const Value.absent(),
                required String sex,
                required int age,
                required double heightCm,
                required double weightKg,
                Value<double?> targetWeightKg = const Value.absent(),
                Value<double?> bodyFatPct = const Value.absent(),
                Value<double?> skeletalMuscleKg = const Value.absent(),
                required String experience,
                required int daysPerWeek,
                required int sessionMinutes,
                required String environment,
                Value<DateTime> updatedAt = const Value.absent(),
              }) => UserProfilesCompanion.insert(
                userId: userId,
                sex: sex,
                age: age,
                heightCm: heightCm,
                weightKg: weightKg,
                targetWeightKg: targetWeightKg,
                bodyFatPct: bodyFatPct,
                skeletalMuscleKg: skeletalMuscleKg,
                experience: experience,
                daysPerWeek: daysPerWeek,
                sessionMinutes: sessionMinutes,
                environment: environment,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable<$UserProfilesTable, UserProfileRow>(table), $$UserProfilesTableReferences(db, table, e))).toList(),
          prefetchHooksCallback: ({userId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <T extends TableManagerState<dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic>>(state) {
                    if (userId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.userId,
                        referencedTable: $$UserProfilesTableReferences._userIdTable(db),
                        referencedColumn: $$UserProfilesTableReferences._userIdTable(db).id,
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

typedef $$UserProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserProfilesTable,
      UserProfileRow,
      $$UserProfilesTableFilterComposer,
      $$UserProfilesTableOrderingComposer,
      $$UserProfilesTableAnnotationComposer,
      $$UserProfilesTableCreateCompanionBuilder,
      $$UserProfilesTableUpdateCompanionBuilder,
      (UserProfileRow, $$UserProfilesTableReferences),
      UserProfileRow,
      PrefetchHooks Function({bool userId})
    >;
typedef $$UserGoalsTableCreateCompanionBuilder = UserGoalsCompanion Function({Value<int> id, required int userId, required String goal, required int priority});
typedef $$UserGoalsTableUpdateCompanionBuilder = UserGoalsCompanion Function({Value<int> id, Value<int> userId, Value<String> goal, Value<int> priority});

final class $$UserGoalsTableReferences extends BaseReferences<_$AppDatabase, $UserGoalsTable, UserGoal> {
  $$UserGoalsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _userIdTable(_$AppDatabase db) => db.users.createAlias('user_goals__user_id__users__id');

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<int>('user_id')!;

    final manager = $$UsersTableTableManager($_db, $_db.users).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$UserGoalsTableFilterComposer extends Composer<_$AppDatabase, $UserGoalsTable> {
  $$UserGoalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get goal => $composableBuilder(column: $table.goal, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get priority => $composableBuilder(column: $table.priority, builder: (column) => ColumnFilters(column));

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$UsersTableFilterComposer(
        $db: $db,
        $table: $db.users,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return composer;
  }
}

class $$UserGoalsTableOrderingComposer extends Composer<_$AppDatabase, $UserGoalsTable> {
  $$UserGoalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get goal => $composableBuilder(column: $table.goal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get priority => $composableBuilder(column: $table.priority, builder: (column) => ColumnOrderings(column));

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$UsersTableOrderingComposer(
        $db: $db,
        $table: $db.users,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return composer;
  }
}

class $$UserGoalsTableAnnotationComposer extends Composer<_$AppDatabase, $UserGoalsTable> {
  $$UserGoalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get goal => $composableBuilder(column: $table.goal, builder: (column) => column);

  GeneratedColumn<int> get priority => $composableBuilder(column: $table.priority, builder: (column) => column);

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$UsersTableAnnotationComposer(
        $db: $db,
        $table: $db.users,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return composer;
  }
}

class $$UserGoalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserGoalsTable,
          UserGoal,
          $$UserGoalsTableFilterComposer,
          $$UserGoalsTableOrderingComposer,
          $$UserGoalsTableAnnotationComposer,
          $$UserGoalsTableCreateCompanionBuilder,
          $$UserGoalsTableUpdateCompanionBuilder,
          (UserGoal, $$UserGoalsTableReferences),
          UserGoal,
          PrefetchHooks Function({bool userId})
        > {
  $$UserGoalsTableTableManager(_$AppDatabase db, $UserGoalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$UserGoalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$UserGoalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$UserGoalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> userId = const Value.absent(),
            Value<String> goal = const Value.absent(),
            Value<int> priority = const Value.absent(),
          }) => UserGoalsCompanion(id: id, userId: userId, goal: goal, priority: priority),
          createCompanionCallback: ({Value<int> id = const Value.absent(), required int userId, required String goal, required int priority}) =>
              UserGoalsCompanion.insert(id: id, userId: userId, goal: goal, priority: priority),
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable<$UserGoalsTable, UserGoal>(table), $$UserGoalsTableReferences(db, table, e))).toList(),
          prefetchHooksCallback: ({userId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <T extends TableManagerState<dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic>>(state) {
                    if (userId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.userId,
                        referencedTable: $$UserGoalsTableReferences._userIdTable(db),
                        referencedColumn: $$UserGoalsTableReferences._userIdTable(db).id,
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

typedef $$UserGoalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserGoalsTable,
      UserGoal,
      $$UserGoalsTableFilterComposer,
      $$UserGoalsTableOrderingComposer,
      $$UserGoalsTableAnnotationComposer,
      $$UserGoalsTableCreateCompanionBuilder,
      $$UserGoalsTableUpdateCompanionBuilder,
      (UserGoal, $$UserGoalsTableReferences),
      UserGoal,
      PrefetchHooks Function({bool userId})
    >;
typedef $$UserEquipmentTableCreateCompanionBuilder = UserEquipmentCompanion Function({required int userId, required String equipment, Value<int> rowid});
typedef $$UserEquipmentTableUpdateCompanionBuilder = UserEquipmentCompanion Function({Value<int> userId, Value<String> equipment, Value<int> rowid});

final class $$UserEquipmentTableReferences extends BaseReferences<_$AppDatabase, $UserEquipmentTable, UserEquipmentData> {
  $$UserEquipmentTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _userIdTable(_$AppDatabase db) => db.users.createAlias('user_equipment__user_id__users__id');

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<int>('user_id')!;

    final manager = $$UsersTableTableManager($_db, $_db.users).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$UserEquipmentTableFilterComposer extends Composer<_$AppDatabase, $UserEquipmentTable> {
  $$UserEquipmentTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get equipment => $composableBuilder(column: $table.equipment, builder: (column) => ColumnFilters(column));

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$UsersTableFilterComposer(
        $db: $db,
        $table: $db.users,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return composer;
  }
}

class $$UserEquipmentTableOrderingComposer extends Composer<_$AppDatabase, $UserEquipmentTable> {
  $$UserEquipmentTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get equipment => $composableBuilder(column: $table.equipment, builder: (column) => ColumnOrderings(column));

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$UsersTableOrderingComposer(
        $db: $db,
        $table: $db.users,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return composer;
  }
}

class $$UserEquipmentTableAnnotationComposer extends Composer<_$AppDatabase, $UserEquipmentTable> {
  $$UserEquipmentTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get equipment => $composableBuilder(column: $table.equipment, builder: (column) => column);

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$UsersTableAnnotationComposer(
        $db: $db,
        $table: $db.users,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return composer;
  }
}

class $$UserEquipmentTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserEquipmentTable,
          UserEquipmentData,
          $$UserEquipmentTableFilterComposer,
          $$UserEquipmentTableOrderingComposer,
          $$UserEquipmentTableAnnotationComposer,
          $$UserEquipmentTableCreateCompanionBuilder,
          $$UserEquipmentTableUpdateCompanionBuilder,
          (UserEquipmentData, $$UserEquipmentTableReferences),
          UserEquipmentData,
          PrefetchHooks Function({bool userId})
        > {
  $$UserEquipmentTableTableManager(_$AppDatabase db, $UserEquipmentTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$UserEquipmentTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$UserEquipmentTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$UserEquipmentTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> userId = const Value.absent(),
            Value<String> equipment = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => UserEquipmentCompanion(userId: userId, equipment: equipment, rowid: rowid),
          createCompanionCallback: ({required int userId, required String equipment, Value<int> rowid = const Value.absent()}) =>
              UserEquipmentCompanion.insert(userId: userId, equipment: equipment, rowid: rowid),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable<$UserEquipmentTable, UserEquipmentData>(table), $$UserEquipmentTableReferences(db, table, e))).toList(),
          prefetchHooksCallback: ({userId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <T extends TableManagerState<dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic>>(state) {
                    if (userId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.userId,
                        referencedTable: $$UserEquipmentTableReferences._userIdTable(db),
                        referencedColumn: $$UserEquipmentTableReferences._userIdTable(db).id,
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

typedef $$UserEquipmentTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserEquipmentTable,
      UserEquipmentData,
      $$UserEquipmentTableFilterComposer,
      $$UserEquipmentTableOrderingComposer,
      $$UserEquipmentTableAnnotationComposer,
      $$UserEquipmentTableCreateCompanionBuilder,
      $$UserEquipmentTableUpdateCompanionBuilder,
      (UserEquipmentData, $$UserEquipmentTableReferences),
      UserEquipmentData,
      PrefetchHooks Function({bool userId})
    >;
typedef $$UserLimitationsTableCreateCompanionBuilder = UserLimitationsCompanion Function({
  Value<int> id,
  required int userId,
  required String area,
  required int severity,
  Value<String> timing,
  Value<String> notes,
  Value<bool> active,
});
typedef $$UserLimitationsTableUpdateCompanionBuilder = UserLimitationsCompanion Function({
  Value<int> id,
  Value<int> userId,
  Value<String> area,
  Value<int> severity,
  Value<String> timing,
  Value<String> notes,
  Value<bool> active,
});

final class $$UserLimitationsTableReferences extends BaseReferences<_$AppDatabase, $UserLimitationsTable, UserLimitation> {
  $$UserLimitationsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _userIdTable(_$AppDatabase db) => db.users.createAlias('user_limitations__user_id__users__id');

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<int>('user_id')!;

    final manager = $$UsersTableTableManager($_db, $_db.users).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$UserLimitationsTableFilterComposer extends Composer<_$AppDatabase, $UserLimitationsTable> {
  $$UserLimitationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get area => $composableBuilder(column: $table.area, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get severity => $composableBuilder(column: $table.severity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get timing => $composableBuilder(column: $table.timing, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get active => $composableBuilder(column: $table.active, builder: (column) => ColumnFilters(column));

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$UsersTableFilterComposer(
        $db: $db,
        $table: $db.users,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return composer;
  }
}

class $$UserLimitationsTableOrderingComposer extends Composer<_$AppDatabase, $UserLimitationsTable> {
  $$UserLimitationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get area => $composableBuilder(column: $table.area, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get severity => $composableBuilder(column: $table.severity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get timing => $composableBuilder(column: $table.timing, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get active => $composableBuilder(column: $table.active, builder: (column) => ColumnOrderings(column));

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$UsersTableOrderingComposer(
        $db: $db,
        $table: $db.users,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return composer;
  }
}

class $$UserLimitationsTableAnnotationComposer extends Composer<_$AppDatabase, $UserLimitationsTable> {
  $$UserLimitationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get area => $composableBuilder(column: $table.area, builder: (column) => column);

  GeneratedColumn<int> get severity => $composableBuilder(column: $table.severity, builder: (column) => column);

  GeneratedColumn<String> get timing => $composableBuilder(column: $table.timing, builder: (column) => column);

  GeneratedColumn<String> get notes => $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get active => $composableBuilder(column: $table.active, builder: (column) => column);

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$UsersTableAnnotationComposer(
        $db: $db,
        $table: $db.users,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return composer;
  }
}

class $$UserLimitationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserLimitationsTable,
          UserLimitation,
          $$UserLimitationsTableFilterComposer,
          $$UserLimitationsTableOrderingComposer,
          $$UserLimitationsTableAnnotationComposer,
          $$UserLimitationsTableCreateCompanionBuilder,
          $$UserLimitationsTableUpdateCompanionBuilder,
          (UserLimitation, $$UserLimitationsTableReferences),
          UserLimitation,
          PrefetchHooks Function({bool userId})
        > {
  $$UserLimitationsTableTableManager(_$AppDatabase db, $UserLimitationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$UserLimitationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$UserLimitationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$UserLimitationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> userId = const Value.absent(),
            Value<String> area = const Value.absent(),
            Value<int> severity = const Value.absent(),
            Value<String> timing = const Value.absent(),
            Value<String> notes = const Value.absent(),
            Value<bool> active = const Value.absent(),
          }) => UserLimitationsCompanion(id: id, userId: userId, area: area, severity: severity, timing: timing, notes: notes, active: active),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int userId,
            required String area,
            required int severity,
            Value<String> timing = const Value.absent(),
            Value<String> notes = const Value.absent(),
            Value<bool> active = const Value.absent(),
          }) => UserLimitationsCompanion.insert(id: id, userId: userId, area: area, severity: severity, timing: timing, notes: notes, active: active),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable<$UserLimitationsTable, UserLimitation>(table), $$UserLimitationsTableReferences(db, table, e))).toList(),
          prefetchHooksCallback: ({userId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <T extends TableManagerState<dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic>>(state) {
                    if (userId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.userId,
                        referencedTable: $$UserLimitationsTableReferences._userIdTable(db),
                        referencedColumn: $$UserLimitationsTableReferences._userIdTable(db).id,
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

typedef $$UserLimitationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserLimitationsTable,
      UserLimitation,
      $$UserLimitationsTableFilterComposer,
      $$UserLimitationsTableOrderingComposer,
      $$UserLimitationsTableAnnotationComposer,
      $$UserLimitationsTableCreateCompanionBuilder,
      $$UserLimitationsTableUpdateCompanionBuilder,
      (UserLimitation, $$UserLimitationsTableReferences),
      UserLimitation,
      PrefetchHooks Function({bool userId})
    >;
typedef $$ExercisesTableCreateCompanionBuilder = ExercisesCompanion Function({
  required String id,
  required String nameKo,
  required String nameEn,
  required String equipment,
  required String type,
  required String pattern,
  required int difficulty,
  required int repMin,
  required int repMax,
  required int restSec,
  required String description,
  required String cues,
  required String mistakes,
  required String cautions,
  required String jointStress,
  required String referenceIds,
  Value<String?> videoUrl,
  Value<bool> assisted,
  Value<bool> bodyweight,
  Value<bool> timed,
  Value<bool> isCustom,
  Value<int> rowid,
});
typedef $$ExercisesTableUpdateCompanionBuilder = ExercisesCompanion Function({
  Value<String> id,
  Value<String> nameKo,
  Value<String> nameEn,
  Value<String> equipment,
  Value<String> type,
  Value<String> pattern,
  Value<int> difficulty,
  Value<int> repMin,
  Value<int> repMax,
  Value<int> restSec,
  Value<String> description,
  Value<String> cues,
  Value<String> mistakes,
  Value<String> cautions,
  Value<String> jointStress,
  Value<String> referenceIds,
  Value<String?> videoUrl,
  Value<bool> assisted,
  Value<bool> bodyweight,
  Value<bool> timed,
  Value<bool> isCustom,
  Value<int> rowid,
});

final class $$ExercisesTableReferences extends BaseReferences<_$AppDatabase, $ExercisesTable, ExerciseRow> {
  $$ExercisesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ExerciseMusclesTable, List<ExerciseMuscle>> _exerciseMusclesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.exerciseMuscles, aliasName: 'exercises__id__exercise_muscles__exercise_id');

  $$ExerciseMusclesTableProcessedTableManager get exerciseMusclesRefs {
    final manager = $$ExerciseMusclesTableTableManager($_db, $_db.exerciseMuscles).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_exerciseMusclesRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ExerciseAlternativesTable, List<ExerciseAlternative>> _exerciseAlternativesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.exerciseAlternatives, aliasName: 'exercises__id__exercise_alternatives__exercise_id');

  $$ExerciseAlternativesTableProcessedTableManager get exerciseAlternativesRefs {
    final manager = $$ExerciseAlternativesTableTableManager(
      $_db,
      $_db.exerciseAlternatives,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_exerciseAlternativesRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ExerciseAlternativesTable, List<ExerciseAlternative>> _alternativeOfTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.exerciseAlternatives, aliasName: 'exercises__id__exercise_alternatives__alternative_id');

  $$ExerciseAlternativesTableProcessedTableManager get alternativeOf {
    final manager = $$ExerciseAlternativesTableTableManager(
      $_db,
      $_db.exerciseAlternatives,
    ).filter((f) => f.alternativeId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_alternativeOfTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$WorkoutExercisesTable, List<WorkoutExercise>> _workoutExercisesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.workoutExercises, aliasName: 'exercises__id__workout_exercises__exercise_id');

  $$WorkoutExercisesTableProcessedTableManager get workoutExercisesRefs {
    final manager = $$WorkoutExercisesTableTableManager($_db, $_db.workoutExercises).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_workoutExercisesRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$WorkoutSessionExercisesTable, List<SessionExercise>> _workoutSessionExercisesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.workoutSessionExercises, aliasName: 'exercises__id__workout_session_exercises__exercise_id');

  $$WorkoutSessionExercisesTableProcessedTableManager get workoutSessionExercisesRefs {
    final manager = $$WorkoutSessionExercisesTableTableManager(
      $_db,
      $_db.workoutSessionExercises,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_workoutSessionExercisesRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ExercisesTableFilterComposer extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nameKo => $composableBuilder(column: $table.nameKo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nameEn => $composableBuilder(column: $table.nameEn, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get equipment => $composableBuilder(column: $table.equipment, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get pattern => $composableBuilder(column: $table.pattern, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get difficulty => $composableBuilder(column: $table.difficulty, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get repMin => $composableBuilder(column: $table.repMin, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get repMax => $composableBuilder(column: $table.repMax, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get restSec => $composableBuilder(column: $table.restSec, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cues => $composableBuilder(column: $table.cues, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mistakes => $composableBuilder(column: $table.mistakes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cautions => $composableBuilder(column: $table.cautions, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get jointStress => $composableBuilder(column: $table.jointStress, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get referenceIds => $composableBuilder(column: $table.referenceIds, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get videoUrl => $composableBuilder(column: $table.videoUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get assisted => $composableBuilder(column: $table.assisted, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get bodyweight => $composableBuilder(column: $table.bodyweight, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get timed => $composableBuilder(column: $table.timed, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCustom => $composableBuilder(column: $table.isCustom, builder: (column) => ColumnFilters(column));

  Expression<bool> exerciseMusclesRefs(Expression<bool> Function($$ExerciseMusclesTableFilterComposer f) f) {
    final $$ExerciseMusclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseMuscles,
      getReferencedColumn: (t) => t.exerciseId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$ExerciseMusclesTableFilterComposer(
        $db: $db,
        $table: $db.exerciseMuscles,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return f(composer);
  }

  Expression<bool> exerciseAlternativesRefs(Expression<bool> Function($$ExerciseAlternativesTableFilterComposer f) f) {
    final $$ExerciseAlternativesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseAlternatives,
      getReferencedColumn: (t) => t.exerciseId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$ExerciseAlternativesTableFilterComposer(
        $db: $db,
        $table: $db.exerciseAlternatives,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return f(composer);
  }

  Expression<bool> alternativeOf(Expression<bool> Function($$ExerciseAlternativesTableFilterComposer f) f) {
    final $$ExerciseAlternativesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseAlternatives,
      getReferencedColumn: (t) => t.alternativeId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$ExerciseAlternativesTableFilterComposer(
        $db: $db,
        $table: $db.exerciseAlternatives,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return f(composer);
  }

  Expression<bool> workoutExercisesRefs(Expression<bool> Function($$WorkoutExercisesTableFilterComposer f) f) {
    final $$WorkoutExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutExercises,
      getReferencedColumn: (t) => t.exerciseId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$WorkoutExercisesTableFilterComposer(
        $db: $db,
        $table: $db.workoutExercises,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return f(composer);
  }

  Expression<bool> workoutSessionExercisesRefs(Expression<bool> Function($$WorkoutSessionExercisesTableFilterComposer f) f) {
    final $$WorkoutSessionExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutSessionExercises,
      getReferencedColumn: (t) => t.exerciseId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$WorkoutSessionExercisesTableFilterComposer(
        $db: $db,
        $table: $db.workoutSessionExercises,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return f(composer);
  }
}

class $$ExercisesTableOrderingComposer extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nameKo => $composableBuilder(column: $table.nameKo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nameEn => $composableBuilder(column: $table.nameEn, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get equipment => $composableBuilder(column: $table.equipment, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get pattern => $composableBuilder(column: $table.pattern, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get difficulty => $composableBuilder(column: $table.difficulty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get repMin => $composableBuilder(column: $table.repMin, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get repMax => $composableBuilder(column: $table.repMax, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get restSec => $composableBuilder(column: $table.restSec, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cues => $composableBuilder(column: $table.cues, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mistakes => $composableBuilder(column: $table.mistakes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cautions => $composableBuilder(column: $table.cautions, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get jointStress => $composableBuilder(column: $table.jointStress, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get referenceIds => $composableBuilder(column: $table.referenceIds, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get videoUrl => $composableBuilder(column: $table.videoUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get assisted => $composableBuilder(column: $table.assisted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get bodyweight => $composableBuilder(column: $table.bodyweight, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get timed => $composableBuilder(column: $table.timed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCustom => $composableBuilder(column: $table.isCustom, builder: (column) => ColumnOrderings(column));
}

class $$ExercisesTableAnnotationComposer extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nameKo => $composableBuilder(column: $table.nameKo, builder: (column) => column);

  GeneratedColumn<String> get nameEn => $composableBuilder(column: $table.nameEn, builder: (column) => column);

  GeneratedColumn<String> get equipment => $composableBuilder(column: $table.equipment, builder: (column) => column);

  GeneratedColumn<String> get type => $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get pattern => $composableBuilder(column: $table.pattern, builder: (column) => column);

  GeneratedColumn<int> get difficulty => $composableBuilder(column: $table.difficulty, builder: (column) => column);

  GeneratedColumn<int> get repMin => $composableBuilder(column: $table.repMin, builder: (column) => column);

  GeneratedColumn<int> get repMax => $composableBuilder(column: $table.repMax, builder: (column) => column);

  GeneratedColumn<int> get restSec => $composableBuilder(column: $table.restSec, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get cues => $composableBuilder(column: $table.cues, builder: (column) => column);

  GeneratedColumn<String> get mistakes => $composableBuilder(column: $table.mistakes, builder: (column) => column);

  GeneratedColumn<String> get cautions => $composableBuilder(column: $table.cautions, builder: (column) => column);

  GeneratedColumn<String> get jointStress => $composableBuilder(column: $table.jointStress, builder: (column) => column);

  GeneratedColumn<String> get referenceIds => $composableBuilder(column: $table.referenceIds, builder: (column) => column);

  GeneratedColumn<String> get videoUrl => $composableBuilder(column: $table.videoUrl, builder: (column) => column);

  GeneratedColumn<bool> get assisted => $composableBuilder(column: $table.assisted, builder: (column) => column);

  GeneratedColumn<bool> get bodyweight => $composableBuilder(column: $table.bodyweight, builder: (column) => column);

  GeneratedColumn<bool> get timed => $composableBuilder(column: $table.timed, builder: (column) => column);

  GeneratedColumn<bool> get isCustom => $composableBuilder(column: $table.isCustom, builder: (column) => column);

  Expression<T> exerciseMusclesRefs<T extends Object>(Expression<T> Function($$ExerciseMusclesTableAnnotationComposer a) f) {
    final $$ExerciseMusclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseMuscles,
      getReferencedColumn: (t) => t.exerciseId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$ExerciseMusclesTableAnnotationComposer(
        $db: $db,
        $table: $db.exerciseMuscles,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return f(composer);
  }

  Expression<T> exerciseAlternativesRefs<T extends Object>(Expression<T> Function($$ExerciseAlternativesTableAnnotationComposer a) f) {
    final $$ExerciseAlternativesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseAlternatives,
      getReferencedColumn: (t) => t.exerciseId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$ExerciseAlternativesTableAnnotationComposer(
        $db: $db,
        $table: $db.exerciseAlternatives,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return f(composer);
  }

  Expression<T> alternativeOf<T extends Object>(Expression<T> Function($$ExerciseAlternativesTableAnnotationComposer a) f) {
    final $$ExerciseAlternativesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseAlternatives,
      getReferencedColumn: (t) => t.alternativeId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$ExerciseAlternativesTableAnnotationComposer(
        $db: $db,
        $table: $db.exerciseAlternatives,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return f(composer);
  }

  Expression<T> workoutExercisesRefs<T extends Object>(Expression<T> Function($$WorkoutExercisesTableAnnotationComposer a) f) {
    final $$WorkoutExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutExercises,
      getReferencedColumn: (t) => t.exerciseId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$WorkoutExercisesTableAnnotationComposer(
        $db: $db,
        $table: $db.workoutExercises,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return f(composer);
  }

  Expression<T> workoutSessionExercisesRefs<T extends Object>(Expression<T> Function($$WorkoutSessionExercisesTableAnnotationComposer a) f) {
    final $$WorkoutSessionExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutSessionExercises,
      getReferencedColumn: (t) => t.exerciseId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$WorkoutSessionExercisesTableAnnotationComposer(
        $db: $db,
        $table: $db.workoutSessionExercises,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return f(composer);
  }
}

class $$ExercisesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExercisesTable,
          ExerciseRow,
          $$ExercisesTableFilterComposer,
          $$ExercisesTableOrderingComposer,
          $$ExercisesTableAnnotationComposer,
          $$ExercisesTableCreateCompanionBuilder,
          $$ExercisesTableUpdateCompanionBuilder,
          (ExerciseRow, $$ExercisesTableReferences),
          ExerciseRow,
          PrefetchHooks Function({
            bool exerciseMusclesRefs,
            bool exerciseAlternativesRefs,
            bool alternativeOf,
            bool workoutExercisesRefs,
            bool workoutSessionExercisesRefs,
          })
        > {
  $$ExercisesTableTableManager(_$AppDatabase db, $ExercisesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$ExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$ExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$ExercisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> nameKo = const Value.absent(),
                Value<String> nameEn = const Value.absent(),
                Value<String> equipment = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> pattern = const Value.absent(),
                Value<int> difficulty = const Value.absent(),
                Value<int> repMin = const Value.absent(),
                Value<int> repMax = const Value.absent(),
                Value<int> restSec = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> cues = const Value.absent(),
                Value<String> mistakes = const Value.absent(),
                Value<String> cautions = const Value.absent(),
                Value<String> jointStress = const Value.absent(),
                Value<String> referenceIds = const Value.absent(),
                Value<String?> videoUrl = const Value.absent(),
                Value<bool> assisted = const Value.absent(),
                Value<bool> bodyweight = const Value.absent(),
                Value<bool> timed = const Value.absent(),
                Value<bool> isCustom = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExercisesCompanion(
                id: id,
                nameKo: nameKo,
                nameEn: nameEn,
                equipment: equipment,
                type: type,
                pattern: pattern,
                difficulty: difficulty,
                repMin: repMin,
                repMax: repMax,
                restSec: restSec,
                description: description,
                cues: cues,
                mistakes: mistakes,
                cautions: cautions,
                jointStress: jointStress,
                referenceIds: referenceIds,
                videoUrl: videoUrl,
                assisted: assisted,
                bodyweight: bodyweight,
                timed: timed,
                isCustom: isCustom,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String nameKo,
                required String nameEn,
                required String equipment,
                required String type,
                required String pattern,
                required int difficulty,
                required int repMin,
                required int repMax,
                required int restSec,
                required String description,
                required String cues,
                required String mistakes,
                required String cautions,
                required String jointStress,
                required String referenceIds,
                Value<String?> videoUrl = const Value.absent(),
                Value<bool> assisted = const Value.absent(),
                Value<bool> bodyweight = const Value.absent(),
                Value<bool> timed = const Value.absent(),
                Value<bool> isCustom = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExercisesCompanion.insert(
                id: id,
                nameKo: nameKo,
                nameEn: nameEn,
                equipment: equipment,
                type: type,
                pattern: pattern,
                difficulty: difficulty,
                repMin: repMin,
                repMax: repMax,
                restSec: restSec,
                description: description,
                cues: cues,
                mistakes: mistakes,
                cautions: cautions,
                jointStress: jointStress,
                referenceIds: referenceIds,
                videoUrl: videoUrl,
                assisted: assisted,
                bodyweight: bodyweight,
                timed: timed,
                isCustom: isCustom,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable<$ExercisesTable, ExerciseRow>(table), $$ExercisesTableReferences(db, table, e))).toList(),
          prefetchHooksCallback:
              ({
                exerciseMusclesRefs = false,
                exerciseAlternativesRefs = false,
                alternativeOf = false,
                workoutExercisesRefs = false,
                workoutSessionExercisesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (exerciseMusclesRefs) db.exerciseMuscles,
                    if (exerciseAlternativesRefs) db.exerciseAlternatives,
                    if (alternativeOf) db.exerciseAlternatives,
                    if (workoutExercisesRefs) db.workoutExercises,
                    if (workoutSessionExercisesRefs) db.workoutSessionExercises,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (exerciseMusclesRefs)
                        await $_getPrefetchedDataByColumns<ExerciseRow, $ExercisesTable, ExerciseMuscle, $ExerciseMusclesTable>(
                          currentTable: table,
                          referencedTable: $$ExercisesTableReferences._exerciseMusclesRefsTable(db),
                          managerFromTypedResult: (p0) => $$ExercisesTableReferences(db, table, p0).exerciseMusclesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'exercise_id',
                          typedResults: items,
                        ),
                      if (exerciseAlternativesRefs)
                        await $_getPrefetchedDataByColumns<ExerciseRow, $ExercisesTable, ExerciseAlternative, $ExerciseAlternativesTable>(
                          currentTable: table,
                          referencedTable: $$ExercisesTableReferences._exerciseAlternativesRefsTable(db),
                          managerFromTypedResult: (p0) => $$ExercisesTableReferences(db, table, p0).exerciseAlternativesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'exercise_id',
                          typedResults: items,
                        ),
                      if (alternativeOf)
                        await $_getPrefetchedDataByColumns<ExerciseRow, $ExercisesTable, ExerciseAlternative, $ExerciseAlternativesTable>(
                          currentTable: table,
                          referencedTable: $$ExercisesTableReferences._alternativeOfTable(db),
                          managerFromTypedResult: (p0) => $$ExercisesTableReferences(db, table, p0).alternativeOf,
                          currentColumn: 'id',
                          referencedColumn: 'alternative_id',
                          typedResults: items,
                        ),
                      if (workoutExercisesRefs)
                        await $_getPrefetchedDataByColumns<ExerciseRow, $ExercisesTable, WorkoutExercise, $WorkoutExercisesTable>(
                          currentTable: table,
                          referencedTable: $$ExercisesTableReferences._workoutExercisesRefsTable(db),
                          managerFromTypedResult: (p0) => $$ExercisesTableReferences(db, table, p0).workoutExercisesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'exercise_id',
                          typedResults: items,
                        ),
                      if (workoutSessionExercisesRefs)
                        await $_getPrefetchedDataByColumns<ExerciseRow, $ExercisesTable, SessionExercise, $WorkoutSessionExercisesTable>(
                          currentTable: table,
                          referencedTable: $$ExercisesTableReferences._workoutSessionExercisesRefsTable(db),
                          managerFromTypedResult: (p0) => $$ExercisesTableReferences(db, table, p0).workoutSessionExercisesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'exercise_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExercisesTable,
      ExerciseRow,
      $$ExercisesTableFilterComposer,
      $$ExercisesTableOrderingComposer,
      $$ExercisesTableAnnotationComposer,
      $$ExercisesTableCreateCompanionBuilder,
      $$ExercisesTableUpdateCompanionBuilder,
      (ExerciseRow, $$ExercisesTableReferences),
      ExerciseRow,
      PrefetchHooks Function({
        bool exerciseMusclesRefs,
        bool exerciseAlternativesRefs,
        bool alternativeOf,
        bool workoutExercisesRefs,
        bool workoutSessionExercisesRefs,
      })
    >;
typedef $$ExerciseMusclesTableCreateCompanionBuilder = ExerciseMusclesCompanion Function({
  required String exerciseId,
  required String muscle,
  required String role,
  Value<int> rowid,
});
typedef $$ExerciseMusclesTableUpdateCompanionBuilder = ExerciseMusclesCompanion Function({
  Value<String> exerciseId,
  Value<String> muscle,
  Value<String> role,
  Value<int> rowid,
});

final class $$ExerciseMusclesTableReferences extends BaseReferences<_$AppDatabase, $ExerciseMusclesTable, ExerciseMuscle> {
  $$ExerciseMusclesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ExercisesTable _exerciseIdTable(_$AppDatabase db) => db.exercises.createAlias('exercise_muscles__exercise_id__exercises__id');

  $$ExercisesTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<String>('exercise_id')!;

    final manager = $$ExercisesTableTableManager($_db, $_db.exercises).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ExerciseMusclesTableFilterComposer extends Composer<_$AppDatabase, $ExerciseMusclesTable> {
  $$ExerciseMusclesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get muscle => $composableBuilder(column: $table.muscle, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role => $composableBuilder(column: $table.role, builder: (column) => ColumnFilters(column));

  $$ExercisesTableFilterComposer get exerciseId {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$ExercisesTableFilterComposer(
        $db: $db,
        $table: $db.exercises,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return composer;
  }
}

class $$ExerciseMusclesTableOrderingComposer extends Composer<_$AppDatabase, $ExerciseMusclesTable> {
  $$ExerciseMusclesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get muscle => $composableBuilder(column: $table.muscle, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(column: $table.role, builder: (column) => ColumnOrderings(column));

  $$ExercisesTableOrderingComposer get exerciseId {
    final $$ExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$ExercisesTableOrderingComposer(
        $db: $db,
        $table: $db.exercises,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return composer;
  }
}

class $$ExerciseMusclesTableAnnotationComposer extends Composer<_$AppDatabase, $ExerciseMusclesTable> {
  $$ExerciseMusclesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get muscle => $composableBuilder(column: $table.muscle, builder: (column) => column);

  GeneratedColumn<String> get role => $composableBuilder(column: $table.role, builder: (column) => column);

  $$ExercisesTableAnnotationComposer get exerciseId {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$ExercisesTableAnnotationComposer(
        $db: $db,
        $table: $db.exercises,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return composer;
  }
}

class $$ExerciseMusclesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExerciseMusclesTable,
          ExerciseMuscle,
          $$ExerciseMusclesTableFilterComposer,
          $$ExerciseMusclesTableOrderingComposer,
          $$ExerciseMusclesTableAnnotationComposer,
          $$ExerciseMusclesTableCreateCompanionBuilder,
          $$ExerciseMusclesTableUpdateCompanionBuilder,
          (ExerciseMuscle, $$ExerciseMusclesTableReferences),
          ExerciseMuscle,
          PrefetchHooks Function({bool exerciseId})
        > {
  $$ExerciseMusclesTableTableManager(_$AppDatabase db, $ExerciseMusclesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$ExerciseMusclesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$ExerciseMusclesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$ExerciseMusclesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> exerciseId = const Value.absent(),
            Value<String> muscle = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => ExerciseMusclesCompanion(exerciseId: exerciseId, muscle: muscle, role: role, rowid: rowid),
          createCompanionCallback: ({required String exerciseId, required String muscle, required String role, Value<int> rowid = const Value.absent()}) =>
              ExerciseMusclesCompanion.insert(exerciseId: exerciseId, muscle: muscle, role: role, rowid: rowid),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable<$ExerciseMusclesTable, ExerciseMuscle>(table), $$ExerciseMusclesTableReferences(db, table, e))).toList(),
          prefetchHooksCallback: ({exerciseId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <T extends TableManagerState<dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic>>(state) {
                    if (exerciseId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.exerciseId,
                        referencedTable: $$ExerciseMusclesTableReferences._exerciseIdTable(db),
                        referencedColumn: $$ExerciseMusclesTableReferences._exerciseIdTable(db).id,
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

typedef $$ExerciseMusclesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExerciseMusclesTable,
      ExerciseMuscle,
      $$ExerciseMusclesTableFilterComposer,
      $$ExerciseMusclesTableOrderingComposer,
      $$ExerciseMusclesTableAnnotationComposer,
      $$ExerciseMusclesTableCreateCompanionBuilder,
      $$ExerciseMusclesTableUpdateCompanionBuilder,
      (ExerciseMuscle, $$ExerciseMusclesTableReferences),
      ExerciseMuscle,
      PrefetchHooks Function({bool exerciseId})
    >;
typedef $$ExerciseAlternativesTableCreateCompanionBuilder = ExerciseAlternativesCompanion Function({
  required String exerciseId,
  required String alternativeId,
  required int rank,
  Value<int> rowid,
});
typedef $$ExerciseAlternativesTableUpdateCompanionBuilder = ExerciseAlternativesCompanion Function({
  Value<String> exerciseId,
  Value<String> alternativeId,
  Value<int> rank,
  Value<int> rowid,
});

final class $$ExerciseAlternativesTableReferences extends BaseReferences<_$AppDatabase, $ExerciseAlternativesTable, ExerciseAlternative> {
  $$ExerciseAlternativesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ExercisesTable _exerciseIdTable(_$AppDatabase db) => db.exercises.createAlias('exercise_alternatives__exercise_id__exercises__id');

  $$ExercisesTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<String>('exercise_id')!;

    final manager = $$ExercisesTableTableManager($_db, $_db.exercises).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ExercisesTable _alternativeIdTable(_$AppDatabase db) => db.exercises.createAlias('exercise_alternatives__alternative_id__exercises__id');

  $$ExercisesTableProcessedTableManager get alternativeId {
    final $_column = $_itemColumn<String>('alternative_id')!;

    final manager = $$ExercisesTableTableManager($_db, $_db.exercises).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_alternativeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ExerciseAlternativesTableFilterComposer extends Composer<_$AppDatabase, $ExerciseAlternativesTable> {
  $$ExerciseAlternativesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get rank => $composableBuilder(column: $table.rank, builder: (column) => ColumnFilters(column));

  $$ExercisesTableFilterComposer get exerciseId {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$ExercisesTableFilterComposer(
        $db: $db,
        $table: $db.exercises,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return composer;
  }

  $$ExercisesTableFilterComposer get alternativeId {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.alternativeId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$ExercisesTableFilterComposer(
        $db: $db,
        $table: $db.exercises,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return composer;
  }
}

class $$ExerciseAlternativesTableOrderingComposer extends Composer<_$AppDatabase, $ExerciseAlternativesTable> {
  $$ExerciseAlternativesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get rank => $composableBuilder(column: $table.rank, builder: (column) => ColumnOrderings(column));

  $$ExercisesTableOrderingComposer get exerciseId {
    final $$ExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$ExercisesTableOrderingComposer(
        $db: $db,
        $table: $db.exercises,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return composer;
  }

  $$ExercisesTableOrderingComposer get alternativeId {
    final $$ExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.alternativeId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$ExercisesTableOrderingComposer(
        $db: $db,
        $table: $db.exercises,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return composer;
  }
}

class $$ExerciseAlternativesTableAnnotationComposer extends Composer<_$AppDatabase, $ExerciseAlternativesTable> {
  $$ExerciseAlternativesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get rank => $composableBuilder(column: $table.rank, builder: (column) => column);

  $$ExercisesTableAnnotationComposer get exerciseId {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$ExercisesTableAnnotationComposer(
        $db: $db,
        $table: $db.exercises,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return composer;
  }

  $$ExercisesTableAnnotationComposer get alternativeId {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.alternativeId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$ExercisesTableAnnotationComposer(
        $db: $db,
        $table: $db.exercises,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return composer;
  }
}

class $$ExerciseAlternativesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExerciseAlternativesTable,
          ExerciseAlternative,
          $$ExerciseAlternativesTableFilterComposer,
          $$ExerciseAlternativesTableOrderingComposer,
          $$ExerciseAlternativesTableAnnotationComposer,
          $$ExerciseAlternativesTableCreateCompanionBuilder,
          $$ExerciseAlternativesTableUpdateCompanionBuilder,
          (ExerciseAlternative, $$ExerciseAlternativesTableReferences),
          ExerciseAlternative,
          PrefetchHooks Function({bool exerciseId, bool alternativeId})
        > {
  $$ExerciseAlternativesTableTableManager(_$AppDatabase db, $ExerciseAlternativesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$ExerciseAlternativesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$ExerciseAlternativesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$ExerciseAlternativesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> exerciseId = const Value.absent(),
            Value<String> alternativeId = const Value.absent(),
            Value<int> rank = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => ExerciseAlternativesCompanion(exerciseId: exerciseId, alternativeId: alternativeId, rank: rank, rowid: rowid),
          createCompanionCallback: ({required String exerciseId, required String alternativeId, required int rank, Value<int> rowid = const Value.absent()}) =>
              ExerciseAlternativesCompanion.insert(exerciseId: exerciseId, alternativeId: alternativeId, rank: rank, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable<$ExerciseAlternativesTable, ExerciseAlternative>(table), $$ExerciseAlternativesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({exerciseId = false, alternativeId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <T extends TableManagerState<dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic>>(state) {
                    if (exerciseId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.exerciseId,
                        referencedTable: $$ExerciseAlternativesTableReferences._exerciseIdTable(db),
                        referencedColumn: $$ExerciseAlternativesTableReferences._exerciseIdTable(db).id,
                      ) as T;
                    }
                    if (alternativeId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.alternativeId,
                        referencedTable: $$ExerciseAlternativesTableReferences._alternativeIdTable(db),
                        referencedColumn: $$ExerciseAlternativesTableReferences._alternativeIdTable(db).id,
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

typedef $$ExerciseAlternativesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExerciseAlternativesTable,
      ExerciseAlternative,
      $$ExerciseAlternativesTableFilterComposer,
      $$ExerciseAlternativesTableOrderingComposer,
      $$ExerciseAlternativesTableAnnotationComposer,
      $$ExerciseAlternativesTableCreateCompanionBuilder,
      $$ExerciseAlternativesTableUpdateCompanionBuilder,
      (ExerciseAlternative, $$ExerciseAlternativesTableReferences),
      ExerciseAlternative,
      PrefetchHooks Function({bool exerciseId, bool alternativeId})
    >;
typedef $$WorkoutProgramsTableCreateCompanionBuilder = WorkoutProgramsCompanion Function({
  Value<int> id,
  required int userId,
  required String name,
  required String split,
  required String source,
  Value<bool> isActive,
  Value<int?> basedOnProgramId,
  Value<String> rationale,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$WorkoutProgramsTableUpdateCompanionBuilder = WorkoutProgramsCompanion Function({
  Value<int> id,
  Value<int> userId,
  Value<String> name,
  Value<String> split,
  Value<String> source,
  Value<bool> isActive,
  Value<int?> basedOnProgramId,
  Value<String> rationale,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

final class $$WorkoutProgramsTableReferences extends BaseReferences<_$AppDatabase, $WorkoutProgramsTable, WorkoutProgram> {
  $$WorkoutProgramsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _userIdTable(_$AppDatabase db) => db.users.createAlias('workout_programs__user_id__users__id');

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<int>('user_id')!;

    final manager = $$UsersTableTableManager($_db, $_db.users).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$WorkoutDaysTable, List<WorkoutDay>> _workoutDaysRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.workoutDays, aliasName: 'workout_programs__id__workout_days__program_id');

  $$WorkoutDaysTableProcessedTableManager get workoutDaysRefs {
    final manager = $$WorkoutDaysTableTableManager($_db, $_db.workoutDays).filter((f) => f.programId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_workoutDaysRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$WorkoutProgramsTableFilterComposer extends Composer<_$AppDatabase, $WorkoutProgramsTable> {
  $$WorkoutProgramsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get split => $composableBuilder(column: $table.split, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source => $composableBuilder(column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get basedOnProgramId => $composableBuilder(column: $table.basedOnProgramId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rationale => $composableBuilder(column: $table.rationale, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$UsersTableFilterComposer(
        $db: $db,
        $table: $db.users,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return composer;
  }

  Expression<bool> workoutDaysRefs(Expression<bool> Function($$WorkoutDaysTableFilterComposer f) f) {
    final $$WorkoutDaysTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutDays,
      getReferencedColumn: (t) => t.programId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$WorkoutDaysTableFilterComposer(
        $db: $db,
        $table: $db.workoutDays,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return f(composer);
  }
}

class $$WorkoutProgramsTableOrderingComposer extends Composer<_$AppDatabase, $WorkoutProgramsTable> {
  $$WorkoutProgramsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get split => $composableBuilder(column: $table.split, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get basedOnProgramId => $composableBuilder(column: $table.basedOnProgramId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rationale => $composableBuilder(column: $table.rationale, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$UsersTableOrderingComposer(
        $db: $db,
        $table: $db.users,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return composer;
  }
}

class $$WorkoutProgramsTableAnnotationComposer extends Composer<_$AppDatabase, $WorkoutProgramsTable> {
  $$WorkoutProgramsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name => $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get split => $composableBuilder(column: $table.split, builder: (column) => column);

  GeneratedColumn<String> get source => $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<bool> get isActive => $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get basedOnProgramId => $composableBuilder(column: $table.basedOnProgramId, builder: (column) => column);

  GeneratedColumn<String> get rationale => $composableBuilder(column: $table.rationale, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt => $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$UsersTableAnnotationComposer(
        $db: $db,
        $table: $db.users,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return composer;
  }

  Expression<T> workoutDaysRefs<T extends Object>(Expression<T> Function($$WorkoutDaysTableAnnotationComposer a) f) {
    final $$WorkoutDaysTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutDays,
      getReferencedColumn: (t) => t.programId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$WorkoutDaysTableAnnotationComposer(
        $db: $db,
        $table: $db.workoutDays,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return f(composer);
  }
}

class $$WorkoutProgramsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutProgramsTable,
          WorkoutProgram,
          $$WorkoutProgramsTableFilterComposer,
          $$WorkoutProgramsTableOrderingComposer,
          $$WorkoutProgramsTableAnnotationComposer,
          $$WorkoutProgramsTableCreateCompanionBuilder,
          $$WorkoutProgramsTableUpdateCompanionBuilder,
          (WorkoutProgram, $$WorkoutProgramsTableReferences),
          WorkoutProgram,
          PrefetchHooks Function({bool userId, bool workoutDaysRefs})
        > {
  $$WorkoutProgramsTableTableManager(_$AppDatabase db, $WorkoutProgramsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$WorkoutProgramsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$WorkoutProgramsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$WorkoutProgramsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> userId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> split = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int?> basedOnProgramId = const Value.absent(),
                Value<String> rationale = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => WorkoutProgramsCompanion(
                id: id,
                userId: userId,
                name: name,
                split: split,
                source: source,
                isActive: isActive,
                basedOnProgramId: basedOnProgramId,
                rationale: rationale,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int userId,
                required String name,
                required String split,
                required String source,
                Value<bool> isActive = const Value.absent(),
                Value<int?> basedOnProgramId = const Value.absent(),
                Value<String> rationale = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => WorkoutProgramsCompanion.insert(
                id: id,
                userId: userId,
                name: name,
                split: split,
                source: source,
                isActive: isActive,
                basedOnProgramId: basedOnProgramId,
                rationale: rationale,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable<$WorkoutProgramsTable, WorkoutProgram>(table), $$WorkoutProgramsTableReferences(db, table, e))).toList(),
          prefetchHooksCallback: ({userId = false, workoutDaysRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (workoutDaysRefs) db.workoutDays],
              addJoins:
                  <T extends TableManagerState<dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic>>(state) {
                    if (userId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.userId,
                        referencedTable: $$WorkoutProgramsTableReferences._userIdTable(db),
                        referencedColumn: $$WorkoutProgramsTableReferences._userIdTable(db).id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (workoutDaysRefs)
                    await $_getPrefetchedDataByColumns<WorkoutProgram, $WorkoutProgramsTable, WorkoutDay, $WorkoutDaysTable>(
                      currentTable: table,
                      referencedTable: $$WorkoutProgramsTableReferences._workoutDaysRefsTable(db),
                      managerFromTypedResult: (p0) => $$WorkoutProgramsTableReferences(db, table, p0).workoutDaysRefs,
                      currentColumn: 'id',
                      referencedColumn: 'program_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$WorkoutProgramsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutProgramsTable,
      WorkoutProgram,
      $$WorkoutProgramsTableFilterComposer,
      $$WorkoutProgramsTableOrderingComposer,
      $$WorkoutProgramsTableAnnotationComposer,
      $$WorkoutProgramsTableCreateCompanionBuilder,
      $$WorkoutProgramsTableUpdateCompanionBuilder,
      (WorkoutProgram, $$WorkoutProgramsTableReferences),
      WorkoutProgram,
      PrefetchHooks Function({bool userId, bool workoutDaysRefs})
    >;
typedef $$WorkoutDaysTableCreateCompanionBuilder = WorkoutDaysCompanion Function({
  Value<int> id,
  required int programId,
  required int dayIndex,
  required int weekday,
  required String name,
});
typedef $$WorkoutDaysTableUpdateCompanionBuilder = WorkoutDaysCompanion Function({
  Value<int> id,
  Value<int> programId,
  Value<int> dayIndex,
  Value<int> weekday,
  Value<String> name,
});

final class $$WorkoutDaysTableReferences extends BaseReferences<_$AppDatabase, $WorkoutDaysTable, WorkoutDay> {
  $$WorkoutDaysTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WorkoutProgramsTable _programIdTable(_$AppDatabase db) => db.workoutPrograms.createAlias('workout_days__program_id__workout_programs__id');

  $$WorkoutProgramsTableProcessedTableManager get programId {
    final $_column = $_itemColumn<int>('program_id')!;

    final manager = $$WorkoutProgramsTableTableManager($_db, $_db.workoutPrograms).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_programIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$WorkoutExercisesTable, List<WorkoutExercise>> _workoutExercisesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.workoutExercises, aliasName: 'workout_days__id__workout_exercises__day_id');

  $$WorkoutExercisesTableProcessedTableManager get workoutExercisesRefs {
    final manager = $$WorkoutExercisesTableTableManager($_db, $_db.workoutExercises).filter((f) => f.dayId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_workoutExercisesRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$WorkoutDaysTableFilterComposer extends Composer<_$AppDatabase, $WorkoutDaysTable> {
  $$WorkoutDaysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get dayIndex => $composableBuilder(column: $table.dayIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get weekday => $composableBuilder(column: $table.weekday, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(column: $table.name, builder: (column) => ColumnFilters(column));

  $$WorkoutProgramsTableFilterComposer get programId {
    final $$WorkoutProgramsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.programId,
      referencedTable: $db.workoutPrograms,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$WorkoutProgramsTableFilterComposer(
        $db: $db,
        $table: $db.workoutPrograms,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return composer;
  }

  Expression<bool> workoutExercisesRefs(Expression<bool> Function($$WorkoutExercisesTableFilterComposer f) f) {
    final $$WorkoutExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutExercises,
      getReferencedColumn: (t) => t.dayId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$WorkoutExercisesTableFilterComposer(
        $db: $db,
        $table: $db.workoutExercises,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return f(composer);
  }
}

class $$WorkoutDaysTableOrderingComposer extends Composer<_$AppDatabase, $WorkoutDaysTable> {
  $$WorkoutDaysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get dayIndex => $composableBuilder(column: $table.dayIndex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get weekday => $composableBuilder(column: $table.weekday, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(column: $table.name, builder: (column) => ColumnOrderings(column));

  $$WorkoutProgramsTableOrderingComposer get programId {
    final $$WorkoutProgramsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.programId,
      referencedTable: $db.workoutPrograms,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$WorkoutProgramsTableOrderingComposer(
        $db: $db,
        $table: $db.workoutPrograms,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return composer;
  }
}

class $$WorkoutDaysTableAnnotationComposer extends Composer<_$AppDatabase, $WorkoutDaysTable> {
  $$WorkoutDaysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get dayIndex => $composableBuilder(column: $table.dayIndex, builder: (column) => column);

  GeneratedColumn<int> get weekday => $composableBuilder(column: $table.weekday, builder: (column) => column);

  GeneratedColumn<String> get name => $composableBuilder(column: $table.name, builder: (column) => column);

  $$WorkoutProgramsTableAnnotationComposer get programId {
    final $$WorkoutProgramsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.programId,
      referencedTable: $db.workoutPrograms,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$WorkoutProgramsTableAnnotationComposer(
        $db: $db,
        $table: $db.workoutPrograms,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return composer;
  }

  Expression<T> workoutExercisesRefs<T extends Object>(Expression<T> Function($$WorkoutExercisesTableAnnotationComposer a) f) {
    final $$WorkoutExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutExercises,
      getReferencedColumn: (t) => t.dayId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$WorkoutExercisesTableAnnotationComposer(
        $db: $db,
        $table: $db.workoutExercises,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return f(composer);
  }
}

class $$WorkoutDaysTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutDaysTable,
          WorkoutDay,
          $$WorkoutDaysTableFilterComposer,
          $$WorkoutDaysTableOrderingComposer,
          $$WorkoutDaysTableAnnotationComposer,
          $$WorkoutDaysTableCreateCompanionBuilder,
          $$WorkoutDaysTableUpdateCompanionBuilder,
          (WorkoutDay, $$WorkoutDaysTableReferences),
          WorkoutDay,
          PrefetchHooks Function({bool programId, bool workoutExercisesRefs})
        > {
  $$WorkoutDaysTableTableManager(_$AppDatabase db, $WorkoutDaysTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$WorkoutDaysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$WorkoutDaysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$WorkoutDaysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> programId = const Value.absent(),
            Value<int> dayIndex = const Value.absent(),
            Value<int> weekday = const Value.absent(),
            Value<String> name = const Value.absent(),
          }) => WorkoutDaysCompanion(id: id, programId: programId, dayIndex: dayIndex, weekday: weekday, name: name),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int programId,
            required int dayIndex,
            required int weekday,
            required String name,
          }) => WorkoutDaysCompanion.insert(id: id, programId: programId, dayIndex: dayIndex, weekday: weekday, name: name),
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable<$WorkoutDaysTable, WorkoutDay>(table), $$WorkoutDaysTableReferences(db, table, e))).toList(),
          prefetchHooksCallback: ({programId = false, workoutExercisesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (workoutExercisesRefs) db.workoutExercises],
              addJoins:
                  <T extends TableManagerState<dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic>>(state) {
                    if (programId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.programId,
                        referencedTable: $$WorkoutDaysTableReferences._programIdTable(db),
                        referencedColumn: $$WorkoutDaysTableReferences._programIdTable(db).id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (workoutExercisesRefs)
                    await $_getPrefetchedDataByColumns<WorkoutDay, $WorkoutDaysTable, WorkoutExercise, $WorkoutExercisesTable>(
                      currentTable: table,
                      referencedTable: $$WorkoutDaysTableReferences._workoutExercisesRefsTable(db),
                      managerFromTypedResult: (p0) => $$WorkoutDaysTableReferences(db, table, p0).workoutExercisesRefs,
                      currentColumn: 'id',
                      referencedColumn: 'day_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$WorkoutDaysTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutDaysTable,
      WorkoutDay,
      $$WorkoutDaysTableFilterComposer,
      $$WorkoutDaysTableOrderingComposer,
      $$WorkoutDaysTableAnnotationComposer,
      $$WorkoutDaysTableCreateCompanionBuilder,
      $$WorkoutDaysTableUpdateCompanionBuilder,
      (WorkoutDay, $$WorkoutDaysTableReferences),
      WorkoutDay,
      PrefetchHooks Function({bool programId, bool workoutExercisesRefs})
    >;
typedef $$WorkoutExercisesTableCreateCompanionBuilder = WorkoutExercisesCompanion Function({
  Value<int> id,
  required int dayId,
  required String exerciseId,
  required int orderIndex,
  required int sets,
  required int repMin,
  required int repMax,
  required int targetRir,
  required int restSec,
  Value<double?> startWeight,
  Value<double?> incrementKg,
  Value<String> notes,
});
typedef $$WorkoutExercisesTableUpdateCompanionBuilder = WorkoutExercisesCompanion Function({
  Value<int> id,
  Value<int> dayId,
  Value<String> exerciseId,
  Value<int> orderIndex,
  Value<int> sets,
  Value<int> repMin,
  Value<int> repMax,
  Value<int> targetRir,
  Value<int> restSec,
  Value<double?> startWeight,
  Value<double?> incrementKg,
  Value<String> notes,
});

final class $$WorkoutExercisesTableReferences extends BaseReferences<_$AppDatabase, $WorkoutExercisesTable, WorkoutExercise> {
  $$WorkoutExercisesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WorkoutDaysTable _dayIdTable(_$AppDatabase db) => db.workoutDays.createAlias('workout_exercises__day_id__workout_days__id');

  $$WorkoutDaysTableProcessedTableManager get dayId {
    final $_column = $_itemColumn<int>('day_id')!;

    final manager = $$WorkoutDaysTableTableManager($_db, $_db.workoutDays).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_dayIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ExercisesTable _exerciseIdTable(_$AppDatabase db) => db.exercises.createAlias('workout_exercises__exercise_id__exercises__id');

  $$ExercisesTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<String>('exercise_id')!;

    final manager = $$ExercisesTableTableManager($_db, $_db.exercises).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$WorkoutExercisesTableFilterComposer extends Composer<_$AppDatabase, $WorkoutExercisesTable> {
  $$WorkoutExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get orderIndex => $composableBuilder(column: $table.orderIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sets => $composableBuilder(column: $table.sets, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get repMin => $composableBuilder(column: $table.repMin, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get repMax => $composableBuilder(column: $table.repMax, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get targetRir => $composableBuilder(column: $table.targetRir, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get restSec => $composableBuilder(column: $table.restSec, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get startWeight => $composableBuilder(column: $table.startWeight, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get incrementKg => $composableBuilder(column: $table.incrementKg, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(column: $table.notes, builder: (column) => ColumnFilters(column));

  $$WorkoutDaysTableFilterComposer get dayId {
    final $$WorkoutDaysTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dayId,
      referencedTable: $db.workoutDays,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$WorkoutDaysTableFilterComposer(
        $db: $db,
        $table: $db.workoutDays,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return composer;
  }

  $$ExercisesTableFilterComposer get exerciseId {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$ExercisesTableFilterComposer(
        $db: $db,
        $table: $db.exercises,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return composer;
  }
}

class $$WorkoutExercisesTableOrderingComposer extends Composer<_$AppDatabase, $WorkoutExercisesTable> {
  $$WorkoutExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get orderIndex => $composableBuilder(column: $table.orderIndex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sets => $composableBuilder(column: $table.sets, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get repMin => $composableBuilder(column: $table.repMin, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get repMax => $composableBuilder(column: $table.repMax, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get targetRir => $composableBuilder(column: $table.targetRir, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get restSec => $composableBuilder(column: $table.restSec, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get startWeight => $composableBuilder(column: $table.startWeight, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get incrementKg => $composableBuilder(column: $table.incrementKg, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(column: $table.notes, builder: (column) => ColumnOrderings(column));

  $$WorkoutDaysTableOrderingComposer get dayId {
    final $$WorkoutDaysTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dayId,
      referencedTable: $db.workoutDays,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$WorkoutDaysTableOrderingComposer(
        $db: $db,
        $table: $db.workoutDays,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return composer;
  }

  $$ExercisesTableOrderingComposer get exerciseId {
    final $$ExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$ExercisesTableOrderingComposer(
        $db: $db,
        $table: $db.exercises,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return composer;
  }
}

class $$WorkoutExercisesTableAnnotationComposer extends Composer<_$AppDatabase, $WorkoutExercisesTable> {
  $$WorkoutExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(column: $table.orderIndex, builder: (column) => column);

  GeneratedColumn<int> get sets => $composableBuilder(column: $table.sets, builder: (column) => column);

  GeneratedColumn<int> get repMin => $composableBuilder(column: $table.repMin, builder: (column) => column);

  GeneratedColumn<int> get repMax => $composableBuilder(column: $table.repMax, builder: (column) => column);

  GeneratedColumn<int> get targetRir => $composableBuilder(column: $table.targetRir, builder: (column) => column);

  GeneratedColumn<int> get restSec => $composableBuilder(column: $table.restSec, builder: (column) => column);

  GeneratedColumn<double> get startWeight => $composableBuilder(column: $table.startWeight, builder: (column) => column);

  GeneratedColumn<double> get incrementKg => $composableBuilder(column: $table.incrementKg, builder: (column) => column);

  GeneratedColumn<String> get notes => $composableBuilder(column: $table.notes, builder: (column) => column);

  $$WorkoutDaysTableAnnotationComposer get dayId {
    final $$WorkoutDaysTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dayId,
      referencedTable: $db.workoutDays,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$WorkoutDaysTableAnnotationComposer(
        $db: $db,
        $table: $db.workoutDays,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return composer;
  }

  $$ExercisesTableAnnotationComposer get exerciseId {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$ExercisesTableAnnotationComposer(
        $db: $db,
        $table: $db.exercises,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return composer;
  }
}

class $$WorkoutExercisesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutExercisesTable,
          WorkoutExercise,
          $$WorkoutExercisesTableFilterComposer,
          $$WorkoutExercisesTableOrderingComposer,
          $$WorkoutExercisesTableAnnotationComposer,
          $$WorkoutExercisesTableCreateCompanionBuilder,
          $$WorkoutExercisesTableUpdateCompanionBuilder,
          (WorkoutExercise, $$WorkoutExercisesTableReferences),
          WorkoutExercise,
          PrefetchHooks Function({bool dayId, bool exerciseId})
        > {
  $$WorkoutExercisesTableTableManager(_$AppDatabase db, $WorkoutExercisesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$WorkoutExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$WorkoutExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$WorkoutExercisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> dayId = const Value.absent(),
                Value<String> exerciseId = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
                Value<int> sets = const Value.absent(),
                Value<int> repMin = const Value.absent(),
                Value<int> repMax = const Value.absent(),
                Value<int> targetRir = const Value.absent(),
                Value<int> restSec = const Value.absent(),
                Value<double?> startWeight = const Value.absent(),
                Value<double?> incrementKg = const Value.absent(),
                Value<String> notes = const Value.absent(),
              }) => WorkoutExercisesCompanion(
                id: id,
                dayId: dayId,
                exerciseId: exerciseId,
                orderIndex: orderIndex,
                sets: sets,
                repMin: repMin,
                repMax: repMax,
                targetRir: targetRir,
                restSec: restSec,
                startWeight: startWeight,
                incrementKg: incrementKg,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int dayId,
                required String exerciseId,
                required int orderIndex,
                required int sets,
                required int repMin,
                required int repMax,
                required int targetRir,
                required int restSec,
                Value<double?> startWeight = const Value.absent(),
                Value<double?> incrementKg = const Value.absent(),
                Value<String> notes = const Value.absent(),
              }) => WorkoutExercisesCompanion.insert(
                id: id,
                dayId: dayId,
                exerciseId: exerciseId,
                orderIndex: orderIndex,
                sets: sets,
                repMin: repMin,
                repMax: repMax,
                targetRir: targetRir,
                restSec: restSec,
                startWeight: startWeight,
                incrementKg: incrementKg,
                notes: notes,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable<$WorkoutExercisesTable, WorkoutExercise>(table), $$WorkoutExercisesTableReferences(db, table, e))).toList(),
          prefetchHooksCallback: ({dayId = false, exerciseId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <T extends TableManagerState<dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic>>(state) {
                    if (dayId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.dayId,
                        referencedTable: $$WorkoutExercisesTableReferences._dayIdTable(db),
                        referencedColumn: $$WorkoutExercisesTableReferences._dayIdTable(db).id,
                      ) as T;
                    }
                    if (exerciseId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.exerciseId,
                        referencedTable: $$WorkoutExercisesTableReferences._exerciseIdTable(db),
                        referencedColumn: $$WorkoutExercisesTableReferences._exerciseIdTable(db).id,
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

typedef $$WorkoutExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutExercisesTable,
      WorkoutExercise,
      $$WorkoutExercisesTableFilterComposer,
      $$WorkoutExercisesTableOrderingComposer,
      $$WorkoutExercisesTableAnnotationComposer,
      $$WorkoutExercisesTableCreateCompanionBuilder,
      $$WorkoutExercisesTableUpdateCompanionBuilder,
      (WorkoutExercise, $$WorkoutExercisesTableReferences),
      WorkoutExercise,
      PrefetchHooks Function({bool dayId, bool exerciseId})
    >;
typedef $$WorkoutSessionsTableCreateCompanionBuilder = WorkoutSessionsCompanion Function({
  Value<int> id,
  Value<int?> programId,
  Value<int?> dayIndex,
  required String dayName,
  required DateTime startedAt,
  Value<DateTime?> finishedAt,
  required String status,
  Value<int?> readinessScore,
  Value<String?> readiness,
  Value<String> notes,
});
typedef $$WorkoutSessionsTableUpdateCompanionBuilder = WorkoutSessionsCompanion Function({
  Value<int> id,
  Value<int?> programId,
  Value<int?> dayIndex,
  Value<String> dayName,
  Value<DateTime> startedAt,
  Value<DateTime?> finishedAt,
  Value<String> status,
  Value<int?> readinessScore,
  Value<String?> readiness,
  Value<String> notes,
});

final class $$WorkoutSessionsTableReferences extends BaseReferences<_$AppDatabase, $WorkoutSessionsTable, WorkoutSession> {
  $$WorkoutSessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$WorkoutSessionExercisesTable, List<SessionExercise>> _workoutSessionExercisesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.workoutSessionExercises, aliasName: 'workout_sessions__id__workout_session_exercises__session_id');

  $$WorkoutSessionExercisesTableProcessedTableManager get workoutSessionExercisesRefs {
    final manager = $$WorkoutSessionExercisesTableTableManager(
      $_db,
      $_db.workoutSessionExercises,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_workoutSessionExercisesRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$WorkoutSetsTable, List<WorkoutSet>> _workoutSetsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.workoutSets, aliasName: 'workout_sessions__id__workout_sets__session_id');

  $$WorkoutSetsTableProcessedTableManager get workoutSetsRefs {
    final manager = $$WorkoutSetsTableTableManager($_db, $_db.workoutSets).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_workoutSetsRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$WorkoutSessionsTableFilterComposer extends Composer<_$AppDatabase, $WorkoutSessionsTable> {
  $$WorkoutSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get programId => $composableBuilder(column: $table.programId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get dayIndex => $composableBuilder(column: $table.dayIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dayName => $composableBuilder(column: $table.dayName, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startedAt => $composableBuilder(column: $table.startedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get finishedAt => $composableBuilder(column: $table.finishedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get readinessScore => $composableBuilder(column: $table.readinessScore, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get readiness => $composableBuilder(column: $table.readiness, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(column: $table.notes, builder: (column) => ColumnFilters(column));

  Expression<bool> workoutSessionExercisesRefs(Expression<bool> Function($$WorkoutSessionExercisesTableFilterComposer f) f) {
    final $$WorkoutSessionExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutSessionExercises,
      getReferencedColumn: (t) => t.sessionId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$WorkoutSessionExercisesTableFilterComposer(
        $db: $db,
        $table: $db.workoutSessionExercises,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return f(composer);
  }

  Expression<bool> workoutSetsRefs(Expression<bool> Function($$WorkoutSetsTableFilterComposer f) f) {
    final $$WorkoutSetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutSets,
      getReferencedColumn: (t) => t.sessionId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$WorkoutSetsTableFilterComposer(
        $db: $db,
        $table: $db.workoutSets,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return f(composer);
  }
}

class $$WorkoutSessionsTableOrderingComposer extends Composer<_$AppDatabase, $WorkoutSessionsTable> {
  $$WorkoutSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get programId => $composableBuilder(column: $table.programId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get dayIndex => $composableBuilder(column: $table.dayIndex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dayName => $composableBuilder(column: $table.dayName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(column: $table.startedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get finishedAt => $composableBuilder(column: $table.finishedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get readinessScore => $composableBuilder(column: $table.readinessScore, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get readiness => $composableBuilder(column: $table.readiness, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(column: $table.notes, builder: (column) => ColumnOrderings(column));
}

class $$WorkoutSessionsTableAnnotationComposer extends Composer<_$AppDatabase, $WorkoutSessionsTable> {
  $$WorkoutSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get programId => $composableBuilder(column: $table.programId, builder: (column) => column);

  GeneratedColumn<int> get dayIndex => $composableBuilder(column: $table.dayIndex, builder: (column) => column);

  GeneratedColumn<String> get dayName => $composableBuilder(column: $table.dayName, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt => $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get finishedAt => $composableBuilder(column: $table.finishedAt, builder: (column) => column);

  GeneratedColumn<String> get status => $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get readinessScore => $composableBuilder(column: $table.readinessScore, builder: (column) => column);

  GeneratedColumn<String> get readiness => $composableBuilder(column: $table.readiness, builder: (column) => column);

  GeneratedColumn<String> get notes => $composableBuilder(column: $table.notes, builder: (column) => column);

  Expression<T> workoutSessionExercisesRefs<T extends Object>(Expression<T> Function($$WorkoutSessionExercisesTableAnnotationComposer a) f) {
    final $$WorkoutSessionExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutSessionExercises,
      getReferencedColumn: (t) => t.sessionId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$WorkoutSessionExercisesTableAnnotationComposer(
        $db: $db,
        $table: $db.workoutSessionExercises,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return f(composer);
  }

  Expression<T> workoutSetsRefs<T extends Object>(Expression<T> Function($$WorkoutSetsTableAnnotationComposer a) f) {
    final $$WorkoutSetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutSets,
      getReferencedColumn: (t) => t.sessionId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$WorkoutSetsTableAnnotationComposer(
        $db: $db,
        $table: $db.workoutSets,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return f(composer);
  }
}

class $$WorkoutSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutSessionsTable,
          WorkoutSession,
          $$WorkoutSessionsTableFilterComposer,
          $$WorkoutSessionsTableOrderingComposer,
          $$WorkoutSessionsTableAnnotationComposer,
          $$WorkoutSessionsTableCreateCompanionBuilder,
          $$WorkoutSessionsTableUpdateCompanionBuilder,
          (WorkoutSession, $$WorkoutSessionsTableReferences),
          WorkoutSession,
          PrefetchHooks Function({bool workoutSessionExercisesRefs, bool workoutSetsRefs})
        > {
  $$WorkoutSessionsTableTableManager(_$AppDatabase db, $WorkoutSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$WorkoutSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$WorkoutSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$WorkoutSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> programId = const Value.absent(),
                Value<int?> dayIndex = const Value.absent(),
                Value<String> dayName = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> finishedAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> readinessScore = const Value.absent(),
                Value<String?> readiness = const Value.absent(),
                Value<String> notes = const Value.absent(),
              }) => WorkoutSessionsCompanion(
                id: id,
                programId: programId,
                dayIndex: dayIndex,
                dayName: dayName,
                startedAt: startedAt,
                finishedAt: finishedAt,
                status: status,
                readinessScore: readinessScore,
                readiness: readiness,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> programId = const Value.absent(),
                Value<int?> dayIndex = const Value.absent(),
                required String dayName,
                required DateTime startedAt,
                Value<DateTime?> finishedAt = const Value.absent(),
                required String status,
                Value<int?> readinessScore = const Value.absent(),
                Value<String?> readiness = const Value.absent(),
                Value<String> notes = const Value.absent(),
              }) => WorkoutSessionsCompanion.insert(
                id: id,
                programId: programId,
                dayIndex: dayIndex,
                dayName: dayName,
                startedAt: startedAt,
                finishedAt: finishedAt,
                status: status,
                readinessScore: readinessScore,
                readiness: readiness,
                notes: notes,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable<$WorkoutSessionsTable, WorkoutSession>(table), $$WorkoutSessionsTableReferences(db, table, e))).toList(),
          prefetchHooksCallback: ({workoutSessionExercisesRefs = false, workoutSetsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (workoutSessionExercisesRefs) db.workoutSessionExercises, if (workoutSetsRefs) db.workoutSets],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (workoutSessionExercisesRefs)
                    await $_getPrefetchedDataByColumns<WorkoutSession, $WorkoutSessionsTable, SessionExercise, $WorkoutSessionExercisesTable>(
                      currentTable: table,
                      referencedTable: $$WorkoutSessionsTableReferences._workoutSessionExercisesRefsTable(db),
                      managerFromTypedResult: (p0) => $$WorkoutSessionsTableReferences(db, table, p0).workoutSessionExercisesRefs,
                      currentColumn: 'id',
                      referencedColumn: 'session_id',
                      typedResults: items,
                    ),
                  if (workoutSetsRefs)
                    await $_getPrefetchedDataByColumns<WorkoutSession, $WorkoutSessionsTable, WorkoutSet, $WorkoutSetsTable>(
                      currentTable: table,
                      referencedTable: $$WorkoutSessionsTableReferences._workoutSetsRefsTable(db),
                      managerFromTypedResult: (p0) => $$WorkoutSessionsTableReferences(db, table, p0).workoutSetsRefs,
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

typedef $$WorkoutSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutSessionsTable,
      WorkoutSession,
      $$WorkoutSessionsTableFilterComposer,
      $$WorkoutSessionsTableOrderingComposer,
      $$WorkoutSessionsTableAnnotationComposer,
      $$WorkoutSessionsTableCreateCompanionBuilder,
      $$WorkoutSessionsTableUpdateCompanionBuilder,
      (WorkoutSession, $$WorkoutSessionsTableReferences),
      WorkoutSession,
      PrefetchHooks Function({bool workoutSessionExercisesRefs, bool workoutSetsRefs})
    >;
typedef $$WorkoutSessionExercisesTableCreateCompanionBuilder = WorkoutSessionExercisesCompanion Function({
  Value<int> id,
  required int sessionId,
  Value<int?> workoutExerciseId,
  required String exerciseId,
  required int orderIndex,
  required int targetSets,
  required int repMin,
  required int repMax,
  required int targetRir,
  required int restSec,
  Value<String?> substitutedFrom,
  Value<bool> pain,
  Value<bool> formUnstable,
  Value<int?> recommendationId,
});
typedef $$WorkoutSessionExercisesTableUpdateCompanionBuilder = WorkoutSessionExercisesCompanion Function({
  Value<int> id,
  Value<int> sessionId,
  Value<int?> workoutExerciseId,
  Value<String> exerciseId,
  Value<int> orderIndex,
  Value<int> targetSets,
  Value<int> repMin,
  Value<int> repMax,
  Value<int> targetRir,
  Value<int> restSec,
  Value<String?> substitutedFrom,
  Value<bool> pain,
  Value<bool> formUnstable,
  Value<int?> recommendationId,
});

final class $$WorkoutSessionExercisesTableReferences extends BaseReferences<_$AppDatabase, $WorkoutSessionExercisesTable, SessionExercise> {
  $$WorkoutSessionExercisesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WorkoutSessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.workoutSessions.createAlias('workout_session_exercises__session_id__workout_sessions__id');

  $$WorkoutSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$WorkoutSessionsTableTableManager($_db, $_db.workoutSessions).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ExercisesTable _exerciseIdTable(_$AppDatabase db) => db.exercises.createAlias('workout_session_exercises__exercise_id__exercises__id');

  $$ExercisesTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<String>('exercise_id')!;

    final manager = $$ExercisesTableTableManager($_db, $_db.exercises).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$WorkoutSetsTable, List<WorkoutSet>> _workoutSetsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.workoutSets, aliasName: 'workout_session_exercises__id__workout_sets__session_exercise_id');

  $$WorkoutSetsTableProcessedTableManager get workoutSetsRefs {
    final manager = $$WorkoutSetsTableTableManager($_db, $_db.workoutSets).filter((f) => f.sessionExerciseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_workoutSetsRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$WorkoutSessionExercisesTableFilterComposer extends Composer<_$AppDatabase, $WorkoutSessionExercisesTable> {
  $$WorkoutSessionExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get workoutExerciseId => $composableBuilder(column: $table.workoutExerciseId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get orderIndex => $composableBuilder(column: $table.orderIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get targetSets => $composableBuilder(column: $table.targetSets, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get repMin => $composableBuilder(column: $table.repMin, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get repMax => $composableBuilder(column: $table.repMax, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get targetRir => $composableBuilder(column: $table.targetRir, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get restSec => $composableBuilder(column: $table.restSec, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get substitutedFrom => $composableBuilder(column: $table.substitutedFrom, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get pain => $composableBuilder(column: $table.pain, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get formUnstable => $composableBuilder(column: $table.formUnstable, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get recommendationId => $composableBuilder(column: $table.recommendationId, builder: (column) => ColumnFilters(column));

  $$WorkoutSessionsTableFilterComposer get sessionId {
    final $$WorkoutSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.workoutSessions,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$WorkoutSessionsTableFilterComposer(
        $db: $db,
        $table: $db.workoutSessions,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return composer;
  }

  $$ExercisesTableFilterComposer get exerciseId {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$ExercisesTableFilterComposer(
        $db: $db,
        $table: $db.exercises,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return composer;
  }

  Expression<bool> workoutSetsRefs(Expression<bool> Function($$WorkoutSetsTableFilterComposer f) f) {
    final $$WorkoutSetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutSets,
      getReferencedColumn: (t) => t.sessionExerciseId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$WorkoutSetsTableFilterComposer(
        $db: $db,
        $table: $db.workoutSets,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return f(composer);
  }
}

class $$WorkoutSessionExercisesTableOrderingComposer extends Composer<_$AppDatabase, $WorkoutSessionExercisesTable> {
  $$WorkoutSessionExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get workoutExerciseId => $composableBuilder(column: $table.workoutExerciseId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get orderIndex => $composableBuilder(column: $table.orderIndex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get targetSets => $composableBuilder(column: $table.targetSets, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get repMin => $composableBuilder(column: $table.repMin, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get repMax => $composableBuilder(column: $table.repMax, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get targetRir => $composableBuilder(column: $table.targetRir, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get restSec => $composableBuilder(column: $table.restSec, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get substitutedFrom => $composableBuilder(column: $table.substitutedFrom, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get pain => $composableBuilder(column: $table.pain, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get formUnstable => $composableBuilder(column: $table.formUnstable, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get recommendationId => $composableBuilder(column: $table.recommendationId, builder: (column) => ColumnOrderings(column));

  $$WorkoutSessionsTableOrderingComposer get sessionId {
    final $$WorkoutSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.workoutSessions,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$WorkoutSessionsTableOrderingComposer(
        $db: $db,
        $table: $db.workoutSessions,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return composer;
  }

  $$ExercisesTableOrderingComposer get exerciseId {
    final $$ExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$ExercisesTableOrderingComposer(
        $db: $db,
        $table: $db.exercises,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return composer;
  }
}

class $$WorkoutSessionExercisesTableAnnotationComposer extends Composer<_$AppDatabase, $WorkoutSessionExercisesTable> {
  $$WorkoutSessionExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get workoutExerciseId => $composableBuilder(column: $table.workoutExerciseId, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(column: $table.orderIndex, builder: (column) => column);

  GeneratedColumn<int> get targetSets => $composableBuilder(column: $table.targetSets, builder: (column) => column);

  GeneratedColumn<int> get repMin => $composableBuilder(column: $table.repMin, builder: (column) => column);

  GeneratedColumn<int> get repMax => $composableBuilder(column: $table.repMax, builder: (column) => column);

  GeneratedColumn<int> get targetRir => $composableBuilder(column: $table.targetRir, builder: (column) => column);

  GeneratedColumn<int> get restSec => $composableBuilder(column: $table.restSec, builder: (column) => column);

  GeneratedColumn<String> get substitutedFrom => $composableBuilder(column: $table.substitutedFrom, builder: (column) => column);

  GeneratedColumn<bool> get pain => $composableBuilder(column: $table.pain, builder: (column) => column);

  GeneratedColumn<bool> get formUnstable => $composableBuilder(column: $table.formUnstable, builder: (column) => column);

  GeneratedColumn<int> get recommendationId => $composableBuilder(column: $table.recommendationId, builder: (column) => column);

  $$WorkoutSessionsTableAnnotationComposer get sessionId {
    final $$WorkoutSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.workoutSessions,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$WorkoutSessionsTableAnnotationComposer(
        $db: $db,
        $table: $db.workoutSessions,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return composer;
  }

  $$ExercisesTableAnnotationComposer get exerciseId {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$ExercisesTableAnnotationComposer(
        $db: $db,
        $table: $db.exercises,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return composer;
  }

  Expression<T> workoutSetsRefs<T extends Object>(Expression<T> Function($$WorkoutSetsTableAnnotationComposer a) f) {
    final $$WorkoutSetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutSets,
      getReferencedColumn: (t) => t.sessionExerciseId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$WorkoutSetsTableAnnotationComposer(
        $db: $db,
        $table: $db.workoutSets,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return f(composer);
  }
}

class $$WorkoutSessionExercisesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutSessionExercisesTable,
          SessionExercise,
          $$WorkoutSessionExercisesTableFilterComposer,
          $$WorkoutSessionExercisesTableOrderingComposer,
          $$WorkoutSessionExercisesTableAnnotationComposer,
          $$WorkoutSessionExercisesTableCreateCompanionBuilder,
          $$WorkoutSessionExercisesTableUpdateCompanionBuilder,
          (SessionExercise, $$WorkoutSessionExercisesTableReferences),
          SessionExercise,
          PrefetchHooks Function({bool sessionId, bool exerciseId, bool workoutSetsRefs})
        > {
  $$WorkoutSessionExercisesTableTableManager(_$AppDatabase db, $WorkoutSessionExercisesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$WorkoutSessionExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$WorkoutSessionExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$WorkoutSessionExercisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<int?> workoutExerciseId = const Value.absent(),
                Value<String> exerciseId = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
                Value<int> targetSets = const Value.absent(),
                Value<int> repMin = const Value.absent(),
                Value<int> repMax = const Value.absent(),
                Value<int> targetRir = const Value.absent(),
                Value<int> restSec = const Value.absent(),
                Value<String?> substitutedFrom = const Value.absent(),
                Value<bool> pain = const Value.absent(),
                Value<bool> formUnstable = const Value.absent(),
                Value<int?> recommendationId = const Value.absent(),
              }) => WorkoutSessionExercisesCompanion(
                id: id,
                sessionId: sessionId,
                workoutExerciseId: workoutExerciseId,
                exerciseId: exerciseId,
                orderIndex: orderIndex,
                targetSets: targetSets,
                repMin: repMin,
                repMax: repMax,
                targetRir: targetRir,
                restSec: restSec,
                substitutedFrom: substitutedFrom,
                pain: pain,
                formUnstable: formUnstable,
                recommendationId: recommendationId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessionId,
                Value<int?> workoutExerciseId = const Value.absent(),
                required String exerciseId,
                required int orderIndex,
                required int targetSets,
                required int repMin,
                required int repMax,
                required int targetRir,
                required int restSec,
                Value<String?> substitutedFrom = const Value.absent(),
                Value<bool> pain = const Value.absent(),
                Value<bool> formUnstable = const Value.absent(),
                Value<int?> recommendationId = const Value.absent(),
              }) => WorkoutSessionExercisesCompanion.insert(
                id: id,
                sessionId: sessionId,
                workoutExerciseId: workoutExerciseId,
                exerciseId: exerciseId,
                orderIndex: orderIndex,
                targetSets: targetSets,
                repMin: repMin,
                repMax: repMax,
                targetRir: targetRir,
                restSec: restSec,
                substitutedFrom: substitutedFrom,
                pain: pain,
                formUnstable: formUnstable,
                recommendationId: recommendationId,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable<$WorkoutSessionExercisesTable, SessionExercise>(table), $$WorkoutSessionExercisesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({sessionId = false, exerciseId = false, workoutSetsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (workoutSetsRefs) db.workoutSets],
              addJoins:
                  <T extends TableManagerState<dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic>>(state) {
                    if (sessionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sessionId,
                        referencedTable: $$WorkoutSessionExercisesTableReferences._sessionIdTable(db),
                        referencedColumn: $$WorkoutSessionExercisesTableReferences._sessionIdTable(db).id,
                      ) as T;
                    }
                    if (exerciseId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.exerciseId,
                        referencedTable: $$WorkoutSessionExercisesTableReferences._exerciseIdTable(db),
                        referencedColumn: $$WorkoutSessionExercisesTableReferences._exerciseIdTable(db).id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (workoutSetsRefs)
                    await $_getPrefetchedDataByColumns<SessionExercise, $WorkoutSessionExercisesTable, WorkoutSet, $WorkoutSetsTable>(
                      currentTable: table,
                      referencedTable: $$WorkoutSessionExercisesTableReferences._workoutSetsRefsTable(db),
                      managerFromTypedResult: (p0) => $$WorkoutSessionExercisesTableReferences(db, table, p0).workoutSetsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'session_exercise_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$WorkoutSessionExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutSessionExercisesTable,
      SessionExercise,
      $$WorkoutSessionExercisesTableFilterComposer,
      $$WorkoutSessionExercisesTableOrderingComposer,
      $$WorkoutSessionExercisesTableAnnotationComposer,
      $$WorkoutSessionExercisesTableCreateCompanionBuilder,
      $$WorkoutSessionExercisesTableUpdateCompanionBuilder,
      (SessionExercise, $$WorkoutSessionExercisesTableReferences),
      SessionExercise,
      PrefetchHooks Function({bool sessionId, bool exerciseId, bool workoutSetsRefs})
    >;
typedef $$WorkoutSetsTableCreateCompanionBuilder = WorkoutSetsCompanion Function({
  Value<int> id,
  required int sessionId,
  required int sessionExerciseId,
  required String exerciseId,
  required int setNumber,
  Value<double?> targetWeight,
  Value<double?> actualWeight,
  Value<int?> targetReps,
  Value<int?> actualReps,
  Value<int?> rir,
  Value<bool> completed,
  Value<DateTime?> completedAt,
  Value<String> notes,
});
typedef $$WorkoutSetsTableUpdateCompanionBuilder = WorkoutSetsCompanion Function({
  Value<int> id,
  Value<int> sessionId,
  Value<int> sessionExerciseId,
  Value<String> exerciseId,
  Value<int> setNumber,
  Value<double?> targetWeight,
  Value<double?> actualWeight,
  Value<int?> targetReps,
  Value<int?> actualReps,
  Value<int?> rir,
  Value<bool> completed,
  Value<DateTime?> completedAt,
  Value<String> notes,
});

final class $$WorkoutSetsTableReferences extends BaseReferences<_$AppDatabase, $WorkoutSetsTable, WorkoutSet> {
  $$WorkoutSetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WorkoutSessionsTable _sessionIdTable(_$AppDatabase db) => db.workoutSessions.createAlias('workout_sets__session_id__workout_sessions__id');

  $$WorkoutSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$WorkoutSessionsTableTableManager($_db, $_db.workoutSessions).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }

  static $WorkoutSessionExercisesTable _sessionExerciseIdTable(_$AppDatabase db) =>
      db.workoutSessionExercises.createAlias('workout_sets__session_exercise_id__workout_session_exercises__id');

  $$WorkoutSessionExercisesTableProcessedTableManager get sessionExerciseId {
    final $_column = $_itemColumn<int>('session_exercise_id')!;

    final manager = $$WorkoutSessionExercisesTableTableManager($_db, $_db.workoutSessionExercises).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionExerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$WorkoutSetsTableFilterComposer extends Composer<_$AppDatabase, $WorkoutSetsTable> {
  $$WorkoutSetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get exerciseId => $composableBuilder(column: $table.exerciseId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get setNumber => $composableBuilder(column: $table.setNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get targetWeight => $composableBuilder(column: $table.targetWeight, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get actualWeight => $composableBuilder(column: $table.actualWeight, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get targetReps => $composableBuilder(column: $table.targetReps, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get actualReps => $composableBuilder(column: $table.actualReps, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get rir => $composableBuilder(column: $table.rir, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get completed => $composableBuilder(column: $table.completed, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(column: $table.notes, builder: (column) => ColumnFilters(column));

  $$WorkoutSessionsTableFilterComposer get sessionId {
    final $$WorkoutSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.workoutSessions,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$WorkoutSessionsTableFilterComposer(
        $db: $db,
        $table: $db.workoutSessions,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return composer;
  }

  $$WorkoutSessionExercisesTableFilterComposer get sessionExerciseId {
    final $$WorkoutSessionExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionExerciseId,
      referencedTable: $db.workoutSessionExercises,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$WorkoutSessionExercisesTableFilterComposer(
        $db: $db,
        $table: $db.workoutSessionExercises,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return composer;
  }
}

class $$WorkoutSetsTableOrderingComposer extends Composer<_$AppDatabase, $WorkoutSetsTable> {
  $$WorkoutSetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get exerciseId => $composableBuilder(column: $table.exerciseId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get setNumber => $composableBuilder(column: $table.setNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get targetWeight => $composableBuilder(column: $table.targetWeight, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get actualWeight => $composableBuilder(column: $table.actualWeight, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get targetReps => $composableBuilder(column: $table.targetReps, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get actualReps => $composableBuilder(column: $table.actualReps, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get rir => $composableBuilder(column: $table.rir, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get completed => $composableBuilder(column: $table.completed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(column: $table.notes, builder: (column) => ColumnOrderings(column));

  $$WorkoutSessionsTableOrderingComposer get sessionId {
    final $$WorkoutSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.workoutSessions,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$WorkoutSessionsTableOrderingComposer(
        $db: $db,
        $table: $db.workoutSessions,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return composer;
  }

  $$WorkoutSessionExercisesTableOrderingComposer get sessionExerciseId {
    final $$WorkoutSessionExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionExerciseId,
      referencedTable: $db.workoutSessionExercises,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$WorkoutSessionExercisesTableOrderingComposer(
        $db: $db,
        $table: $db.workoutSessionExercises,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return composer;
  }
}

class $$WorkoutSetsTableAnnotationComposer extends Composer<_$AppDatabase, $WorkoutSetsTable> {
  $$WorkoutSetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get exerciseId => $composableBuilder(column: $table.exerciseId, builder: (column) => column);

  GeneratedColumn<int> get setNumber => $composableBuilder(column: $table.setNumber, builder: (column) => column);

  GeneratedColumn<double> get targetWeight => $composableBuilder(column: $table.targetWeight, builder: (column) => column);

  GeneratedColumn<double> get actualWeight => $composableBuilder(column: $table.actualWeight, builder: (column) => column);

  GeneratedColumn<int> get targetReps => $composableBuilder(column: $table.targetReps, builder: (column) => column);

  GeneratedColumn<int> get actualReps => $composableBuilder(column: $table.actualReps, builder: (column) => column);

  GeneratedColumn<int> get rir => $composableBuilder(column: $table.rir, builder: (column) => column);

  GeneratedColumn<bool> get completed => $composableBuilder(column: $table.completed, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<String> get notes => $composableBuilder(column: $table.notes, builder: (column) => column);

  $$WorkoutSessionsTableAnnotationComposer get sessionId {
    final $$WorkoutSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.workoutSessions,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$WorkoutSessionsTableAnnotationComposer(
        $db: $db,
        $table: $db.workoutSessions,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return composer;
  }

  $$WorkoutSessionExercisesTableAnnotationComposer get sessionExerciseId {
    final $$WorkoutSessionExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionExerciseId,
      referencedTable: $db.workoutSessionExercises,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$WorkoutSessionExercisesTableAnnotationComposer(
        $db: $db,
        $table: $db.workoutSessionExercises,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return composer;
  }
}

class $$WorkoutSetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutSetsTable,
          WorkoutSet,
          $$WorkoutSetsTableFilterComposer,
          $$WorkoutSetsTableOrderingComposer,
          $$WorkoutSetsTableAnnotationComposer,
          $$WorkoutSetsTableCreateCompanionBuilder,
          $$WorkoutSetsTableUpdateCompanionBuilder,
          (WorkoutSet, $$WorkoutSetsTableReferences),
          WorkoutSet,
          PrefetchHooks Function({bool sessionId, bool sessionExerciseId})
        > {
  $$WorkoutSetsTableTableManager(_$AppDatabase db, $WorkoutSetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$WorkoutSetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$WorkoutSetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$WorkoutSetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<int> sessionExerciseId = const Value.absent(),
                Value<String> exerciseId = const Value.absent(),
                Value<int> setNumber = const Value.absent(),
                Value<double?> targetWeight = const Value.absent(),
                Value<double?> actualWeight = const Value.absent(),
                Value<int?> targetReps = const Value.absent(),
                Value<int?> actualReps = const Value.absent(),
                Value<int?> rir = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<String> notes = const Value.absent(),
              }) => WorkoutSetsCompanion(
                id: id,
                sessionId: sessionId,
                sessionExerciseId: sessionExerciseId,
                exerciseId: exerciseId,
                setNumber: setNumber,
                targetWeight: targetWeight,
                actualWeight: actualWeight,
                targetReps: targetReps,
                actualReps: actualReps,
                rir: rir,
                completed: completed,
                completedAt: completedAt,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessionId,
                required int sessionExerciseId,
                required String exerciseId,
                required int setNumber,
                Value<double?> targetWeight = const Value.absent(),
                Value<double?> actualWeight = const Value.absent(),
                Value<int?> targetReps = const Value.absent(),
                Value<int?> actualReps = const Value.absent(),
                Value<int?> rir = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<String> notes = const Value.absent(),
              }) => WorkoutSetsCompanion.insert(
                id: id,
                sessionId: sessionId,
                sessionExerciseId: sessionExerciseId,
                exerciseId: exerciseId,
                setNumber: setNumber,
                targetWeight: targetWeight,
                actualWeight: actualWeight,
                targetReps: targetReps,
                actualReps: actualReps,
                rir: rir,
                completed: completed,
                completedAt: completedAt,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable<$WorkoutSetsTable, WorkoutSet>(table), $$WorkoutSetsTableReferences(db, table, e))).toList(),
          prefetchHooksCallback: ({sessionId = false, sessionExerciseId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <T extends TableManagerState<dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic>>(state) {
                    if (sessionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sessionId,
                        referencedTable: $$WorkoutSetsTableReferences._sessionIdTable(db),
                        referencedColumn: $$WorkoutSetsTableReferences._sessionIdTable(db).id,
                      ) as T;
                    }
                    if (sessionExerciseId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sessionExerciseId,
                        referencedTable: $$WorkoutSetsTableReferences._sessionExerciseIdTable(db),
                        referencedColumn: $$WorkoutSetsTableReferences._sessionExerciseIdTable(db).id,
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

typedef $$WorkoutSetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutSetsTable,
      WorkoutSet,
      $$WorkoutSetsTableFilterComposer,
      $$WorkoutSetsTableOrderingComposer,
      $$WorkoutSetsTableAnnotationComposer,
      $$WorkoutSetsTableCreateCompanionBuilder,
      $$WorkoutSetsTableUpdateCompanionBuilder,
      (WorkoutSet, $$WorkoutSetsTableReferences),
      WorkoutSet,
      PrefetchHooks Function({bool sessionId, bool sessionExerciseId})
    >;
typedef $$BodyMeasurementsTableCreateCompanionBuilder = BodyMeasurementsCompanion Function({
  Value<int> id,
  required DateTime date,
  Value<double?> weightKg,
  Value<double?> bodyFatPct,
  Value<double?> skeletalMuscleKg,
  Value<double?> waistCm,
  Value<String> notes,
});
typedef $$BodyMeasurementsTableUpdateCompanionBuilder = BodyMeasurementsCompanion Function({
  Value<int> id,
  Value<DateTime> date,
  Value<double?> weightKg,
  Value<double?> bodyFatPct,
  Value<double?> skeletalMuscleKg,
  Value<double?> waistCm,
  Value<String> notes,
});

class $$BodyMeasurementsTableFilterComposer extends Composer<_$AppDatabase, $BodyMeasurementsTable> {
  $$BodyMeasurementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get weightKg => $composableBuilder(column: $table.weightKg, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get bodyFatPct => $composableBuilder(column: $table.bodyFatPct, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get skeletalMuscleKg => $composableBuilder(column: $table.skeletalMuscleKg, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get waistCm => $composableBuilder(column: $table.waistCm, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(column: $table.notes, builder: (column) => ColumnFilters(column));
}

class $$BodyMeasurementsTableOrderingComposer extends Composer<_$AppDatabase, $BodyMeasurementsTable> {
  $$BodyMeasurementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get weightKg => $composableBuilder(column: $table.weightKg, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get bodyFatPct => $composableBuilder(column: $table.bodyFatPct, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get skeletalMuscleKg => $composableBuilder(column: $table.skeletalMuscleKg, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get waistCm => $composableBuilder(column: $table.waistCm, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(column: $table.notes, builder: (column) => ColumnOrderings(column));
}

class $$BodyMeasurementsTableAnnotationComposer extends Composer<_$AppDatabase, $BodyMeasurementsTable> {
  $$BodyMeasurementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date => $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get weightKg => $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<double> get bodyFatPct => $composableBuilder(column: $table.bodyFatPct, builder: (column) => column);

  GeneratedColumn<double> get skeletalMuscleKg => $composableBuilder(column: $table.skeletalMuscleKg, builder: (column) => column);

  GeneratedColumn<double> get waistCm => $composableBuilder(column: $table.waistCm, builder: (column) => column);

  GeneratedColumn<String> get notes => $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$BodyMeasurementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BodyMeasurementsTable,
          BodyMeasurement,
          $$BodyMeasurementsTableFilterComposer,
          $$BodyMeasurementsTableOrderingComposer,
          $$BodyMeasurementsTableAnnotationComposer,
          $$BodyMeasurementsTableCreateCompanionBuilder,
          $$BodyMeasurementsTableUpdateCompanionBuilder,
          (BodyMeasurement, BaseReferences<_$AppDatabase, $BodyMeasurementsTable, BodyMeasurement>),
          BodyMeasurement,
          PrefetchHooks Function()
        > {
  $$BodyMeasurementsTableTableManager(_$AppDatabase db, $BodyMeasurementsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$BodyMeasurementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$BodyMeasurementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$BodyMeasurementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<double?> weightKg = const Value.absent(),
                Value<double?> bodyFatPct = const Value.absent(),
                Value<double?> skeletalMuscleKg = const Value.absent(),
                Value<double?> waistCm = const Value.absent(),
                Value<String> notes = const Value.absent(),
              }) => BodyMeasurementsCompanion(
                id: id,
                date: date,
                weightKg: weightKg,
                bodyFatPct: bodyFatPct,
                skeletalMuscleKg: skeletalMuscleKg,
                waistCm: waistCm,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime date,
                Value<double?> weightKg = const Value.absent(),
                Value<double?> bodyFatPct = const Value.absent(),
                Value<double?> skeletalMuscleKg = const Value.absent(),
                Value<double?> waistCm = const Value.absent(),
                Value<String> notes = const Value.absent(),
              }) => BodyMeasurementsCompanion.insert(
                id: id,
                date: date,
                weightKg: weightKg,
                bodyFatPct: bodyFatPct,
                skeletalMuscleKg: skeletalMuscleKg,
                waistCm: waistCm,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BodyMeasurementsTable, BodyMeasurement>(table),
                  BaseReferences<_$AppDatabase, $BodyMeasurementsTable, BodyMeasurement>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BodyMeasurementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BodyMeasurementsTable,
      BodyMeasurement,
      $$BodyMeasurementsTableFilterComposer,
      $$BodyMeasurementsTableOrderingComposer,
      $$BodyMeasurementsTableAnnotationComposer,
      $$BodyMeasurementsTableCreateCompanionBuilder,
      $$BodyMeasurementsTableUpdateCompanionBuilder,
      (BodyMeasurement, BaseReferences<_$AppDatabase, $BodyMeasurementsTable, BodyMeasurement>),
      BodyMeasurement,
      PrefetchHooks Function()
    >;
typedef $$RecoveryLogsTableCreateCompanionBuilder = RecoveryLogsCompanion Function({
  Value<int> id,
  required DateTime date,
  required double sleepHours,
  required int fatigue,
  required int soreness,
  required int motivation,
  required bool jointPain,
  Value<String?> painArea,
  required int score,
  required String readiness,
  Value<int?> sessionId,
});
typedef $$RecoveryLogsTableUpdateCompanionBuilder = RecoveryLogsCompanion Function({
  Value<int> id,
  Value<DateTime> date,
  Value<double> sleepHours,
  Value<int> fatigue,
  Value<int> soreness,
  Value<int> motivation,
  Value<bool> jointPain,
  Value<String?> painArea,
  Value<int> score,
  Value<String> readiness,
  Value<int?> sessionId,
});

class $$RecoveryLogsTableFilterComposer extends Composer<_$AppDatabase, $RecoveryLogsTable> {
  $$RecoveryLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get sleepHours => $composableBuilder(column: $table.sleepHours, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get fatigue => $composableBuilder(column: $table.fatigue, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get soreness => $composableBuilder(column: $table.soreness, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get motivation => $composableBuilder(column: $table.motivation, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get jointPain => $composableBuilder(column: $table.jointPain, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get painArea => $composableBuilder(column: $table.painArea, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get score => $composableBuilder(column: $table.score, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get readiness => $composableBuilder(column: $table.readiness, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sessionId => $composableBuilder(column: $table.sessionId, builder: (column) => ColumnFilters(column));
}

class $$RecoveryLogsTableOrderingComposer extends Composer<_$AppDatabase, $RecoveryLogsTable> {
  $$RecoveryLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get sleepHours => $composableBuilder(column: $table.sleepHours, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get fatigue => $composableBuilder(column: $table.fatigue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get soreness => $composableBuilder(column: $table.soreness, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get motivation => $composableBuilder(column: $table.motivation, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get jointPain => $composableBuilder(column: $table.jointPain, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get painArea => $composableBuilder(column: $table.painArea, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get score => $composableBuilder(column: $table.score, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get readiness => $composableBuilder(column: $table.readiness, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sessionId => $composableBuilder(column: $table.sessionId, builder: (column) => ColumnOrderings(column));
}

class $$RecoveryLogsTableAnnotationComposer extends Composer<_$AppDatabase, $RecoveryLogsTable> {
  $$RecoveryLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date => $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get sleepHours => $composableBuilder(column: $table.sleepHours, builder: (column) => column);

  GeneratedColumn<int> get fatigue => $composableBuilder(column: $table.fatigue, builder: (column) => column);

  GeneratedColumn<int> get soreness => $composableBuilder(column: $table.soreness, builder: (column) => column);

  GeneratedColumn<int> get motivation => $composableBuilder(column: $table.motivation, builder: (column) => column);

  GeneratedColumn<bool> get jointPain => $composableBuilder(column: $table.jointPain, builder: (column) => column);

  GeneratedColumn<String> get painArea => $composableBuilder(column: $table.painArea, builder: (column) => column);

  GeneratedColumn<int> get score => $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<String> get readiness => $composableBuilder(column: $table.readiness, builder: (column) => column);

  GeneratedColumn<int> get sessionId => $composableBuilder(column: $table.sessionId, builder: (column) => column);
}

class $$RecoveryLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecoveryLogsTable,
          RecoveryLog,
          $$RecoveryLogsTableFilterComposer,
          $$RecoveryLogsTableOrderingComposer,
          $$RecoveryLogsTableAnnotationComposer,
          $$RecoveryLogsTableCreateCompanionBuilder,
          $$RecoveryLogsTableUpdateCompanionBuilder,
          (RecoveryLog, BaseReferences<_$AppDatabase, $RecoveryLogsTable, RecoveryLog>),
          RecoveryLog,
          PrefetchHooks Function()
        > {
  $$RecoveryLogsTableTableManager(_$AppDatabase db, $RecoveryLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$RecoveryLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$RecoveryLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$RecoveryLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<double> sleepHours = const Value.absent(),
                Value<int> fatigue = const Value.absent(),
                Value<int> soreness = const Value.absent(),
                Value<int> motivation = const Value.absent(),
                Value<bool> jointPain = const Value.absent(),
                Value<String?> painArea = const Value.absent(),
                Value<int> score = const Value.absent(),
                Value<String> readiness = const Value.absent(),
                Value<int?> sessionId = const Value.absent(),
              }) => RecoveryLogsCompanion(
                id: id,
                date: date,
                sleepHours: sleepHours,
                fatigue: fatigue,
                soreness: soreness,
                motivation: motivation,
                jointPain: jointPain,
                painArea: painArea,
                score: score,
                readiness: readiness,
                sessionId: sessionId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime date,
                required double sleepHours,
                required int fatigue,
                required int soreness,
                required int motivation,
                required bool jointPain,
                Value<String?> painArea = const Value.absent(),
                required int score,
                required String readiness,
                Value<int?> sessionId = const Value.absent(),
              }) => RecoveryLogsCompanion.insert(
                id: id,
                date: date,
                sleepHours: sleepHours,
                fatigue: fatigue,
                soreness: soreness,
                motivation: motivation,
                jointPain: jointPain,
                painArea: painArea,
                score: score,
                readiness: readiness,
                sessionId: sessionId,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable<$RecoveryLogsTable, RecoveryLog>(table), BaseReferences<_$AppDatabase, $RecoveryLogsTable, RecoveryLog>(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecoveryLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecoveryLogsTable,
      RecoveryLog,
      $$RecoveryLogsTableFilterComposer,
      $$RecoveryLogsTableOrderingComposer,
      $$RecoveryLogsTableAnnotationComposer,
      $$RecoveryLogsTableCreateCompanionBuilder,
      $$RecoveryLogsTableUpdateCompanionBuilder,
      (RecoveryLog, BaseReferences<_$AppDatabase, $RecoveryLogsTable, RecoveryLog>),
      RecoveryLog,
      PrefetchHooks Function()
    >;
typedef $$ProgressionRecommendationsTableCreateCompanionBuilder = ProgressionRecommendationsCompanion Function({
  Value<int> id,
  required int userId,
  required String exerciseId,
  Value<int?> sessionId,
  Value<double?> previousWeight,
  Value<double?> recommendedWeight,
  required String recommendedReps,
  required int recommendedSets,
  required String action,
  required String reason,
  required String confidenceLevel,
  Value<DateTime> createdAt,
  Value<bool?> accepted,
});
typedef $$ProgressionRecommendationsTableUpdateCompanionBuilder = ProgressionRecommendationsCompanion Function({
  Value<int> id,
  Value<int> userId,
  Value<String> exerciseId,
  Value<int?> sessionId,
  Value<double?> previousWeight,
  Value<double?> recommendedWeight,
  Value<String> recommendedReps,
  Value<int> recommendedSets,
  Value<String> action,
  Value<String> reason,
  Value<String> confidenceLevel,
  Value<DateTime> createdAt,
  Value<bool?> accepted,
});

class $$ProgressionRecommendationsTableFilterComposer extends Composer<_$AppDatabase, $ProgressionRecommendationsTable> {
  $$ProgressionRecommendationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get userId => $composableBuilder(column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get exerciseId => $composableBuilder(column: $table.exerciseId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sessionId => $composableBuilder(column: $table.sessionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get previousWeight => $composableBuilder(column: $table.previousWeight, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get recommendedWeight => $composableBuilder(column: $table.recommendedWeight, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get recommendedReps => $composableBuilder(column: $table.recommendedReps, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get recommendedSets => $composableBuilder(column: $table.recommendedSets, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get action => $composableBuilder(column: $table.action, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reason => $composableBuilder(column: $table.reason, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get confidenceLevel => $composableBuilder(column: $table.confidenceLevel, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get accepted => $composableBuilder(column: $table.accepted, builder: (column) => ColumnFilters(column));
}

class $$ProgressionRecommendationsTableOrderingComposer extends Composer<_$AppDatabase, $ProgressionRecommendationsTable> {
  $$ProgressionRecommendationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get userId => $composableBuilder(column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get exerciseId => $composableBuilder(column: $table.exerciseId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sessionId => $composableBuilder(column: $table.sessionId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get previousWeight => $composableBuilder(column: $table.previousWeight, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get recommendedWeight => $composableBuilder(column: $table.recommendedWeight, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get recommendedReps => $composableBuilder(column: $table.recommendedReps, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get recommendedSets => $composableBuilder(column: $table.recommendedSets, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get action => $composableBuilder(column: $table.action, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reason => $composableBuilder(column: $table.reason, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get confidenceLevel => $composableBuilder(column: $table.confidenceLevel, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get accepted => $composableBuilder(column: $table.accepted, builder: (column) => ColumnOrderings(column));
}

class $$ProgressionRecommendationsTableAnnotationComposer extends Composer<_$AppDatabase, $ProgressionRecommendationsTable> {
  $$ProgressionRecommendationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get userId => $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get exerciseId => $composableBuilder(column: $table.exerciseId, builder: (column) => column);

  GeneratedColumn<int> get sessionId => $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<double> get previousWeight => $composableBuilder(column: $table.previousWeight, builder: (column) => column);

  GeneratedColumn<double> get recommendedWeight => $composableBuilder(column: $table.recommendedWeight, builder: (column) => column);

  GeneratedColumn<String> get recommendedReps => $composableBuilder(column: $table.recommendedReps, builder: (column) => column);

  GeneratedColumn<int> get recommendedSets => $composableBuilder(column: $table.recommendedSets, builder: (column) => column);

  GeneratedColumn<String> get action => $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get reason => $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get confidenceLevel => $composableBuilder(column: $table.confidenceLevel, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get accepted => $composableBuilder(column: $table.accepted, builder: (column) => column);
}

class $$ProgressionRecommendationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProgressionRecommendationsTable,
          ProgressionRecommendationRow,
          $$ProgressionRecommendationsTableFilterComposer,
          $$ProgressionRecommendationsTableOrderingComposer,
          $$ProgressionRecommendationsTableAnnotationComposer,
          $$ProgressionRecommendationsTableCreateCompanionBuilder,
          $$ProgressionRecommendationsTableUpdateCompanionBuilder,
          (ProgressionRecommendationRow, BaseReferences<_$AppDatabase, $ProgressionRecommendationsTable, ProgressionRecommendationRow>),
          ProgressionRecommendationRow,
          PrefetchHooks Function()
        > {
  $$ProgressionRecommendationsTableTableManager(_$AppDatabase db, $ProgressionRecommendationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$ProgressionRecommendationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$ProgressionRecommendationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$ProgressionRecommendationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> userId = const Value.absent(),
                Value<String> exerciseId = const Value.absent(),
                Value<int?> sessionId = const Value.absent(),
                Value<double?> previousWeight = const Value.absent(),
                Value<double?> recommendedWeight = const Value.absent(),
                Value<String> recommendedReps = const Value.absent(),
                Value<int> recommendedSets = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<String> confidenceLevel = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool?> accepted = const Value.absent(),
              }) => ProgressionRecommendationsCompanion(
                id: id,
                userId: userId,
                exerciseId: exerciseId,
                sessionId: sessionId,
                previousWeight: previousWeight,
                recommendedWeight: recommendedWeight,
                recommendedReps: recommendedReps,
                recommendedSets: recommendedSets,
                action: action,
                reason: reason,
                confidenceLevel: confidenceLevel,
                createdAt: createdAt,
                accepted: accepted,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int userId,
                required String exerciseId,
                Value<int?> sessionId = const Value.absent(),
                Value<double?> previousWeight = const Value.absent(),
                Value<double?> recommendedWeight = const Value.absent(),
                required String recommendedReps,
                required int recommendedSets,
                required String action,
                required String reason,
                required String confidenceLevel,
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool?> accepted = const Value.absent(),
              }) => ProgressionRecommendationsCompanion.insert(
                id: id,
                userId: userId,
                exerciseId: exerciseId,
                sessionId: sessionId,
                previousWeight: previousWeight,
                recommendedWeight: recommendedWeight,
                recommendedReps: recommendedReps,
                recommendedSets: recommendedSets,
                action: action,
                reason: reason,
                confidenceLevel: confidenceLevel,
                createdAt: createdAt,
                accepted: accepted,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProgressionRecommendationsTable, ProgressionRecommendationRow>(table),
                  BaseReferences<_$AppDatabase, $ProgressionRecommendationsTable, ProgressionRecommendationRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProgressionRecommendationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProgressionRecommendationsTable,
      ProgressionRecommendationRow,
      $$ProgressionRecommendationsTableFilterComposer,
      $$ProgressionRecommendationsTableOrderingComposer,
      $$ProgressionRecommendationsTableAnnotationComposer,
      $$ProgressionRecommendationsTableCreateCompanionBuilder,
      $$ProgressionRecommendationsTableUpdateCompanionBuilder,
      (ProgressionRecommendationRow, BaseReferences<_$AppDatabase, $ProgressionRecommendationsTable, ProgressionRecommendationRow>),
      ProgressionRecommendationRow,
      PrefetchHooks Function()
    >;
typedef $$AiRecommendationsTableCreateCompanionBuilder = AiRecommendationsCompanion Function({
  Value<int> id,
  Value<DateTime> createdAt,
  required String kind,
  required String title,
  required String body,
  required String payload,
  Value<String> status,
});
typedef $$AiRecommendationsTableUpdateCompanionBuilder = AiRecommendationsCompanion Function({
  Value<int> id,
  Value<DateTime> createdAt,
  Value<String> kind,
  Value<String> title,
  Value<String> body,
  Value<String> payload,
  Value<String> status,
});

class $$AiRecommendationsTableFilterComposer extends Composer<_$AppDatabase, $AiRecommendationsTable> {
  $$AiRecommendationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get kind => $composableBuilder(column: $table.kind, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get body => $composableBuilder(column: $table.body, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payload => $composableBuilder(column: $table.payload, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(column: $table.status, builder: (column) => ColumnFilters(column));
}

class $$AiRecommendationsTableOrderingComposer extends Composer<_$AppDatabase, $AiRecommendationsTable> {
  $$AiRecommendationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kind => $composableBuilder(column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get body => $composableBuilder(column: $table.body, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payload => $composableBuilder(column: $table.payload, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(column: $table.status, builder: (column) => ColumnOrderings(column));
}

class $$AiRecommendationsTableAnnotationComposer extends Composer<_$AppDatabase, $AiRecommendationsTable> {
  $$AiRecommendationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get kind => $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get title => $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get body => $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get payload => $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<String> get status => $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$AiRecommendationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AiRecommendationsTable,
          AiRecommendation,
          $$AiRecommendationsTableFilterComposer,
          $$AiRecommendationsTableOrderingComposer,
          $$AiRecommendationsTableAnnotationComposer,
          $$AiRecommendationsTableCreateCompanionBuilder,
          $$AiRecommendationsTableUpdateCompanionBuilder,
          (AiRecommendation, BaseReferences<_$AppDatabase, $AiRecommendationsTable, AiRecommendation>),
          AiRecommendation,
          PrefetchHooks Function()
        > {
  $$AiRecommendationsTableTableManager(_$AppDatabase db, $AiRecommendationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$AiRecommendationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$AiRecommendationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$AiRecommendationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<String> kind = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> body = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<String> status = const Value.absent(),
          }) => AiRecommendationsCompanion(id: id, createdAt: createdAt, kind: kind, title: title, body: body, payload: payload, status: status),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            required String kind,
            required String title,
            required String body,
            required String payload,
            Value<String> status = const Value.absent(),
          }) => AiRecommendationsCompanion.insert(id: id, createdAt: createdAt, kind: kind, title: title, body: body, payload: payload, status: status),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AiRecommendationsTable, AiRecommendation>(table),
                  BaseReferences<_$AppDatabase, $AiRecommendationsTable, AiRecommendation>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AiRecommendationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AiRecommendationsTable,
      AiRecommendation,
      $$AiRecommendationsTableFilterComposer,
      $$AiRecommendationsTableOrderingComposer,
      $$AiRecommendationsTableAnnotationComposer,
      $$AiRecommendationsTableCreateCompanionBuilder,
      $$AiRecommendationsTableUpdateCompanionBuilder,
      (AiRecommendation, BaseReferences<_$AppDatabase, $AiRecommendationsTable, AiRecommendation>),
      AiRecommendation,
      PrefetchHooks Function()
    >;
typedef $$ResearchReferencesTableCreateCompanionBuilder = ResearchReferencesCompanion Function({
  required String id,
  required String title,
  required String authors,
  required int year,
  required String journal,
  required String studyType,
  required String population,
  required String keyFindings,
  required String limitations,
  required String appliedIn,
  Value<int> rowid,
});
typedef $$ResearchReferencesTableUpdateCompanionBuilder = ResearchReferencesCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String> authors,
  Value<int> year,
  Value<String> journal,
  Value<String> studyType,
  Value<String> population,
  Value<String> keyFindings,
  Value<String> limitations,
  Value<String> appliedIn,
  Value<int> rowid,
});

class $$ResearchReferencesTableFilterComposer extends Composer<_$AppDatabase, $ResearchReferencesTable> {
  $$ResearchReferencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get authors => $composableBuilder(column: $table.authors, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get year => $composableBuilder(column: $table.year, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get journal => $composableBuilder(column: $table.journal, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get studyType => $composableBuilder(column: $table.studyType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get population => $composableBuilder(column: $table.population, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get keyFindings => $composableBuilder(column: $table.keyFindings, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get limitations => $composableBuilder(column: $table.limitations, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get appliedIn => $composableBuilder(column: $table.appliedIn, builder: (column) => ColumnFilters(column));
}

class $$ResearchReferencesTableOrderingComposer extends Composer<_$AppDatabase, $ResearchReferencesTable> {
  $$ResearchReferencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get authors => $composableBuilder(column: $table.authors, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get year => $composableBuilder(column: $table.year, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get journal => $composableBuilder(column: $table.journal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get studyType => $composableBuilder(column: $table.studyType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get population => $composableBuilder(column: $table.population, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get keyFindings => $composableBuilder(column: $table.keyFindings, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get limitations => $composableBuilder(column: $table.limitations, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get appliedIn => $composableBuilder(column: $table.appliedIn, builder: (column) => ColumnOrderings(column));
}

class $$ResearchReferencesTableAnnotationComposer extends Composer<_$AppDatabase, $ResearchReferencesTable> {
  $$ResearchReferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title => $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get authors => $composableBuilder(column: $table.authors, builder: (column) => column);

  GeneratedColumn<int> get year => $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<String> get journal => $composableBuilder(column: $table.journal, builder: (column) => column);

  GeneratedColumn<String> get studyType => $composableBuilder(column: $table.studyType, builder: (column) => column);

  GeneratedColumn<String> get population => $composableBuilder(column: $table.population, builder: (column) => column);

  GeneratedColumn<String> get keyFindings => $composableBuilder(column: $table.keyFindings, builder: (column) => column);

  GeneratedColumn<String> get limitations => $composableBuilder(column: $table.limitations, builder: (column) => column);

  GeneratedColumn<String> get appliedIn => $composableBuilder(column: $table.appliedIn, builder: (column) => column);
}

class $$ResearchReferencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ResearchReferencesTable,
          ResearchReferenceRow,
          $$ResearchReferencesTableFilterComposer,
          $$ResearchReferencesTableOrderingComposer,
          $$ResearchReferencesTableAnnotationComposer,
          $$ResearchReferencesTableCreateCompanionBuilder,
          $$ResearchReferencesTableUpdateCompanionBuilder,
          (ResearchReferenceRow, BaseReferences<_$AppDatabase, $ResearchReferencesTable, ResearchReferenceRow>),
          ResearchReferenceRow,
          PrefetchHooks Function()
        > {
  $$ResearchReferencesTableTableManager(_$AppDatabase db, $ResearchReferencesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$ResearchReferencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$ResearchReferencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$ResearchReferencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> authors = const Value.absent(),
                Value<int> year = const Value.absent(),
                Value<String> journal = const Value.absent(),
                Value<String> studyType = const Value.absent(),
                Value<String> population = const Value.absent(),
                Value<String> keyFindings = const Value.absent(),
                Value<String> limitations = const Value.absent(),
                Value<String> appliedIn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ResearchReferencesCompanion(
                id: id,
                title: title,
                authors: authors,
                year: year,
                journal: journal,
                studyType: studyType,
                population: population,
                keyFindings: keyFindings,
                limitations: limitations,
                appliedIn: appliedIn,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String authors,
                required int year,
                required String journal,
                required String studyType,
                required String population,
                required String keyFindings,
                required String limitations,
                required String appliedIn,
                Value<int> rowid = const Value.absent(),
              }) => ResearchReferencesCompanion.insert(
                id: id,
                title: title,
                authors: authors,
                year: year,
                journal: journal,
                studyType: studyType,
                population: population,
                keyFindings: keyFindings,
                limitations: limitations,
                appliedIn: appliedIn,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ResearchReferencesTable, ResearchReferenceRow>(table),
                  BaseReferences<_$AppDatabase, $ResearchReferencesTable, ResearchReferenceRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ResearchReferencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ResearchReferencesTable,
      ResearchReferenceRow,
      $$ResearchReferencesTableFilterComposer,
      $$ResearchReferencesTableOrderingComposer,
      $$ResearchReferencesTableAnnotationComposer,
      $$ResearchReferencesTableCreateCompanionBuilder,
      $$ResearchReferencesTableUpdateCompanionBuilder,
      (ResearchReferenceRow, BaseReferences<_$AppDatabase, $ResearchReferencesTable, ResearchReferenceRow>),
      ResearchReferenceRow,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder = AppSettingsCompanion Function({required String key, required String value, Value<int> rowid});
typedef $$AppSettingsTableUpdateCompanionBuilder = AppSettingsCompanion Function({Value<String> key, Value<String> value, Value<int> rowid});

class $$AppSettingsTableFilterComposer extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$AppSettingsTableOrderingComposer extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$AppSettingsTableAnnotationComposer extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key => $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value => $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (AppSetting, BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => AppSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({required String key, required String value, Value<int> rowid = const Value.absent()}) =>
              AppSettingsCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable<$AppSettingsTable, AppSetting>(table), BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (AppSetting, BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>),
      AppSetting,
      PrefetchHooks Function()
    >;
typedef $$ChatMessagesTableCreateCompanionBuilder = ChatMessagesCompanion Function({
  Value<int> id,
  Value<DateTime> createdAt,
  required String role,
  required String content,
  Value<String?> provider,
  Value<int?> recommendationId,
});
typedef $$ChatMessagesTableUpdateCompanionBuilder = ChatMessagesCompanion Function({
  Value<int> id,
  Value<DateTime> createdAt,
  Value<String> role,
  Value<String> content,
  Value<String?> provider,
  Value<int?> recommendationId,
});

class $$ChatMessagesTableFilterComposer extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role => $composableBuilder(column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get provider => $composableBuilder(column: $table.provider, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get recommendationId => $composableBuilder(column: $table.recommendationId, builder: (column) => ColumnFilters(column));
}

class $$ChatMessagesTableOrderingComposer extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get provider => $composableBuilder(column: $table.provider, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get recommendationId => $composableBuilder(column: $table.recommendationId, builder: (column) => ColumnOrderings(column));
}

class $$ChatMessagesTableAnnotationComposer extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get role => $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get content => $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get provider => $composableBuilder(column: $table.provider, builder: (column) => column);

  GeneratedColumn<int> get recommendationId => $composableBuilder(column: $table.recommendationId, builder: (column) => column);
}

class $$ChatMessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChatMessagesTable,
          ChatMessage,
          $$ChatMessagesTableFilterComposer,
          $$ChatMessagesTableOrderingComposer,
          $$ChatMessagesTableAnnotationComposer,
          $$ChatMessagesTableCreateCompanionBuilder,
          $$ChatMessagesTableUpdateCompanionBuilder,
          (ChatMessage, BaseReferences<_$AppDatabase, $ChatMessagesTable, ChatMessage>),
          ChatMessage,
          PrefetchHooks Function()
        > {
  $$ChatMessagesTableTableManager(_$AppDatabase db, $ChatMessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$ChatMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$ChatMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$ChatMessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<String?> provider = const Value.absent(),
            Value<int?> recommendationId = const Value.absent(),
          }) => ChatMessagesCompanion(id: id, createdAt: createdAt, role: role, content: content, provider: provider, recommendationId: recommendationId),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                required String role,
                required String content,
                Value<String?> provider = const Value.absent(),
                Value<int?> recommendationId = const Value.absent(),
              }) => ChatMessagesCompanion.insert(
                id: id,
                createdAt: createdAt,
                role: role,
                content: content,
                provider: provider,
                recommendationId: recommendationId,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable<$ChatMessagesTable, ChatMessage>(table), BaseReferences<_$AppDatabase, $ChatMessagesTable, ChatMessage>(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChatMessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChatMessagesTable,
      ChatMessage,
      $$ChatMessagesTableFilterComposer,
      $$ChatMessagesTableOrderingComposer,
      $$ChatMessagesTableAnnotationComposer,
      $$ChatMessagesTableCreateCompanionBuilder,
      $$ChatMessagesTableUpdateCompanionBuilder,
      (ChatMessage, BaseReferences<_$AppDatabase, $ChatMessagesTable, ChatMessage>),
      ChatMessage,
      PrefetchHooks Function()
    >;
typedef $$AiUsageLogsTableCreateCompanionBuilder = AiUsageLogsCompanion Function({
  Value<int> id,
  Value<DateTime> createdAt,
  required String provider,
  required String model,
  Value<int> inputTokens,
  Value<int> outputTokens,
});
typedef $$AiUsageLogsTableUpdateCompanionBuilder = AiUsageLogsCompanion Function({
  Value<int> id,
  Value<DateTime> createdAt,
  Value<String> provider,
  Value<String> model,
  Value<int> inputTokens,
  Value<int> outputTokens,
});

class $$AiUsageLogsTableFilterComposer extends Composer<_$AppDatabase, $AiUsageLogsTable> {
  $$AiUsageLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get provider => $composableBuilder(column: $table.provider, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get model => $composableBuilder(column: $table.model, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get inputTokens => $composableBuilder(column: $table.inputTokens, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get outputTokens => $composableBuilder(column: $table.outputTokens, builder: (column) => ColumnFilters(column));
}

class $$AiUsageLogsTableOrderingComposer extends Composer<_$AppDatabase, $AiUsageLogsTable> {
  $$AiUsageLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get provider => $composableBuilder(column: $table.provider, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get model => $composableBuilder(column: $table.model, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get inputTokens => $composableBuilder(column: $table.inputTokens, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get outputTokens => $composableBuilder(column: $table.outputTokens, builder: (column) => ColumnOrderings(column));
}

class $$AiUsageLogsTableAnnotationComposer extends Composer<_$AppDatabase, $AiUsageLogsTable> {
  $$AiUsageLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get provider => $composableBuilder(column: $table.provider, builder: (column) => column);

  GeneratedColumn<String> get model => $composableBuilder(column: $table.model, builder: (column) => column);

  GeneratedColumn<int> get inputTokens => $composableBuilder(column: $table.inputTokens, builder: (column) => column);

  GeneratedColumn<int> get outputTokens => $composableBuilder(column: $table.outputTokens, builder: (column) => column);
}

class $$AiUsageLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AiUsageLogsTable,
          AiUsageLog,
          $$AiUsageLogsTableFilterComposer,
          $$AiUsageLogsTableOrderingComposer,
          $$AiUsageLogsTableAnnotationComposer,
          $$AiUsageLogsTableCreateCompanionBuilder,
          $$AiUsageLogsTableUpdateCompanionBuilder,
          (AiUsageLog, BaseReferences<_$AppDatabase, $AiUsageLogsTable, AiUsageLog>),
          AiUsageLog,
          PrefetchHooks Function()
        > {
  $$AiUsageLogsTableTableManager(_$AppDatabase db, $AiUsageLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$AiUsageLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$AiUsageLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$AiUsageLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<String> provider = const Value.absent(),
            Value<String> model = const Value.absent(),
            Value<int> inputTokens = const Value.absent(),
            Value<int> outputTokens = const Value.absent(),
          }) => AiUsageLogsCompanion(id: id, createdAt: createdAt, provider: provider, model: model, inputTokens: inputTokens, outputTokens: outputTokens),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                required String provider,
                required String model,
                Value<int> inputTokens = const Value.absent(),
                Value<int> outputTokens = const Value.absent(),
              }) => AiUsageLogsCompanion.insert(
                id: id,
                createdAt: createdAt,
                provider: provider,
                model: model,
                inputTokens: inputTokens,
                outputTokens: outputTokens,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable<$AiUsageLogsTable, AiUsageLog>(table), BaseReferences<_$AppDatabase, $AiUsageLogsTable, AiUsageLog>(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AiUsageLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AiUsageLogsTable,
      AiUsageLog,
      $$AiUsageLogsTableFilterComposer,
      $$AiUsageLogsTableOrderingComposer,
      $$AiUsageLogsTableAnnotationComposer,
      $$AiUsageLogsTableCreateCompanionBuilder,
      $$AiUsageLogsTableUpdateCompanionBuilder,
      (AiUsageLog, BaseReferences<_$AppDatabase, $AiUsageLogsTable, AiUsageLog>),
      AiUsageLog,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users => $$UsersTableTableManager(_db, _db.users);
  $$UserProfilesTableTableManager get userProfiles => $$UserProfilesTableTableManager(_db, _db.userProfiles);
  $$UserGoalsTableTableManager get userGoals => $$UserGoalsTableTableManager(_db, _db.userGoals);
  $$UserEquipmentTableTableManager get userEquipment => $$UserEquipmentTableTableManager(_db, _db.userEquipment);
  $$UserLimitationsTableTableManager get userLimitations => $$UserLimitationsTableTableManager(_db, _db.userLimitations);
  $$ExercisesTableTableManager get exercises => $$ExercisesTableTableManager(_db, _db.exercises);
  $$ExerciseMusclesTableTableManager get exerciseMuscles => $$ExerciseMusclesTableTableManager(_db, _db.exerciseMuscles);
  $$ExerciseAlternativesTableTableManager get exerciseAlternatives => $$ExerciseAlternativesTableTableManager(_db, _db.exerciseAlternatives);
  $$WorkoutProgramsTableTableManager get workoutPrograms => $$WorkoutProgramsTableTableManager(_db, _db.workoutPrograms);
  $$WorkoutDaysTableTableManager get workoutDays => $$WorkoutDaysTableTableManager(_db, _db.workoutDays);
  $$WorkoutExercisesTableTableManager get workoutExercises => $$WorkoutExercisesTableTableManager(_db, _db.workoutExercises);
  $$WorkoutSessionsTableTableManager get workoutSessions => $$WorkoutSessionsTableTableManager(_db, _db.workoutSessions);
  $$WorkoutSessionExercisesTableTableManager get workoutSessionExercises => $$WorkoutSessionExercisesTableTableManager(_db, _db.workoutSessionExercises);
  $$WorkoutSetsTableTableManager get workoutSets => $$WorkoutSetsTableTableManager(_db, _db.workoutSets);
  $$BodyMeasurementsTableTableManager get bodyMeasurements => $$BodyMeasurementsTableTableManager(_db, _db.bodyMeasurements);
  $$RecoveryLogsTableTableManager get recoveryLogs => $$RecoveryLogsTableTableManager(_db, _db.recoveryLogs);
  $$ProgressionRecommendationsTableTableManager get progressionRecommendations =>
      $$ProgressionRecommendationsTableTableManager(_db, _db.progressionRecommendations);
  $$AiRecommendationsTableTableManager get aiRecommendations => $$AiRecommendationsTableTableManager(_db, _db.aiRecommendations);
  $$ResearchReferencesTableTableManager get researchReferences => $$ResearchReferencesTableTableManager(_db, _db.researchReferences);
  $$AppSettingsTableTableManager get appSettings => $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$ChatMessagesTableTableManager get chatMessages => $$ChatMessagesTableTableManager(_db, _db.chatMessages);
  $$AiUsageLogsTableTableManager get aiUsageLogs => $$AiUsageLogsTableTableManager(_db, _db.aiUsageLogs);
}
