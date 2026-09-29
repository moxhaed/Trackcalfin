import '../../../core/enums.dart';
import '../../isar/collections/nutrition.dart';
import '../json_reader.dart';
import 'enum_codec.dart';

class NewIngredientDto {
  NewIngredientDto({
    required this.name,
    required this.category,
    required this.unit,
    this.gramsPerPiece,
    this.densityGPerMl,
    required this.per100,
    required this.shelfLifeDays,
    required this.suggestStaple,
  });
  final String name;
  final IngredientCategory category;
  final BaseUnit unit;
  final double? gramsPerPiece;
  final double? densityGPerMl;
  final Nutrition per100;
  final int shelfLifeDays;
  final bool suggestStaple;
}

class ReceiptItemDto {
  ReceiptItemDto({
    required this.rawText,
    required this.name,
    required this.lineType,
    required this.category,
    required this.totalMinor,
    this.ingredientKey,
    required this.isNewIngredient,
    this.qty,
    this.unit,
    required this.qtySource,
    required this.confidence,
    this.newIngredient,
  });
  final String rawText;
  final String name;
  final LineType lineType;
  final SpendCategory category;
  final int totalMinor;
  final String? ingredientKey;
  final bool isNewIngredient;
  final double? qty;
  final BaseUnit? unit;
  final QtySource qtySource;
  final Confidence confidence;
  final NewIngredientDto? newIngredient;
}

class ReceiptExtraction {
  ReceiptExtraction({
    required this.imageType,
    required this.stockMode,
    this.merchant,
    this.purchasedAt,
    this.currency,
    this.receiptTotalMinor,
    required this.items,
    required this.warnings,
  });
  final ScanKind imageType;
  final String stockMode;
  final String? merchant;
  final DateTime? purchasedAt;
  final String? currency;
  final int? receiptTotalMinor;
  final List<ReceiptItemDto> items;
  final List<String> warnings;

  static final _key = RegExp(r'^[a-z][a-z0-9_]{1,40}$');

  static ParseResult<ReceiptExtraction> parse(Map<String, dynamic> m) {
    final j = JsonReader();
    final imageType = j.enumOf(m, 'image_type', r'$', EnumCodec.imageType);
    final stockMode = j.enumOf(m, 'stock_mode', r'$', const {'add': 'add', 'set': 'set', 'none': 'none'});
    final merchant = j.str(m, 'merchant', r'$', nullable: true);
    final date = j.str(m, 'purchased_at', r'$', nullable: true);
    final time = j.str(m, 'purchased_time', r'$', nullable: true);
    DateTime? purchasedAt;
    if (date != null) {
      final d = DateTime.tryParse(date);
      if (d == null) {
        j.error(r'$.purchased_at', 'must be YYYY-MM-DD');
      } else {
        var h = 12, min = 0;
        final tm = time == null ? null : RegExp(r'^(\d{1,2}):(\d{2})').firstMatch(time);
        if (tm != null) {
          h = int.parse(tm.group(1)!).clamp(0, 23);
          min = int.parse(tm.group(2)!).clamp(0, 59);
        }
        purchasedAt = DateTime(d.year, d.month, d.day, h, min);
      }
    }
    final currency = j.str(m, 'currency', r'$', nullable: true);
    final total = j.integer(m, 'receipt_total_minor', r'$', nullable: true);
    final items = <ReceiptItemDto>[];
    final rawItems = j.list(m, 'items', r'$');
    for (var i = 0; i < rawItems.length; i++) {
      final path = '\$.items[$i]';
      final it = rawItems[i];
      if (it is! Map) {
        j.error(path, 'must be an object');
        continue;
      }
      final isNew = j.boolean(it, 'is_new_ingredient', path);
      final key = j.str(it, 'ingredient_key', path, nullable: true);
      if (key != null && !_key.hasMatch(key)) {
        j.error('$path.ingredient_key', "'$key' must match ^[a-z][a-z0-9_]{1,40}\$");
      }
      NewIngredientDto? profile;
      final rawProfile = it['new_ingredient'];
      if (isNew && key != null) {
        if (rawProfile is! Map) {
          j.error('$path.new_ingredient', 'is required when is_new_ingredient is true');
        } else {
          profile = _profile(j, rawProfile.cast<String, dynamic>(), '$path.new_ingredient');
        }
      }
      items.add(
        ReceiptItemDto(
          rawText: j.str(it, 'raw_text', path, nullable: true) ?? '',
          name: j.str(it, 'name', path) ?? '',
          lineType: j.enumOf(it, 'line_type', path, EnumCodec.lineType) ?? LineType.product,
          category: j.enumOf(it, 'spend_category', path, EnumCodec.spendCategory) ?? SpendCategory.other,
          totalMinor: j.integer(it, 'total_minor', path) ?? 0,
          ingredientKey: key,
          isNewIngredient: isNew,
          qty: j.number(it, 'qty', path, nullable: true),
          unit: j.enumOf(it, 'unit', path, EnumCodec.unit, nullable: true),
          qtySource: j.enumOf(it, 'qty_source', path, EnumCodec.qtySource, nullable: true) ?? QtySource.unknown,
          confidence: j.enumOf(it, 'confidence', path, EnumCodec.confidence, nullable: true) ?? Confidence.medium,
          newIngredient: profile,
        ),
      );
    }
    final warnings = j.strings(m, 'warnings', r'$');
    if (j.errors.isNotEmpty) return ParseResult(null, j.errors);
    return ParseResult(
      ReceiptExtraction(
        imageType: imageType!,
        stockMode: stockMode!,
        merchant: merchant,
        purchasedAt: purchasedAt,
        currency: currency,
        receiptTotalMinor: total,
        items: items,
        warnings: warnings,
      ),
      const [],
    );
  }

  static NewIngredientDto? _profile(JsonReader j, Map<String, dynamic> p, String path) {
    final per = j.object(p, 'per_100', path);
    final unit = j.enumOf(p, 'unit', path, EnumCodec.unit);
    final gpp = j.number(p, 'grams_per_piece', path, nullable: true);
    if (unit == BaseUnit.pc && gpp == null) j.error('$path.grams_per_piece', 'is required when unit is "pc"');
    final nutrition = per == null
        ? Nutrition()
        : Nutrition(
            kcal: j.number(per, 'kcal', '$path.per_100') ?? 0,
            proteinG: j.number(per, 'protein_g', '$path.per_100') ?? 0,
            carbsG: j.number(per, 'carbs_g', '$path.per_100') ?? 0,
            fatG: j.number(per, 'fat_g', '$path.per_100') ?? 0,
            fiberG: j.number(per, 'fiber_g', '$path.per_100', nullable: true) ?? 0,
          );
    return NewIngredientDto(
      name: j.str(p, 'name', path) ?? '',
      category: j.enumOf(p, 'ingredient_category', path, EnumCodec.ingredientCategory) ?? IngredientCategory.other,
      unit: unit ?? BaseUnit.g,
      gramsPerPiece: gpp,
      densityGPerMl: j.number(p, 'density_g_per_ml', path, nullable: true),
      per100: nutrition,
      shelfLifeDays: j.integer(p, 'shelf_life_days', path) ?? 7,
      suggestStaple: j.boolean(p, 'suggest_staple', path),
    );
  }
}
