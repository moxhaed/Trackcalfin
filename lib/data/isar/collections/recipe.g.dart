// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetRecipeCollection on Isar {
  IsarCollection<Recipe> get recipes => this.collection();
}

const RecipeSchema = CollectionSchema(
  name: r'Recipe',
  id: 8054415271972849591,
  properties: {
    r'activeMinutes': PropertySchema(
      id: 0,
      name: r'activeMinutes',
      type: IsarType.long,
    ),
    r'aiCostPerPortionMinor': PropertySchema(
      id: 1,
      name: r'aiCostPerPortionMinor',
      type: IsarType.long,
    ),
    r'aiPerPortion': PropertySchema(
      id: 2,
      name: r'aiPerPortion',
      type: IsarType.object,

      target: r'Nutrition',
    ),
    r'cookMinutes': PropertySchema(
      id: 3,
      name: r'cookMinutes',
      type: IsarType.long,
    ),
    r'costPerPortionMinor': PropertySchema(
      id: 4,
      name: r'costPerPortionMinor',
      type: IsarType.long,
    ),
    r'createdAt': PropertySchema(
      id: 5,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'cuisine': PropertySchema(id: 6, name: r'cuisine', type: IsarType.string),
    r'defaultPortions': PropertySchema(
      id: 7,
      name: r'defaultPortions',
      type: IsarType.long,
    ),
    r'favorite': PropertySchema(id: 8, name: r'favorite', type: IsarType.bool),
    r'feasibilityStatus': PropertySchema(
      id: 9,
      name: r'feasibilityStatus',
      type: IsarType.string,
    ),
    r'fridgeLifeDays': PropertySchema(
      id: 10,
      name: r'fridgeLifeDays',
      type: IsarType.long,
    ),
    r'hook': PropertySchema(id: 11, name: r'hook', type: IsarType.string),
    r'ingredients': PropertySchema(
      id: 12,
      name: r'ingredients',
      type: IsarType.objectList,

      target: r'RecipeIngredient',
    ),
    r'lastCookedAt': PropertySchema(
      id: 13,
      name: r'lastCookedAt',
      type: IsarType.dateTime,
    ),
    r'lastPortionsCooked': PropertySchema(
      id: 14,
      name: r'lastPortionsCooked',
      type: IsarType.long,
    ),
    r'omitted': PropertySchema(
      id: 15,
      name: r'omitted',
      type: IsarType.stringList,
    ),
    r'origin': PropertySchema(
      id: 16,
      name: r'origin',
      type: IsarType.string,
      enumMap: _RecipeoriginEnumValueMap,
    ),
    r'perPortion': PropertySchema(
      id: 17,
      name: r'perPortion',
      type: IsarType.object,

      target: r'Nutrition',
    ),
    r'prepMinutes': PropertySchema(
      id: 18,
      name: r'prepMinutes',
      type: IsarType.long,
    ),
    r'promptVersion': PropertySchema(
      id: 19,
      name: r'promptVersion',
      type: IsarType.string,
    ),
    r'shoppingList': PropertySchema(
      id: 20,
      name: r'shoppingList',
      type: IsarType.objectList,

      target: r'ShoppingItem',
    ),
    r'sourceQuery': PropertySchema(
      id: 21,
      name: r'sourceQuery',
      type: IsarType.string,
    ),
    r'status': PropertySchema(
      id: 22,
      name: r'status',
      type: IsarType.string,
      enumMap: _RecipestatusEnumValueMap,
    ),
    r'steps': PropertySchema(id: 23, name: r'steps', type: IsarType.stringList),
    r'suggestedForDateKey': PropertySchema(
      id: 24,
      name: r'suggestedForDateKey',
      type: IsarType.long,
    ),
    r'summary': PropertySchema(id: 25, name: r'summary', type: IsarType.string),
    r'tags': PropertySchema(id: 26, name: r'tags', type: IsarType.stringList),
    r'timesCooked': PropertySchema(
      id: 27,
      name: r'timesCooked',
      type: IsarType.long,
    ),
    r'title': PropertySchema(id: 28, name: r'title', type: IsarType.string),
    r'validationFlags': PropertySchema(
      id: 29,
      name: r'validationFlags',
      type: IsarType.stringList,
    ),
    r'why': PropertySchema(id: 30, name: r'why', type: IsarType.string),
  },

  estimateSize: _recipeEstimateSize,
  serialize: _recipeSerialize,
  deserialize: _recipeDeserialize,
  deserializeProp: _recipeDeserializeProp,
  idName: r'id',
  indexes: {
    r'status': IndexSchema(
      id: -107785170620420283,
      name: r'status',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'status',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'suggestedForDateKey': IndexSchema(
      id: -6830016431741380528,
      name: r'suggestedForDateKey',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'suggestedForDateKey',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
    r'favorite': IndexSchema(
      id: 4264748667377999100,
      name: r'favorite',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'favorite',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {
    r'RecipeIngredient': RecipeIngredientSchema,
    r'Nutrition': NutritionSchema,
    r'ShoppingItem': ShoppingItemSchema,
  },

  getId: _recipeGetId,
  getLinks: _recipeGetLinks,
  attach: _recipeAttach,
  version: '3.3.2',
);

int _recipeEstimateSize(
  Recipe object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.aiPerPortion;
    if (value != null) {
      bytesCount +=
          3 +
          NutritionSchema.estimateSize(
            value,
            allOffsets[Nutrition]!,
            allOffsets,
          );
    }
  }
  bytesCount += 3 + object.cuisine.length * 3;
  {
    final value = object.feasibilityStatus;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.hook.length * 3;
  bytesCount += 3 + object.ingredients.length * 3;
  {
    final offsets = allOffsets[RecipeIngredient]!;
    for (var i = 0; i < object.ingredients.length; i++) {
      final value = object.ingredients[i];
      bytesCount += RecipeIngredientSchema.estimateSize(
        value,
        offsets,
        allOffsets,
      );
    }
  }
  bytesCount += 3 + object.omitted.length * 3;
  {
    for (var i = 0; i < object.omitted.length; i++) {
      final value = object.omitted[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.origin.name.length * 3;
  bytesCount +=
      3 +
      NutritionSchema.estimateSize(
        object.perPortion,
        allOffsets[Nutrition]!,
        allOffsets,
      );
  {
    final value = object.promptVersion;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.shoppingList.length * 3;
  {
    final offsets = allOffsets[ShoppingItem]!;
    for (var i = 0; i < object.shoppingList.length; i++) {
      final value = object.shoppingList[i];
      bytesCount += ShoppingItemSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  {
    final value = object.sourceQuery;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.status.name.length * 3;
  bytesCount += 3 + object.steps.length * 3;
  {
    for (var i = 0; i < object.steps.length; i++) {
      final value = object.steps[i];
      bytesCount += value.length * 3;
    }
  }
  {
    final value = object.summary;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.tags.length * 3;
  {
    for (var i = 0; i < object.tags.length; i++) {
      final value = object.tags[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.title.length * 3;
  bytesCount += 3 + object.validationFlags.length * 3;
  {
    for (var i = 0; i < object.validationFlags.length; i++) {
      final value = object.validationFlags[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.why.length * 3;
  return bytesCount;
}

void _recipeSerialize(
  Recipe object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.activeMinutes);
  writer.writeLong(offsets[1], object.aiCostPerPortionMinor);
  writer.writeObject<Nutrition>(
    offsets[2],
    allOffsets,
    NutritionSchema.serialize,
    object.aiPerPortion,
  );
  writer.writeLong(offsets[3], object.cookMinutes);
  writer.writeLong(offsets[4], object.costPerPortionMinor);
  writer.writeDateTime(offsets[5], object.createdAt);
  writer.writeString(offsets[6], object.cuisine);
  writer.writeLong(offsets[7], object.defaultPortions);
  writer.writeBool(offsets[8], object.favorite);
  writer.writeString(offsets[9], object.feasibilityStatus);
  writer.writeLong(offsets[10], object.fridgeLifeDays);
  writer.writeString(offsets[11], object.hook);
  writer.writeObjectList<RecipeIngredient>(
    offsets[12],
    allOffsets,
    RecipeIngredientSchema.serialize,
    object.ingredients,
  );
  writer.writeDateTime(offsets[13], object.lastCookedAt);
  writer.writeLong(offsets[14], object.lastPortionsCooked);
  writer.writeStringList(offsets[15], object.omitted);
  writer.writeString(offsets[16], object.origin.name);
  writer.writeObject<Nutrition>(
    offsets[17],
    allOffsets,
    NutritionSchema.serialize,
    object.perPortion,
  );
  writer.writeLong(offsets[18], object.prepMinutes);
  writer.writeString(offsets[19], object.promptVersion);
  writer.writeObjectList<ShoppingItem>(
    offsets[20],
    allOffsets,
    ShoppingItemSchema.serialize,
    object.shoppingList,
  );
  writer.writeString(offsets[21], object.sourceQuery);
  writer.writeString(offsets[22], object.status.name);
  writer.writeStringList(offsets[23], object.steps);
  writer.writeLong(offsets[24], object.suggestedForDateKey);
  writer.writeString(offsets[25], object.summary);
  writer.writeStringList(offsets[26], object.tags);
  writer.writeLong(offsets[27], object.timesCooked);
  writer.writeString(offsets[28], object.title);
  writer.writeStringList(offsets[29], object.validationFlags);
  writer.writeString(offsets[30], object.why);
}

Recipe _recipeDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Recipe();
  object.activeMinutes = reader.readLong(offsets[0]);
  object.aiCostPerPortionMinor = reader.readLongOrNull(offsets[1]);
  object.aiPerPortion = reader.readObjectOrNull<Nutrition>(
    offsets[2],
    NutritionSchema.deserialize,
    allOffsets,
  );
  object.cookMinutes = reader.readLong(offsets[3]);
  object.costPerPortionMinor = reader.readLong(offsets[4]);
  object.createdAt = reader.readDateTime(offsets[5]);
  object.cuisine = reader.readString(offsets[6]);
  object.defaultPortions = reader.readLong(offsets[7]);
  object.favorite = reader.readBool(offsets[8]);
  object.feasibilityStatus = reader.readStringOrNull(offsets[9]);
  object.fridgeLifeDays = reader.readLong(offsets[10]);
  object.hook = reader.readString(offsets[11]);
  object.id = id;
  object.ingredients =
      reader.readObjectList<RecipeIngredient>(
        offsets[12],
        RecipeIngredientSchema.deserialize,
        allOffsets,
        RecipeIngredient(),
      ) ??
      [];
  object.lastCookedAt = reader.readDateTimeOrNull(offsets[13]);
  object.lastPortionsCooked = reader.readLong(offsets[14]);
  object.omitted = reader.readStringList(offsets[15]) ?? [];
  object.origin =
      _RecipeoriginValueEnumMap[reader.readStringOrNull(offsets[16])] ??
      RecipeOrigin.dailyAuto;
  object.perPortion =
      reader.readObjectOrNull<Nutrition>(
        offsets[17],
        NutritionSchema.deserialize,
        allOffsets,
      ) ??
      Nutrition();
  object.prepMinutes = reader.readLong(offsets[18]);
  object.promptVersion = reader.readStringOrNull(offsets[19]);
  object.shoppingList =
      reader.readObjectList<ShoppingItem>(
        offsets[20],
        ShoppingItemSchema.deserialize,
        allOffsets,
        ShoppingItem(),
      ) ??
      [];
  object.sourceQuery = reader.readStringOrNull(offsets[21]);
  object.status =
      _RecipestatusValueEnumMap[reader.readStringOrNull(offsets[22])] ??
      RecipeStatus.suggested;
  object.steps = reader.readStringList(offsets[23]) ?? [];
  object.suggestedForDateKey = reader.readLongOrNull(offsets[24]);
  object.summary = reader.readStringOrNull(offsets[25]);
  object.tags = reader.readStringList(offsets[26]) ?? [];
  object.timesCooked = reader.readLong(offsets[27]);
  object.title = reader.readString(offsets[28]);
  object.validationFlags = reader.readStringList(offsets[29]) ?? [];
  object.why = reader.readString(offsets[30]);
  return object;
}

P _recipeDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readLongOrNull(offset)) as P;
    case 2:
      return (reader.readObjectOrNull<Nutrition>(
            offset,
            NutritionSchema.deserialize,
            allOffsets,
          ))
          as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readLong(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readObjectList<RecipeIngredient>(
                offset,
                RecipeIngredientSchema.deserialize,
                allOffsets,
                RecipeIngredient(),
              ) ??
              [])
          as P;
    case 13:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 14:
      return (reader.readLong(offset)) as P;
    case 15:
      return (reader.readStringList(offset) ?? []) as P;
    case 16:
      return (_RecipeoriginValueEnumMap[reader.readStringOrNull(offset)] ??
              RecipeOrigin.dailyAuto)
          as P;
    case 17:
      return (reader.readObjectOrNull<Nutrition>(
                offset,
                NutritionSchema.deserialize,
                allOffsets,
              ) ??
              Nutrition())
          as P;
    case 18:
      return (reader.readLong(offset)) as P;
    case 19:
      return (reader.readStringOrNull(offset)) as P;
    case 20:
      return (reader.readObjectList<ShoppingItem>(
                offset,
                ShoppingItemSchema.deserialize,
                allOffsets,
                ShoppingItem(),
              ) ??
              [])
          as P;
    case 21:
      return (reader.readStringOrNull(offset)) as P;
    case 22:
      return (_RecipestatusValueEnumMap[reader.readStringOrNull(offset)] ??
              RecipeStatus.suggested)
          as P;
    case 23:
      return (reader.readStringList(offset) ?? []) as P;
    case 24:
      return (reader.readLongOrNull(offset)) as P;
    case 25:
      return (reader.readStringOrNull(offset)) as P;
    case 26:
      return (reader.readStringList(offset) ?? []) as P;
    case 27:
      return (reader.readLong(offset)) as P;
    case 28:
      return (reader.readString(offset)) as P;
    case 29:
      return (reader.readStringList(offset) ?? []) as P;
    case 30:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _RecipeoriginEnumValueMap = {
  r'dailyAuto': r'dailyAuto',
  r'spontaneous': r'spontaneous',
  r'manual': r'manual',
};
const _RecipeoriginValueEnumMap = {
  r'dailyAuto': RecipeOrigin.dailyAuto,
  r'spontaneous': RecipeOrigin.spontaneous,
  r'manual': RecipeOrigin.manual,
};
const _RecipestatusEnumValueMap = {
  r'suggested': r'suggested',
  r'saved': r'saved',
  r'dismissed': r'dismissed',
  r'archived': r'archived',
};
const _RecipestatusValueEnumMap = {
  r'suggested': RecipeStatus.suggested,
  r'saved': RecipeStatus.saved,
  r'dismissed': RecipeStatus.dismissed,
  r'archived': RecipeStatus.archived,
};

Id _recipeGetId(Recipe object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _recipeGetLinks(Recipe object) {
  return [];
}

void _recipeAttach(IsarCollection<dynamic> col, Id id, Recipe object) {
  object.id = id;
}

extension RecipeQueryWhereSort on QueryBuilder<Recipe, Recipe, QWhere> {
  QueryBuilder<Recipe, Recipe, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterWhere> anySuggestedForDateKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'suggestedForDateKey'),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterWhere> anyFavorite() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'favorite'),
      );
    });
  }
}

extension RecipeQueryWhere on QueryBuilder<Recipe, Recipe, QWhereClause> {
  QueryBuilder<Recipe, Recipe, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Recipe, Recipe, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterWhereClause> idBetween(
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

  QueryBuilder<Recipe, Recipe, QAfterWhereClause> statusEqualTo(
    RecipeStatus status,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'status', value: [status]),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterWhereClause> statusNotEqualTo(
    RecipeStatus status,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'status',
                lower: [],
                upper: [status],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'status',
                lower: [status],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'status',
                lower: [status],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'status',
                lower: [],
                upper: [status],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterWhereClause> suggestedForDateKeyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'suggestedForDateKey',
          value: [null],
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterWhereClause>
  suggestedForDateKeyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'suggestedForDateKey',
          lower: [null],
          includeLower: false,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterWhereClause> suggestedForDateKeyEqualTo(
    int? suggestedForDateKey,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'suggestedForDateKey',
          value: [suggestedForDateKey],
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterWhereClause> suggestedForDateKeyNotEqualTo(
    int? suggestedForDateKey,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'suggestedForDateKey',
                lower: [],
                upper: [suggestedForDateKey],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'suggestedForDateKey',
                lower: [suggestedForDateKey],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'suggestedForDateKey',
                lower: [suggestedForDateKey],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'suggestedForDateKey',
                lower: [],
                upper: [suggestedForDateKey],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterWhereClause>
  suggestedForDateKeyGreaterThan(
    int? suggestedForDateKey, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'suggestedForDateKey',
          lower: [suggestedForDateKey],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterWhereClause> suggestedForDateKeyLessThan(
    int? suggestedForDateKey, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'suggestedForDateKey',
          lower: [],
          upper: [suggestedForDateKey],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterWhereClause> suggestedForDateKeyBetween(
    int? lowerSuggestedForDateKey,
    int? upperSuggestedForDateKey, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'suggestedForDateKey',
          lower: [lowerSuggestedForDateKey],
          includeLower: includeLower,
          upper: [upperSuggestedForDateKey],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterWhereClause> favoriteEqualTo(
    bool favorite,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'favorite', value: [favorite]),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterWhereClause> favoriteNotEqualTo(
    bool favorite,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'favorite',
                lower: [],
                upper: [favorite],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'favorite',
                lower: [favorite],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'favorite',
                lower: [favorite],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'favorite',
                lower: [],
                upper: [favorite],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension RecipeQueryFilter on QueryBuilder<Recipe, Recipe, QFilterCondition> {
  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> activeMinutesEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'activeMinutes', value: value),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> activeMinutesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'activeMinutes',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> activeMinutesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'activeMinutes',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> activeMinutesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'activeMinutes',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition>
  aiCostPerPortionMinorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'aiCostPerPortionMinor'),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition>
  aiCostPerPortionMinorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'aiCostPerPortionMinor'),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition>
  aiCostPerPortionMinorEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'aiCostPerPortionMinor',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition>
  aiCostPerPortionMinorGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'aiCostPerPortionMinor',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition>
  aiCostPerPortionMinorLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'aiCostPerPortionMinor',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition>
  aiCostPerPortionMinorBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'aiCostPerPortionMinor',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> aiPerPortionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'aiPerPortion'),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> aiPerPortionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'aiPerPortion'),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> cookMinutesEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'cookMinutes', value: value),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> cookMinutesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'cookMinutes',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> cookMinutesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'cookMinutes',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> cookMinutesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'cookMinutes',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition>
  costPerPortionMinorEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'costPerPortionMinor', value: value),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition>
  costPerPortionMinorGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'costPerPortionMinor',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition>
  costPerPortionMinorLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'costPerPortionMinor',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition>
  costPerPortionMinorBetween(
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

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> createdAtEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> createdAtGreaterThan(
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

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> createdAtLessThan(
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

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> createdAtBetween(
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

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> cuisineEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'cuisine',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> cuisineGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'cuisine',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> cuisineLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'cuisine',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> cuisineBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'cuisine',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> cuisineStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'cuisine',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> cuisineEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'cuisine',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> cuisineContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'cuisine',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> cuisineMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'cuisine',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> cuisineIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'cuisine', value: ''),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> cuisineIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'cuisine', value: ''),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> defaultPortionsEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'defaultPortions', value: value),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition>
  defaultPortionsGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'defaultPortions',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> defaultPortionsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'defaultPortions',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> defaultPortionsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'defaultPortions',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> favoriteEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'favorite', value: value),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition>
  feasibilityStatusIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'feasibilityStatus'),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition>
  feasibilityStatusIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'feasibilityStatus'),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> feasibilityStatusEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'feasibilityStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition>
  feasibilityStatusGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'feasibilityStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> feasibilityStatusLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'feasibilityStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> feasibilityStatusBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'feasibilityStatus',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition>
  feasibilityStatusStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'feasibilityStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> feasibilityStatusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'feasibilityStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> feasibilityStatusContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'feasibilityStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> feasibilityStatusMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'feasibilityStatus',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition>
  feasibilityStatusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'feasibilityStatus', value: ''),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition>
  feasibilityStatusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'feasibilityStatus', value: ''),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> fridgeLifeDaysEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'fridgeLifeDays', value: value),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> fridgeLifeDaysGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'fridgeLifeDays',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> fridgeLifeDaysLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'fridgeLifeDays',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> fridgeLifeDaysBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'fridgeLifeDays',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> hookEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'hook',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> hookGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'hook',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> hookLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'hook',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> hookBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'hook',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> hookStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'hook',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> hookEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'hook',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> hookContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'hook',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> hookMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'hook',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> hookIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'hook', value: ''),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> hookIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'hook', value: ''),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> idBetween(
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

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> ingredientsLengthEqualTo(
    int length,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'ingredients', length, true, length, true);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> ingredientsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'ingredients', 0, true, 0, true);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> ingredientsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'ingredients', 0, false, 999999, true);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> ingredientsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'ingredients', 0, true, length, include);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition>
  ingredientsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'ingredients', length, include, 999999, true);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> ingredientsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'ingredients',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> lastCookedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastCookedAt'),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> lastCookedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastCookedAt'),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> lastCookedAtEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastCookedAt', value: value),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> lastCookedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastCookedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> lastCookedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastCookedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> lastCookedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastCookedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> lastPortionsCookedEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastPortionsCooked', value: value),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition>
  lastPortionsCookedGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastPortionsCooked',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition>
  lastPortionsCookedLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastPortionsCooked',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> lastPortionsCookedBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastPortionsCooked',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> omittedElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'omitted',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> omittedElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'omitted',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> omittedElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'omitted',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> omittedElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'omitted',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> omittedElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'omitted',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> omittedElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'omitted',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> omittedElementContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'omitted',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> omittedElementMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'omitted',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> omittedElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'omitted', value: ''),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition>
  omittedElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'omitted', value: ''),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> omittedLengthEqualTo(
    int length,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'omitted', length, true, length, true);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> omittedIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'omitted', 0, true, 0, true);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> omittedIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'omitted', 0, false, 999999, true);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> omittedLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'omitted', 0, true, length, include);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> omittedLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'omitted', length, include, 999999, true);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> omittedLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'omitted',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> originEqualTo(
    RecipeOrigin value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'origin',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> originGreaterThan(
    RecipeOrigin value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'origin',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> originLessThan(
    RecipeOrigin value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'origin',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> originBetween(
    RecipeOrigin lower,
    RecipeOrigin upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'origin',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> originStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'origin',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> originEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'origin',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> originContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'origin',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> originMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'origin',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> originIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'origin', value: ''),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> originIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'origin', value: ''),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> prepMinutesEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'prepMinutes', value: value),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> prepMinutesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'prepMinutes',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> prepMinutesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'prepMinutes',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> prepMinutesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'prepMinutes',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> promptVersionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'promptVersion'),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> promptVersionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'promptVersion'),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> promptVersionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> promptVersionGreaterThan(
    String? value, {
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

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> promptVersionLessThan(
    String? value, {
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

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> promptVersionBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> promptVersionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> promptVersionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> promptVersionContains(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> promptVersionMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> promptVersionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'promptVersion', value: ''),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition>
  promptVersionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'promptVersion', value: ''),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> shoppingListLengthEqualTo(
    int length,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'shoppingList', length, true, length, true);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> shoppingListIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'shoppingList', 0, true, 0, true);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> shoppingListIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'shoppingList', 0, false, 999999, true);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition>
  shoppingListLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'shoppingList', 0, true, length, include);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition>
  shoppingListLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'shoppingList', length, include, 999999, true);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> shoppingListLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'shoppingList',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> sourceQueryIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'sourceQuery'),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> sourceQueryIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'sourceQuery'),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> sourceQueryEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'sourceQuery',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> sourceQueryGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sourceQuery',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> sourceQueryLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sourceQuery',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> sourceQueryBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sourceQuery',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> sourceQueryStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'sourceQuery',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> sourceQueryEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'sourceQuery',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> sourceQueryContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'sourceQuery',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> sourceQueryMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'sourceQuery',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> sourceQueryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sourceQuery', value: ''),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> sourceQueryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'sourceQuery', value: ''),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> statusEqualTo(
    RecipeStatus value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> statusGreaterThan(
    RecipeStatus value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> statusLessThan(
    RecipeStatus value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> statusBetween(
    RecipeStatus lower,
    RecipeStatus upper, {
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

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> statusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> statusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> statusContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> statusMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'status',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'status', value: ''),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'status', value: ''),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> stepsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'steps',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> stepsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'steps',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> stepsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'steps',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> stepsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'steps',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> stepsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'steps',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> stepsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'steps',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> stepsElementContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'steps',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> stepsElementMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'steps',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> stepsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'steps', value: ''),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> stepsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'steps', value: ''),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> stepsLengthEqualTo(
    int length,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'steps', length, true, length, true);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> stepsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'steps', 0, true, 0, true);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> stepsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'steps', 0, false, 999999, true);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> stepsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'steps', 0, true, length, include);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> stepsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'steps', length, include, 999999, true);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> stepsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'steps',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition>
  suggestedForDateKeyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'suggestedForDateKey'),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition>
  suggestedForDateKeyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'suggestedForDateKey'),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition>
  suggestedForDateKeyEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'suggestedForDateKey', value: value),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition>
  suggestedForDateKeyGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'suggestedForDateKey',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition>
  suggestedForDateKeyLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'suggestedForDateKey',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition>
  suggestedForDateKeyBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'suggestedForDateKey',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> summaryIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'summary'),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> summaryIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'summary'),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> summaryEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'summary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> summaryGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'summary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> summaryLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'summary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> summaryBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'summary',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> summaryStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'summary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> summaryEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'summary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> summaryContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'summary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> summaryMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'summary',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> summaryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'summary', value: ''),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> summaryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'summary', value: ''),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> tagsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'tags',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> tagsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'tags',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> tagsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'tags',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> tagsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'tags',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> tagsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'tags',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> tagsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'tags',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> tagsElementContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'tags',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> tagsElementMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'tags',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> tagsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'tags', value: ''),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> tagsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'tags', value: ''),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> tagsLengthEqualTo(
    int length,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'tags', length, true, length, true);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> tagsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'tags', 0, true, 0, true);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> tagsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'tags', 0, false, 999999, true);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> tagsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'tags', 0, true, length, include);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> tagsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'tags', length, include, 999999, true);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> tagsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> timesCookedEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'timesCooked', value: value),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> timesCookedGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'timesCooked',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> timesCookedLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'timesCooked',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> timesCookedBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'timesCooked',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> titleEqualTo(
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

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> titleGreaterThan(
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

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> titleLessThan(
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

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> titleBetween(
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

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> titleStartsWith(
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

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> titleEndsWith(
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

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> titleContains(
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

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> titleMatches(
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

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition>
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

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition>
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

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition>
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

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition>
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

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition>
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

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition>
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

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition>
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

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition>
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

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition>
  validationFlagsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'validationFlags', value: ''),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition>
  validationFlagsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'validationFlags', value: ''),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition>
  validationFlagsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'validationFlags', length, true, length, true);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> validationFlagsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'validationFlags', 0, true, 0, true);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition>
  validationFlagsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'validationFlags', 0, false, 999999, true);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition>
  validationFlagsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'validationFlags', 0, true, length, include);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition>
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

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition>
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

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> whyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'why',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> whyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'why',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> whyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'why',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> whyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'why',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> whyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'why',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> whyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'why',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> whyContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'why',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> whyMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'why',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> whyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'why', value: ''),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> whyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'why', value: ''),
      );
    });
  }
}

