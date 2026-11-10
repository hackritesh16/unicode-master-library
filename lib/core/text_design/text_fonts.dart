import '../unicode/normalization.dart';

/// Maps one code point to its styled equivalent, or null when this style has
/// no matching character (the original code point is then kept unchanged).
typedef RuneMapper = int? Function(int rune);

/// A "font" here is a Unicode alphabet (for example Mathematical Bold), not an
/// installed typeface. Characters a style cannot represent are left exactly as
/// typed; they are never swapped for look-alike or unrelated characters.
class TextFont {
  TextFont(this.id, this.label, this._mapper, {this.note});

  final String id;
  final String label;

  /// Honest remark about gaps in this alphabet, shown in the UI.
  final String? note;
  final RuneMapper _mapper;

  /// Styles [text]. Precomposed Latin letters (for example "é") are split into
  /// base + combining mark so the base letter can be styled.
  String apply(String text) {
    final out = StringBuffer();
    for (final rune in text.runes) {
      final mapped = _mapper(rune);
      if (mapped != null) {
        out.writeCharCode(mapped);
        continue;
      }
      if (rune >= 0xC0 && rune <= 0x24F) {
        final decomposed = normalizeText(
          String.fromCharCode(rune),
          NormalizationForm.nfd,
        ).runes.toList();
        final mappedBase = decomposed.length > 1 ? _mapper(decomposed.first) : null;
        if (mappedBase != null) {
          out.writeCharCode(mappedBase);
          for (final mark in decomposed.skip(1)) {
            out.writeCharCode(mark);
          }
          continue;
        }
      }
      out.writeCharCode(rune);
    }
    return out.toString();
  }

  /// Share (0..1) of the ASCII letters and digits in [text] this style can
  /// represent. Returns 1 when [text] has none.
  double coverage(String text) {
    var total = 0;
    var covered = 0;
    for (final rune in text.runes) {
      if (_isAsciiAlnum(rune)) {
        total++;
        if (_mapper(rune) != null) {
          covered++;
        }
      }
    }
    return total == 0 ? 1 : covered / total;
  }
}

bool _isAsciiAlnum(int r) =>
    (r >= 0x30 && r <= 0x39) ||
    (r >= 0x41 && r <= 0x5A) ||
    (r >= 0x61 && r <= 0x7A);

/// True when [text] has letters outside Basic Latin / Latin-1 / Latin
/// Extended (for example Devanagari). Those are kept as typed by every style.
bool hasNonLatinLetters(String text) {
  for (final rune in text.runes) {
    if (rune < 0x250) {
      continue;
    }
    final isMark = (rune >= 0x0300 && rune <= 0x036F) ||
        (rune >= 0x20D0 && rune <= 0x20FF);
    final isSpaceOrPunct = (rune >= 0x2000 && rune <= 0x206F) || rune == 0x3000;
    if (!isMark && !isSpaceOrPunct) {
      return true;
    }
  }
  return false;
}

RuneMapper _alphabet({
  int? upper,
  int? lower,
  Map<int, int> holes = const {},
  Map<int, int> digits = const {},
  bool caseless = false,
}) {
  final u = upper;
  final l = lower;
  return (int r) {
    if (r >= 0x41 && r <= 0x5A) {
      final hole = holes[r];
      if (hole != null) {
        return hole;
      }
      return u == null ? null : u + (r - 0x41);
    }
    if (r >= 0x61 && r <= 0x7A) {
      final hole = holes[r];
      if (hole != null) {
        return hole;
      }
      if (caseless) {
        return u == null ? null : u + (r - 0x61);
      }
      return l == null ? null : l + (r - 0x61);
    }
    if (r >= 0x30 && r <= 0x39) {
      return digits[r - 0x30];
    }
    return null;
  };
}

Map<int, int> _digitRun(int zeroCodePoint) =>
    {for (var d = 0; d <= 9; d++) d: zeroCodePoint + d};

Map<int, int> _digitsOneToNine(int oneCodePoint) =>
    {for (var d = 1; d <= 9; d++) d: oneCodePoint + d - 1};

// Letterlike Symbols stand in for reserved slots in the Mathematical
// Alphanumeric Symbols block (for example there is no MATHEMATICAL SCRIPT
// CAPITAL B at U+1D49D; the real character is U+212C).
const Map<int, int> _scriptHoles = {
  0x42: 0x212C, // B
  0x45: 0x2130, // E
  0x46: 0x2131, // F
  0x48: 0x210B, // H
  0x49: 0x2110, // I
  0x4C: 0x2112, // L
  0x4D: 0x2133, // M
  0x52: 0x211B, // R
  0x65: 0x212F, // e
  0x67: 0x210A, // g
  0x6F: 0x2134, // o
};
const Map<int, int> _frakturHoles = {
  0x43: 0x212D, // C
  0x48: 0x210C, // H
  0x49: 0x2111, // I
  0x52: 0x211C, // R
  0x5A: 0x2128, // Z
};
const Map<int, int> _doubleStruckHoles = {
  0x43: 0x2102, // C
  0x48: 0x210D, // H
  0x4E: 0x2115, // N
  0x50: 0x2119, // P
  0x51: 0x211A, // Q
  0x52: 0x211D, // R
  0x5A: 0x2124, // Z
};
const Map<int, int> _italicHoles = {
  0x68: 0x210E, // h (PLANCK CONSTANT)
};

