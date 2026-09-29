import '../core/enums.dart';
import '../core/money.dart';
import '../data/isar/collections/user_profile.dart';

class ParsedExpense {
  ParsedExpense(this.amountMinor, this.category, this.note, this.keyword);
  final int amountMinor;
  final SpendCategory? category;
  final String note;
  final String? keyword;
}

/// "12.50 lunch" -> amount + category, no network.
class QuickTextParser {
  const QuickTextParser._();

  static const builtIn = <String, SpendCategory>{
    // eating out
    'lunch': SpendCategory.eatingOut, 'dinner': SpendCategory.eatingOut,
    'breakfast': SpendCategory.eatingOut, 'brunch': SpendCategory.eatingOut,
    'coffee': SpendCategory.eatingOut, 'cafe': SpendCategory.eatingOut,
    'café': SpendCategory.eatingOut, 'restaurant': SpendCategory.eatingOut,
    'pizza': SpendCategory.eatingOut, 'kebab': SpendCategory.eatingOut,
    'burger': SpendCategory.eatingOut, 'sushi': SpendCategory.eatingOut,
    'takeaway': SpendCategory.eatingOut, 'takeout': SpendCategory.eatingOut,
    'delivery': SpendCategory.eatingOut, 'bar': SpendCategory.eatingOut,
    'beer': SpendCategory.eatingOut, 'drinks': SpendCategory.eatingOut,
    'canteen': SpendCategory.eatingOut, 'snack': SpendCategory.eatingOut,
    // entertainment
    'cinema': SpendCategory.entertainment, 'movie': SpendCategory.entertainment,
    'movies': SpendCategory.entertainment, 'concert': SpendCategory.entertainment,
    'netflix': SpendCategory.entertainment, 'spotify': SpendCategory.entertainment,
    'game': SpendCategory.entertainment, 'games': SpendCategory.entertainment,
    'book': SpendCategory.entertainment, 'books': SpendCategory.entertainment,
    'museum': SpendCategory.entertainment, 'theatre': SpendCategory.entertainment,
    'theater': SpendCategory.entertainment, 'tickets': SpendCategory.entertainment,
    'ticket': SpendCategory.entertainment, 'gym': SpendCategory.entertainment,
    // clothes
    'shirt': SpendCategory.clothes, 'tshirt': SpendCategory.clothes,
    'shoes': SpendCategory.clothes, 'jeans': SpendCategory.clothes,
    'jacket': SpendCategory.clothes, 'dress': SpendCategory.clothes,
    'socks': SpendCategory.clothes, 'clothes': SpendCategory.clothes,
    'zara': SpendCategory.clothes, 'h&m': SpendCategory.clothes,
    'uniqlo': SpendCategory.clothes, 'primark': SpendCategory.clothes,
    // household
    'detergent': SpendCategory.household, 'soap': SpendCategory.household,
    'ikea': SpendCategory.household, 'cleaning': SpendCategory.household,
    'toilet': SpendCategory.household, 'shampoo': SpendCategory.household,
    'toothpaste': SpendCategory.household, 'pharmacy': SpendCategory.household,
    'dm': SpendCategory.household, 'rossmann': SpendCategory.household,
    'household': SpendCategory.household,
    // groceries
    'groceries': SpendCategory.groceries, 'grocery': SpendCategory.groceries,
    'supermarket': SpendCategory.groceries, 'lidl': SpendCategory.groceries,
    'aldi': SpendCategory.groceries, 'rewe': SpendCategory.groceries,
    'edeka': SpendCategory.groceries, 'market': SpendCategory.groceries,
    'tesco': SpendCategory.groceries, 'carrefour': SpendCategory.groceries,
  };

  static final _amount = RegExp(r'(\d+(?:[.,]\d{1,2})?)');

  static ParsedExpense? parse(String input, {List<KeywordCategory> learned = const [], MoneyFormat? money}) {
    final m = _amount.firstMatch(input);
    if (m == null) return null;
    final amount = (money ?? const MoneyFormat()).parse(m.group(1)!);
    if (amount == null || amount <= 0) return null;
    final rest = input.replaceRange(m.start, m.end, ' ').trim();
    final tokens = rest
        .toLowerCase()
        .split(RegExp(r'[\s,;:/]+'))
        .map((t) => t.replaceAll(RegExp(r'[^\p{L}&]', unicode: true), ''))
        .where((t) => t.isNotEmpty)
        .toList();
    final learnedMap = {for (final k in learned) k.keyword: k.category};
    SpendCategory? category;
    String? keyword;
    for (final t in tokens) {
      if (learnedMap.containsKey(t)) {
        category = learnedMap[t];
        keyword = t;
        break;
      }
    }
    if (category == null) {
      for (final t in tokens) {
        if (builtIn.containsKey(t)) {
          category = builtIn[t];
          keyword = t;
          break;
        }
      }
    }
    return ParsedExpense(amount, category, rest.replaceAll(RegExp(r'\s+'), ' '), keyword ?? tokens.firstOrNull);
  }

  /// Upserts the user's correction into the learned keyword memory.
  static List<KeywordCategory> learn(List<KeywordCategory> learned, String keyword, SpendCategory category) {
    final k = keyword.toLowerCase().trim();
    if (k.isEmpty) return learned;
    final out = learned.where((e) => e.keyword != k).toList()
      ..add(KeywordCategory()
        ..keyword = k
        ..category = category);
    return out.length > 200 ? out.sublist(out.length - 200) : out;
  }
}