extension RecipeQueryObject on QueryBuilder<Recipe, Recipe, QFilterCondition> {
  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> aiPerPortion(
    FilterQuery<Nutrition> q,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'aiPerPortion');
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> ingredientsElement(
    FilterQuery<RecipeIngredient> q,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'ingredients');
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> perPortion(
    FilterQuery<Nutrition> q,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'perPortion');
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> shoppingListElement(
    FilterQuery<ShoppingItem> q,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'shoppingList');
    });
  }
}

extension RecipeQueryLinks on QueryBuilder<Recipe, Recipe, QFilterCondition> {}

extension RecipeQuerySortBy on QueryBuilder<Recipe, Recipe, QSortBy> {
  QueryBuilder<Recipe, Recipe, QAfterSortBy> sortByActiveMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeMinutes', Sort.asc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> sortByActiveMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeMinutes', Sort.desc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> sortByAiCostPerPortionMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiCostPerPortionMinor', Sort.asc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> sortByAiCostPerPortionMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiCostPerPortionMinor', Sort.desc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> sortByCookMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cookMinutes', Sort.asc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> sortByCookMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cookMinutes', Sort.desc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> sortByCostPerPortionMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'costPerPortionMinor', Sort.asc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> sortByCostPerPortionMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'costPerPortionMinor', Sort.desc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> sortByCuisine() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cuisine', Sort.asc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> sortByCuisineDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cuisine', Sort.desc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> sortByDefaultPortions() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultPortions', Sort.asc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> sortByDefaultPortionsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultPortions', Sort.desc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> sortByFavorite() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'favorite', Sort.asc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> sortByFavoriteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'favorite', Sort.desc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> sortByFeasibilityStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feasibilityStatus', Sort.asc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> sortByFeasibilityStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feasibilityStatus', Sort.desc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> sortByFridgeLifeDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fridgeLifeDays', Sort.asc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> sortByFridgeLifeDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fridgeLifeDays', Sort.desc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> sortByHook() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hook', Sort.asc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> sortByHookDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hook', Sort.desc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> sortByLastCookedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCookedAt', Sort.asc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> sortByLastCookedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCookedAt', Sort.desc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> sortByLastPortionsCooked() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPortionsCooked', Sort.asc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> sortByLastPortionsCookedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPortionsCooked', Sort.desc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> sortByOrigin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origin', Sort.asc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> sortByOriginDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origin', Sort.desc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> sortByPrepMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'prepMinutes', Sort.asc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> sortByPrepMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'prepMinutes', Sort.desc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> sortByPromptVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'promptVersion', Sort.asc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> sortByPromptVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'promptVersion', Sort.desc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> sortBySourceQuery() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceQuery', Sort.asc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> sortBySourceQueryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceQuery', Sort.desc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> sortBySuggestedForDateKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'suggestedForDateKey', Sort.asc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> sortBySuggestedForDateKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'suggestedForDateKey', Sort.desc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> sortBySummary() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'summary', Sort.asc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> sortBySummaryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'summary', Sort.desc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> sortByTimesCooked() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timesCooked', Sort.asc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> sortByTimesCookedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timesCooked', Sort.desc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> sortByWhy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'why', Sort.asc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> sortByWhyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'why', Sort.desc);
    });
  }
}

