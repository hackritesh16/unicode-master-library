import '../unicode/code_point.dart';

/// A palette category of single-code-point symbols for the Composer.
/// Every code point is checked against the official UCD by the test suite
/// (assigned, not a control/private-use/combining character).
class SymbolCategory {
  const SymbolCategory(this.id, this.label, this.glyphs);

  final String id;
  final String label;
  final List<String> glyphs;
}

// Variation selectors are skipped so a glyph typed with or without VS16 gives
// the same single code point.
List<String> _glyphs(String source) => [
      for (final rune in source.runes)
        if (rune != 0x20 && rune != 0x0A && !(rune >= 0xFE00 && rune <= 0xFE0F))
          String.fromCharCode(rune),
    ];

/// Only for blocks that have no unassigned code points in their range.
List<String> _range(int start, int end) => [
      for (var cp = start; cp <= end; cp++) String.fromCharCode(cp),
    ];

abstract final class SymbolCatalog {
  static final List<SymbolCategory> categories = [
    SymbolCategory('stars', 'Stars', _glyphs(
      '★☆✦✧✩✪✫✬✭✮✯✰✶✷✸✹✺✻✼✽✾❂❉❊❋⚝⚹⁂',
    )),
    SymbolCategory('hearts', 'Hearts', _glyphs('♡♥❥❦❧❣ღ❤')),
    SymbolCategory('flowers', 'Flowers', _glyphs('❀❁❂❃❄❅❆❇❈✿⚘⚜☘☙❧')),
    SymbolCategory('lines', 'Lines', _glyphs(
      '─━═┄┅┈┉╌╍⎯⎼⎻⎺‒–—―⁓∼～﹏﹋﹌⸺⸻‾¯‿⁀⏤⏝⏜',
    )),
    SymbolCategory('brackets', 'Brackets', _glyphs(
      '()[]{}⟨⟩⟦⟧⟪⟫⟬⟭⟮⟯❨❩❪❫❬❭❮❯❰❱❲❳❴❵⦃⦄⦅⦆⦇⦈⦉⦊⦋⦌⸢⸣⸤⸥⸦⸧⸨⸩'
      '「」『』【】〈〉《》〔〕〖〗〘〙〚〛‹›«»꒰꒱༺༻꧁꧂',
    )),
    SymbolCategory('kawaii', 'Kawaii', _glyphs(
      '˚₊‧⁺˖°⋆｡･ﾟ✧⊹ʚɞ୨୧ৎ꒰꒱ა໒ᵔᴗᵕ⸜⸝',
    )),
    SymbolCategory('dots', 'Dots & bullets', _glyphs(
      '·•‧∙⋅‣◦◘◙○●◍◎◉⦿⊙⊚⊛⚬∘⁃',
    )),
    SymbolCategory('diamonds', 'Diamonds', _glyphs('◆◇◈◊❖⟐⟡')),
    SymbolCategory('crosses', 'Crosses', _glyphs('†‡✙✚✛✜✠✕✗✘╳☓')),
    SymbolCategory('royal', 'Chess & royal', _range(0x2654, 0x265F)),
    SymbolCategory('music', 'Music', _range(0x2669, 0x266F)),
    SymbolCategory('arrows', 'Arrows', _range(0x2190, 0x21FF)),
    SymbolCategory('dingbat_arrows', 'Dingbat arrows', _range(0x2794, 0x27BF)),
    SymbolCategory('shapes', 'Geometric shapes', _range(0x25A0, 0x25FF)),
    SymbolCategory('box', 'Box drawing', _range(0x2500, 0x257F)),
    SymbolCategory('blocks', 'Block elements', _range(0x2580, 0x259F)),
    SymbolCategory('braille', 'Braille', _range(0x2800, 0x28FF)),
    SymbolCategory('math', 'Math operators', _range(0x2200, 0x22FF)),
    SymbolCategory('enclosed', 'Enclosed', _range(0x2460, 0x24FF)),
    SymbolCategory('misc', 'Misc symbols', _range(0x2600, 0x26FF)),
    SymbolCategory('dingbats', 'Dingbats', _range(0x2701, 0x2793)),
    SymbolCategory('currency', 'Currency', _glyphs(
      r'$¢£¤¥€₠₡₢₣₤₥₦₧₨₩₪₫₭₮₯₰₱₲₳₴₵₶₷₸₹₺₻₼₽₾₿',
    )),
    SymbolCategory('punctuation', 'Punctuation', _glyphs(
      '¡¿«»§¶‰‱†‡•…‼⁇⁈⁉‽⸮※❝❞‘’‚“”„‹›',
    )),
    SymbolCategory('scripts', 'Super & subscripts', _glyphs(
      '⁰¹²³⁴⁵⁶⁷⁸⁹⁺⁻⁼⁽⁾ⁿⁱ₀₁₂₃₄₅₆₇₈₉₊₋₌₍₎ₐₑₒₓₕₖₗₘₙₚₛₜ'
      'ᵃᵇᶜᵈᵉᶠᵍʰʲᵏˡᵐᵒᵖʳˢᵗᵘᵛʷˣʸᶻ',
    )),
  ];

  static SymbolCategory? byId(String id) {
    for (final category in categories) {
      if (category.id == id) {
        return category;
      }
    }
    return null;
  }

  /// Searches the palette by the glyph itself, a code point (`2605`, `U+2605`,
  /// `0x2605`) or the category name. Searching by official Unicode name needs
  /// the installed UCD database (see the Explorer).
  static List<String> search(String query, {int limit = 200}) {
    final q = query.trim();
    if (q.isEmpty) {
      return const [];
    }
    final results = <String>[];
    final seen = <String>{};
    void add(String glyph) {
      if (results.length < limit && seen.add(glyph)) {
        results.add(glyph);
      }
    }

    final cp = tryParseCodePointQuery(q);
    final lower = q.toLowerCase();
    for (final category in categories) {
      final categoryMatch = category.label.toLowerCase().contains(lower);
      for (final glyph in category.glyphs) {
        if (categoryMatch ||
            q.runes.length == 1 && glyph == q ||
            (cp != null && glyph.runes.length == 1 && glyph.runes.first == cp)) {
          add(glyph);
        }
      }
    }
    return results;
  }
}
