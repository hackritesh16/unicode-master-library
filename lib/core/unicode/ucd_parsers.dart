import 'code_point.dart';

/// A inclusive code point range with a string value
/// (block name, script name, age, property name, ...).
class CodePointRange {
  const CodePointRange(this.start, this.end, this.value);

  final int start;
  final int end;
  final String value;

  bool contains(int cp) => cp >= start && cp <= end;
  int get length => end - start + 1;
}

final RegExp _lineSplit = RegExp(r'\r?\n');

String _stripComment(String line) {
  final i = line.indexOf('#');
  return (i >= 0 ? line.substring(0, i) : line).trim();
}

(int, int) _parseRange(String field, int lineNo) {
  try {
    final parts = field.split('..');
    final start = parseCodePoint(parts[0]);
    final end = parts.length > 1 ? parseCodePoint(parts[1]) : start;
    if (end < start) {
      throw const FormatException('range end before start');
    }
    return (start, end);
  } on FormatException catch (e) {
    throw FormatException('Line $lineNo: ${e.message}', field);
  }
}

/// Parses the common UCD format `START[..END] ; value # comment`, used by
/// Blocks.txt, Scripts.txt, DerivedAge.txt, EastAsianWidth.txt, PropList.txt,
/// DerivedCoreProperties.txt and emoji-data.txt.
///
/// When a line has more than two fields (e.g. `094D ; InCB; Linker`), the
/// remaining fields are joined with `; `.
List<CodePointRange> parseRangeFile(String text) {
  final result = <CodePointRange>[];
  final lines = text.split(_lineSplit);
  for (var i = 0; i < lines.length; i++) {
    final line = _stripComment(lines[i]);
    if (line.isEmpty) {
      continue;
    }
    final fields = line.split(';');
    if (fields.length < 2) {
      throw FormatException('Line ${i + 1}: expected at least 2 fields', line);
    }
    final range = _parseRange(fields[0].trim(), i + 1);
    final value = fields.sublist(1).map((f) => f.trim()).join('; ');
    result.add(CodePointRange(range.$1, range.$2, value));
  }
  return result;
}

/// One explicit row of UnicodeData.txt.
class UnicodeDataRecord {
  const UnicodeDataRecord({
    required this.cp,
    required this.name,
    required this.generalCategory,
    required this.combiningClass,
    required this.bidiClass,
    required this.decomposition,
    required this.decimalValue,
    required this.digitValue,
    required this.numericValue,
    required this.bidiMirrored,
    required this.uppercaseMapping,
    required this.lowercaseMapping,
    required this.titlecaseMapping,
  });

  final int cp;

  /// Raw name field. Control characters carry `<control>`; their real names
  /// come from NameAliases.txt.
  final String name;
  final String generalCategory;
  final int combiningClass;
  final String bidiClass;
  final String decomposition;
  final String decimalValue;
  final String digitValue;
  final String numericValue;
  final bool bidiMirrored;
  final String uppercaseMapping;
  final String lowercaseMapping;
  final String titlecaseMapping;
}

/// A `<..., First>` / `<..., Last>` pair of UnicodeData.txt (CJK ideographs,
/// Hangul syllables, private use areas, surrogates, ...). These are NOT
/// expanded into one record per code point.
class UnicodeDataRange {
  const UnicodeDataRange({
    required this.start,
    required this.end,
    required this.name,
    required this.generalCategory,
    required this.combiningClass,
    required this.bidiClass,
  });

  final int start;
  final int end;

  /// Name without angle brackets and First/Last, e.g. `CJK Ideograph`.
  final String name;
  final String generalCategory;
  final int combiningClass;
  final String bidiClass;
}

class UnicodeDataParseResult {
  const UnicodeDataParseResult(this.characters, this.ranges);

  final List<UnicodeDataRecord> characters;
  final List<UnicodeDataRange> ranges;
}

const String _firstSuffix = ', First>';
const String _lastSuffix = ', Last>';

