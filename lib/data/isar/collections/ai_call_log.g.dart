// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_call_log.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAiCallLogCollection on Isar {
  IsarCollection<AiCallLog> get aiCallLogs => this.collection();
}

const AiCallLogSchema = CollectionSchema(
  name: r'AiCallLog',
  id: -2387153078644396525,
  properties: {
    r'at': PropertySchema(id: 0, name: r'at', type: IsarType.dateTime),
    r'error': PropertySchema(id: 1, name: r'error', type: IsarType.string),
    r'inputTokens': PropertySchema(
      id: 2,
      name: r'inputTokens',
      type: IsarType.long,
    ),
    r'latencyMs': PropertySchema(
      id: 3,
      name: r'latencyMs',
      type: IsarType.long,
    ),
    r'model': PropertySchema(id: 4, name: r'model', type: IsarType.string),
    r'outputTokens': PropertySchema(
      id: 5,
      name: r'outputTokens',
      type: IsarType.long,
    ),
    r'parsedOk': PropertySchema(id: 6, name: r'parsedOk', type: IsarType.bool),
    r'promptVersion': PropertySchema(
      id: 7,
      name: r'promptVersion',
      type: IsarType.string,
    ),
    r'rawResponse': PropertySchema(
      id: 8,
      name: r'rawResponse',
      type: IsarType.string,
    ),
    r'repaired': PropertySchema(id: 9, name: r'repaired', type: IsarType.bool),
    r'task': PropertySchema(
      id: 10,
      name: r'task',
      type: IsarType.string,
      enumMap: _AiCallLogtaskEnumValueMap,
    ),
    r'validationFlags': PropertySchema(
      id: 11,
      name: r'validationFlags',
      type: IsarType.stringList,
    ),
  },

  estimateSize: _aiCallLogEstimateSize,
  serialize: _aiCallLogSerialize,
  deserialize: _aiCallLogDeserialize,
  deserializeProp: _aiCallLogDeserializeProp,
  idName: r'id',
  indexes: {
    r'at': IndexSchema(
      id: 1454144528255648370,
      name: r'at',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'at',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _aiCallLogGetId,
  getLinks: _aiCallLogGetLinks,
  attach: _aiCallLogAttach,
  version: '3.3.2',
);

int _aiCallLogEstimateSize(
  AiCallLog object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.error;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.model.length * 3;
  bytesCount += 3 + object.promptVersion.length * 3;
  bytesCount += 3 + object.rawResponse.length * 3;
  bytesCount += 3 + object.task.name.length * 3;
  bytesCount += 3 + object.validationFlags.length * 3;
  {
    for (var i = 0; i < object.validationFlags.length; i++) {
      final value = object.validationFlags[i];
      bytesCount += value.length * 3;
    }
  }
  return bytesCount;
}

void _aiCallLogSerialize(
  AiCallLog object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.at);
  writer.writeString(offsets[1], object.error);
  writer.writeLong(offsets[2], object.inputTokens);
  writer.writeLong(offsets[3], object.latencyMs);
  writer.writeString(offsets[4], object.model);
  writer.writeLong(offsets[5], object.outputTokens);
  writer.writeBool(offsets[6], object.parsedOk);
  writer.writeString(offsets[7], object.promptVersion);
  writer.writeString(offsets[8], object.rawResponse);
  writer.writeBool(offsets[9], object.repaired);
  writer.writeString(offsets[10], object.task.name);
  writer.writeStringList(offsets[11], object.validationFlags);
}

AiCallLog _aiCallLogDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AiCallLog();
  object.at = reader.readDateTime(offsets[0]);
  object.error = reader.readStringOrNull(offsets[1]);
  object.id = id;
  object.inputTokens = reader.readLongOrNull(offsets[2]);
  object.latencyMs = reader.readLong(offsets[3]);
  object.model = reader.readString(offsets[4]);
  object.outputTokens = reader.readLongOrNull(offsets[5]);
  object.parsedOk = reader.readBool(offsets[6]);
  object.promptVersion = reader.readString(offsets[7]);
  object.rawResponse = reader.readString(offsets[8]);
  object.repaired = reader.readBool(offsets[9]);
  object.task =
      _AiCallLogtaskValueEnumMap[reader.readStringOrNull(offsets[10])] ??
      AiTask.receipt;
  object.validationFlags = reader.readStringList(offsets[11]) ?? [];
  return object;
}

