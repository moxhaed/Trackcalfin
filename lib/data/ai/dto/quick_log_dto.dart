import '../../../core/enums.dart';
import '../../../domain/measures.dart';
import '../../isar/collections/nutrition.dart';
import '../json_reader.dart';
import 'enum_codec.dart';
import 'receipt_dto.dart';

enum QuickActionType {
  buy,
  expense,
  eat,
  cook,
  throwAway,
  count,

  /// "Where is X cheaper?": answered from the user's receipts (PriceBook), nothing is saved.
  priceCheck,
}

/// Where eaten or thrown-away food came from.
enum FoodSource { fridge, pantry, out }

/// One thing the user did, as Prompt G read it from what they said. Dart checks it against
/// the user's data and computes every number before anything is saved.
class QuickAction {
  QuickAction({
    required this.type,
    this.when,
    this.source,
    this.key,
    this.name,
    this.qty,
    this.unit,
    this.measure,
    this.piece,
    this.batchId,
    this.recipeId,
    this.portions,
    this.atePortions,
    this.paidMinor,
    this.estPriceMinor,
    this.category,
    this.merchant,
    this.nutrition,
    this.newIngredient,
  });
  final QuickActionType type;

  /// Set only when the user said when; null = now.
  final DateTime? when;
  final FoodSource? source;
  final String? key;
  final String? name;
  final double? qty;

  /// [qty] is in [unit], or in [measure] ("1 tbsp"): Dart converts it to the item's unit.
  final BaseUnit? unit;
  final Measure? measure;

  /// A new item bought in pieces: what one is called and holds.
  final PieceDto? piece;
  final int? batchId;
  final int? recipeId;
  final double? portions;
  final int? atePortions;
  final int? paidMinor;
  final int? estPriceMinor;
  final SpendCategory? category;
  final String? merchant;

  /// Eaten out: the model's estimate for everything eaten.
  final Nutrition? nutrition;

  /// A bought item that isn't in the pantry yet.
  final NewIngredientDto? newIngredient;
}

/// What the app knows, so Prompt G's references can be checked.
class QuickLogContext {
  QuickLogContext({required this.now, required this.pantry, required this.fridge, required this.recipes});
  final DateTime now;

  /// Pantry keys and the unit each is counted in.
  final Map<String, BaseUnit> pantry;

  /// Fridge batch ids and the portions left.
  final Map<int, int> fridge;
  final Set<int> recipes;
}

/// Prompt G output: the actions in what the user said, or a question.
class QuickLog {
  QuickLog(this.actions, {this.totalPaidMinor, this.question});
  final List<QuickAction> actions;

  /// One amount the user gave for several items bought together.
  final int? totalPaidMinor;
  final String? question;

  static const maxMoneyMinor = 100000;

  /// Further back than this is more likely a misread than a late log.
  static const maxDaysBack = 14;

  static const _types = {
    'buy': QuickActionType.buy,
    'expense': QuickActionType.expense,
    'eat': QuickActionType.eat,
    'cook': QuickActionType.cook,
    'throw_away': QuickActionType.throwAway,
    'count': QuickActionType.count,
    'price_check': QuickActionType.priceCheck,
  };
  static const _sources = {'fridge': FoodSource.fridge, 'pantry': FoodSource.pantry, 'out': FoodSource.out};
  static final _expense = {
    for (final e in EnumCodec.spendCategory.entries)
      if (e.value != SpendCategory.groceries) e.key: e.value,
  };
  static final _keyPattern = RegExp(r'^[a-z][a-z0-9_]{1,40}$');
  static final _spokenUnits = ['g', 'ml', 'pc', for (final m in Measure.values) m.label].join(', ');

