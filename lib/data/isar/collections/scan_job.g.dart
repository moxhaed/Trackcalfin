// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scan_job.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetScanJobCollection on Isar {
  IsarCollection<ScanJob> get scanJobs => this.collection();
}

const ScanJobSchema = CollectionSchema(
  name: r'ScanJob',
  id: -7190018832374939473,
  properties: {
    r'aiCallLogId': PropertySchema(id: 0, name: r'aiCallLogId', type: IsarType.long),
    r'attempts': PropertySchema(id: 1, name: r'attempts', type: IsarType.long),
    r'capturedAt': PropertySchema(id: 2, name: r'capturedAt', type: IsarType.dateTime),
    r'currency': PropertySchema(id: 3, name: r'currency', type: IsarType.string),
    r'flags': PropertySchema(id: 4, name: r'flags', type: IsarType.stringList),
    r'imagePaths': PropertySchema(id: 5, name: r'imagePaths', type: IsarType.stringList),
    r'kind': PropertySchema(id: 6, name: r'kind', type: IsarType.string, enumMap: _ScanJobkindEnumValueMap),
    r'lastError': PropertySchema(id: 7, name: r'lastError', type: IsarType.string),
    r'lines': PropertySchema(id: 8, name: r'lines', type: IsarType.objectList, target: r'DraftLine'),
    r'merchant': PropertySchema(id: 9, name: r'merchant', type: IsarType.string),
    r'purchasedAt': PropertySchema(id: 10, name: r'purchasedAt', type: IsarType.dateTime),
    r'receiptTotalMinor': PropertySchema(id: 11, name: r'receiptTotalMinor', type: IsarType.long),
    r'status': PropertySchema(id: 12, name: r'status', type: IsarType.string, enumMap: _ScanJobstatusEnumValueMap),
    r'transactionId': PropertySchema(id: 13, name: r'transactionId', type: IsarType.long),
    r'userHint': PropertySchema(id: 14, name: r'userHint', type: IsarType.string),
  },

  estimateSize: _scanJobEstimateSize,
  serialize: _scanJobSerialize,
  deserialize: _scanJobDeserialize,
  deserializeProp: _scanJobDeserializeProp,
  idName: r'id',
  indexes: {
    r'status': IndexSchema(
      id: -107785170620420283,
      name: r'status',
      unique: false,
      replace: false,
      properties: [IndexPropertySchema(name: r'status', type: IndexType.hash, caseSensitive: true)],
    ),
  },
  links: {},
  embeddedSchemas: {
    r'DraftLine': DraftLineSchema,
    r'NewIngredientProfile': NewIngredientProfileSchema,
    r'Nutrition': NutritionSchema,
  },

  getId: _scanJobGetId,
  getLinks: _scanJobGetLinks,
  attach: _scanJobAttach,
  version: '3.3.2',
);

