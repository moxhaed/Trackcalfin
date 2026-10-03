import 'package:isar_community/isar.dart';

import '../../../core/enums.dart';

part 'cookbook_import.g.dart';

/// A PDF cookbook being read into recipes: the index of what is in it, the recipes read so
/// far (drafts the user reviews) and where the reading stopped, so it can go on later.
@collection
class CookbookImport {
  Id id = Isar.autoIncrement;

  /// As picked ("Simple.pdf").
  String fileName = '';

  /// The title on the cover, as the model read it; the file name until then.
  String bookTitle = '';

  /// The app's own copy of the PDF, for uploads and later passes.
  String filePath = '';
  int sizeBytes = 0;

  /// Counted from the file when it says so, otherwise as the model reported it.
  int? pageCount;

  /// The Files API upload ("files/abc…") and its URI. Uploads expire after about 48 h.
  String? remoteName;
  String? remoteUri;
  DateTime? remoteExpiresAt;

  /// The index is read in passes of a few hundred titles; the next pass starts here.
  bool indexDone = false;
  int nextIndexPage = 1;
  int indexCalls = 0;

  /// The recipes the index found, in book order. A draft points at its entry by position.
  List<CookbookEntry> entries = [];
  List<CookbookDraft> drafts = [];

  @Index()
  @Enumerated(EnumType.name)
  CookbookStatus status = CookbookStatus.open;

  /// Why reading stopped (a daily limit, no connection, …); cleared by the next pass.
  String? lastError;

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  @ignore
  bool get hasWork => !indexDone || entries.any((e) => e.state == CookbookEntryState.pending);

  @ignore
  Iterable<CookbookDraft> get unsaved => drafts.where((d) => d.recipeId == null);
}

@embedded
class CookbookEntry {
  String title = '';

  /// PDF page (1-based) the index says the recipe starts on.
  int? page;

  @Enumerated(EnumType.name)
  CookbookEntryState state = CookbookEntryState.pending;

  /// Failed passes; a retry reads it in a smaller batch.
  int attempts = 0;
}

/// A recipe as read from the book, before Dart matches it to the pantry.
@embedded
class CookbookDraft {
  /// Position of its [CookbookEntry].
  int entry = 0;
  String title = '';
  int? page;
  int servings = 1;
  int prepMinutes = 0;
  int cookMinutes = 0;
  List<CookbookLine> ingredients = [];
  List<String> steps = [];
  List<String> tags = [];

  /// What looked off: `qty_suspect:<name>`, `allergen:<name>:<allergy>`.
  List<String> flags = [];

  /// Set once saved as a recipe.
  int? recipeId;
}

/// One ingredient line of a cookbook recipe, for the whole recipe (all servings).
@embedded
class CookbookLine {
  /// The line as printed ("2 tbsp tahini").
  String asWritten = '';
  String name = '';

  /// A pantry key the model matched, or its own generic key for something not in the pantry.
  String key = '';
  double qty = 0;

  @Enumerated(EnumType.name)
  BaseUnit unit = BaseUnit.g;

  /// "To serve", "optional": left out of the recipe and listed as such.
  bool optional = false;
}
