import 'dart:math';

import 'combining_marks.dart';
import 'design_themes.dart';
import 'design_types.dart';
import 'emoji_catalog.dart';
import 'graphemes.dart';
import 'text_fonts.dart';

/// Longest name (in user-perceived characters) the engine accepts.
const int maxDesignNameLength = 40;

/// Designs longer than this many user-perceived characters are rejected: long
/// compositions wrap badly in chat apps and profile fields.
const int _maxDesignGraphemes = 90;

/// A name styled with several fonts, one letter at a time.
typedef FontStyledText = ({TextFont font, String text});

/// Generates decorated Unicode name designs.
///
/// The engine never picks a fixed template. For every design it draws a font
/// plan, a letter decoration, and a frame (wrap, bracket, line run, caps,
/// emoji) from the theme's pools, then applies design rules:
///
/// * frames are symmetrical and line runs are the same length on both sides;
/// * the number of decoration glyphs stays inside the theme's clutter budget;
/// * combining marks are only put on Latin letters, never on spaces, never
///   on enclosed (circled or squared) letters, and are capped per letter and
///   per design;
/// * no design may contain a structurally broken sequence;
/// * every design in a batch is unique.
abstract final class DesignEngine {
  /// Collapses whitespace and limits [input] to [maxDesignNameLength]
  /// user-perceived characters. Zero-width joiners are kept (they are part of
  /// Indic and emoji sequences).
  static String cleanName(String input) {
    final collapsed = input.replaceAll(RegExp(r'\s+'), ' ').trim();
    final graphemes = splitGraphemes(collapsed);
    if (graphemes.length <= maxDesignNameLength) {
      return collapsed;
    }
    return graphemes.take(maxDesignNameLength).join().trim();
  }

  /// Applies every font to [name] (one font per row). Characters a font
  /// cannot represent stay exactly as typed.
  static List<FontStyledText> fontStyles(String name) {
    final clean = cleanName(name);
    return [
      for (final font in TextFonts.all)
        if (font.id != 'plain') (font: font, text: font.apply(clean)),
    ];
  }

  /// Generates up to [DesignRequest.count] unique designs.
  static DesignBatch generate(DesignRequest request) {
    final count = min(100, max(1, request.count));
    final name = cleanName(request.name);
    if (name.isEmpty) {
      return DesignBatch(
        designs: const [],
        requested: count,
        notes: const ['Enter a name to generate designs.'],
      );
    }

    final themes = _resolveThemes(request.themeIds);
    final context = _Context(
      request: request,
      name: name,
      graphemes: splitGraphemes(name),
      rng: Random(request.seed ?? DateTime.now().microsecondsSinceEpoch),
    );

    final seen = <String>{...request.exclude};
    final designs = <GeneratedDesign>[];
    final misses = <String, int>{};
    final exhausted = <String>{};
    final maxAttempts = count * 90;
    var attempts = 0;
    var cursor = 0;

    while (designs.length < count &&
        attempts < maxAttempts &&
        exhausted.length < themes.length) {
      attempts++;
      final theme = themes[cursor % themes.length];
      cursor++;
      if (exhausted.contains(theme.id)) {
        continue;
      }
      final design = _composeOne(theme, context);
      if (design != null && seen.add(design.text)) {
        designs.add(design);
        misses[theme.id] = 0;
      } else {
        final missCount = (misses[theme.id] ?? 0) + 1;
        misses[theme.id] = missCount;
        if (missCount >= 150) {
          exhausted.add(theme.id);
        }
      }
    }

    final notes = <String>[];
    if (designs.length < count) {
      notes.add(
        'Only ${designs.length} unique designs were possible with these '
        'settings. Try another theme, more fonts or a richer intensity.',
      );
    }
    return DesignBatch(designs: designs, requested: count, notes: notes);
  }
}

List<DesignTheme> _resolveThemes(List<String> ids) {
  if (ids.isEmpty) {
    return DesignThemes.all;
  }
  final themes = <DesignTheme>[];
  for (final id in ids) {
    final theme = DesignThemes.byId(id);
    if (theme != null && !themes.contains(theme)) {
      themes.add(theme);
    }
  }
  return themes.isEmpty ? DesignThemes.all : themes;
}

class _Context {
  _Context({
    required this.request,
    required this.name,
    required this.graphemes,
    required this.rng,
  });

