// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetUserProfileCollection on Isar {
  IsarCollection<UserProfile> get userProfiles => this.collection();
}

const UserProfileSchema = CollectionSchema(
  name: r'UserProfile',
  id: 4738427352541298891,
  properties: {
    r'allergies': PropertySchema(
      id: 0,
      name: r'allergies',
      type: IsarType.stringList,
    ),
    r'autoCommitCleanScans': PropertySchema(
      id: 1,
      name: r'autoCommitCleanScans',
      type: IsarType.bool,
    ),
    r'autoLogFirstPortion': PropertySchema(
      id: 2,
      name: r'autoLogFirstPortion',
      type: IsarType.bool,
    ),
    r'country': PropertySchema(id: 3, name: r'country', type: IsarType.string),
    r'cuisinesLiked': PropertySchema(
      id: 4,
      name: r'cuisinesLiked',
      type: IsarType.stringList,
    ),
    r'currency': PropertySchema(
      id: 5,
      name: r'currency',
      type: IsarType.string,
    ),
    r'currencyMinorDigits': PropertySchema(
      id: 6,
      name: r'currencyMinorDigits',
      type: IsarType.long,
    ),
    r'dailyKcalTarget': PropertySchema(
      id: 7,
      name: r'dailyKcalTarget',
      type: IsarType.double,
    ),
    r'dailyPickMinuteOfDay': PropertySchema(
      id: 8,
      name: r'dailyPickMinuteOfDay',
      type: IsarType.long,
    ),
    r'dailyProteinTargetG': PropertySchema(
      id: 9,
      name: r'dailyProteinTargetG',
      type: IsarType.double,
    ),
    r'dayRolloverHour': PropertySchema(
      id: 10,
      name: r'dayRolloverHour',
      type: IsarType.long,
    ),
    r'defaultPortions': PropertySchema(
      id: 11,
      name: r'defaultPortions',
      type: IsarType.long,
    ),
    r'diet': PropertySchema(id: 12, name: r'diet', type: IsarType.stringList),
    r'dislikes': PropertySchema(
      id: 13,
      name: r'dislikes',
      type: IsarType.stringList,
    ),
    r'eatingOutAvgMealMinor': PropertySchema(
      id: 14,
      name: r'eatingOutAvgMealMinor',
      type: IsarType.long,
    ),
    r'equipment': PropertySchema(
      id: 15,
      name: r'equipment',
      type: IsarType.stringList,
    ),
    r'foodBasis': PropertySchema(
      id: 16,
      name: r'foodBasis',
      type: IsarType.string,
      enumMap: _UserProfilefoodBasisEnumValueMap,
    ),
    r'fxMemory': PropertySchema(
      id: 17,
      name: r'fxMemory',
      type: IsarType.objectList,

      target: r'FxMemo',
    ),
    r'geminiModel': PropertySchema(
      id: 18,
      name: r'geminiModel',
      type: IsarType.string,
    ),
    r'learnedKeywords': PropertySchema(
      id: 19,
      name: r'learnedKeywords',
      type: IsarType.objectList,

      target: r'KeywordCategory',
    ),
    r'lookUpPrices': PropertySchema(
      id: 20,
      name: r'lookUpPrices',
      type: IsarType.bool,
    ),
    r'maxActiveMinutes': PropertySchema(
      id: 21,
      name: r'maxActiveMinutes',
      type: IsarType.long,
    ),
    r'mealReminderMinutes': PropertySchema(
      id: 22,
      name: r'mealReminderMinutes',
      type: IsarType.longList,
    ),
    r'mealsPerDay': PropertySchema(
      id: 23,
      name: r'mealsPerDay',
      type: IsarType.long,
    ),
    r'monthlyCategoryLimits': PropertySchema(
      id: 24,
      name: r'monthlyCategoryLimits',
      type: IsarType.objectList,

      target: r'CategoryLimit',
    ),
    r'monthlyFoodBudgetMinor': PropertySchema(
      id: 25,
      name: r'monthlyFoodBudgetMinor',
      type: IsarType.long,
    ),
    r'notificationsEnabled': PropertySchema(
      id: 26,
      name: r'notificationsEnabled',
      type: IsarType.bool,
    ),
    r'onboardingDone': PropertySchema(
      id: 27,
      name: r'onboardingDone',
      type: IsarType.bool,
    ),
    r'outputLanguage': PropertySchema(
      id: 28,
      name: r'outputLanguage',
      type: IsarType.string,
    ),
    r'schemaVersion': PropertySchema(
      id: 29,
      name: r'schemaVersion',
      type: IsarType.long,
    ),
    r'targetCostPerPortionMinor': PropertySchema(
      id: 30,
      name: r'targetCostPerPortionMinor',
      type: IsarType.long,
    ),
    r'themeMode': PropertySchema(
      id: 31,
      name: r'themeMode',
      type: IsarType.string,
    ),
    r'weekStartsOn': PropertySchema(
      id: 32,
      name: r'weekStartsOn',
      type: IsarType.long,
    ),
    r'weeklyRecapEnabled': PropertySchema(
      id: 33,
      name: r'weeklyRecapEnabled',
      type: IsarType.bool,
    ),
  },

  estimateSize: _userProfileEstimateSize,
  serialize: _userProfileSerialize,
  deserialize: _userProfileDeserialize,
  deserializeProp: _userProfileDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {
    r'CategoryLimit': CategoryLimitSchema,
    r'KeywordCategory': KeywordCategorySchema,
    r'FxMemo': FxMemoSchema,
  },

  getId: _userProfileGetId,
  getLinks: _userProfileGetLinks,
  attach: _userProfileAttach,
  version: '3.3.2',
);

