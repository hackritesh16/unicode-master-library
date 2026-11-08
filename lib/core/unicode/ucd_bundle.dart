import 'ucd_parsers.dart';

/// Raw text of the downloaded UCD files, keyed by file name
/// (e.g. `UnicodeData.txt`), plus the Unicode version they belong to.
class UcdBundle {
  const UcdBundle({required this.version, required this.files});

  final String version;
  final Map<String, String> files;
}

/// A property range from PropList.txt, DerivedCoreProperties.txt or
/// emoji-data.txt.
class PropertyRange {
  const PropertyRange(this.start, this.end, this.name, this.source);

  final int start;
  final int end;
  final String name;

  /// File the property came from.
  final String source;
}

/// Everything parsed from a [UcdBundle], ready to be written to SQLite.
class ParsedUcd {
  const ParsedUcd({
    required this.version,
    required this.unicodeData,
    required this.blocks,
    required this.scripts,
    required this.ages,
    required this.eastAsianWidths,
    required this.properties,
    required this.nameAliases,
    required this.emojiSequences,
  });

  final String version;
  final UnicodeDataParseResult unicodeData;
  final List<CodePointRange> blocks;
  final List<CodePointRange> scripts;
  final List<CodePointRange> ages;
  final List<CodePointRange> eastAsianWidths;
  final List<PropertyRange> properties;
  final List<NameAlias> nameAliases;
  final List<EmojiSequenceRecord> emojiSequences;
}

/// Files that must be present in a bundle.
const List<String> requiredUcdFiles = [
  'UnicodeData.txt',
  'Blocks.txt',
  'Scripts.txt',
  'DerivedAge.txt',
  'PropList.txt',
  'DerivedCoreProperties.txt',
  'EastAsianWidth.txt',
  'NameAliases.txt',
  'emoji-data.txt',
];

/// Optional: emoji-test.txt (emoji sequences). Missing means no emoji
/// sequences are imported.
const String optionalEmojiTestFile = 'emoji-test.txt';

List<PropertyRange> _properties(String source, List<CodePointRange> ranges) =>
    ranges
        .map((r) => PropertyRange(r.start, r.end, r.value, source))
        .toList();

/// Parses a whole bundle. Top-level so it can run in a background isolate via
/// `compute`. Throws [StateError] if a required file is missing and
/// [FormatException] on malformed data.
ParsedUcd parseUcdBundle(UcdBundle bundle) {
  String need(String name) {
    final text = bundle.files[name];
    if (text == null) {
      throw StateError('Missing required UCD file: $name');
    }
    return text;
  }

  final emojiTest = bundle.files[optionalEmojiTestFile];

  return ParsedUcd(
    version: bundle.version,
    unicodeData: parseUnicodeData(need('UnicodeData.txt')),
    blocks: parseRangeFile(need('Blocks.txt')),
    scripts: parseRangeFile(need('Scripts.txt')),
    ages: parseRangeFile(need('DerivedAge.txt')),
    eastAsianWidths: parseRangeFile(need('EastAsianWidth.txt')),
    properties: [
      ..._properties('PropList.txt', parseRangeFile(need('PropList.txt'))),
      ..._properties(
        'DerivedCoreProperties.txt',
        parseRangeFile(need('DerivedCoreProperties.txt')),
      ),
      ..._properties('emoji-data.txt', parseRangeFile(need('emoji-data.txt'))),
    ],
    nameAliases: parseNameAliases(need('NameAliases.txt')),
    emojiSequences: emojiTest == null ? const [] : parseEmojiTest(emojiTest),
  );
}
