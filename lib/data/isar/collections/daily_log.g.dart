// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_log.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDailyLogCollection on Isar {
  IsarCollection<DailyLog> get dailyLogs => this.collection();
}

const DailyLogSchema = CollectionSchema(
  name: r'DailyLog',
  id: -3995615497450705259,
  properties: {
    r'dateKey': PropertySchema(id: 0, name: r'dateKey', type: IsarType.long),
    r'foodCostMinor': PropertySchema(
      id: 1,
      name: r'foodCostMinor',
      type: IsarType.long,
    ),
    r'meals': PropertySchema(
      id: 2,
      name: r'meals',
      type: IsarType.objectList,

      target: r'MealEntry',
    ),
    r'mealsCount': PropertySchema(
      id: 3,
      name: r'mealsCount',
      type: IsarType.long,
    ),
    r'totals': PropertySchema(
      id: 4,
      name: r'totals',
      type: IsarType.object,

      target: r'Nutrition',
    ),
    r'updatedAt': PropertySchema(
      id: 5,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
  },

  estimateSize: _dailyLogEstimateSize,
  serialize: _dailyLogSerialize,
  deserialize: _dailyLogDeserialize,
  deserializeProp: _dailyLogDeserializeProp,
  idName: r'id',
  indexes: {
    r'dateKey': IndexSchema(
      id: 7975223786082927131,
      name: r'dateKey',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'dateKey',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {
    r'MealEntry': MealEntrySchema,
    r'Nutrition': NutritionSchema,
  },

  getId: _dailyLogGetId,
  getLinks: _dailyLogGetLinks,
  attach: _dailyLogAttach,
  version: '3.3.2',
);

int _dailyLogEstimateSize(
  DailyLog object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.meals.length * 3;
  {
    final offsets = allOffsets[MealEntry]!;
    for (var i = 0; i < object.meals.length; i++) {
      final value = object.meals[i];
      bytesCount += MealEntrySchema.estimateSize(value, offsets, allOffsets);
    }
  }
  bytesCount +=
      3 +
      NutritionSchema.estimateSize(
        object.totals,
        allOffsets[Nutrition]!,
        allOffsets,
      );
  return bytesCount;
}

void _dailyLogSerialize(
  DailyLog object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.dateKey);
  writer.writeLong(offsets[1], object.foodCostMinor);
  writer.writeObjectList<MealEntry>(
    offsets[2],
    allOffsets,
    MealEntrySchema.serialize,
    object.meals,
  );
  writer.writeLong(offsets[3], object.mealsCount);
  writer.writeObject<Nutrition>(
    offsets[4],
    allOffsets,
    NutritionSchema.serialize,
    object.totals,
  );
  writer.writeDateTime(offsets[5], object.updatedAt);
}

DailyLog _dailyLogDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DailyLog();
  object.dateKey = reader.readLong(offsets[0]);
  object.foodCostMinor = reader.readLong(offsets[1]);
  object.id = id;
  object.meals =
      reader.readObjectList<MealEntry>(
        offsets[2],
        MealEntrySchema.deserialize,
        allOffsets,
        MealEntry(),
      ) ??
      [];
  object.mealsCount = reader.readLong(offsets[3]);
  object.totals =
      reader.readObjectOrNull<Nutrition>(
        offsets[4],
        NutritionSchema.deserialize,
        allOffsets,
      ) ??
      Nutrition();
  object.updatedAt = reader.readDateTime(offsets[5]);
  return object;
}

P _dailyLogDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readObjectList<MealEntry>(
                offset,
                MealEntrySchema.deserialize,
                allOffsets,
                MealEntry(),
              ) ??
              [])
          as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readObjectOrNull<Nutrition>(
                offset,
                NutritionSchema.deserialize,
                allOffsets,
              ) ??
              Nutrition())
          as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _dailyLogGetId(DailyLog object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _dailyLogGetLinks(DailyLog object) {
  return [];
}

void _dailyLogAttach(IsarCollection<dynamic> col, Id id, DailyLog object) {
  object.id = id;
}

extension DailyLogByIndex on IsarCollection<DailyLog> {
  Future<DailyLog?> getByDateKey(int dateKey) {
    return getByIndex(r'dateKey', [dateKey]);
  }

  DailyLog? getByDateKeySync(int dateKey) {
    return getByIndexSync(r'dateKey', [dateKey]);
  }

  Future<bool> deleteByDateKey(int dateKey) {
    return deleteByIndex(r'dateKey', [dateKey]);
  }

  bool deleteByDateKeySync(int dateKey) {
    return deleteByIndexSync(r'dateKey', [dateKey]);
  }

  Future<List<DailyLog?>> getAllByDateKey(List<int> dateKeyValues) {
    final values = dateKeyValues.map((e) => [e]).toList();
    return getAllByIndex(r'dateKey', values);
  }

  List<DailyLog?> getAllByDateKeySync(List<int> dateKeyValues) {
    final values = dateKeyValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'dateKey', values);
  }

  Future<int> deleteAllByDateKey(List<int> dateKeyValues) {
    final values = dateKeyValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'dateKey', values);
  }

  int deleteAllByDateKeySync(List<int> dateKeyValues) {
    final values = dateKeyValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'dateKey', values);
  }

  Future<Id> putByDateKey(DailyLog object) {
    return putByIndex(r'dateKey', object);
  }

  Id putByDateKeySync(DailyLog object, {bool saveLinks = true}) {
    return putByIndexSync(r'dateKey', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByDateKey(List<DailyLog> objects) {
    return putAllByIndex(r'dateKey', objects);
  }

  List<Id> putAllByDateKeySync(
    List<DailyLog> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'dateKey', objects, saveLinks: saveLinks);
  }
}

