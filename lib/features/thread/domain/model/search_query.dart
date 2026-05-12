import 'package:equatable/equatable.dart';

class SearchQuery with EquatableMixin {
  final String value;

  SearchQuery(this.value);

  factory SearchQuery.initial() {
    return SearchQuery('');
  }

  /// Splits the query into display search tokens for multi-keyword AND search.
  ///
  /// Unquoted text is split by whitespace, while quoted text is kept as one
  /// token without the surrounding quotes.
  ///
  /// Examples:
  /// - `'portal access'`          → `["portal", "access"]`
  /// - `'"portal access"'`        → `["portal access"]`
  /// - `'"portal access" denied'` → `["portal access", "denied"]`
  List<String> toTokens() => _parseTokens(preserveQuotedPhrase: false);

  /// Splits the query into JMAP filter tokens.
  ///
  /// Stalwart treats a text/body search as exact phrase only when the filter
  /// value itself starts and ends with quotes, so quoted user input keeps its
  /// surrounding quotes for the backend request.
  ///
  /// Examples:
  /// - `'portal access'`          → `["portal", "access"]`
  /// - `'"portal access"'`        → `["\"portal access\""]`
  /// - `'"portal access" denied'` → `["\"portal access\"", "denied"]`
  List<String> toFilterTokens() => _parseTokens(preserveQuotedPhrase: true);

  List<String> _parseTokens({required bool preserveQuotedPhrase}) {
    final query = value.trim();
    if (query.isEmpty) return [];

    final tokens = <String>[];
    final buffer = StringBuffer();
    var insideQuote = false;
    var bufferIsQuoted = false;

    void flushBuffer() {
      final token = buffer.toString().trim().replaceAll(RegExp(r'\s+'), ' ');
      if (token.isNotEmpty) {
        tokens.add(preserveQuotedPhrase && bufferIsQuoted ? '"$token"' : token);
      }
      buffer.clear();
      bufferIsQuoted = false;
    }

    for (var index = 0; index < query.length; index++) {
      final char = query[index];
      if (char == '"') {
        flushBuffer();
        insideQuote = !insideQuote;
        bufferIsQuoted = insideQuote;
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