int _userProfileEstimateSize(
  UserProfile object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.allergies.length * 3;
  {
    for (var i = 0; i < object.allergies.length; i++) {
      final value = object.allergies[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.country.length * 3;
  bytesCount += 3 + object.cuisinesLiked.length * 3;
  {
    for (var i = 0; i < object.cuisinesLiked.length; i++) {
      final value = object.cuisinesLiked[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.currency.length * 3;
  bytesCount += 3 + object.diet.length * 3;
  {
    for (var i = 0; i < object.diet.length; i++) {
      final value = object.diet[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.dislikes.length * 3;
  {
    for (var i = 0; i < object.dislikes.length; i++) {
      final value = object.dislikes[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.equipment.length * 3;
  {
    for (var i = 0; i < object.equipment.length; i++) {
      final value = object.equipment[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.foodBasis.name.length * 3;
  bytesCount += 3 + object.fxMemory.length * 3;
  {
    final offsets = allOffsets[FxMemo]!;
    for (var i = 0; i < object.fxMemory.length; i++) {
      final value = object.fxMemory[i];
      bytesCount += FxMemoSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  bytesCount += 3 + object.geminiModel.length * 3;
  bytesCount += 3 + object.learnedKeywords.length * 3;
  {
    final offsets = allOffsets[KeywordCategory]!;
    for (var i = 0; i < object.learnedKeywords.length; i++) {
      final value = object.learnedKeywords[i];
      bytesCount += KeywordCategorySchema.estimateSize(
        value,
        offsets,
        allOffsets,
      );
    }
  }
  bytesCount += 3 + object.mealReminderMinutes.length * 8;
  bytesCount += 3 + object.monthlyCategoryLimits.length * 3;
  {
    final offsets = allOffsets[CategoryLimit]!;
    for (var i = 0; i < object.monthlyCategoryLimits.length; i++) {
      final value = object.monthlyCategoryLimits[i];
      bytesCount += CategoryLimitSchema.estimateSize(
        value,
        offsets,
        allOffsets,
      );
    }
  }
  bytesCount += 3 + object.outputLanguage.length * 3;
  bytesCount += 3 + object.themeMode.length * 3;
  return bytesCount;
}

void _userProfileSerialize(
  UserProfile object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeStringList(offsets[0], object.allergies);
  writer.writeBool(offsets[1], object.autoCommitCleanScans);
  writer.writeBool(offsets[2], object.autoLogFirstPortion);
  writer.writeString(offsets[3], object.country);
  writer.writeStringList(offsets[4], object.cuisinesLiked);
  writer.writeString(offsets[5], object.currency);
  writer.writeLong(offsets[6], object.currencyMinorDigits);
  writer.writeDouble(offsets[7], object.dailyKcalTarget);
  writer.writeLong(offsets[8], object.dailyPickMinuteOfDay);
  writer.writeDouble(offsets[9], object.dailyProteinTargetG);
  writer.writeLong(offsets[10], object.dayRolloverHour);
  writer.writeLong(offsets[11], object.defaultPortions);
  writer.writeStringList(offsets[12], object.diet);
  writer.writeStringList(offsets[13], object.dislikes);
  writer.writeLong(offsets[14], object.eatingOutAvgMealMinor);
  writer.writeStringList(offsets[15], object.equipment);
  writer.writeString(offsets[16], object.foodBasis.name);
  writer.writeObjectList<FxMemo>(
    offsets[17],
    allOffsets,
    FxMemoSchema.serialize,
    object.fxMemory,
  );
  writer.writeString(offsets[18], object.geminiModel);
  writer.writeObjectList<KeywordCategory>(
    offsets[19],
    allOffsets,
    KeywordCategorySchema.serialize,
    object.learnedKeywords,
  );
  writer.writeBool(offsets[20], object.lookUpPrices);
  writer.writeLong(offsets[21], object.maxActiveMinutes);
  writer.writeLongList(offsets[22], object.mealReminderMinutes);
  writer.writeLong(offsets[23], object.mealsPerDay);
  writer.writeObjectList<CategoryLimit>(
    offsets[24],
    allOffsets,
    CategoryLimitSchema.serialize,
    object.monthlyCategoryLimits,
  );
  writer.writeLong(offsets[25], object.monthlyFoodBudgetMinor);
  writer.writeBool(offsets[26], object.notificationsEnabled);
  writer.writeBool(offsets[27], object.onboardingDone);
  writer.writeString(offsets[28], object.outputLanguage);
  writer.writeLong(offsets[29], object.schemaVersion);
  writer.writeLong(offsets[30], object.targetCostPerPortionMinor);
  writer.writeString(offsets[31], object.themeMode);
  writer.writeLong(offsets[32], object.weekStartsOn);
  writer.writeBool(offsets[33], object.weeklyRecapEnabled);
}

UserProfile _userProfileDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = UserProfile();
  object.allergies = reader.readStringList(offsets[0]) ?? [];
  object.autoCommitCleanScans = reader.readBool(offsets[1]);
  object.autoLogFirstPortion = reader.readBool(offsets[2]);
  object.country = reader.readString(offsets[3]);
  object.cuisinesLiked = reader.readStringList(offsets[4]) ?? [];
  object.currency = reader.readString(offsets[5]);
  object.currencyMinorDigits = reader.readLong(offsets[6]);
  object.dailyKcalTarget = reader.readDouble(offsets[7]);
  object.dailyPickMinuteOfDay = reader.readLong(offsets[8]);
  object.dailyProteinTargetG = reader.readDouble(offsets[9]);
  object.dayRolloverHour = reader.readLong(offsets[10]);
  object.defaultPortions = reader.readLong(offsets[11]);
  object.diet = reader.readStringList(offsets[12]) ?? [];
  object.dislikes = reader.readStringList(offsets[13]) ?? [];
  object.eatingOutAvgMealMinor = reader.readLong(offsets[14]);
  object.equipment = reader.readStringList(offsets[15]) ?? [];
  object.foodBasis =
      _UserProfilefoodBasisValueEnumMap[reader.readStringOrNull(offsets[16])] ??
      FoodBasis.eaten;
  object.fxMemory =
      reader.readObjectList<FxMemo>(
        offsets[17],
        FxMemoSchema.deserialize,
        allOffsets,
        FxMemo(),
      ) ??
      [];
  object.geminiModel = reader.readString(offsets[18]);
  object.id = id;
  object.learnedKeywords =
      reader.readObjectList<KeywordCategory>(
        offsets[19],
        KeywordCategorySchema.deserialize,
        allOffsets,
        KeywordCategory(),
      ) ??
      [];
  object.lookUpPrices = reader.readBool(offsets[20]);
  object.maxActiveMinutes = reader.readLong(offsets[21]);
  object.mealReminderMinutes = reader.readLongList(offsets[22]) ?? [];
  object.mealsPerDay = reader.readLong(offsets[23]);
  object.monthlyCategoryLimits =
      reader.readObjectList<CategoryLimit>(
        offsets[24],
        CategoryLimitSchema.deserialize,
        allOffsets,
        CategoryLimit(),
      ) ??
      [];
  object.monthlyFoodBudgetMinor = reader.readLong(offsets[25]);
  object.notificationsEnabled = reader.readBool(offsets[26]);
  object.onboardingDone = reader.readBool(offsets[27]);
  object.outputLanguage = reader.readString(offsets[28]);
  object.schemaVersion = reader.readLong(offsets[29]);
  object.targetCostPerPortionMinor = reader.readLong(offsets[30]);
  object.themeMode = reader.readString(offsets[31]);
  object.weekStartsOn = reader.readLong(offsets[32]);
  object.weeklyRecapEnabled = reader.readBool(offsets[33]);
  return object;
}

P _userProfileDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringList(offset) ?? []) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readStringList(offset) ?? []) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readDouble(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readDouble(offset)) as P;
    case 10:
      return (reader.readLong(offset)) as P;
    case 11:
      return (reader.readLong(offset)) as P;
    case 12:
      return (reader.readStringList(offset) ?? []) as P;
    case 13:
      return (reader.readStringList(offset) ?? []) as P;
    case 14:
      return (reader.readLong(offset)) as P;
    case 15:
      return (reader.readStringList(offset) ?? []) as P;
    case 16:
      return (_UserProfilefoodBasisValueEnumMap[reader.readStringOrNull(
                offset,
              )] ??
              FoodBasis.eaten)
          as P;
    case 17:
      return (reader.readObjectList<FxMemo>(
                offset,
                FxMemoSchema.deserialize,
                allOffsets,
                FxMemo(),
              ) ??
              [])
          as P;
    case 18:
      return (reader.readString(offset)) as P;
    case 19:
      return (reader.readObjectList<KeywordCategory>(
                offset,
                KeywordCategorySchema.deserialize,
                allOffsets,
                KeywordCategory(),
              ) ??
              [])
          as P;
    case 20:
      return (reader.readBool(offset)) as P;
    case 21:
      return (reader.readLong(offset)) as P;
    case 22:
      return (reader.readLongList(offset) ?? []) as P;
    case 23:
      return (reader.readLong(offset)) as P;
    case 24:
      return (reader.readObjectList<CategoryLimit>(
                offset,
                CategoryLimitSchema.deserialize,
                allOffsets,
                CategoryLimit(),
              ) ??
              [])
          as P;
    case 25:
      return (reader.readLong(offset)) as P;
    case 26:
      return (reader.readBool(offset)) as P;
    case 27:
      return (reader.readBool(offset)) as P;
    case 28:
      return (reader.readString(offset)) as P;
    case 29:
      return (reader.readLong(offset)) as P;
    case 30:
      return (reader.readLong(offset)) as P;
    case 31:
      return (reader.readString(offset)) as P;
    case 32:
      return (reader.readLong(offset)) as P;
    case 33:
      return (reader.readBool(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _UserProfilefoodBasisEnumValueMap = {
  r'eaten': r'eaten',
  r'spent': r'spent',
};
const _UserProfilefoodBasisValueEnumMap = {
  r'eaten': FoodBasis.eaten,
  r'spent': FoodBasis.spent,
};

Id _userProfileGetId(UserProfile object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _userProfileGetLinks(UserProfile object) {
  return [];
}

void _userProfileAttach(
  IsarCollection<dynamic> col,
  Id id,
  UserProfile object,
) {
  object.id = id;
}

extension UserProfileQueryWhereSort
    on QueryBuilder<UserProfile, UserProfile, QWhere> {
  QueryBuilder<UserProfile, UserProfile, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension UserProfileQueryWhere
    on QueryBuilder<UserProfile, UserProfile, QWhereClause> {
  QueryBuilder<UserProfile, UserProfile, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterWhereClause> idNotEqualTo(
    Id id,
  ) {
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

  QueryBuilder<UserProfile, UserProfile, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterWhereClause> idBetween(
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
}

extension UserProfileQueryFilter
    on QueryBuilder<UserProfile, UserProfile, QFilterCondition> {
  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  allergiesElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'allergies',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  allergiesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'allergies',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  allergiesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'allergies',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  allergiesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'allergies',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  allergiesElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'allergies',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  allergiesElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'allergies',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  allergiesElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'allergies',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  allergiesElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'allergies',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  allergiesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'allergies', value: ''),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  allergiesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'allergies', value: ''),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  allergiesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'allergies', length, true, length, true);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  allergiesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'allergies', 0, true, 0, true);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  allergiesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'allergies', 0, false, 999999, true);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  allergiesLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'allergies', 0, true, length, include);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  allergiesLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'allergies', length, include, 999999, true);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  allergiesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'allergies',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  autoCommitCleanScansEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'autoCommitCleanScans',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  autoLogFirstPortionEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'autoLogFirstPortion', value: value),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> countryEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'country',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  countryGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'country',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> countryLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'country',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> countryBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'country',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  countryStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'country',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> countryEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'country',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> countryContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'country',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> countryMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'country',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  countryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'country', value: ''),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  countryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'country', value: ''),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  cuisinesLikedElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'cuisinesLiked',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  cuisinesLikedElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'cuisinesLiked',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  cuisinesLikedElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'cuisinesLiked',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  cuisinesLikedElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'cuisinesLiked',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  cuisinesLikedElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'cuisinesLiked',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  cuisinesLikedElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'cuisinesLiked',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  cuisinesLikedElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'cuisinesLiked',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  cuisinesLikedElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'cuisinesLiked',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  cuisinesLikedElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'cuisinesLiked', value: ''),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  cuisinesLikedElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'cuisinesLiked', value: ''),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  cuisinesLikedLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'cuisinesLiked', length, true, length, true);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  cuisinesLikedIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'cuisinesLiked', 0, true, 0, true);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  cuisinesLikedIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'cuisinesLiked', 0, false, 999999, true);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  cuisinesLikedLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'cuisinesLiked', 0, true, length, include);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  cuisinesLikedLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'cuisinesLiked', length, include, 999999, true);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  cuisinesLikedLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'cuisinesLiked',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> currencyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'currency',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  currencyGreaterThan(
    String value, {
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

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  currencyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'currency',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> currencyBetween(
    String lower,
    String upper, {
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

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  currencyStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'currency',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  currencyEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'currency',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  currencyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'currency',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> currencyMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'currency',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  currencyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'currency', value: ''),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  currencyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'currency', value: ''),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  currencyMinorDigitsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'currencyMinorDigits', value: value),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  currencyMinorDigitsGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'currencyMinorDigits',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  currencyMinorDigitsLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'currencyMinorDigits',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  currencyMinorDigitsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'currencyMinorDigits',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  dailyKcalTargetEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'dailyKcalTarget',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  dailyKcalTargetGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'dailyKcalTarget',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  dailyKcalTargetLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'dailyKcalTarget',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  dailyKcalTargetBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'dailyKcalTarget',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  dailyPickMinuteOfDayEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'dailyPickMinuteOfDay',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  dailyPickMinuteOfDayGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'dailyPickMinuteOfDay',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  dailyPickMinuteOfDayLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'dailyPickMinuteOfDay',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  dailyPickMinuteOfDayBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'dailyPickMinuteOfDay',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  dailyProteinTargetGEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'dailyProteinTargetG',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  dailyProteinTargetGGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'dailyProteinTargetG',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  dailyProteinTargetGLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'dailyProteinTargetG',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  dailyProteinTargetGBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'dailyProteinTargetG',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  dayRolloverHourEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'dayRolloverHour', value: value),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  dayRolloverHourGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'dayRolloverHour',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  dayRolloverHourLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'dayRolloverHour',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  dayRolloverHourBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'dayRolloverHour',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  defaultPortionsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'defaultPortions', value: value),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
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

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  defaultPortionsLessThan(int value, {bool include = false}) {
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

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  defaultPortionsBetween(
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

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  dietElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'diet',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  dietElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'diet',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  dietElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'diet',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  dietElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'diet',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  dietElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'diet',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  dietElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'diet',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  dietElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'diet',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  dietElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'diet',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  dietElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'diet', value: ''),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  dietElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'diet', value: ''),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  dietLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'diet', length, true, length, true);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> dietIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'diet', 0, true, 0, true);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  dietIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'diet', 0, false, 999999, true);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  dietLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'diet', 0, true, length, include);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  dietLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'diet', length, include, 999999, true);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  dietLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'diet',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  dislikesElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'dislikes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  dislikesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'dislikes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  dislikesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'dislikes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  dislikesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'dislikes',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  dislikesElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'dislikes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  dislikesElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'dislikes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  dislikesElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'dislikes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  dislikesElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'dislikes',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  dislikesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'dislikes', value: ''),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  dislikesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'dislikes', value: ''),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  dislikesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'dislikes', length, true, length, true);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  dislikesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'dislikes', 0, true, 0, true);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  dislikesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'dislikes', 0, false, 999999, true);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  dislikesLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'dislikes', 0, true, length, include);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  dislikesLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'dislikes', length, include, 999999, true);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  dislikesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'dislikes',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  eatingOutAvgMealMinorEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'eatingOutAvgMealMinor',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  eatingOutAvgMealMinorGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'eatingOutAvgMealMinor',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  eatingOutAvgMealMinorLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'eatingOutAvgMealMinor',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  eatingOutAvgMealMinorBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'eatingOutAvgMealMinor',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  equipmentElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'equipment',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  equipmentElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'equipment',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  equipmentElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'equipment',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  equipmentElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'equipment',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  equipmentElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'equipment',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  equipmentElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'equipment',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  equipmentElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'equipment',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  equipmentElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'equipment',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  equipmentElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'equipment', value: ''),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  equipmentElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'equipment', value: ''),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  equipmentLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'equipment', length, true, length, true);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  equipmentIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'equipment', 0, true, 0, true);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  equipmentIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'equipment', 0, false, 999999, true);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  equipmentLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'equipment', 0, true, length, include);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  equipmentLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'equipment', length, include, 999999, true);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  equipmentLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'equipment',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  foodBasisEqualTo(FoodBasis value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'foodBasis',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  foodBasisGreaterThan(
    FoodBasis value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'foodBasis',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  foodBasisLessThan(
    FoodBasis value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'foodBasis',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  foodBasisBetween(
    FoodBasis lower,
    FoodBasis upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'foodBasis',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  foodBasisStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'foodBasis',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  foodBasisEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'foodBasis',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  foodBasisContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'foodBasis',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  foodBasisMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'foodBasis',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  foodBasisIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'foodBasis', value: ''),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  foodBasisIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'foodBasis', value: ''),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  fxMemoryLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'fxMemory', length, true, length, true);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  fxMemoryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'fxMemory', 0, true, 0, true);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  fxMemoryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'fxMemory', 0, false, 999999, true);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  fxMemoryLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'fxMemory', 0, true, length, include);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  fxMemoryLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'fxMemory', length, include, 999999, true);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  fxMemoryLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'fxMemory',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  geminiModelEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'geminiModel',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  geminiModelGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'geminiModel',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  geminiModelLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'geminiModel',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  geminiModelBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'geminiModel',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  geminiModelStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'geminiModel',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  geminiModelEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'geminiModel',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  geminiModelContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'geminiModel',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  geminiModelMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'geminiModel',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  geminiModelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'geminiModel', value: ''),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  geminiModelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'geminiModel', value: ''),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> idBetween(
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

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  learnedKeywordsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'learnedKeywords', length, true, length, true);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  learnedKeywordsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'learnedKeywords', 0, true, 0, true);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  learnedKeywordsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'learnedKeywords', 0, false, 999999, true);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  learnedKeywordsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'learnedKeywords', 0, true, length, include);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  learnedKeywordsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'learnedKeywords',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  learnedKeywordsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'learnedKeywords',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  lookUpPricesEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lookUpPrices', value: value),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  maxActiveMinutesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'maxActiveMinutes', value: value),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  maxActiveMinutesGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'maxActiveMinutes',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  maxActiveMinutesLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'maxActiveMinutes',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  maxActiveMinutesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'maxActiveMinutes',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  mealReminderMinutesElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'mealReminderMinutes', value: value),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  mealReminderMinutesElementGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'mealReminderMinutes',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  mealReminderMinutesElementLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'mealReminderMinutes',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  mealReminderMinutesElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'mealReminderMinutes',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  mealReminderMinutesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mealReminderMinutes',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  mealReminderMinutesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'mealReminderMinutes', 0, true, 0, true);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  mealReminderMinutesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'mealReminderMinutes', 0, false, 999999, true);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  mealReminderMinutesLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'mealReminderMinutes', 0, true, length, include);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  mealReminderMinutesLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mealReminderMinutes',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  mealReminderMinutesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mealReminderMinutes',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  mealsPerDayEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'mealsPerDay', value: value),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  mealsPerDayGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'mealsPerDay',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  mealsPerDayLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'mealsPerDay',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  mealsPerDayBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'mealsPerDay',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  monthlyCategoryLimitsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'monthlyCategoryLimits',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  monthlyCategoryLimitsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'monthlyCategoryLimits', 0, true, 0, true);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  monthlyCategoryLimitsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'monthlyCategoryLimits', 0, false, 999999, true);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  monthlyCategoryLimitsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'monthlyCategoryLimits',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  monthlyCategoryLimitsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'monthlyCategoryLimits',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  monthlyCategoryLimitsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'monthlyCategoryLimits',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  monthlyFoodBudgetMinorEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'monthlyFoodBudgetMinor',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  monthlyFoodBudgetMinorGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'monthlyFoodBudgetMinor',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  monthlyFoodBudgetMinorLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'monthlyFoodBudgetMinor',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  monthlyFoodBudgetMinorBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'monthlyFoodBudgetMinor',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  notificationsEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'notificationsEnabled',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  onboardingDoneEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'onboardingDone', value: value),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  outputLanguageEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'outputLanguage',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  outputLanguageGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'outputLanguage',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  outputLanguageLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'outputLanguage',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  outputLanguageBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'outputLanguage',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  outputLanguageStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'outputLanguage',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  outputLanguageEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'outputLanguage',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  outputLanguageContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'outputLanguage',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  outputLanguageMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'outputLanguage',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  outputLanguageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'outputLanguage', value: ''),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  outputLanguageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'outputLanguage', value: ''),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  schemaVersionEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'schemaVersion', value: value),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  schemaVersionGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'schemaVersion',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  schemaVersionLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'schemaVersion',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  schemaVersionBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'schemaVersion',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  targetCostPerPortionMinorEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'targetCostPerPortionMinor',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  targetCostPerPortionMinorGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'targetCostPerPortionMinor',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  targetCostPerPortionMinorLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'targetCostPerPortionMinor',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  targetCostPerPortionMinorBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'targetCostPerPortionMinor',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  themeModeEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'themeMode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  themeModeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'themeMode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  themeModeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'themeMode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  themeModeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'themeMode',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  themeModeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'themeMode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  themeModeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'themeMode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  themeModeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'themeMode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  themeModeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'themeMode',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  themeModeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'themeMode', value: ''),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  themeModeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'themeMode', value: ''),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  weekStartsOnEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'weekStartsOn', value: value),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  weekStartsOnGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'weekStartsOn',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  weekStartsOnLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'weekStartsOn',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  weekStartsOnBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'weekStartsOn',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  weeklyRecapEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'weeklyRecapEnabled', value: value),
      );
    });
  }
}

