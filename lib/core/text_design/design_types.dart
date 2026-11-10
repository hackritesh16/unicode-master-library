import 'combining_marks.dart';
import 'graphemes.dart';

/// How individual letters of a name are decorated.
enum LetterDecoration {
  /// Letters are left alone.
  none,

  /// A combining mark is drawn above each selected letter.
  above,

  /// A combining mark is drawn below each selected letter.
  below,

  /// A separator glyph is placed between letters of a word.
  between,

  /// An overlay mark (stroke, slash, ring) crosses a selected letter.
  overlay,

  /// Letters are separated by plain spaces.
  spaced,
}

/// A left and right piece that surround something. The pieces include their
/// own spacing, for example `WrapPair('꒰ა ', ' ໒꒱')`.
class WrapPair {
  const WrapPair(this.left, this.right);

  /// The same glyph on both sides (a symmetrical cap).
  const WrapPair.mirror(String glyph)
      : left = glyph,
        right = glyph;

  final String left;
  final String right;

  @override
  bool operator ==(Object other) =>
      other is WrapPair && other.left == left && other.right == right;

  @override
  int get hashCode => Object.hash(left, right);
}

/// A visual theme for the Name Studio. A theme is pure data: pools of fonts,
/// wraps, brackets, caps, lines, separators, combining marks and emoji pairs,
/// plus weights and clutter limits. The engine combines them under design
/// rules, so a theme is never a fixed template.
class DesignTheme {
  const DesignTheme({
    required this.id,
    required this.label,
    required this.blurb,
    required this.fontIds,
    required this.wraps,
    required this.brackets,
    required this.caps,
    required this.lines,
    required this.separators,
    required this.letterMarks,
    required this.emojiPairs,
    required this.emojiGroups,
    required this.letterDecor,
    required this.wrapChance,
    required this.bracketChance,
    required this.capChance,
    required this.lineChance,
    required this.minDecor,
    required this.maxDecor,
    required this.emojiChance,
    this.lineMarks = const [],
    this.maxCaps = 1,
    this.mixChance = 0,
    this.lineMarkChance = 0,
    this.maxMarksPerLetter = 1,
    this.multiLineChance = 0,
  });

  final String id;
  final String label;
  final String blurb;

  /// Ids from [TextFonts] this theme likes.
  final List<String> fontIds;

  /// Whole-name wraps that already contain their own ornaments and spacing.
  final List<WrapPair> wraps;

  /// Tight brackets placed directly around the name.
  final List<WrapPair> brackets;

  /// Symmetrical end caps (`★ name ★`).
  final List<WrapPair> caps;

  /// Single glyphs repeated into horizontal line runs.
  final List<String> lines;

  /// Glyphs inserted between letters.
  final List<String> separators;

  /// Combining marks (code points) used on letters. Their position (above,
  /// below, overlay) comes from the combining mark catalog.
  final List<int> letterMarks;

  /// Combining marks that may be drawn on line glyphs.
  final List<int> lineMarks;

  /// Emoji pairs that look good together.
  final List<WrapPair> emojiPairs;

  /// Ids from the emoji catalog used for extra single emoji.
  final List<String> emojiGroups;

  /// Relative weights of the letter decoration modes.
  final Map<LetterDecoration, double> letterDecor;

  final double wrapChance;
  final double bracketChance;
  final double capChance;
  final double lineChance;
  final double emojiChance;

  /// Allowed number of decoration glyphs (not counting the name itself).
  final int minDecor;
  final int maxDecor;

  /// Most nested cap pairs.
  final int maxCaps;

  /// Chance that two fonts are mixed inside one name.
  final double mixChance;

  /// Chance that a line run carries combining marks.
  final double lineMarkChance;

  /// Most combining marks drawn on one letter.
  final int maxMarksPerLetter;

  /// Chance of a three-line design (line, name, line).
  final double multiLineChance;
}

/// How strongly designs are decorated.
enum DecorIntensity { subtle, balanced, rich }

/// How fonts are mixed inside a single name.
enum FontMixing {
  /// Use the theme's own mix chance.
  theme,

  /// Never mix: one font per design.
  never,

  /// Mix often.
  often,
}

/// Everything the user chose in the Name Studio.
class DesignRequest {
  const DesignRequest({
    required this.name,
    this.themeIds = const [],
    this.count = 20,
    this.fontIds = const [],
    this.fontMixing = FontMixing.theme,
    this.useEmoji = true,
    this.customEmojis = const [],
    this.useMarks = true,
    this.intensity = DecorIntensity.balanced,
    this.seed,
    this.exclude = const {},
  });

  final String name;

  /// Empty means every theme, mixed.
  final List<String> themeIds;

  /// How many designs to produce (1 to 100).
  final int count;

  /// Empty means "the theme's own fonts".
  final List<String> fontIds;

  final FontMixing fontMixing;
  final bool useEmoji;

  /// Emoji chosen by the user; used instead of the theme's emoji.
  final List<String> customEmojis;

  /// When false no combining marks are used on letters or lines.
  final bool useMarks;

  final DecorIntensity intensity;

  /// Fixed seed for reproducible output; null means a fresh random seed.
  final int? seed;

  /// Designs that must not be produced again ("generate more").
  final Set<String> exclude;
}

/// One generated design.
class GeneratedDesign {
  const GeneratedDesign({
    required this.text,
    required this.themeId,
    required this.fontIds,
    required this.markCodePoints,
    required this.warnings,
  });

  final String text;
  final String themeId;

  /// Font ids used for the letters of the name.
  final List<String> fontIds;

  /// Distinct combining marks used anywhere in the design.
  final List<int> markCodePoints;

  /// Advisory compatibility notes. Never a guarantee either way.
  final List<CompatibilityWarning> warnings;

  List<int> get codePoints => text.runes.toList();

  int get graphemeCount => splitGraphemes(text).length;

  bool get hasCautions =>
      warnings.any((warning) => warning.level == WarningLevel.caution);
}

/// The result of one generation request.
class DesignBatch {
  const DesignBatch({
    required this.designs,
    required this.requested,
    this.notes = const [],
  });

  final List<GeneratedDesign> designs;
  final int requested;

  /// Honest remarks, for example when fewer designs were possible.
  final List<String> notes;

  bool get isComplete => designs.length >= requested;
}