P _aiCallLogDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readLongOrNull(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readLongOrNull(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readBool(offset)) as P;
    case 10:
      return (_AiCallLogtaskValueEnumMap[reader.readStringOrNull(offset)] ??
              AiTask.receipt)
          as P;
    case 11:
      return (reader.readStringList(offset) ?? []) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _AiCallLogtaskEnumValueMap = {
  r'receipt': r'receipt',
  r'dailyRecipe': r'dailyRecipe',
  r'spontaneousRecipe': r'spontaneousRecipe',
  r'nutritionEstimate': r'nutritionEstimate',
  r'nutritionLabel': r'nutritionLabel',
  r'priceLookup': r'priceLookup',
  r'quickLog': r'quickLog',
  r'cookbookImport': r'cookbookImport',
};
const _AiCallLogtaskValueEnumMap = {
  r'receipt': AiTask.receipt,
  r'dailyRecipe': AiTask.dailyRecipe,
  r'spontaneousRecipe': AiTask.spontaneousRecipe,
  r'nutritionEstimate': AiTask.nutritionEstimate,
  r'nutritionLabel': AiTask.nutritionLabel,
  r'priceLookup': AiTask.priceLookup,
  r'quickLog': AiTask.quickLog,
  r'cookbookImport': AiTask.cookbookImport,
};

Id _aiCallLogGetId(AiCallLog object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _aiCallLogGetLinks(AiCallLog object) {
  return [];
}

void _aiCallLogAttach(IsarCollection<dynamic> col, Id id, AiCallLog object) {
  object.id = id;
}

extension AiCallLogQueryWhereSort
    on QueryBuilder<AiCallLog, AiCallLog, QWhere> {
  QueryBuilder<AiCallLog, AiCallLog, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterWhere> anyAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IndexWhereClause.any(indexName: r'at'));
    });
  }
}