int _scanJobEstimateSize(ScanJob object, List<int> offsets, Map<Type, List<int>> allOffsets) {
  var bytesCount = offsets.last;
  {
    final value = object.currency;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.flags.length * 3;
  {
    for (var i = 0; i < object.flags.length; i++) {
      final value = object.flags[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.imagePaths.length * 3;
  {
    for (var i = 0; i < object.imagePaths.length; i++) {
      final value = object.imagePaths[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.kind.name.length * 3;
  {
    final value = object.lastError;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.lines.length * 3;
  {
    final offsets = allOffsets[DraftLine]!;
    for (var i = 0; i < object.lines.length; i++) {
      final value = object.lines[i];
      bytesCount += DraftLineSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  {
    final value = object.merchant;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.status.name.length * 3;
  {
    final value = object.userHint;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _scanJobSerialize(ScanJob object, IsarWriter writer, List<int> offsets, Map<Type, List<int>> allOffsets) {
  writer.writeLong(offsets[0], object.aiCallLogId);
  writer.writeLong(offsets[1], object.attempts);
  writer.writeDateTime(offsets[2], object.capturedAt);
  writer.writeString(offsets[3], object.currency);
  writer.writeStringList(offsets[4], object.flags);
  writer.writeStringList(offsets[5], object.imagePaths);
  writer.writeString(offsets[6], object.kind.name);
  writer.writeString(offsets[7], object.lastError);
  writer.writeObjectList<DraftLine>(offsets[8], allOffsets, DraftLineSchema.serialize, object.lines);
  writer.writeString(offsets[9], object.merchant);
  writer.writeDateTime(offsets[10], object.purchasedAt);
  writer.writeLong(offsets[11], object.receiptTotalMinor);
  writer.writeString(offsets[12], object.status.name);
  writer.writeLong(offsets[13], object.transactionId);
  writer.writeString(offsets[14], object.userHint);
}

ScanJob _scanJobDeserialize(Id id, IsarReader reader, List<int> offsets, Map<Type, List<int>> allOffsets) {
  final object = ScanJob();
  object.aiCallLogId = reader.readLongOrNull(offsets[0]);
  object.attempts = reader.readLong(offsets[1]);
  object.capturedAt = reader.readDateTime(offsets[2]);
  object.currency = reader.readStringOrNull(offsets[3]);
  object.flags = reader.readStringList(offsets[4]) ?? [];
  object.id = id;
  object.imagePaths = reader.readStringList(offsets[5]) ?? [];
  object.kind = _ScanJobkindValueEnumMap[reader.readStringOrNull(offsets[6])] ?? ScanKind.unknown;
  object.lastError = reader.readStringOrNull(offsets[7]);
  object.lines =
      reader.readObjectList<DraftLine>(offsets[8], DraftLineSchema.deserialize, allOffsets, DraftLine()) ?? [];
  object.merchant = reader.readStringOrNull(offsets[9]);
  object.purchasedAt = reader.readDateTimeOrNull(offsets[10]);
  object.receiptTotalMinor = reader.readLongOrNull(offsets[11]);
  object.status = _ScanJobstatusValueEnumMap[reader.readStringOrNull(offsets[12])] ?? ScanStatus.queued;
  object.transactionId = reader.readLongOrNull(offsets[13]);
  object.userHint = reader.readStringOrNull(offsets[14]);
  return object;
}

P _scanJobDeserializeProp<P>(IsarReader reader, int propertyId, int offset, Map<Type, List<int>> allOffsets) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readStringList(offset) ?? []) as P;
    case 5:
      return (reader.readStringList(offset) ?? []) as P;
    case 6:
      return (_ScanJobkindValueEnumMap[reader.readStringOrNull(offset)] ?? ScanKind.unknown) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readObjectList<DraftLine>(offset, DraftLineSchema.deserialize, allOffsets, DraftLine()) ?? [])
          as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 11:
      return (reader.readLongOrNull(offset)) as P;
    case 12:
      return (_ScanJobstatusValueEnumMap[reader.readStringOrNull(offset)] ?? ScanStatus.queued) as P;
    case 13:
      return (reader.readLongOrNull(offset)) as P;
    case 14:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _ScanJobkindEnumValueMap = {
  r'unknown': r'unknown',
  r'receipt': r'receipt',
  r'pantry': r'pantry',
  r'unreadable': r'unreadable',
};
const _ScanJobkindValueEnumMap = {
  r'unknown': ScanKind.unknown,
  r'receipt': ScanKind.receipt,
  r'pantry': ScanKind.pantry,
  r'unreadable': ScanKind.unreadable,
};
const _ScanJobstatusEnumValueMap = {
  r'queued': r'queued',
  r'processing': r'processing',
  r'needsReview': r'needsReview',
  r'committed': r'committed',
  r'failed': r'failed',
  r'discarded': r'discarded',
};
const _ScanJobstatusValueEnumMap = {
  r'queued': ScanStatus.queued,
  r'processing': ScanStatus.processing,
  r'needsReview': ScanStatus.needsReview,
  r'committed': ScanStatus.committed,
  r'failed': ScanStatus.failed,
  r'discarded': ScanStatus.discarded,
};

Id _scanJobGetId(ScanJob object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _scanJobGetLinks(ScanJob object) {
  return [];
}

void _scanJobAttach(IsarCollection<dynamic> col, Id id, ScanJob object) {
  object.id = id;
}

extension ScanJobQueryWhereSort on QueryBuilder<ScanJob, ScanJob, QWhere> {
  QueryBuilder<ScanJob, ScanJob, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ScanJobQueryWhere on QueryBuilder<ScanJob, ScanJob, QWhereClause> {
  QueryBuilder<ScanJob, ScanJob, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IdWhereClause.lessThan(upper: id, includeUpper: false))
            .addWhereClause(IdWhereClause.greaterThan(lower: id, includeLower: false));
      } else {
        return query
            .addWhereClause(IdWhereClause.greaterThan(lower: id, includeLower: false))
            .addWhereClause(IdWhereClause.lessThan(upper: id, includeUpper: false));
      }
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.greaterThan(lower: id, includeLower: include));
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.lessThan(upper: id, includeUpper: include));
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(lower: lowerId, includeLower: includeLower, upper: upperId, includeUpper: includeUpper),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterWhereClause> statusEqualTo(ScanStatus status) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(indexName: r'status', value: [status]));
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterWhereClause> statusNotEqualTo(ScanStatus status) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(indexName: r'status', lower: [], upper: [status], includeUpper: false),
            )
            .addWhereClause(
              IndexWhereClause.between(indexName: r'status', lower: [status], includeLower: false, upper: []),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(indexName: r'status', lower: [status], includeLower: false, upper: []),
            )
            .addWhereClause(
              IndexWhereClause.between(indexName: r'status', lower: [], upper: [status], includeUpper: false),
            );
      }
    });
  }
}

extension ScanJobQueryFilter on QueryBuilder<ScanJob, ScanJob, QFilterCondition> {
  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> aiCallLogIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(property: r'aiCallLogId'));
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> aiCallLogIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(property: r'aiCallLogId'));
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> aiCallLogIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'aiCallLogId', value: value));
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> aiCallLogIdGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(include: include, property: r'aiCallLogId', value: value),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> aiCallLogIdLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'aiCallLogId', value: value),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> aiCallLogIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'aiCallLogId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> attemptsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'attempts', value: value));
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> attemptsGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(include: include, property: r'attempts', value: value),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> attemptsLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(include: include, property: r'attempts', value: value));
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> attemptsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'attempts',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> capturedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'capturedAt', value: value));
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> capturedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(include: include, property: r'capturedAt', value: value),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> capturedAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'capturedAt', value: value),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> capturedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'capturedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> currencyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(property: r'currency'));
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> currencyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(property: r'currency'));
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> currencyEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'currency', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> currencyGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'currency',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> currencyLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'currency', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> currencyBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'currency',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> currencyStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(property: r'currency', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> currencyEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(property: r'currency', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> currencyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(property: r'currency', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> currencyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(property: r'currency', wildcard: pattern, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> currencyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'currency', value: ''));
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> currencyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(property: r'currency', value: ''));
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> flagsElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'flags', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> flagsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(include: include, property: r'flags', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> flagsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'flags', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> flagsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'flags',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> flagsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(property: r'flags', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> flagsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(property: r'flags', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> flagsElementContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(property: r'flags', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> flagsElementMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(property: r'flags', wildcard: pattern, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> flagsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'flags', value: ''));
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> flagsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(property: r'flags', value: ''));
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> flagsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'flags', length, true, length, true);
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> flagsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'flags', 0, true, 0, true);
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> flagsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'flags', 0, false, 999999, true);
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> flagsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'flags', 0, true, length, include);
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> flagsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'flags', length, include, 999999, true);
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> flagsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'flags', lower, includeLower, upper, includeUpper);
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'id', value: value));
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(include: include, property: r'id', value: value));
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> idLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(include: include, property: r'id', value: value));
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> imagePathsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'imagePaths', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> imagePathsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'imagePaths',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> imagePathsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'imagePaths', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> imagePathsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'imagePaths',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> imagePathsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(property: r'imagePaths', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> imagePathsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(property: r'imagePaths', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> imagePathsElementContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(property: r'imagePaths', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> imagePathsElementMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(property: r'imagePaths', wildcard: pattern, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> imagePathsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'imagePaths', value: ''));
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> imagePathsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(property: r'imagePaths', value: ''));
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> imagePathsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'imagePaths', length, true, length, true);
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> imagePathsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'imagePaths', 0, true, 0, true);
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> imagePathsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'imagePaths', 0, false, 999999, true);
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> imagePathsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'imagePaths', 0, true, length, include);
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> imagePathsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'imagePaths', length, include, 999999, true);
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> imagePathsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'imagePaths', lower, includeLower, upper, includeUpper);
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> kindEqualTo(ScanKind value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'kind', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> kindGreaterThan(
    ScanKind value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(include: include, property: r'kind', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> kindLessThan(
    ScanKind value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'kind', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> kindBetween(
    ScanKind lower,
    ScanKind upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'kind',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> kindStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(property: r'kind', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> kindEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(property: r'kind', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> kindContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(property: r'kind', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> kindMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(property: r'kind', wildcard: pattern, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> kindIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'kind', value: ''));
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> kindIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(property: r'kind', value: ''));
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> lastErrorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(property: r'lastError'));
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> lastErrorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(property: r'lastError'));
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> lastErrorEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastError', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> lastErrorGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastError',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> lastErrorLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'lastError', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> lastErrorBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastError',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> lastErrorStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(property: r'lastError', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> lastErrorEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(property: r'lastError', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> lastErrorContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(property: r'lastError', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> lastErrorMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(property: r'lastError', wildcard: pattern, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> lastErrorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'lastError', value: ''));
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> lastErrorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(property: r'lastError', value: ''));
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> linesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'lines', length, true, length, true);
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> linesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'lines', 0, true, 0, true);
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> linesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'lines', 0, false, 999999, true);
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> linesLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'lines', 0, true, length, include);
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> linesLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'lines', length, include, 999999, true);
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> linesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'lines', lower, includeLower, upper, includeUpper);
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> merchantIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(property: r'merchant'));
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> merchantIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(property: r'merchant'));
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> merchantEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'merchant', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> merchantGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'merchant',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> merchantLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'merchant', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> merchantBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'merchant',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> merchantStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(property: r'merchant', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> merchantEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(property: r'merchant', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> merchantContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(property: r'merchant', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> merchantMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(property: r'merchant', wildcard: pattern, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> merchantIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'merchant', value: ''));
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> merchantIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(property: r'merchant', value: ''));
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> purchasedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(property: r'purchasedAt'));
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> purchasedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(property: r'purchasedAt'));
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> purchasedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'purchasedAt', value: value));
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> purchasedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(include: include, property: r'purchasedAt', value: value),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> purchasedAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'purchasedAt', value: value),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> purchasedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'purchasedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> receiptTotalMinorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(property: r'receiptTotalMinor'));
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> receiptTotalMinorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(property: r'receiptTotalMinor'));
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> receiptTotalMinorEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'receiptTotalMinor', value: value));
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> receiptTotalMinorGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(include: include, property: r'receiptTotalMinor', value: value),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> receiptTotalMinorLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'receiptTotalMinor', value: value),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> receiptTotalMinorBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'receiptTotalMinor',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> statusEqualTo(ScanStatus value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'status', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> statusGreaterThan(
    ScanStatus value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(include: include, property: r'status', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> statusLessThan(
    ScanStatus value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'status', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> statusBetween(
    ScanStatus lower,
    ScanStatus upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'status',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> statusStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(property: r'status', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> statusEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(property: r'status', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(property: r'status', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> statusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(property: r'status', wildcard: pattern, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'status', value: ''));
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(property: r'status', value: ''));
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> transactionIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(property: r'transactionId'));
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> transactionIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(property: r'transactionId'));
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> transactionIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'transactionId', value: value));
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> transactionIdGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(include: include, property: r'transactionId', value: value),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> transactionIdLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'transactionId', value: value),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> transactionIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'transactionId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> userHintIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(property: r'userHint'));
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> userHintIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(property: r'userHint'));
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> userHintEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'userHint', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> userHintGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'userHint',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> userHintLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'userHint', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> userHintBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'userHint',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> userHintStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(property: r'userHint', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> userHintEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(property: r'userHint', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> userHintContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(property: r'userHint', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> userHintMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(property: r'userHint', wildcard: pattern, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> userHintIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'userHint', value: ''));
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> userHintIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(property: r'userHint', value: ''));
    });
  }
}

