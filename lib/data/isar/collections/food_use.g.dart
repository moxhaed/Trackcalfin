// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_use.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetFoodUseCollection on Isar {
  IsarCollection<FoodUse> get foodUses => this.collection();
}

const FoodUseSchema = CollectionSchema(
  name: r'FoodUse',
  id: -7279156902872967318,
  properties: {
    r'costMinor': PropertySchema(
      id: 0,
      name: r'costMinor',
      type: IsarType.long,
    ),
    r'countLeft': PropertySchema(
      id: 1,
      name: r'countLeft',
      type: IsarType.double,
    ),
    r'countedBefore': PropertySchema(
      id: 2,
      name: r'countedBefore',
      type: IsarType.dateTime,
    ),
    r'createdAt': PropertySchema(
      id: 3,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'expiresBefore': PropertySchema(
      id: 4,
      name: r'expiresBefore',
      type: IsarType.dateTime,
    ),
    r'from': PropertySchema(id: 5, name: r'from', type: IsarType.dateTime),
    r'ingredientKey': PropertySchema(
      id: 6,
      name: r'ingredientKey',
      type: IsarType.string,
    ),
    r'kind': PropertySchema(
      id: 7,
      name: r'kind',
      type: IsarType.string,
      enumMap: _FoodUsekindEnumValueMap,
    ),
    r'name': PropertySchema(id: 8, name: r'name', type: IsarType.string),
    r'qtyBase': PropertySchema(id: 9, name: r'qtyBase', type: IsarType.double),
    r'to': PropertySchema(id: 10, name: r'to', type: IsarType.dateTime),
    r'transactionId': PropertySchema(
      id: 11,
      name: r'transactionId',
      type: IsarType.long,
    ),
  },

  estimateSize: _foodUseEstimateSize,
  serialize: _foodUseSerialize,
  deserialize: _foodUseDeserialize,
  deserializeProp: _foodUseDeserializeProp,
  idName: r'id',
  indexes: {
    r'to': IndexSchema(
      id: 8585794172020190459,
      name: r'to',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'to',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
    r'transactionId': IndexSchema(
      id: 8561542235958051982,
      name: r'transactionId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'transactionId',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _foodUseGetId,
  getLinks: _foodUseGetLinks,
  attach: _foodUseAttach,
  version: '3.3.2',
);

int _foodUseEstimateSize(
  FoodUse object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.ingredientKey.length * 3;
  bytesCount += 3 + object.kind.name.length * 3;
  bytesCount += 3 + object.name.length * 3;
  return bytesCount;
}

void _foodUseSerialize(
  FoodUse object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.costMinor);
  writer.writeDouble(offsets[1], object.countLeft);
  writer.writeDateTime(offsets[2], object.countedBefore);
  writer.writeDateTime(offsets[3], object.createdAt);
  writer.writeDateTime(offsets[4], object.expiresBefore);
  writer.writeDateTime(offsets[5], object.from);
  writer.writeString(offsets[6], object.ingredientKey);
  writer.writeString(offsets[7], object.kind.name);
  writer.writeString(offsets[8], object.name);
  writer.writeDouble(offsets[9], object.qtyBase);
  writer.writeDateTime(offsets[10], object.to);
  writer.writeLong(offsets[11], object.transactionId);
}

FoodUse _foodUseDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = FoodUse();
  object.costMinor = reader.readLong(offsets[0]);
  object.countLeft = reader.readDoubleOrNull(offsets[1]);
  object.countedBefore = reader.readDateTimeOrNull(offsets[2]);
  object.createdAt = reader.readDateTime(offsets[3]);
  object.expiresBefore = reader.readDateTimeOrNull(offsets[4]);
  object.from = reader.readDateTime(offsets[5]);
  object.id = id;
  object.ingredientKey = reader.readString(offsets[6]);
  object.kind =
      _FoodUsekindValueEnumMap[reader.readStringOrNull(offsets[7])] ??
      UseKind.eaten;
  object.name = reader.readString(offsets[8]);
  object.qtyBase = reader.readDouble(offsets[9]);
  object.to = reader.readDateTime(offsets[10]);
  object.transactionId = reader.readLongOrNull(offsets[11]);
  return object;
}

P _foodUseDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readDoubleOrNull(offset)) as P;
    case 2:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (_FoodUsekindValueEnumMap[reader.readStringOrNull(offset)] ??
              UseKind.eaten)
          as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readDouble(offset)) as P;
    case 10:
      return (reader.readDateTime(offset)) as P;
    case 11:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _FoodUsekindEnumValueMap = {
  r'eaten': r'eaten',
  r'thrownAway': r'thrownAway',
};
const _FoodUsekindValueEnumMap = {
  r'eaten': UseKind.eaten,
  r'thrownAway': UseKind.thrownAway,
};