extension UserProfileQueryObject
    on QueryBuilder<UserProfile, UserProfile, QFilterCondition> {
  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> fxMemoryElement(
    FilterQuery<FxMemo> q,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'fxMemory');
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  learnedKeywordsElement(FilterQuery<KeywordCategory> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'learnedKeywords');
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
  monthlyCategoryLimitsElement(FilterQuery<CategoryLimit> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'monthlyCategoryLimits');
    });
  }
}

extension UserProfileQueryLinks
    on QueryBuilder<UserProfile, UserProfile, QFilterCondition> {}

extension UserProfileQuerySortBy
    on QueryBuilder<UserProfile, UserProfile, QSortBy> {
  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
  sortByAutoCommitCleanScans() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoCommitCleanScans', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
  sortByAutoCommitCleanScansDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoCommitCleanScans', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
  sortByAutoLogFirstPortion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoLogFirstPortion', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
  sortByAutoLogFirstPortionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoLogFirstPortion', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByCountry() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'country', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByCountryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'country', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
  sortByCurrencyMinorDigits() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currencyMinorDigits', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
  sortByCurrencyMinorDigitsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currencyMinorDigits', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByDailyKcalTarget() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyKcalTarget', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
  sortByDailyKcalTargetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyKcalTarget', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
  sortByDailyPickMinuteOfDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyPickMinuteOfDay', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
  sortByDailyPickMinuteOfDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyPickMinuteOfDay', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
  sortByDailyProteinTargetG() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyProteinTargetG', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
  sortByDailyProteinTargetGDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyProteinTargetG', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByDayRolloverHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dayRolloverHour', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
  sortByDayRolloverHourDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dayRolloverHour', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByDefaultPortions() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultPortions', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
  sortByDefaultPortionsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultPortions', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
  sortByEatingOutAvgMealMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eatingOutAvgMealMinor', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
  sortByEatingOutAvgMealMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eatingOutAvgMealMinor', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByFoodBasis() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'foodBasis', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByFoodBasisDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'foodBasis', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByGeminiModel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'geminiModel', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByGeminiModelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'geminiModel', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByLookUpPrices() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lookUpPrices', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
  sortByLookUpPricesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lookUpPrices', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
  sortByMaxActiveMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxActiveMinutes', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
  sortByMaxActiveMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxActiveMinutes', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByMealsPerDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mealsPerDay', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByMealsPerDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mealsPerDay', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
  sortByMonthlyFoodBudgetMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monthlyFoodBudgetMinor', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
  sortByMonthlyFoodBudgetMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monthlyFoodBudgetMinor', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
  sortByNotificationsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationsEnabled', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
  sortByNotificationsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationsEnabled', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByOnboardingDone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'onboardingDone', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
  sortByOnboardingDoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'onboardingDone', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByOutputLanguage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outputLanguage', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
  sortByOutputLanguageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outputLanguage', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortBySchemaVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaVersion', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
  sortBySchemaVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaVersion', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
  sortByTargetCostPerPortionMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetCostPerPortionMinor', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
  sortByTargetCostPerPortionMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetCostPerPortionMinor', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByThemeMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeMode', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByThemeModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeMode', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByWeekStartsOn() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weekStartsOn', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
  sortByWeekStartsOnDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weekStartsOn', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
  sortByWeeklyRecapEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weeklyRecapEnabled', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
  sortByWeeklyRecapEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weeklyRecapEnabled', Sort.desc);
    });
  }
}

