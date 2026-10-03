// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cookbook_import.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCookbookImportCollection on Isar {
  IsarCollection<CookbookImport> get cookbookImports => this.collection();
}

const CookbookImportSchema = CollectionSchema(
  name: r'CookbookImport',
  id: -2039176752468021566,
  properties: {
    r'bookTitle': PropertySchema(
      id: 0,
      name: r'bookTitle',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'drafts': PropertySchema(
      id: 2,
      name: r'drafts',
      type: IsarType.objectList,

      target: r'CookbookDraft',
    ),
    r'entries': PropertySchema(
      id: 3,
      name: r'entries',
      type: IsarType.objectList,

      target: r'CookbookEntry',
    ),
    r'fileName': PropertySchema(
      id: 4,
      name: r'fileName',
      type: IsarType.string,
    ),
    r'filePath': PropertySchema(
      id: 5,
      name: r'filePath',
      type: IsarType.string,
    ),
    r'indexCalls': PropertySchema(
      id: 6,
      name: r'indexCalls',
      type: IsarType.long,
    ),
    r'indexDone': PropertySchema(
      id: 7,
      name: r'indexDone',
      type: IsarType.bool,
    ),
    r'lastError': PropertySchema(
      id: 8,
      name: r'lastError',
      type: IsarType.string,
    ),
    r'nextIndexPage': PropertySchema(
      id: 9,
      name: r'nextIndexPage',
      type: IsarType.long,
    ),
    r'pageCount': PropertySchema(
      id: 10,
      name: r'pageCount',
      type: IsarType.long,
    ),
    r'remoteExpiresAt': PropertySchema(
      id: 11,
      name: r'remoteExpiresAt',
      type: IsarType.dateTime,
    ),
    r'remoteName': PropertySchema(
      id: 12,
      name: r'remoteName',
      type: IsarType.string,
    ),
    r'remoteUri': PropertySchema(
      id: 13,
      name: r'remoteUri',
      type: IsarType.string,
    ),
    r'sizeBytes': PropertySchema(
      id: 14,
      name: r'sizeBytes',
      type: IsarType.long,
    ),
    r'status': PropertySchema(
      id: 15,
      name: r'status',
      type: IsarType.string,
      enumMap: _CookbookImportstatusEnumValueMap,
    ),
    r'updatedAt': PropertySchema(
      id: 16,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
  },

  estimateSize: _cookbookImportEstimateSize,
  serialize: _cookbookImportSerialize,
  deserialize: _cookbookImportDeserialize,
  deserializeProp: _cookbookImportDeserializeProp,
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
  },
  links: {},
  embeddedSchemas: {
    r'CookbookEntry': CookbookEntrySchema,
    r'CookbookDraft': CookbookDraftSchema,
    r'CookbookLine': CookbookLineSchema,
  },

  getId: _cookbookImportGetId,
  getLinks: _cookbookImportGetLinks,
  attach: _cookbookImportAttach,
  version: '3.3.2',
);

int _cookbookImportEstimateSize(
  CookbookImport object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.bookTitle.length * 3;
  bytesCount += 3 + object.drafts.length * 3;
  {
    final offsets = allOffsets[CookbookDraft]!;
    for (var i = 0; i < object.drafts.length; i++) {
      final value = object.drafts[i];
      bytesCount += CookbookDraftSchema.estimateSize(
        value,
        offsets,
        allOffsets,
      );
    }
  }
  bytesCount += 3 + object.entries.length * 3;
  {
    final offsets = allOffsets[CookbookEntry]!;
    for (var i = 0; i < object.entries.length; i++) {
      final value = object.entries[i];
      bytesCount += CookbookEntrySchema.estimateSize(
        value,
        offsets,
        allOffsets,
      );
    }
  }
  bytesCount += 3 + object.fileName.length * 3;
  bytesCount += 3 + object.filePath.length * 3;
  {
    final value = object.lastError;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.remoteName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.remoteUri;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.status.name.length * 3;
  return bytesCount;
}

void _cookbookImportSerialize(
  CookbookImport object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.bookTitle);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeObjectList<CookbookDraft>(
    offsets[2],
    allOffsets,
    CookbookDraftSchema.serialize,
    object.drafts,
  );
  writer.writeObjectList<CookbookEntry>(
    offsets[3],
    allOffsets,
    CookbookEntrySchema.serialize,
    object.entries,
  );
  writer.writeString(offsets[4], object.fileName);
  writer.writeString(offsets[5], object.filePath);
  writer.writeLong(offsets[6], object.indexCalls);
  writer.writeBool(offsets[7], object.indexDone);
  writer.writeString(offsets[8], object.lastError);
  writer.writeLong(offsets[9], object.nextIndexPage);
  writer.writeLong(offsets[10], object.pageCount);
  writer.writeDateTime(offsets[11], object.remoteExpiresAt);
  writer.writeString(offsets[12], object.remoteName);
  writer.writeString(offsets[13], object.remoteUri);
  writer.writeLong(offsets[14], object.sizeBytes);
  writer.writeString(offsets[15], object.status.name);
  writer.writeDateTime(offsets[16], object.updatedAt);
}

CookbookImport _cookbookImportDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CookbookImport();
  object.bookTitle = reader.readString(offsets[0]);
  object.createdAt = reader.readDateTime(offsets[1]);
  object.drafts =
      reader.readObjectList<CookbookDraft>(
        offsets[2],
        CookbookDraftSchema.deserialize,
        allOffsets,
        CookbookDraft(),
      ) ??
      [];
  object.entries =
      reader.readObjectList<CookbookEntry>(
        offsets[3],
        CookbookEntrySchema.deserialize,
        allOffsets,
        CookbookEntry(),
      ) ??
      [];
  object.fileName = reader.readString(offsets[4]);
  object.filePath = reader.readString(offsets[5]);
  object.id = id;
  object.indexCalls = reader.readLong(offsets[6]);
  object.indexDone = reader.readBool(offsets[7]);
  object.lastError = reader.readStringOrNull(offsets[8]);
  object.nextIndexPage = reader.readLong(offsets[9]);
  object.pageCount = reader.readLongOrNull(offsets[10]);
  object.remoteExpiresAt = reader.readDateTimeOrNull(offsets[11]);
  object.remoteName = reader.readStringOrNull(offsets[12]);
  object.remoteUri = reader.readStringOrNull(offsets[13]);
  object.sizeBytes = reader.readLong(offsets[14]);
  object.status =
      _CookbookImportstatusValueEnumMap[reader.readStringOrNull(offsets[15])] ??
      CookbookStatus.open;
  object.updatedAt = reader.readDateTime(offsets[16]);
  return object;
}