extension RecipeQuerySortThenBy on QueryBuilder<Recipe, Recipe, QSortThenBy> {
  QueryBuilder<Recipe, Recipe, QAfterSortBy> thenByActiveMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeMinutes', Sort.asc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> thenByActiveMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeMinutes', Sort.desc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> thenByAiCostPerPortionMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiCostPerPortionMinor', Sort.asc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> thenByAiCostPerPortionMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiCostPerPortionMinor', Sort.desc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> thenByCookMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cookMinutes', Sort.asc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> thenByCookMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cookMinutes', Sort.desc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> thenByCostPerPortionMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'costPerPortionMinor', Sort.asc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> thenByCostPerPortionMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'costPerPortionMinor', Sort.desc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> thenByCuisine() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cuisine', Sort.asc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> thenByCuisineDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cuisine', Sort.desc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> thenByDefaultPortions() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultPortions', Sort.asc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> thenByDefaultPortionsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultPortions', Sort.desc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> thenByFavorite() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'favorite', Sort.asc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> thenByFavoriteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'favorite', Sort.desc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> thenByFeasibilityStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feasibilityStatus', Sort.asc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> thenByFeasibilityStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feasibilityStatus', Sort.desc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> thenByFridgeLifeDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fridgeLifeDays', Sort.asc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> thenByFridgeLifeDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fridgeLifeDays', Sort.desc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> thenByHook() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hook', Sort.asc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> thenByHookDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hook', Sort.desc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> thenByLastCookedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCookedAt', Sort.asc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> thenByLastCookedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCookedAt', Sort.desc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> thenByLastPortionsCooked() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPortionsCooked', Sort.asc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> thenByLastPortionsCookedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPortionsCooked', Sort.desc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> thenByOrigin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origin', Sort.asc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> thenByOriginDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origin', Sort.desc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> thenByPrepMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'prepMinutes', Sort.asc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> thenByPrepMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'prepMinutes', Sort.desc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> thenByPromptVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'promptVersion', Sort.asc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> thenByPromptVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'promptVersion', Sort.desc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> thenBySourceQuery() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceQuery', Sort.asc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> thenBySourceQueryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceQuery', Sort.desc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> thenBySuggestedForDateKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'suggestedForDateKey', Sort.asc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> thenBySuggestedForDateKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'suggestedForDateKey', Sort.desc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> thenBySummary() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'summary', Sort.asc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> thenBySummaryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'summary', Sort.desc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> thenByTimesCooked() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timesCooked', Sort.asc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> thenByTimesCookedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timesCooked', Sort.desc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> thenByWhy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'why', Sort.asc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> thenByWhyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'why', Sort.desc);
    });
  }
}

