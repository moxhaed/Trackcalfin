import '../../core/enums.dart';
import '../../data/ai/dto/cookbook_dto.dart';
import '../../data/isar/collections/cookbook_import.dart';
import '../../data/isar/collections/user_profile.dart';
import '../cookbook.dart';
import 'allergens.dart';

/// Turns a recipe read from a cookbook into a draft for review. The DTO already rejected what
/// can't be used (and the model got one repair round); what is left is flagged, never dropped:
/// it is the user's own book, and they decide.
class CookbookValidator {
  const CookbookValidator._();

  /// More than this per portion of one ingredient is probably the whole recipe's amount
  /// divided wrongly, or a unit slip.
  static const maxGramsPerPortion = 1000.0;

  static CookbookDraft draft(
    CookbookRecipeDto dto, {
    required int entry,
    required String title,
    required UserProfile profile,
  }) {
    final servings = dto.servings.clamp(1, 100);
    final flags = <String>{};
    final lines = <CookbookLine>[];
    for (final l in dto.ingredients) {
      // ml counts as grams here, pieces aren't checked: their weight isn't known yet.
      if (l.unit != BaseUnit.pc && l.qty / servings > maxGramsPerPortion) flags.add('qty_suspect:${l.name}');
      final allergen = AllergenScreen.hit(l.key, profile.allergies) ?? AllergenScreen.hit(l.name, profile.allergies);
      if (allergen != null && !l.optional) flags.add('allergen:${l.name}:$allergen');
      lines.add(
        CookbookLine()
          ..asWritten = CookbookPlanner.truncate(l.asWritten, 80)
          ..name = CookbookPlanner.truncate(l.name.isEmpty ? l.key.replaceAll('_', ' ') : l.name, 60)
          ..key = l.key
          ..qty = l.qty
          ..unit = l.unit
          ..optional = l.optional,
      );
    }
    final name = title.trim().isNotEmpty ? title.trim() : dto.title.trim();
    return CookbookDraft()
      ..entry = entry
      ..title = CookbookPlanner.truncate(name.isEmpty ? 'Untitled recipe' : name, 120)
      ..page = dto.page
      ..servings = servings
      ..prepMinutes = dto.prepMinutes.clamp(0, 600)
      ..cookMinutes = dto.cookMinutes.clamp(0, 1440)
      ..ingredients = lines
      ..steps = dto.steps.take(8).map((s) => CookbookPlanner.truncate(s, 220)).toList()
      ..tags = dto.tags
      ..flags = flags.toList();
  }
}
