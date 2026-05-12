import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';

void main() {
  group('SearchQuery::toTokens', () {
    test('SHOULD return empty list WHEN query is empty', () {
      expect(SearchQuery('').toTokens(), isEmpty);
      expect(SearchQuery('   ').toTokens(), isEmpty);
    });

    test('SHOULD return single token WHEN query is one word', () {
      expect(SearchQuery('portal').toTokens(), equals(['portal']));
    });

    test('SHOULD split into separate tokens WHEN query has multiple words', () {
      expect(
        SearchQuery('portal access').toTokens(),
        equals(['portal', 'access']),
      );
    });

    test('SHOULD split three words into three tokens', () {
      expect(
        SearchQuery('portal access denied').toTokens(),
        equals(['portal', 'access', 'denied']),
      );
    });

    test('SHOULD preserve quoted phrase as one token', () {
      expect(
        SearchQuery('"portal access"').toTokens(),
        equals(['portal access']),
      );
    });

    test('SHOULD preserve quoted phrase and split bare words', () {
      expect(
        SearchQuery('"portal access" denied').toTokens(),
        equals(['portal access', 'denied']),
      );
    });

    test('SHOULD preserve multiple quoted phrases', () {
      expect(
        SearchQuery('"portal access" "user login"').toTokens(),
        equals(['portal access', 'user login']),
      );
    });

    test('SHOULD split bare word and preserve quoted phrase', () {
      expect(
        SearchQuery('error "portal access"').toTokens(),
        equals(['error', 'portal access']),
      );
    });

    test(
      'SHOULD preserve exact phrase token for quoted mail content search',
      () {
        expect(
          SearchQuery('"research trial"').toTokens(),
          equals(['research trial']),
        );
      },
    );

    test('SHOULD normalize whitespace inside quoted phrase', () {
      expect(
        SearchQuery('"research   trial"').toTokens(),
        equals(['research trial']),
      );
    });

    test('SHOULD return empty list WHEN query is only quotes', () {
      expect(SearchQuery('""').toTokens(), isEmpty);
    });

    test('SHOULD trim leading and trailing whitespace', () {
      expect(
        SearchQuery('  portal access  ').toTokens(),
        equals(['portal', 'access']),
      );
    });
  });

  group('SearchQuery::toFilterTokens', () {
    test('SHOULD return empty list WHEN query is empty', () {
      expect(SearchQuery('').toFilterTokens(), isEmpty);
      expect(SearchQuery('   ').toFilterTokens(), isEmpty);
    });

    test('SHOULD split unquoted words as separate filter tokens', () {
      expect(
        SearchQuery('portal access').toFilterTokens(),
        equals(['portal', 'access']),
      );
    });

    test('SHOULD preserve quotes for Stalwart exact phrase search', () {
      expect(
        SearchQuery('"portal access"').toFilterTokens(),
        equals(['"portal access"']),
      );
    });

    test('SHOULD preserve quoted phrase and split bare words', () {
      expect(
        SearchQuery('"portal access" denied').toFilterTokens(),
        equals(['"portal access"', 'denied']),
      );
    });

    test('SHOULD preserve exact phrase filter for mail content search', () {
      expect(
        SearchQuery('"research trial"').toFilterTokens(),
        equals(['"research trial"']),
      );
    });

    test('SHOULD normalize whitespace inside quoted phrase', () {
      expect(
        SearchQuery('"research   trial"').toFilterTokens(),
        equals(['"research trial"']),
      );
    });

    test('SHOULD return empty list WHEN query is only quotes', () {
      expect(SearchQuery('""').toFilterTokens(), isEmpty);
    });
  });
}