P _cookbookImportDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readObjectList<CookbookDraft>(
                offset,
                CookbookDraftSchema.deserialize,
                allOffsets,
                CookbookDraft(),
              ) ??
              [])
          as P;
    case 3:
      return (reader.readObjectList<CookbookEntry>(
                offset,
                CookbookEntrySchema.deserialize,
                allOffsets,
                CookbookEntry(),
              ) ??
              [])
          as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readBool(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readLongOrNull(offset)) as P;
    case 11:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 12:
      return (reader.readStringOrNull(offset)) as P;
    case 13:
      return (reader.readStringOrNull(offset)) as P;
    case 14:
      return (reader.readLong(offset)) as P;
    case 15:
      return (_CookbookImportstatusValueEnumMap[reader.readStringOrNull(
                offset,
              )] ??
              CookbookStatus.open)
          as P;
    case 16:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _CookbookImportstatusEnumValueMap = {
  r'open': r'open',
  r'done': r'done',
  r'discarded': r'discarded',
};
const _CookbookImportstatusValueEnumMap = {
  r'open': CookbookStatus.open,
  r'done': CookbookStatus.done,
  r'discarded': CookbookStatus.discarded,
};

Id _cookbookImportGetId(CookbookImport object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _cookbookImportGetLinks(CookbookImport object) {
  return [];
}

void _cookbookImportAttach(
  IsarCollection<dynamic> col,
  Id id,
  CookbookImport object,
) {
  object.id = id;
}

extension CookbookImportQueryWhereSort
    on QueryBuilder<CookbookImport, CookbookImport, QWhere> {
  QueryBuilder<CookbookImport, CookbookImport, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CookbookImportQueryWhere
    on QueryBuilder<CookbookImport, CookbookImport, QWhereClause> {
  QueryBuilder<CookbookImport, CookbookImport, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<CookbookImport, CookbookImport, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterWhereClause> idBetween(
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

  QueryBuilder<CookbookImport, CookbookImport, QAfterWhereClause> statusEqualTo(
    CookbookStatus status,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'status', value: [status]),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterWhereClause>
  statusNotEqualTo(CookbookStatus status) {
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
}

extension CookbookImportQueryFilter
    on QueryBuilder<CookbookImport, CookbookImport, QFilterCondition> {
  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  bookTitleEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'bookTitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  bookTitleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'bookTitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  bookTitleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'bookTitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  bookTitleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'bookTitle',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  bookTitleStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'bookTitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  bookTitleEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'bookTitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  bookTitleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'bookTitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  bookTitleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'bookTitle',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  bookTitleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'bookTitle', value: ''),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  bookTitleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'bookTitle', value: ''),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  createdAtGreaterThan(DateTime value, {bool include = false}) {
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

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  createdAtLessThan(DateTime value, {bool include = false}) {
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

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  createdAtBetween(
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

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  draftsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'drafts', length, true, length, true);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  draftsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'drafts', 0, true, 0, true);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  draftsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'drafts', 0, false, 999999, true);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  draftsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'drafts', 0, true, length, include);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  draftsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'drafts', length, include, 999999, true);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  draftsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'drafts',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  entriesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'entries', length, true, length, true);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  entriesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'entries', 0, true, 0, true);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  entriesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'entries', 0, false, 999999, true);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  entriesLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'entries', 0, true, length, include);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  entriesLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'entries', length, include, 999999, true);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  entriesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'entries',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  fileNameEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'fileName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  fileNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'fileName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  fileNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'fileName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  fileNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'fileName',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  fileNameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'fileName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  fileNameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'fileName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  fileNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'fileName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  fileNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'fileName',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  fileNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'fileName', value: ''),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  fileNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'fileName', value: ''),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  filePathEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'filePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  filePathGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'filePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  filePathLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'filePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  filePathBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'filePath',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  filePathStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'filePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  filePathEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'filePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  filePathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'filePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  filePathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'filePath',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  filePathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'filePath', value: ''),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  filePathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'filePath', value: ''),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
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

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
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

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition> idBetween(
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

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  indexCallsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'indexCalls', value: value),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  indexCallsGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'indexCalls',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  indexCallsLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'indexCalls',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  indexCallsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'indexCalls',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  indexDoneEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'indexDone', value: value),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  lastErrorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastError'),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  lastErrorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastError'),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  lastErrorEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'lastError',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  lastErrorGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastError',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  lastErrorLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastError',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  lastErrorBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastError',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  lastErrorStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'lastError',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  lastErrorEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'lastError',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  lastErrorContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'lastError',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  lastErrorMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'lastError',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  lastErrorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastError', value: ''),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  lastErrorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'lastError', value: ''),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  nextIndexPageEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'nextIndexPage', value: value),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  nextIndexPageGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'nextIndexPage',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  nextIndexPageLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'nextIndexPage',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  nextIndexPageBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'nextIndexPage',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  pageCountIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'pageCount'),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  pageCountIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'pageCount'),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  pageCountEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'pageCount', value: value),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  pageCountGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'pageCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  pageCountLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'pageCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  pageCountBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'pageCount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  remoteExpiresAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'remoteExpiresAt'),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  remoteExpiresAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'remoteExpiresAt'),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  remoteExpiresAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'remoteExpiresAt', value: value),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  remoteExpiresAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'remoteExpiresAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  remoteExpiresAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'remoteExpiresAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  remoteExpiresAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'remoteExpiresAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  remoteNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'remoteName'),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  remoteNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'remoteName'),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  remoteNameEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'remoteName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  remoteNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'remoteName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  remoteNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'remoteName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  remoteNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'remoteName',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  remoteNameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'remoteName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  remoteNameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'remoteName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  remoteNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'remoteName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  remoteNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'remoteName',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  remoteNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'remoteName', value: ''),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  remoteNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'remoteName', value: ''),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  remoteUriIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'remoteUri'),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  remoteUriIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'remoteUri'),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  remoteUriEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'remoteUri',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  remoteUriGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'remoteUri',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  remoteUriLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'remoteUri',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  remoteUriBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'remoteUri',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  remoteUriStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'remoteUri',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  remoteUriEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'remoteUri',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  remoteUriContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'remoteUri',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  remoteUriMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'remoteUri',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  remoteUriIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'remoteUri', value: ''),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  remoteUriIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'remoteUri', value: ''),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  sizeBytesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sizeBytes', value: value),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  sizeBytesGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sizeBytes',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  sizeBytesLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sizeBytes',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  sizeBytesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sizeBytes',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  statusEqualTo(CookbookStatus value, {bool caseSensitive = true}) {
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

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  statusGreaterThan(
    CookbookStatus value, {
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

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  statusLessThan(
    CookbookStatus value, {
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

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  statusBetween(
    CookbookStatus lower,
    CookbookStatus upper, {
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

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  statusStartsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  statusEndsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  statusContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  statusMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'status', value: ''),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'status', value: ''),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
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

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  updatedAtLessThan(DateTime value, {bool include = false}) {
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

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  updatedAtBetween(
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

extension CookbookImportQueryObject
    on QueryBuilder<CookbookImport, CookbookImport, QFilterCondition> {
  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  draftsElement(FilterQuery<CookbookDraft> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'drafts');
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterFilterCondition>
  entriesElement(FilterQuery<CookbookEntry> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'entries');
    });
  }
}

extension CookbookImportQueryLinks
    on QueryBuilder<CookbookImport, CookbookImport, QFilterCondition> {}

extension CookbookImportQuerySortBy
    on QueryBuilder<CookbookImport, CookbookImport, QSortBy> {
  QueryBuilder<CookbookImport, CookbookImport, QAfterSortBy> sortByBookTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookTitle', Sort.asc);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterSortBy>
  sortByBookTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookTitle', Sort.desc);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterSortBy>
  sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterSortBy> sortByFileName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileName', Sort.asc);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterSortBy>
  sortByFileNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileName', Sort.desc);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterSortBy> sortByFilePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filePath', Sort.asc);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterSortBy>
  sortByFilePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filePath', Sort.desc);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterSortBy>
  sortByIndexCalls() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'indexCalls', Sort.asc);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterSortBy>
  sortByIndexCallsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'indexCalls', Sort.desc);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterSortBy> sortByIndexDone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'indexDone', Sort.asc);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterSortBy>
  sortByIndexDoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'indexDone', Sort.desc);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterSortBy> sortByLastError() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastError', Sort.asc);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterSortBy>
  sortByLastErrorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastError', Sort.desc);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterSortBy>
  sortByNextIndexPage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextIndexPage', Sort.asc);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterSortBy>
  sortByNextIndexPageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextIndexPage', Sort.desc);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterSortBy> sortByPageCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pageCount', Sort.asc);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterSortBy>
  sortByPageCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pageCount', Sort.desc);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterSortBy>
  sortByRemoteExpiresAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteExpiresAt', Sort.asc);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterSortBy>
  sortByRemoteExpiresAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteExpiresAt', Sort.desc);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterSortBy>
  sortByRemoteName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteName', Sort.asc);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterSortBy>
  sortByRemoteNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteName', Sort.desc);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterSortBy> sortByRemoteUri() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteUri', Sort.asc);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterSortBy>
  sortByRemoteUriDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteUri', Sort.desc);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterSortBy> sortBySizeBytes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sizeBytes', Sort.asc);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterSortBy>
  sortBySizeBytesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sizeBytes', Sort.desc);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterSortBy>
  sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterSortBy>
  sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension CookbookImportQuerySortThenBy
    on QueryBuilder<CookbookImport, CookbookImport, QSortThenBy> {
  QueryBuilder<CookbookImport, CookbookImport, QAfterSortBy> thenByBookTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookTitle', Sort.asc);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterSortBy>
  thenByBookTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookTitle', Sort.desc);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterSortBy>
  thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterSortBy> thenByFileName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileName', Sort.asc);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterSortBy>
  thenByFileNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileName', Sort.desc);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterSortBy> thenByFilePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filePath', Sort.asc);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterSortBy>
  thenByFilePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filePath', Sort.desc);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterSortBy>
  thenByIndexCalls() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'indexCalls', Sort.asc);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterSortBy>
  thenByIndexCallsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'indexCalls', Sort.desc);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterSortBy> thenByIndexDone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'indexDone', Sort.asc);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterSortBy>
  thenByIndexDoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'indexDone', Sort.desc);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterSortBy> thenByLastError() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastError', Sort.asc);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterSortBy>
  thenByLastErrorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastError', Sort.desc);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterSortBy>
  thenByNextIndexPage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextIndexPage', Sort.asc);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterSortBy>
  thenByNextIndexPageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextIndexPage', Sort.desc);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterSortBy> thenByPageCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pageCount', Sort.asc);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterSortBy>
  thenByPageCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pageCount', Sort.desc);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterSortBy>
  thenByRemoteExpiresAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteExpiresAt', Sort.asc);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterSortBy>
  thenByRemoteExpiresAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteExpiresAt', Sort.desc);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterSortBy>
  thenByRemoteName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteName', Sort.asc);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterSortBy>
  thenByRemoteNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteName', Sort.desc);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterSortBy> thenByRemoteUri() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteUri', Sort.asc);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterSortBy>
  thenByRemoteUriDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteUri', Sort.desc);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterSortBy> thenBySizeBytes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sizeBytes', Sort.asc);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterSortBy>
  thenBySizeBytesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sizeBytes', Sort.desc);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterSortBy>
  thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QAfterSortBy>
  thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension CookbookImportQueryWhereDistinct
    on QueryBuilder<CookbookImport, CookbookImport, QDistinct> {
  QueryBuilder<CookbookImport, CookbookImport, QDistinct> distinctByBookTitle({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bookTitle', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QDistinct>
  distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QDistinct> distinctByFileName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fileName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QDistinct> distinctByFilePath({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'filePath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QDistinct>
  distinctByIndexCalls() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'indexCalls');
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QDistinct>
  distinctByIndexDone() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'indexDone');
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QDistinct> distinctByLastError({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastError', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QDistinct>
  distinctByNextIndexPage() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nextIndexPage');
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QDistinct>
  distinctByPageCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pageCount');
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QDistinct>
  distinctByRemoteExpiresAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'remoteExpiresAt');
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QDistinct> distinctByRemoteName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'remoteName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QDistinct> distinctByRemoteUri({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'remoteUri', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QDistinct>
  distinctBySizeBytes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sizeBytes');
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QDistinct> distinctByStatus({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CookbookImport, CookbookImport, QDistinct>
  distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension CookbookImportQueryProperty
    on QueryBuilder<CookbookImport, CookbookImport, QQueryProperty> {
  QueryBuilder<CookbookImport, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CookbookImport, String, QQueryOperations> bookTitleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bookTitle');
    });
  }

  QueryBuilder<CookbookImport, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<CookbookImport, List<CookbookDraft>, QQueryOperations>
  draftsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'drafts');
    });
  }

  QueryBuilder<CookbookImport, List<CookbookEntry>, QQueryOperations>
  entriesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'entries');
    });
  }

  QueryBuilder<CookbookImport, String, QQueryOperations> fileNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fileName');
    });
  }

  QueryBuilder<CookbookImport, String, QQueryOperations> filePathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'filePath');
    });
  }

  QueryBuilder<CookbookImport, int, QQueryOperations> indexCallsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'indexCalls');
    });
  }

  QueryBuilder<CookbookImport, bool, QQueryOperations> indexDoneProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'indexDone');
    });
  }

  QueryBuilder<CookbookImport, String?, QQueryOperations> lastErrorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastError');
    });
  }

  QueryBuilder<CookbookImport, int, QQueryOperations> nextIndexPageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nextIndexPage');
    });
  }

  QueryBuilder<CookbookImport, int?, QQueryOperations> pageCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pageCount');
    });
  }

  QueryBuilder<CookbookImport, DateTime?, QQueryOperations>
  remoteExpiresAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'remoteExpiresAt');
    });
  }

  QueryBuilder<CookbookImport, String?, QQueryOperations> remoteNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'remoteName');
    });
  }

  QueryBuilder<CookbookImport, String?, QQueryOperations> remoteUriProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'remoteUri');
    });
  }

  QueryBuilder<CookbookImport, int, QQueryOperations> sizeBytesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sizeBytes');
    });
  }

  QueryBuilder<CookbookImport, CookbookStatus, QQueryOperations>
  statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<CookbookImport, DateTime, QQueryOperations> updatedAtProperty() {
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

const CookbookEntrySchema = Schema(
  name: r'CookbookEntry',
  id: -998821704044516415,
  properties: {
    r'attempts': PropertySchema(id: 0, name: r'attempts', type: IsarType.long),
    r'page': PropertySchema(id: 1, name: r'page', type: IsarType.long),
    r'state': PropertySchema(
      id: 2,
      name: r'state',
      type: IsarType.string,
      enumMap: _CookbookEntrystateEnumValueMap,
    ),
    r'title': PropertySchema(id: 3, name: r'title', type: IsarType.string),
  },

  estimateSize: _cookbookEntryEstimateSize,
  serialize: _cookbookEntrySerialize,
  deserialize: _cookbookEntryDeserialize,
  deserializeProp: _cookbookEntryDeserializeProp,
);

int _cookbookEntryEstimateSize(
  CookbookEntry object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.state.name.length * 3;
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _cookbookEntrySerialize(
  CookbookEntry object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.attempts);
  writer.writeLong(offsets[1], object.page);
  writer.writeString(offsets[2], object.state.name);
  writer.writeString(offsets[3], object.title);
}

CookbookEntry _cookbookEntryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CookbookEntry();
  object.attempts = reader.readLong(offsets[0]);
  object.page = reader.readLongOrNull(offsets[1]);
  object.state =
      _CookbookEntrystateValueEnumMap[reader.readStringOrNull(offsets[2])] ??
      CookbookEntryState.pending;
  object.title = reader.readString(offsets[3]);
  return object;
}

