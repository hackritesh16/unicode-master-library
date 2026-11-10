import '../unicode/code_point.dart';
import 'graphemes.dart';
import 'text_fonts.dart';

enum MarkPosition { above, below, overlay, enclosing, doubleSpan }

/// How likely a mark is to render badly across fonts and apps. Advisory only.
enum RenderRisk { low, medium, high }

/// A curated combining mark. [name] is the official Unicode name without the
/// leading `COMBINING `. Each entry is checked against the official UCD by the
/// test suite (name, general category and combining class).
class CombiningMark {
  const CombiningMark(
    this.cp,
    this.name,
    this.position, [
    this.risk = RenderRisk.low,
  ]);

  final int cp;
  final String name;
  final MarkPosition position;
  final RenderRisk risk;

  String get char => String.fromCharCode(cp);
  String get officialName => 'COMBINING $name';
  String get label => formatCodePoint(cp);
}

abstract final class CombiningMarks {
  static const List<CombiningMark> all = [
    // Above
    CombiningMark(0x0300, 'GRAVE ACCENT', MarkPosition.above),
    CombiningMark(0x0301, 'ACUTE ACCENT', MarkPosition.above),
    CombiningMark(0x0302, 'CIRCUMFLEX ACCENT', MarkPosition.above),
    CombiningMark(0x0303, 'TILDE', MarkPosition.above),
    CombiningMark(0x0304, 'MACRON', MarkPosition.above),
    CombiningMark(0x0305, 'OVERLINE', MarkPosition.above),
    CombiningMark(0x0306, 'BREVE', MarkPosition.above),
    CombiningMark(0x0307, 'DOT ABOVE', MarkPosition.above),
    CombiningMark(0x0308, 'DIAERESIS', MarkPosition.above),
    CombiningMark(0x0309, 'HOOK ABOVE', MarkPosition.above),
    CombiningMark(0x030A, 'RING ABOVE', MarkPosition.above),
    CombiningMark(0x030B, 'DOUBLE ACUTE ACCENT', MarkPosition.above),
    CombiningMark(0x030C, 'CARON', MarkPosition.above),
    CombiningMark(0x030D, 'VERTICAL LINE ABOVE', MarkPosition.above),
    CombiningMark(0x030E, 'DOUBLE VERTICAL LINE ABOVE', MarkPosition.above),
    CombiningMark(0x030F, 'DOUBLE GRAVE ACCENT', MarkPosition.above),
    CombiningMark(0x0310, 'CANDRABINDU', MarkPosition.above),
    CombiningMark(0x0311, 'INVERTED BREVE', MarkPosition.above),
    CombiningMark(0x0312, 'TURNED COMMA ABOVE', MarkPosition.above),
    CombiningMark(0x0313, 'COMMA ABOVE', MarkPosition.above),
    CombiningMark(0x0314, 'REVERSED COMMA ABOVE', MarkPosition.above),
    CombiningMark(0x033D, 'X ABOVE', MarkPosition.above),
    CombiningMark(0x033E, 'VERTICAL TILDE', MarkPosition.above),
    CombiningMark(0x033F, 'DOUBLE OVERLINE', MarkPosition.above),
    CombiningMark(0x0346, 'BRIDGE ABOVE', MarkPosition.above, RenderRisk.medium),
    CombiningMark(0x034A, 'NOT TILDE ABOVE', MarkPosition.above, RenderRisk.medium),
    CombiningMark(0x034B, 'HOMOTHETIC ABOVE', MarkPosition.above, RenderRisk.medium),
    CombiningMark(0x034C, 'ALMOST EQUAL TO ABOVE', MarkPosition.above, RenderRisk.medium),
    CombiningMark(0x0350, 'RIGHT ARROWHEAD ABOVE', MarkPosition.above, RenderRisk.medium),
    CombiningMark(0x0351, 'LEFT HALF RING ABOVE', MarkPosition.above, RenderRisk.medium),
    CombiningMark(0x0352, 'FERMATA', MarkPosition.above, RenderRisk.medium),
    CombiningMark(0x0357, 'RIGHT HALF RING ABOVE', MarkPosition.above, RenderRisk.medium),
    CombiningMark(0x035B, 'ZIGZAG ABOVE', MarkPosition.above, RenderRisk.medium),
    CombiningMark(0x0363, 'LATIN SMALL LETTER A', MarkPosition.above, RenderRisk.medium),
    CombiningMark(0x0364, 'LATIN SMALL LETTER E', MarkPosition.above, RenderRisk.medium),
    CombiningMark(0x0365, 'LATIN SMALL LETTER I', MarkPosition.above, RenderRisk.medium),
    CombiningMark(0x0366, 'LATIN SMALL LETTER O', MarkPosition.above, RenderRisk.medium),
    CombiningMark(0x0367, 'LATIN SMALL LETTER U', MarkPosition.above, RenderRisk.medium),
    CombiningMark(0x0368, 'LATIN SMALL LETTER C', MarkPosition.above, RenderRisk.medium),
    CombiningMark(0x0369, 'LATIN SMALL LETTER D', MarkPosition.above, RenderRisk.medium),
    CombiningMark(0x036A, 'LATIN SMALL LETTER H', MarkPosition.above, RenderRisk.medium),
    CombiningMark(0x036B, 'LATIN SMALL LETTER M', MarkPosition.above, RenderRisk.medium),
    CombiningMark(0x036C, 'LATIN SMALL LETTER R', MarkPosition.above, RenderRisk.medium),
    CombiningMark(0x036D, 'LATIN SMALL LETTER T', MarkPosition.above, RenderRisk.medium),
    CombiningMark(0x036E, 'LATIN SMALL LETTER V', MarkPosition.above, RenderRisk.medium),
    CombiningMark(0x036F, 'LATIN SMALL LETTER X', MarkPosition.above, RenderRisk.medium),
    CombiningMark(0x20D0, 'LEFT HARPOON ABOVE', MarkPosition.above, RenderRisk.medium),
    CombiningMark(0x20D1, 'RIGHT HARPOON ABOVE', MarkPosition.above, RenderRisk.medium),
    CombiningMark(0x20D4, 'ANTICLOCKWISE ARROW ABOVE', MarkPosition.above, RenderRisk.medium),
    CombiningMark(0x20D5, 'CLOCKWISE ARROW ABOVE', MarkPosition.above, RenderRisk.medium),
    CombiningMark(0x20D6, 'LEFT ARROW ABOVE', MarkPosition.above, RenderRisk.medium),
    CombiningMark(0x20D7, 'RIGHT ARROW ABOVE', MarkPosition.above, RenderRisk.medium),
    CombiningMark(0x20DB, 'THREE DOTS ABOVE', MarkPosition.above, RenderRisk.medium),
    CombiningMark(0x20DC, 'FOUR DOTS ABOVE', MarkPosition.above, RenderRisk.medium),
    CombiningMark(0x20E1, 'LEFT RIGHT ARROW ABOVE', MarkPosition.above, RenderRisk.medium),
    CombiningMark(0x20F0, 'ASTERISK ABOVE', MarkPosition.above, RenderRisk.medium),
    // Below
    CombiningMark(0x0316, 'GRAVE ACCENT BELOW', MarkPosition.below),
    CombiningMark(0x0317, 'ACUTE ACCENT BELOW', MarkPosition.below),
    CombiningMark(0x0318, 'LEFT TACK BELOW', MarkPosition.below),
    CombiningMark(0x0319, 'RIGHT TACK BELOW', MarkPosition.below),
    CombiningMark(0x031C, 'LEFT HALF RING BELOW', MarkPosition.below),
    CombiningMark(0x031D, 'UP TACK BELOW', MarkPosition.below),
    CombiningMark(0x031E, 'DOWN TACK BELOW', MarkPosition.below),
    CombiningMark(0x031F, 'PLUS SIGN BELOW', MarkPosition.below),
    CombiningMark(0x0320, 'MINUS SIGN BELOW', MarkPosition.below),
    CombiningMark(0x0323, 'DOT BELOW', MarkPosition.below),
    CombiningMark(0x0324, 'DIAERESIS BELOW', MarkPosition.below),
    CombiningMark(0x0325, 'RING BELOW', MarkPosition.below),
    CombiningMark(0x0326, 'COMMA BELOW', MarkPosition.below),
    CombiningMark(0x0329, 'VERTICAL LINE BELOW', MarkPosition.below),
    CombiningMark(0x032A, 'BRIDGE BELOW', MarkPosition.below),
    CombiningMark(0x032B, 'INVERTED DOUBLE ARCH BELOW', MarkPosition.below),
    CombiningMark(0x032C, 'CARON BELOW', MarkPosition.below),
    CombiningMark(0x032D, 'CIRCUMFLEX ACCENT BELOW', MarkPosition.below),
    CombiningMark(0x032E, 'BREVE BELOW', MarkPosition.below),
    CombiningMark(0x032F, 'INVERTED BREVE BELOW', MarkPosition.below),
    CombiningMark(0x0330, 'TILDE BELOW', MarkPosition.below),
    CombiningMark(0x0331, 'MACRON BELOW', MarkPosition.below),
    CombiningMark(0x0332, 'LOW LINE', MarkPosition.below),
    CombiningMark(0x0333, 'DOUBLE LOW LINE', MarkPosition.below),
    CombiningMark(0x0339, 'RIGHT HALF RING BELOW', MarkPosition.below),
    CombiningMark(0x033A, 'INVERTED BRIDGE BELOW', MarkPosition.below),
    CombiningMark(0x033B, 'SQUARE BELOW', MarkPosition.below),
    CombiningMark(0x033C, 'SEAGULL BELOW', MarkPosition.below),
    CombiningMark(0x0347, 'EQUALS SIGN BELOW', MarkPosition.below, RenderRisk.medium),
    CombiningMark(0x0348, 'DOUBLE VERTICAL LINE BELOW', MarkPosition.below, RenderRisk.medium),
    CombiningMark(0x0349, 'LEFT ANGLE BELOW', MarkPosition.below, RenderRisk.medium),
    CombiningMark(0x034D, 'LEFT RIGHT ARROW BELOW', MarkPosition.below, RenderRisk.medium),
    CombiningMark(0x034E, 'UPWARDS ARROW BELOW', MarkPosition.below, RenderRisk.medium),
    CombiningMark(0x0353, 'X BELOW', MarkPosition.below, RenderRisk.medium),
    CombiningMark(0x0354, 'LEFT ARROWHEAD BELOW', MarkPosition.below, RenderRisk.medium),
    CombiningMark(0x0355, 'RIGHT ARROWHEAD BELOW', MarkPosition.below, RenderRisk.medium),
    CombiningMark(0x0356, 'RIGHT ARROWHEAD AND UP ARROWHEAD BELOW', MarkPosition.below, RenderRisk.medium),
    CombiningMark(0x0359, 'ASTERISK BELOW', MarkPosition.below, RenderRisk.medium),
    CombiningMark(0x035A, 'DOUBLE RING BELOW', MarkPosition.below, RenderRisk.medium),
    CombiningMark(0x20E8, 'TRIPLE UNDERDOT', MarkPosition.below, RenderRisk.medium),
    // Through the letter (overlay)
    CombiningMark(0x0334, 'TILDE OVERLAY', MarkPosition.overlay),
    CombiningMark(0x0335, 'SHORT STROKE OVERLAY', MarkPosition.overlay),
    CombiningMark(0x0336, 'LONG STROKE OVERLAY', MarkPosition.overlay),
    CombiningMark(0x0337, 'SHORT SOLIDUS OVERLAY', MarkPosition.overlay),
    CombiningMark(0x0338, 'LONG SOLIDUS OVERLAY', MarkPosition.overlay),
    CombiningMark(0x20D2, 'LONG VERTICAL LINE OVERLAY', MarkPosition.overlay, RenderRisk.medium),
    CombiningMark(0x20D3, 'SHORT VERTICAL LINE OVERLAY', MarkPosition.overlay, RenderRisk.medium),
    CombiningMark(0x20D8, 'RING OVERLAY', MarkPosition.overlay, RenderRisk.medium),
    CombiningMark(0x20D9, 'CLOCKWISE RING OVERLAY', MarkPosition.overlay, RenderRisk.medium),
    CombiningMark(0x20DA, 'ANTICLOCKWISE RING OVERLAY', MarkPosition.overlay, RenderRisk.medium),
    CombiningMark(0x20E5, 'REVERSE SOLIDUS OVERLAY', MarkPosition.overlay, RenderRisk.medium),
    // Around the letter (enclosing)
    CombiningMark(0x20DD, 'ENCLOSING CIRCLE', MarkPosition.enclosing, RenderRisk.high),
    CombiningMark(0x20DE, 'ENCLOSING SQUARE', MarkPosition.enclosing, RenderRisk.high),
    CombiningMark(0x20DF, 'ENCLOSING DIAMOND', MarkPosition.enclosing, RenderRisk.high),
    CombiningMark(0x20E0, 'ENCLOSING CIRCLE BACKSLASH', MarkPosition.enclosing, RenderRisk.high),
    CombiningMark(0x20E2, 'ENCLOSING SCREEN', MarkPosition.enclosing, RenderRisk.high),
    CombiningMark(0x20E3, 'ENCLOSING KEYCAP', MarkPosition.enclosing, RenderRisk.high),
    CombiningMark(0x20E4, 'ENCLOSING UPWARD POINTING TRIANGLE', MarkPosition.enclosing, RenderRisk.high),
    // Spanning two letters
    CombiningMark(0x035C, 'DOUBLE BREVE BELOW', MarkPosition.doubleSpan, RenderRisk.high),
    CombiningMark(0x035D, 'DOUBLE BREVE', MarkPosition.doubleSpan, RenderRisk.high),
    CombiningMark(0x035E, 'DOUBLE MACRON', MarkPosition.doubleSpan, RenderRisk.high),
    CombiningMark(0x035F, 'DOUBLE MACRON BELOW', MarkPosition.doubleSpan, RenderRisk.high),
    CombiningMark(0x0360, 'DOUBLE TILDE', MarkPosition.doubleSpan, RenderRisk.high),
    CombiningMark(0x0361, 'DOUBLE INVERTED BREVE', MarkPosition.doubleSpan, RenderRisk.high),
    CombiningMark(0x0362, 'DOUBLE RIGHTWARDS ARROW BELOW', MarkPosition.doubleSpan, RenderRisk.high),
  ];