extension RecipeQueryWhereDistinct on QueryBuilder<Recipe, Recipe, QDistinct> {
  QueryBuilder<Recipe, Recipe, QDistinct> distinctByActiveMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'activeMinutes');
    });
  }

  QueryBuilder<Recipe, Recipe, QDistinct> distinctByAiCostPerPortionMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'aiCostPerPortionMinor');
    });
  }

  QueryBuilder<Recipe, Recipe, QDistinct> distinctByCookMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cookMinutes');
    });
  }

  QueryBuilder<Recipe, Recipe, QDistinct> distinctByCostPerPortionMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'costPerPortionMinor');
    });
  }

  QueryBuilder<Recipe, Recipe, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<Recipe, Recipe, QDistinct> distinctByCuisine({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cuisine', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Recipe, Recipe, QDistinct> distinctByDefaultPortions() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'defaultPortions');
    });
  }

  QueryBuilder<Recipe, Recipe, QDistinct> distinctByFavorite() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'favorite');
    });
  }

  QueryBuilder<Recipe, Recipe, QDistinct> distinctByFeasibilityStatus({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'feasibilityStatus',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QDistinct> distinctByFridgeLifeDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fridgeLifeDays');
    });
  }

  QueryBuilder<Recipe, Recipe, QDistinct> distinctByHook({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hook', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Recipe, Recipe, QDistinct> distinctByLastCookedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastCookedAt');
    });
  }

  QueryBuilder<Recipe, Recipe, QDistinct> distinctByLastPortionsCooked() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastPortionsCooked');
    });
  }

  QueryBuilder<Recipe, Recipe, QDistinct> distinctByOmitted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'omitted');
    });
  }

  QueryBuilder<Recipe, Recipe, QDistinct> distinctByOrigin({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'origin', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Recipe, Recipe, QDistinct> distinctByPrepMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'prepMinutes');
    });
  }

  QueryBuilder<Recipe, Recipe, QDistinct> distinctByPromptVersion({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'promptVersion',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QDistinct> distinctBySourceQuery({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceQuery', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Recipe, Recipe, QDistinct> distinctByStatus({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Recipe, Recipe, QDistinct> distinctBySteps() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'steps');
    });
  }

  QueryBuilder<Recipe, Recipe, QDistinct> distinctBySuggestedForDateKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'suggestedForDateKey');
    });
  }

  QueryBuilder<Recipe, Recipe, QDistinct> distinctBySummary({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'summary', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Recipe, Recipe, QDistinct> distinctByTags() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tags');
    });
  }

  QueryBuilder<Recipe, Recipe, QDistinct> distinctByTimesCooked() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timesCooked');
    });
  }

  QueryBuilder<Recipe, Recipe, QDistinct> distinctByTitle({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Recipe, Recipe, QDistinct> distinctByValidationFlags() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'validationFlags');
    });
  }

  QueryBuilder<Recipe, Recipe, QDistinct> distinctByWhy({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'why', caseSensitive: caseSensitive);
    });
  }
}