extension ScanJobQueryObject on QueryBuilder<ScanJob, ScanJob, QFilterCondition> {
  QueryBuilder<ScanJob, ScanJob, QAfterFilterCondition> linesElement(FilterQuery<DraftLine> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'lines');
    });
  }
}

extension ScanJobQueryLinks on QueryBuilder<ScanJob, ScanJob, QFilterCondition> {}

extension ScanJobQuerySortBy on QueryBuilder<ScanJob, ScanJob, QSortBy> {
  QueryBuilder<ScanJob, ScanJob, QAfterSortBy> sortByAiCallLogId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiCallLogId', Sort.asc);
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterSortBy> sortByAiCallLogIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiCallLogId', Sort.desc);
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterSortBy> sortByAttempts() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attempts', Sort.asc);
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterSortBy> sortByAttemptsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attempts', Sort.desc);
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterSortBy> sortByCapturedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'capturedAt', Sort.asc);
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterSortBy> sortByCapturedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'capturedAt', Sort.desc);
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterSortBy> sortByCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.asc);
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterSortBy> sortByCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.desc);
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterSortBy> sortByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.asc);
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterSortBy> sortByKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.desc);
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterSortBy> sortByLastError() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastError', Sort.asc);
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterSortBy> sortByLastErrorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastError', Sort.desc);
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterSortBy> sortByMerchant() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'merchant', Sort.asc);
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterSortBy> sortByMerchantDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'merchant', Sort.desc);
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterSortBy> sortByPurchasedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purchasedAt', Sort.asc);
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterSortBy> sortByPurchasedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purchasedAt', Sort.desc);
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterSortBy> sortByReceiptTotalMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receiptTotalMinor', Sort.asc);
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterSortBy> sortByReceiptTotalMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receiptTotalMinor', Sort.desc);
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterSortBy> sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterSortBy> sortByTransactionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transactionId', Sort.asc);
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterSortBy> sortByTransactionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transactionId', Sort.desc);
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterSortBy> sortByUserHint() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userHint', Sort.asc);
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterSortBy> sortByUserHintDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userHint', Sort.desc);
    });
  }
}

