import 'package:flutter_test/flutter_test.dart';
import 'package:unicode_master_library/core/unicode/code_point.dart';

void main() {
  group('parseCodePoint', () {
    test('parses hex code points', () {
      expect(parseCodePoint('41'), 0x41);
      expect(parseCodePoint('0905'), 0x905);
      expect(parseCodePoint('1F600'), 0x1F600);
      expect(parseCodePoint(' 10FFFF '), 0x10FFFF);
    });

    test('rejects invalid or out-of-range values', () {
      expect(() => parseCodePoint('ZZZ'), throwsFormatException);
      expect(() => parseCodePoint('110000'), throwsFormatException);
      expect(() => parseCodePoint(''), throwsFormatException);
    });
  });

  group('tryParseCodePointQuery', () {
    test('accepts U+, 0x and bare hex', () {
      expect(tryParseCodePointQuery('U+0041'), 0x41);
      expect(tryParseCodePointQuery('u+1f600'), 0x1F600);
      expect(tryParseCodePointQuery('0x0905'), 0x905);
      expect(tryParseCodePointQuery('1F600'), 0x1F600);
    });

    test('returns null for non-hex text', () {
      expect(tryParseCodePointQuery('hello'), isNull);
      expect(tryParseCodePointQuery(''), isNull);
      expect(tryParseCodePointQuery('U+110000'), isNull);
    });
  });

  group('formatting', () {
    test('formatCodePoint pads to four digits', () {
      expect(formatCodePoint(0x41), 'U+0041');
      expect(formatCodePoint(0x1F600), 'U+1F600');
    });

    test('sequences round-trip', () {
      final cps = parseCodePointSequence('263A FE0F');
      expect(cps, [0x263A, 0xFE0F]);
      expect(formatCodePointSequence(cps), 'U+263A U+FE0F');
      expect(fromCodePoints(cps).runes.toList(), cps);
    });
  });

  group('UTF-8', () {
    test('ASCII, Devanagari and emoji encodings', () {
      expect(utf8Hex(0x41), '41');
      expect(utf8Hex(0x0905), 'E0 A4 85');
      expect(utf8Hex(0x1F600), 'F0 9F 98 80');
    });

    test('surrogates are not encodable', () {
      expect(isSurrogate(0xD800), isTrue);
      expect(isUnicodeScalar(0xD800), isFalse);
      expect(() => utf8Bytes(0xD800), throwsArgumentError);
    });
  });
}
