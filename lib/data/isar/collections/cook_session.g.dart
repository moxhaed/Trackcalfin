// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cook_session.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCookSessionCollection on Isar {
  IsarCollection<CookSession> get cookSessions => this.collection();
}

const CookSessionSchema = CollectionSchema(
  name: r'CookSession',
  id: 7175498929270146000,
  properties: {
    r'cookedAt': PropertySchema(id: 0, name: r'cookedAt', type: IsarType.dateTime),
    r'costPerPortionMinor': PropertySchema(id: 1, name: r'costPerPortionMinor', type: IsarType.long),
    r'deltas': PropertySchema(id: 2, name: r'deltas', type: IsarType.objectList, target: r'StockDelta'),
    r'fridgeExpiresAt': PropertySchema(id: 3, name: r'fridgeExpiresAt', type: IsarType.dateTime),
    r'perPortion': PropertySchema(id: 4, name: r'perPortion', type: IsarType.object, target: r'Nutrition'),
    r'portionsCooked': PropertySchema(id: 5, name: r'portionsCooked', type: IsarType.long),
    r'portionsDiscarded': PropertySchema(id: 6, name: r'portionsDiscarded', type: IsarType.long),
    r'portionsRemaining': PropertySchema(id: 7, name: r'portionsRemaining', type: IsarType.long),
    r'recipeId': PropertySchema(id: 8, name: r'recipeId', type: IsarType.long),
    r'recipeTitle': PropertySchema(id: 9, name: r'recipeTitle', type: IsarType.string),
    r'status': PropertySchema(id: 10, name: r'status', type: IsarType.string, enumMap: _CookSessionstatusEnumValueMap),
  },

  estimateSize: _cookSessionEstimateSize,
  serialize: _cookSessionSerialize,
  deserialize: _cookSessionDeserialize,
  deserializeProp: _cookSessionDeserializeProp,
  idName: r'id',
  indexes: {
    r'cookedAt': IndexSchema(
      id: -1224455373919012237,
      name: r'cookedAt',
      unique: false,
      replace: false,
      properties: [IndexPropertySchema(name: r'cookedAt', type: IndexType.value, caseSensitive: false)],
    ),
    r'status': IndexSchema(
      id: -107785170620420283,
      name: r'status',
      unique: false,
      replace: false,
      properties: [IndexPropertySchema(name: r'status', type: IndexType.hash, caseSensitive: true)],
    ),
  },
  links: {},
  embeddedSchemas: {r'Nutrition': NutritionSchema, r'StockDelta': StockDeltaSchema},

  getId: _cookSessionGetId,
  getLinks: _cookSessionGetLinks,
  attach: _cookSessionAttach,
  version: '3.3.2',
);

