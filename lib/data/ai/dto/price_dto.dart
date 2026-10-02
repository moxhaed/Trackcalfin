import '../../../core/enums.dart';
import '../json_reader.dart';

/// One product's shop price from Prompt F, or [found] false.
class PriceFindDto {
  PriceFindDto({
    required this.id,
    required this.found,
    this.priceMinor,
    this.packageQty,
    this.store,
    this.source,
    this.note,
  });
  final String id;
  final bool found;

  /// One pack, in minor units of the home currency.
  final int? priceMinor;

  /// Size of that pack, in the item's unit.
  final double? packageQty;
  final String? store;

  /// Domain of the page the price was read on ("rewe.de").
  final String? source;
  final String? note;
}

/// Prompt F output: what the products of a pantry photo cost in the shops.
class PriceLookup {
  PriceLookup(this.items);
  final List<PriceFindDto> items;

  static const maxPriceMinor = 100000;

  /// [units] maps every id that was asked to its unit. Each one must come back exactly once,
  /// and a found price needs a plausible pack size for that unit.
  static ParseResult<PriceLookup> parse(Map<String, dynamic> m, {required Map<String, BaseUnit> units}) {
    final j = JsonReader();
    final out = <PriceFindDto>[];
    final seen = <String>{};
    final raw = j.list(m, 'items', r'$');
    for (var i = 0; i < raw.length; i++) {
      final path = '\$.items[$i]';
      final it = raw[i];
      if (it is! Map) {
        j.error(path, 'must be an object');
        continue;
      }
      final id = j.str(it, 'id', path);
      if (id == null) continue;
      final unit = units[id];
      if (unit == null) {
        j.error('$path.id', "'$id' was not in the input; copy input ids exactly");
        continue;
      }
      if (!seen.add(id)) {
        j.error('$path.id', "'$id' appears twice");
        continue;
      }
      if (!it.containsKey('found')) j.error('$path.found', 'is required (boolean)');
      final found = j.boolean(it, 'found', path);
      int? price;
      double? qty;
      if (found) {
        price = j.integer(it, 'price_minor', path);
        qty = j.number(it, 'package_qty', path);
        if (price != null && (price <= 0 || price > maxPriceMinor)) {
          j.error('$path.price_minor', 'must be between 1 and $maxPriceMinor for one pack');
        }
        final maxQty = unit == BaseUnit.pc ? 60 : 25000;
        if (qty != null && (qty <= 0 || qty > maxQty)) {
          j.error('$path.package_qty', 'must be between 0 and $maxQty ${unit.label} for one pack');
        }
      }
      String? text(String k) {
        final v = j.str(it, k, path, nullable: true)?.trim();
        return v == null || v.isEmpty ? null : v;
      }

      out.add(
        PriceFindDto(
          id: id,
          found: found,
          priceMinor: found ? price : null,
          packageQty: found ? qty : null,
          store: found ? text('store') : null,
          source: found ? text('source') : null,
          note: text('note'),
        ),
      );
    }
    final missing = units.keys.where((id) => !seen.contains(id)).toList();
    if (missing.isNotEmpty) j.error(r'$.items', 'is missing ids: ${missing.join(', ')}');
    if (j.errors.isNotEmpty) return ParseResult(null, j.errors);
    return ParseResult(PriceLookup(out), const []);
  }
}
