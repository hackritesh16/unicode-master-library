import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:unicode_master_library/services/export_formats.dart';

void main() {
  group('ExportFormats', () {
    test('code points keep every code point of a combining sequence', () {
      expect(ExportFormats.codePointsOf('Ȧ'), 'U+0041 U+0307');
      expect(
        ExportFormats.codePointsOf('👨‍👩‍👧'),
        'U+1F468 U+200D U+1F469 U+200D U+1F467',
      );
      expect(ExportFormats.codePointsOf('सेफाली'), 'U+0938 U+0947 U+092B U+093E U+0932 U+0940');
    });

    test('plain text export joins designs with newlines and keeps them intact',
        () {
      const designs = ['★ Ȧ ★', '꒰ა 𝐒 ໒꒱'];
      expect(ExportFormats.toText(designs), '★ Ȧ ★\n꒰ა 𝐒 ໒꒱');
    });

    test('multi-line designs are separated by blank lines', () {
      const designs = ['──\nA\n──', '══\nB\n══'];
      expect(ExportFormats.toText(designs), '──\nA\n──\n\n══\nB\n══');
    });

    test('report lists each design with its code points', () {
      final report = ExportFormats.toCodePointReport(['Ȧ']);
      expect(report, 'Ȧ\nU+0041 U+0307');
    });

    test('JSON round-trips the exact text and code points', () {
      final json = ExportFormats.toJson(
        const [
          ExportItem(text: 'Ȧ ♡', theme: 'cute', fonts: ['bold']),
          ExportItem(text: '🦋'),
        ],
        name: 'Sefali',
        generatedAt: DateTime.utc(2026, 11, 9, 12),
      );
      final decoded = jsonDecode(json) as Map<String, dynamic>;
      expect(decoded['name'], 'Sefali');
      expect(decoded['count'], 2);
      expect(decoded['generatedAt'], '2026-11-09T12:00:00.000Z');
      final designs = decoded['designs'] as List<dynamic>;
      final first = designs[0] as Map<String, dynamic>;
      expect(first['text'], 'Ȧ ♡');
      expect(first['codePoints'], ['U+0041', 'U+0307', 'U+0020', 'U+2661']);
      expect(first['theme'], 'cute');
      expect(first['fonts'], ['bold']);
      final second = designs[1] as Map<String, dynamic>;
      expect(second['codePoints'], ['U+1F98B']);
      expect(second.containsKey('theme'), isFalse);
    });
  });
}
