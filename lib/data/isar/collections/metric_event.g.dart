// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metric_event.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMetricEventCollection on Isar {
  IsarCollection<MetricEvent> get metricEvents => this.collection();
}

const MetricEventSchema = CollectionSchema(
  name: r'MetricEvent',
  id: -2467149497370000390,
  properties: {
    r'action': PropertySchema(id: 0, name: r'action', type: IsarType.string),
    r'at': PropertySchema(id: 1, name: r'at', type: IsarType.dateTime),
    r'millis': PropertySchema(id: 2, name: r'millis', type: IsarType.long),
  },

  estimateSize: _metricEventEstimateSize,
  serialize: _metricEventSerialize,
  deserialize: _metricEventDeserialize,
  deserializeProp: _metricEventDeserializeProp,
  idName: r'id',
  indexes: {
    r'action': IndexSchema(
      id: -2948318935682215514,
      name: r'action',
      unique: false,
      replace: false,
      properties: [IndexPropertySchema(name: r'action', type: IndexType.hash, caseSensitive: true)],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _metricEventGetId,
  getLinks: _metricEventGetLinks,
  attach: _metricEventAttach,
  version: '3.3.2',
);

int _metricEventEstimateSize(MetricEvent object, List<int> offsets, Map<Type, List<int>> allOffsets) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.action.length * 3;
  return bytesCount;
}

void _metricEventSerialize(MetricEvent object, IsarWriter writer, List<int> offsets, Map<Type, List<int>> allOffsets) {
  writer.writeString(offsets[0], object.action);
  writer.writeDateTime(offsets[1], object.at);
  writer.writeLong(offsets[2], object.millis);
}

MetricEvent _metricEventDeserialize(Id id, IsarReader reader, List<int> offsets, Map<Type, List<int>> allOffsets) {
  final object = MetricEvent();
  object.action = reader.readString(offsets[0]);
  object.at = reader.readDateTime(offsets[1]);
  object.id = id;
  object.millis = reader.readLong(offsets[2]);
  return object;
}

P _metricEventDeserializeProp<P>(IsarReader reader, int propertyId, int offset, Map<Type, List<int>> allOffsets) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _metricEventGetId(MetricEvent object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _metricEventGetLinks(MetricEvent object) {
  return [];
}

void _metricEventAttach(IsarCollection<dynamic> col, Id id, MetricEvent object) {
  object.id = id;
}

extension MetricEventQueryWhereSort on QueryBuilder<MetricEvent, MetricEvent, QWhere> {
  QueryBuilder<MetricEvent, MetricEvent, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension MetricEventQueryWhere on QueryBuilder<MetricEvent, MetricEvent, QWhereClause> {
  QueryBuilder<MetricEvent, MetricEvent, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<MetricEvent, MetricEvent, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<MetricEvent, MetricEvent, QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.greaterThan(lower: id, includeLower: include));
    });
  }

  QueryBuilder<MetricEvent, MetricEvent, QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.lessThan(upper: id, includeUpper: include));
    });
  }

  QueryBuilder<MetricEvent, MetricEvent, QAfterWhereClause> idBetween(
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

  QueryBuilder<MetricEvent, MetricEvent, QAfterWhereClause> actionEqualTo(String action) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(indexName: r'action', value: [action]));
    });
  }

  QueryBuilder<MetricEvent, MetricEvent, QAfterWhereClause> actionNotEqualTo(String action) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(indexName: r'action', lower: [], upper: [action], includeUpper: false),
            )
            .addWhereClause(
              IndexWhereClause.between(indexName: r'action', lower: [action], includeLower: false, upper: []),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(indexName: r'action', lower: [action], includeLower: false, upper: []),
            )
            .addWhereClause(
              IndexWhereClause.between(indexName: r'action', lower: [], upper: [action], includeUpper: false),
            );
      }
    });
  }
}

extension MetricEventQueryFilter on QueryBuilder<MetricEvent, MetricEvent, QFilterCondition> {
  QueryBuilder<MetricEvent, MetricEvent, QAfterFilterCondition> actionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'action', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<MetricEvent, MetricEvent, QAfterFilterCondition> actionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(include: include, property: r'action', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<MetricEvent, MetricEvent, QAfterFilterCondition> actionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'action', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<MetricEvent, MetricEvent, QAfterFilterCondition> actionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'action',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MetricEvent, MetricEvent, QAfterFilterCondition> actionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(property: r'action', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<MetricEvent, MetricEvent, QAfterFilterCondition> actionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(property: r'action', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<MetricEvent, MetricEvent, QAfterFilterCondition> actionContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(property: r'action', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<MetricEvent, MetricEvent, QAfterFilterCondition> actionMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(property: r'action', wildcard: pattern, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<MetricEvent, MetricEvent, QAfterFilterCondition> actionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'action', value: ''));
    });
  }