extension AiCallLogQueryWhere
    on QueryBuilder<AiCallLog, AiCallLog, QWhereClause> {
  QueryBuilder<AiCallLog, AiCallLog, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterWhereClause> atEqualTo(DateTime at) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'at', value: [at]),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterWhereClause> atNotEqualTo(
    DateTime at,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'at',
                lower: [],
                upper: [at],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'at',
                lower: [at],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'at',
                lower: [at],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'at',
                lower: [],
                upper: [at],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterWhereClause> atGreaterThan(
    DateTime at, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'at',
          lower: [at],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterWhereClause> atLessThan(
    DateTime at, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'at',
          lower: [],
          upper: [at],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterWhereClause> atBetween(
    DateTime lowerAt,
    DateTime upperAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'at',
          lower: [lowerAt],
          includeLower: includeLower,
          upper: [upperAt],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension AiCallLogQueryFilter
    on QueryBuilder<AiCallLog, AiCallLog, QFilterCondition> {
  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition> atEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'at', value: value),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition> atGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'at',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition> atLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'at',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition> atBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'at',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition> errorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'error'),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition> errorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'error'),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition> errorEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'error',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition> errorGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'error',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition> errorLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'error',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition> errorBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'error',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition> errorStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'error',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition> errorEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'error',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition> errorContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'error',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition> errorMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'error',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition> errorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'error', value: ''),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition> errorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'error', value: ''),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition> idBetween(
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

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition>
  inputTokensIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'inputTokens'),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition>
  inputTokensIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'inputTokens'),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition> inputTokensEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'inputTokens', value: value),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition>
  inputTokensGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'inputTokens',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition> inputTokensLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'inputTokens',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition> inputTokensBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'inputTokens',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition> latencyMsEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'latencyMs', value: value),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition>
  latencyMsGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'latencyMs',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition> latencyMsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'latencyMs',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition> latencyMsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'latencyMs',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition> modelEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'model',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition> modelGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'model',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition> modelLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'model',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition> modelBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'model',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition> modelStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'model',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition> modelEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'model',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition> modelContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'model',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition> modelMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'model',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition> modelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'model', value: ''),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition> modelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'model', value: ''),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition>
  outputTokensIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'outputTokens'),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition>
  outputTokensIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'outputTokens'),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition> outputTokensEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'outputTokens', value: value),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition>
  outputTokensGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'outputTokens',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition>
  outputTokensLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'outputTokens',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition> outputTokensBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'outputTokens',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition> parsedOkEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'parsedOk', value: value),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition>
  promptVersionEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'promptVersion',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition>
  promptVersionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'promptVersion',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition>
  promptVersionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'promptVersion',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition>
  promptVersionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'promptVersion',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition>
  promptVersionStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'promptVersion',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition>
  promptVersionEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'promptVersion',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition>
  promptVersionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'promptVersion',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition>
  promptVersionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'promptVersion',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition>
  promptVersionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'promptVersion', value: ''),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition>
  promptVersionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'promptVersion', value: ''),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition> rawResponseEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'rawResponse',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition>
  rawResponseGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'rawResponse',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition> rawResponseLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'rawResponse',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition> rawResponseBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'rawResponse',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition>
  rawResponseStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'rawResponse',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition> rawResponseEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'rawResponse',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition> rawResponseContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'rawResponse',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition> rawResponseMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'rawResponse',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition>
  rawResponseIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'rawResponse', value: ''),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition>
  rawResponseIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'rawResponse', value: ''),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition> repairedEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'repaired', value: value),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition> taskEqualTo(
    AiTask value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'task',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition> taskGreaterThan(
    AiTask value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'task',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition> taskLessThan(
    AiTask value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'task',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition> taskBetween(
    AiTask lower,
    AiTask upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'task',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition> taskStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'task',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition> taskEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'task',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition> taskContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'task',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition> taskMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'task',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition> taskIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'task', value: ''),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition> taskIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'task', value: ''),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition>
  validationFlagsElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'validationFlags',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition>
  validationFlagsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'validationFlags',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition>
  validationFlagsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'validationFlags',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition>
  validationFlagsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'validationFlags',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition>
  validationFlagsElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'validationFlags',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition>
  validationFlagsElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'validationFlags',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition>
  validationFlagsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'validationFlags',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition>
  validationFlagsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'validationFlags',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition>
  validationFlagsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'validationFlags', value: ''),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition>
  validationFlagsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'validationFlags', value: ''),
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition>
  validationFlagsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'validationFlags', length, true, length, true);
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition>
  validationFlagsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'validationFlags', 0, true, 0, true);
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition>
  validationFlagsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'validationFlags', 0, false, 999999, true);
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition>
  validationFlagsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'validationFlags', 0, true, length, include);
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition>
  validationFlagsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'validationFlags',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterFilterCondition>
  validationFlagsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'validationFlags',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension AiCallLogQueryObject
    on QueryBuilder<AiCallLog, AiCallLog, QFilterCondition> {}

extension AiCallLogQueryLinks
    on QueryBuilder<AiCallLog, AiCallLog, QFilterCondition> {}

extension AiCallLogQuerySortBy on QueryBuilder<AiCallLog, AiCallLog, QSortBy> {
  QueryBuilder<AiCallLog, AiCallLog, QAfterSortBy> sortByAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'at', Sort.asc);
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterSortBy> sortByAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'at', Sort.desc);
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterSortBy> sortByError() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'error', Sort.asc);
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterSortBy> sortByErrorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'error', Sort.desc);
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterSortBy> sortByInputTokens() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inputTokens', Sort.asc);
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterSortBy> sortByInputTokensDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inputTokens', Sort.desc);
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterSortBy> sortByLatencyMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latencyMs', Sort.asc);
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterSortBy> sortByLatencyMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latencyMs', Sort.desc);
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterSortBy> sortByModel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'model', Sort.asc);
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterSortBy> sortByModelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'model', Sort.desc);
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterSortBy> sortByOutputTokens() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outputTokens', Sort.asc);
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterSortBy> sortByOutputTokensDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outputTokens', Sort.desc);
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterSortBy> sortByParsedOk() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parsedOk', Sort.asc);
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterSortBy> sortByParsedOkDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parsedOk', Sort.desc);
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterSortBy> sortByPromptVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'promptVersion', Sort.asc);
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterSortBy> sortByPromptVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'promptVersion', Sort.desc);
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterSortBy> sortByRawResponse() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawResponse', Sort.asc);
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterSortBy> sortByRawResponseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawResponse', Sort.desc);
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterSortBy> sortByRepaired() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'repaired', Sort.asc);
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterSortBy> sortByRepairedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'repaired', Sort.desc);
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterSortBy> sortByTask() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'task', Sort.asc);
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterSortBy> sortByTaskDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'task', Sort.desc);
    });
  }
}

