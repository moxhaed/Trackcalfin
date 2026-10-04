import '../core/enums.dart';
import '../data/isar/collections/ingredient.dart';
import 'units.dart';

/// Kitchen measures people say instead of grams or ml ("a tablespoon of soy sauce"). The sizes
/// are fixed, the same in every country, and Dart converts them: the AI never does the sums.
enum Measure { tsp, tbsp, cup, glass, pinch, handful }

extension MeasureSize on Measure {
  /// ml in one, for the measures of volume.
  double? get ml => switch (this) {
    Measure.tsp => 5,
    Measure.tbsp => 15,
    Measure.cup => 240,
    Measure.glass => 250,
    Measure.pinch || Measure.handful => null,
  };

  /// g in one, for the measures of weight.
  double? get grams => switch (this) {
    Measure.pinch => 0.4,
    Measure.handful => 30,
    _ => null,
  };

  String get label => name;
}

/// One amount the Ate dialog offers: [label] ("1 tbsp") is [qty] in the item's own unit.
class MeasurePreset {
  const MeasurePreset(this.label, this.qty);
  final String label;
  final double qty;
}

class Measures {
  const Measures._();

  /// "tbsp", "tablespoon", "Tbsp." and so on, or null when [s] isn't a measure.
  static Measure? parse(String s) => switch (s.trim().toLowerCase().replaceAll('.', '')) {
    'tsp' || 'teaspoon' || 'teaspoons' => Measure.tsp,
    'tbsp' || 'tablespoon' || 'tablespoons' => Measure.tbsp,
    'cup' || 'cups' => Measure.cup,
    'glass' || 'glasses' => Measure.glass,
    'pinch' || 'pinches' => Measure.pinch,
    'handful' || 'handfuls' => Measure.handful,
    _ => null,
  };

  /// [qty] of [m] in [i]'s base unit: 1 tbsp of soy sauce is 15 ml, of sugar 15 ml × 0.85 =
  /// 12.8 g, a glass of cola from 330 ml cans 0.76 cans. Null for a piece item without a size.
  static double? toBase(double qty, Measure m, Ingredient i) {
    final ml = m.ml;
    return ml != null
        ? UnitConverter.toBase(qty * ml, BaseUnit.ml, i)
        : UnitConverter.toBase(qty * m.grams!, BaseUnit.g, i);
  }

  /// What the Ate dialog offers for [i] (grams and ml items; a piece is eaten whole): spoons
  /// for sauces, oils, spices and what has a spoon weight (its density), a glass for drinks,
  /// cups for rice and grains, a handful for nuts and snacks, then plain amounts of its unit.
  static List<MeasurePreset> presetsFor(Ingredient i) {
    MeasurePreset m(double n, Measure x) =>
        MeasurePreset('${UnitConverter.formatNumber(n)} ${x.label}', toBase(n, x, i)!);
    MeasurePreset plain(double q) => MeasurePreset(UnitConverter.format(q, i.baseUnit), q);
    final c = i.category;
    final condiment = c == IngredientCategory.spicesCondiments || c == IngredientCategory.oilsFats;
    final spoons = [m(1, Measure.tsp), m(1, Measure.tbsp), m(2, Measure.tbsp)];
    switch (i.baseUnit) {
      case BaseUnit.ml:
        if (condiment) return [...spoons, plain(50), plain(100)];
        return [m(1, Measure.glass), plain(100), plain(200), plain(330), plain(500)];
      case BaseUnit.g:
        if (c == IngredientCategory.legumesNuts || c == IngredientCategory.snacksSweets) {
          return [m(1, Measure.handful), if (i.densityGPerMl != null) m(1, Measure.tbsp), plain(50), plain(100)];
        }
        if (c == IngredientCategory.grainsPasta && i.densityGPerMl != null) {
          return [m(0.5, Measure.cup), m(1, Measure.cup), plain(50), plain(100)];
        }
        if (condiment) return [m(1, Measure.pinch), ...spoons, plain(50)];
        if (i.densityGPerMl != null) return [...spoons, plain(50), plain(100)];
        return [plain(30), plain(50), plain(100), plain(150), plain(200)];
      case BaseUnit.pc:
        return const [];
    }
  }
}