Id _foodUseGetId(FoodUse object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _foodUseGetLinks(FoodUse object) {
  return [];
}

void _foodUseAttach(IsarCollection<dynamic> col, Id id, FoodUse object) {
  object.id = id;
}

extension FoodUseQueryWhereSort on QueryBuilder<FoodUse, FoodUse, QWhere> {
  QueryBuilder<FoodUse, FoodUse, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterWhere> anyTo() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IndexWhereClause.any(indexName: r'to'));
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterWhere> anyTransactionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'transactionId'),
      );
    });
  }
}

extension FoodUseQueryWhere on QueryBuilder<FoodUse, FoodUse, QWhereClause> {
  QueryBuilder<FoodUse, FoodUse, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<FoodUse, FoodUse, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterWhereClause> idBetween(
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

  QueryBuilder<FoodUse, FoodUse, QAfterWhereClause> toEqualTo(DateTime to) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'to', value: [to]),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterWhereClause> toNotEqualTo(DateTime to) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'to',
                lower: [],
                upper: [to],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'to',
                lower: [to],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'to',
                lower: [to],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'to',
                lower: [],
                upper: [to],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterWhereClause> toGreaterThan(
    DateTime to, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'to',
          lower: [to],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterWhereClause> toLessThan(
    DateTime to, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'to',
          lower: [],
          upper: [to],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterWhereClause> toBetween(
    DateTime lowerTo,
    DateTime upperTo, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'to',
          lower: [lowerTo],
          includeLower: includeLower,
          upper: [upperTo],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterWhereClause> transactionIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'transactionId', value: [null]),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterWhereClause> transactionIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'transactionId',
          lower: [null],
          includeLower: false,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterWhereClause> transactionIdEqualTo(
    int? transactionId,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'transactionId',
          value: [transactionId],
        ),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterWhereClause> transactionIdNotEqualTo(
    int? transactionId,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'transactionId',
                lower: [],
                upper: [transactionId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'transactionId',
                lower: [transactionId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'transactionId',
                lower: [transactionId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'transactionId',
                lower: [],
                upper: [transactionId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterWhereClause> transactionIdGreaterThan(
    int? transactionId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'transactionId',
          lower: [transactionId],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterWhereClause> transactionIdLessThan(
    int? transactionId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'transactionId',
          lower: [],
          upper: [transactionId],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterWhereClause> transactionIdBetween(
    int? lowerTransactionId,
    int? upperTransactionId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'transactionId',
          lower: [lowerTransactionId],
          includeLower: includeLower,
          upper: [upperTransactionId],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension FoodUseQueryFilter
    on QueryBuilder<FoodUse, FoodUse, QFilterCondition> {
  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition> costMinorEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'costMinor', value: value),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition> costMinorGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'costMinor',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition> costMinorLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'costMinor',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition> costMinorBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'costMinor',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition> countLeftIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'countLeft'),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition> countLeftIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'countLeft'),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition> countLeftEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'countLeft',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition> countLeftGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'countLeft',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition> countLeftLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'countLeft',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition> countLeftBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'countLeft',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition> countedBeforeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'countedBefore'),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition>
  countedBeforeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'countedBefore'),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition> countedBeforeEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'countedBefore', value: value),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition>
  countedBeforeGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'countedBefore',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition> countedBeforeLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'countedBefore',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition> countedBeforeBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'countedBefore',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition> createdAtEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition> createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition> createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition> createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'createdAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition> expiresBeforeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'expiresBefore'),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition>
  expiresBeforeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'expiresBefore'),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition> expiresBeforeEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'expiresBefore', value: value),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition>
  expiresBeforeGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'expiresBefore',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition> expiresBeforeLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'expiresBefore',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition> expiresBeforeBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'expiresBefore',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition> fromEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'from', value: value),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition> fromGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'from',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition> fromLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'from',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition> fromBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'from',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition> idBetween(
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

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition> ingredientKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'ingredientKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition>
  ingredientKeyGreaterThan(
    String value, {
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

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition> ingredientKeyLessThan(
    String value, {
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

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition> ingredientKeyBetween(
    String lower,
    String upper, {
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

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition> ingredientKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'ingredientKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition> ingredientKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'ingredientKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition> ingredientKeyContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'ingredientKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition> ingredientKeyMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'ingredientKey',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition> ingredientKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'ingredientKey', value: ''),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition>
  ingredientKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'ingredientKey', value: ''),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition> kindEqualTo(
    UseKind value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'kind',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition> kindGreaterThan(
    UseKind value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'kind',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition> kindLessThan(
    UseKind value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'kind',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition> kindBetween(
    UseKind lower,
    UseKind upper, {
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

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition> kindStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'kind',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition> kindEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'kind',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition> kindContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'kind',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition> kindMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'kind',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition> kindIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'kind', value: ''),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition> kindIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'kind', value: ''),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition> nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition> nameBetween(
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

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition> nameContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition> nameMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'name',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition> qtyBaseEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'qtyBase',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition> qtyBaseGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'qtyBase',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition> qtyBaseLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'qtyBase',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition> qtyBaseBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'qtyBase',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition> toEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'to', value: value),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition> toGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'to',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition> toLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'to',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition> toBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'to',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition> transactionIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'transactionId'),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition>
  transactionIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'transactionId'),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition> transactionIdEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'transactionId', value: value),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition>
  transactionIdGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'transactionId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition> transactionIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'transactionId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterFilterCondition> transactionIdBetween(
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
}

extension FoodUseQueryObject
    on QueryBuilder<FoodUse, FoodUse, QFilterCondition> {}

extension FoodUseQueryLinks
    on QueryBuilder<FoodUse, FoodUse, QFilterCondition> {}

extension FoodUseQuerySortBy on QueryBuilder<FoodUse, FoodUse, QSortBy> {
  QueryBuilder<FoodUse, FoodUse, QAfterSortBy> sortByCostMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'costMinor', Sort.asc);
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterSortBy> sortByCostMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'costMinor', Sort.desc);
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterSortBy> sortByCountLeft() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'countLeft', Sort.asc);
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterSortBy> sortByCountLeftDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'countLeft', Sort.desc);
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterSortBy> sortByCountedBefore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'countedBefore', Sort.asc);
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterSortBy> sortByCountedBeforeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'countedBefore', Sort.desc);
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterSortBy> sortByExpiresBefore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiresBefore', Sort.asc);
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterSortBy> sortByExpiresBeforeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiresBefore', Sort.desc);
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterSortBy> sortByFrom() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'from', Sort.asc);
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterSortBy> sortByFromDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'from', Sort.desc);
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterSortBy> sortByIngredientKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ingredientKey', Sort.asc);
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterSortBy> sortByIngredientKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ingredientKey', Sort.desc);
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterSortBy> sortByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.asc);
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterSortBy> sortByKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.desc);
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterSortBy> sortByQtyBase() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qtyBase', Sort.asc);
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterSortBy> sortByQtyBaseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qtyBase', Sort.desc);
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterSortBy> sortByTo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'to', Sort.asc);
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterSortBy> sortByToDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'to', Sort.desc);
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterSortBy> sortByTransactionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transactionId', Sort.asc);
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterSortBy> sortByTransactionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transactionId', Sort.desc);
    });
  }
}

