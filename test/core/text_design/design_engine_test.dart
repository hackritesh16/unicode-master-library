import 'package:flutter_test/flutter_test.dart';
import 'package:unicode_master_library/core/text_design/combining_marks.dart';
import 'package:unicode_master_library/core/text_design/design_engine.dart';
import 'package:unicode_master_library/core/text_design/design_themes.dart';
import 'package:unicode_master_library/core/text_design/design_types.dart';
import 'package:unicode_master_library/core/text_design/emoji_catalog.dart';
import 'package:unicode_master_library/core/text_design/graphemes.dart';
import 'package:unicode_master_library/core/text_design/text_fonts.dart';

DesignBatch run(
  String name, {
  List<String> themes = const [],
  int count = 20,
  int seed = 1,
  List<String> fonts = const [],
  FontMixing mixing = FontMixing.theme,
  bool emoji = true,
  List<String> customEmojis = const [],
  bool marks = true,
  DecorIntensity intensity = DecorIntensity.balanced,
  Set<String> exclude = const {},
}) {
  return DesignEngine.generate(
    DesignRequest(
      name: name,
      themeIds: themes,
      count: count,
      seed: seed,
      fontIds: fonts,
      fontMixing: mixing,
      useEmoji: emoji,
      customEmojis: customEmojis,
      useMarks: marks,
      intensity: intensity,
      exclude: exclude,
    ),
  );
}

void expectSound(DesignBatch batch) {
  final texts = batch.designs.map((d) => d.text).toList();
  expect(texts.toSet().length, texts.length, reason: 'designs must be unique');
  for (final design in batch.designs) {
    expect(design.text.trim(), design.text);
    expect(design.text, isNotEmpty);
    expect(
      findSequenceProblems(design.text),
      isEmpty,
      reason: 'broken sequence in ${design.text} (${design.themeId})',
    );
    expect(design.graphemeCount, lessThanOrEqualTo(90));
    expect(design.codePoints, design.text.runes.toList());
  }
}

