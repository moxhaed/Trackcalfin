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
    this.pieceName,
    this.densityGPerMl,
    required this.per100,
    required this.shelfLifeDays,
  });
  final String name;
  final IngredientCategory category;
  final BaseUnit unit;
  final double? gramsPerPiece;
  final String? pieceName;
  final double? densityGPerMl;
  final Nutrition per100;
  final int shelfLifeDays;

  /// The `new_ingredient` object of Prompts A and G, at [path]. Since A v5 and G v3 the unit and
  /// the piece come from the line ([unit], [piece]); older answers carry `unit` and
  /// `grams_per_piece` in the object itself, which count only where the line has none.
  static NewIngredientDto parse(JsonReader j, Map<String, dynamic> p, String path, {BaseUnit? unit, PieceDto? piece}) {
    // Missing details fall back (no macros: estimated later in a batch; a week's shelf life)
    // instead of costing a second request. Wrong values are still errors.
    final per = j.object(p, 'per_100', path, nullable: true);
    final own = j.enumOf(p, 'unit', path, EnumCodec.unit, nullable: unit != null);
    final u = unit ?? own ?? BaseUnit.g;
    final density = j.number(p, 'density_g_per_ml', path, nullable: true);
    if (density != null && (density < 0.1 || density > 3)) j.error('$path.density_g_per_ml', 'must be 0.1 to 3');
    final gpp = piece?.grams(density) ?? j.number(p, 'grams_per_piece', path, nullable: true);
    if (u == BaseUnit.pc && gpp == null) {
      j.error(piece == null ? '$path.grams_per_piece' : '${piece.path}.piece_size', 'is required when unit is "pc"');
    }
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
      name: j.str(p, 'name', path, nullable: true) ?? '',
      category:
          j.enumOf(p, 'ingredient_category', path, EnumCodec.ingredientCategory, nullable: true) ??
          IngredientCategory.other,
      unit: u,
      gramsPerPiece: u == BaseUnit.pc ? gpp : null,
      pieceName: u == BaseUnit.pc ? piece?.name : null,
      densityGPerMl: density,
      per100: nutrition,
      shelfLifeDays: j.integer(p, 'shelf_life_days', path, nullable: true) ?? 7,
    );
  }
}

/// A line counted in pieces: what one is called and what one holds ([size] in [unit], g or ml).
class PieceDto {
  PieceDto({this.name, this.size, this.unit, required this.path});
  final String? name;
  final double? size;
  final BaseUnit? unit;

  /// Where the line is, for errors.
  final String path;

  /// What one weighs at [density] g per ml (1 if unknown).
  double? grams(double? density) {
    final s = size;
    if (s == null) return null;
    return unit == BaseUnit.ml ? s * (density ?? 1.0) : s;
  }

  static const _units = {'g': BaseUnit.g, 'ml': BaseUnit.ml};

  /// `piece_name`, `piece_size` and `piece_unit` of a line at [path] (Prompts A v5, G v3).
  /// Null when the line is not counted in pieces.
  static PieceDto? parse(JsonReader j, Map m, String path, BaseUnit? unit) {
    if (unit != BaseUnit.pc) return null;
    final raw = j.str(m, 'piece_name', path, nullable: true)?.trim().toLowerCase();
    final size = j.number(m, 'piece_size', path, nullable: true);
    final u = j.enumOf(m, 'piece_unit', path, _units, nullable: size == null);
    if (size != null && (size <= 0 || size > 5000)) {
      j.error('$path.piece_size', 'must be the size of ONE piece, from 0 to 5000');
      return PieceDto(name: raw, path: path);
    }
    return PieceDto(name: raw == null || raw.isEmpty ? null : raw, size: size, unit: u, path: path);
  }
}

/// The usual shop price of one package, from a pantry photo: [priceMinor] in the home
/// currency for [packageQty] of the item's unit.
class ShelfPriceDto {
  ShelfPriceDto(this.packageQty, this.priceMinor);
  final double packageQty;
  final int priceMinor;
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
    this.piece,
    this.product,
    this.shelfPrice,
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

  /// For a line counted in pieces: what one is called and holds.
  final PieceDto? piece;

  /// The exact product the model recognized: brand, name, variant and pack size.
  final String? product;
  final ShelfPriceDto? shelfPrice;
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
      final unit = j.enumOf(it, 'unit', path, EnumCodec.unit, nullable: true);
      final piece = PieceDto.parse(j, it, path, unit);
      // A new item without its profile is still filed: its macros are estimated later, in a batch
      // with others (NutritionService), which costs less than reading the photo again.
      NewIngredientDto? profile;
      final rawProfile = it['new_ingredient'];
      if (isNew && key != null) {
        if (rawProfile != null && rawProfile is! Map) {
          j.error('$path.new_ingredient', 'must be an object or null');
        } else if (rawProfile is Map) {
          profile = NewIngredientDto.parse(
            j,
            rawProfile.cast<String, dynamic>(),
            '$path.new_ingredient',
            unit: unit,
            piece: piece,
          );
        }
      }
      final product = j.str(it, 'product', path, nullable: true);
      ShelfPriceDto? shelf;
      final rawShelf = j.object(it, 'shelf_price', path, nullable: true);
      if (rawShelf != null) {
        final sp = '$path.shelf_price';
        final q = j.number(rawShelf, 'package_qty', sp);
        final price = j.integer(rawShelf, 'price_minor', sp);
        if (q != null && q <= 0) j.error('$sp.package_qty', 'must be > 0');
        if (price != null && price <= 0) j.error('$sp.price_minor', 'must be > 0');
        if (q != null && price != null && q > 0 && price > 0) shelf = ShelfPriceDto(q, price);
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
          unit: unit,
          piece: piece,
          qtySource: j.enumOf(it, 'qty_source', path, EnumCodec.qtySource, nullable: true) ?? QtySource.unknown,
          confidence: j.enumOf(it, 'confidence', path, EnumCodec.confidence, nullable: true) ?? Confidence.medium,
          product: product == null || product.trim().isEmpty ? null : product.trim(),
          shelfPrice: shelf,
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
}