P _cookbookEntryDeserializeProp<P>(
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
      return (_CookbookEntrystateValueEnumMap[reader.readStringOrNull(
                offset,
              )] ??
              CookbookEntryState.pending)
          as P;
    case 3:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _CookbookEntrystateEnumValueMap = {
  r'pending': r'pending',
  r'done': r'done',
  r'notFound': r'notFound',
  r'failed': r'failed',
};
const _CookbookEntrystateValueEnumMap = {
  r'pending': CookbookEntryState.pending,
  r'done': CookbookEntryState.done,
  r'notFound': CookbookEntryState.notFound,
  r'failed': CookbookEntryState.failed,
};

extension CookbookEntryQueryFilter
    on QueryBuilder<CookbookEntry, CookbookEntry, QFilterCondition> {
  QueryBuilder<CookbookEntry, CookbookEntry, QAfterFilterCondition>
  attemptsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'attempts', value: value),
      );
    });
  }

  QueryBuilder<CookbookEntry, CookbookEntry, QAfterFilterCondition>
  attemptsGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'attempts',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CookbookEntry, CookbookEntry, QAfterFilterCondition>
  attemptsLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'attempts',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CookbookEntry, CookbookEntry, QAfterFilterCondition>
  attemptsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'attempts',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<CookbookEntry, CookbookEntry, QAfterFilterCondition>
  pageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'page'),
      );
    });
  }

  QueryBuilder<CookbookEntry, CookbookEntry, QAfterFilterCondition>
  pageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'page'),
      );
    });
  }

  QueryBuilder<CookbookEntry, CookbookEntry, QAfterFilterCondition> pageEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'page', value: value),
      );
    });
  }

  QueryBuilder<CookbookEntry, CookbookEntry, QAfterFilterCondition>
  pageGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'page',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CookbookEntry, CookbookEntry, QAfterFilterCondition>
  pageLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'page',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CookbookEntry, CookbookEntry, QAfterFilterCondition> pageBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'page',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<CookbookEntry, CookbookEntry, QAfterFilterCondition>
  stateEqualTo(CookbookEntryState value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'state',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookbookEntry, CookbookEntry, QAfterFilterCondition>
  stateGreaterThan(
    CookbookEntryState value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'state',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookbookEntry, CookbookEntry, QAfterFilterCondition>
  stateLessThan(
    CookbookEntryState value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'state',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookbookEntry, CookbookEntry, QAfterFilterCondition>
  stateBetween(
    CookbookEntryState lower,
    CookbookEntryState upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'state',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookbookEntry, CookbookEntry, QAfterFilterCondition>
  stateStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'state',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookbookEntry, CookbookEntry, QAfterFilterCondition>
  stateEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'state',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookbookEntry, CookbookEntry, QAfterFilterCondition>
  stateContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'state',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookbookEntry, CookbookEntry, QAfterFilterCondition>
  stateMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'state',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookbookEntry, CookbookEntry, QAfterFilterCondition>
  stateIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'state', value: ''),
      );
    });
  }

  QueryBuilder<CookbookEntry, CookbookEntry, QAfterFilterCondition>
  stateIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'state', value: ''),
      );
    });
  }

  QueryBuilder<CookbookEntry, CookbookEntry, QAfterFilterCondition>
  titleEqualTo(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<CookbookEntry, CookbookEntry, QAfterFilterCondition>
  titleGreaterThan(
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

  QueryBuilder<CookbookEntry, CookbookEntry, QAfterFilterCondition>
  titleLessThan(
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

  QueryBuilder<CookbookEntry, CookbookEntry, QAfterFilterCondition>
  titleBetween(
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

  QueryBuilder<CookbookEntry, CookbookEntry, QAfterFilterCondition>
  titleStartsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<CookbookEntry, CookbookEntry, QAfterFilterCondition>
  titleEndsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<CookbookEntry, CookbookEntry, QAfterFilterCondition>
  titleContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<CookbookEntry, CookbookEntry, QAfterFilterCondition>
  titleMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<CookbookEntry, CookbookEntry, QAfterFilterCondition>
  titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<CookbookEntry, CookbookEntry, QAfterFilterCondition>
  titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'title', value: ''),
      );
    });
  }
}

