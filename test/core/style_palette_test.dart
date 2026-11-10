import 'package:flutter_test/flutter_test.dart';
import 'package:unicode_master_library/core/text_design/style_palette.dart';

void main() {
  group('StylePalette', () {
    test('keeps combining marks separate from their dotted-circle preview', () {
      final dot = StylePalette.entries.firstWhere(
        (entry) => entry.codePoint == 0x0307,
      );
      expect(dot.value, '\u0307');
      expect(dot.preview, '\u25CC\u0307');
      expect(dot.isCombiningMark, isTrue);
    });

    test('searches official names, glyphs and code points', () {
      expect(StylePalette.search('Combining Dot Above').single.codePoint,
          0x0307);
      expect(StylePalette.search('U+0307').single.codePoint, 0x0307);
      expect(StylePalette.search('★').single.name, 'Black Star');
    });

    test('filters by category without leaking other categories', () {
      final hearts = StylePalette.search('', category: 'Hearts');
      expect(hearts, isNotEmpty);
      expect(hearts.every((entry) => entry.category == 'Hearts'), isTrue);
    });

    test('contains no duplicate code points', () {
      final codePoints = StylePalette.entries.map((entry) => entry.codePoint);
      expect(codePoints.toSet().length, codePoints.length);
    });
  });
}
