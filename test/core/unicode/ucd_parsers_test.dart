import 'package:flutter_test/flutter_test.dart';
import 'package:unicode_master_library/core/unicode/ucd_bundle.dart';
import 'package:unicode_master_library/core/unicode/ucd_parsers.dart';

import '../../fixtures/ucd_fixture.dart';

void main() {
  group('parseUnicodeData', () {
    final result = parseUnicodeData(unicodeDataFixture);

    test('separates explicit characters from First/Last ranges', () {
      expect(result.characters.map((c) => c.cp), [
        0x0000,
        0x0041,
        0x0307,
        0x0905,
        0x1F600,
      ]);
      expect(result.ranges, hasLength(2));
    });

    test('keeps ranges unexpanded', () {
      final cjk = result.ranges.first;
      expect(cjk.name, 'CJK Ideograph Extension A');
      expect(cjk.start, 0x3400);
      expect(cjk.end, 0x4DBF);
      expect(result.ranges.last.generalCategory, 'Co'); // private use
    });

    test('reads combining class, bidi class and mappings', () {
      final dotAbove = result.characters.firstWhere((c) => c.cp == 0x0307);
      expect(dotAbove.combiningClass, 230);
      expect(dotAbove.bidiClass, 'NSM');
      expect(dotAbove.generalCategory, 'Mn');

      final a = result.characters.firstWhere((c) => c.cp == 0x41);
      expect(a.lowercaseMapping, '0061');
      expect(a.bidiMirrored, isFalse);
    });

    test('control characters keep the raw <control> name', () {
      expect(result.characters.first.name, '<control>');
    });

    test('Hindi letter is parsed', () {
      final a = result.characters.firstWhere((c) => c.cp == 0x0905);
      expect(a.name, 'DEVANAGARI LETTER A');
      expect(a.generalCategory, 'Lo');
    });

    test('rejects short lines and unmatched ranges', () {
      expect(() => parseUnicodeData('0041;A;Lu'), throwsFormatException);
      expect(
        () => parseUnicodeData('3400;<X, First>;Lo;0;L;;;;;N;;;;;\n'),
        throwsFormatException,
      );
      expect(
        () => parseUnicodeData('4DBF;<X, Last>;Lo;0;L;;;;;N;;;;;\n'),
        throwsFormatException,
      );
    });
  });

  group('parseRangeFile', () {
    test('handles ranges, single code points and comments', () {
      final ranges = parseRangeFile(scriptsFixture);
      expect(ranges, hasLength(5));
      expect(ranges[1].start, 0x41);
      expect(ranges[1].end, 0x5A);
      expect(ranges[1].value, 'Latin');
    });

    test('single code point has start == end', () {
      final ages = parseRangeFile(agesFixture);
      final grinning = ages.firstWhere((r) => r.start == 0x1F600);
      expect(grinning.end, 0x1F600);
      expect(grinning.value, '6.1');
    });

    test('multi-field values are joined', () {
      final props = parseRangeFile(derivedCoreFixture);
      expect(props.last.value, 'InCB; Linker');
    });

    test('block names with spaces', () {
      final blocks = parseRangeFile(blocksFixture);
      expect(blocks, hasLength(4));
      expect(blocks[1].value, 'Combining Diacritical Marks');
    });

    test('rejects malformed lines', () {
      expect(() => parseRangeFile('0041..0040; X'), throwsFormatException);
      expect(() => parseRangeFile('ZZZZ; X'), throwsFormatException);
      expect(() => parseRangeFile('0041'), throwsFormatException);
    });
  });

  group('parseNameAliases', () {
    test('reads alias and type', () {
      final aliases = parseNameAliases(nameAliasesFixture);
      expect(aliases, hasLength(2));
      expect(aliases.first.cp, 0);
      expect(aliases.first.alias, 'NULL');
      expect(aliases.first.type, 'control');
    });
  });

  group('parseEmojiTest', () {
    final emojis = parseEmojiTest(emojiTestFixture);

    test('distinguishes single code points from sequences', () {
      expect(emojis, hasLength(3));
      expect(emojis[0].isSingleCodePoint, isTrue);
      expect(emojis[1].isSingleCodePoint, isFalse);
      expect(emojis[1].codePoints, [0x263A, 0xFE0F]);
      expect(emojis[1].sequence.runes.toList(), [0x263A, 0xFE0F]);
    });

    test('tracks group, subgroup, status, name and version', () {
      final first = emojis.first;
      expect(first.group, 'Smileys & Emotion');
      expect(first.subgroup, 'face-smiling');
      expect(first.status, 'fully-qualified');
      expect(first.name, 'grinning face');
      expect(first.since, '1.0');
      expect(emojis[2].status, 'unqualified');
    });
  });

  group('parseUcdVersion', () {
    test('reads the version from a ReadMe spanning lines', () {
      const readme =
          'This directory contains final data files and charts for version 18.0.0 of the\n'
          'Unicode Character Database and for the synchronized Unicode Technical Standards.\n';
      expect(parseUcdVersion(readme), '18.0.0');
    });

    test('returns null when the sentence is missing', () {
      expect(parseUcdVersion('nothing useful'), isNull);
    });
  });

  group('parseUcdBundle', () {
    test('parses the full fixture bundle', () {
      final parsed = parseUcdBundle(fixtureBundle);
      expect(parsed.version, '99.0.0');
      expect(parsed.unicodeData.characters, hasLength(5));
      expect(parsed.properties, hasLength(5));
      expect(
        parsed.properties.map((p) => p.source).toSet(),
        {'PropList.txt', 'DerivedCoreProperties.txt', 'emoji-data.txt'},
      );
      expect(parsed.emojiSequences, hasLength(3));
    });

    test('emoji-test.txt is optional', () {
      final files = Map<String, String>.of(fixtureBundle.files)
        ..remove('emoji-test.txt');
      final parsed =
          parseUcdBundle(UcdBundle(version: '99.0.0', files: files));
      expect(parsed.emojiSequences, isEmpty);
    });

    test('a missing required file throws StateError', () {
      final files = Map<String, String>.of(fixtureBundle.files)
        ..remove('Blocks.txt');
      expect(
        () => parseUcdBundle(UcdBundle(version: '99.0.0', files: files)),
        throwsStateError,
      );
    });
  });
}
