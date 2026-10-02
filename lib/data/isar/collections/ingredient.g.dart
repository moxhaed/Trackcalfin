// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ingredient.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetIngredientCollection on Isar {
  IsarCollection<Ingredient> get ingredients => this.collection();
}

const IngredientSchema = CollectionSchema(
  name: r'Ingredient',
  id: 800151778681338436,
  properties: {
    r'aliases': PropertySchema(
      id: 0,
      name: r'aliases',
      type: IsarType.stringList,
    ),
    r'avgCostPerUnitMinor': PropertySchema(
      id: 1,
      name: r'avgCostPerUnitMinor',
      type: IsarType.double,
    ),
    r'baseUnit': PropertySchema(
      id: 2,
      name: r'baseUnit',
      type: IsarType.string,
      enumMap: _IngredientbaseUnitEnumValueMap,
    ),
    r'category': PropertySchema(
      id: 3,
      name: r'category',
      type: IsarType.string,
      enumMap: _IngredientcategoryEnumValueMap,
    ),
    r'densityGPerMl': PropertySchema(
      id: 4,
      name: r'densityGPerMl',
      type: IsarType.double,
    ),
    r'expiresAt': PropertySchema(
      id: 5,
      name: r'expiresAt',
      type: IsarType.dateTime,
    ),
    r'gramsPerPiece': PropertySchema(
      id: 6,
      name: r'gramsPerPiece',
      type: IsarType.double,
    ),
    r'key': PropertySchema(id: 7, name: r'key', type: IsarType.string),
    r'lastPurchaseQty': PropertySchema(
      id: 8,
      name: r'lastPurchaseQty',
      type: IsarType.double,
    ),
    r'lastPurchasedAt': PropertySchema(
      id: 9,
      name: r'lastPurchasedAt',
      type: IsarType.dateTime,
    ),
    r'lastVerifiedAt': PropertySchema(
      id: 10,
      name: r'lastVerifiedAt',
      type: IsarType.dateTime,
    ),
    r'lowStockThreshold': PropertySchema(
      id: 11,
      name: r'lowStockThreshold',
      type: IsarType.double,
    ),
    r'name': PropertySchema(id: 12, name: r'name', type: IsarType.string),
    r'nutritionConfirmedAt': PropertySchema(
      id: 13,
      name: r'nutritionConfirmedAt',
      type: IsarType.dateTime,
    ),
    r'nutritionSource': PropertySchema(
      id: 14,
      name: r'nutritionSource',
      type: IsarType.string,
      enumMap: _IngredientnutritionSourceEnumValueMap,
    ),
    r'per100': PropertySchema(
      id: 15,
      name: r'per100',
      type: IsarType.object,

      target: r'Nutrition',
    ),
    r'qtyOnHand': PropertySchema(
      id: 16,
      name: r'qtyOnHand',
      type: IsarType.double,
    ),
    r'shelfLifeDays': PropertySchema(
      id: 17,
      name: r'shelfLifeDays',
      type: IsarType.long,
    ),
    r'trackingMode': PropertySchema(
      id: 18,
      name: r'trackingMode',
      type: IsarType.string,
      enumMap: _IngredienttrackingModeEnumValueMap,
    ),
    r'updatedAt': PropertySchema(
      id: 19,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
  },

  estimateSize: _ingredientEstimateSize,
  serialize: _ingredientSerialize,
  deserialize: _ingredientDeserialize,
  deserializeProp: _ingredientDeserializeProp,
  idName: r'id',
  indexes: {
    r'key': IndexSchema(
      id: -4906094122524121629,
      name: r'key',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'key',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'aliases': IndexSchema(
      id: 7903086418021463659,
      name: r'aliases',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'aliases',
          type: IndexType.hashElements,
          caseSensitive: true,
        ),
      ],
    ),
    r'expiresAt': IndexSchema(
      id: 4994901953235663716,
      name: r'expiresAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'expiresAt',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {r'Nutrition': NutritionSchema},

  getId: _ingredientGetId,
  getLinks: _ingredientGetLinks,
  attach: _ingredientAttach,
  version: '3.3.2',
);

int _ingredientEstimateSize(
  Ingredient object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.aliases.length * 3;
  {
    for (var i = 0; i < object.aliases.length; i++) {
      final value = object.aliases[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.baseUnit.name.length * 3;
  bytesCount += 3 + object.category.name.length * 3;
  bytesCount += 3 + object.key.length * 3;
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.nutritionSource.name.length * 3;
  bytesCount +=
      3 +
      NutritionSchema.estimateSize(
        object.per100,
        allOffsets[Nutrition]!,
        allOffsets,
      );
  bytesCount += 3 + object.trackingMode.name.length * 3;
  return bytesCount;
}

void _ingredientSerialize(
  Ingredient object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeStringList(offsets[0], object.aliases);
  writer.writeDouble(offsets[1], object.avgCostPerUnitMinor);
  writer.writeString(offsets[2], object.baseUnit.name);
  writer.writeString(offsets[3], object.category.name);
  writer.writeDouble(offsets[4], object.densityGPerMl);
  writer.writeDateTime(offsets[5], object.expiresAt);
  writer.writeDouble(offsets[6], object.gramsPerPiece);
  writer.writeString(offsets[7], object.key);
  writer.writeDouble(offsets[8], object.lastPurchaseQty);
  writer.writeDateTime(offsets[9], object.lastPurchasedAt);
  writer.writeDateTime(offsets[10], object.lastVerifiedAt);
  writer.writeDouble(offsets[11], object.lowStockThreshold);
  writer.writeString(offsets[12], object.name);
  writer.writeDateTime(offsets[13], object.nutritionConfirmedAt);
  writer.writeString(offsets[14], object.nutritionSource.name);
  writer.writeObject<Nutrition>(
    offsets[15],
    allOffsets,
    NutritionSchema.serialize,
    object.per100,
  );
  writer.writeDouble(offsets[16], object.qtyOnHand);
  writer.writeLong(offsets[17], object.shelfLifeDays);
  writer.writeString(offsets[18], object.trackingMode.name);
  writer.writeDateTime(offsets[19], object.updatedAt);
}

Ingredient _ingredientDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Ingredient();
  object.aliases = reader.readStringList(offsets[0]) ?? [];
  object.avgCostPerUnitMinor = reader.readDouble(offsets[1]);
  object.baseUnit =
      _IngredientbaseUnitValueEnumMap[reader.readStringOrNull(offsets[2])] ??
      BaseUnit.g;
  object.category =
      _IngredientcategoryValueEnumMap[reader.readStringOrNull(offsets[3])] ??
      IngredientCategory.produce;
  object.densityGPerMl = reader.readDoubleOrNull(offsets[4]);
  object.expiresAt = reader.readDateTimeOrNull(offsets[5]);
  object.gramsPerPiece = reader.readDoubleOrNull(offsets[6]);
  object.id = id;
  object.key = reader.readString(offsets[7]);
  object.lastPurchaseQty = reader.readDouble(offsets[8]);
  object.lastPurchasedAt = reader.readDateTimeOrNull(offsets[9]);
  object.lastVerifiedAt = reader.readDateTimeOrNull(offsets[10]);
  object.lowStockThreshold = reader.readDouble(offsets[11]);
  object.name = reader.readString(offsets[12]);
  object.nutritionConfirmedAt = reader.readDateTimeOrNull(offsets[13]);
  object.nutritionSource =
      _IngredientnutritionSourceValueEnumMap[reader.readStringOrNull(
        offsets[14],
      )] ??
      DataSource.none;
  object.per100 =
      reader.readObjectOrNull<Nutrition>(
        offsets[15],
        NutritionSchema.deserialize,
        allOffsets,
      ) ??
      Nutrition();
  object.qtyOnHand = reader.readDouble(offsets[16]);
  object.shelfLifeDays = reader.readLong(offsets[17]);
  object.trackingMode =
      _IngredienttrackingModeValueEnumMap[reader.readStringOrNull(
        offsets[18],
      )] ??
      TrackingMode.exact;
  object.updatedAt = reader.readDateTime(offsets[19]);
  return object;
}

P _ingredientDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringList(offset) ?? []) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (_IngredientbaseUnitValueEnumMap[reader.readStringOrNull(
                offset,
              )] ??
              BaseUnit.g)
          as P;
    case 3:
      return (_IngredientcategoryValueEnumMap[reader.readStringOrNull(
                offset,
              )] ??
              IngredientCategory.produce)
          as P;
    case 4:
      return (reader.readDoubleOrNull(offset)) as P;
    case 5:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 6:
      return (reader.readDoubleOrNull(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readDouble(offset)) as P;
    case 9:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 10:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 11:
      return (reader.readDouble(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 14:
      return (_IngredientnutritionSourceValueEnumMap[reader.readStringOrNull(
                offset,
              )] ??
              DataSource.none)
          as P;
    case 15:
      return (reader.readObjectOrNull<Nutrition>(
                offset,
                NutritionSchema.deserialize,
                allOffsets,
              ) ??
              Nutrition())
          as P;
    case 16:
      return (reader.readDouble(offset)) as P;
    case 17:
      return (reader.readLong(offset)) as P;
    case 18:
      return (_IngredienttrackingModeValueEnumMap[reader.readStringOrNull(
                offset,
              )] ??
              TrackingMode.exact)
          as P;
    case 19:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _IngredientbaseUnitEnumValueMap = {
  r'g': r'g',
  r'ml': r'ml',
  r'pc': r'pc',
};
const _IngredientbaseUnitValueEnumMap = {
  r'g': BaseUnit.g,
  r'ml': BaseUnit.ml,
  r'pc': BaseUnit.pc,
};
const _IngredientcategoryEnumValueMap = {
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
const _IngredientcategoryValueEnumMap = {
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
const _IngredientnutritionSourceEnumValueMap = {
  r'none': r'none',
  r'aiEstimate': r'aiEstimate',
  r'user': r'user',
  r'label': r'label',
};
const _IngredientnutritionSourceValueEnumMap = {
  r'none': DataSource.none,
  r'aiEstimate': DataSource.aiEstimate,
  r'user': DataSource.user,
  r'label': DataSource.label,
};
const _IngredienttrackingModeEnumValueMap = {
  r'exact': r'exact',
  r'staple': r'staple',
};
const _IngredienttrackingModeValueEnumMap = {
  r'exact': TrackingMode.exact,
  r'staple': TrackingMode.staple,
};

Id _ingredientGetId(Ingredient object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _ingredientGetLinks(Ingredient object) {
  return [];
}

void _ingredientAttach(IsarCollection<dynamic> col, Id id, Ingredient object) {
  object.id = id;
}

extension IngredientByIndex on IsarCollection<Ingredient> {
  Future<Ingredient?> getByKey(String key) {
    return getByIndex(r'key', [key]);
  }

  Ingredient? getByKeySync(String key) {
    return getByIndexSync(r'key', [key]);
  }

  Future<bool> deleteByKey(String key) {
    return deleteByIndex(r'key', [key]);
  }

  bool deleteByKeySync(String key) {
    return deleteByIndexSync(r'key', [key]);
  }

  Future<List<Ingredient?>> getAllByKey(List<String> keyValues) {
    final values = keyValues.map((e) => [e]).toList();
    return getAllByIndex(r'key', values);
  }

  List<Ingredient?> getAllByKeySync(List<String> keyValues) {
    final values = keyValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'key', values);
  }

  Future<int> deleteAllByKey(List<String> keyValues) {
    final values = keyValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'key', values);
  }

  int deleteAllByKeySync(List<String> keyValues) {
    final values = keyValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'key', values);
  }

  Future<Id> putByKey(Ingredient object) {
    return putByIndex(r'key', object);
  }

  Id putByKeySync(Ingredient object, {bool saveLinks = true}) {
    return putByIndexSync(r'key', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByKey(List<Ingredient> objects) {
    return putAllByIndex(r'key', objects);
  }

  List<Id> putAllByKeySync(List<Ingredient> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'key', objects, saveLinks: saveLinks);
  }
}

extension IngredientQueryWhereSort
    on QueryBuilder<Ingredient, Ingredient, QWhere> {
  QueryBuilder<Ingredient, Ingredient, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterWhere> anyExpiresAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'expiresAt'),
      );
    });
  }
}

extension IngredientQueryWhere
    on QueryBuilder<Ingredient, Ingredient, QWhereClause> {
  QueryBuilder<Ingredient, Ingredient, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Ingredient, Ingredient, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterWhereClause> idBetween(
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

  QueryBuilder<Ingredient, Ingredient, QAfterWhereClause> keyEqualTo(
    String key,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'key', value: [key]),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterWhereClause> keyNotEqualTo(
    String key,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'key',
                lower: [],
                upper: [key],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'key',
                lower: [key],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'key',
                lower: [key],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'key',
                lower: [],
                upper: [key],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterWhereClause> aliasesElementEqualTo(
    String aliasesElement,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'aliases',
          value: [aliasesElement],
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterWhereClause>
  aliasesElementNotEqualTo(String aliasesElement) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'aliases',
                lower: [],
                upper: [aliasesElement],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'aliases',
                lower: [aliasesElement],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'aliases',
                lower: [aliasesElement],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'aliases',
                lower: [],
                upper: [aliasesElement],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterWhereClause> expiresAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'expiresAt', value: [null]),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterWhereClause> expiresAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'expiresAt',
          lower: [null],
          includeLower: false,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterWhereClause> expiresAtEqualTo(
    DateTime? expiresAt,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'expiresAt', value: [expiresAt]),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterWhereClause> expiresAtNotEqualTo(
    DateTime? expiresAt,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'expiresAt',
                lower: [],
                upper: [expiresAt],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'expiresAt',
                lower: [expiresAt],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'expiresAt',
                lower: [expiresAt],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'expiresAt',
                lower: [],
                upper: [expiresAt],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterWhereClause> expiresAtGreaterThan(
    DateTime? expiresAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'expiresAt',
          lower: [expiresAt],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterWhereClause> expiresAtLessThan(
    DateTime? expiresAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'expiresAt',
          lower: [],
          upper: [expiresAt],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterWhereClause> expiresAtBetween(
    DateTime? lowerExpiresAt,
    DateTime? upperExpiresAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'expiresAt',
          lower: [lowerExpiresAt],
          includeLower: includeLower,
          upper: [upperExpiresAt],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension IngredientQueryFilter
    on QueryBuilder<Ingredient, Ingredient, QFilterCondition> {
  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  aliasesElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'aliases',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  aliasesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'aliases',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  aliasesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'aliases',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  aliasesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'aliases',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  aliasesElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'aliases',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  aliasesElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'aliases',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  aliasesElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'aliases',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  aliasesElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'aliases',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  aliasesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'aliases', value: ''),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  aliasesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'aliases', value: ''),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  aliasesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'aliases', length, true, length, true);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> aliasesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'aliases', 0, true, 0, true);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  aliasesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'aliases', 0, false, 999999, true);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  aliasesLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'aliases', 0, true, length, include);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  aliasesLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'aliases', length, include, 999999, true);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  aliasesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'aliases',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  avgCostPerUnitMinorEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'avgCostPerUnitMinor',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  avgCostPerUnitMinorGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'avgCostPerUnitMinor',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  avgCostPerUnitMinorLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'avgCostPerUnitMinor',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  avgCostPerUnitMinorBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'avgCostPerUnitMinor',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> baseUnitEqualTo(
    BaseUnit value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'baseUnit',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  baseUnitGreaterThan(
    BaseUnit value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'baseUnit',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> baseUnitLessThan(
    BaseUnit value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'baseUnit',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> baseUnitBetween(
    BaseUnit lower,
    BaseUnit upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'baseUnit',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  baseUnitStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'baseUnit',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> baseUnitEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'baseUnit',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> baseUnitContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'baseUnit',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> baseUnitMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'baseUnit',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  baseUnitIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'baseUnit', value: ''),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  baseUnitIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'baseUnit', value: ''),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> categoryEqualTo(
    IngredientCategory value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'category',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  categoryGreaterThan(
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

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> categoryLessThan(
    IngredientCategory value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'category',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> categoryBetween(
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

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  categoryStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'category',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> categoryEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'category',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> categoryContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'category',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> categoryMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'category',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  categoryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'category', value: ''),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  categoryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'category', value: ''),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  densityGPerMlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'densityGPerMl'),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  densityGPerMlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'densityGPerMl'),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  densityGPerMlEqualTo(double? value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'densityGPerMl',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  densityGPerMlGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'densityGPerMl',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  densityGPerMlLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'densityGPerMl',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  densityGPerMlBetween(
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

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  expiresAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'expiresAt'),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  expiresAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'expiresAt'),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> expiresAtEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'expiresAt', value: value),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  expiresAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'expiresAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> expiresAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'expiresAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> expiresAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'expiresAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  gramsPerPieceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'gramsPerPiece'),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  gramsPerPieceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'gramsPerPiece'),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  gramsPerPieceEqualTo(double? value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'gramsPerPiece',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  gramsPerPieceGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'gramsPerPiece',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  gramsPerPieceLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'gramsPerPiece',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  gramsPerPieceBetween(
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

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> idBetween(
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

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> keyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'key',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> keyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'key',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> keyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'key',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> keyBetween(
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

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> keyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'key',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> keyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'key',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> keyContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'key',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> keyMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'key',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> keyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'key', value: ''),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> keyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'key', value: ''),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  lastPurchaseQtyEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'lastPurchaseQty',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  lastPurchaseQtyGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastPurchaseQty',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  lastPurchaseQtyLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastPurchaseQty',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  lastPurchaseQtyBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastPurchaseQty',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  lastPurchasedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastPurchasedAt'),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  lastPurchasedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastPurchasedAt'),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  lastPurchasedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastPurchasedAt', value: value),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  lastPurchasedAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastPurchasedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  lastPurchasedAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastPurchasedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  lastPurchasedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastPurchasedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  lastVerifiedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastVerifiedAt'),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  lastVerifiedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastVerifiedAt'),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  lastVerifiedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastVerifiedAt', value: value),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  lastVerifiedAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastVerifiedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  lastVerifiedAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastVerifiedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  lastVerifiedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastVerifiedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  lowStockThresholdEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'lowStockThreshold',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  lowStockThresholdGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lowStockThreshold',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  lowStockThresholdLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lowStockThreshold',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  lowStockThresholdBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lowStockThreshold',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> nameEqualTo(
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

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> nameGreaterThan(
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

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> nameLessThan(
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

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> nameBetween(
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

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> nameStartsWith(
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

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> nameEndsWith(
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

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> nameContains(
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

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> nameMatches(
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

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  nutritionConfirmedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'nutritionConfirmedAt'),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  nutritionConfirmedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'nutritionConfirmedAt'),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  nutritionConfirmedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'nutritionConfirmedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  nutritionConfirmedAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'nutritionConfirmedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  nutritionConfirmedAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'nutritionConfirmedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  nutritionConfirmedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'nutritionConfirmedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  nutritionSourceEqualTo(DataSource value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'nutritionSource',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  nutritionSourceGreaterThan(
    DataSource value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'nutritionSource',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  nutritionSourceLessThan(
    DataSource value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'nutritionSource',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  nutritionSourceBetween(
    DataSource lower,
    DataSource upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'nutritionSource',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  nutritionSourceStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'nutritionSource',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  nutritionSourceEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'nutritionSource',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  nutritionSourceContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'nutritionSource',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  nutritionSourceMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'nutritionSource',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  nutritionSourceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'nutritionSource', value: ''),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  nutritionSourceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'nutritionSource', value: ''),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> qtyOnHandEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'qtyOnHand',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  qtyOnHandGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'qtyOnHand',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> qtyOnHandLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'qtyOnHand',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> qtyOnHandBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'qtyOnHand',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  shelfLifeDaysEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'shelfLifeDays', value: value),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  shelfLifeDaysGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'shelfLifeDays',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  shelfLifeDaysLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'shelfLifeDays',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  shelfLifeDaysBetween(
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

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  trackingModeEqualTo(TrackingMode value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'trackingMode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  trackingModeGreaterThan(
    TrackingMode value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'trackingMode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  trackingModeLessThan(
    TrackingMode value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'trackingMode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  trackingModeBetween(
    TrackingMode lower,
    TrackingMode upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'trackingMode',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  trackingModeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'trackingMode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  trackingModeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'trackingMode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  trackingModeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'trackingMode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  trackingModeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'trackingMode',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  trackingModeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'trackingMode', value: ''),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  trackingModeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'trackingMode', value: ''),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> updatedAtEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition>
  updatedAtGreaterThan(DateTime value, {bool include = false}) {
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

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> updatedAtLessThan(
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

  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> updatedAtBetween(
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

extension IngredientQueryObject
    on QueryBuilder<Ingredient, Ingredient, QFilterCondition> {
  QueryBuilder<Ingredient, Ingredient, QAfterFilterCondition> per100(
    FilterQuery<Nutrition> q,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'per100');
    });
  }
}

extension IngredientQueryLinks
    on QueryBuilder<Ingredient, Ingredient, QFilterCondition> {}

extension IngredientQuerySortBy
    on QueryBuilder<Ingredient, Ingredient, QSortBy> {
  QueryBuilder<Ingredient, Ingredient, QAfterSortBy>
  sortByAvgCostPerUnitMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgCostPerUnitMinor', Sort.asc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy>
  sortByAvgCostPerUnitMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgCostPerUnitMinor', Sort.desc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> sortByBaseUnit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseUnit', Sort.asc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> sortByBaseUnitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseUnit', Sort.desc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> sortByCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.asc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> sortByCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.desc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> sortByDensityGPerMl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'densityGPerMl', Sort.asc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> sortByDensityGPerMlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'densityGPerMl', Sort.desc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> sortByExpiresAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiresAt', Sort.asc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> sortByExpiresAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiresAt', Sort.desc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> sortByGramsPerPiece() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gramsPerPiece', Sort.asc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> sortByGramsPerPieceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gramsPerPiece', Sort.desc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> sortByKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.asc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> sortByKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.desc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> sortByLastPurchaseQty() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPurchaseQty', Sort.asc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy>
  sortByLastPurchaseQtyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPurchaseQty', Sort.desc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> sortByLastPurchasedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPurchasedAt', Sort.asc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy>
  sortByLastPurchasedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPurchasedAt', Sort.desc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> sortByLastVerifiedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastVerifiedAt', Sort.asc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy>
  sortByLastVerifiedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastVerifiedAt', Sort.desc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> sortByLowStockThreshold() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lowStockThreshold', Sort.asc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy>
  sortByLowStockThresholdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lowStockThreshold', Sort.desc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy>
  sortByNutritionConfirmedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nutritionConfirmedAt', Sort.asc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy>
  sortByNutritionConfirmedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nutritionConfirmedAt', Sort.desc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> sortByNutritionSource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nutritionSource', Sort.asc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy>
  sortByNutritionSourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nutritionSource', Sort.desc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> sortByQtyOnHand() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qtyOnHand', Sort.asc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> sortByQtyOnHandDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qtyOnHand', Sort.desc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> sortByShelfLifeDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shelfLifeDays', Sort.asc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> sortByShelfLifeDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shelfLifeDays', Sort.desc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> sortByTrackingMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackingMode', Sort.asc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> sortByTrackingModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackingMode', Sort.desc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension IngredientQuerySortThenBy
    on QueryBuilder<Ingredient, Ingredient, QSortThenBy> {
  QueryBuilder<Ingredient, Ingredient, QAfterSortBy>
  thenByAvgCostPerUnitMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgCostPerUnitMinor', Sort.asc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy>
  thenByAvgCostPerUnitMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgCostPerUnitMinor', Sort.desc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> thenByBaseUnit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseUnit', Sort.asc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> thenByBaseUnitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseUnit', Sort.desc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> thenByCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.asc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> thenByCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.desc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> thenByDensityGPerMl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'densityGPerMl', Sort.asc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> thenByDensityGPerMlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'densityGPerMl', Sort.desc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> thenByExpiresAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiresAt', Sort.asc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> thenByExpiresAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiresAt', Sort.desc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> thenByGramsPerPiece() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gramsPerPiece', Sort.asc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> thenByGramsPerPieceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gramsPerPiece', Sort.desc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> thenByKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.asc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> thenByKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.desc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> thenByLastPurchaseQty() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPurchaseQty', Sort.asc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy>
  thenByLastPurchaseQtyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPurchaseQty', Sort.desc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> thenByLastPurchasedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPurchasedAt', Sort.asc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy>
  thenByLastPurchasedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPurchasedAt', Sort.desc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> thenByLastVerifiedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastVerifiedAt', Sort.asc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy>
  thenByLastVerifiedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastVerifiedAt', Sort.desc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> thenByLowStockThreshold() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lowStockThreshold', Sort.asc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy>
  thenByLowStockThresholdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lowStockThreshold', Sort.desc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy>
  thenByNutritionConfirmedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nutritionConfirmedAt', Sort.asc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy>
  thenByNutritionConfirmedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nutritionConfirmedAt', Sort.desc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> thenByNutritionSource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nutritionSource', Sort.asc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy>
  thenByNutritionSourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nutritionSource', Sort.desc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> thenByQtyOnHand() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qtyOnHand', Sort.asc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> thenByQtyOnHandDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qtyOnHand', Sort.desc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> thenByShelfLifeDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shelfLifeDays', Sort.asc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> thenByShelfLifeDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shelfLifeDays', Sort.desc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> thenByTrackingMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackingMode', Sort.asc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> thenByTrackingModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackingMode', Sort.desc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension IngredientQueryWhereDistinct
    on QueryBuilder<Ingredient, Ingredient, QDistinct> {
  QueryBuilder<Ingredient, Ingredient, QDistinct> distinctByAliases() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'aliases');
    });
  }

  QueryBuilder<Ingredient, Ingredient, QDistinct>
  distinctByAvgCostPerUnitMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'avgCostPerUnitMinor');
    });
  }

  QueryBuilder<Ingredient, Ingredient, QDistinct> distinctByBaseUnit({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'baseUnit', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QDistinct> distinctByCategory({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'category', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QDistinct> distinctByDensityGPerMl() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'densityGPerMl');
    });
  }

  QueryBuilder<Ingredient, Ingredient, QDistinct> distinctByExpiresAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'expiresAt');
    });
  }

  QueryBuilder<Ingredient, Ingredient, QDistinct> distinctByGramsPerPiece() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'gramsPerPiece');
    });
  }

  QueryBuilder<Ingredient, Ingredient, QDistinct> distinctByKey({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'key', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QDistinct> distinctByLastPurchaseQty() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastPurchaseQty');
    });
  }

  QueryBuilder<Ingredient, Ingredient, QDistinct> distinctByLastPurchasedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastPurchasedAt');
    });
  }

  QueryBuilder<Ingredient, Ingredient, QDistinct> distinctByLastVerifiedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastVerifiedAt');
    });
  }

  QueryBuilder<Ingredient, Ingredient, QDistinct>
  distinctByLowStockThreshold() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lowStockThreshold');
    });
  }

  QueryBuilder<Ingredient, Ingredient, QDistinct> distinctByName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QDistinct>
  distinctByNutritionConfirmedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nutritionConfirmedAt');
    });
  }

  QueryBuilder<Ingredient, Ingredient, QDistinct> distinctByNutritionSource({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'nutritionSource',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<Ingredient, Ingredient, QDistinct> distinctByQtyOnHand() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'qtyOnHand');
    });
  }

  QueryBuilder<Ingredient, Ingredient, QDistinct> distinctByShelfLifeDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'shelfLifeDays');
    });
  }

  QueryBuilder<Ingredient, Ingredient, QDistinct> distinctByTrackingMode({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'trackingMode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Ingredient, Ingredient, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension IngredientQueryProperty
    on QueryBuilder<Ingredient, Ingredient, QQueryProperty> {
  QueryBuilder<Ingredient, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Ingredient, List<String>, QQueryOperations> aliasesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'aliases');
    });
  }

  QueryBuilder<Ingredient, double, QQueryOperations>
  avgCostPerUnitMinorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'avgCostPerUnitMinor');
    });
  }

  QueryBuilder<Ingredient, BaseUnit, QQueryOperations> baseUnitProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'baseUnit');
    });
  }

  QueryBuilder<Ingredient, IngredientCategory, QQueryOperations>
  categoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'category');
    });
  }

  QueryBuilder<Ingredient, double?, QQueryOperations> densityGPerMlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'densityGPerMl');
    });
  }

  QueryBuilder<Ingredient, DateTime?, QQueryOperations> expiresAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'expiresAt');
    });
  }

  QueryBuilder<Ingredient, double?, QQueryOperations> gramsPerPieceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'gramsPerPiece');
    });
  }

  QueryBuilder<Ingredient, String, QQueryOperations> keyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'key');
    });
  }

  QueryBuilder<Ingredient, double, QQueryOperations> lastPurchaseQtyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastPurchaseQty');
    });
  }

  QueryBuilder<Ingredient, DateTime?, QQueryOperations>
  lastPurchasedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastPurchasedAt');
    });
  }

  QueryBuilder<Ingredient, DateTime?, QQueryOperations>
  lastVerifiedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastVerifiedAt');
    });
  }

  QueryBuilder<Ingredient, double, QQueryOperations>
  lowStockThresholdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lowStockThreshold');
    });
  }

  QueryBuilder<Ingredient, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<Ingredient, DateTime?, QQueryOperations>
  nutritionConfirmedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nutritionConfirmedAt');
    });
  }

  QueryBuilder<Ingredient, DataSource, QQueryOperations>
  nutritionSourceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nutritionSource');
    });
  }

  QueryBuilder<Ingredient, Nutrition, QQueryOperations> per100Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'per100');
    });
  }

  QueryBuilder<Ingredient, double, QQueryOperations> qtyOnHandProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'qtyOnHand');
    });
  }

  QueryBuilder<Ingredient, int, QQueryOperations> shelfLifeDaysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'shelfLifeDays');
    });
  }

  QueryBuilder<Ingredient, TrackingMode, QQueryOperations>
  trackingModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'trackingMode');
    });
  }

  QueryBuilder<Ingredient, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
