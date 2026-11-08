import 'dart:convert';

/// Highest valid Unicode code point.
const int maxCodePoint = 0x10FFFF;

bool isSurrogate(int cp) => cp >= 0xD800 && cp <= 0xDFFF;

/// True for code points that can be encoded in UTF-8/UTF-16 (everything in
/// 0..10FFFF except surrogates).
bool isUnicodeScalar(int cp) => cp >= 0 && cp <= maxCodePoint && !isSurrogate(cp);

/// Parses a bare hexadecimal code point such as `1F600`.
/// Throws [FormatException] for invalid or out-of-range values.
int parseCodePoint(String hex) {
  final value = int.tryParse(hex.trim(), radix: 16);
  if (value == null || value < 0 || value > maxCodePoint) {
    throw FormatException('Invalid code point', hex);
  }
  return value;
}

/// Parses a user-typed code point query: `U+1F600`, `0x1F600` or `1F600`.
/// Returns null when the text is not a valid code point. Pure hex parsing:
/// callers decide whether a short string like `A` is a character or a code.
int? tryParseCodePointQuery(String query) {
  var text = query.trim();
  if (text.isEmpty) {
    return null;
  }
  final lower = text.toLowerCase();
  if (lower.startsWith('u+') || lower.startsWith('0x')) {
    text = text.substring(2);
  }
  final value = int.tryParse(text, radix: 16);
  if (value == null || value < 0 || value > maxCodePoint) {
    return null;
  }
  return value;
}

/// Parses a whitespace-separated sequence such as `263A FE0F`.
List<int> parseCodePointSequence(String text) {
  final parts = text.trim().split(RegExp(r'\s+'));
  if (parts.length == 1 && parts.first.isEmpty) {
    throw FormatException('Empty code point sequence', text);
  }
  return parts.map(parseCodePoint).toList();
}

/// `U+0041`, `U+1F600` (at least four hex digits, upper case).
String formatCodePoint(int cp) =>
    'U+${cp.toRadixString(16).toUpperCase().padLeft(4, '0')}';

String formatCodePointSequence(Iterable<int> cps) =>
    cps.map(formatCodePoint).join(' ');

String fromCodePoints(Iterable<int> cps) => String.fromCharCodes(cps);

/// UTF-8 bytes of a single code point. Surrogates have no UTF-8 encoding and
/// throw [ArgumentError] instead of silently becoming U+FFFD.
List<int> utf8Bytes(int cp) {
  if (!isUnicodeScalar(cp)) {
    throw ArgumentError.value(cp, 'cp', 'not a Unicode scalar value');
  }
  return utf8.encode(String.fromCharCode(cp));
}

/// UTF-8 bytes as upper-case hex, e.g. `E0 A4 85` for U+0905.
String utf8Hex(int cp) => utf8Bytes(cp)
    .map((b) => b.toRadixString(16).toUpperCase().padLeft(2, '0'))
    .join(' ');