/// Parses UnicodeData.txt (15 semicolon-separated fields per line).
UnicodeDataParseResult parseUnicodeData(String text) {
  final characters = <UnicodeDataRecord>[];
  final ranges = <UnicodeDataRange>[];
  final lines = text.split(_lineSplit);

  int? pendingStart;
  String? pendingName;
  List<String>? pendingFields;

  for (var i = 0; i < lines.length; i++) {
    final line = lines[i].trim();
    if (line.isEmpty) {
      continue;
    }
    final f = line.split(';');
    if (f.length < 15) {
      throw FormatException(
        'Line ${i + 1}: expected 15 fields, got ${f.length}',
        line,
      );
    }
    final cp = parseCodePoint(f[0]);
    final name = f[1];

    if (name.endsWith(_firstSuffix)) {
      pendingStart = cp;
      pendingName = name.substring(1, name.length - _firstSuffix.length);
      pendingFields = f;
      continue;
    }
    if (name.endsWith(_lastSuffix)) {
      final rangeName = name.substring(1, name.length - _lastSuffix.length);
      if (pendingStart == null ||
          pendingName != rangeName ||
          pendingFields == null) {
        throw FormatException('Line ${i + 1}: unmatched range end', line);
      }
      ranges.add(
        UnicodeDataRange(
          start: pendingStart,
          end: cp,
          name: rangeName,
          generalCategory: pendingFields[2],
          combiningClass: int.parse(pendingFields[3]),
          bidiClass: pendingFields[4],
        ),
      );
      pendingStart = null;
      pendingName = null;
      pendingFields = null;
      continue;
    }

    characters.add(
      UnicodeDataRecord(
        cp: cp,
        name: name,
        generalCategory: f[2],
        combiningClass: int.parse(f[3]),
        bidiClass: f[4],
        decomposition: f[5],
        decimalValue: f[6],
        digitValue: f[7],
        numericValue: f[8],
        bidiMirrored: f[9] == 'Y',
        uppercaseMapping: f[12],
        lowercaseMapping: f[13],
        titlecaseMapping: f[14],
      ),
    );
  }

  if (pendingStart != null) {
    throw const FormatException('UnicodeData.txt ends inside a First/Last range');
  }
  return UnicodeDataParseResult(characters, ranges);
}

/// One row of NameAliases.txt: `code point; alias; type`.
class NameAlias {
  const NameAlias(this.cp, this.alias, this.type);

  final int cp;
  final String alias;

  /// correction, control, alternate, figment or abbreviation.
  final String type;
}

List<NameAlias> parseNameAliases(String text) {
  final result = <NameAlias>[];
  final lines = text.split(_lineSplit);
  for (var i = 0; i < lines.length; i++) {
    final line = _stripComment(lines[i]);
    if (line.isEmpty) {
      continue;
    }
    final f = line.split(';');
    if (f.length < 3) {
      throw FormatException('Line ${i + 1}: expected 3 fields', line);
    }
    result.add(NameAlias(parseCodePoint(f[0]), f[1].trim(), f[2].trim()));
  }
  return result;
}

/// One emoji (single code point or multi-code-point sequence) from
/// emoji-test.txt.
class EmojiSequenceRecord {
  const EmojiSequenceRecord({
    required this.codePoints,
    required this.status,
    required this.group,
    required this.subgroup,
    required this.name,
    required this.since,
  });

  final List<int> codePoints;

  /// component, fully-qualified, minimally-qualified or unqualified.
  final String status;
  final String group;
  final String subgroup;
  final String name;

  /// Emoji version the sequence was introduced in, e.g. `1.0`.
  final String since;

  String get sequence => String.fromCharCodes(codePoints);
  bool get isSingleCodePoint => codePoints.length == 1;
}

final RegExp _groupRe = RegExp(r'^#\s*group:\s*(.+)$');
final RegExp _subgroupRe = RegExp(r'^#\s*subgroup:\s*(.+)$');
final RegExp _emojiCommentRe = RegExp(r'^\s*(\S+)\s+E(\d+(?:\.\d+)?)\s+(.+)$');

/// Parses emoji-test.txt, tracking `# group:` and `# subgroup:` headers.
List<EmojiSequenceRecord> parseEmojiTest(String text) {
  final result = <EmojiSequenceRecord>[];
  final lines = text.split(_lineSplit);
  var group = '';
  var subgroup = '';

  for (var i = 0; i < lines.length; i++) {
    final line = lines[i].trim();
    if (line.isEmpty) {
      continue;
    }
    if (line.startsWith('#')) {
      final g = _groupRe.firstMatch(line);
      if (g != null) {
        group = g.group(1)!.trim();
        continue;
      }
      final s = _subgroupRe.firstMatch(line);
      if (s != null) {
        subgroup = s.group(1)!.trim();
      }
      continue;
    }

    final hash = line.indexOf('#');
    if (hash < 0) {
      throw FormatException('Line ${i + 1}: missing comment', line);
    }
    final left = line.substring(0, hash).split(';');
    if (left.length < 2) {
      throw FormatException('Line ${i + 1}: expected 2 fields', line);
    }
    final comment = _emojiCommentRe.firstMatch(line.substring(hash + 1));
    if (comment == null) {
      throw FormatException('Line ${i + 1}: unrecognised comment', line);
    }
    result.add(
      EmojiSequenceRecord(
        codePoints: parseCodePointSequence(left[0]),
        status: left[1].trim(),
        group: group,
        subgroup: subgroup,
        name: comment.group(3)!.trim(),
        since: comment.group(2)!,
      ),
    );
  }
  return result;
}

final RegExp _versionRe = RegExp(
  r'version\s+(\d+\.\d+\.\d+)\s+of\s+the\s+Unicode\s+Character\s+Database',
  caseSensitive: false,
);

/// Extracts the Unicode version (e.g. `18.0.0`) from `UCD/latest/ReadMe.txt`.
/// Returns null if the expected sentence is not found.
String? parseUcdVersion(String readme) =>
    _versionRe.firstMatch(readme)?.group(1);