extension CookbookEntryQueryObject
    on QueryBuilder<CookbookEntry, CookbookEntry, QFilterCondition> {}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const CookbookDraftSchema = Schema(
  name: r'CookbookDraft',
  id: 7662160812382659761,
  properties: {
    r'cookMinutes': PropertySchema(
      id: 0,
      name: r'cookMinutes',
      type: IsarType.long,
    ),
    r'entry': PropertySchema(id: 1, name: r'entry', type: IsarType.long),
    r'flags': PropertySchema(id: 2, name: r'flags', type: IsarType.stringList),
    r'ingredients': PropertySchema(
      id: 3,
      name: r'ingredients',
      type: IsarType.objectList,

      target: r'CookbookLine',
    ),
    r'page': PropertySchema(id: 4, name: r'page', type: IsarType.long),
    r'prepMinutes': PropertySchema(
      id: 5,
      name: r'prepMinutes',
      type: IsarType.long,
    ),
    r'recipeId': PropertySchema(id: 6, name: r'recipeId', type: IsarType.long),
    r'servings': PropertySchema(id: 7, name: r'servings', type: IsarType.long),
    r'steps': PropertySchema(id: 8, name: r'steps', type: IsarType.stringList),
    r'tags': PropertySchema(id: 9, name: r'tags', type: IsarType.stringList),
    r'title': PropertySchema(id: 10, name: r'title', type: IsarType.string),
  },

  estimateSize: _cookbookDraftEstimateSize,
  serialize: _cookbookDraftSerialize,
  deserialize: _cookbookDraftDeserialize,
  deserializeProp: _cookbookDraftDeserializeProp,
);

