import 'package:flutter_test/flutter_test.dart';
import 'package:unicode_master_library/core/unicode/code_point_class.dart';

void main() {
  group('classifyCodePoint', () {
    test('surrogates are never assigned or scalar', () {
      expect(classifyCodePoint(0xD800, isAssigned: true),
          CodePointClass.surrogate);
      expect(classifyCodePoint(0xDFFF, isAssigned: false),
          CodePointClass.surrogate);
    });

    test('noncharacters: FDD0..FDEF and the last two code points of a plane',
        () {
      for (final cp in [0xFDD0, 0xFDEF, 0xFFFE, 0xFFFF, 0x1FFFE, 0x10FFFF]) {
        expect(classifyCodePoint(cp, isAssigned: false),
            CodePointClass.noncharacter,
            reason: 'U+${cp.toRadixString(16)}');
      }
      expect(classifyCodePoint(0xFDCF, isAssigned: false),
          isNot(CodePointClass.noncharacter));
      expect(classifyCodePoint(0xFFFD, isAssigned: true),
          CodePointClass.assigned);
    });

    test('private use areas', () {
      for (final cp in [0xE000, 0xF8FF, 0xF0000, 0xFFFFD, 0x100000, 0x10FFFD]) {
        expect(classifyCodePoint(cp, isAssigned: true),
            CodePointClass.privateUse,
            reason: 'U+${cp.toRadixString(16)}');
      }
    });

    test('control characters', () {
      for (final cp in [0x0, 0x1F, 0x7F, 0x9F]) {
        expect(classifyCodePoint(cp, isAssigned: true), CodePointClass.control);
      }
      expect(classifyCodePoint(0x20, isAssigned: true), CodePointClass.assigned);
      expect(classifyCodePoint(0xA0, isAssigned: true), CodePointClass.assigned);
    });

    test('assigned versus unassigned depends on the database flag', () {
      expect(classifyCodePoint(0x41, isAssigned: true), CodePointClass.assigned);
      expect(classifyCodePoint(0x378, isAssigned: false),
          CodePointClass.unassigned);
    });

    test('rejects values outside 0..10FFFF', () {
      expect(() => classifyCodePoint(-1, isAssigned: false),
          throwsA(isA<RangeError>()));
      expect(() => classifyCodePoint(0x110000, isAssigned: false),
          throwsA(isA<RangeError>()));
    });
  });

  group('utf16Hex', () {
    test('BMP code points are one unit', () {
      expect(utf16Hex(0x41), '0041');
      expect(utf16Hex(0x20AC), '20AC');
    });

    test('supplementary code points are surrogate pairs', () {
      expect(utf16Hex(0x1F600), 'D83D DE00');
      expect(utf16Hex(0x10000), 'D800 DC00');
      expect(utf16Hex(0x10FFFF), 'DBFF DFFF');
    });

    test('surrogates and out-of-range values throw', () {
      expect(() => utf16Hex(0xD800), throwsArgumentError);
      expect(() => utf16Hex(0x110000), throwsArgumentError);
    });
  });
}