  final DesignRequest request;
  final String name;
  final List<String> graphemes;
  final Random rng;
  final Map<String, List<TextFont>> _fontPools = {};

  /// Fonts usable for [theme]: the user's choice if any, else the theme's own.
  /// Fonts that cannot represent the letters of the name are dropped, so a
  /// design never silently loses half of its letters.
  List<TextFont> fontsFor(DesignTheme theme) {
    final ids = request.fontIds.isNotEmpty ? request.fontIds : theme.fontIds;
    return _fontPools.putIfAbsent(ids.join(','), () {
      final fonts = <TextFont>[];
      for (final id in ids) {
        final font = TextFonts.byId(id);
        if (font != null && !fonts.contains(font)) {
          fonts.add(font);
        }
      }
      final covering = [
        for (final font in fonts)
          if (font.coverage(name) >= 0.99) font,
      ];
      if (covering.isNotEmpty) {
        return covering;
      }
      return fonts.isNotEmpty ? fonts : [TextFonts.bold];
    });
  }
}

/// A finished piece of a design: its text, how many decoration glyphs it
/// added, and which combining marks it used.
class _Core {
  const _Core(this.text, this.decor, this.letterMarks, this.allMarks);

  final String text;
  final int decor;

  /// Marks on the most decorated letter (used for compatibility advice).
  final List<int> letterMarks;
  final Set<int> allMarks;
}

const Map<String, double> _upperBias = {
  'attitude': 0.45,
  'gaming': 0.5,
  'heavy': 0.2,
  'royal': 0.2,
  'luxury': 0.2,
};

const Map<String, double> _lowerBias = {
  'aesthetic': 0.4,
  'minimal': 0.35,
  'cute': 0.2,
  'princess': 0.1,
  'floral': 0.15,
};

const int _maxMarksPerDesign = 30;

T _pick<T>(List<T> items, Random rng) => items[rng.nextInt(items.length)];

T _weighted<T>(Map<T, double> weights, Random rng) {
  final total = weights.values.fold<double>(0, (sum, weight) => sum + weight);
  var roll = rng.nextDouble() * total;
  for (final entry in weights.entries) {
    roll -= entry.value;
    if (roll <= 0) {
      return entry.key;
    }
  }
  return weights.keys.last;
}

/// Number of visible decoration glyphs in [piece] (spaces do not count).
int _decorCount(String piece) =>
    splitGraphemes(piece).where((g) => !isBlankGrapheme(g)).length;

bool _isMarkMode(LetterDecoration mode) =>
    mode == LetterDecoration.above ||
    mode == LetterDecoration.below ||
    mode == LetterDecoration.overlay;

/// True when combining marks look right on [grapheme]: Latin letters and
/// digits, their styled Unicode forms and Latin small capitals. Enclosed
/// letters are boxes already, and other scripts have their own marks.
bool _acceptsMarks(String grapheme) {
  if (grapheme.isEmpty) {
    return false;
  }
  final r = grapheme.runes.first;
  return (r >= 0x30 && r <= 0x39) ||
      (r >= 0x41 && r <= 0x5A) ||
      (r >= 0x61 && r <= 0x7A) ||
      (r >= 0xC0 && r <= 0x2FF) ||
      (r >= 0x1D00 && r <= 0x1DBF) ||
      (r >= 0x2100 && r <= 0x214F) ||
      (r >= 0xA720 && r <= 0xA7FF) ||
      (r >= 0xFF21 && r <= 0xFF5A) ||
      (r >= 0x1D400 && r <= 0x1D7FF);
}