extension FoodUseQuerySortThenBy
    on QueryBuilder<FoodUse, FoodUse, QSortThenBy> {
  QueryBuilder<FoodUse, FoodUse, QAfterSortBy> thenByCostMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'costMinor', Sort.asc);
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterSortBy> thenByCostMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'costMinor', Sort.desc);
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterSortBy> thenByCountLeft() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'countLeft', Sort.asc);
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterSortBy> thenByCountLeftDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'countLeft', Sort.desc);
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterSortBy> thenByCountedBefore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'countedBefore', Sort.asc);
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterSortBy> thenByCountedBeforeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'countedBefore', Sort.desc);
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterSortBy> thenByExpiresBefore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiresBefore', Sort.asc);
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterSortBy> thenByExpiresBeforeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiresBefore', Sort.desc);
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterSortBy> thenByFrom() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'from', Sort.asc);
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterSortBy> thenByFromDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'from', Sort.desc);
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterSortBy> thenByIngredientKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ingredientKey', Sort.asc);
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterSortBy> thenByIngredientKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ingredientKey', Sort.desc);
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterSortBy> thenByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.asc);
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterSortBy> thenByKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.desc);
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterSortBy> thenByQtyBase() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qtyBase', Sort.asc);
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterSortBy> thenByQtyBaseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qtyBase', Sort.desc);
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterSortBy> thenByTo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'to', Sort.asc);
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterSortBy> thenByToDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'to', Sort.desc);
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterSortBy> thenByTransactionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transactionId', Sort.asc);
    });
  }

  QueryBuilder<FoodUse, FoodUse, QAfterSortBy> thenByTransactionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transactionId', Sort.desc);
    });
  }
}

