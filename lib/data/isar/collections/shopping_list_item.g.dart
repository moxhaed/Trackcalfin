// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shopping_list_item.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetShoppingListItemCollection on Isar {
  IsarCollection<ShoppingListItem> get shoppingListItems => this.collection();
}

const ShoppingListItemSchema = CollectionSchema(
  name: r'ShoppingListItem',
  id: -3816175988203906805,
  properties: {
    r'addedAt': PropertySchema(
      id: 0,
      name: r'addedAt',
      type: IsarType.dateTime,
    ),
    r'amount': PropertySchema(id: 1, name: r'amount', type: IsarType.string),
    r'doneAt': PropertySchema(id: 2, name: r'doneAt', type: IsarType.dateTime),
    r'ingredientKey': PropertySchema(
      id: 3,
      name: r'ingredientKey',
      type: IsarType.string,
    ),
    r'name': PropertySchema(id: 4, name: r'name', type: IsarType.string),
  },

  estimateSize: _shoppingListItemEstimateSize,
  serialize: _shoppingListItemSerialize,
  deserialize: _shoppingListItemDeserialize,
  deserializeProp: _shoppingListItemDeserializeProp,
  idName: r'id',
  indexes: {
    r'ingredientKey': IndexSchema(
      id: -100855915596880430,
      name: r'ingredientKey',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'ingredientKey',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _shoppingListItemGetId,
  getLinks: _shoppingListItemGetLinks,
  attach: _shoppingListItemAttach,
  version: '3.3.2',
);

int _shoppingListItemEstimateSize(
  ShoppingListItem object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.amount;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.ingredientKey;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.name.length * 3;
  return bytesCount;
}

void _shoppingListItemSerialize(
  ShoppingListItem object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.addedAt);
  writer.writeString(offsets[1], object.amount);
  writer.writeDateTime(offsets[2], object.doneAt);
  writer.writeString(offsets[3], object.ingredientKey);
  writer.writeString(offsets[4], object.name);
}

ShoppingListItem _shoppingListItemDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ShoppingListItem();
  object.addedAt = reader.readDateTime(offsets[0]);
  object.amount = reader.readStringOrNull(offsets[1]);
  object.doneAt = reader.readDateTimeOrNull(offsets[2]);
  object.id = id;
  object.ingredientKey = reader.readStringOrNull(offsets[3]);
  object.name = reader.readString(offsets[4]);
  return object;
}

P _shoppingListItemDeserializeProp<P>(
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
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _shoppingListItemGetId(ShoppingListItem object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _shoppingListItemGetLinks(ShoppingListItem object) {
  return [];
}

void _shoppingListItemAttach(
  IsarCollection<dynamic> col,
  Id id,
  ShoppingListItem object,
) {
  object.id = id;
}

extension ShoppingListItemQueryWhereSort
    on QueryBuilder<ShoppingListItem, ShoppingListItem, QWhere> {
  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ShoppingListItemQueryWhere
    on QueryBuilder<ShoppingListItem, ShoppingListItem, QWhereClause> {
  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterWhereClause>
  idNotEqualTo(Id id) {
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

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterWhereClause> idBetween(
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

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterWhereClause>
  ingredientKeyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'ingredientKey', value: [null]),
      );
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterWhereClause>
  ingredientKeyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'ingredientKey',
          lower: [null],
          includeLower: false,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterWhereClause>
  ingredientKeyEqualTo(String? ingredientKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'ingredientKey',
          value: [ingredientKey],
        ),
      );
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterWhereClause>
  ingredientKeyNotEqualTo(String? ingredientKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'ingredientKey',
                lower: [],
                upper: [ingredientKey],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'ingredientKey',
                lower: [ingredientKey],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'ingredientKey',
                lower: [ingredientKey],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'ingredientKey',
                lower: [],
                upper: [ingredientKey],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension ShoppingListItemQueryFilter
    on QueryBuilder<ShoppingListItem, ShoppingListItem, QFilterCondition> {
  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
  addedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'addedAt', value: value),
      );
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
  addedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'addedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
  addedAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'addedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
  addedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'addedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
  amountIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'amount'),
      );
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
  amountIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'amount'),
      );
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
  amountEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'amount',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
  amountGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'amount',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
  amountLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'amount',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
  amountBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'amount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
  amountStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'amount',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
  amountEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'amount',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
  amountContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'amount',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
  amountMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'amount',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
  amountIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'amount', value: ''),
      );
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
  amountIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'amount', value: ''),
      );
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
  doneAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'doneAt'),
      );
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
  doneAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'doneAt'),
      );
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
  doneAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'doneAt', value: value),
      );
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
  doneAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'doneAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
  doneAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'doneAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
  doneAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'doneAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
  idGreaterThan(Id value, {bool include = false}) {
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

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
  idLessThan(Id value, {bool include = false}) {
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

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
  idBetween(
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

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
  ingredientKeyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'ingredientKey'),
      );
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
  ingredientKeyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'ingredientKey'),
      );
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
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

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
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

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
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

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
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

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
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

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
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

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
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

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
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

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
  ingredientKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'ingredientKey', value: ''),
      );
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
  ingredientKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'ingredientKey', value: ''),
      );
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
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

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
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

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
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

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
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

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
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

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
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

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
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

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
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

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
  nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
  nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'name', value: ''),
      );
    });
  }
}