extension UserProfileQuerySortThenBy
    on QueryBuilder<UserProfile, UserProfile, QSortThenBy> {
  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
  thenByAutoCommitCleanScans() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoCommitCleanScans', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
  thenByAutoCommitCleanScansDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoCommitCleanScans', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
  thenByAutoLogFirstPortion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoLogFirstPortion', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
  thenByAutoLogFirstPortionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoLogFirstPortion', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByCountry() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'country', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByCountryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'country', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
  thenByCurrencyMinorDigits() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currencyMinorDigits', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
  thenByCurrencyMinorDigitsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currencyMinorDigits', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByDailyKcalTarget() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyKcalTarget', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
  thenByDailyKcalTargetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyKcalTarget', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
  thenByDailyPickMinuteOfDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyPickMinuteOfDay', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
  thenByDailyPickMinuteOfDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyPickMinuteOfDay', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
  thenByDailyProteinTargetG() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyProteinTargetG', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
  thenByDailyProteinTargetGDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyProteinTargetG', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByDayRolloverHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dayRolloverHour', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
  thenByDayRolloverHourDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dayRolloverHour', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByDefaultPortions() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultPortions', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
  thenByDefaultPortionsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultPortions', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
  thenByEatingOutAvgMealMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eatingOutAvgMealMinor', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
  thenByEatingOutAvgMealMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eatingOutAvgMealMinor', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByFoodBasis() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'foodBasis', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByFoodBasisDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'foodBasis', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByGeminiModel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'geminiModel', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByGeminiModelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'geminiModel', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByLookUpPrices() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lookUpPrices', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
  thenByLookUpPricesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lookUpPrices', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
  thenByMaxActiveMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxActiveMinutes', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
  thenByMaxActiveMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxActiveMinutes', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByMealsPerDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mealsPerDay', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByMealsPerDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mealsPerDay', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
  thenByMonthlyFoodBudgetMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monthlyFoodBudgetMinor', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
  thenByMonthlyFoodBudgetMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monthlyFoodBudgetMinor', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
  thenByNotificationsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationsEnabled', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
  thenByNotificationsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationsEnabled', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByOnboardingDone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'onboardingDone', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
  thenByOnboardingDoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'onboardingDone', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByOutputLanguage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outputLanguage', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
  thenByOutputLanguageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outputLanguage', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenBySchemaVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaVersion', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
  thenBySchemaVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaVersion', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
  thenByTargetCostPerPortionMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetCostPerPortionMinor', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
  thenByTargetCostPerPortionMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetCostPerPortionMinor', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByThemeMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeMode', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByThemeModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeMode', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByWeekStartsOn() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weekStartsOn', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
  thenByWeekStartsOnDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weekStartsOn', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
  thenByWeeklyRecapEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weeklyRecapEnabled', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
  thenByWeeklyRecapEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weeklyRecapEnabled', Sort.desc);
    });
  }
}