extension ScanJobQuerySortThenBy on QueryBuilder<ScanJob, ScanJob, QSortThenBy> {
  QueryBuilder<ScanJob, ScanJob, QAfterSortBy> thenByAiCallLogId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiCallLogId', Sort.asc);
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterSortBy> thenByAiCallLogIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiCallLogId', Sort.desc);
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterSortBy> thenByAttempts() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attempts', Sort.asc);
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterSortBy> thenByAttemptsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attempts', Sort.desc);
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterSortBy> thenByCapturedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'capturedAt', Sort.asc);
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterSortBy> thenByCapturedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'capturedAt', Sort.desc);
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterSortBy> thenByCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.asc);
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterSortBy> thenByCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.desc);
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterSortBy> thenByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.asc);
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterSortBy> thenByKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.desc);
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterSortBy> thenByLastError() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastError', Sort.asc);
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterSortBy> thenByLastErrorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastError', Sort.desc);
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterSortBy> thenByMerchant() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'merchant', Sort.asc);
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterSortBy> thenByMerchantDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'merchant', Sort.desc);
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterSortBy> thenByPurchasedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purchasedAt', Sort.asc);
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterSortBy> thenByPurchasedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purchasedAt', Sort.desc);
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterSortBy> thenByReceiptTotalMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receiptTotalMinor', Sort.asc);
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterSortBy> thenByReceiptTotalMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receiptTotalMinor', Sort.desc);
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterSortBy> thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterSortBy> thenByTransactionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transactionId', Sort.asc);
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterSortBy> thenByTransactionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transactionId', Sort.desc);
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterSortBy> thenByUserHint() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userHint', Sort.asc);
    });
  }

  QueryBuilder<ScanJob, ScanJob, QAfterSortBy> thenByUserHintDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userHint', Sort.desc);
    });
  }
}

extension ScanJobQueryWhereDistinct on QueryBuilder<ScanJob, ScanJob, QDistinct> {
  QueryBuilder<ScanJob, ScanJob, QDistinct> distinctByAiCallLogId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'aiCallLogId');
    });
  }

  QueryBuilder<ScanJob, ScanJob, QDistinct> distinctByAttempts() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'attempts');
    });
  }

  QueryBuilder<ScanJob, ScanJob, QDistinct> distinctByCapturedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'capturedAt');
    });
  }

  QueryBuilder<ScanJob, ScanJob, QDistinct> distinctByCurrency({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currency', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ScanJob, ScanJob, QDistinct> distinctByFlags() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'flags');
    });
  }

  QueryBuilder<ScanJob, ScanJob, QDistinct> distinctByImagePaths() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'imagePaths');
    });
  }

  QueryBuilder<ScanJob, ScanJob, QDistinct> distinctByKind({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'kind', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ScanJob, ScanJob, QDistinct> distinctByLastError({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastError', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ScanJob, ScanJob, QDistinct> distinctByMerchant({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'merchant', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ScanJob, ScanJob, QDistinct> distinctByPurchasedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'purchasedAt');
    });
  }

  QueryBuilder<ScanJob, ScanJob, QDistinct> distinctByReceiptTotalMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'receiptTotalMinor');
    });
  }

  QueryBuilder<ScanJob, ScanJob, QDistinct> distinctByStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ScanJob, ScanJob, QDistinct> distinctByTransactionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'transactionId');
    });
  }

  QueryBuilder<ScanJob, ScanJob, QDistinct> distinctByUserHint({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userHint', caseSensitive: caseSensitive);
    });
  }
}

extension ScanJobQueryProperty on QueryBuilder<ScanJob, ScanJob, QQueryProperty> {
  QueryBuilder<ScanJob, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ScanJob, int?, QQueryOperations> aiCallLogIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'aiCallLogId');
    });
  }

  QueryBuilder<ScanJob, int, QQueryOperations> attemptsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'attempts');
    });
  }

  QueryBuilder<ScanJob, DateTime, QQueryOperations> capturedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'capturedAt');
    });
  }

  QueryBuilder<ScanJob, String?, QQueryOperations> currencyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currency');
    });
  }

  QueryBuilder<ScanJob, List<String>, QQueryOperations> flagsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'flags');
    });
  }

  QueryBuilder<ScanJob, List<String>, QQueryOperations> imagePathsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'imagePaths');
    });
  }

  QueryBuilder<ScanJob, ScanKind, QQueryOperations> kindProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'kind');
    });
  }

  QueryBuilder<ScanJob, String?, QQueryOperations> lastErrorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastError');
    });
  }

  QueryBuilder<ScanJob, List<DraftLine>, QQueryOperations> linesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lines');
    });
  }

  QueryBuilder<ScanJob, String?, QQueryOperations> merchantProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'merchant');
    });
  }

  QueryBuilder<ScanJob, DateTime?, QQueryOperations> purchasedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'purchasedAt');
    });
  }

  QueryBuilder<ScanJob, int?, QQueryOperations> receiptTotalMinorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'receiptTotalMinor');
    });
  }

  QueryBuilder<ScanJob, ScanStatus, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<ScanJob, int?, QQueryOperations> transactionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'transactionId');
    });
  }

  QueryBuilder<ScanJob, String?, QQueryOperations> userHintProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userHint');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const DraftLineSchema = Schema(
  name: r'DraftLine',
  id: -3664488723718158314,
  properties: {
    r'category': PropertySchema(
      id: 0,
      name: r'category',
      type: IsarType.string,
      enumMap: _DraftLinecategoryEnumValueMap,
    ),
    r'confidence': PropertySchema(
      id: 1,
      name: r'confidence',
      type: IsarType.string,
      enumMap: _DraftLineconfidenceEnumValueMap,
    ),
    r'include': PropertySchema(id: 2, name: r'include', type: IsarType.bool),
    r'ingredientKey': PropertySchema(id: 3, name: r'ingredientKey', type: IsarType.string),
    r'isNewIngredient': PropertySchema(id: 4, name: r'isNewIngredient', type: IsarType.bool),
    r'lineType': PropertySchema(
      id: 5,
      name: r'lineType',
      type: IsarType.string,
      enumMap: _DraftLinelineTypeEnumValueMap,
    ),
    r'matchedIngredientId': PropertySchema(id: 6, name: r'matchedIngredientId', type: IsarType.long),
    r'mergeCandidateId': PropertySchema(id: 7, name: r'mergeCandidateId', type: IsarType.long),
    r'name': PropertySchema(id: 8, name: r'name', type: IsarType.string),
    r'profile': PropertySchema(id: 9, name: r'profile', type: IsarType.object, target: r'NewIngredientProfile'),
    r'qty': PropertySchema(id: 10, name: r'qty', type: IsarType.double),
    r'qtySource': PropertySchema(
      id: 11,
      name: r'qtySource',
      type: IsarType.string,
      enumMap: _DraftLineqtySourceEnumValueMap,
    ),
    r'rawText': PropertySchema(id: 12, name: r'rawText', type: IsarType.string),
    r'totalMinor': PropertySchema(id: 13, name: r'totalMinor', type: IsarType.long),
    r'unit': PropertySchema(id: 14, name: r'unit', type: IsarType.string, enumMap: _DraftLineunitEnumValueMap),
  },

  estimateSize: _draftLineEstimateSize,
  serialize: _draftLineSerialize,
  deserialize: _draftLineDeserialize,
  deserializeProp: _draftLineDeserializeProp,
);

