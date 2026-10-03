import '../../../core/enums.dart';
import '../json_reader.dart';
import 'enum_codec.dart';

/// Prompt H, index pass: what recipes a PDF cookbook holds, and on which pages.
class CookbookIndexOutput {
  CookbookIndexOutput({
    required this.isCookbook,
    required this.bookTitle,
    required this.pageCount,
    required this.recipes,
    required this.nextPage,
  });
  final bool isCookbook;
  final String? bookTitle;
  final int? pageCount;
  final List<(String, int?)> recipes;

  /// Where the next pass starts; null when the index reached the end of the book.
  final int? nextPage;

  static ParseResult<CookbookIndexOutput> parse(Map<String, dynamic> m) {
    final j = JsonReader();
    final isCookbook = j.boolean(m, 'is_cookbook', r'$', fallback: true);
    final pageCount = j.integer(m, 'page_count', r'$', nullable: true);
    if (pageCount != null && pageCount < 1) j.error(r'$.page_count', 'must be >= 1');
    final nextPage = j.integer(m, 'next_page', r'$', nullable: true);
    if (nextPage != null && nextPage < 1) j.error(r'$.next_page', 'must be >= 1');
    final recipes = <(String, int?)>[];
    for (final (i, r) in j.list(m, 'recipes', r'$').indexed) {
      final p = '\$.recipes[$i]';
      if (r is! Map) {
        j.error(p, 'must be an object');
        continue;
      }
      final title = j.str(r, 'title', p)?.trim();
      if (title != null && title.isEmpty) j.error('$p.title', 'must not be empty');
      final page = j.integer(r, 'page', p, nullable: true);
      if (page != null && page < 1) j.error('$p.page', 'must be >= 1 (the first page of the PDF is 1)');
      if (title != null && title.isNotEmpty) recipes.add((title, page));
    }
    final bookTitle = j.str(m, 'book_title', r'$', nullable: true)?.trim();
    if (j.errors.isNotEmpty) return ParseResult(null, j.errors);
    return ParseResult(
      CookbookIndexOutput(
        isCookbook: isCookbook,
        bookTitle: bookTitle == null || bookTitle.isEmpty ? null : bookTitle,
        pageCount: pageCount,
        recipes: recipes,
        nextPage: nextPage,
      ),
      const [],
    );
  }
}

class CookbookLineDto {
  CookbookLineDto({
    required this.asWritten,
    required this.name,
    required this.key,
    required this.qty,
    required this.unit,
    required this.optional,
  });
  final String asWritten;
  final String name;
  final String key;

  /// For the whole recipe.
  final double qty;
  final BaseUnit unit;
  final bool optional;
}

class CookbookRecipeDto {
  CookbookRecipeDto({
    required this.id,
    required this.found,
    required this.title,
    this.page,
    this.servings = 1,
    this.prepMinutes = 0,
    this.cookMinutes = 0,
    this.ingredients = const [],
    this.steps = const [],
    this.tags = const [],
  });
  final int id;
  final bool found;
  final String title;
  final int? page;
  final int servings;
  final int prepMinutes;
  final int cookMinutes;
  final List<CookbookLineDto> ingredients;
  final List<String> steps;
  final List<String> tags;
}

/// Prompt H, recipe passes: the recipes asked for by id, each found or not.
class CookbookRecipesOutput {
  CookbookRecipesOutput(this.recipes);
  final List<CookbookRecipeDto> recipes;

  static final keyPattern = RegExp(r'^[a-z][a-z0-9_]{1,40}$');