int _cookbookDraftEstimateSize(
  CookbookDraft object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.flags.length * 3;
  {
    for (var i = 0; i < object.flags.length; i++) {
      final value = object.flags[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.ingredients.length * 3;
  {
    final offsets = allOffsets[CookbookLine]!;
    for (var i = 0; i < object.ingredients.length; i++) {
      final value = object.ingredients[i];
      bytesCount += CookbookLineSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  bytesCount += 3 + object.steps.length * 3;
  {
    for (var i = 0; i < object.steps.length; i++) {
      final value = object.steps[i];
      bytesCount += value.length * 3;
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
  return bytesCount;
}

void _cookbookDraftSerialize(
  CookbookDraft object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.cookMinutes);
  writer.writeLong(offsets[1], object.entry);
  writer.writeStringList(offsets[2], object.flags);
  writer.writeObjectList<CookbookLine>(
    offsets[3],
    allOffsets,
    CookbookLineSchema.serialize,
    object.ingredients,
  );
  writer.writeLong(offsets[4], object.page);
  writer.writeLong(offsets[5], object.prepMinutes);
  writer.writeLong(offsets[6], object.recipeId);
  writer.writeLong(offsets[7], object.servings);
  writer.writeStringList(offsets[8], object.steps);
  writer.writeStringList(offsets[9], object.tags);
  writer.writeString(offsets[10], object.title);
}

CookbookDraft _cookbookDraftDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CookbookDraft();
  object.cookMinutes = reader.readLong(offsets[0]);
  object.entry = reader.readLong(offsets[1]);
  object.flags = reader.readStringList(offsets[2]) ?? [];
  object.ingredients =
      reader.readObjectList<CookbookLine>(
        offsets[3],
        CookbookLineSchema.deserialize,
        allOffsets,
        CookbookLine(),
      ) ??
      [];
  object.page = reader.readLongOrNull(offsets[4]);
  object.prepMinutes = reader.readLong(offsets[5]);
  object.recipeId = reader.readLongOrNull(offsets[6]);
  object.servings = reader.readLong(offsets[7]);
  object.steps = reader.readStringList(offsets[8]) ?? [];
  object.tags = reader.readStringList(offsets[9]) ?? [];
  object.title = reader.readString(offsets[10]);
  return object;
}

P _cookbookDraftDeserializeProp<P>(
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
      return (reader.readStringList(offset) ?? []) as P;
    case 3:
      return (reader.readObjectList<CookbookLine>(
                offset,
                CookbookLineSchema.deserialize,
                allOffsets,
                CookbookLine(),
              ) ??
              [])
          as P;
    case 4:
      return (reader.readLongOrNull(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readLongOrNull(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readStringList(offset) ?? []) as P;
    case 9:
      return (reader.readStringList(offset) ?? []) as P;
    case 10:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension CookbookDraftQueryFilter
    on QueryBuilder<CookbookDraft, CookbookDraft, QFilterCondition> {
  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  cookMinutesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'cookMinutes', value: value),
      );
    });
  }

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  cookMinutesGreaterThan(int value, {bool include = false}) {
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

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  cookMinutesLessThan(int value, {bool include = false}) {
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

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  cookMinutesBetween(
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

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  entryEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'entry', value: value),
      );
    });
  }

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  entryGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'entry',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  entryLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'entry',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  entryBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'entry',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  flagsElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'flags',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  flagsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'flags',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  flagsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'flags',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  flagsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'flags',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  flagsElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'flags',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  flagsElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'flags',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  flagsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'flags',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  flagsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'flags',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  flagsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'flags', value: ''),
      );
    });
  }

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  flagsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'flags', value: ''),
      );
    });
  }

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  flagsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'flags', length, true, length, true);
    });
  }

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  flagsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'flags', 0, true, 0, true);
    });
  }

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  flagsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'flags', 0, false, 999999, true);
    });
  }

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  flagsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'flags', 0, true, length, include);
    });
  }

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  flagsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'flags', length, include, 999999, true);
    });
  }

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  flagsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'flags',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  ingredientsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'ingredients', length, true, length, true);
    });
  }

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  ingredientsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'ingredients', 0, true, 0, true);
    });
  }

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  ingredientsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'ingredients', 0, false, 999999, true);
    });
  }

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  ingredientsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'ingredients', 0, true, length, include);
    });
  }

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  ingredientsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'ingredients', length, include, 999999, true);
    });
  }

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  ingredientsLengthBetween(
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

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  pageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'page'),
      );
    });
  }

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  pageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'page'),
      );
    });
  }

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition> pageEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'page', value: value),
      );
    });
  }

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  pageGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'page',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  pageLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'page',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition> pageBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'page',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  prepMinutesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'prepMinutes', value: value),
      );
    });
  }

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  prepMinutesGreaterThan(int value, {bool include = false}) {
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

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  prepMinutesLessThan(int value, {bool include = false}) {
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

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  prepMinutesBetween(
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

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  recipeIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'recipeId'),
      );
    });
  }

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  recipeIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'recipeId'),
      );
    });
  }

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  recipeIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'recipeId', value: value),
      );
    });
  }

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  recipeIdGreaterThan(int? value, {bool include = false}) {
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

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  recipeIdLessThan(int? value, {bool include = false}) {
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

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  recipeIdBetween(
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

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  servingsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'servings', value: value),
      );
    });
  }

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  servingsGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'servings',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  servingsLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'servings',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  servingsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'servings',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  stepsElementEqualTo(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  stepsElementGreaterThan(
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

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  stepsElementLessThan(
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

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  stepsElementBetween(
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

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  stepsElementStartsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  stepsElementEndsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  stepsElementContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  stepsElementMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  stepsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'steps', value: ''),
      );
    });
  }

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  stepsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'steps', value: ''),
      );
    });
  }

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  stepsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'steps', length, true, length, true);
    });
  }

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  stepsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'steps', 0, true, 0, true);
    });
  }

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  stepsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'steps', 0, false, 999999, true);
    });
  }

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  stepsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'steps', 0, true, length, include);
    });
  }

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  stepsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'steps', length, include, 999999, true);
    });
  }

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  stepsLengthBetween(
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

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  tagsElementEqualTo(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  tagsElementGreaterThan(
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

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  tagsElementLessThan(
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

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  tagsElementBetween(
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

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  tagsElementStartsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  tagsElementEndsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  tagsElementContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  tagsElementMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  tagsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'tags', value: ''),
      );
    });
  }

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  tagsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'tags', value: ''),
      );
    });
  }

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  tagsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'tags', length, true, length, true);
    });
  }

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  tagsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'tags', 0, true, 0, true);
    });
  }

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  tagsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'tags', 0, false, 999999, true);
    });
  }

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  tagsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'tags', 0, true, length, include);
    });
  }

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  tagsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'tags', length, include, 999999, true);
    });
  }

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  tagsLengthBetween(
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

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  titleEqualTo(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  titleGreaterThan(
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

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  titleLessThan(
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

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  titleBetween(
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

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  titleStartsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  titleEndsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  titleContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  titleMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'title', value: ''),
      );
    });
  }
}