  static final Map<int, CombiningMark> _byCp = {
    for (final mark in all) mark.cp: mark,
  };

  static CombiningMark? byCp(int cp) => _byCp[cp];

  static List<CombiningMark> withPosition(MarkPosition position) =>
      all.where((mark) => mark.position == position).toList();

  /// Marks from [cps] that sit at [position] (unknown code points are skipped).
  static List<int> filterPosition(Iterable<int> cps, MarkPosition position) {
    return [
      for (final cp in cps)
        if (_byCp[cp]?.position == position) cp,
    ];
  }
}

/// Appends [marks] (code points, in the given order) after each letter of
/// [text]. Whitespace never receives marks. Marks that span two letters are
/// attached to the first letter of each adjacent pair inside a word.
///
/// [onlyIndexes] restricts the marks to selected grapheme indexes (null = all).
String applyCombiningMarks(
  String text,
  List<int> marks, {
  Set<int>? onlyIndexes,
}) {
  if (marks.isEmpty) {
    return text;
  }
  final singleBuffer = StringBuffer();
  final doubleBuffer = StringBuffer();
  for (final cp in marks) {
    if (CombiningMarks.byCp(cp)?.position == MarkPosition.doubleSpan) {
      doubleBuffer.writeCharCode(cp);
    } else {
      singleBuffer.writeCharCode(cp);
    }
  }
  final single = singleBuffer.toString();
  final doubles = doubleBuffer.toString();

  final graphemes = splitGraphemes(text);
  final out = StringBuffer();
  var wordPosition = 0;
  for (var i = 0; i < graphemes.length; i++) {
    final grapheme = graphemes[i];
    out.write(grapheme);
    if (isBlankGrapheme(grapheme)) {
      wordPosition = 0;
      continue;
    }
    final selected = onlyIndexes == null || onlyIndexes.contains(i);
    if (selected) {
      out.write(single);
      final hasPartner = i + 1 < graphemes.length &&
          !isBlankGrapheme(graphemes[i + 1]);
      if (doubles.isNotEmpty && hasPartner && wordPosition.isEven) {
        out.write(doubles);
      }
    }
    wordPosition++;
  }
  return out.toString();
}