extension DailyLogQueryWhereSort on QueryBuilder<DailyLog, DailyLog, QWhere> {
  QueryBuilder<DailyLog, DailyLog, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterWhere> anyDateKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'dateKey'),
      );
    });
  }
}

extension DailyLogQueryWhere on QueryBuilder<DailyLog, DailyLog, QWhereClause> {
  QueryBuilder<DailyLog, DailyLog, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<DailyLog, DailyLog, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterWhereClause> idBetween(
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

  QueryBuilder<DailyLog, DailyLog, QAfterWhereClause> dateKeyEqualTo(
    int dateKey,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'dateKey', value: [dateKey]),
      );
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterWhereClause> dateKeyNotEqualTo(
    int dateKey,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'dateKey',
                lower: [],
                upper: [dateKey],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'dateKey',
                lower: [dateKey],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'dateKey',
                lower: [dateKey],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'dateKey',
                lower: [],
                upper: [dateKey],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterWhereClause> dateKeyGreaterThan(
    int dateKey, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'dateKey',
          lower: [dateKey],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterWhereClause> dateKeyLessThan(
    int dateKey, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'dateKey',
          lower: [],
          upper: [dateKey],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterWhereClause> dateKeyBetween(
    int lowerDateKey,
    int upperDateKey, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'dateKey',
          lower: [lowerDateKey],
          includeLower: includeLower,
          upper: [upperDateKey],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension DailyLogQueryFilter
    on QueryBuilder<DailyLog, DailyLog, QFilterCondition> {
  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> dateKeyEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'dateKey', value: value),
      );
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> dateKeyGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'dateKey',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> dateKeyLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'dateKey',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> dateKeyBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'dateKey',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> foodCostMinorEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'foodCostMinor', value: value),
      );
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition>
  foodCostMinorGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'foodCostMinor',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> foodCostMinorLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'foodCostMinor',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> foodCostMinorBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'foodCostMinor',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> idBetween(
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

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> mealsLengthEqualTo(
    int length,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'meals', length, true, length, true);
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> mealsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'meals', 0, true, 0, true);
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> mealsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'meals', 0, false, 999999, true);
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> mealsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'meals', 0, true, length, include);
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition>
  mealsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'meals', length, include, 999999, true);
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> mealsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'meals',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> mealsCountEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'mealsCount', value: value),
      );
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> mealsCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'mealsCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> mealsCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'mealsCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> mealsCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'mealsCount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> updatedAtEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> updatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> updatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'updatedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension DailyLogQueryObject
    on QueryBuilder<DailyLog, DailyLog, QFilterCondition> {
  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> mealsElement(
    FilterQuery<MealEntry> q,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'meals');
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> totals(
    FilterQuery<Nutrition> q,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'totals');
    });
  }
}

extension DailyLogQueryLinks
    on QueryBuilder<DailyLog, DailyLog, QFilterCondition> {}