extension RecipeQueryProperty on QueryBuilder<Recipe, Recipe, QQueryProperty> {
  QueryBuilder<Recipe, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Recipe, int, QQueryOperations> activeMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'activeMinutes');
    });
  }

  QueryBuilder<Recipe, int?, QQueryOperations> aiCostPerPortionMinorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'aiCostPerPortionMinor');
    });
  }

  QueryBuilder<Recipe, Nutrition?, QQueryOperations> aiPerPortionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'aiPerPortion');
    });
  }

  QueryBuilder<Recipe, int, QQueryOperations> cookMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cookMinutes');
    });
  }

  QueryBuilder<Recipe, int, QQueryOperations> costPerPortionMinorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'costPerPortionMinor');
    });
  }

  QueryBuilder<Recipe, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<Recipe, String, QQueryOperations> cuisineProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cuisine');
    });
  }

  QueryBuilder<Recipe, int, QQueryOperations> defaultPortionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'defaultPortions');
    });
  }

  QueryBuilder<Recipe, bool, QQueryOperations> favoriteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'favorite');
    });
  }

  QueryBuilder<Recipe, String?, QQueryOperations> feasibilityStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'feasibilityStatus');
    });
  }

  QueryBuilder<Recipe, int, QQueryOperations> fridgeLifeDaysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fridgeLifeDays');
    });
  }

  QueryBuilder<Recipe, String, QQueryOperations> hookProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hook');
    });
  }

  QueryBuilder<Recipe, List<RecipeIngredient>, QQueryOperations>
  ingredientsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ingredients');
    });
  }

  QueryBuilder<Recipe, DateTime?, QQueryOperations> lastCookedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastCookedAt');
    });
  }

  QueryBuilder<Recipe, int, QQueryOperations> lastPortionsCookedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastPortionsCooked');
    });
  }

  QueryBuilder<Recipe, List<String>, QQueryOperations> omittedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'omitted');
    });
  }

  QueryBuilder<Recipe, RecipeOrigin, QQueryOperations> originProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'origin');
    });
  }

  QueryBuilder<Recipe, Nutrition, QQueryOperations> perPortionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'perPortion');
    });
  }

  QueryBuilder<Recipe, int, QQueryOperations> prepMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'prepMinutes');
    });
  }

  QueryBuilder<Recipe, String?, QQueryOperations> promptVersionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'promptVersion');
    });
  }

  QueryBuilder<Recipe, List<ShoppingItem>, QQueryOperations>
  shoppingListProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'shoppingList');
    });
  }

  QueryBuilder<Recipe, String?, QQueryOperations> sourceQueryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceQuery');
    });
  }

  QueryBuilder<Recipe, RecipeStatus, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<Recipe, List<String>, QQueryOperations> stepsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'steps');
    });
  }

  QueryBuilder<Recipe, int?, QQueryOperations> suggestedForDateKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'suggestedForDateKey');
    });
  }

  QueryBuilder<Recipe, String?, QQueryOperations> summaryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'summary');
    });
  }

  QueryBuilder<Recipe, List<String>, QQueryOperations> tagsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tags');
    });
  }

  QueryBuilder<Recipe, int, QQueryOperations> timesCookedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timesCooked');
    });
  }

  QueryBuilder<Recipe, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<Recipe, List<String>, QQueryOperations>
  validationFlagsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'validationFlags');
    });
  }

  QueryBuilder<Recipe, String, QQueryOperations> whyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'why');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const RecipeIngredientSchema = Schema(
  name: r'RecipeIngredient',
  id: -7135109042295776315,
  properties: {
    r'estCostMinor': PropertySchema(
      id: 0,
      name: r'estCostMinor',
      type: IsarType.long,
    ),
    r'estNutritionPerPortion': PropertySchema(
      id: 1,
      name: r'estNutritionPerPortion',
      type: IsarType.object,

      target: r'Nutrition',
    ),
    r'ingredientId': PropertySchema(
      id: 2,
      name: r'ingredientId',
      type: IsarType.long,
    ),
    r'key': PropertySchema(id: 3, name: r'key', type: IsarType.string),
    r'name': PropertySchema(id: 4, name: r'name', type: IsarType.string),
    r'prepNote': PropertySchema(
      id: 5,
      name: r'prepNote',
      type: IsarType.string,
    ),
    r'qtyPerPortion': PropertySchema(
      id: 6,
      name: r'qtyPerPortion',
      type: IsarType.double,
    ),
    r'role': PropertySchema(
      id: 7,
      name: r'role',
      type: IsarType.string,
      enumMap: _RecipeIngredientroleEnumValueMap,
    ),
    r'substitutesFor': PropertySchema(
      id: 8,
      name: r'substitutesFor',
      type: IsarType.string,
    ),
    r'unit': PropertySchema(
      id: 9,
      name: r'unit',
      type: IsarType.string,
      enumMap: _RecipeIngredientunitEnumValueMap,
    ),
  },

  estimateSize: _recipeIngredientEstimateSize,
  serialize: _recipeIngredientSerialize,
  deserialize: _recipeIngredientDeserialize,
  deserializeProp: _recipeIngredientDeserializeProp,
);