extension UserProfileQueryWhereDistinct
    on QueryBuilder<UserProfile, UserProfile, QDistinct> {
  QueryBuilder<UserProfile, UserProfile, QDistinct> distinctByAllergies() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'allergies');
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct>
  distinctByAutoCommitCleanScans() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'autoCommitCleanScans');
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct>
  distinctByAutoLogFirstPortion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'autoLogFirstPortion');
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct> distinctByCountry({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'country', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct> distinctByCuisinesLiked() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cuisinesLiked');
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct> distinctByCurrency({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currency', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct>
  distinctByCurrencyMinorDigits() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currencyMinorDigits');
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct>
  distinctByDailyKcalTarget() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dailyKcalTarget');
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct>
  distinctByDailyPickMinuteOfDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dailyPickMinuteOfDay');
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct>
  distinctByDailyProteinTargetG() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dailyProteinTargetG');
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct>
  distinctByDayRolloverHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dayRolloverHour');
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct>
  distinctByDefaultPortions() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'defaultPortions');
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct> distinctByDiet() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'diet');
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct> distinctByDislikes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dislikes');
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct>
  distinctByEatingOutAvgMealMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'eatingOutAvgMealMinor');
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct> distinctByEquipment() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'equipment');
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct> distinctByFoodBasis({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'foodBasis', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct> distinctByGeminiModel({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'geminiModel', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct> distinctByLookUpPrices() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lookUpPrices');
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct>
  distinctByMaxActiveMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'maxActiveMinutes');
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct>
  distinctByMealReminderMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mealReminderMinutes');
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct> distinctByMealsPerDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mealsPerDay');
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct>
  distinctByMonthlyFoodBudgetMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'monthlyFoodBudgetMinor');
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct>
  distinctByNotificationsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notificationsEnabled');
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct> distinctByOnboardingDone() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'onboardingDone');
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct> distinctByOutputLanguage({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'outputLanguage',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct> distinctBySchemaVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'schemaVersion');
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct>
  distinctByTargetCostPerPortionMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'targetCostPerPortionMinor');
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct> distinctByThemeMode({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'themeMode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct> distinctByWeekStartsOn() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'weekStartsOn');
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct>
  distinctByWeeklyRecapEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'weeklyRecapEnabled');
    });
  }
}

