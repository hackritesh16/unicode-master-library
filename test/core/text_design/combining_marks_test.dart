import 'package:flutter_test/flutter_test.dart';
import 'package:unicode_master_library/core/text_design/combining_marks.dart';
import 'package:unicode_master_library/core/unicode/normalization.dart';

void main() {
  group('applyCombiningMarks', () {
    test('reference examples from the specification', () {
      expect(applyCombiningMarks('A', [0x0307]), 'Ȧ');
      expect(applyCombiningMarks('A', [0x0308]), 'Ä');
      expect(applyCombiningMarks('A', [0x0332]), 'A̲');
      expect(applyCombiningMarks('A', [0x0333]), 'A̳');
      expect(applyCombiningMarks('A', [0x0336]), 'A̶');
      expect(applyCombiningMarks('A', [0x0338]), 'A̸');
      expect(applyCombiningMarks('A', [0x20DB]), 'A⃛');
    });

    test('keeps the order of several marks', () {
      expect(
        applyCombiningMarks('A', [0x0332, 0x0307]),
        'Ȧ̲',
      );
      expect(
        applyCombiningMarks('A', [0x0307, 0x0332]),
        'Ȧ̲',
      );
    });

    test('never puts marks on whitespace', () {
      expect(
        applyCombiningMarks('A B', [0x0307]),
        'Ȧ Ḃ',
      );
    });

    test('can target selected letters only', () {
      expect(
        applyCombiningMarks('Sefali', [0x0307], onlyIndexes: {0, 5}),
        'Ṡefali̇',
      );
    });

    test('double marks attach to the first letter of each pair', () {
      expect(applyCombiningMarks('ABCD', [0x0361]), 'A͡BC͡D');
      expect(applyCombiningMarks('ABC', [0x0361]), 'A͡BC');
    });

    test('no marks returns the text unchanged', () {
      expect(applyCombiningMarks('Sefali', const []), 'Sefali');
    });

    test('stripCatalogMarks removes what was applied', () {
      final decorated = applyCombiningMarks('Sefali', [0x0307, 0x0332]);
      expect(decorated, isNot('Sefali'));
      expect(stripCatalogMarks(decorated), 'Sefali');
    });
  });

  group('normalization of results', () {
    test('NFC composes A + dot above and A + diaeresis', () {
      expect(
        normalizeText('Ȧ', NormalizationForm.nfc),
        'Ȧ',
      );
      expect(
        normalizeText('Ä', NormalizationForm.nfc),
        'Ä',
      );
    });

    test('marks without a precomposed form stay separate under NFC', () {
      expect(
        normalizeText('A̲', NormalizationForm.nfc),
        'A̲',
      );
    });

    test('canonicallyEqual treats precomposed and decomposed as equal', () {
      expect(canonicallyEqual('Ä', 'Ä'), isTrue);
      expect(canonicallyEqual('A', 'B'), isFalse);
    });

    test('composition exclusions stay decomposed (Devanagari QA)', () {
      expect(
        normalizeText('क़', NormalizationForm.nfd),
        'क़',
      );
      expect(
        normalizeText('क़', NormalizationForm.nfc),
        'क़',
      );
    });

    test('NFKC folds fullwidth letters, NFC does not', () {
      expect(normalizeText('Ａ', NormalizationForm.nfkc), 'A');
      expect(normalizeText('Ａ', NormalizationForm.nfc), 'Ａ');
    });
  });

  group('catalog', () {
    test('code points are unique and positions are found', () {
      final cps = CombiningMarks.all.map((mark) => mark.cp).toList();
      expect(cps.toSet().length, cps.length);
      expect(cps.length, greaterThan(100));
      expect(CombiningMarks.byCp(0x0307)?.position, MarkPosition.above);
      expect(CombiningMarks.byCp(0x0332)?.position, MarkPosition.below);
      expect(CombiningMarks.byCp(0x0338)?.position, MarkPosition.overlay);
      expect(CombiningMarks.byCp(0x20DD)?.position, MarkPosition.enclosing);
      expect(CombiningMarks.byCp(0x0361)?.position, MarkPosition.doubleSpan);
      expect(CombiningMarks.byCp(0x0041), isNull);
    });

    test('every position has marks', () {
      for (final position in MarkPosition.values) {
        expect(
          CombiningMarks.withPosition(position),
          isNotEmpty,
          reason: position.name,
        );
      }
    });

    test('filterPosition skips unknown code points', () {
      expect(
        CombiningMarks.filterPosition(
          [0x0307, 0x0332, 0x0041],
          MarkPosition.above,
        ),
        [0x0307],
      );
    });
  });

  group('analyzeMarkCompatibility', () {
    test('no marks, no warnings', () {
      expect(analyzeMarkCompatibility(text: 'A', marks: const []), isEmpty);
    });

    test('enclosing marks are flagged as risky', () {
      final warnings =
          analyzeMarkCompatibility(text: 'A', marks: const [0x20DD]);
      expect(
        warnings.any((w) => w.level == WarningLevel.caution),
        isTrue,
      );
    });

    test('three marks above one letter warn about piling up', () {
      final warnings = analyzeMarkCompatibility(
        text: 'A',
        marks: const [0x0307, 0x0308, 0x030A],
      );
      expect(warnings.any((w) => w.message.contains('above')), isTrue);
    });

    test('a single common accent is not flagged', () {
      final warnings =
          analyzeMarkCompatibility(text: 'A', marks: const [0x0301]);
      expect(
        warnings.where((w) => w.level == WarningLevel.caution),
        isEmpty,
      );
    });
  });
}