  QueryBuilder<MetricEvent, MetricEvent, QAfterFilterCondition> actionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(property: r'action', value: ''));
    });
  }

  QueryBuilder<MetricEvent, MetricEvent, QAfterFilterCondition> atEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'at', value: value));
    });
  }

  QueryBuilder<MetricEvent, MetricEvent, QAfterFilterCondition> atGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(include: include, property: r'at', value: value));
    });
  }

  QueryBuilder<MetricEvent, MetricEvent, QAfterFilterCondition> atLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(include: include, property: r'at', value: value));
    });
  }

  QueryBuilder<MetricEvent, MetricEvent, QAfterFilterCondition> atBetween(
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

  QueryBuilder<MetricEvent, MetricEvent, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'id', value: value));
    });
  }

  QueryBuilder<MetricEvent, MetricEvent, QAfterFilterCondition> idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(include: include, property: r'id', value: value));
    });
  }

  QueryBuilder<MetricEvent, MetricEvent, QAfterFilterCondition> idLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(include: include, property: r'id', value: value));
    });
  }

  QueryBuilder<MetricEvent, MetricEvent, QAfterFilterCondition> idBetween(
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

  QueryBuilder<MetricEvent, MetricEvent, QAfterFilterCondition> millisEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'millis', value: value));
    });
  }

  QueryBuilder<MetricEvent, MetricEvent, QAfterFilterCondition> millisGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(include: include, property: r'millis', value: value));
    });
  }

  QueryBuilder<MetricEvent, MetricEvent, QAfterFilterCondition> millisLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(include: include, property: r'millis', value: value));
    });
  }

  QueryBuilder<MetricEvent, MetricEvent, QAfterFilterCondition> millisBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'millis',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension MetricEventQueryObject on QueryBuilder<MetricEvent, MetricEvent, QFilterCondition> {}

extension MetricEventQueryLinks on QueryBuilder<MetricEvent, MetricEvent, QFilterCondition> {}

extension MetricEventQuerySortBy on QueryBuilder<MetricEvent, MetricEvent, QSortBy> {
  QueryBuilder<MetricEvent, MetricEvent, QAfterSortBy> sortByAction() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'action', Sort.asc);
    });
  }

  QueryBuilder<MetricEvent, MetricEvent, QAfterSortBy> sortByActionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'action', Sort.desc);
    });
  }

  QueryBuilder<MetricEvent, MetricEvent, QAfterSortBy> sortByAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'at', Sort.asc);
    });
  }

  QueryBuilder<MetricEvent, MetricEvent, QAfterSortBy> sortByAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'at', Sort.desc);
    });
  }

  QueryBuilder<MetricEvent, MetricEvent, QAfterSortBy> sortByMillis() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'millis', Sort.asc);
    });
  }

  QueryBuilder<MetricEvent, MetricEvent, QAfterSortBy> sortByMillisDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'millis', Sort.desc);
    });
  }
}

extension MetricEventQuerySortThenBy on QueryBuilder<MetricEvent, MetricEvent, QSortThenBy> {
  QueryBuilder<MetricEvent, MetricEvent, QAfterSortBy> thenByAction() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'action', Sort.asc);
    });
  }

  QueryBuilder<MetricEvent, MetricEvent, QAfterSortBy> thenByActionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'action', Sort.desc);
    });
  }

  QueryBuilder<MetricEvent, MetricEvent, QAfterSortBy> thenByAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'at', Sort.asc);
    });
  }

  QueryBuilder<MetricEvent, MetricEvent, QAfterSortBy> thenByAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'at', Sort.desc);
    });
  }

  QueryBuilder<MetricEvent, MetricEvent, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MetricEvent, MetricEvent, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MetricEvent, MetricEvent, QAfterSortBy> thenByMillis() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'millis', Sort.asc);
    });
  }

  QueryBuilder<MetricEvent, MetricEvent, QAfterSortBy> thenByMillisDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'millis', Sort.desc);
    });
  }
}

extension MetricEventQueryWhereDistinct on QueryBuilder<MetricEvent, MetricEvent, QDistinct> {
  QueryBuilder<MetricEvent, MetricEvent, QDistinct> distinctByAction({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'action', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MetricEvent, MetricEvent, QDistinct> distinctByAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'at');
    });
  }

  QueryBuilder<MetricEvent, MetricEvent, QDistinct> distinctByMillis() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'millis');
    });
  }
}

extension MetricEventQueryProperty on QueryBuilder<MetricEvent, MetricEvent, QQueryProperty> {
  QueryBuilder<MetricEvent, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MetricEvent, String, QQueryOperations> actionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'action');
    });
  }

  QueryBuilder<MetricEvent, DateTime, QQueryOperations> atProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'at');
    });
  }

  QueryBuilder<MetricEvent, int, QQueryOperations> millisProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'millis');
    });
  }
}