extension UserProfileQueryProperty
    on QueryBuilder<UserProfile, UserProfile, QQueryProperty> {
  QueryBuilder<UserProfile, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<UserProfile, List<String>, QQueryOperations>
  allergiesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'allergies');
    });
  }

  QueryBuilder<UserProfile, bool, QQueryOperations>
  autoCommitCleanScansProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'autoCommitCleanScans');
    });
  }

  QueryBuilder<UserProfile, bool, QQueryOperations>
  autoLogFirstPortionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'autoLogFirstPortion');
    });
  }

  QueryBuilder<UserProfile, String, QQueryOperations> countryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'country');
    });
  }

  QueryBuilder<UserProfile, List<String>, QQueryOperations>
  cuisinesLikedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cuisinesLiked');
    });
  }

  QueryBuilder<UserProfile, String, QQueryOperations> currencyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currency');
    });
  }

  QueryBuilder<UserProfile, int, QQueryOperations>
  currencyMinorDigitsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currencyMinorDigits');
    });
  }

  QueryBuilder<UserProfile, double, QQueryOperations>
  dailyKcalTargetProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dailyKcalTarget');
    });
  }

  QueryBuilder<UserProfile, int, QQueryOperations>
  dailyPickMinuteOfDayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dailyPickMinuteOfDay');
    });
  }

  QueryBuilder<UserProfile, double, QQueryOperations>
  dailyProteinTargetGProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dailyProteinTargetG');
    });
  }

  QueryBuilder<UserProfile, int, QQueryOperations> dayRolloverHourProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dayRolloverHour');
    });
  }

  QueryBuilder<UserProfile, int, QQueryOperations> defaultPortionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'defaultPortions');
    });
  }

  QueryBuilder<UserProfile, List<String>, QQueryOperations> dietProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'diet');
    });
  }

  QueryBuilder<UserProfile, List<String>, QQueryOperations> dislikesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dislikes');
    });
  }

  QueryBuilder<UserProfile, int, QQueryOperations>
  eatingOutAvgMealMinorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'eatingOutAvgMealMinor');
    });
  }

  QueryBuilder<UserProfile, List<String>, QQueryOperations>
  equipmentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'equipment');
    });
  }

  QueryBuilder<UserProfile, FoodBasis, QQueryOperations> foodBasisProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'foodBasis');
    });
  }

  QueryBuilder<UserProfile, List<FxMemo>, QQueryOperations> fxMemoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fxMemory');
    });
  }

  QueryBuilder<UserProfile, String, QQueryOperations> geminiModelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'geminiModel');
    });
  }

  QueryBuilder<UserProfile, List<KeywordCategory>, QQueryOperations>
  learnedKeywordsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'learnedKeywords');
    });
  }

  QueryBuilder<UserProfile, bool, QQueryOperations> lookUpPricesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lookUpPrices');
    });
  }

  QueryBuilder<UserProfile, int, QQueryOperations> maxActiveMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'maxActiveMinutes');
    });
  }

  QueryBuilder<UserProfile, List<int>, QQueryOperations>
  mealReminderMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mealReminderMinutes');
    });
  }

  QueryBuilder<UserProfile, int, QQueryOperations> mealsPerDayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mealsPerDay');
    });
  }

  QueryBuilder<UserProfile, List<CategoryLimit>, QQueryOperations>
  monthlyCategoryLimitsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'monthlyCategoryLimits');
    });
  }

  QueryBuilder<UserProfile, int, QQueryOperations>
  monthlyFoodBudgetMinorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'monthlyFoodBudgetMinor');
    });
  }

  QueryBuilder<UserProfile, bool, QQueryOperations>
  notificationsEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notificationsEnabled');
    });
  }

  QueryBuilder<UserProfile, bool, QQueryOperations> onboardingDoneProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'onboardingDone');
    });
  }

  QueryBuilder<UserProfile, String, QQueryOperations> outputLanguageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'outputLanguage');
    });
  }

  QueryBuilder<UserProfile, int, QQueryOperations> schemaVersionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'schemaVersion');
    });
  }

  QueryBuilder<UserProfile, int, QQueryOperations>
  targetCostPerPortionMinorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'targetCostPerPortionMinor');
    });
  }

  QueryBuilder<UserProfile, String, QQueryOperations> themeModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'themeMode');
    });
  }

  QueryBuilder<UserProfile, int, QQueryOperations> weekStartsOnProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weekStartsOn');
    });
  }

  QueryBuilder<UserProfile, bool, QQueryOperations>
  weeklyRecapEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weeklyRecapEnabled');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const CategoryLimitSchema = Schema(
  name: r'CategoryLimit',
  id: -4720361322884841844,
  properties: {
    r'category': PropertySchema(
      id: 0,
      name: r'category',
      type: IsarType.string,
      enumMap: _CategoryLimitcategoryEnumValueMap,
    ),
    r'limitMinor': PropertySchema(
      id: 1,
      name: r'limitMinor',
      type: IsarType.long,
    ),
  },

  estimateSize: _categoryLimitEstimateSize,
  serialize: _categoryLimitSerialize,
  deserialize: _categoryLimitDeserialize,
  deserializeProp: _categoryLimitDeserializeProp,
);

