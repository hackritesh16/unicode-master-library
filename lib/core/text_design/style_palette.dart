import '../../unicode/code_point.dart';

/// A curated, searchable entry for the Style Palette.
///
/// [value] is the exact text copied to the clipboard. Combining marks use a
/// dotted-circle preview so they remain visible without changing copy output.
class StylePaletteEntry {
  const StylePaletteEntry({
    required this.name,
    required this.category,
    required this.codePoint,
    required this.value,
    this.isCombiningMark = false,
  });

  final String name;
  final String category;
  final int codePoint;
  final String value;
  final bool isCombiningMark;

  String get code => formatCodePoint(codePoint);
  String get preview => isCombiningMark ? '\u25CC$value' : value;
}

abstract final class StylePalette {
  static const entries = <StylePaletteEntry>[
    StylePaletteEntry(name: 'Combining Grave Accent', category: 'Above marks', codePoint: 0x0300, value: '\u0300', isCombiningMark: true),
    StylePaletteEntry(name: 'Combining Acute Accent', category: 'Above marks', codePoint: 0x0301, value: '\u0301', isCombiningMark: true),
    StylePaletteEntry(name: 'Combining Circumflex Accent', category: 'Above marks', codePoint: 0x0302, value: '\u0302', isCombiningMark: true),
    StylePaletteEntry(name: 'Combining Tilde', category: 'Above marks', codePoint: 0x0303, value: '\u0303', isCombiningMark: true),
    StylePaletteEntry(name: 'Combining Macron', category: 'Above marks', codePoint: 0x0304, value: '\u0304', isCombiningMark: true),
    StylePaletteEntry(name: 'Combining Overline', category: 'Above marks', codePoint: 0x0305, value: '\u0305', isCombiningMark: true),
    StylePaletteEntry(name: 'Combining Dot Above', category: 'Above marks', codePoint: 0x0307, value: '\u0307', isCombiningMark: true),
    StylePaletteEntry(name: 'Combining Diaeresis', category: 'Above marks', codePoint: 0x0308, value: '\u0308', isCombiningMark: true),
    StylePaletteEntry(name: 'Combining Ring Above', category: 'Above marks', codePoint: 0x030A, value: '\u030A', isCombiningMark: true),
    StylePaletteEntry(name: 'Combining Double Acute Accent', category: 'Above marks', codePoint: 0x030B, value: '\u030B', isCombiningMark: true),
    StylePaletteEntry(name: 'Combining Caron', category: 'Above marks', codePoint: 0x030C, value: '\u030C', isCombiningMark: true),
    StylePaletteEntry(name: 'Combining Dot Below', category: 'Below marks', codePoint: 0x0323, value: '\u0323', isCombiningMark: true),
    StylePaletteEntry(name: 'Combining Diaeresis Below', category: 'Below marks', codePoint: 0x0324, value: '\u0324', isCombiningMark: true),
    StylePaletteEntry(name: 'Combining Ring Below', category: 'Below marks', codePoint: 0x0325, value: '\u0325', isCombiningMark: true),
    StylePaletteEntry(name: 'Combining Cedilla', category: 'Below marks', codePoint: 0x0327, value: '\u0327', isCombiningMark: true),
    StylePaletteEntry(name: 'Combining Ogonek', category: 'Below marks', codePoint: 0x0328, value: '\u0328', isCombiningMark: true),
    StylePaletteEntry(name: 'Combining Low Line', category: 'Below marks', codePoint: 0x0332, value: '\u0332', isCombiningMark: true),
    StylePaletteEntry(name: 'Combining Double Low Line', category: 'Below marks', codePoint: 0x0333, value: '\u0333', isCombiningMark: true),
    StylePaletteEntry(name: 'Combining Short Stroke Overlay', category: 'Overlay marks', codePoint: 0x0335, value: '\u0335', isCombiningMark: true),
    StylePaletteEntry(name: 'Combining Long Stroke Overlay', category: 'Overlay marks', codePoint: 0x0336, value: '\u0336', isCombiningMark: true),
    StylePaletteEntry(name: 'Combining Short Solidus Overlay', category: 'Overlay marks', codePoint: 0x0337, value: '\u0337', isCombiningMark: true),
    StylePaletteEntry(name: 'Combining Long Solidus Overlay', category: 'Overlay marks', codePoint: 0x0338, value: '\u0338', isCombiningMark: true),
    StylePaletteEntry(name: 'Combining Enclosing Circle', category: 'Enclosing marks', codePoint: 0x20DD, value: '\u20DD', isCombiningMark: true),
    StylePaletteEntry(name: 'Combining Enclosing Square', category: 'Enclosing marks', codePoint: 0x20DE, value: '\u20DE', isCombiningMark: true),
    StylePaletteEntry(name: 'Combining Enclosing Diamond', category: 'Enclosing marks', codePoint: 0x20DF, value: '\u20DF', isCombiningMark: true),
    StylePaletteEntry(name: 'Combining Enclosing Circle Backslash', category: 'Enclosing marks', codePoint: 0x20E0, value: '\u20E0', isCombiningMark: true),
    StylePaletteEntry(name: 'Black Star', category: 'Stars', codePoint: 0x2605, value: '★'),
    StylePaletteEntry(name: 'White Star', category: 'Stars', codePoint: 0x2606, value: '☆'),
    StylePaletteEntry(name: 'Sparkles', category: 'Stars', codePoint: 0x2728, value: '✨'),
    StylePaletteEntry(name: 'Black Heart Suit', category: 'Hearts', codePoint: 0x2665, value: '♥'),
    StylePaletteEntry(name: 'White Heart Suit', category: 'Hearts', codePoint: 0x2661, value: '♡'),
    StylePaletteEntry(name: 'Heavy Black Heart', category: 'Hearts', codePoint: 0x2764, value: '❤'),
    StylePaletteEntry(name: 'Rightwards Arrow', category: 'Arrows', codePoint: 0x2192, value: '→'),
    StylePaletteEntry(name: 'Rightwards Double Arrow', category: 'Arrows', codePoint: 0x21D2, value: '⇒'),
    StylePaletteEntry(name: 'North East Arrow', category: 'Arrows', codePoint: 0x2197, value: '↗'),
    StylePaletteEntry(name: 'South East Arrow', category: 'Arrows', codePoint: 0x2198, value: '↘'),
    StylePaletteEntry(name: 'Black Diamond', category: 'Shapes', codePoint: 0x25C6, value: '◆'),
    StylePaletteEntry(name: 'White Diamond', category: 'Shapes', codePoint: 0x25C7, value: '◇'),
    StylePaletteEntry(name: 'Black Circle', category: 'Shapes', codePoint: 0x25CF, value: '●'),
    StylePaletteEntry(name: 'White Circle', category: 'Shapes', codePoint: 0x25CB, value: '○'),
    StylePaletteEntry(name: 'Black Square', category: 'Shapes', codePoint: 0x25A0, value: '■'),
    StylePaletteEntry(name: 'White Square', category: 'Shapes', codePoint: 0x25A1, value: '□'),
    StylePaletteEntry(name: 'Music Note', category: 'Music', codePoint: 0x266A, value: '♪'),
    StylePaletteEntry(name: 'Beamed Eighth Notes', category: 'Music', codePoint: 0x266B, value: '♫'),
  ];

  static List<String> get categories => [
        'All',
        ...entries.map((entry) => entry.category).toSet(),
      ];

  /// Searches by official Unicode name, visible glyph or code point.
  static List<StylePaletteEntry> search(
    String query, {
    String category = 'All',
  }) {
    final q = query.trim().toLowerCase();
    return entries.where((entry) {
      if (category != 'All' && entry.category != category) return false;
      if (q.isEmpty) return true;
      return entry.name.toLowerCase().contains(q) ||
          entry.value.contains(query.trim()) ||
          entry.code.toLowerCase().contains(q) ||
          entry.codePoint.toRadixString(16).toLowerCase() == q.replaceFirst('u+', '');
    }).toList(growable: false);
  }
}