const Map<int, int> _smallCaps = {
  0x61: 0x1D00,
  0x62: 0x0299,
  0x63: 0x1D04,
  0x64: 0x1D05,
  0x65: 0x1D07,
  0x66: 0xA730,
  0x67: 0x0262,
  0x68: 0x029C,
  0x69: 0x026A,
  0x6A: 0x1D0A,
  0x6B: 0x1D0B,
  0x6C: 0x029F,
  0x6D: 0x1D0D,
  0x6E: 0x0274,
  0x6F: 0x1D0F,
  0x70: 0x1D18,
  0x71: 0xA7AF,
  0x72: 0x0280,
  0x73: 0xA731,
  0x74: 0x1D1B,
  0x75: 0x1D1C,
  0x76: 0x1D20,
  0x77: 0x1D21,
  // No small capital x exists in Unicode.
  0x79: 0x028F,
  0x7A: 0x1D22,
};

const Map<int, int> _superscriptLetters = {
  0x61: 0x1D43,
  0x62: 0x1D47,
  0x63: 0x1D9C,
  0x64: 0x1D48,
  0x65: 0x1D49,
  0x66: 0x1DA0,
  0x67: 0x1D4D,
  0x68: 0x02B0,
  0x69: 0x2071,
  0x6A: 0x02B2,
  0x6B: 0x1D4F,
  0x6C: 0x02E1,
  0x6D: 0x1D50,
  0x6E: 0x207F,
  0x6F: 0x1D52,
  0x70: 0x1D56,
  // No modifier letter small q in older Unicode versions; left unchanged.
  0x72: 0x02B3,
  0x73: 0x02E2,
  0x74: 0x1D57,
  0x75: 0x1D58,
  0x76: 0x1D5B,
  0x77: 0x02B7,
  0x78: 0x02E3,
  0x79: 0x02B8,
  0x7A: 0x1DBB,
};

const Map<int, int> _superscriptDigits = {
  0: 0x2070,
  1: 0x00B9,
  2: 0x00B2,
  3: 0x00B3,
  4: 0x2074,
  5: 0x2075,
  6: 0x2076,
  7: 0x2077,
  8: 0x2078,
  9: 0x2079,
};

const Map<int, int> _subscriptLetters = {
  0x61: 0x2090,
  0x65: 0x2091,
  0x68: 0x2095,
  0x69: 0x1D62,
  0x6A: 0x2C7C,
  0x6B: 0x2096,
  0x6C: 0x2097,
  0x6D: 0x2098,
  0x6E: 0x2099,
  0x6F: 0x2092,
  0x70: 0x209A,
  0x72: 0x1D63,
  0x73: 0x209B,
  0x74: 0x209C,
  0x75: 0x1D64,
  0x76: 0x1D65,
  0x78: 0x2093,
};

/// Folds an upper-case ASCII letter to lower case, leaves others unchanged.
int _foldLower(int r) => (r >= 0x41 && r <= 0x5A) ? r + 0x20 : r;

RuneMapper _foldedLookup(Map<int, int> letters, Map<int, int> digits) {
  return (int r) {
    final folded = _foldLower(r);
    if (folded >= 0x61 && folded <= 0x7A) {
      return letters[folded];
    }
    if (r >= 0x30 && r <= 0x39) {
      return digits[r - 0x30];
    }
    return null;
  };
}

/// Catalogue of Unicode alphabets used by the Name Studio and Composer.
abstract final class TextFonts {
  static final TextFont plain = TextFont('plain', 'Plain', (r) => null);