void main() {
  group('theme data is consistent', () {
    for (final theme in DesignThemes.all) {
      test(theme.id, () {
        expect(theme.minDecor, lessThanOrEqualTo(theme.maxDecor));
        for (final chance in [
          theme.wrapChance,
          theme.bracketChance,
          theme.capChance,
          theme.lineChance,
          theme.emojiChance,
          theme.mixChance,
          theme.lineMarkChance,
          theme.multiLineChance,
        ]) {
          expect(chance, inInclusiveRange(0, 1));
        }
        expect(theme.fontIds, isNotEmpty);
        for (final id in theme.fontIds) {
          expect(TextFonts.byId(id), isNotNull, reason: 'font $id');
        }
        for (final id in theme.emojiGroups) {
          expect(EmojiCatalog.byId(id), isNotNull, reason: 'emoji group $id');
        }
        for (final cp in [...theme.letterMarks, ...theme.lineMarks]) {
          expect(CombiningMarks.byCp(cp), isNotNull, reason: 'mark $cp');
        }
        expect(theme.wraps, isNotEmpty);
        expect(theme.caps, isNotEmpty);
        expect(theme.lines, isNotEmpty);
        expect(theme.letterDecor, isNotEmpty);
        expect(DesignThemes.byId(theme.id), theme);
      });
    }

    test('ids are unique', () {
      final ids = DesignThemes.all.map((t) => t.id).toList();
      expect(ids.toSet().length, ids.length);
      expect(ids.length, 15);
    });
  });

  group('cleanName', () {
    test('collapses whitespace and trims', () {
      expect(DesignEngine.cleanName('  Sefali \n  Kumari '), 'Sefali Kumari');
    });

    test('limits the length without cutting a character in half', () {
      final long = 'ab' * 30;
      expect(
        splitGraphemes(DesignEngine.cleanName(long)).length,
        maxDesignNameLength,
      );
      final family = '👨‍👩‍👧' * 50;
      final cut = DesignEngine.cleanName(family);
      expect(splitGraphemes(cut).length, maxDesignNameLength);
      expect(findSequenceProblems(cut), isEmpty);
    });

    test('keeps zero width joiners', () {
      expect(DesignEngine.cleanName('क्‍ष'), 'क्‍ष');
    });
  });

  group('generate', () {
    test('empty name yields no designs and a note', () {
      final batch = run('   ');
      expect(batch.designs, isEmpty);
      expect(batch.notes, isNotEmpty);
    });

    test('count is limited to 100', () {
      expect(run('Sefali', count: 500).requested, 100);
      expect(run('Sefali', count: 0).requested, 1);
    });

    test('20, 50 and 100 unique designs across all themes', () {
      for (final count in [20, 50, 100]) {
        final batch = run('Sefali', count: count);
        expect(batch.designs.length, count, reason: 'count $count');
        expect(batch.isComplete, isTrue);
        expectSound(batch);
      }
    });

    test('every theme yields at least 20 sound designs', () {
      for (final theme in DesignThemes.all) {
        final batch = run('Sefali', themes: [theme.id], count: 20);
        expect(
          batch.designs.length,
          greaterThanOrEqualTo(20),
          reason: theme.id,
        );
        expectSound(batch);
        expect(batch.designs.every((d) => d.themeId == theme.id), isTrue);
      }
    });

    test('same seed gives the same designs, another seed differs', () {
      final a = run('Sefali', seed: 42).designs.map((d) => d.text).toList();
      final b = run('Sefali', seed: 42).designs.map((d) => d.text).toList();
      final c = run('Sefali', seed: 43).designs.map((d) => d.text).toList();
      expect(a, b);
      expect(a, isNot(c));
    });

    test('exclude prevents repeating designs ("generate more")', () {
      final first = run('Sefali', count: 50);
      final more = run(
        'Sefali',
        count: 50,
        seed: 2,
        exclude: first.designs.map((d) => d.text).toSet(),
      );
      final firstTexts = first.designs.map((d) => d.text).toSet();
      expect(more.designs.any((d) => firstTexts.contains(d.text)), isFalse);
    });

    test('a combined name with spaces and digits stays sound', () {
      expectSound(run('Player 1', count: 50));
      expectSound(run('2026', count: 20));
      expectSound(run('A', count: 20));
    });

    test('Hindi name: letters are preserved and never get Latin marks', () {
      const name = 'सेफाली';
      final batch = run(name, count: 50);
      expect(batch.designs, isNotEmpty);
      expectSound(batch);
      for (final design in batch.designs) {
        for (final grapheme in splitGraphemes(name)) {
          expect(design.text.contains(grapheme), isTrue, reason: design.text);
        }
        final runes = design.text.runes.toList();
        for (var i = 1; i < runes.length; i++) {
          final onDevanagari = runes[i - 1] >= 0x0900 && runes[i - 1] <= 0x097F;
          if (onDevanagari) {
            expect(
              CombiningMarks.byCp(runes[i]),
              isNull,
              reason: 'mark on Devanagari in ${design.text}',
            );
          }
        }
      }
    });

    test('mixed scripts stay sound', () {
      final batch = run('Ritesh रितेश', count: 50);
      expectSound(batch);
      expect(batch.designs.length, 50);
    });

    test('emoji in the name are kept as whole sequences', () {
      final batch = run('Sef😀', count: 20);
      expectSound(batch);
      expect(batch.designs.every((d) => d.text.contains('😀')), isTrue);

      final family = run('A👨‍👩‍👧B', count: 20);
      expectSound(family);
      expect(family.designs.every((d) => d.text.contains('👨‍👩‍👧')), isTrue);
    });

    test('name with combining marks stays sound', () {
      expectSound(run('Amélie', count: 20));
    });

    test('marks off: no catalog combining mark appears anywhere', () {
      final batch = run('Sefali', count: 100, marks: false);
      expectSound(batch);
      for (final design in batch.designs) {
        for (final rune in design.text.runes) {
          expect(
            CombiningMarks.byCp(rune),
            isNull,
            reason: 'mark in ${design.text}',
          );
        }
        expect(design.markCodePoints, isEmpty);
      }
    });

    test('marks are only used when enabled and are reported', () {
      final batch = run('Sefali', count: 100);
      final withMarks = batch.designs.where((d) => d.markCodePoints.isNotEmpty);
      expect(withMarks, isNotEmpty);
      for (final design in withMarks) {
        for (final cp in design.markCodePoints) {
          expect(design.text.runes.contains(cp), isTrue);
        }
      }
    });

    test('custom emoji are used instead of theme emoji', () {
      final batch = run(
        'Sefali',
        themes: ['cute'],
        count: 50,
        customEmojis: ['🌟'],
      );
      expectSound(batch);
      expect(batch.designs.where((d) => d.text.contains('🌟')).length,
          greaterThan(5));
    });

    test('chosen fonts are respected', () {
      final batch = run(
        'Sefali',
        themes: ['minimal'],
        count: 20,
        fonts: ['monospace'],
        mixing: FontMixing.never,
      );
      expectSound(batch);
      for (final design in batch.designs) {
        expect(design.fontIds, ['monospace']);
        expect(design.text.contains('\u{1D68A}'), isTrue); // monospace a
      }
    });

    test('font mixing combines two styles inside one name', () {
      final batch = run(
        'Sefali',
        themes: ['cute'],
        count: 50,
        fonts: ['bold', 'script'],
        mixing: FontMixing.often,
      );
      expectSound(batch);
      expect(batch.designs.any((d) => d.fontIds.length == 2), isTrue);
      expect(batch.designs.any((d) => d.fontIds.length == 1), isTrue);
    });

    test('never mixing keeps one font per design', () {
      final batch = run(
        'Sefali',
        count: 50,
        mixing: FontMixing.never,
      );
      expect(batch.designs.every((d) => d.fontIds.length == 1), isTrue);
    });

    test('subtle designs are lighter than rich ones', () {
      double average(DecorIntensity intensity) {
        final batch = run(
          'Sefali',
          count: 100,
          intensity: intensity,
          marks: false,
        );
        final total =
            batch.designs.fold<int>(0, (sum, d) => sum + d.graphemeCount);
        return total / batch.designs.length;
      }

      expect(
        average(DecorIntensity.subtle),
        lessThan(average(DecorIntensity.rich)),
      );
    });

    test('line art can produce balanced three line designs', () {
      final batch = run('Sefali', themes: ['line_art'], count: 100);
      final multi = batch.designs.where((d) => d.text.contains('\n')).toList();
      expect(multi, isNotEmpty);
      for (final design in multi) {
        final lines = design.text.split('\n');
        expect(lines.length, 3);
        expect(lines.first, lines.last, reason: 'bars must be symmetrical');
      }
    });

    test('warnings are advisory and never claim universal support', () {
      final batch = run('Sefali', themes: ['unicode_pad'], count: 100);
      final warned = batch.designs.where((d) => d.warnings.isNotEmpty);
      expect(warned, isNotEmpty);
      for (final design in warned) {
        for (final warning in design.warnings) {
          expect(warning.message.toLowerCase(), isNot(contains('works in all')));
        }
      }
    });
  });

  group('fontStyles', () {
    test('returns every style except plain, with the name unchanged in plain',
        () {
      final styles = DesignEngine.fontStyles('Sefali');
      expect(styles.length, TextFonts.all.length - 1);
      expect(styles.every((s) => s.font.id != 'plain'), isTrue);
      final bold = styles.firstWhere((s) => s.font.id == 'bold');
      expect(bold.text, TextFonts.bold.apply('Sefali'));
    });
  });
}
