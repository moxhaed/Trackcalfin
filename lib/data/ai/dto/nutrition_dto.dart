import '../../../core/enums.dart';
import '../../isar/collections/nutrition.dart';
import '../json_reader.dart';

class NutritionEstimateDto {
  NutritionEstimateDto({required this.key, required this.per100g, this.densityGPerMl, this.gramsPerPiece});
  final String key;

  /// Always per 100 g; NutritionService converts ml items.
  final Nutrition per100g;
  final double? densityGPerMl;
  final double? gramsPerPiece;
}

/// Output of nutrition_estimate: one entry per requested key.
class NutritionEstimates {
  NutritionEstimates(this.items);
  final List<NutritionEstimateDto> items;

  /// [units] maps each requested key to its unit; every key must come back exactly once.
  static ParseResult<NutritionEstimates> parse(Map<String, dynamic> m, {required Map<String, BaseUnit> units}) {
    final j = JsonReader();
    final items = <NutritionEstimateDto>[];
    final seen = <String>{};
    final raw = j.list(m, 'items', r'$');
    for (var i = 0; i < raw.length; i++) {
      final path = '\$.items[$i]';
      final it = raw[i];
      if (it is! Map) {
        j.error(path, 'must be an object');
        continue;
      }
      final key = j.str(it, 'key', path);
      if (key == null) continue;
      final unit = units[key];
      if (unit == null) {
        j.error('$path.key', "'$key' was not in the input; copy input keys exactly");
        continue;
      }
      if (!seen.add(key)) {
        j.error('$path.key', "'$key' appears more than once");
        continue;
      }
      final per = j.object(it, 'per_100g', path);
      final n = per == null ? Nutrition() : macros(j, per, '$path.per_100g');
      final density = j.number(it, 'density_g_per_ml', path, nullable: true);
      final gpp = j.number(it, 'grams_per_piece', path, nullable: true);
      if (unit == BaseUnit.ml && (density == null || density < 0.3 || density > 2.5)) {
        j.error('$path.density_g_per_ml', 'is required for "ml" items and must be between 0.3 and 2.5');
      }
      if (unit == BaseUnit.pc && (gpp == null || gpp <= 0 || gpp > 5000)) {
        j.error('$path.grams_per_piece', 'is required for "pc" items and must be between 0 and 5000');
      }
      items.add(NutritionEstimateDto(key: key, per100g: n, densityGPerMl: density, gramsPerPiece: gpp));
    }
    final missing = units.keys.where((k) => !seen.contains(k)).toList();
    if (missing.isNotEmpty) j.error(r'$.items', 'is missing keys: ${missing.join(', ')}');
    if (j.errors.isNotEmpty) return ParseResult(null, j.errors);
    return ParseResult(NutritionEstimates(items), const []);
  }

  /// Reads per-100 g macros and rejects values no food can have.
  static Nutrition macros(JsonReader j, Map<String, dynamic> per, String path) {
    double read(String k, int max) {
      final v = j.number(per, k, path) ?? 0;
      if (v < 0 || v > max) j.error('$path.$k', 'must be between 0 and $max per 100 g');
      return v;
    }

    final n = Nutrition(
      kcal: read('kcal', 900),
      proteinG: read('protein_g', 100),
      carbsG: read('carbs_g', 100),
      fatG: read('fat_g', 100),
      fiberG: read('fiber_g', 100),
    );
    if (n.proteinG + n.carbsG + n.fatG + n.fiberG > 105) {
      j.error(path, 'macros add up to more than 100 g per 100 g');
    }
    return n;
  }
}

enum LabelBasis { per100g, per100ml, perServing }

/// Output of nutrition_label: the panel as printed, before any conversion.
class LabelReading {
  LabelReading({
    required this.readable,
    this.productName,
    this.basis,
    this.servingSizeG,
    this.servingSizeMl,
    this.energyKcal,
    this.energyKj,
    this.proteinG,
    this.carbsG,
    this.fatG,
    this.fiberG,
    this.carbsIncludeFiber = false,
    this.warnings = const [],
  });
  final bool readable;
  final String? productName;
  final LabelBasis? basis;
  final double? servingSizeG;
  final double? servingSizeMl;
  final double? energyKcal;
  final double? energyKj;
  final double? proteinG;
  final double? carbsG;
  final double? fatG;
  final double? fiberG;
  final bool carbsIncludeFiber;
  final List<String> warnings;

  static const _basis = {
    'per_100g': LabelBasis.per100g,
    'per_100ml': LabelBasis.per100ml,
    'per_serving': LabelBasis.perServing,
  };

  static ParseResult<LabelReading> parse(Map<String, dynamic> m) {
    final j = JsonReader();
    final type = j.enumOf(m, 'image_type', r'$', const {'label': true, 'unreadable': false});
    final readable = type ?? false;
    final basis = j.enumOf(m, 'basis', r'$', _basis, nullable: !readable);
    double? num(String k) {
      final v = j.number(m, k, r'$', nullable: true);
      if (v != null && v < 0) j.error('\$.$k', 'must not be negative');
      return v;
    }

    final r = LabelReading(
      readable: readable,
      productName: j.str(m, 'product_name', r'$', nullable: true),
      basis: basis,
      servingSizeG: num('serving_size_g'),
      servingSizeMl: num('serving_size_ml'),
      energyKcal: num('energy_kcal'),
      energyKj: num('energy_kj'),
      proteinG: num('protein_g'),
      carbsG: num('carbs_g'),
      fatG: num('fat_g'),
      fiberG: num('fiber_g'),
      carbsIncludeFiber: j.boolean(m, 'carbs_include_fiber', r'$'),
      warnings: j.strings(m, 'warnings', r'$'),
    );
    if (readable && basis == LabelBasis.perServing && (r.servingSizeG ?? r.servingSizeMl ?? 0) <= 0) {
      j.error(r'$.serving_size_g', 'or serving_size_ml is required when basis is "per_serving"');
    }
    if (j.errors.isNotEmpty) return ParseResult(null, j.errors);
    return ParseResult(r, const []);
  }
}