extension FoodUseQueryWhereDistinct
    on QueryBuilder<FoodUse, FoodUse, QDistinct> {
  QueryBuilder<FoodUse, FoodUse, QDistinct> distinctByCostMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'costMinor');
    });
  }

  QueryBuilder<FoodUse, FoodUse, QDistinct> distinctByCountLeft() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'countLeft');
    });
  }

  QueryBuilder<FoodUse, FoodUse, QDistinct> distinctByCountedBefore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'countedBefore');
    });
  }

  QueryBuilder<FoodUse, FoodUse, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<FoodUse, FoodUse, QDistinct> distinctByExpiresBefore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'expiresBefore');
    });
  }

  QueryBuilder<FoodUse, FoodUse, QDistinct> distinctByFrom() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'from');
    });
  }

  QueryBuilder<FoodUse, FoodUse, QDistinct> distinctByIngredientKey({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'ingredientKey',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<FoodUse, FoodUse, QDistinct> distinctByKind({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'kind', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FoodUse, FoodUse, QDistinct> distinctByName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FoodUse, FoodUse, QDistinct> distinctByQtyBase() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'qtyBase');
    });
  }

  QueryBuilder<FoodUse, FoodUse, QDistinct> distinctByTo() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'to');
    });
  }

  QueryBuilder<FoodUse, FoodUse, QDistinct> distinctByTransactionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'transactionId');
    });
  }
}

extension FoodUseQueryProperty
    on QueryBuilder<FoodUse, FoodUse, QQueryProperty> {
  QueryBuilder<FoodUse, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<FoodUse, int, QQueryOperations> costMinorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'costMinor');
    });
  }

  QueryBuilder<FoodUse, double?, QQueryOperations> countLeftProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'countLeft');
    });
  }

  QueryBuilder<FoodUse, DateTime?, QQueryOperations> countedBeforeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'countedBefore');
    });
  }

  QueryBuilder<FoodUse, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<FoodUse, DateTime?, QQueryOperations> expiresBeforeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'expiresBefore');
    });
  }

  QueryBuilder<FoodUse, DateTime, QQueryOperations> fromProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'from');
    });
  }

  QueryBuilder<FoodUse, String, QQueryOperations> ingredientKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ingredientKey');
    });
  }

  QueryBuilder<FoodUse, UseKind, QQueryOperations> kindProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'kind');
    });
  }

  QueryBuilder<FoodUse, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<FoodUse, double, QQueryOperations> qtyBaseProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'qtyBase');
    });
  }

  QueryBuilder<FoodUse, DateTime, QQueryOperations> toProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'to');
    });
  }

  QueryBuilder<FoodUse, int?, QQueryOperations> transactionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'transactionId');
    });
  }
}