extension DailyLogQuerySortBy on QueryBuilder<DailyLog, DailyLog, QSortBy> {
  QueryBuilder<DailyLog, DailyLog, QAfterSortBy> sortByDateKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateKey', Sort.asc);
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterSortBy> sortByDateKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateKey', Sort.desc);
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterSortBy> sortByFoodCostMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'foodCostMinor', Sort.asc);
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterSortBy> sortByFoodCostMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'foodCostMinor', Sort.desc);
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterSortBy> sortByMealsCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mealsCount', Sort.asc);
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterSortBy> sortByMealsCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mealsCount', Sort.desc);
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension DailyLogQuerySortThenBy
    on QueryBuilder<DailyLog, DailyLog, QSortThenBy> {
  QueryBuilder<DailyLog, DailyLog, QAfterSortBy> thenByDateKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateKey', Sort.asc);
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterSortBy> thenByDateKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateKey', Sort.desc);
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterSortBy> thenByFoodCostMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'foodCostMinor', Sort.asc);
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterSortBy> thenByFoodCostMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'foodCostMinor', Sort.desc);
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterSortBy> thenByMealsCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mealsCount', Sort.asc);
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterSortBy> thenByMealsCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mealsCount', Sort.desc);
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension DailyLogQueryWhereDistinct
    on QueryBuilder<DailyLog, DailyLog, QDistinct> {
  QueryBuilder<DailyLog, DailyLog, QDistinct> distinctByDateKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dateKey');
    });
  }

  QueryBuilder<DailyLog, DailyLog, QDistinct> distinctByFoodCostMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'foodCostMinor');
    });
  }

  QueryBuilder<DailyLog, DailyLog, QDistinct> distinctByMealsCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mealsCount');
    });
  }

  QueryBuilder<DailyLog, DailyLog, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension DailyLogQueryProperty
    on QueryBuilder<DailyLog, DailyLog, QQueryProperty> {
  QueryBuilder<DailyLog, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DailyLog, int, QQueryOperations> dateKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dateKey');
    });
  }

  QueryBuilder<DailyLog, int, QQueryOperations> foodCostMinorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'foodCostMinor');
    });
  }

  QueryBuilder<DailyLog, List<MealEntry>, QQueryOperations> mealsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'meals');
    });
  }

  QueryBuilder<DailyLog, int, QQueryOperations> mealsCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mealsCount');
    });
  }

  QueryBuilder<DailyLog, Nutrition, QQueryOperations> totalsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totals');
    });
  }

  QueryBuilder<DailyLog, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const MealEntrySchema = Schema(
  name: r'MealEntry',
  id: 2136597722614945685,
  properties: {
    r'cookSessionId': PropertySchema(
      id: 0,
      name: r'cookSessionId',
      type: IsarType.long,
    ),
    r'costMinor': PropertySchema(
      id: 1,
      name: r'costMinor',
      type: IsarType.long,
    ),
    r'eatenAt': PropertySchema(
      id: 2,
      name: r'eatenAt',
      type: IsarType.dateTime,
    ),
    r'entryId': PropertySchema(id: 3, name: r'entryId', type: IsarType.string),
    r'ingredientKey': PropertySchema(
      id: 4,
      name: r'ingredientKey',
      type: IsarType.string,
    ),
    r'nutrition': PropertySchema(
      id: 5,
      name: r'nutrition',
      type: IsarType.object,

      target: r'Nutrition',
    ),
    r'portions': PropertySchema(
      id: 6,
      name: r'portions',
      type: IsarType.double,
    ),
    r'qtyBase': PropertySchema(id: 7, name: r'qtyBase', type: IsarType.double),
    r'recipeId': PropertySchema(id: 8, name: r'recipeId', type: IsarType.long),
    r'source': PropertySchema(
      id: 9,
      name: r'source',
      type: IsarType.string,
      enumMap: _MealEntrysourceEnumValueMap,
    ),
    r'title': PropertySchema(id: 10, name: r'title', type: IsarType.string),
  },

  estimateSize: _mealEntryEstimateSize,
  serialize: _mealEntrySerialize,
  deserialize: _mealEntryDeserialize,
  deserializeProp: _mealEntryDeserializeProp,
);

int _mealEntryEstimateSize(
  MealEntry object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.entryId.length * 3;
  {
    final value = object.ingredientKey;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount +=
      3 +
      NutritionSchema.estimateSize(
        object.nutrition,
        allOffsets[Nutrition]!,
        allOffsets,
      );
  bytesCount += 3 + object.source.name.length * 3;
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _mealEntrySerialize(
  MealEntry object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.cookSessionId);
  writer.writeLong(offsets[1], object.costMinor);
  writer.writeDateTime(offsets[2], object.eatenAt);
  writer.writeString(offsets[3], object.entryId);
  writer.writeString(offsets[4], object.ingredientKey);
  writer.writeObject<Nutrition>(
    offsets[5],
    allOffsets,
    NutritionSchema.serialize,
    object.nutrition,
  );
  writer.writeDouble(offsets[6], object.portions);
  writer.writeDouble(offsets[7], object.qtyBase);
  writer.writeLong(offsets[8], object.recipeId);
  writer.writeString(offsets[9], object.source.name);
  writer.writeString(offsets[10], object.title);
}

MealEntry _mealEntryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MealEntry();
  object.cookSessionId = reader.readLongOrNull(offsets[0]);
  object.costMinor = reader.readLong(offsets[1]);
  object.eatenAt = reader.readDateTime(offsets[2]);
  object.entryId = reader.readString(offsets[3]);
  object.ingredientKey = reader.readStringOrNull(offsets[4]);
  object.nutrition =
      reader.readObjectOrNull<Nutrition>(
        offsets[5],
        NutritionSchema.deserialize,
        allOffsets,
      ) ??
      Nutrition();
  object.portions = reader.readDouble(offsets[6]);
  object.qtyBase = reader.readDoubleOrNull(offsets[7]);
  object.recipeId = reader.readLongOrNull(offsets[8]);
  object.source =
      _MealEntrysourceValueEnumMap[reader.readStringOrNull(offsets[9])] ??
      MealSource.cookedNow;
  object.title = reader.readString(offsets[10]);
  return object;
}