int _recipeIngredientEstimateSize(
  RecipeIngredient object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.estNutritionPerPortion;
    if (value != null) {
      bytesCount +=
          3 +
          NutritionSchema.estimateSize(
            value,
            allOffsets[Nutrition]!,
            allOffsets,
          );
    }
  }
  bytesCount += 3 + object.key.length * 3;
  bytesCount += 3 + object.name.length * 3;
  {
    final value = object.prepNote;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.role.name.length * 3;
  {
    final value = object.substitutesFor;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.unit.name.length * 3;
  return bytesCount;
}

void _recipeIngredientSerialize(
  RecipeIngredient object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.estCostMinor);
  writer.writeObject<Nutrition>(
    offsets[1],
    allOffsets,
    NutritionSchema.serialize,
    object.estNutritionPerPortion,
  );
  writer.writeLong(offsets[2], object.ingredientId);
  writer.writeString(offsets[3], object.key);
  writer.writeString(offsets[4], object.name);
  writer.writeString(offsets[5], object.prepNote);
  writer.writeDouble(offsets[6], object.qtyPerPortion);
  writer.writeString(offsets[7], object.role.name);
  writer.writeString(offsets[8], object.substitutesFor);
  writer.writeString(offsets[9], object.unit.name);
}

RecipeIngredient _recipeIngredientDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = RecipeIngredient();
  object.estCostMinor = reader.readLongOrNull(offsets[0]);
  object.estNutritionPerPortion = reader.readObjectOrNull<Nutrition>(
    offsets[1],
    NutritionSchema.deserialize,
    allOffsets,
  );
  object.ingredientId = reader.readLongOrNull(offsets[2]);
  object.key = reader.readString(offsets[3]);
  object.name = reader.readString(offsets[4]);
  object.prepNote = reader.readStringOrNull(offsets[5]);
  object.qtyPerPortion = reader.readDouble(offsets[6]);
  object.role =
      _RecipeIngredientroleValueEnumMap[reader.readStringOrNull(offsets[7])] ??
      IngredientRole.stock;
  object.substitutesFor = reader.readStringOrNull(offsets[8]);
  object.unit =
      _RecipeIngredientunitValueEnumMap[reader.readStringOrNull(offsets[9])] ??
      BaseUnit.g;
  return object;
}

