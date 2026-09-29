/// Dart-side allergen screen: defense in depth behind the prompt rules.
class AllergenScreen {
  const AllergenScreen._();

  static const synonyms = <String, List<String>>{
    'peanut': ['peanut', 'groundnut', 'satay'],
    'tree_nut': [
      'almond',
      'walnut',
      'cashew',
      'hazelnut',
      'pecan',
      'pistachio',
      'macadamia',
      'brazil',
      'pine_nut',
      'praline',
      'marzipan',
      'nutella',
    ],
    'gluten': [
      'wheat',
      'flour',
      'pasta',
      'bread',
      'couscous',
      'barley',
      'rye',
      'semolina',
      'bulgur',
      'seitan',
      'soy_sauce',
      'noodle',
      'spaghetti',
      'penne',
      'orzo',
      'tortilla',
      'breadcrumb',
      'panko',
      'cracker',
      'beer',
      'spelt',
      'farro',
      'lasagne',
      'lasagna',
      'gnocchi',
      'pita',
      'naan',
      'bagel',
      'croissant',
      'roll',
      'bun',
    ],
    'dairy': [
      'milk',
      'cheese',
      'butter',
      'cream',
      'yogurt',
      'yoghurt',
      'whey',
      'parmesan',
      'mozzarella',
      'feta',
      'ricotta',
      'grana',
      'cheddar',
      'ghee',
      'kefir',
      'quark',
      'skyr',
      'mascarpone',
      'halloumi',
      'paneer',
      'buttermilk',
      'creme',
      'gouda',
      'emmental',
      'pecorino',
      'brie',
      'camembert',
      'burrata',
      'labneh',
    ],
    'egg': ['egg', 'mayonnaise', 'mayo', 'meringue', 'aioli'],
    'fish': [
      'fish',
      'salmon',
      'tuna',
      'cod',
      'anchovy',
      'sardine',
      'mackerel',
      'trout',
      'haddock',
      'pollock',
      'herring',
      'tilapia',
      'halibut',
      'sea_bass',
      'bass',
      'hake',
      'fish_sauce',
    ],
    'shellfish': [
      'shrimp',
      'prawn',
      'crab',
      'lobster',
      'mussel',
      'clam',
      'oyster',
      'scallop',
      'squid',
      'octopus',
      'crayfish',
    ],
    'soy': ['soy', 'soya', 'tofu', 'tempeh', 'edamame', 'miso', 'soy_sauce'],
    'sesame': ['sesame', 'tahini', 'halva'],
    'celery': ['celery', 'celeriac'],
    'mustard': ['mustard'],
  };

  static const aliases = {
    'peanuts': 'peanut',
    'nuts': 'tree_nut',
    'nut': 'tree_nut',
    'tree_nuts': 'tree_nut',
    'tree nuts': 'tree_nut',
    'lactose': 'dairy',
    'milk': 'dairy',
    'eggs': 'egg',
    'wheat': 'gluten',
    'celiac': 'gluten',
    'coeliac': 'gluten',
    'seafood': 'shellfish',
    'crustaceans': 'shellfish',
    'soya': 'soy',
  };

  /// Plant-based or unrelated items that contain a trigger word.
  static const exceptions = <String, List<String>>{
    'dairy': [
      'coconut_milk',
      'oat_milk',
      'almond_milk',
      'soy_milk',
      'soya_milk',
      'rice_milk',
      'peanut_butter',
      'cocoa_butter',
      'nut_butter',
      'almond_butter',
      'coconut_cream',
      'cream_of_tartar',
      'vegan',
      'plant',
      'dairy_free',
      'lactose_free',
    ],
    'gluten': [
      'gluten_free',
      'rice_noodle',
      'rice_paper',
      'buckwheat',
      'corn_tortilla',
      'chickpea_flour',
      'rice_flour',
    ],
    'egg': ['eggplant', 'egg_free', 'vegan_mayo'],
    'tree_nut': ['coconut', 'nutmeg', 'butternut', 'water_chestnut'],
    'fish': ['fish_free'],
  };

  static String canonical(String allergy) {
    final a = allergy.toLowerCase().trim().replaceAll(RegExp(r'[\s-]+'), '_');
    return aliases[a] ?? aliases[allergy.toLowerCase().trim()] ?? a;
  }

  static List<String> _tokens(String s) {
    final base = s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
    return base
        .split('_')
        .where((t) => t.isNotEmpty)
        .map((t) => t.length > 3 && t.endsWith('es') && !t.endsWith('ses') ? t.substring(0, t.length - 2) : t)
        .map((t) => t.length > 3 && t.endsWith('s') ? t.substring(0, t.length - 1) : t)
        .toList();
  }

  /// Returns the allergy that [keyOrName] triggers, or null.
  static String? hit(String keyOrName, List<String> allergies) {
    if (allergies.isEmpty) return null;
    final text = keyOrName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
    final tokens = _tokens(keyOrName);
    final joined = tokens.join('_');
    for (final allergy in allergies) {
      final c = canonical(allergy);
      final words = synonyms[c] ?? [c];
      if ((exceptions[c] ?? const []).any((e) => text.contains(e))) continue;
      for (final w in words) {
        final hitWord = w.contains('_') ? joined.contains(w) : tokens.contains(w);
        if (hitWord) return allergy;
      }
    }
    return null;
  }
}
