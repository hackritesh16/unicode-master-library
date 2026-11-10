import 'package:flutter_test/flutter_test.dart';
import 'package:unicode_master_library/core/text_design/text_fonts.dart';

void main() {
  group('mathematical alphabets', () {
    test('bold maps letters and digits', () {
      expect(
        TextFonts.bold.apply('Ab9'),
        '\u{1D400}\u{1D41B}\u{1D7D7}',
      );
    });

    test('italic uses the Planck constant for h (reserved hole)', () {
      expect(TextFonts.italic.apply('hA'), '\u{210E}\u{1D434}');
    });

    test('script fills its holes with letterlike symbols', () {
      expect(TextFonts.script.apply('BeA'), '\u{212C}\u{212F}\u{1D49C}');
    });

    test('fraktur fills its holes with letterlike symbols', () {
      expect(TextFonts.fraktur.apply('CH'), '\u{212D}\u{210C}');
    });

    test('double struck letters and digits', () {
      expect(TextFonts.doubleStruck.apply('N1'), '\u{2115}\u{1D7D9}');
    });

    test('monospace letters and digits', () {
      expect(TextFonts.monospace.apply('a0'), '\u{1D68A}\u{1D7F6}');
    });

    test('every ASCII letter maps to a different character', () {
      const letters =
          'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
      final fonts = [
        TextFonts.bold,
        TextFonts.italic,
        TextFonts.boldItalic,
        TextFonts.script,
        TextFonts.boldScript,
        TextFonts.fraktur,
        TextFonts.boldFraktur,
        TextFonts.doubleStruck,
        TextFonts.sans,
        TextFonts.sansBold,
        TextFonts.sansItalic,
        TextFonts.sansBoldItalic,
        TextFonts.monospace,
      ];
      for (final font in fonts) {
        final mapped = letters.split('').map(font.apply).toList();
        expect(mapped.toSet().length, 52, reason: '${font.id} has collisions');
        for (var i = 0; i < mapped.length; i++) {
          expect(
            mapped[i].runes.length,
            1,
            reason: '${font.id} ${letters[i]} must be one code point',
          );
          expect(mapped[i], isNot(letters[i]), reason: font.id);
        }
      }
    });
  });

  group('other styles', () {
    test('fullwidth', () {
      expect(TextFonts.fullwidth.apply('A1'), '\u{FF21}\u{FF11}');
    });

    test('circled letters and digits', () {
      expect(
        TextFonts.circled.apply('Az10'),
        '\u{24B6}\u{24E9}\u{2460}\u{24EA}',
      );
    });

    test('negative squared has no lower case: it uses capitals', () {
      expect(TextFonts.negativeSquared.apply('ab'), '\u{1F170}\u{1F171}');
    });

    test('small caps leaves letters without a small capital unchanged', () {
      expect(
        TextFonts.smallCaps.apply('Hello x'),
        '\u{29C}\u{1D07}\u{29F}\u{29F}\u{1D0F} x',
      );
    });

    test('superscript letters and digits', () {
      expect(
        TextFonts.superscript.apply('abc 12'),
        '\u{1D43}\u{1D47}\u{1D9C} \u{B9}\u{B2}',
      );
    });

    test('plain returns the text unchanged', () {
      expect(TextFonts.plain.apply('Sefali 1'), 'Sefali 1');
    });
  });

  group('unsupported characters', () {
    test('Hindi text is never replaced by unrelated characters', () {
      const hindi = 'सेफाली';
      for (final font in TextFonts.all) {
        expect(font.apply(hindi), hindi, reason: font.id);
      }
    });

    test('mixed scripts: only the Latin part is styled', () {
      expect(
        TextFonts.bold.apply('A रितेश'),
        '\u{1D400} रितेश',
      );
    });

    test('emoji and multi code point sequences are preserved', () {
      const text = '👨‍👩‍👧 🇮🇳 👍🏽 ❤️';
      expect(TextFonts.bold.apply(text), text);
    });

    test('precomposed accents are decomposed so the accent survives', () {
      expect(TextFonts.bold.apply('é'), '\u{1D41E}́');
    });

    test('combining marks already in the input are kept in order', () {
      expect(
        TextFonts.bold.apply('é̲'),
        '\u{1D41E}̲́',
      );
    });

    test('coverage reports how much of the text a font can style', () {
      expect(TextFonts.bold.coverage('Hello1'), 1);
      expect(TextFonts.italic.coverage('ab12'), lessThan(1));
      expect(TextFonts.bold.coverage('सेफाली'), 1);
    });
  });

  group('catalog', () {
    test('ids are unique and byId finds every font', () {
      final ids = TextFonts.all.map((font) => font.id).toList();
      expect(ids.toSet().length, ids.length);
      for (final id in ids) {
        expect(TextFonts.byId(id)?.id, id);
      }
      expect(TextFonts.byId('does_not_exist'), isNull);
    });
  });
}