int _cookSessionEstimateSize(CookSession object, List<int> offsets, Map<Type, List<int>> allOffsets) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.deltas.length * 3;
  {
    final offsets = allOffsets[StockDelta]!;
    for (var i = 0; i < object.deltas.length; i++) {
      final value = object.deltas[i];
      bytesCount += StockDeltaSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  bytesCount += 3 + NutritionSchema.estimateSize(object.perPortion, allOffsets[Nutrition]!, allOffsets);
  bytesCount += 3 + object.recipeTitle.length * 3;
  bytesCount += 3 + object.status.name.length * 3;
  return bytesCount;
}

void _cookSessionSerialize(CookSession object, IsarWriter writer, List<int> offsets, Map<Type, List<int>> allOffsets) {
  writer.writeDateTime(offsets[0], object.cookedAt);
  writer.writeLong(offsets[1], object.costPerPortionMinor);
  writer.writeObjectList<StockDelta>(offsets[2], allOffsets, StockDeltaSchema.serialize, object.deltas);
  writer.writeDateTime(offsets[3], object.fridgeExpiresAt);
  writer.writeObject<Nutrition>(offsets[4], allOffsets, NutritionSchema.serialize, object.perPortion);
  writer.writeLong(offsets[5], object.portionsCooked);
  writer.writeLong(offsets[6], object.portionsDiscarded);
  writer.writeLong(offsets[7], object.portionsRemaining);
  writer.writeLong(offsets[8], object.recipeId);
  writer.writeString(offsets[9], object.recipeTitle);
  writer.writeString(offsets[10], object.status.name);
}

CookSession _cookSessionDeserialize(Id id, IsarReader reader, List<int> offsets, Map<Type, List<int>> allOffsets) {
  final object = CookSession();
  object.cookedAt = reader.readDateTime(offsets[0]);
  object.costPerPortionMinor = reader.readLong(offsets[1]);
  object.deltas =
      reader.readObjectList<StockDelta>(offsets[2], StockDeltaSchema.deserialize, allOffsets, StockDelta()) ?? [];
  object.fridgeExpiresAt = reader.readDateTimeOrNull(offsets[3]);
  object.id = id;
  object.perPortion =
      reader.readObjectOrNull<Nutrition>(offsets[4], NutritionSchema.deserialize, allOffsets) ?? Nutrition();
  object.portionsCooked = reader.readLong(offsets[5]);
  object.portionsDiscarded = reader.readLong(offsets[6]);
  object.portionsRemaining = reader.readLong(offsets[7]);
  object.recipeId = reader.readLong(offsets[8]);
  object.recipeTitle = reader.readString(offsets[9]);
  object.status = _CookSessionstatusValueEnumMap[reader.readStringOrNull(offsets[10])] ?? CookStatus.active;
  return object;
}

P _cookSessionDeserializeProp<P>(IsarReader reader, int propertyId, int offset, Map<Type, List<int>> allOffsets) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readObjectList<StockDelta>(offset, StockDeltaSchema.deserialize, allOffsets, StockDelta()) ?? [])
          as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readObjectOrNull<Nutrition>(offset, NutritionSchema.deserialize, allOffsets) ?? Nutrition()) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (_CookSessionstatusValueEnumMap[reader.readStringOrNull(offset)] ?? CookStatus.active) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _CookSessionstatusEnumValueMap = {
  r'active': r'active',
  r'finished': r'finished',
  r'discarded': r'discarded',
  r'undone': r'undone',
};
const _CookSessionstatusValueEnumMap = {
  r'active': CookStatus.active,
  r'finished': CookStatus.finished,
  r'discarded': CookStatus.discarded,
  r'undone': CookStatus.undone,
};

Id _cookSessionGetId(CookSession object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _cookSessionGetLinks(CookSession object) {
  return [];
}

void _cookSessionAttach(IsarCollection<dynamic> col, Id id, CookSession object) {
  object.id = id;
}

extension CookSessionQueryWhereSort on QueryBuilder<CookSession, CookSession, QWhere> {
  QueryBuilder<CookSession, CookSession, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterWhere> anyCookedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IndexWhereClause.any(indexName: r'cookedAt'));
    });
  }
}