extension AiCallLogQuerySortThenBy
    on QueryBuilder<AiCallLog, AiCallLog, QSortThenBy> {
  QueryBuilder<AiCallLog, AiCallLog, QAfterSortBy> thenByAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'at', Sort.asc);
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterSortBy> thenByAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'at', Sort.desc);
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterSortBy> thenByError() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'error', Sort.asc);
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterSortBy> thenByErrorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'error', Sort.desc);
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterSortBy> thenByInputTokens() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inputTokens', Sort.asc);
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterSortBy> thenByInputTokensDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inputTokens', Sort.desc);
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterSortBy> thenByLatencyMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latencyMs', Sort.asc);
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterSortBy> thenByLatencyMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latencyMs', Sort.desc);
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterSortBy> thenByModel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'model', Sort.asc);
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterSortBy> thenByModelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'model', Sort.desc);
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterSortBy> thenByOutputTokens() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outputTokens', Sort.asc);
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterSortBy> thenByOutputTokensDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outputTokens', Sort.desc);
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterSortBy> thenByParsedOk() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parsedOk', Sort.asc);
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterSortBy> thenByParsedOkDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parsedOk', Sort.desc);
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterSortBy> thenByPromptVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'promptVersion', Sort.asc);
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterSortBy> thenByPromptVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'promptVersion', Sort.desc);
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterSortBy> thenByRawResponse() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawResponse', Sort.asc);
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterSortBy> thenByRawResponseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawResponse', Sort.desc);
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterSortBy> thenByRepaired() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'repaired', Sort.asc);
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterSortBy> thenByRepairedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'repaired', Sort.desc);
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterSortBy> thenByTask() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'task', Sort.asc);
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QAfterSortBy> thenByTaskDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'task', Sort.desc);
    });
  }
}

extension AiCallLogQueryWhereDistinct
    on QueryBuilder<AiCallLog, AiCallLog, QDistinct> {
  QueryBuilder<AiCallLog, AiCallLog, QDistinct> distinctByAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'at');
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QDistinct> distinctByError({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'error', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QDistinct> distinctByInputTokens() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'inputTokens');
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QDistinct> distinctByLatencyMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'latencyMs');
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QDistinct> distinctByModel({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'model', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QDistinct> distinctByOutputTokens() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'outputTokens');
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QDistinct> distinctByParsedOk() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'parsedOk');
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QDistinct> distinctByPromptVersion({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'promptVersion',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QDistinct> distinctByRawResponse({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rawResponse', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QDistinct> distinctByRepaired() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'repaired');
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QDistinct> distinctByTask({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'task', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AiCallLog, AiCallLog, QDistinct> distinctByValidationFlags() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'validationFlags');
    });
  }
}

extension AiCallLogQueryProperty
    on QueryBuilder<AiCallLog, AiCallLog, QQueryProperty> {
  QueryBuilder<AiCallLog, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AiCallLog, DateTime, QQueryOperations> atProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'at');
    });
  }

  QueryBuilder<AiCallLog, String?, QQueryOperations> errorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'error');
    });
  }

  QueryBuilder<AiCallLog, int?, QQueryOperations> inputTokensProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'inputTokens');
    });
  }

  QueryBuilder<AiCallLog, int, QQueryOperations> latencyMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'latencyMs');
    });
  }

  QueryBuilder<AiCallLog, String, QQueryOperations> modelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'model');
    });
  }

  QueryBuilder<AiCallLog, int?, QQueryOperations> outputTokensProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'outputTokens');
    });
  }

  QueryBuilder<AiCallLog, bool, QQueryOperations> parsedOkProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'parsedOk');
    });
  }

  QueryBuilder<AiCallLog, String, QQueryOperations> promptVersionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'promptVersion');
    });
  }

  QueryBuilder<AiCallLog, String, QQueryOperations> rawResponseProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rawResponse');
    });
  }

  QueryBuilder<AiCallLog, bool, QQueryOperations> repairedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'repaired');
    });
  }

  QueryBuilder<AiCallLog, AiTask, QQueryOperations> taskProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'task');
    });
  }

  QueryBuilder<AiCallLog, List<String>, QQueryOperations>
  validationFlagsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'validationFlags');
    });
  }
}