P _recipeIngredientDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset)) as P;
    case 1:
      return (reader.readObjectOrNull<Nutrition>(
            offset,
            NutritionSchema.deserialize,
            allOffsets,
          ))
          as P;
    case 2:
      return (reader.readLongOrNull(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readDouble(offset)) as P;
    case 7:
      return (_RecipeIngredientroleValueEnumMap[reader.readStringOrNull(
                offset,
              )] ??
              IngredientRole.stock)
          as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (_RecipeIngredientunitValueEnumMap[reader.readStringOrNull(
                offset,
              )] ??
              BaseUnit.g)
          as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _RecipeIngredientroleEnumValueMap = {
  r'stock': r'stock',
  r'missing': r'missing',
};
const _RecipeIngredientroleValueEnumMap = {
  r'stock': IngredientRole.stock,
  r'missing': IngredientRole.missing,
};
const _RecipeIngredientunitEnumValueMap = {
  r'g': r'g',
  r'ml': r'ml',
  r'pc': r'pc',
};
const _RecipeIngredientunitValueEnumMap = {
  r'g': BaseUnit.g,
  r'ml': BaseUnit.ml,
  r'pc': BaseUnit.pc,
};

extension RecipeIngredientQueryFilter
    on QueryBuilder<RecipeIngredient, RecipeIngredient, QFilterCondition> {
  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  estCostMinorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'estCostMinor'),
      );
    });
  }

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  estCostMinorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'estCostMinor'),
      );
    });
  }

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  estCostMinorEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'estCostMinor', value: value),
      );
    });
  }

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  estCostMinorGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'estCostMinor',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  estCostMinorLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'estCostMinor',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  estCostMinorBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'estCostMinor',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  estNutritionPerPortionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'estNutritionPerPortion'),
      );
    });
  }

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  estNutritionPerPortionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'estNutritionPerPortion'),
      );
    });
  }

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  ingredientIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'ingredientId'),
      );
    });
  }

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  ingredientIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'ingredientId'),
      );
    });
  }

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  ingredientIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'ingredientId', value: value),
      );
    });
  }

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  ingredientIdGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'ingredientId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  ingredientIdLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'ingredientId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  ingredientIdBetween(
    int? lower,
    int? upper, {
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

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  keyEqualTo(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  keyGreaterThan(
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

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  keyLessThan(String value, {bool include = false, bool caseSensitive = true}) {
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

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  keyBetween(
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

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  keyStartsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  keyEndsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  keyContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  keyMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  keyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'key', value: ''),
      );
    });
  }

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  keyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'key', value: ''),
      );
    });
  }

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  nameEqualTo(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  nameGreaterThan(
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

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  nameLessThan(
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

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  nameBetween(
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

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  nameStartsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  nameEndsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  nameContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  nameMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  prepNoteIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'prepNote'),
      );
    });
  }

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  prepNoteIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'prepNote'),
      );
    });
  }

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  prepNoteEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'prepNote',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  prepNoteGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'prepNote',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  prepNoteLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'prepNote',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  prepNoteBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'prepNote',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  prepNoteStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'prepNote',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  prepNoteEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'prepNote',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  prepNoteContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'prepNote',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  prepNoteMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'prepNote',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  prepNoteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'prepNote', value: ''),
      );
    });
  }

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  prepNoteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'prepNote', value: ''),
      );
    });
  }

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  qtyPerPortionEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'qtyPerPortion',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  qtyPerPortionGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'qtyPerPortion',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  qtyPerPortionLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'qtyPerPortion',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  qtyPerPortionBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'qtyPerPortion',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  roleEqualTo(IngredientRole value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'role',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  roleGreaterThan(
    IngredientRole value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'role',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  roleLessThan(
    IngredientRole value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'role',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  roleBetween(
    IngredientRole lower,
    IngredientRole upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'role',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  roleStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'role',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  roleEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'role',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  roleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'role',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  roleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'role',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  roleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'role', value: ''),
      );
    });
  }

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  roleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'role', value: ''),
      );
    });
  }

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  substitutesForIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'substitutesFor'),
      );
    });
  }

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  substitutesForIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'substitutesFor'),
      );
    });
  }

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  substitutesForEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'substitutesFor',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  substitutesForGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'substitutesFor',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  substitutesForLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'substitutesFor',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  substitutesForBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'substitutesFor',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  substitutesForStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'substitutesFor',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  substitutesForEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'substitutesFor',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  substitutesForContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'substitutesFor',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  substitutesForMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'substitutesFor',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  substitutesForIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'substitutesFor', value: ''),
      );
    });
  }

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  substitutesForIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'substitutesFor', value: ''),
      );
    });
  }

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  unitEqualTo(BaseUnit value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'unit',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  unitGreaterThan(
    BaseUnit value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'unit',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  unitLessThan(
    BaseUnit value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'unit',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  unitBetween(
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

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  unitStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'unit',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  unitEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'unit',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  unitContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'unit',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  unitMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'unit',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  unitIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'unit', value: ''),
      );
    });
  }

  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  unitIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'unit', value: ''),
      );
    });
  }
}

