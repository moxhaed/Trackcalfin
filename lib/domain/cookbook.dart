import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import '../core/enums.dart';
import '../data/isar/collections/cookbook_import.dart';
import '../data/isar/collections/ingredient.dart';
import '../data/isar/collections/recipe.dart';
import 'feasibility.dart';
import 'ingredient_matcher.dart';
import 'nutrition.dart';
import 'stock_index.dart';
import 'validation/recipe_validator.dart';

/// What can be told about a PDF from its bytes, without a PDF library.
class CookbookPdf {
  const CookbookPdf._();

  static bool looksLikePdf(Uint8List bytes) =>
      bytes.length > 5 && bytes[0] == 0x25 && bytes[1] == 0x50 && bytes[2] == 0x44 && bytes[3] == 0x46; // %PDF

  static final _linearized = RegExp(r'/Linearized\b[^>]*?/N\s+(\d+)');
  static final _pagesNode = RegExp(r'/Type\s*/Pages\b');
  static final _count = RegExp(r'/Count\s+(\d+)');
  static final _page = RegExp(r'/Type\s*/Page\b');

  /// The page count the file states: a linearized file's /N, else the largest /Count of a
  /// /Pages node, else the /Page objects counted. Null when the page tree is compressed
  /// (object streams); the model reports the count then.
  static int? pageCount(Uint8List bytes) {
    final s = latin1.decode(bytes, allowInvalid: true);
    final lin = _linearized.firstMatch(s.substring(0, math.min(s.length, 4096)));
    if (lin != null) return int.parse(lin.group(1)!);
    var best = 0;
    for (final m in _pagesNode.allMatches(s)) {
      final open = s.lastIndexOf('<<', m.start);
      final close = s.indexOf('>>', m.end);
      if (open < 0 || close < 0) continue;
      final c = _count.firstMatch(s.substring(open, close));
      if (c != null) best = math.max(best, int.parse(c.group(1)!));
    }
    if (best > 0) return best;
    final pages = _page.allMatches(s).length;
    return pages > 0 ? pages : null;
  }
}

/// How the import walks through a book: the index in passes, then a few recipes per call.
class CookbookPlanner {
  const CookbookPlanner._();

  static final _nonWord = RegExp(r'[^\p{L}\p{N}]+', unicode: true);

  /// "Hummus with Spiced Lamb!" and "hummus with spiced lamb" are the same recipe.
  static String normalizeTitle(String title) => title.toLowerCase().replaceAll(_nonWord, ' ').trim();

  static String truncate(String s, int max) => s.length <= max ? s : '${s.substring(0, max - 1).trimRight()}…';

  /// Adds the index entries not listed yet to [entries]; returns how many were new.
  static int addToIndex(List<CookbookEntry> entries, Iterable<(String, int?)> found) {
    final seen = {for (final e in entries) normalizeTitle(e.title)};
    var added = 0;
    for (final (title, page) in found) {
      final key = normalizeTitle(title);
      if (key.isEmpty || !seen.add(key)) continue;
      entries.add(
        CookbookEntry()
          ..title = truncate(title.trim(), 120)
          ..page = page,
      );
      added++;
    }
    return added;
  }

  /// The entries to read next: pending ones in book order. A batch that failed is read again
  /// in halves, so one recipe the model can't read doesn't hold up the others.
  static List<int> nextBatch(List<CookbookEntry> entries, {required int size}) {
    final pending = [
      for (final (i, e) in entries.indexed)
        if (e.state == CookbookEntryState.pending) i,
    ];
    if (pending.isEmpty) return const [];
    pending.sort((a, b) {
      final pa = entries[a].page ?? 1 << 30;
      final pb = entries[b].page ?? 1 << 30;
      return pa != pb ? pa.compareTo(pb) : a.compareTo(b);
    });
    final n = math.max(1, size >> entries[pending.first].attempts.clamp(0, 10));
    return pending.take(n).toList();
  }

  /// "pages 41–60", "page 41", or "8 recipes" when the index gave no pages.
  static String pagesLabel(List<CookbookEntry> entries, List<int> batch) {
    final pages = [for (final i in batch) ?entries[i].page];
    if (pages.isEmpty) return batch.length == 1 ? '1 recipe' : '${batch.length} recipes';
    final lo = pages.reduce(math.min);
    final hi = pages.reduce(math.max);
    return lo == hi ? 'page $lo' : 'pages $lo–$hi';
  }

  /// What the next pass does, for the progress line.
  static String nextLabel(CookbookImport job, {required int batchSize}) {
    if (!job.indexDone) {
      return job.nextIndexPage <= 1 ? 'Finding the recipes' : 'Finding more recipes from page ${job.nextIndexPage}';
    }
    final batch = nextBatch(job.entries, size: batchSize);
    return batch.isEmpty ? 'Done reading' : 'Reading ${pagesLabel(job.entries, batch)}';
  }
}

/// Matches cookbook ingredients to the pantry ([IngredientMatcher]: key, then a close name),
/// remembering each answer: a book names "olive oil" and "salt" in most recipes.
class CookbookMatcher {
  CookbookMatcher(Iterable<Ingredient> pantry) : _matcher = IngredientMatcher(pantry);
  final IngredientMatcher _matcher;
  final _memo = <String, Ingredient?>{};