int _draftLineEstimateSize(DraftLine object, List<int> offsets, Map<Type, List<int>> allOffsets) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.category.name.length * 3;
  bytesCount += 3 + object.confidence.name.length * 3;
  {
    final value = object.ingredientKey;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.lineType.name.length * 3;
  bytesCount += 3 + object.name.length * 3;
  {
    final value = object.profile;
    if (value != null) {
      bytesCount += 3 + NewIngredientProfileSchema.estimateSize(value, allOffsets[NewIngredientProfile]!, allOffsets);
    }
  }
  bytesCount += 3 + object.qtySource.name.length * 3;
  bytesCount += 3 + object.rawText.length * 3;
  bytesCount += 3 + object.unit.name.length * 3;
  return bytesCount;
}

void _draftLineSerialize(DraftLine object, IsarWriter writer, List<int> offsets, Map<Type, List<int>> allOffsets) {
  writer.writeString(offsets[0], object.category.name);
  writer.writeString(offsets[1], object.confidence.name);
  writer.writeBool(offsets[2], object.include);
  writer.writeString(offsets[3], object.ingredientKey);
  writer.writeBool(offsets[4], object.isNewIngredient);
  writer.writeString(offsets[5], object.lineType.name);
  writer.writeLong(offsets[6], object.matchedIngredientId);
  writer.writeLong(offsets[7], object.mergeCandidateId);
  writer.writeString(offsets[8], object.name);
  writer.writeObject<NewIngredientProfile>(
    offsets[9],
    allOffsets,
    NewIngredientProfileSchema.serialize,
    object.profile,
  );
  writer.writeDouble(offsets[10], object.qty);
  writer.writeString(offsets[11], object.qtySource.name);
  writer.writeString(offsets[12], object.rawText);
  writer.writeLong(offsets[13], object.totalMinor);
  writer.writeString(offsets[14], object.unit.name);
}

DraftLine _draftLineDeserialize(Id id, IsarReader reader, List<int> offsets, Map<Type, List<int>> allOffsets) {
  final object = DraftLine();
  object.category = _DraftLinecategoryValueEnumMap[reader.readStringOrNull(offsets[0])] ?? SpendCategory.groceries;
  object.confidence = _DraftLineconfidenceValueEnumMap[reader.readStringOrNull(offsets[1])] ?? Confidence.high;
  object.include = reader.readBool(offsets[2]);
  object.ingredientKey = reader.readStringOrNull(offsets[3]);
  object.isNewIngredient = reader.readBool(offsets[4]);
  object.lineType = _DraftLinelineTypeValueEnumMap[reader.readStringOrNull(offsets[5])] ?? LineType.product;
  object.matchedIngredientId = reader.readLongOrNull(offsets[6]);
  object.mergeCandidateId = reader.readLongOrNull(offsets[7]);
  object.name = reader.readString(offsets[8]);
  object.profile = reader.readObjectOrNull<NewIngredientProfile>(
    offsets[9],
    NewIngredientProfileSchema.deserialize,
    allOffsets,
  );
  object.qty = reader.readDoubleOrNull(offsets[10]);
  object.qtySource = _DraftLineqtySourceValueEnumMap[reader.readStringOrNull(offsets[11])] ?? QtySource.printed;
  object.rawText = reader.readString(offsets[12]);
  object.totalMinor = reader.readLong(offsets[13]);
  object.unit = _DraftLineunitValueEnumMap[reader.readStringOrNull(offsets[14])] ?? BaseUnit.g;
  return object;
}