extension RecipeIngredientQueryObject
    on QueryBuilder<RecipeIngredient, RecipeIngredient, QFilterCondition> {
  QueryBuilder<RecipeIngredient, RecipeIngredient, QAfterFilterCondition>
  estNutritionPerPortion(FilterQuery<Nutrition> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'estNutritionPerPortion');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const ShoppingItemSchema = Schema(
  name: r'ShoppingItem',
  id: 8757760147473695853,
  properties: {
    r'estCostMinor': PropertySchema(
      id: 0,
      name: r'estCostMinor',
      type: IsarType.long,
    ),
    r'name': PropertySchema(id: 1, name: r'name', type: IsarType.string),
    r'packageDesc': PropertySchema(
      id: 2,
      name: r'packageDesc',
      type: IsarType.string,
    ),
    r'reason': PropertySchema(id: 3, name: r'reason', type: IsarType.string),
  },

  estimateSize: _shoppingItemEstimateSize,
  serialize: _shoppingItemSerialize,
  deserialize: _shoppingItemDeserialize,
  deserializeProp: _shoppingItemDeserializeProp,
);

int _shoppingItemEstimateSize(
  ShoppingItem object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.packageDesc.length * 3;
  bytesCount += 3 + object.reason.length * 3;
  return bytesCount;
}

void _shoppingItemSerialize(
  ShoppingItem object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.estCostMinor);
  writer.writeString(offsets[1], object.name);
  writer.writeString(offsets[2], object.packageDesc);
  writer.writeString(offsets[3], object.reason);
}

ShoppingItem _shoppingItemDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ShoppingItem();
  object.estCostMinor = reader.readLong(offsets[0]);
  object.name = reader.readString(offsets[1]);
  object.packageDesc = reader.readString(offsets[2]);
  object.reason = reader.readString(offsets[3]);
  return object;
}

P _shoppingItemDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension ShoppingItemQueryFilter
    on QueryBuilder<ShoppingItem, ShoppingItem, QFilterCondition> {
  QueryBuilder<ShoppingItem, ShoppingItem, QAfterFilterCondition>
  estCostMinorEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'estCostMinor', value: value),
      );
    });
  }

  QueryBuilder<ShoppingItem, ShoppingItem, QAfterFilterCondition>
  estCostMinorGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'estCostMinor',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItem, ShoppingItem, QAfterFilterCondition>
  estCostMinorLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'estCostMinor',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItem, ShoppingItem, QAfterFilterCondition>
  estCostMinorBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'estCostMinor',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItem, ShoppingItem, QAfterFilterCondition> nameEqualTo(
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

  QueryBuilder<ShoppingItem, ShoppingItem, QAfterFilterCondition>
  nameGreaterThan(
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

  QueryBuilder<ShoppingItem, ShoppingItem, QAfterFilterCondition> nameLessThan(
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

  QueryBuilder<ShoppingItem, ShoppingItem, QAfterFilterCondition> nameBetween(
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

  QueryBuilder<ShoppingItem, ShoppingItem, QAfterFilterCondition>
  nameStartsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<ShoppingItem, ShoppingItem, QAfterFilterCondition> nameEndsWith(
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

  QueryBuilder<ShoppingItem, ShoppingItem, QAfterFilterCondition> nameContains(
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

  QueryBuilder<ShoppingItem, ShoppingItem, QAfterFilterCondition> nameMatches(
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

  QueryBuilder<ShoppingItem, ShoppingItem, QAfterFilterCondition>
  nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<ShoppingItem, ShoppingItem, QAfterFilterCondition>
  nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<ShoppingItem, ShoppingItem, QAfterFilterCondition>
  packageDescEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'packageDesc',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItem, ShoppingItem, QAfterFilterCondition>
  packageDescGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'packageDesc',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItem, ShoppingItem, QAfterFilterCondition>
  packageDescLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'packageDesc',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItem, ShoppingItem, QAfterFilterCondition>
  packageDescBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'packageDesc',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItem, ShoppingItem, QAfterFilterCondition>
  packageDescStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'packageDesc',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItem, ShoppingItem, QAfterFilterCondition>
  packageDescEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'packageDesc',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItem, ShoppingItem, QAfterFilterCondition>
  packageDescContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'packageDesc',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItem, ShoppingItem, QAfterFilterCondition>
  packageDescMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'packageDesc',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItem, ShoppingItem, QAfterFilterCondition>
  packageDescIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'packageDesc', value: ''),
      );
    });
  }

  QueryBuilder<ShoppingItem, ShoppingItem, QAfterFilterCondition>
  packageDescIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'packageDesc', value: ''),
      );
    });
  }

  QueryBuilder<ShoppingItem, ShoppingItem, QAfterFilterCondition> reasonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'reason',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItem, ShoppingItem, QAfterFilterCondition>
  reasonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'reason',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItem, ShoppingItem, QAfterFilterCondition>
  reasonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'reason',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItem, ShoppingItem, QAfterFilterCondition> reasonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'reason',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItem, ShoppingItem, QAfterFilterCondition>
  reasonStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'reason',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItem, ShoppingItem, QAfterFilterCondition>
  reasonEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'reason',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItem, ShoppingItem, QAfterFilterCondition>
  reasonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'reason',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItem, ShoppingItem, QAfterFilterCondition> reasonMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'reason',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItem, ShoppingItem, QAfterFilterCondition>
  reasonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'reason', value: ''),
      );
    });
  }

  QueryBuilder<ShoppingItem, ShoppingItem, QAfterFilterCondition>
  reasonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'reason', value: ''),
      );
    });
  }
}

extension ShoppingItemQueryObject
    on QueryBuilder<ShoppingItem, ShoppingItem, QFilterCondition> {}