extension CookSessionQueryWhere on QueryBuilder<CookSession, CookSession, QWhereClause> {
  QueryBuilder<CookSession, CookSession, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<CookSession, CookSession, QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.greaterThan(lower: id, includeLower: include));
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.lessThan(upper: id, includeUpper: include));
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterWhereClause> idBetween(
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

  QueryBuilder<CookSession, CookSession, QAfterWhereClause> cookedAtEqualTo(DateTime cookedAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(indexName: r'cookedAt', value: [cookedAt]));
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterWhereClause> cookedAtNotEqualTo(DateTime cookedAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(indexName: r'cookedAt', lower: [], upper: [cookedAt], includeUpper: false),
            )
            .addWhereClause(
              IndexWhereClause.between(indexName: r'cookedAt', lower: [cookedAt], includeLower: false, upper: []),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(indexName: r'cookedAt', lower: [cookedAt], includeLower: false, upper: []),
            )
            .addWhereClause(
              IndexWhereClause.between(indexName: r'cookedAt', lower: [], upper: [cookedAt], includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterWhereClause> cookedAtGreaterThan(
    DateTime cookedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(indexName: r'cookedAt', lower: [cookedAt], includeLower: include, upper: []),
      );
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterWhereClause> cookedAtLessThan(
    DateTime cookedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(indexName: r'cookedAt', lower: [], upper: [cookedAt], includeUpper: include),
      );
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterWhereClause> cookedAtBetween(
    DateTime lowerCookedAt,
    DateTime upperCookedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'cookedAt',
          lower: [lowerCookedAt],
          includeLower: includeLower,
          upper: [upperCookedAt],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterWhereClause> statusEqualTo(CookStatus status) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(indexName: r'status', value: [status]));
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterWhereClause> statusNotEqualTo(CookStatus status) {
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

extension CookSessionQueryFilter on QueryBuilder<CookSession, CookSession, QFilterCondition> {
  QueryBuilder<CookSession, CookSession, QAfterFilterCondition> cookedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'cookedAt', value: value));
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterFilterCondition> cookedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(include: include, property: r'cookedAt', value: value),
      );
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterFilterCondition> cookedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(include: include, property: r'cookedAt', value: value));
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterFilterCondition> cookedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'cookedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterFilterCondition> costPerPortionMinorEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'costPerPortionMinor', value: value));
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterFilterCondition> costPerPortionMinorGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(include: include, property: r'costPerPortionMinor', value: value),
      );
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterFilterCondition> costPerPortionMinorLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'costPerPortionMinor', value: value),
      );
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterFilterCondition> costPerPortionMinorBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'costPerPortionMinor',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterFilterCondition> deltasLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'deltas', length, true, length, true);
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterFilterCondition> deltasIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'deltas', 0, true, 0, true);
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterFilterCondition> deltasIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'deltas', 0, false, 999999, true);
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterFilterCondition> deltasLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'deltas', 0, true, length, include);
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterFilterCondition> deltasLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'deltas', length, include, 999999, true);
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterFilterCondition> deltasLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'deltas', lower, includeLower, upper, includeUpper);
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterFilterCondition> fridgeExpiresAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(property: r'fridgeExpiresAt'));
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterFilterCondition> fridgeExpiresAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(property: r'fridgeExpiresAt'));
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterFilterCondition> fridgeExpiresAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'fridgeExpiresAt', value: value));
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterFilterCondition> fridgeExpiresAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(include: include, property: r'fridgeExpiresAt', value: value),
      );
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterFilterCondition> fridgeExpiresAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'fridgeExpiresAt', value: value),
      );
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterFilterCondition> fridgeExpiresAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'fridgeExpiresAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'id', value: value));
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterFilterCondition> idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(include: include, property: r'id', value: value));
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterFilterCondition> idLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(include: include, property: r'id', value: value));
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterFilterCondition> idBetween(
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

  QueryBuilder<CookSession, CookSession, QAfterFilterCondition> portionsCookedEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'portionsCooked', value: value));
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterFilterCondition> portionsCookedGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(include: include, property: r'portionsCooked', value: value),
      );
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterFilterCondition> portionsCookedLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'portionsCooked', value: value),
      );
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterFilterCondition> portionsCookedBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'portionsCooked',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterFilterCondition> portionsDiscardedEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'portionsDiscarded', value: value));
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterFilterCondition> portionsDiscardedGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(include: include, property: r'portionsDiscarded', value: value),
      );
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterFilterCondition> portionsDiscardedLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'portionsDiscarded', value: value),
      );
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterFilterCondition> portionsDiscardedBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'portionsDiscarded',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterFilterCondition> portionsRemainingEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'portionsRemaining', value: value));
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterFilterCondition> portionsRemainingGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(include: include, property: r'portionsRemaining', value: value),
      );
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterFilterCondition> portionsRemainingLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'portionsRemaining', value: value),
      );
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterFilterCondition> portionsRemainingBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'portionsRemaining',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterFilterCondition> recipeIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'recipeId', value: value));
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterFilterCondition> recipeIdGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(include: include, property: r'recipeId', value: value),
      );
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterFilterCondition> recipeIdLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(include: include, property: r'recipeId', value: value));
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterFilterCondition> recipeIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'recipeId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterFilterCondition> recipeTitleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'recipeTitle', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterFilterCondition> recipeTitleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'recipeTitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterFilterCondition> recipeTitleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'recipeTitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterFilterCondition> recipeTitleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'recipeTitle',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterFilterCondition> recipeTitleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(property: r'recipeTitle', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterFilterCondition> recipeTitleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(property: r'recipeTitle', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterFilterCondition> recipeTitleContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(property: r'recipeTitle', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterFilterCondition> recipeTitleMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(property: r'recipeTitle', wildcard: pattern, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterFilterCondition> recipeTitleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'recipeTitle', value: ''));
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterFilterCondition> recipeTitleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(property: r'recipeTitle', value: ''));
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterFilterCondition> statusEqualTo(
    CookStatus value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'status', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterFilterCondition> statusGreaterThan(
    CookStatus value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(include: include, property: r'status', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterFilterCondition> statusLessThan(
    CookStatus value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'status', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterFilterCondition> statusBetween(
    CookStatus lower,
    CookStatus upper, {
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

  QueryBuilder<CookSession, CookSession, QAfterFilterCondition> statusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(property: r'status', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterFilterCondition> statusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(property: r'status', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterFilterCondition> statusContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(property: r'status', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterFilterCondition> statusMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(property: r'status', wildcard: pattern, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterFilterCondition> statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'status', value: ''));
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterFilterCondition> statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(property: r'status', value: ''));
    });
  }
}

extension CookSessionQueryObject on QueryBuilder<CookSession, CookSession, QFilterCondition> {
  QueryBuilder<CookSession, CookSession, QAfterFilterCondition> deltasElement(FilterQuery<StockDelta> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'deltas');
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterFilterCondition> perPortion(FilterQuery<Nutrition> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'perPortion');
    });
  }
}