extension ShoppingListItemQueryObject
    on QueryBuilder<ShoppingListItem, ShoppingListItem, QFilterCondition> {}

extension ShoppingListItemQueryLinks
    on QueryBuilder<ShoppingListItem, ShoppingListItem, QFilterCondition> {}

extension ShoppingListItemQuerySortBy
    on QueryBuilder<ShoppingListItem, ShoppingListItem, QSortBy> {
  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterSortBy>
  sortByAddedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addedAt', Sort.asc);
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterSortBy>
  sortByAddedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addedAt', Sort.desc);
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterSortBy>
  sortByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterSortBy>
  sortByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.desc);
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterSortBy>
  sortByDoneAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'doneAt', Sort.asc);
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterSortBy>
  sortByDoneAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'doneAt', Sort.desc);
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterSortBy>
  sortByIngredientKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ingredientKey', Sort.asc);
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterSortBy>
  sortByIngredientKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ingredientKey', Sort.desc);
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterSortBy>
  sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }
}

extension ShoppingListItemQuerySortThenBy
    on QueryBuilder<ShoppingListItem, ShoppingListItem, QSortThenBy> {
  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterSortBy>
  thenByAddedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addedAt', Sort.asc);
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterSortBy>
  thenByAddedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addedAt', Sort.desc);
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterSortBy>
  thenByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterSortBy>
  thenByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.desc);
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterSortBy>
  thenByDoneAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'doneAt', Sort.asc);
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterSortBy>
  thenByDoneAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'doneAt', Sort.desc);
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterSortBy>
  thenByIngredientKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ingredientKey', Sort.asc);
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterSortBy>
  thenByIngredientKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ingredientKey', Sort.desc);
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterSortBy>
  thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }
}

extension ShoppingListItemQueryWhereDistinct
    on QueryBuilder<ShoppingListItem, ShoppingListItem, QDistinct> {
  QueryBuilder<ShoppingListItem, ShoppingListItem, QDistinct>
  distinctByAddedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'addedAt');
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QDistinct> distinctByAmount({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'amount', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QDistinct>
  distinctByDoneAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'doneAt');
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QDistinct>
  distinctByIngredientKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'ingredientKey',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QDistinct> distinctByName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }
}

extension ShoppingListItemQueryProperty
    on QueryBuilder<ShoppingListItem, ShoppingListItem, QQueryProperty> {
  QueryBuilder<ShoppingListItem, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ShoppingListItem, DateTime, QQueryOperations> addedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'addedAt');
    });
  }

  QueryBuilder<ShoppingListItem, String?, QQueryOperations> amountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'amount');
    });
  }

  QueryBuilder<ShoppingListItem, DateTime?, QQueryOperations> doneAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'doneAt');
    });
  }

  QueryBuilder<ShoppingListItem, String?, QQueryOperations>
  ingredientKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ingredientKey');
    });
  }

  QueryBuilder<ShoppingListItem, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }
}