GeneratedDesign? _composeOne(DesignTheme theme, _Context c) {
  final rng = c.rng;
  final intensity = c.request.intensity;
  final chanceScale = switch (intensity) {
    DecorIntensity.subtle => 0.7,
    DecorIntensity.balanced => 1.0,
    DecorIntensity.rich => 1.25,
  };
  bool roll(double chance) => rng.nextDouble() < min(0.95, chance * chanceScale);

  final maxDecor = (theme.maxDecor *
          switch (intensity) {
            DecorIntensity.subtle => 0.7,
            DecorIntensity.balanced => 1.0,
            DecorIntensity.rich => 1.3,
          })
      .round();
  final minDecor = intensity == DecorIntensity.subtle
      ? max(1, (theme.minDecor * 0.5).round())
      : theme.minDecor;

  // 1. Letters: case, font plan, styling.
  final styled = _styleLetters(theme, c);
  final usedFonts = <String>{...styled.fontIds};

  // 2. Letter decoration (marks, separators, spacing).
  final core = _decorateLetters(theme, c, styled.graphemes, intensity);
  var text = core.text;
  var decor = core.decor;

  // 3. Frame around the name.
  final multiLine = theme.multiLineChance > 0 &&
      theme.lines.isNotEmpty &&
      roll(theme.multiLineChance);
  final lineMarks = <int>{};
  var lineUsed = false;

  if (theme.wraps.isNotEmpty && roll(theme.wrapChance)) {
    final wrap = _pick(theme.wraps, rng);
    text = '${wrap.left}$text${wrap.right}';
    decor += _decorCount(wrap.left) + _decorCount(wrap.right);
  } else {
    if (theme.brackets.isNotEmpty && roll(theme.bracketChance)) {
      final bracket = _pick(theme.brackets, rng);
      final spaced = rng.nextDouble() < 0.4;
      text = spaced
          ? '${bracket.left} $text ${bracket.right}'
          : '${bracket.left}$text${bracket.right}';
      decor += 2;
    }
    if (!multiLine && theme.lines.isNotEmpty && roll(theme.lineChance)) {
      final run = _lineRun(theme, c, text, lineMarks);
      text = '${run.text} $text ${run.text}';
      decor += run.glyphs * 2;
      lineUsed = true;
    }
    if (theme.caps.isNotEmpty && roll(theme.capChance)) {
      final layers =
          theme.maxCaps > 1 && rng.nextDouble() < 0.4 ? 2 : 1;
      final chosen = <WrapPair>[];
      for (var i = 0; i < layers; i++) {
        final cap = _pick(theme.caps, rng);
        if (!chosen.contains(cap)) {
          chosen.add(cap);
        }
      }
      final spaced = lineUsed ? rng.nextDouble() < 0.25 : rng.nextDouble() < 0.8;
      for (final cap in chosen) {
        text = spaced
            ? '${cap.left} $text ${cap.right}'
            : '${cap.left}$text${cap.right}';
        decor += _decorCount(cap.left) + _decorCount(cap.right);
      }
    }
  }

  // 4. Emoji.
  if (c.request.useEmoji && roll(theme.emojiChance)) {
    final pair = _pickEmoji(theme, c);
    final shape = rng.nextDouble();
    if (pair.left.isNotEmpty && pair.right.isNotEmpty && shape < 0.55) {
      text = '${pair.left} $text ${pair.right}';
      decor += _decorCount(pair.left) + _decorCount(pair.right);
    } else if (pair.right.isNotEmpty && shape < 0.85) {
      text = '$text ${pair.right}';
      decor += _decorCount(pair.right);
    } else if (pair.left.isNotEmpty) {
      text = '${pair.left} $text';
      decor += _decorCount(pair.left);
    }
  }

  // 5. Design rules.
  if (decor < minDecor || decor > maxDecor) {
    return null;
  }

  // 6. Optional line / name / line layout with balanced line lengths.
  if (multiLine) {
    final width = min(30, max(8, splitGraphemes(text).length));
    final glyph = _pick(theme.lines, rng);
    final capped = theme.caps.isNotEmpty && rng.nextDouble() < 0.4;
    final String bar;
    if (capped) {
      final cap = _pick(theme.caps, rng);
      bar = '${cap.left}${glyph * (width - 2)}${cap.right}';
    } else {
      bar = glyph * width;
    }
    text = '$bar\n$text\n$bar';
  }

  text = text.trim();
  if (splitGraphemes(text).length > _maxDesignGraphemes) {
    return null;
  }
  if (findSequenceProblems(text).isNotEmpty) {
    return null;
  }

  final allMarks = <int>{...core.allMarks, ...lineMarks};
  return GeneratedDesign(
    text: text,
    themeId: theme.id,
    fontIds: usedFonts.toList(),
    markCodePoints: allMarks.toList()..sort(),
    warnings: _warningsFor(
      name: c.name,
      text: text,
      letterMarks: core.letterMarks,
      lineMarks: lineMarks.toList(),
    ),
  );
}

class _Styled {
  const _Styled(this.graphemes, this.fontIds);

  final List<String> graphemes;
  final List<String> fontIds;
}