extension CookSessionQueryLinks on QueryBuilder<CookSession, CookSession, QFilterCondition> {}

extension CookSessionQuerySortBy on QueryBuilder<CookSession, CookSession, QSortBy> {
  QueryBuilder<CookSession, CookSession, QAfterSortBy> sortByCookedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cookedAt', Sort.asc);
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterSortBy> sortByCookedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cookedAt', Sort.desc);
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterSortBy> sortByCostPerPortionMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'costPerPortionMinor', Sort.asc);
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterSortBy> sortByCostPerPortionMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'costPerPortionMinor', Sort.desc);
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterSortBy> sortByFridgeExpiresAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fridgeExpiresAt', Sort.asc);
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterSortBy> sortByFridgeExpiresAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fridgeExpiresAt', Sort.desc);
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterSortBy> sortByPortionsCooked() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'portionsCooked', Sort.asc);
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterSortBy> sortByPortionsCookedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'portionsCooked', Sort.desc);
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterSortBy> sortByPortionsDiscarded() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'portionsDiscarded', Sort.asc);
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterSortBy> sortByPortionsDiscardedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'portionsDiscarded', Sort.desc);
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterSortBy> sortByPortionsRemaining() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'portionsRemaining', Sort.asc);
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterSortBy> sortByPortionsRemainingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'portionsRemaining', Sort.desc);
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterSortBy> sortByRecipeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recipeId', Sort.asc);
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterSortBy> sortByRecipeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recipeId', Sort.desc);
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterSortBy> sortByRecipeTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recipeTitle', Sort.asc);
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterSortBy> sortByRecipeTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recipeTitle', Sort.desc);
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterSortBy> sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }
}

extension CookSessionQuerySortThenBy on QueryBuilder<CookSession, CookSession, QSortThenBy> {
  QueryBuilder<CookSession, CookSession, QAfterSortBy> thenByCookedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cookedAt', Sort.asc);
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterSortBy> thenByCookedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cookedAt', Sort.desc);
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterSortBy> thenByCostPerPortionMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'costPerPortionMinor', Sort.asc);
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterSortBy> thenByCostPerPortionMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'costPerPortionMinor', Sort.desc);
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterSortBy> thenByFridgeExpiresAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fridgeExpiresAt', Sort.asc);
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterSortBy> thenByFridgeExpiresAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fridgeExpiresAt', Sort.desc);
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterSortBy> thenByPortionsCooked() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'portionsCooked', Sort.asc);
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterSortBy> thenByPortionsCookedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'portionsCooked', Sort.desc);
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterSortBy> thenByPortionsDiscarded() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'portionsDiscarded', Sort.asc);
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterSortBy> thenByPortionsDiscardedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'portionsDiscarded', Sort.desc);
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterSortBy> thenByPortionsRemaining() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'portionsRemaining', Sort.asc);
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterSortBy> thenByPortionsRemainingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'portionsRemaining', Sort.desc);
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterSortBy> thenByRecipeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recipeId', Sort.asc);
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterSortBy> thenByRecipeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recipeId', Sort.desc);
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterSortBy> thenByRecipeTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recipeTitle', Sort.asc);
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterSortBy> thenByRecipeTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recipeTitle', Sort.desc);
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<CookSession, CookSession, QAfterSortBy> thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }
}