  static ParseResult<QuickLog> parse(Map<String, dynamic> m, {required QuickLogContext ctx}) {
    final j = JsonReader();
    final out = <QuickAction>[];
    // Keys bought earlier in this message can be eaten, counted or thrown away after it.
    final units = {...ctx.pantry};
    final raw = j.list(m, 'actions', r'$');
    for (var i = 0; i < raw.length; i++) {
      final path = '\$.actions[$i]';
      final it = raw[i];
      if (it is! Map) {
        j.error(path, 'must be an object');
        continue;
      }
      final a = it.cast<String, dynamic>();
      final type = j.enumOf(a, 'type', path, _types);
      if (type == null) continue;
      final when = _when(j, a, path, ctx.now);
      int? money(String k, {required bool required}) {
        final v = j.integer(a, k, path, nullable: !required);
        if (v != null && (v <= 0 || v > maxMoneyMinor)) j.error('$path.$k', 'must be between 1 and $maxMoneyMinor');
        return v;
      }

      String? key({bool known = true}) {
        final k = j.str(a, 'key', path);
        if (k == null) return null;
        if (!_keyPattern.hasMatch(k)) {
          j.error('$path.key', "'$k' must be lowercase snake_case");
          return null;
        }
        if (known && !units.containsKey(k)) j.error('$path.key', "'$k' is not in the pantry; copy pantry keys exactly");
        return k;
      }

      /// qty as the user said it: in g, ml or pc, or in a kitchen measure ("1 tbsp"), which Dart
      /// converts to the item's unit. Only what can't be converted is an error: pieces of an item
      /// counted in g or ml (it has no piece size).
      (double?, BaseUnit?, Measure?) amount(
        String? k, {
        required bool required,
        bool measures = true,
        bool pieces = false,
      }) {
        final qty = j.number(a, 'qty', path, nullable: !required);
        final raw = j.str(a, 'unit', path, nullable: qty == null);
        BaseUnit? unit;
        Measure? measure;
        if (raw != null) {
          unit = EnumCodec.unit[raw];
          measure = unit == null && measures ? Measures.parse(raw) : null;
          if (unit == null && measure == null) {
            j.error('$path.unit', "'$raw' is not one of ${measures ? _spokenUnits : 'g, ml, pc'}");
          }
        }
        final max = unit == BaseUnit.pc ? 60 : (measure != null ? 100 : 25000);
        if (qty != null && (qty < 0 || qty > max)) j.error('$path.qty', 'must be between 0 and $max');
        final counted = k == null ? null : units[k];
        if (!pieces && counted != null && counted != BaseUnit.pc && unit == BaseUnit.pc) {
          j.error(
            '$path.unit',
            "'$k' is counted in ${counted.label}: give one piece as its ${counted == BaseUnit.ml ? 'volume' : 'weight'} "
                '(a can of cola is 330 ml, a tortilla 40 g)',
          );
        }
        return (qty, unit, measure);
      }

      int? batch() {
        final b = j.integer(a, 'batch_id', path);
        if (b != null && !ctx.fridge.containsKey(b)) j.error('$path.batch_id', '$b is not in the fridge');
        return b;
      }

      switch (type) {
        case QuickActionType.buy:
          final k = key(known: false);
          // Pieces of an item kept in g or ml switch it to pieces, like a scan (docs/07 §7.3):
          // they need the piece's size.
          final (qty, unit, _) = amount(k, required: true, measures: false, pieces: true);
          final piece = PieceDto.parse(j, a, path, unit);
          final counted = k == null ? null : units[k];
          if (counted != null && counted != BaseUnit.pc && unit == BaseUnit.pc && piece?.size == null) {
            j.error('$path.piece_size', "is required to count '$k' in pieces; or give qty in ${counted.label}");
          }
          // A new item without its profile is still logged: its macros are estimated later, in a
          // batch with others (NutritionService), which costs less than asking this again.
          NewIngredientDto? profile;
          if (k != null && counted == null) {
            final p = j.object(a, 'new_ingredient', path, nullable: true);
            if (p != null) {
              profile = NewIngredientDto.parse(j, p, '$path.new_ingredient', unit: unit, piece: piece);
            }
          }
          if (k != null) {
            units[k] = unit == BaseUnit.pc ? BaseUnit.pc : (counted ?? profile?.unit ?? unit ?? BaseUnit.g);
          }
          if (qty != null && qty <= 0) j.error('$path.qty', 'must be more than 0');
          final paid = money('paid_minor', required: false);
          final est = money('est_price_minor', required: false);
          if (paid == null && est == null) j.error('$path.est_price_minor', 'is required when paid_minor is null');
          out.add(
            QuickAction(
              type: type,
              when: when,
              key: k,
              name: _text(j, a, 'name', path),
              qty: qty,
              unit: unit,
              piece: piece,
              paidMinor: paid,
              estPriceMinor: est,
              merchant: _text(j, a, 'merchant', path),
              newIngredient: profile,
            ),
          );
        case QuickActionType.expense:
          out.add(
            QuickAction(
              type: type,
              when: when,
              name: _text(j, a, 'name', path),
              paidMinor: money('paid_minor', required: true),
              category: j.enumOf(a, 'category', path, _expense),
              merchant: _text(j, a, 'merchant', path),
            ),
          );
        case QuickActionType.eat:
          final source = j.enumOf(a, 'source', path, _sources);
          switch (source) {
            case FoodSource.fridge:
              final b = batch();
              final portions = j.number(a, 'portions', path);
              if (portions != null && (portions <= 0 || portions > 20)) {
                j.error('$path.portions', 'must be between 0 and 20');
              }
              out.add(QuickAction(type: type, when: when, source: source, batchId: b, portions: portions));
            case FoodSource.pantry:
              final k = key();
              final (qty, unit, measure) = amount(k, required: true);
              if (qty != null && qty <= 0) j.error('$path.qty', 'must be more than 0');
              out.add(
                QuickAction(type: type, when: when, source: source, key: k, qty: qty, unit: unit, measure: measure),
              );
            case FoodSource.out:
              final name = _text(j, a, 'name', path);
              if (name == null) j.error('$path.name', 'is required for food eaten out');
              out.add(
                QuickAction(type: type, when: when, source: source, name: name, nutrition: _nutrition(j, a, path)),
              );
            case null:
              break;
          }
        case QuickActionType.cook:
          final recipe = j.integer(a, 'recipe_id', path);
          if (recipe != null && !ctx.recipes.contains(recipe)) j.error('$path.recipe_id', '$recipe is not a recipe');
          final portions = j.integer(a, 'portions', path);
          if (portions != null && (portions < 1 || portions > 20)) {
            j.error('$path.portions', 'must be a whole number from 1 to 20');
          }
          final ate = j.integer(a, 'ate_portions', path, nullable: true);
          if (ate != null && (ate < 0 || ate > (portions ?? 20))) {
            j.error('$path.ate_portions', 'must be between 0 and the portions cooked');
          }
          out.add(
            QuickAction(type: type, when: when, recipeId: recipe, portions: portions?.toDouble(), atePortions: ate),
          );
        case QuickActionType.throwAway:
          final source = j.enumOf(a, 'source', path, {'fridge': FoodSource.fridge, 'pantry': FoodSource.pantry});
          if (source == FoodSource.fridge) {
            final b = batch();
            final portions = j.number(a, 'portions', path, nullable: true);
            if (portions != null && portions <= 0) j.error('$path.portions', 'must be more than 0, or null for all');
            out.add(QuickAction(type: type, when: when, source: source, batchId: b, portions: portions));
          } else if (source == FoodSource.pantry) {
            final k = key();
            final (qty, unit, measure) = amount(k, required: false);
            if (qty != null && qty <= 0) j.error('$path.qty', 'must be more than 0, or null for all');
            out.add(
              QuickAction(type: type, when: when, source: source, key: k, qty: qty, unit: unit, measure: measure),
            );
          }
        case QuickActionType.count:
          final k = key();
          final (qty, unit, measure) = amount(k, required: true);
          out.add(QuickAction(type: type, when: when, key: k, qty: qty, unit: unit, measure: measure));
        case QuickActionType.priceCheck:
          // Null for an item the pantry doesn't have: the app says it has no prices for it.
          final k = j.str(a, 'key', path, nullable: true);
          if (k != null && !units.containsKey(k)) {
            j.error('$path.key', "'$k' is not in the pantry; copy pantry keys exactly, or use null");
          }
          final name = _text(j, a, 'name', path);
          if (k == null && name == null) j.error('$path.name', 'is required when key is null');
          out.add(QuickAction(type: type, key: k, name: name));
      }
    }
    final total = j.integer(m, 'total_paid_minor', r'$', nullable: true);
    if (total != null && (total <= 0 || total > maxMoneyMinor * 5)) {
      j.error(r'$.total_paid_minor', 'must be between 1 and ${maxMoneyMinor * 5}');
    }
    final question = _text(j, m, 'question', r'$');
    if (raw.isEmpty && question == null) j.error(r'$.question', 'is required when there are no actions');
    if (j.errors.isNotEmpty) return ParseResult(null, j.errors);
    return ParseResult(QuickLog(out, totalPaidMinor: total, question: question), const []);
  }