/// Applies the case policy and a font plan (one font, or two mixed fonts) to
/// the letters of the name.
_Styled _styleLetters(DesignTheme theme, _Context c) {
  final rng = c.rng;
  final source = c.graphemes;

  var upper = false;
  var lower = false;
  final caseRoll = rng.nextDouble();
  final upperBias = _upperBias[theme.id] ?? 0;
  final lowerBias = _lowerBias[theme.id] ?? 0;
  if (caseRoll < upperBias) {
    upper = true;
  } else if (caseRoll < upperBias + lowerBias) {
    lower = true;
  }
  String recase(String g) {
    if (g.length != 1) {
      return g;
    }
    if (upper) {
      return g.toUpperCase();
    }
    if (lower) {
      return g.toLowerCase();
    }
    return g;
  }

  final fonts = c.fontsFor(theme);
  final first = _pick(fonts, rng);
  final mixChance = switch (c.request.fontMixing) {
    FontMixing.never => 0.0,
    FontMixing.often => 0.65,
    FontMixing.theme => theme.mixChance,
  };
  final others = [
    for (final font in fonts)
      if (font.id != first.id) font,
  ];
  final mix = others.isNotEmpty &&
      source.length >= 2 &&
      rng.nextDouble() < mixChance;

  final plan = List<TextFont>.filled(source.length, first);
  if (mix) {
    final second = _pick(others, rng);
    final strategy = rng.nextInt(3);
    final letters = source.where((g) => !isBlankGrapheme(g)).length;
    final split = letters < 2 ? 1 : 1 + rng.nextInt(letters - 1);
    var inWord = 0;
    var letterIndex = 0;
    for (var i = 0; i < source.length; i++) {
      if (isBlankGrapheme(source[i])) {
        inWord = 0;
        continue;
      }
      final bool useFirst;
      if (strategy == 0) {
        useFirst = inWord != 0;
      } else if (strategy == 1) {
        useFirst = inWord.isEven;
      } else {
        useFirst = letterIndex < split;
      }
      plan[i] = useFirst ? first : second;
      inWord++;
      letterIndex++;
    }
  }

  final fontIds = <String>[];
  final graphemes = <String>[];
  for (var i = 0; i < source.length; i++) {
    graphemes.add(plan[i].apply(recase(source[i])));
    if (!isBlankGrapheme(source[i]) && !fontIds.contains(plan[i].id)) {
      fontIds.add(plan[i].id);
    }
  }
  return _Styled(graphemes, fontIds);
}

List<int> _markPool(DesignTheme theme, LetterDecoration mode) {
  final wanted = switch (mode) {
    LetterDecoration.above => const [MarkPosition.above],
    LetterDecoration.below => const [MarkPosition.below],
    LetterDecoration.overlay => const [
        MarkPosition.overlay,
        MarkPosition.enclosing,
      ],
    _ => const <MarkPosition>[],
  };
  return [
    for (final cp in theme.letterMarks)
      if (wanted.contains(CombiningMarks.byCp(cp)?.position)) cp,
  ];
}

_Core _decorateLetters(
  DesignTheme theme,
  _Context c,
  List<String> styled,
  DecorIntensity intensity,
) {
  final rng = c.rng;
  final plain = _Core(styled.join(), 0, const [], const {});

  final noneScale = switch (intensity) {
    DecorIntensity.subtle => 2.0,
    DecorIntensity.balanced => 1.0,
    DecorIntensity.rich => 0.5,
  };
  final letterCount = styled.where((g) => !isBlankGrapheme(g)).length;
  final weights = <LetterDecoration, double>{};
  theme.letterDecor.forEach((mode, weight) {
    if (_isMarkMode(mode)) {
      if (!c.request.useMarks || _markPool(theme, mode).isEmpty) {
        return;
      }
    }
    if ((mode == LetterDecoration.between || mode == LetterDecoration.spaced) &&
        (letterCount < 2 || letterCount > 12)) {
      return;
    }
    weights[mode] =
        mode == LetterDecoration.none ? weight * noneScale : weight;
  });
  if (weights.isEmpty) {
    return plain;
  }

  final mode = _weighted(weights, rng);
  switch (mode) {
    case LetterDecoration.none:
      return plain;
    case LetterDecoration.above:
    case LetterDecoration.below:
    case LetterDecoration.overlay:
      return _applyLetterMarks(theme, c, styled, mode) ?? plain;
    case LetterDecoration.between:
      return _applySeparators(theme, c, styled) ?? plain;
    case LetterDecoration.spaced:
      return _applySpacing(theme, c, styled);
  }
}