  Ingredient? resolve(String key, String name) => _memo.putIfAbsent('$key|${name.toLowerCase()}', () {
    final m = _matcher.resolve(key: key, name: name);
    return m.kind == MatchKind.none ? null : m.ingredient;
  });
}

/// Have and missing for one cookbook recipe, from the user's own stock and prices.
class CookbookFit {
  CookbookFit({
    required this.feasibility,
    required this.total,
    required this.missing,
    required this.short,
    required this.unpriced,
    required this.costPerPortionMinor,
  });
  final FeasibilityResult feasibility;

  /// Ingredient rows (optional ones are left out of the recipe).
  final int total;

  /// Not in the pantry at all.
  final List<String> missing;

  /// In the pantry, but not enough for the recipe's portions.
  final List<String> short;

  /// Pantry items without a price yet: the cost counts them as free.
  final int unpriced;

  /// What the pantry items cost per portion, at the user's prices. Missing items add nothing.
  final int costPerPortionMinor;

  int get have => total - missing.length - short.length;
  bool get ready => feasibility.ready;

  /// "You have 7 of 9 · missing tahini, sumac".
  String get summary {
    if (ready) return 'You have all $total';
    final parts = ['You have $have of $total'];
    String names(List<String> xs) =>
        [...xs.take(3).map((n) => n.toLowerCase()), if (xs.length > 3) '+${xs.length - 3}'].join(', ');
    if (missing.isNotEmpty) parts.add('missing ${names(missing)}');
    if (short.isNotEmpty) parts.add('short on ${names(short)}');
    return parts.join(' · ');
  }
}

/// Turns a draft read from the book into a recipe: Dart matches every ingredient to the
/// pantry and computes cost and stock. Nothing the model says about prices is used.
class CookbookReview {
  const CookbookReview._();

  static double _round(double v) => (v * 100).round() / 100;

  static Recipe toRecipe(CookbookDraft d, {required String book, required CookbookMatcher matcher, StockIndex? stock}) {
    final servings = math.max(1, d.servings);
    final items = <RecipeIngredient>[];
    final omitted = <String>[];
    for (final l in d.ingredients) {
      if (l.optional) {
        omitted.add(l.name);
        continue;
      }
      final ing = matcher.resolve(l.key, l.name);
      final key = ing?.key ?? l.key;
      // The same item twice ("oil for the dressing", "oil for frying") is one row, so stock
      // is checked against what the whole recipe needs.
      final same = items.where((x) => x.key == key && x.unit == l.unit).firstOrNull;
      if (same != null) {
        same.qtyPerPortion = _round(same.qtyPerPortion + l.qty / servings);
        continue;
      }
      items.add(
        RecipeIngredient()
          ..key = key
          ..ingredientId = ing?.id
          ..name = l.name
          ..qtyPerPortion = _round(l.qty / servings)
          ..unit = l.unit
          ..role = IngredientRole.stock,
      );
    }
    final r = Recipe()
      ..title = d.title
      ..origin = RecipeOrigin.cookbook
      ..status = RecipeStatus.saved
      ..sourceBook = book
      ..sourcePage = d.page
      ..defaultPortions = servings.clamp(1, 12)
      ..prepMinutes = d.prepMinutes
      ..cookMinutes = d.cookMinutes
      ..activeMinutes = d.prepMinutes
      ..fridgeLifeDays = 3
      ..ingredients = items
      ..steps = [...d.steps]
      ..tags = d.tags.where(RecipeValidator.allowedTags.contains).toList()
      ..omitted = omitted
      ..validationFlags = [...d.flags];
    if (stock != null) {
      final n = NutritionEngine.compute(items, stock);
      r
        ..perPortion = n.perPortion
        ..costPerPortionMinor = n.costPerPortionMinor;
    }
    return r;
  }

  static CookbookFit fit(Recipe r, StockIndex stock, {int? portions}) {
    final f = FeasibilityChecker.check(
      r.ingredients,
      portions ?? (r.lastPortionsCooked > 0 ? r.lastPortionsCooked : r.defaultPortions),
      stock,
    );
    final used = [
      for (final ri in r.ingredients)
        if (ri.role == IngredientRole.stock) ?stock.resolve(ri),
    ];
    return CookbookFit(
      feasibility: f,
      total: r.ingredients.length,
      missing: f.missing,
      short: [for (final s in f.shortfalls) s.item.name],
      unpriced: used.where((i) => i.avgCostPerUnitMinor <= 0).length,
      costPerPortionMinor: NutritionEngine.compute(r.ingredients, stock).costPerPortionMinor,
    );
  }

  /// Points rows that weren't in the pantry at items bought since. True when one changed.
  static bool relink(Recipe r, StockIndex stock, CookbookMatcher matcher) {
    var changed = false;
    for (final ri in r.ingredients) {
      if (ri.role != IngredientRole.stock || stock.resolve(ri) != null) continue;
      final ing = matcher.resolve(ri.key, ri.name);
      if (ing == null) continue;
      ri
        ..key = ing.key
        ..ingredientId = ing.id;
      changed = true;
    }
    return changed;
  }
}