int _categoryLimitEstimateSize(
  CategoryLimit object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.category.name.length * 3;
  return bytesCount;
}

void _categoryLimitSerialize(
  CategoryLimit object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.category.name);
  writer.writeLong(offsets[1], object.limitMinor);
}

CategoryLimit _categoryLimitDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CategoryLimit();
  object.category =
      _CategoryLimitcategoryValueEnumMap[reader.readStringOrNull(offsets[0])] ??
      SpendCategory.groceries;
  object.limitMinor = reader.readLong(offsets[1]);
  return object;
}

P _categoryLimitDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (_CategoryLimitcategoryValueEnumMap[reader.readStringOrNull(
                offset,
              )] ??
              SpendCategory.groceries)
          as P;
    case 1:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _CategoryLimitcategoryEnumValueMap = {
  r'groceries': r'groceries',
  r'household': r'household',
  r'clothes': r'clothes',
  r'eatingOut': r'eatingOut',
  r'entertainment': r'entertainment',
  r'other': r'other',
};
const _CategoryLimitcategoryValueEnumMap = {
  r'groceries': SpendCategory.groceries,
  r'household': SpendCategory.household,
  r'clothes': SpendCategory.clothes,
  r'eatingOut': SpendCategory.eatingOut,
  r'entertainment': SpendCategory.entertainment,
  r'other': SpendCategory.other,
};

extension CategoryLimitQueryFilter
    on QueryBuilder<CategoryLimit, CategoryLimit, QFilterCondition> {
  QueryBuilder<CategoryLimit, CategoryLimit, QAfterFilterCondition>
  categoryEqualTo(SpendCategory value, {bool caseSensitive = true}) {
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

  QueryBuilder<CategoryLimit, CategoryLimit, QAfterFilterCondition>
  categoryGreaterThan(
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

  QueryBuilder<CategoryLimit, CategoryLimit, QAfterFilterCondition>
  categoryLessThan(
    SpendCategory value, {
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

  QueryBuilder<CategoryLimit, CategoryLimit, QAfterFilterCondition>
  categoryBetween(
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

  QueryBuilder<CategoryLimit, CategoryLimit, QAfterFilterCondition>
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

  QueryBuilder<CategoryLimit, CategoryLimit, QAfterFilterCondition>
  categoryEndsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<CategoryLimit, CategoryLimit, QAfterFilterCondition>
  categoryContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<CategoryLimit, CategoryLimit, QAfterFilterCondition>
  categoryMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<CategoryLimit, CategoryLimit, QAfterFilterCondition>
  categoryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'category', value: ''),
      );
    });
  }

  QueryBuilder<CategoryLimit, CategoryLimit, QAfterFilterCondition>
  categoryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'category', value: ''),
      );
    });
  }

  QueryBuilder<CategoryLimit, CategoryLimit, QAfterFilterCondition>
  limitMinorEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'limitMinor', value: value),
      );
    });
  }

  QueryBuilder<CategoryLimit, CategoryLimit, QAfterFilterCondition>
  limitMinorGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'limitMinor',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CategoryLimit, CategoryLimit, QAfterFilterCondition>
  limitMinorLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'limitMinor',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CategoryLimit, CategoryLimit, QAfterFilterCondition>
  limitMinorBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'limitMinor',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension CategoryLimitQueryObject
    on QueryBuilder<CategoryLimit, CategoryLimit, QFilterCondition> {}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const KeywordCategorySchema = Schema(
  name: r'KeywordCategory',
  id: -5034344011247658355,
  properties: {
    r'category': PropertySchema(
      id: 0,
      name: r'category',
      type: IsarType.string,
      enumMap: _KeywordCategorycategoryEnumValueMap,
    ),
    r'keyword': PropertySchema(id: 1, name: r'keyword', type: IsarType.string),
  },

  estimateSize: _keywordCategoryEstimateSize,
  serialize: _keywordCategorySerialize,
  deserialize: _keywordCategoryDeserialize,
  deserializeProp: _keywordCategoryDeserializeProp,
);

int _keywordCategoryEstimateSize(
  KeywordCategory object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.category.name.length * 3;
  bytesCount += 3 + object.keyword.length * 3;
  return bytesCount;
}

void _keywordCategorySerialize(
  KeywordCategory object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.category.name);
  writer.writeString(offsets[1], object.keyword);
}

KeywordCategory _keywordCategoryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = KeywordCategory();
  object.category =
      _KeywordCategorycategoryValueEnumMap[reader.readStringOrNull(
        offsets[0],
      )] ??
      SpendCategory.groceries;
  object.keyword = reader.readString(offsets[1]);
  return object;
}

P _keywordCategoryDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (_KeywordCategorycategoryValueEnumMap[reader.readStringOrNull(
                offset,
              )] ??
              SpendCategory.groceries)
          as P;
    case 1:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _KeywordCategorycategoryEnumValueMap = {
  r'groceries': r'groceries',
  r'household': r'household',
  r'clothes': r'clothes',
  r'eatingOut': r'eatingOut',
  r'entertainment': r'entertainment',
  r'other': r'other',
};
const _KeywordCategorycategoryValueEnumMap = {
  r'groceries': SpendCategory.groceries,
  r'household': SpendCategory.household,
  r'clothes': SpendCategory.clothes,
  r'eatingOut': SpendCategory.eatingOut,
  r'entertainment': SpendCategory.entertainment,
  r'other': SpendCategory.other,
};