extension CookSessionQueryWhereDistinct on QueryBuilder<CookSession, CookSession, QDistinct> {
  QueryBuilder<CookSession, CookSession, QDistinct> distinctByCookedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cookedAt');
    });
  }

  QueryBuilder<CookSession, CookSession, QDistinct> distinctByCostPerPortionMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'costPerPortionMinor');
    });
  }

  QueryBuilder<CookSession, CookSession, QDistinct> distinctByFridgeExpiresAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fridgeExpiresAt');
    });
  }

  QueryBuilder<CookSession, CookSession, QDistinct> distinctByPortionsCooked() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'portionsCooked');
    });
  }

  QueryBuilder<CookSession, CookSession, QDistinct> distinctByPortionsDiscarded() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'portionsDiscarded');
    });
  }

  QueryBuilder<CookSession, CookSession, QDistinct> distinctByPortionsRemaining() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'portionsRemaining');
    });
  }

  QueryBuilder<CookSession, CookSession, QDistinct> distinctByRecipeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'recipeId');
    });
  }

  QueryBuilder<CookSession, CookSession, QDistinct> distinctByRecipeTitle({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'recipeTitle', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CookSession, CookSession, QDistinct> distinctByStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }
}

extension CookSessionQueryProperty on QueryBuilder<CookSession, CookSession, QQueryProperty> {
  QueryBuilder<CookSession, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CookSession, DateTime, QQueryOperations> cookedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cookedAt');
    });
  }

  QueryBuilder<CookSession, int, QQueryOperations> costPerPortionMinorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'costPerPortionMinor');
    });
  }

  QueryBuilder<CookSession, List<StockDelta>, QQueryOperations> deltasProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deltas');
    });
  }

  QueryBuilder<CookSession, DateTime?, QQueryOperations> fridgeExpiresAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fridgeExpiresAt');
    });
  }

  QueryBuilder<CookSession, Nutrition, QQueryOperations> perPortionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'perPortion');
    });
  }

  QueryBuilder<CookSession, int, QQueryOperations> portionsCookedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'portionsCooked');
    });
  }

  QueryBuilder<CookSession, int, QQueryOperations> portionsDiscardedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'portionsDiscarded');
    });
  }

  QueryBuilder<CookSession, int, QQueryOperations> portionsRemainingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'portionsRemaining');
    });
  }

  QueryBuilder<CookSession, int, QQueryOperations> recipeIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recipeId');
    });
  }

  QueryBuilder<CookSession, String, QQueryOperations> recipeTitleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recipeTitle');
    });
  }

  QueryBuilder<CookSession, CookStatus, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const StockDeltaSchema = Schema(
  name: r'StockDelta',
  id: -1886869021671230156,
  properties: {
    r'deducted': PropertySchema(id: 0, name: r'deducted', type: IsarType.double),
    r'ingredientId': PropertySchema(id: 1, name: r'ingredientId', type: IsarType.long),
    r'key': PropertySchema(id: 2, name: r'key', type: IsarType.string),
    r'requested': PropertySchema(id: 3, name: r'requested', type: IsarType.double),
    r'shortfall': PropertySchema(id: 4, name: r'shortfall', type: IsarType.double),
  },

  estimateSize: _stockDeltaEstimateSize,
  serialize: _stockDeltaSerialize,
  deserialize: _stockDeltaDeserialize,
  deserializeProp: _stockDeltaDeserializeProp,
);

int _stockDeltaEstimateSize(StockDelta object, List<int> offsets, Map<Type, List<int>> allOffsets) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.key.length * 3;
  return bytesCount;
}

void _stockDeltaSerialize(StockDelta object, IsarWriter writer, List<int> offsets, Map<Type, List<int>> allOffsets) {
  writer.writeDouble(offsets[0], object.deducted);
  writer.writeLong(offsets[1], object.ingredientId);
  writer.writeString(offsets[2], object.key);
  writer.writeDouble(offsets[3], object.requested);
  writer.writeDouble(offsets[4], object.shortfall);
}