P _mealEntryDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readObjectOrNull<Nutrition>(
                offset,
                NutritionSchema.deserialize,
                allOffsets,
              ) ??
              Nutrition())
          as P;
    case 6:
      return (reader.readDouble(offset)) as P;
    case 7:
      return (reader.readDoubleOrNull(offset)) as P;
    case 8:
      return (reader.readLongOrNull(offset)) as P;
    case 9:
      return (_MealEntrysourceValueEnumMap[reader.readStringOrNull(offset)] ??
              MealSource.cookedNow)
          as P;
    case 10:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _MealEntrysourceEnumValueMap = {
  r'cookedNow': r'cookedNow',
  r'fridge': r'fridge',
  r'quickAdd': r'quickAdd',
  r'pantry': r'pantry',
};
const _MealEntrysourceValueEnumMap = {
  r'cookedNow': MealSource.cookedNow,
  r'fridge': MealSource.fridge,
  r'quickAdd': MealSource.quickAdd,
  r'pantry': MealSource.pantry,
};

extension MealEntryQueryFilter
    on QueryBuilder<MealEntry, MealEntry, QFilterCondition> {
  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition>
  cookSessionIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'cookSessionId'),
      );
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition>
  cookSessionIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'cookSessionId'),
      );
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition>
  cookSessionIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'cookSessionId', value: value),
      );
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition>
  cookSessionIdGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'cookSessionId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition>
  cookSessionIdLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'cookSessionId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition>
  cookSessionIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'cookSessionId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> costMinorEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'costMinor', value: value),
      );
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition>
  costMinorGreaterThan(int value, {bool include = false}) {
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

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> costMinorLessThan(
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

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> costMinorBetween(
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

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> eatenAtEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'eatenAt', value: value),
      );
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> eatenAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'eatenAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> eatenAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'eatenAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> eatenAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'eatenAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> entryIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'entryId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> entryIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'entryId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> entryIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'entryId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> entryIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'entryId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> entryIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'entryId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> entryIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'entryId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> entryIdContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'entryId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> entryIdMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'entryId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> entryIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'entryId', value: ''),
      );
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition>
  entryIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'entryId', value: ''),
      );
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition>
  ingredientKeyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'ingredientKey'),
      );
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition>
  ingredientKeyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'ingredientKey'),
      );
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition>
  ingredientKeyEqualTo(String? value, {bool caseSensitive = true}) {
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

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition>
  ingredientKeyGreaterThan(
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

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition>
  ingredientKeyLessThan(
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

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition>
  ingredientKeyBetween(
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

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition>
  ingredientKeyStartsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition>
  ingredientKeyEndsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition>
  ingredientKeyContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition>
  ingredientKeyMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition>
  ingredientKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'ingredientKey', value: ''),
      );
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition>
  ingredientKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'ingredientKey', value: ''),
      );
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> portionsEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'portions',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> portionsGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'portions',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> portionsLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'portions',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> portionsBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'portions',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> qtyBaseIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'qtyBase'),
      );
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> qtyBaseIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'qtyBase'),
      );
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> qtyBaseEqualTo(
    double? value, {
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

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> qtyBaseGreaterThan(
    double? value, {
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

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> qtyBaseLessThan(
    double? value, {
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

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> qtyBaseBetween(
    double? lower,
    double? upper, {
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

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> recipeIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'recipeId'),
      );
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition>
  recipeIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'recipeId'),
      );
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> recipeIdEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'recipeId', value: value),
      );
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> recipeIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'recipeId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> recipeIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'recipeId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> recipeIdBetween(
    int? lower,
    int? upper, {
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

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> sourceEqualTo(
    MealSource value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'source',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> sourceGreaterThan(
    MealSource value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'source',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> sourceLessThan(
    MealSource value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'source',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> sourceBetween(
    MealSource lower,
    MealSource upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'source',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> sourceStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'source',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> sourceEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'source',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> sourceContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'source',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> sourceMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'source',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> sourceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'source', value: ''),
      );
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> sourceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'source', value: ''),
      );
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'title',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> titleContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> titleMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'title',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'title', value: ''),
      );
    });
  }
}

extension MealEntryQueryObject
    on QueryBuilder<MealEntry, MealEntry, QFilterCondition> {
  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> nutrition(
    FilterQuery<Nutrition> q,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'nutrition');
    });
  }
}
