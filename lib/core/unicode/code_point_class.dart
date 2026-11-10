import 'code_point.dart';

/// What kind of code point a number is. Assigned, unassigned, private-use,
/// control, surrogate and noncharacter code points are different things; an
/// unassigned code point must never be shown as if it were a visible symbol.
enum CodePointClass {
  /// Has an entry in UnicodeData.txt (explicit row or First/Last range) and
  /// is none of the special classes below.
  assigned,

  /// Valid scalar value with no UnicodeData.txt entry.
  unassigned,

  /// Private use areas (U+E000..F8FF, planes 15 and 16).
  privateUse,

  /// General category Cc (U+0000..001F, U+007F..009F).
  control,

  /// U+D800..DFFF. Not a scalar value; has no UTF-8 or UTF-16 form.
  surrogate,

  /// U+FDD0..FDEF and the last two code points of every plane.
  noncharacter,
}

bool isNoncharacter(int cp) =>
    (cp >= 0xFDD0 && cp <= 0xFDEF) ||
    (cp >= 0 && cp <= maxCodePoint && (cp & 0xFFFE) == 0xFFFE);

bool isPrivateUse(int cp) =>
    (cp >= 0xE000 && cp <= 0xF8FF) ||
    (cp >= 0xF0000 && cp <= 0xFFFFD) ||
    (cp >= 0x100000 && cp <= 0x10FFFD);

bool isControl(int cp) => (cp >= 0 && cp <= 0x1F) || (cp >= 0x7F && cp <= 0x9F);

/// Classifies [cp]. [isAssigned] says whether the database has a
/// UnicodeData.txt entry for it (explicit row or range). Surrogates,
/// noncharacters, private use and controls are decided by the code point
/// itself, so they do not depend on [isAssigned].
CodePointClass classifyCodePoint(int cp, {required bool isAssigned}) {
  if (cp < 0 || cp > maxCodePoint) {
    throw RangeError.range(cp, 0, maxCodePoint, 'cp');
  }
  if (isSurrogate(cp)) {
    return CodePointClass.surrogate;
  }
  if (isNoncharacter(cp)) {
    return CodePointClass.noncharacter;
  }
  if (isPrivateUse(cp)) {
    return CodePointClass.privateUse;
  }
  if (isControl(cp)) {
    return CodePointClass.control;
  }
  return isAssigned ? CodePointClass.assigned : CodePointClass.unassigned;
}

/// UTF-16 code units of a single code point as upper-case hex, for example
/// `0041` or `D83D DE00` for U+1F600. Surrogates have no well-formed UTF-16
/// encoding and throw [ArgumentError].
String utf16Hex(int cp) {
  if (!isUnicodeScalar(cp)) {
    throw ArgumentError.value(cp, 'cp', 'not a Unicode scalar value');
  }
  String unit(int value) =>
      value.toRadixString(16).toUpperCase().padLeft(4, '0');
  if (cp < 0x10000) {
    return unit(cp);
  }
  final offset = cp - 0x10000;
  final high = 0xD800 + (offset >> 10);
  final low = 0xDC00 + (offset & 0x3FF);
  return '${unit(high)} ${unit(low)}';
}