StockDelta _stockDeltaDeserialize(Id id, IsarReader reader, List<int> offsets, Map<Type, List<int>> allOffsets) {
  final object = StockDelta();
  object.deducted = reader.readDouble(offsets[0]);
  object.ingredientId = reader.readLong(offsets[1]);
  object.key = reader.readString(offsets[2]);
  object.requested = reader.readDouble(offsets[3]);
  object.shortfall = reader.readDouble(offsets[4]);
  return object;
}

P _stockDeltaDeserializeProp<P>(IsarReader reader, int propertyId, int offset, Map<Type, List<int>> allOffsets) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension StockDeltaQueryFilter on QueryBuilder<StockDelta, StockDelta, QFilterCondition> {
  QueryBuilder<StockDelta, StockDelta, QAfterFilterCondition> deductedEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'deducted', value: value, epsilon: epsilon));
    });
  }

  QueryBuilder<StockDelta, StockDelta, QAfterFilterCondition> deductedGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(include: include, property: r'deducted', value: value, epsilon: epsilon),
      );
    });
  }

  QueryBuilder<StockDelta, StockDelta, QAfterFilterCondition> deductedLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'deducted', value: value, epsilon: epsilon),
      );
    });
  }

  QueryBuilder<StockDelta, StockDelta, QAfterFilterCondition> deductedBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'deducted',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<StockDelta, StockDelta, QAfterFilterCondition> ingredientIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'ingredientId', value: value));
    });
  }

  QueryBuilder<StockDelta, StockDelta, QAfterFilterCondition> ingredientIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(include: include, property: r'ingredientId', value: value),
      );
    });
  }

  QueryBuilder<StockDelta, StockDelta, QAfterFilterCondition> ingredientIdLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'ingredientId', value: value),
      );
    });
  }

  QueryBuilder<StockDelta, StockDelta, QAfterFilterCondition> ingredientIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'ingredientId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<StockDelta, StockDelta, QAfterFilterCondition> keyEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'key', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<StockDelta, StockDelta, QAfterFilterCondition> keyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(include: include, property: r'key', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<StockDelta, StockDelta, QAfterFilterCondition> keyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'key', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<StockDelta, StockDelta, QAfterFilterCondition> keyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'key',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StockDelta, StockDelta, QAfterFilterCondition> keyStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(property: r'key', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<StockDelta, StockDelta, QAfterFilterCondition> keyEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(property: r'key', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<StockDelta, StockDelta, QAfterFilterCondition> keyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(property: r'key', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<StockDelta, StockDelta, QAfterFilterCondition> keyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(property: r'key', wildcard: pattern, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<StockDelta, StockDelta, QAfterFilterCondition> keyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'key', value: ''));
    });
  }

  QueryBuilder<StockDelta, StockDelta, QAfterFilterCondition> keyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(property: r'key', value: ''));
    });
  }

  QueryBuilder<StockDelta, StockDelta, QAfterFilterCondition> requestedEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'requested', value: value, epsilon: epsilon));
    });
  }

  QueryBuilder<StockDelta, StockDelta, QAfterFilterCondition> requestedGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(include: include, property: r'requested', value: value, epsilon: epsilon),
      );
    });
  }

  QueryBuilder<StockDelta, StockDelta, QAfterFilterCondition> requestedLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'requested', value: value, epsilon: epsilon),
      );
    });
  }

  QueryBuilder<StockDelta, StockDelta, QAfterFilterCondition> requestedBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'requested',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<StockDelta, StockDelta, QAfterFilterCondition> shortfallEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'shortfall', value: value, epsilon: epsilon));
    });
  }

  QueryBuilder<StockDelta, StockDelta, QAfterFilterCondition> shortfallGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(include: include, property: r'shortfall', value: value, epsilon: epsilon),
      );
    });
  }

  QueryBuilder<StockDelta, StockDelta, QAfterFilterCondition> shortfallLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'shortfall', value: value, epsilon: epsilon),
      );
    });
  }

  QueryBuilder<StockDelta, StockDelta, QAfterFilterCondition> shortfallBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'shortfall',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }
}

extension StockDeltaQueryObject on QueryBuilder<StockDelta, StockDelta, QFilterCondition> {}
