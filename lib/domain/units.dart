import '../core/enums.dart';
import '../data/isar/collections/ingredient.dart';

class ParsedQty {
  const ParsedQty(this.qty, this.unit);
  final double qty;
  final BaseUnit unit;

  @override
  String toString() => '$qty ${unit.label}';
}

/// Converts between g, ml and pc using an ingredient's piece weight and density.
class UnitConverter {
  const UnitConverter._();

  /// Grams for [qty] in [unit]; null when a piece weight is needed but unknown.
  static double? toGrams(double qty, BaseUnit unit, {double? gramsPerPiece, double? density}) => switch (unit) {
    BaseUnit.g => qty,
    BaseUnit.ml => qty * (density ?? 1.0),
    BaseUnit.pc => gramsPerPiece == null ? null : qty * gramsPerPiece,
  };

  static double? ingredientGrams(double qty, BaseUnit unit, Ingredient i) =>
      toGrams(qty, unit, gramsPerPiece: i.gramsPerPiece, density: i.densityGPerMl);

  /// Converts [qty] expressed in [from] into [i]'s base unit; null if impossible.
  static double? toBase(double qty, BaseUnit from, Ingredient i) {
    if (from == i.baseUnit) return qty;
    final grams = ingredientGrams(qty, from, i);
    if (grams == null) return null;
    return switch (i.baseUnit) {
      BaseUnit.g => grams,
      BaseUnit.ml => grams / (i.densityGPerMl ?? 1.0),
      BaseUnit.pc => i.gramsPerPiece == null || i.gramsPerPiece == 0 ? null : grams / i.gramsPerPiece!,
    };
  }

  /// How many [to] units make one [from] unit: 1 ml of cola is 1/340 of a 340 g can.
  /// Pieces need their weight ([fromGramsPerPiece], [toGramsPerPiece]); ml counts [density] g.
  /// null when a piece weight is missing.
  static double? factor(
    BaseUnit from,
    BaseUnit to, {
    double? fromGramsPerPiece,
    double? toGramsPerPiece,
    double? density,
  }) {
    if (from == to && (from != BaseUnit.pc || fromGramsPerPiece == toGramsPerPiece)) return 1;
    double? grams(BaseUnit u, double? gpp) => switch (u) {
      BaseUnit.g => 1,
      BaseUnit.ml => density ?? 1.0,
      BaseUnit.pc => gpp == null || gpp <= 0 ? null : gpp,
    };
    final a = grams(from, fromGramsPerPiece);
    final b = grams(to, toGramsPerPiece);
    if (a == null || b == null) return null;
    return a / b;
  }

  static final _multi = RegExp(r'(\d+)\s*[x×]\s*(\d+(?:[.,]\d+)?)\s*([a-zA-Z]+)');
  static final _single = RegExp(r'(\d+(?:[.,]\d+)?)\s*([a-zA-Zµ]+)?');

  /// "1,5 kg" -> 1500 g, "6x0,33l" -> 1980 ml, "10 stk" -> 10 pc, "250" -> 250 g.
  static ParsedQty? parseHuman(String input) {
    final s = input.trim().toLowerCase();
    final m = _multi.firstMatch(s);
    if (m != null) {
      final count = double.parse(m.group(1)!);
      final one = _unitAmount(double.parse(m.group(2)!.replaceAll(',', '.')), m.group(3)!);
      if (one == null) return null;
      return ParsedQty(count * one.qty, one.unit);
    }
    final m2 = _single.firstMatch(s);
    if (m2 == null) return null;
    final value = double.parse(m2.group(1)!.replaceAll(',', '.'));
    return _unitAmount(value, m2.group(2) ?? 'g');
  }

  static ParsedQty? _unitAmount(double v, String unit) => switch (unit) {
    'g' || 'gr' || 'gram' || 'grams' => ParsedQty(v, BaseUnit.g),
    'kg' || 'kilo' || 'kilos' => ParsedQty(v * 1000, BaseUnit.g),
    'mg' => ParsedQty(v / 1000, BaseUnit.g),
    'oz' => ParsedQty(v * 28.3495, BaseUnit.g),
    'lb' || 'lbs' => ParsedQty(v * 453.592, BaseUnit.g),
    'ml' => ParsedQty(v, BaseUnit.ml),
    'cl' => ParsedQty(v * 10, BaseUnit.ml),
    'dl' => ParsedQty(v * 100, BaseUnit.ml),
    'l' || 'lt' || 'liter' || 'litre' || 'liters' || 'litres' => ParsedQty(v * 1000, BaseUnit.ml),
    'pc' || 'pcs' || 'stk' || 'st' || 'x' || 'piece' || 'pieces' || 'ea' => ParsedQty(v, BaseUnit.pc),
    _ => null,
  };

  /// 1500 g -> "1.5 kg", 250 g -> "250 g", 1.5 pc -> "1.5 pc".
  static String format(double qty, BaseUnit unit) {
    String num(double v) {
      if (v == v.roundToDouble()) return v.toStringAsFixed(0);
      final s = v.toStringAsFixed(v >= 10 ? 0 : 1);
      return s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
    }

    return switch (unit) {
      BaseUnit.g when qty >= 1000 => '${num(qty / 1000)} kg',
      BaseUnit.ml when qty >= 1000 => '${num(qty / 1000)} l',
      BaseUnit.g => '${num(qty)} g',
      BaseUnit.ml => '${num(qty)} ml',
      BaseUnit.pc => '${num(qty)} pc',
    };
  }
}