  static final TextFont bold = TextFont(
    'bold',
    'Bold',
    _alphabet(
      upper: 0x1D400,
      lower: 0x1D41A,
      digits: _digitRun(0x1D7CE),
    ),
  );
  static final TextFont italic = TextFont(
    'italic',
    'Italic',
    _alphabet(upper: 0x1D434, lower: 0x1D44E, holes: _italicHoles),
    note: 'Digits stay plain (no italic digits exist in Unicode).',
  );
  static final TextFont boldItalic = TextFont(
    'bold_italic',
    'Bold Italic',
    _alphabet(upper: 0x1D468, lower: 0x1D482),
    note: 'Digits stay plain (no bold italic digits exist in Unicode).',
  );
  static final TextFont script = TextFont(
    'script',
    'Script',
    _alphabet(upper: 0x1D49C, lower: 0x1D4B6, holes: _scriptHoles),
    note: 'Digits stay plain.',
  );
  static final TextFont boldScript = TextFont(
    'bold_script',
    'Bold Script',
    _alphabet(upper: 0x1D4D0, lower: 0x1D4EA),
    note: 'Digits stay plain.',
  );
  static final TextFont fraktur = TextFont(
    'fraktur',
    'Fraktur',
    _alphabet(upper: 0x1D504, lower: 0x1D51E, holes: _frakturHoles),
    note: 'Digits stay plain.',
  );
  static final TextFont boldFraktur = TextFont(
    'bold_fraktur',
    'Bold Fraktur',
    _alphabet(upper: 0x1D56C, lower: 0x1D586),
    note: 'Digits stay plain.',
  );
  static final TextFont doubleStruck = TextFont(
    'double_struck',
    'Double Struck',
    _alphabet(
      upper: 0x1D538,
      lower: 0x1D552,
      holes: _doubleStruckHoles,
      digits: _digitRun(0x1D7D8),
    ),
  );
  static final TextFont sans = TextFont(
    'sans',
    'Sans Serif',
    _alphabet(
      upper: 0x1D5A0,
      lower: 0x1D5BA,
      digits: _digitRun(0x1D7E2),
    ),
  );
  static final TextFont sansBold = TextFont(
    'sans_bold',
    'Sans Serif Bold',
    _alphabet(
      upper: 0x1D5D4,
      lower: 0x1D5EE,
      digits: _digitRun(0x1D7EC),
    ),
  );
  static final TextFont sansItalic = TextFont(
    'sans_italic',
    'Sans Serif Italic',
    _alphabet(upper: 0x1D608, lower: 0x1D622),
    note: 'Digits stay plain.',
  );
  static final TextFont sansBoldItalic = TextFont(
    'sans_bold_italic',
    'Sans Bold Italic',
    _alphabet(upper: 0x1D63C, lower: 0x1D656),
    note: 'Digits stay plain.',
  );
  static final TextFont monospace = TextFont(
    'monospace',
    'Monospace',
    _alphabet(
      upper: 0x1D670,
      lower: 0x1D68A,
      digits: _digitRun(0x1D7F6),
    ),
  );
  static final TextFont fullwidth = TextFont(
    'fullwidth',
    'Fullwidth',
    _alphabet(upper: 0xFF21, lower: 0xFF41, digits: _digitRun(0xFF10)),
  );
  static final TextFont circled = TextFont(
    'circled',
    'Circled',
    _alphabet(
      upper: 0x24B6,
      lower: 0x24D0,
      digits: {0: 0x24EA, ..._digitsOneToNine(0x2460)},
    ),
  );
  static final TextFont negativeCircled = TextFont(
    'negative_circled',
    'Black Circled',
    _alphabet(
      upper: 0x1F150,
      caseless: true,
      digits: {0: 0x24FF, ..._digitsOneToNine(0x2776)},
    ),
    note: 'Capital letters only; lower case is shown as capitals.',
  );
  static final TextFont squared = TextFont(
    'squared',
    'Squared',
    _alphabet(upper: 0x1F130, caseless: true),
    note: 'Capital letters only; digits stay plain.',
  );
  static final TextFont negativeSquared = TextFont(
    'negative_squared',
    'Black Squared',
    _alphabet(upper: 0x1F170, caseless: true),
    note: 'Capital letters only; digits stay plain.',
  );
  static final TextFont parenthesized = TextFont(
    'parenthesized',
    'Parenthesized',
    _alphabet(
      upper: 0x1F110,
      lower: 0x249C,
      digits: _digitsOneToNine(0x2474),
    ),
    note: 'There is no parenthesized zero.',
  );
  static final TextFont smallCaps = TextFont(
    'small_caps',
    'Small Caps',
    _foldedLookup(_smallCaps, const {}),
    note: 'No small capital X exists; X stays plain.',
  );
  static final TextFont superscript = TextFont(
    'superscript',
    'Superscript',
    _foldedLookup(_superscriptLetters, _superscriptDigits),
    note: 'No superscript Q; shown in lower case.',
  );
  static final TextFont subscript = TextFont(
    'subscript',
    'Subscript',
    _foldedLookup(_subscriptLetters, {
      for (var d = 0; d <= 9; d++) d: 0x2080 + d,
    }),
    note: 'Unicode only has some subscript letters; others stay plain.',
  );

  static final List<TextFont> all = [
    plain,
    bold,
    italic,
    boldItalic,
    script,
    boldScript,
    fraktur,
    boldFraktur,
    doubleStruck,
    sans,
    sansBold,
    sansItalic,
    sansBoldItalic,
    monospace,
    fullwidth,
    circled,
    negativeCircled,
    squared,
    negativeSquared,
    parenthesized,
    smallCaps,
    superscript,
    subscript,
  ];

  static TextFont? byId(String id) {
    for (final font in all) {
      if (font.id == id) {
        return font;
      }
    }
    return null;
  }
}