/// Removes every combining mark from the curated catalog from [text].
String stripCatalogMarks(String text) {
  final out = StringBuffer();
  for (final rune in text.runes) {
    if (CombiningMarks.byCp(rune) == null) {
      out.writeCharCode(rune);
    }
  }
  return out.toString();
}

enum WarningLevel { info, caution }

class CompatibilityWarning {
  const CompatibilityWarning(this.level, this.message);

  final WarningLevel level;
  final String message;
}

const String renderingDisclaimer =
    'The preview uses this app\'s font. Other apps and fonts may move, '
    'overlap or drop combining marks, so check the result where you plan to '
    'use it.';

/// Advisory compatibility warnings for applying [marks] to [text]. They are
/// heuristics about typical rendering behaviour, not a guarantee either way.
List<CompatibilityWarning> analyzeMarkCompatibility({
  required String text,
  required List<int> marks,
}) {
  final warnings = <CompatibilityWarning>[];
  if (marks.isEmpty) {
    return warnings;
  }

  var above = 0;
  var below = 0;
  var overlay = 0;
  var enclosing = 0;
  var doubleSpan = 0;
  var medium = 0;
  var unknown = 0;
  for (final cp in marks) {
    final mark = CombiningMarks.byCp(cp);
    if (mark == null) {
      unknown++;
      continue;
    }
    switch (mark.position) {
      case MarkPosition.above:
        above++;
      case MarkPosition.below:
        below++;
      case MarkPosition.overlay:
        overlay++;
      case MarkPosition.enclosing:
        enclosing++;
      case MarkPosition.doubleSpan:
        doubleSpan++;
    }
    if (mark.risk == RenderRisk.medium) {
      medium++;
    }
  }

  if (enclosing > 0) {
    warnings.add(const CompatibilityWarning(
      WarningLevel.caution,
      'Enclosing marks (circle, square, keycap...) are often drawn off-centre, '
      'as empty boxes, or dropped entirely.',
    ));
  }
  if (doubleSpan > 0) {
    warnings.add(const CompatibilityWarning(
      WarningLevel.caution,
      'Double marks stretch over two letters. They are attached to the first '
      'letter of each pair and depend heavily on the font.',
    ));
  }
  if (above >= 3) {
    warnings.add(CompatibilityWarning(
      WarningLevel.caution,
      '$above marks above one letter usually pile up and may collide with the '
      'line above.',
    ));
  }
  if (below >= 3) {
    warnings.add(CompatibilityWarning(
      WarningLevel.caution,
      '$below marks below one letter usually pile up and may collide with the '
      'line below.',
    ));
  }
  if (overlay >= 2) {
    warnings.add(const CompatibilityWarning(
      WarningLevel.caution,
      'Several overlay marks drawn through the same letter make it hard to '
      'read.',
    ));
  }
  if (overlay > 0 && above + below > 0) {
    warnings.add(const CompatibilityWarning(
      WarningLevel.info,
      'Overlay marks combined with marks above or below can overlap each '
      'other.',
    ));
  }
  if (marks.length > 4) {
    warnings.add(CompatibilityWarning(
      WarningLevel.caution,
      '${marks.length} marks per letter gives a "zalgo" look that many apps '
      'cut off or render unreadably.',
    ));
  }
  if (medium > 0) {
    warnings.add(const CompatibilityWarning(
      WarningLevel.info,
      'Arrow, symbol and Latin-letter marks only render in fonts that include '
      'them; elsewhere they may show as boxes.',
    ));
  }
  if (unknown > 0) {
    warnings.add(CompatibilityWarning(
      WarningLevel.info,
      '$unknown mark(s) are not in the curated list; their rendering is '
      'unknown.',
    ));
  }
  if (hasNonLatinLetters(text)) {
    warnings.add(const CompatibilityWarning(
      WarningLevel.caution,
      'These marks are designed for Latin letters. On Devanagari and other '
      'scripts they may be misplaced or merge with the script\'s own signs.',
    ));
  }
  return warnings;
}
