import 'dart:convert';

import '../core/unicode/code_point.dart';

/// One design prepared for export.
class ExportItem {
  const ExportItem({
    required this.text,
    this.theme,
    this.fonts = const [],
  });

  final String text;
  final String? theme;
  final List<String> fonts;
}

/// Pure formatting helpers for copy, TXT and JSON export. Nothing here
/// normalizes or trims the designs: the exact Unicode characters and
/// combining sequences are preserved.
abstract final class ExportFormats {
  /// `U+0053 U+0065 ...` for [text], one entry per code point.
  static String codePointsOf(String text) =>
      formatCodePointSequence(text.runes);

  /// Designs separated by a newline, or by a blank line when any design spans
  /// several lines so the blocks stay distinguishable.
  static String toText(Iterable<String> designs) {
    final list = designs.toList();
    final separator = list.any((design) => design.contains('\n')) ? '\n\n' : '\n';
    return list.join(separator);
  }

  /// A readable report: every design followed by its code points.
  static String toCodePointReport(Iterable<String> designs) {
    final buffer = StringBuffer();
    for (final design in designs) {
      buffer
        ..writeln(design)
        ..writeln(codePointsOf(design))
        ..writeln();
    }
    return buffer.toString().trimRight();
  }

  /// Pretty JSON with the text, its code points and the theme and fonts used.
  static String toJson(
    Iterable<ExportItem> items, {
    String? name,
    DateTime? generatedAt,
  }) {
    final data = <String, Object?>{
      'generator': 'Unicode Master Library',
      if (name != null) 'name': name,
      if (generatedAt != null)
        'generatedAt': generatedAt.toUtc().toIso8601String(),
      'count': items.length,
      'designs': [
        for (final item in items)
          {
            'text': item.text,
            'codePoints': [for (final rune in item.text.runes) formatCodePoint(rune)],
            if (item.theme != null) 'theme': item.theme,
            if (item.fonts.isNotEmpty) 'fonts': item.fonts,
          },
      ],
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }
}