extension KeywordCategoryQueryFilter
    on QueryBuilder<KeywordCategory, KeywordCategory, QFilterCondition> {
  QueryBuilder<KeywordCategory, KeywordCategory, QAfterFilterCondition>
  categoryEqualTo(SpendCategory value, {bool caseSensitive = true}) {
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

  QueryBuilder<KeywordCategory, KeywordCategory, QAfterFilterCondition>
  categoryGreaterThan(
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

  QueryBuilder<KeywordCategory, KeywordCategory, QAfterFilterCondition>
  categoryLessThan(
    SpendCategory value, {
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

  QueryBuilder<KeywordCategory, KeywordCategory, QAfterFilterCondition>
  categoryBetween(
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

  QueryBuilder<KeywordCategory, KeywordCategory, QAfterFilterCondition>
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

  QueryBuilder<KeywordCategory, KeywordCategory, QAfterFilterCondition>
  categoryEndsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<KeywordCategory, KeywordCategory, QAfterFilterCondition>
  categoryContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<KeywordCategory, KeywordCategory, QAfterFilterCondition>
  categoryMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<KeywordCategory, KeywordCategory, QAfterFilterCondition>
  categoryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'category', value: ''),
      );
    });
  }

  QueryBuilder<KeywordCategory, KeywordCategory, QAfterFilterCondition>
  categoryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'category', value: ''),
      );
    });
  }

  QueryBuilder<KeywordCategory, KeywordCategory, QAfterFilterCondition>
  keywordEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'keyword',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KeywordCategory, KeywordCategory, QAfterFilterCondition>
  keywordGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'keyword',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KeywordCategory, KeywordCategory, QAfterFilterCondition>
  keywordLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'keyword',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KeywordCategory, KeywordCategory, QAfterFilterCondition>
  keywordBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'keyword',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KeywordCategory, KeywordCategory, QAfterFilterCondition>
  keywordStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'keyword',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KeywordCategory, KeywordCategory, QAfterFilterCondition>
  keywordEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'keyword',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KeywordCategory, KeywordCategory, QAfterFilterCondition>
  keywordContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'keyword',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KeywordCategory, KeywordCategory, QAfterFilterCondition>
  keywordMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'keyword',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KeywordCategory, KeywordCategory, QAfterFilterCondition>
  keywordIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'keyword', value: ''),
      );
    });
  }

  QueryBuilder<KeywordCategory, KeywordCategory, QAfterFilterCondition>
  keywordIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'keyword', value: ''),
      );
    });
  }
}

extension KeywordCategoryQueryObject
    on QueryBuilder<KeywordCategory, KeywordCategory, QFilterCondition> {}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const FxMemoSchema = Schema(
  name: r'FxMemo',
  id: 8291751755241215275,
  properties: {
    r'from': PropertySchema(id: 0, name: r'from', type: IsarType.string),
    r'rate': PropertySchema(id: 1, name: r'rate', type: IsarType.double),
    r'to': PropertySchema(id: 2, name: r'to', type: IsarType.string),
    r'updatedAt': PropertySchema(
      id: 3,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
  },

  estimateSize: _fxMemoEstimateSize,
  serialize: _fxMemoSerialize,
  deserialize: _fxMemoDeserialize,
  deserializeProp: _fxMemoDeserializeProp,
);

int _fxMemoEstimateSize(
  FxMemo object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.from.length * 3;
  bytesCount += 3 + object.to.length * 3;
  return bytesCount;
}

void _fxMemoSerialize(
  FxMemo object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.from);
  writer.writeDouble(offsets[1], object.rate);
  writer.writeString(offsets[2], object.to);
  writer.writeDateTime(offsets[3], object.updatedAt);
}

FxMemo _fxMemoDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = FxMemo();
  object.from = reader.readString(offsets[0]);
  object.rate = reader.readDouble(offsets[1]);
  object.to = reader.readString(offsets[2]);
  object.updatedAt = reader.readDateTime(offsets[3]);
  return object;
}

P _fxMemoDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension FxMemoQueryFilter on QueryBuilder<FxMemo, FxMemo, QFilterCondition> {
  QueryBuilder<FxMemo, FxMemo, QAfterFilterCondition> fromEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'from',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FxMemo, FxMemo, QAfterFilterCondition> fromGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'from',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FxMemo, FxMemo, QAfterFilterCondition> fromLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'from',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FxMemo, FxMemo, QAfterFilterCondition> fromBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'from',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FxMemo, FxMemo, QAfterFilterCondition> fromStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'from',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FxMemo, FxMemo, QAfterFilterCondition> fromEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'from',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FxMemo, FxMemo, QAfterFilterCondition> fromContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'from',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FxMemo, FxMemo, QAfterFilterCondition> fromMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'from',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FxMemo, FxMemo, QAfterFilterCondition> fromIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'from', value: ''),
      );
    });
  }

  QueryBuilder<FxMemo, FxMemo, QAfterFilterCondition> fromIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'from', value: ''),
      );
    });
  }

  QueryBuilder<FxMemo, FxMemo, QAfterFilterCondition> rateEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'rate',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<FxMemo, FxMemo, QAfterFilterCondition> rateGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'rate',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<FxMemo, FxMemo, QAfterFilterCondition> rateLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'rate',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<FxMemo, FxMemo, QAfterFilterCondition> rateBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'rate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<FxMemo, FxMemo, QAfterFilterCondition> toEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'to',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FxMemo, FxMemo, QAfterFilterCondition> toGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'to',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FxMemo, FxMemo, QAfterFilterCondition> toLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'to',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FxMemo, FxMemo, QAfterFilterCondition> toBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'to',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FxMemo, FxMemo, QAfterFilterCondition> toStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'to',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FxMemo, FxMemo, QAfterFilterCondition> toEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'to',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FxMemo, FxMemo, QAfterFilterCondition> toContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'to',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FxMemo, FxMemo, QAfterFilterCondition> toMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'to',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FxMemo, FxMemo, QAfterFilterCondition> toIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'to', value: ''),
      );
    });
  }

  QueryBuilder<FxMemo, FxMemo, QAfterFilterCondition> toIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'to', value: ''),
      );
    });
  }

  QueryBuilder<FxMemo, FxMemo, QAfterFilterCondition> updatedAtEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<FxMemo, FxMemo, QAfterFilterCondition> updatedAtGreaterThan(
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

  QueryBuilder<FxMemo, FxMemo, QAfterFilterCondition> updatedAtLessThan(
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

  QueryBuilder<FxMemo, FxMemo, QAfterFilterCondition> updatedAtBetween(
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

extension FxMemoQueryObject on QueryBuilder<FxMemo, FxMemo, QFilterCondition> {}