_Core? _applyLetterMarks(
  DesignTheme theme,
  _Context c,
  List<String> styled,
  LetterDecoration mode,
) {
  final rng = c.rng;
  final pool = _markPool(theme, mode);
  final eligible = [
    for (var i = 0; i < styled.length; i++)
      if (!isBlankGrapheme(styled[i]) && _acceptsMarks(styled[i])) i,
  ];
  if (pool.isEmpty || eligible.isEmpty) {
    return null;
  }

  // Which letters receive marks. Stroke-like overlays are only used on some
  // letters so the name stays readable.
  var coverage = _weighted(
    mode == LetterDecoration.overlay
        ? const {'alternate': 3.0, 'ends': 2.0}
        : const {'all': 6.5, 'alternate': 2.5, 'ends': 1.0},
    rng,
  );
  if (coverage == 'all' && eligible.length > 10) {
    coverage = 'alternate';
  }
  var selected = <int>{};
  if (coverage == 'all') {
    selected = {...eligible};
  } else if (coverage == 'alternate') {
    for (var k = 0; k < eligible.length; k += 2) {
      selected.add(eligible[k]);
    }
  } else {
    selected = {eligible.first, eligible.last};
  }

  // Marks per letter, capped by the theme and by an overall mark budget.
  final perLetterMax = max(1, theme.maxMarksPerLetter);
  var perLetter = 1;
  if (perLetterMax > 1 && rng.nextDouble() < 0.5) {
    perLetter = 1 + rng.nextInt(perLetterMax);
  }
  while (selected.length * perLetter > _maxMarksPerDesign && perLetter > 1) {
    perLetter--;
  }
  if (selected.length * perLetter > _maxMarksPerDesign) {
    selected = {
      for (var k = 0; k < eligible.length; k += 2) eligible[k],
    };
  }

  // The opposite side (above <-> below) gives a second mark a place to go
  // without piling both marks on the same side.
  final opposite = switch (mode) {
    LetterDecoration.above => _markPool(theme, LetterDecoration.below),
    LetterDecoration.below => _markPool(theme, LetterDecoration.above),
    _ => const <int>[],
  };

  List<int> pickMarks() {
    final marks = <int>[_pick(pool, rng)];
    while (marks.length < perLetter) {
      final source = opposite.isNotEmpty && marks.length == 1 ? opposite : pool;
      final choices = [
        for (final cp in source)
          if (!marks.contains(cp)) cp,
      ];
      if (choices.isEmpty) {
        break;
      }
      marks.add(_pick(choices, rng));
    }
    return marks;
  }

  final patternRoll = rng.nextDouble();
  final pattern = pool.length >= 2 && patternRoll < 0.2
      ? 'cycle'
      : patternRoll < 0.3
          ? 'random'
          : 'uniform';
  final fixedA = pickMarks();
  final fixedB = pickMarks();

  final out = StringBuffer();
  final used = <int>{};
  var sample = const <int>[];
  var seen = 0;
  for (var i = 0; i < styled.length; i++) {
    out.write(styled[i]);
    if (!selected.contains(i)) {
      continue;
    }
    final marks = switch (pattern) {
      'cycle' => seen.isEven ? fixedA : fixedB,
      'random' => pickMarks(),
      _ => fixedA,
    };
    seen++;
    for (final cp in marks) {
      out.writeCharCode(cp);
      used.add(cp);
    }
    if (marks.length > sample.length) {
      sample = marks;
    }
  }
  return _Core(out.toString(), 0, List<int>.of(sample), used);
}

_Core? _applySeparators(DesignTheme theme, _Context c, List<String> styled) {
  final rng = c.rng;
  if (theme.separators.isEmpty) {
    return null;
  }
  final first = _pick(theme.separators, rng);
  final alternate = theme.separators.length >= 2 && rng.nextDouble() < 0.25
      ? _pick(theme.separators, rng)
      : first;
  final spaced = rng.nextDouble() < 0.3;

  final out = StringBuffer();
  var inserted = 0;
  var previousLetter = false;
  for (final grapheme in styled) {
    final blank = isBlankGrapheme(grapheme);
    if (!blank && previousLetter) {
      final sep = inserted.isEven ? first : alternate;
      out.write(spaced ? ' $sep ' : sep);
      inserted++;
    }
    out.write(grapheme);
    previousLetter = !blank;
  }
  return _Core(out.toString(), inserted, const [], const {});
}