  static String? _text(JsonReader j, Map<String, dynamic> m, String k, String path) {
    final v = j.str(m, k, path, nullable: true)?.trim();
    return v == null || v.isEmpty ? null : v;
  }

  static Nutrition? _nutrition(JsonReader j, Map<String, dynamic> a, String path) {
    final n = j.object(a, 'nutrition', path);
    if (n == null) return null;
    final p = '$path.nutrition';
    double part(String k, double max) {
      final v = j.number(n, k, p) ?? 0;
      if (v < 0 || v > max) j.error('$p.$k', 'must be between 0 and ${max.round()}');
      return v;
    }

    return Nutrition(
      kcal: part('kcal', 5000),
      proteinG: part('protein_g', 400),
      carbsG: part('carbs_g', 800),
      fatG: part('fat_g', 400),
    );
  }

  /// "2026-10-02T12:30" in local time: not after now, not more than [maxDaysBack] back.
  static DateTime? _when(JsonReader j, Map<String, dynamic> a, String path, DateTime now) {
    final s = j.str(a, 'when', path, nullable: true);
    if (s == null) return null;
    final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2})$').firstMatch(s.trim());
    final t = m == null
        ? null
        : DateTime(
            int.parse(m.group(1)!),
            int.parse(m.group(2)!),
            int.parse(m.group(3)!),
            int.parse(m.group(4)!),
            int.parse(m.group(5)!),
          );
    if (t == null || t.month != int.parse(m!.group(2)!) || t.day != int.parse(m.group(3)!)) {
      j.error('$path.when', "'$s' must be YYYY-MM-DDTHH:MM");
      return null;
    }
    if (t.isAfter(now.add(const Duration(minutes: 10)))) {
      j.error('$path.when', "'$s' is after now; leave it null for now");
      return null;
    }
    if (t.isBefore(now.subtract(const Duration(days: maxDaysBack)))) {
      j.error('$path.when', "'$s' is more than $maxDaysBack days back");
      return null;
    }
    return t;
  }
}