extension CookbookDraftQueryObject
    on QueryBuilder<CookbookDraft, CookbookDraft, QFilterCondition> {
  QueryBuilder<CookbookDraft, CookbookDraft, QAfterFilterCondition>
  ingredientsElement(FilterQuery<CookbookLine> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'ingredients');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const CookbookLineSchema = Schema(
  name: r'CookbookLine',
  id: -5413668936975616430,
  properties: {
    r'asWritten': PropertySchema(
      id: 0,
      name: r'asWritten',
      type: IsarType.string,
    ),
    r'key': PropertySchema(id: 1, name: r'key', type: IsarType.string),
    r'name': PropertySchema(id: 2, name: r'name', type: IsarType.string),
    r'optional': PropertySchema(id: 3, name: r'optional', type: IsarType.bool),
    r'qty': PropertySchema(id: 4, name: r'qty', type: IsarType.double),
    r'unit': PropertySchema(
      id: 5,
      name: r'unit',
      type: IsarType.string,
      enumMap: _CookbookLineunitEnumValueMap,
    ),
  },

  estimateSize: _cookbookLineEstimateSize,
  serialize: _cookbookLineSerialize,
  deserialize: _cookbookLineDeserialize,
  deserializeProp: _cookbookLineDeserializeProp,
);

int _cookbookLineEstimateSize(
  CookbookLine object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.asWritten.length * 3;
  bytesCount += 3 + object.key.length * 3;
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.unit.name.length * 3;
  return bytesCount;
}

void _cookbookLineSerialize(
  CookbookLine object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.asWritten);
  writer.writeString(offsets[1], object.key);
  writer.writeString(offsets[2], object.name);
  writer.writeBool(offsets[3], object.optional);
  writer.writeDouble(offsets[4], object.qty);
  writer.writeString(offsets[5], object.unit.name);
}

