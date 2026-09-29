import 'dart:math' as math;

import '../data/isar/collections/ingredient.dart';

enum MatchKind { alias, key, fuzzy, none }

class MatchResult {
  const MatchResult(this.ingredient, this.kind, this.score);
  const MatchResult.none() : this(null, MatchKind.none, 0);
  final Ingredient? ingredient;
  final MatchKind kind;
  final double score;
}

/// Resolves receipt lines and AI keys to existing pantry ingredients.
class IngredientMatcher {
  IngredientMatcher(Iterable<Ingredient> all) : _all = all.toList() {
    for (final i in _all) {
      _byKey[i.key] = i;
      for (final a in i.aliases) {
        _byAlias[a] = i;
      }
    }
  }

  final List<Ingredient> _all;
  final _byKey = <String, Ingredient>{};
  final _byAlias = <String, Ingredient>{};

  static const fuzzyThreshold = 0.85;
  static const maxAliases = 20;

  static final _price = RegExp(r'-?\d+[.,]\d{2}\s*[AB€*]?(?=\s|$)');
  static final _measure = RegExp(r'\b\d+(?:[.,]\d+)?\s*(?:G|GR|KG|ML|L|CL|STK|ST|X|%|PCS|PC)(?=[^A-Z]|$)');
  static final _digits = RegExp(r'\d+');
  static final _nonLetters = RegExp(r'[^\p{L} ]', unicode: true);
  static final _spaces = RegExp(r'\s+');

  /// "HOCHL.BRUSTFILET 500G 4,99" -> "HOCHL BRUSTFILET"
  static String normalize(String raw) {
    var s = raw.toUpperCase();
    s = s.replaceAll(_price, ' ');
    s = s.replaceAll(_measure, ' ');
    s = s.replaceAll(_digits, ' ');
    s = s.replaceAll(_nonLetters, ' ');
    return s.replaceAll(_spaces, ' ').trim();
  }

  static int _levenshtein(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;
    var prev = List<int>.generate(b.length + 1, (i) => i);
    for (var i = 1; i <= a.length; i++) {
      final cur = List<int>.filled(b.length + 1, 0)..[0] = i;
      for (var j = 1; j <= b.length; j++) {
        final cost = a.codeUnitAt(i - 1) == b.codeUnitAt(j - 1) ? 0 : 1;
        cur[j] = math.min(math.min(cur[j - 1] + 1, prev[j] + 1), prev[j - 1] + cost);
      }
      prev = cur;
    }
    return prev[b.length];
  }

  /// 1.0 = identical, 0.0 = nothing in common.
  static double similarity(String a, String b) {
    if (a.isEmpty && b.isEmpty) return 1;
    final d = _levenshtein(a, b);
    return 1 - d / math.max(a.length, b.length);
  }

  static Set<String> _tokens(String s) => s
      .toLowerCase()
      .split(RegExp(r'[\s_\-]+'))
      .map((t) => t.endsWith('s') && t.length > 3 ? t.substring(0, t.length - 1) : t)
      .where((t) => t.isNotEmpty)
      .toSet();

  /// Token-set ratio: shared tokens over the larger set.
  static double tokenSetRatio(String a, String b) {
    final ta = _tokens(a);
    final tb = _tokens(b);
    if (ta.isEmpty || tb.isEmpty) return 0;
    final inter = ta.intersection(tb).length;
    return inter / math.max(ta.length, tb.length);
  }

  Ingredient? byKey(String key) => _byKey[key];

  /// alias -> key -> fuzzy (proposal only) -> none.
  MatchResult resolve({String? rawText, String? key, String? name}) {
    if (rawText != null && rawText.isNotEmpty) {
      final hit = _byAlias[normalize(rawText)];
      if (hit != null) return MatchResult(hit, MatchKind.alias, 1);
    }
    if (key != null && key.isNotEmpty) {
      final hit = _byKey[key];
      if (hit != null) return MatchResult(hit, MatchKind.key, 1);
    }
    Ingredient? best;
    var bestScore = 0.0;
    for (final i in _all) {
      var s = 0.0;
      if (key != null && key.isNotEmpty) {
        s = math.max(s, similarity(key, i.key));
        s = math.max(s, tokenSetRatio(key, i.key));
      }
      if (name != null && name.isNotEmpty) {
        s = math.max(s, tokenSetRatio(name, i.name));
        s = math.max(s, similarity(name.toLowerCase(), i.name.toLowerCase()));
      }
      if (s > bestScore) {
        bestScore = s;
        best = i;
      }
    }
    if (best != null && bestScore >= fuzzyThreshold) return MatchResult(best, MatchKind.fuzzy, bestScore);
    return const MatchResult.none();
  }

  /// Adds a confirmed raw receipt string to [ing]'s aliases (newest kept).
  static void learnAlias(Ingredient ing, String rawText) {
    final n = normalize(rawText);
    if (n.length < 3) return;
    final list = ing.aliases.where((a) => a != n).toList()..add(n);
    ing.aliases = list.length > maxAliases ? list.sublist(list.length - maxAliases) : list;
  }
}