_Core _applySpacing(DesignTheme theme, _Context c, List<String> styled) {
  final words = <List<String>>[[]];
  for (final grapheme in styled) {
    if (isBlankGrapheme(grapheme)) {
      if (words.last.isNotEmpty) {
        words.add([]);
      }
    } else {
      words.last.add(grapheme);
    }
  }
  words.removeWhere((word) => word.isEmpty);

  // Letters are separated by single spaces. Between words a separator glyph
  // keeps the word boundary visible (a wider gap of plain spaces would be
  // flagged as a double space).
  final hasSeparator = theme.separators.isNotEmpty;
  final wordGap =
      hasSeparator ? ' ${_pick(theme.separators, c.rng)} ' : ' ';
  final text = words.map((word) => word.join(' ')).join(wordGap);
  final decor = hasSeparator && words.length > 1 ? words.length - 1 : 0;
  return _Core(text, decor, const [], const {});
}

({String text, int glyphs}) _lineRun(
  DesignTheme theme,
  _Context c,
  String inner,
  Set<int> lineMarks,
) {
  final rng = c.rng;
  final glyph = _pick(theme.lines, rng);
  // Short names get longer lines; long names get short ones.
  final innerWidth = splitGraphemes(inner).length;
  final longest = max(2, 6 - innerWidth ~/ 4);
  final glyphs = 2 + rng.nextInt(max(1, longest - 1));
  var run = glyph * glyphs;
  if (c.request.useMarks &&
      theme.lineMarks.isNotEmpty &&
      rng.nextDouble() < theme.lineMarkChance) {
    final mark = _pick(theme.lineMarks, rng);
    run = applyCombiningMarks(run, [mark]);
    lineMarks.add(mark);
  }
  return (text: run, glyphs: glyphs);
}

WrapPair _pickEmoji(DesignTheme theme, _Context c) {
  final rng = c.rng;
  final custom = [
    for (final emoji in c.request.customEmojis)
      if (emoji.trim().isNotEmpty) emoji.trim(),
  ];
  if (custom.isNotEmpty) {
    final left = _pick(custom, rng);
    final right = custom.length > 1 && rng.nextBool() ? _pick(custom, rng) : left;
    return WrapPair(left, right);
  }
  if (theme.emojiGroups.isNotEmpty && rng.nextDouble() < 0.3) {
    final group = EmojiCatalog.byId(_pick(theme.emojiGroups, rng));
    if (group != null && group.emojis.isNotEmpty) {
      return WrapPair.mirror(_pick(group.emojis, rng));
    }
  }
  if (theme.emojiPairs.isNotEmpty) {
    return _pick(theme.emojiPairs, rng);
  }
  return const WrapPair('', '');
}

const List<(int, int, String)> _borrowedScripts = [
  (0x0980, 0x09FF, 'Bengali'),
  (0x0B00, 0x0B7F, 'Oriya'),
  (0x0E80, 0x0EFF, 'Lao'),
  (0x10A0, 0x10FF, 'Georgian'),
  (0x0F00, 0x0FFF, 'Tibetan'),
  (0x13000, 0x1342F, 'Egyptian hieroglyphs'),
];

List<CompatibilityWarning> _warningsFor({
  required String name,
  required String text,
  required List<int> letterMarks,
  required List<int> lineMarks,
}) {
  final warnings = <CompatibilityWarning>[];
  final seen = <String>{};
  void add(Iterable<CompatibilityWarning> items) {
    for (final item in items) {
      if (seen.add(item.message)) {
        warnings.add(item);
      }
    }
  }

  add(analyzeMarkCompatibility(text: name, marks: letterMarks));
  add(analyzeMarkCompatibility(text: name, marks: lineMarks));

  final nameRunes = name.runes.toSet();
  final borrowed = <String>[];
  for (final rune in text.runes.toSet()) {
    if (nameRunes.contains(rune)) {
      continue;
    }
    for (final (start, end, label) in _borrowedScripts) {
      if (rune >= start && rune <= end && !borrowed.contains(label)) {
        borrowed.add(label);
      }
    }
  }
  if (borrowed.isNotEmpty) {
    warnings.add(
      CompatibilityWarning(
        WarningLevel.info,
        'Uses ornaments borrowed from other scripts (${borrowed.join(', ')}). '
        'Phones or apps without a matching font may show empty boxes.',
      ),
    );
  }
  return warnings;
}