CookbookLine _cookbookLineDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CookbookLine();
  object.asWritten = reader.readString(offsets[0]);
  object.key = reader.readString(offsets[1]);
  object.name = reader.readString(offsets[2]);
  object.optional = reader.readBool(offsets[3]);
  object.qty = reader.readDouble(offsets[4]);
  object.unit =
      _CookbookLineunitValueEnumMap[reader.readStringOrNull(offsets[5])] ??
      BaseUnit.g;
  return object;
}

P _cookbookLineDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readDouble(offset)) as P;
    case 5:
      return (_CookbookLineunitValueEnumMap[reader.readStringOrNull(offset)] ??
              BaseUnit.g)
          as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _CookbookLineunitEnumValueMap = {r'g': r'g', r'ml': r'ml', r'pc': r'pc'};
const _CookbookLineunitValueEnumMap = {
  r'g': BaseUnit.g,
  r'ml': BaseUnit.ml,
  r'pc': BaseUnit.pc,
};

extension CookbookLineQueryFilter
    on QueryBuilder<CookbookLine, CookbookLine, QFilterCondition> {
  QueryBuilder<CookbookLine, CookbookLine, QAfterFilterCondition>
  asWrittenEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'asWritten',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookbookLine, CookbookLine, QAfterFilterCondition>
  asWrittenGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'asWritten',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookbookLine, CookbookLine, QAfterFilterCondition>
  asWrittenLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'asWritten',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookbookLine, CookbookLine, QAfterFilterCondition>
  asWrittenBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'asWritten',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookbookLine, CookbookLine, QAfterFilterCondition>
  asWrittenStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'asWritten',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookbookLine, CookbookLine, QAfterFilterCondition>
  asWrittenEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'asWritten',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookbookLine, CookbookLine, QAfterFilterCondition>
  asWrittenContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'asWritten',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookbookLine, CookbookLine, QAfterFilterCondition>
  asWrittenMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'asWritten',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CookbookLine, CookbookLine, QAfterFilterCondition>
  asWrittenIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'asWritten', value: ''),
      );
    });
  }

  QueryBuilder<CookbookLine, CookbookLine, QAfterFilterCondition>
  asWrittenIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'asWritten', value: ''),
      );
    });
  }

  QueryBuilder<CookbookLine, CookbookLine, QAfterFilterCondition> keyEqualTo(
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

  QueryBuilder<CookbookLine, CookbookLine, QAfterFilterCondition>
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

  QueryBuilder<CookbookLine, CookbookLine, QAfterFilterCondition> keyLessThan(
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

  QueryBuilder<CookbookLine, CookbookLine, QAfterFilterCondition> keyBetween(
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

  QueryBuilder<CookbookLine, CookbookLine, QAfterFilterCondition> keyStartsWith(
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

  QueryBuilder<CookbookLine, CookbookLine, QAfterFilterCondition> keyEndsWith(
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

  QueryBuilder<CookbookLine, CookbookLine, QAfterFilterCondition> keyContains(
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

  QueryBuilder<CookbookLine, CookbookLine, QAfterFilterCondition> keyMatches(
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

  QueryBuilder<CookbookLine, CookbookLine, QAfterFilterCondition> keyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'key', value: ''),
      );
    });
  }

  QueryBuilder<CookbookLine, CookbookLine, QAfterFilterCondition>
  keyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'key', value: ''),
      );
    });
  }

  QueryBuilder<CookbookLine, CookbookLine, QAfterFilterCondition> nameEqualTo(
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

  QueryBuilder<CookbookLine, CookbookLine, QAfterFilterCondition>
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

  QueryBuilder<CookbookLine, CookbookLine, QAfterFilterCondition> nameLessThan(
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

  QueryBuilder<CookbookLine, CookbookLine, QAfterFilterCondition> nameBetween(
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

  QueryBuilder<CookbookLine, CookbookLine, QAfterFilterCondition>
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

  QueryBuilder<CookbookLine, CookbookLine, QAfterFilterCondition> nameEndsWith(
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

  QueryBuilder<CookbookLine, CookbookLine, QAfterFilterCondition> nameContains(
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

  QueryBuilder<CookbookLine, CookbookLine, QAfterFilterCondition> nameMatches(
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

  QueryBuilder<CookbookLine, CookbookLine, QAfterFilterCondition>
  nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<CookbookLine, CookbookLine, QAfterFilterCondition>
  nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<CookbookLine, CookbookLine, QAfterFilterCondition>
  optionalEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'optional', value: value),
      );
    });
  }

  QueryBuilder<CookbookLine, CookbookLine, QAfterFilterCondition> qtyEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'qty',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<CookbookLine, CookbookLine, QAfterFilterCondition>
  qtyGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'qty',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<CookbookLine, CookbookLine, QAfterFilterCondition> qtyLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'qty',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<CookbookLine, CookbookLine, QAfterFilterCondition> qtyBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'qty',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<CookbookLine, CookbookLine, QAfterFilterCondition> unitEqualTo(
    BaseUnit value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<CookbookLine, CookbookLine, QAfterFilterCondition>
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

  QueryBuilder<CookbookLine, CookbookLine, QAfterFilterCondition> unitLessThan(
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

  QueryBuilder<CookbookLine, CookbookLine, QAfterFilterCondition> unitBetween(
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

  QueryBuilder<CookbookLine, CookbookLine, QAfterFilterCondition>
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

  QueryBuilder<CookbookLine, CookbookLine, QAfterFilterCondition> unitEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<CookbookLine, CookbookLine, QAfterFilterCondition> unitContains(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<CookbookLine, CookbookLine, QAfterFilterCondition> unitMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<CookbookLine, CookbookLine, QAfterFilterCondition>
  unitIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'unit', value: ''),
      );
    });
  }

  QueryBuilder<CookbookLine, CookbookLine, QAfterFilterCondition>
  unitIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'unit', value: ''),
      );
    });
  }
}

extension CookbookLineQueryObject
    on QueryBuilder<CookbookLine, CookbookLine, QFilterCondition> {}
