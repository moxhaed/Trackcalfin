// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nutrition.dart';

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const NutritionSchema = Schema(
  name: r'Nutrition',
  id: 7179252175094545754,
  properties: {
    r'carbsG': PropertySchema(id: 0, name: r'carbsG', type: IsarType.double),
    r'fatG': PropertySchema(id: 1, name: r'fatG', type: IsarType.double),
    r'fiberG': PropertySchema(id: 2, name: r'fiberG', type: IsarType.double),
    r'kcal': PropertySchema(id: 3, name: r'kcal', type: IsarType.double),
    r'proteinG': PropertySchema(id: 4, name: r'proteinG', type: IsarType.double),
  },

  estimateSize: _nutritionEstimateSize,
  serialize: _nutritionSerialize,
  deserialize: _nutritionDeserialize,
  deserializeProp: _nutritionDeserializeProp,
);

int _nutritionEstimateSize(Nutrition object, List<int> offsets, Map<Type, List<int>> allOffsets) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _nutritionSerialize(Nutrition object, IsarWriter writer, List<int> offsets, Map<Type, List<int>> allOffsets) {
  writer.writeDouble(offsets[0], object.carbsG);
  writer.writeDouble(offsets[1], object.fatG);
  writer.writeDouble(offsets[2], object.fiberG);
  writer.writeDouble(offsets[3], object.kcal);
  writer.writeDouble(offsets[4], object.proteinG);
}

Nutrition _nutritionDeserialize(Id id, IsarReader reader, List<int> offsets, Map<Type, List<int>> allOffsets) {
  final object = Nutrition(
    carbsG: reader.readDoubleOrNull(offsets[0]) ?? 0,
    fatG: reader.readDoubleOrNull(offsets[1]) ?? 0,
    fiberG: reader.readDoubleOrNull(offsets[2]) ?? 0,
    kcal: reader.readDoubleOrNull(offsets[3]) ?? 0,
    proteinG: reader.readDoubleOrNull(offsets[4]) ?? 0,
  );
  return object;
}

P _nutritionDeserializeProp<P>(IsarReader reader, int propertyId, int offset, Map<Type, List<int>> allOffsets) {
  switch (propertyId) {
    case 0:
      return (reader.readDoubleOrNull(offset) ?? 0) as P;
    case 1:
      return (reader.readDoubleOrNull(offset) ?? 0) as P;
    case 2:
      return (reader.readDoubleOrNull(offset) ?? 0) as P;
    case 3:
      return (reader.readDoubleOrNull(offset) ?? 0) as P;
    case 4:
      return (reader.readDoubleOrNull(offset) ?? 0) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension NutritionQueryFilter on QueryBuilder<Nutrition, Nutrition, QFilterCondition> {
  QueryBuilder<Nutrition, Nutrition, QAfterFilterCondition> carbsGEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'carbsG', value: value, epsilon: epsilon));
    });
  }

  QueryBuilder<Nutrition, Nutrition, QAfterFilterCondition> carbsGGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(include: include, property: r'carbsG', value: value, epsilon: epsilon),
      );
    });
  }

  QueryBuilder<Nutrition, Nutrition, QAfterFilterCondition> carbsGLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'carbsG', value: value, epsilon: epsilon),
      );
    });
  }

  QueryBuilder<Nutrition, Nutrition, QAfterFilterCondition> carbsGBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'carbsG',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Nutrition, Nutrition, QAfterFilterCondition> fatGEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'fatG', value: value, epsilon: epsilon));
    });
  }

  QueryBuilder<Nutrition, Nutrition, QAfterFilterCondition> fatGGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(include: include, property: r'fatG', value: value, epsilon: epsilon),
      );
    });
  }

  QueryBuilder<Nutrition, Nutrition, QAfterFilterCondition> fatGLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'fatG', value: value, epsilon: epsilon),
      );
    });
  }

  QueryBuilder<Nutrition, Nutrition, QAfterFilterCondition> fatGBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'fatG',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Nutrition, Nutrition, QAfterFilterCondition> fiberGEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'fiberG', value: value, epsilon: epsilon));
    });
  }

  QueryBuilder<Nutrition, Nutrition, QAfterFilterCondition> fiberGGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(include: include, property: r'fiberG', value: value, epsilon: epsilon),
      );
    });
  }

  QueryBuilder<Nutrition, Nutrition, QAfterFilterCondition> fiberGLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'fiberG', value: value, epsilon: epsilon),
      );
    });
  }

  QueryBuilder<Nutrition, Nutrition, QAfterFilterCondition> fiberGBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'fiberG',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Nutrition, Nutrition, QAfterFilterCondition> kcalEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'kcal', value: value, epsilon: epsilon));
    });
  }

  QueryBuilder<Nutrition, Nutrition, QAfterFilterCondition> kcalGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(include: include, property: r'kcal', value: value, epsilon: epsilon),
      );
    });
  }

  QueryBuilder<Nutrition, Nutrition, QAfterFilterCondition> kcalLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'kcal', value: value, epsilon: epsilon),
      );
    });
  }

  QueryBuilder<Nutrition, Nutrition, QAfterFilterCondition> kcalBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'kcal',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Nutrition, Nutrition, QAfterFilterCondition> proteinGEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'proteinG', value: value, epsilon: epsilon));
    });
  }

  QueryBuilder<Nutrition, Nutrition, QAfterFilterCondition> proteinGGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(include: include, property: r'proteinG', value: value, epsilon: epsilon),
      );
    });
  }

  QueryBuilder<Nutrition, Nutrition, QAfterFilterCondition> proteinGLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'proteinG', value: value, epsilon: epsilon),
      );
    });
  }

  QueryBuilder<Nutrition, Nutrition, QAfterFilterCondition> proteinGBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'proteinG',
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

extension NutritionQueryObject on QueryBuilder<Nutrition, Nutrition, QFilterCondition> {}
