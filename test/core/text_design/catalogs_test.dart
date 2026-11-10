import 'package:flutter_test/flutter_test.dart';
import 'package:unicode_master_library/core/text_design/emoji_catalog.dart';
import 'package:unicode_master_library/core/text_design/graphemes.dart';
import 'package:unicode_master_library/core/text_design/symbol_catalog.dart';

void main() {
  group('EmojiCatalog', () {
    test('group ids are unique and cover the requested collections', () {
      final ids = EmojiCatalog.groups.map((g) => g.id).toList();
      expect(ids.toSet().length, ids.length);
      for (final id in [
        'hearts',
        'flowers',
        'butterflies',
        'animals',
        'nature',
        'faces',
        'stars',
        'royal',
        'objects',
        'decorations',
      ]) {
        expect(ids, contains(id));
      }
    });

    test('every entry is exactly one user-perceived emoji', () {
      for (final emoji in EmojiCatalog.all) {
        expect(
          splitGraphemes(emoji).length,
          1,
          reason: '$emoji (${emoji.runes.map((r) => r.toRadixString(16))})',
        );
      }
    });

    test('multi code point emoji are distinguishable from single ones', () {
      final multi = EmojiCatalog.all.where((e) => e.runes.length > 1);
      expect(multi, isNotEmpty);
      expect(EmojiCatalog.all.any((e) => e.runes.length == 1), isTrue);
    });

    test('entries are unique across the catalog', () {
      final all = EmojiCatalog.all;
      expect(all.toSet().length, all.length);
    });

    test('byId and search', () {
      expect(EmojiCatalog.byId('hearts'), isNotNull);
      expect(EmojiCatalog.byId('nope'), isNull);
      expect(EmojiCatalog.search(''), isEmpty);
    });
  });

  group('SymbolCatalog', () {
    test('category ids are unique and nothing is blank', () {
      final ids = SymbolCatalog.categories.map((c) => c.id).toList();
      expect(ids.toSet().length, ids.length);
      for (final category in SymbolCatalog.categories) {
        expect(category.glyphs, isNotEmpty, reason: category.id);
        for (final glyph in category.glyphs) {
          expect(glyph.trim(), isNotEmpty, reason: category.id);
        }
      }
    });

    test('searching by code point and by glyph', () {
      expect(SymbolCatalog.search('2605'), contains('★'));
      expect(SymbolCatalog.search('U+2605'), contains('★'));
      expect(SymbolCatalog.search('★'), contains('★'));
      expect(SymbolCatalog.search(''), isEmpty);
    });
  });
}