P _draftLineDeserializeProp<P>(IsarReader reader, int propertyId, int offset, Map<Type, List<int>> allOffsets) {
  switch (propertyId) {
    case 0:
      return (_DraftLinecategoryValueEnumMap[reader.readStringOrNull(offset)] ?? SpendCategory.groceries) as P;
    case 1:
      return (_DraftLineconfidenceValueEnumMap[reader.readStringOrNull(offset)] ?? Confidence.high) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (_DraftLinelineTypeValueEnumMap[reader.readStringOrNull(offset)] ?? LineType.product) as P;
    case 6:
      return (reader.readLongOrNull(offset)) as P;
    case 7:
      return (reader.readLongOrNull(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readObjectOrNull<NewIngredientProfile>(offset, NewIngredientProfileSchema.deserialize, allOffsets))
          as P;
    case 10:
      return (reader.readDoubleOrNull(offset)) as P;
    case 11:
      return (_DraftLineqtySourceValueEnumMap[reader.readStringOrNull(offset)] ?? QtySource.printed) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readLong(offset)) as P;
    case 14:
      return (_DraftLineunitValueEnumMap[reader.readStringOrNull(offset)] ?? BaseUnit.g) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _DraftLinecategoryEnumValueMap = {
  r'groceries': r'groceries',
  r'household': r'household',
  r'clothes': r'clothes',
  r'eatingOut': r'eatingOut',
  r'entertainment': r'entertainment',
  r'other': r'other',
};
const _DraftLinecategoryValueEnumMap = {
  r'groceries': SpendCategory.groceries,
  r'household': SpendCategory.household,
  r'clothes': SpendCategory.clothes,
  r'eatingOut': SpendCategory.eatingOut,
  r'entertainment': SpendCategory.entertainment,
  r'other': SpendCategory.other,
};
const _DraftLineconfidenceEnumValueMap = {r'high': r'high', r'medium': r'medium', r'low': r'low'};
const _DraftLineconfidenceValueEnumMap = {
  r'high': Confidence.high,
  r'medium': Confidence.medium,
  r'low': Confidence.low,
};
const _DraftLinelineTypeEnumValueMap = {
  r'product': r'product',
  r'adjustment': r'adjustment',
  r'deposit': r'deposit',
  r'fee': r'fee',
};
const _DraftLinelineTypeValueEnumMap = {
  r'product': LineType.product,
  r'adjustment': LineType.adjustment,
  r'deposit': LineType.deposit,
  r'fee': LineType.fee,
};
const _DraftLineqtySourceEnumValueMap = {
  r'printed': r'printed',
  r'inferred': r'inferred',
  r'estimated': r'estimated',
  r'unknown': r'unknown',
};
const _DraftLineqtySourceValueEnumMap = {
  r'printed': QtySource.printed,
  r'inferred': QtySource.inferred,
  r'estimated': QtySource.estimated,
  r'unknown': QtySource.unknown,
};
const _DraftLineunitEnumValueMap = {r'g': r'g', r'ml': r'ml', r'pc': r'pc'};
const _DraftLineunitValueEnumMap = {r'g': BaseUnit.g, r'ml': BaseUnit.ml, r'pc': BaseUnit.pc};

extension DraftLineQueryFilter on QueryBuilder<DraftLine, DraftLine, QFilterCondition> {
  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> categoryEqualTo(
    SpendCategory value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'category', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> categoryGreaterThan(
    SpendCategory value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'category',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> categoryLessThan(
    SpendCategory value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'category', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> categoryBetween(
    SpendCategory lower,
    SpendCategory upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'category',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> categoryStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(property: r'category', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> categoryEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(property: r'category', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> categoryContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(property: r'category', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> categoryMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(property: r'category', wildcard: pattern, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> categoryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'category', value: ''));
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> categoryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(property: r'category', value: ''));
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> confidenceEqualTo(
    Confidence value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'confidence', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> confidenceGreaterThan(
    Confidence value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'confidence',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> confidenceLessThan(
    Confidence value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'confidence', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> confidenceBetween(
    Confidence lower,
    Confidence upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'confidence',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> confidenceStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(property: r'confidence', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> confidenceEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(property: r'confidence', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> confidenceContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(property: r'confidence', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> confidenceMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(property: r'confidence', wildcard: pattern, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> confidenceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'confidence', value: ''));
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> confidenceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(property: r'confidence', value: ''));
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> includeEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'include', value: value));
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> ingredientKeyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(property: r'ingredientKey'));
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> ingredientKeyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(property: r'ingredientKey'));
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> ingredientKeyEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'ingredientKey', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> ingredientKeyGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'ingredientKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> ingredientKeyLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'ingredientKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> ingredientKeyBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'ingredientKey',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> ingredientKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(property: r'ingredientKey', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> ingredientKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(property: r'ingredientKey', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> ingredientKeyContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(property: r'ingredientKey', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> ingredientKeyMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(property: r'ingredientKey', wildcard: pattern, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> ingredientKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'ingredientKey', value: ''));
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> ingredientKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(property: r'ingredientKey', value: ''));
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> isNewIngredientEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'isNewIngredient', value: value));
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> lineTypeEqualTo(
    LineType value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lineType', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> lineTypeGreaterThan(
    LineType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lineType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> lineTypeLessThan(
    LineType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'lineType', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> lineTypeBetween(
    LineType lower,
    LineType upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lineType',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> lineTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(property: r'lineType', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> lineTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(property: r'lineType', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> lineTypeContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(property: r'lineType', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> lineTypeMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(property: r'lineType', wildcard: pattern, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> lineTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'lineType', value: ''));
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> lineTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(property: r'lineType', value: ''));
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> matchedIngredientIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(property: r'matchedIngredientId'));
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> matchedIngredientIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(property: r'matchedIngredientId'));
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> matchedIngredientIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'matchedIngredientId', value: value));
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> matchedIngredientIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(include: include, property: r'matchedIngredientId', value: value),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> matchedIngredientIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'matchedIngredientId', value: value),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> matchedIngredientIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'matchedIngredientId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> mergeCandidateIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(property: r'mergeCandidateId'));
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> mergeCandidateIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(property: r'mergeCandidateId'));
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> mergeCandidateIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'mergeCandidateId', value: value));
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> mergeCandidateIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(include: include, property: r'mergeCandidateId', value: value),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> mergeCandidateIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'mergeCandidateId', value: value),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> mergeCandidateIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'mergeCandidateId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> nameEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'name', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(include: include, property: r'name', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'name', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'name',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> nameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(property: r'name', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> nameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(property: r'name', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(property: r'name', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(property: r'name', wildcard: pattern, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'name', value: ''));
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(property: r'name', value: ''));
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> profileIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(property: r'profile'));
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> profileIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(property: r'profile'));
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> qtyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(property: r'qty'));
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> qtyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(property: r'qty'));
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> qtyEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'qty', value: value, epsilon: epsilon));
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> qtyGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(include: include, property: r'qty', value: value, epsilon: epsilon),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> qtyLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'qty', value: value, epsilon: epsilon),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> qtyBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'qty',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> qtySourceEqualTo(
    QtySource value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'qtySource', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> qtySourceGreaterThan(
    QtySource value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'qtySource',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> qtySourceLessThan(
    QtySource value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'qtySource', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> qtySourceBetween(
    QtySource lower,
    QtySource upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'qtySource',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> qtySourceStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(property: r'qtySource', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> qtySourceEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(property: r'qtySource', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> qtySourceContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(property: r'qtySource', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> qtySourceMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(property: r'qtySource', wildcard: pattern, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> qtySourceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'qtySource', value: ''));
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> qtySourceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(property: r'qtySource', value: ''));
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> rawTextEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'rawText', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> rawTextGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(include: include, property: r'rawText', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> rawTextLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'rawText', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> rawTextBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'rawText',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> rawTextStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(property: r'rawText', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> rawTextEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(property: r'rawText', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> rawTextContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(property: r'rawText', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> rawTextMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(property: r'rawText', wildcard: pattern, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> rawTextIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'rawText', value: ''));
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> rawTextIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(property: r'rawText', value: ''));
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> totalMinorEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'totalMinor', value: value));
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> totalMinorGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(include: include, property: r'totalMinor', value: value),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> totalMinorLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'totalMinor', value: value),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> totalMinorBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'totalMinor',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> unitEqualTo(BaseUnit value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'unit', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> unitGreaterThan(
    BaseUnit value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(include: include, property: r'unit', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> unitLessThan(
    BaseUnit value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'unit', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> unitBetween(
    BaseUnit lower,
    BaseUnit upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'unit',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> unitStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(property: r'unit', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> unitEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(property: r'unit', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> unitContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(property: r'unit', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> unitMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(property: r'unit', wildcard: pattern, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> unitIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'unit', value: ''));
    });
  }

  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> unitIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(property: r'unit', value: ''));
    });
  }
}

extension DraftLineQueryObject on QueryBuilder<DraftLine, DraftLine, QFilterCondition> {
  QueryBuilder<DraftLine, DraftLine, QAfterFilterCondition> profile(FilterQuery<NewIngredientProfile> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'profile');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const NewIngredientProfileSchema = Schema(
  name: r'NewIngredientProfile',
  id: 1875700393409645863,
  properties: {
    r'category': PropertySchema(
      id: 0,
      name: r'category',
      type: IsarType.string,
      enumMap: _NewIngredientProfilecategoryEnumValueMap,
    ),
    r'densityGPerMl': PropertySchema(id: 1, name: r'densityGPerMl', type: IsarType.double),
    r'gramsPerPiece': PropertySchema(id: 2, name: r'gramsPerPiece', type: IsarType.double),
    r'name': PropertySchema(id: 3, name: r'name', type: IsarType.string),
    r'per100': PropertySchema(id: 4, name: r'per100', type: IsarType.object, target: r'Nutrition'),
    r'shelfLifeDays': PropertySchema(id: 5, name: r'shelfLifeDays', type: IsarType.long),
    r'suggestStaple': PropertySchema(id: 6, name: r'suggestStaple', type: IsarType.bool),
    r'unit': PropertySchema(
      id: 7,
      name: r'unit',
      type: IsarType.string,
      enumMap: _NewIngredientProfileunitEnumValueMap,
    ),
  },

  estimateSize: _newIngredientProfileEstimateSize,
  serialize: _newIngredientProfileSerialize,
  deserialize: _newIngredientProfileDeserialize,
  deserializeProp: _newIngredientProfileDeserializeProp,
);

int _newIngredientProfileEstimateSize(NewIngredientProfile object, List<int> offsets, Map<Type, List<int>> allOffsets) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.category.name.length * 3;
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + NutritionSchema.estimateSize(object.per100, allOffsets[Nutrition]!, allOffsets);
  bytesCount += 3 + object.unit.name.length * 3;
  return bytesCount;
}

void _newIngredientProfileSerialize(
  NewIngredientProfile object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.category.name);
  writer.writeDouble(offsets[1], object.densityGPerMl);
  writer.writeDouble(offsets[2], object.gramsPerPiece);
  writer.writeString(offsets[3], object.name);
  writer.writeObject<Nutrition>(offsets[4], allOffsets, NutritionSchema.serialize, object.per100);
  writer.writeLong(offsets[5], object.shelfLifeDays);
  writer.writeBool(offsets[6], object.suggestStaple);
  writer.writeString(offsets[7], object.unit.name);
}

NewIngredientProfile _newIngredientProfileDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = NewIngredientProfile();
  object.category =
      _NewIngredientProfilecategoryValueEnumMap[reader.readStringOrNull(offsets[0])] ?? IngredientCategory.produce;
  object.densityGPerMl = reader.readDoubleOrNull(offsets[1]);
  object.gramsPerPiece = reader.readDoubleOrNull(offsets[2]);
  object.name = reader.readString(offsets[3]);
  object.per100 =
      reader.readObjectOrNull<Nutrition>(offsets[4], NutritionSchema.deserialize, allOffsets) ?? Nutrition();
  object.shelfLifeDays = reader.readLong(offsets[5]);
  object.suggestStaple = reader.readBool(offsets[6]);
  object.unit = _NewIngredientProfileunitValueEnumMap[reader.readStringOrNull(offsets[7])] ?? BaseUnit.g;
  return object;
}

P _newIngredientProfileDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (_NewIngredientProfilecategoryValueEnumMap[reader.readStringOrNull(offset)] ?? IngredientCategory.produce)
          as P;
    case 1:
      return (reader.readDoubleOrNull(offset)) as P;
    case 2:
      return (reader.readDoubleOrNull(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readObjectOrNull<Nutrition>(offset, NutritionSchema.deserialize, allOffsets) ?? Nutrition()) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (_NewIngredientProfileunitValueEnumMap[reader.readStringOrNull(offset)] ?? BaseUnit.g) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _NewIngredientProfilecategoryEnumValueMap = {
  r'produce': r'produce',
  r'meatFish': r'meatFish',
  r'dairyEggs': r'dairyEggs',
  r'grainsPasta': r'grainsPasta',
  r'legumesNuts': r'legumesNuts',
  r'cannedJarred': r'cannedJarred',
  r'bakery': r'bakery',
  r'frozen': r'frozen',
  r'spicesCondiments': r'spicesCondiments',
  r'oilsFats': r'oilsFats',
  r'beverages': r'beverages',
  r'snacksSweets': r'snacksSweets',
  r'other': r'other',
};
const _NewIngredientProfilecategoryValueEnumMap = {
  r'produce': IngredientCategory.produce,
  r'meatFish': IngredientCategory.meatFish,
  r'dairyEggs': IngredientCategory.dairyEggs,
  r'grainsPasta': IngredientCategory.grainsPasta,
  r'legumesNuts': IngredientCategory.legumesNuts,
  r'cannedJarred': IngredientCategory.cannedJarred,
  r'bakery': IngredientCategory.bakery,
  r'frozen': IngredientCategory.frozen,
  r'spicesCondiments': IngredientCategory.spicesCondiments,
  r'oilsFats': IngredientCategory.oilsFats,
  r'beverages': IngredientCategory.beverages,
  r'snacksSweets': IngredientCategory.snacksSweets,
  r'other': IngredientCategory.other,
};
const _NewIngredientProfileunitEnumValueMap = {r'g': r'g', r'ml': r'ml', r'pc': r'pc'};
const _NewIngredientProfileunitValueEnumMap = {r'g': BaseUnit.g, r'ml': BaseUnit.ml, r'pc': BaseUnit.pc};

extension NewIngredientProfileQueryFilter
    on QueryBuilder<NewIngredientProfile, NewIngredientProfile, QFilterCondition> {
  QueryBuilder<NewIngredientProfile, NewIngredientProfile, QAfterFilterCondition> categoryEqualTo(
    IngredientCategory value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'category', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<NewIngredientProfile, NewIngredientProfile, QAfterFilterCondition> categoryGreaterThan(
    IngredientCategory value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'category',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NewIngredientProfile, NewIngredientProfile, QAfterFilterCondition> categoryLessThan(
    IngredientCategory value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'category', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<NewIngredientProfile, NewIngredientProfile, QAfterFilterCondition> categoryBetween(
    IngredientCategory lower,
    IngredientCategory upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'category',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NewIngredientProfile, NewIngredientProfile, QAfterFilterCondition> categoryStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(property: r'category', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<NewIngredientProfile, NewIngredientProfile, QAfterFilterCondition> categoryEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(property: r'category', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<NewIngredientProfile, NewIngredientProfile, QAfterFilterCondition> categoryContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(property: r'category', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<NewIngredientProfile, NewIngredientProfile, QAfterFilterCondition> categoryMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(property: r'category', wildcard: pattern, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<NewIngredientProfile, NewIngredientProfile, QAfterFilterCondition> categoryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'category', value: ''));
    });
  }

  QueryBuilder<NewIngredientProfile, NewIngredientProfile, QAfterFilterCondition> categoryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(property: r'category', value: ''));
    });
  }

  QueryBuilder<NewIngredientProfile, NewIngredientProfile, QAfterFilterCondition> densityGPerMlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(property: r'densityGPerMl'));
    });
  }

  QueryBuilder<NewIngredientProfile, NewIngredientProfile, QAfterFilterCondition> densityGPerMlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(property: r'densityGPerMl'));
    });
  }

  QueryBuilder<NewIngredientProfile, NewIngredientProfile, QAfterFilterCondition> densityGPerMlEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'densityGPerMl', value: value, epsilon: epsilon),
      );
    });
  }

  QueryBuilder<NewIngredientProfile, NewIngredientProfile, QAfterFilterCondition> densityGPerMlGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(include: include, property: r'densityGPerMl', value: value, epsilon: epsilon),
      );
    });
  }

  QueryBuilder<NewIngredientProfile, NewIngredientProfile, QAfterFilterCondition> densityGPerMlLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'densityGPerMl', value: value, epsilon: epsilon),
      );
    });
  }

  QueryBuilder<NewIngredientProfile, NewIngredientProfile, QAfterFilterCondition> densityGPerMlBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'densityGPerMl',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<NewIngredientProfile, NewIngredientProfile, QAfterFilterCondition> gramsPerPieceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(property: r'gramsPerPiece'));
    });
  }

  QueryBuilder<NewIngredientProfile, NewIngredientProfile, QAfterFilterCondition> gramsPerPieceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(property: r'gramsPerPiece'));
    });
  }

  QueryBuilder<NewIngredientProfile, NewIngredientProfile, QAfterFilterCondition> gramsPerPieceEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'gramsPerPiece', value: value, epsilon: epsilon),
      );
    });
  }

  QueryBuilder<NewIngredientProfile, NewIngredientProfile, QAfterFilterCondition> gramsPerPieceGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(include: include, property: r'gramsPerPiece', value: value, epsilon: epsilon),
      );
    });
  }

  QueryBuilder<NewIngredientProfile, NewIngredientProfile, QAfterFilterCondition> gramsPerPieceLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'gramsPerPiece', value: value, epsilon: epsilon),
      );
    });
  }

  QueryBuilder<NewIngredientProfile, NewIngredientProfile, QAfterFilterCondition> gramsPerPieceBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'gramsPerPiece',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<NewIngredientProfile, NewIngredientProfile, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'name', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<NewIngredientProfile, NewIngredientProfile, QAfterFilterCondition> nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(include: include, property: r'name', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<NewIngredientProfile, NewIngredientProfile, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'name', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<NewIngredientProfile, NewIngredientProfile, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'name',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NewIngredientProfile, NewIngredientProfile, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(property: r'name', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<NewIngredientProfile, NewIngredientProfile, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(property: r'name', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<NewIngredientProfile, NewIngredientProfile, QAfterFilterCondition> nameContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(property: r'name', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<NewIngredientProfile, NewIngredientProfile, QAfterFilterCondition> nameMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(property: r'name', wildcard: pattern, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<NewIngredientProfile, NewIngredientProfile, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'name', value: ''));
    });
  }

  QueryBuilder<NewIngredientProfile, NewIngredientProfile, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(property: r'name', value: ''));
    });
  }

  QueryBuilder<NewIngredientProfile, NewIngredientProfile, QAfterFilterCondition> shelfLifeDaysEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'shelfLifeDays', value: value));
    });
  }

  QueryBuilder<NewIngredientProfile, NewIngredientProfile, QAfterFilterCondition> shelfLifeDaysGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(include: include, property: r'shelfLifeDays', value: value),
      );
    });
  }

  QueryBuilder<NewIngredientProfile, NewIngredientProfile, QAfterFilterCondition> shelfLifeDaysLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'shelfLifeDays', value: value),
      );
    });
  }

  QueryBuilder<NewIngredientProfile, NewIngredientProfile, QAfterFilterCondition> shelfLifeDaysBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'shelfLifeDays',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<NewIngredientProfile, NewIngredientProfile, QAfterFilterCondition> suggestStapleEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'suggestStaple', value: value));
    });
  }

  QueryBuilder<NewIngredientProfile, NewIngredientProfile, QAfterFilterCondition> unitEqualTo(
    BaseUnit value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'unit', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<NewIngredientProfile, NewIngredientProfile, QAfterFilterCondition> unitGreaterThan(
    BaseUnit value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(include: include, property: r'unit', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<NewIngredientProfile, NewIngredientProfile, QAfterFilterCondition> unitLessThan(
    BaseUnit value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'unit', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<NewIngredientProfile, NewIngredientProfile, QAfterFilterCondition> unitBetween(
    BaseUnit lower,
    BaseUnit upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'unit',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NewIngredientProfile, NewIngredientProfile, QAfterFilterCondition> unitStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(property: r'unit', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<NewIngredientProfile, NewIngredientProfile, QAfterFilterCondition> unitEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(property: r'unit', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<NewIngredientProfile, NewIngredientProfile, QAfterFilterCondition> unitContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(property: r'unit', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<NewIngredientProfile, NewIngredientProfile, QAfterFilterCondition> unitMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(property: r'unit', wildcard: pattern, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<NewIngredientProfile, NewIngredientProfile, QAfterFilterCondition> unitIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'unit', value: ''));
    });
  }

  QueryBuilder<NewIngredientProfile, NewIngredientProfile, QAfterFilterCondition> unitIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(property: r'unit', value: ''));
    });
  }
}

extension NewIngredientProfileQueryObject
    on QueryBuilder<NewIngredientProfile, NewIngredientProfile, QFilterCondition> {
  QueryBuilder<NewIngredientProfile, NewIngredientProfile, QAfterFilterCondition> per100(FilterQuery<Nutrition> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'per100');
    });
  }
}
