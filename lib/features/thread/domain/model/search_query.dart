import 'package:equatable/equatable.dart';

class SearchQuery with EquatableMixin {
  final String value;

  SearchQuery(this.value);

  factory SearchQuery.initial() {
    return SearchQuery('');
  }

  /// Splits the query into search tokens for multi-keyword AND search.
  ///
  /// Unquoted text is split by whitespace, while quoted text is kept as one
  /// token so the backend receives phrase searches such as `research trial` as
  /// a single text condition.
  ///
  /// Examples:
  /// - `'portal access'`          → `["portal", "access"]`
  /// - `'"portal access"'`        → `["portal access"]`
  /// - `'"portal access" denied'` → `["portal access", "denied"]`
  List<String> toTokens() {
    final query = value.trim();
    if (query.isEmpty) return [];

    final tokens = <String>[];
    final buffer = StringBuffer();
    var insideQuote = false;

    void flushBuffer() {
      final token = buffer.toString().trim().replaceAll(RegExp(r'\s+'), ' ');
      if (token.isNotEmpty) {
        tokens.add(token);
      }
      buffer.clear();
    }

    for (var index = 0; index < query.length; index++) {
      final char = query[index];
      if (char == '"') {
        flushBuffer();
        insideQuote = !insideQuote;
        continue;
      }

      if (!insideQuote && char.trim().isEmpty) {
        flushBuffer();
        continue;
      }

      buffer.write(char);
    }

    flushBuffer();
    return tokens;
  }

  @override
  List<Object?> get props => [value];
}
