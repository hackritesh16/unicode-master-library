import 'package:characters/characters.dart';

import '../unicode/code_point.dart';

/// Splits [text] into user-perceived characters (extended grapheme clusters),
/// so conjuncts such as Devanagari "स्ते" or "e" + combining marks stay whole.
List<String> splitGraphemes(String text) => text.characters.toList();

/// Rough check for combining-mark blocks, used for sanity checks only. The
/// authoritative answer (General Category Mn/Mc/Me) comes from the UCD.
bool isCombiningCodePoint(int cp) =>
    (cp >= 0x0300 && cp <= 0x036F) ||
    (cp >= 0x1AB0 && cp <= 0x1AFF) ||
    (cp >= 0x1DC0 && cp <= 0x1DFF) ||
    (cp >= 0x20D0 && cp <= 0x20FF) ||
    (cp >= 0xFE20 && cp <= 0xFE2F);

bool isVariationSelector(int cp) =>
    (cp >= 0xFE00 && cp <= 0xFE0F) || (cp >= 0xE0100 && cp <= 0xE01EF);

const int zeroWidthJoiner = 0x200D;

bool isSpaceLike(int cp) =>
    cp == 0x20 ||
    cp == 0x09 ||
    cp == 0x0A ||
    cp == 0x0D ||
    cp == 0xA0 ||
    cp == 0x3000 ||
    (cp >= 0x2000 && cp <= 0x200A);

/// True when every code point of [grapheme] is whitespace.
bool isBlankGrapheme(String grapheme) =>
    grapheme.runes.every(isSpaceLike);

/// Finds structurally broken sequences: orphan combining marks, unpaired
/// surrogates, dangling joiners and variation selectors, double spaces.
/// An empty list means no problem was found. This is a structural check, not a
/// promise that every app renders the text well.
List<String> findSequenceProblems(String text) {
  final problems = <String>[];
  final runes = text.runes.toList();
  for (var i = 0; i < runes.length; i++) {
    final cp = runes[i];
    final prev = i > 0 ? runes[i - 1] : null;
    if (isSurrogate(cp)) {
      problems.add('Unpaired surrogate at index $i');
      continue;
    }
    if (cp == 0xFFFD) {
      problems.add('Replacement character at index $i');
    }
    if (isCombiningCodePoint(cp) && (prev == null || isSpaceLike(prev))) {
      problems.add('Combining mark ${formatCodePoint(cp)} has no base');
    }
    if (isVariationSelector(cp) && (prev == null || isSpaceLike(prev))) {
      problems.add('Variation selector ${formatCodePoint(cp)} has no base');
    }
    if (cp == zeroWidthJoiner && (prev == null || i == runes.length - 1)) {
      problems.add('Dangling zero width joiner at index $i');
    }
    if (cp == 0x20 && prev == 0x20) {
      problems.add('Double space at index $i');
    }
  }
  return problems;
}
