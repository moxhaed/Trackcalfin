/// Loads the versioned system prompts from assets/prompts/.
class PromptRepository {
  PromptRepository(this._loader);

  final Future<String> Function(String assetPath) _loader;
  final _cache = <String, String>{};

  static const receipt = 'receipt_extraction.v1';
  static const daily = 'daily_recipe.v1';
  static const spontaneous = 'spontaneous_recipe.v1';

  Future<String> load(String version) async =>
      _cache[version] ??= await _loader('assets/prompts/$version.md');
}
