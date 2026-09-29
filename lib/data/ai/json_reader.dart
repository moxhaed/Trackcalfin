/// Strict JSON field reader that collects path-qualified errors for the repair retry.
class JsonReader {
  final errors = <String>[];

  void error(String path, String msg) => errors.add('$path $msg');

  bool has(Map m, String k) => m.containsKey(k);

  String? str(Map m, String k, String path, {bool nullable = false}) {
    final v = m[k];
    if (v == null) {
      if (!nullable) error('$path.$k', 'is required (string)');
      return null;
    }
    if (v is! String) {
      error('$path.$k', 'must be a string');
      return null;
    }
    return v;
  }

  int? integer(Map m, String k, String path, {bool nullable = false}) {
    final v = m[k];
    if (v == null) {
      if (!nullable) error('$path.$k', 'is required (integer)');
      return null;
    }
    if (v is int) return v;
    if (v is double && v == v.roundToDouble()) return v.toInt();
    error('$path.$k', 'must be an integer');
    return null;
  }

  double? number(Map m, String k, String path, {bool nullable = false}) {
    final v = m[k];
    if (v == null) {
      if (!nullable) error('$path.$k', 'is required (number)');
      return null;
    }
    if (v is num) return v.toDouble();
    error('$path.$k', 'must be a number');
    return null;
  }

  bool boolean(Map m, String k, String path, {bool fallback = false}) {
    final v = m[k];
    if (v is bool) return v;
    if (v != null) error('$path.$k', 'must be a boolean');
    return fallback;
  }

  T? enumOf<T>(Map m, String k, String path, Map<String, T> values, {bool nullable = false}) {
    final v = m[k];
    if (v == null) {
      if (!nullable) error('$path.$k', 'is required, one of ${values.keys.join(', ')}');
      return null;
    }
    final hit = values[v];
    if (hit == null) error('$path.$k', "'$v' is not one of ${values.keys.join(', ')}");
    return hit;
  }

  List<dynamic> list(Map m, String k, String path, {bool required = true}) {
    final v = m[k];
    if (v == null) {
      if (required) error('$path.$k', 'is required (array)');
      return const [];
    }
    if (v is! List) {
      error('$path.$k', 'must be an array');
      return const [];
    }
    return v;
  }

  Map<String, dynamic>? object(Map m, String k, String path, {bool nullable = false}) {
    final v = m[k];
    if (v == null) {
      if (!nullable) error('$path.$k', 'is required (object)');
      return null;
    }
    if (v is! Map) {
      error('$path.$k', 'must be an object');
      return null;
    }
    return v.cast<String, dynamic>();
  }

  List<String> strings(Map m, String k, String path) =>
      list(m, k, path, required: false).whereType<String>().toList();
}

class ParseResult<T> {
  ParseResult(this.value, this.errors);
  final T? value;
  final List<String> errors;
  bool get ok => errors.isEmpty && value != null;
}