  /// [ids] are the ids the request asked for: each must come back exactly once.
  static ParseResult<CookbookRecipesOutput> parse(Map<String, dynamic> m, {required Set<int> ids}) {
    final j = JsonReader();
    final out = <CookbookRecipeDto>[];
    final seen = <int>{};
    for (final (i, r) in j.list(m, 'recipes', r'$').indexed) {
      final p = '\$.recipes[$i]';
      if (r is! Map) {
        j.error(p, 'must be an object');
        continue;
      }
      final id = j.integer(r, 'id', p);
      if (id == null) continue;
      if (!ids.contains(id)) {
        j.error('$p.id', '$id was not asked for; return only the ids in recipes_to_extract');
        continue;
      }
      if (!seen.add(id)) {
        j.error('$p.id', '$id appears twice; return each recipe once');
        continue;
      }
      final found = j.boolean(r, 'found', p, fallback: true);
      final title = j.str(r, 'title', p, nullable: true) ?? '';
      final page = j.integer(r, 'page', p, nullable: true);
      if (page != null && page < 1) j.error('$p.page', 'must be >= 1 (the first page of the PDF is 1)');
      if (!found) {
        out.add(CookbookRecipeDto(id: id, found: false, title: title, page: page));
        continue;
      }
      final servings = j.integer(r, 'servings', p, nullable: true);
      if (servings == null) {
        j.error('$p.servings', 'is required when found is true (integer >= 1)');
      } else if (servings < 1 || servings > 100) {
        j.error('$p.servings', 'must be between 1 and 100');
      }
      final prep = j.integer(r, 'prep_minutes', p, nullable: true);
      final cook = j.integer(r, 'cook_minutes', p, nullable: true);
      if ((prep ?? 0) < 0) j.error('$p.prep_minutes', 'must be >= 0');
      if ((cook ?? 0) < 0) j.error('$p.cook_minutes', 'must be >= 0');
      final lines = <CookbookLineDto>[];
      final raw = j.list(r, 'ingredients', p);
      if (raw.isEmpty) j.error('$p.ingredients', 'must not be empty when found is true');
      for (final (k, it) in raw.indexed) {
        final q = '$p.ingredients[$k]';
        if (it is! Map) {
          j.error(q, 'must be an object');
          continue;
        }
        final name = j.str(it, 'name', q)?.trim();
        if (name != null && name.isEmpty) j.error('$q.name', 'must not be empty');
        final key = j.str(it, 'key', q);
        if (key != null && !keyPattern.hasMatch(key)) {
          j.error('$q.key', "'$key' must be a pantry key or a new snake_case key like \"red_onion\"");
        }
        final qty = j.number(it, 'qty', q);
        if (qty != null && qty <= 0) {
          j.error('$q.qty', 'must be > 0: give a realistic amount for "to taste" or "for frying"');
        }
        final unit = j.enumOf(it, 'unit', q, EnumCodec.unit);
        lines.add(
          CookbookLineDto(
            asWritten: (j.str(it, 'as_written', q, nullable: true) ?? '').trim(),
            name: name ?? '',
            key: key ?? '',
            qty: qty ?? 0,
            unit: unit ?? BaseUnit.g,
            optional: j.boolean(it, 'optional', q),
          ),
        );
      }
      final steps = [
        for (final s in j.strings(r, 'steps', p))
          if (s.trim().isNotEmpty) s.trim(),
      ];
      if (steps.isEmpty) j.error('$p.steps', 'must contain at least one step when found is true');
      out.add(
        CookbookRecipeDto(
          id: id,
          found: true,
          title: title,
          page: page,
          servings: servings ?? 1,
          prepMinutes: prep ?? 0,
          cookMinutes: cook ?? 0,
          ingredients: lines,
          steps: steps,
          tags: j.strings(r, 'tags', p),
        ),
      );
    }
    final missing = ids.difference(seen).toList()..sort();
    if (missing.isNotEmpty) {
      j.error(
        r'$.recipes',
        'has no entry for id ${missing.join(', ')}: return one per id, found false if not in the PDF',
      );
    }
    if (j.errors.isNotEmpty) return ParseResult(null, j.errors);
    return ParseResult(CookbookRecipesOutput(out), const []);
  }
}
