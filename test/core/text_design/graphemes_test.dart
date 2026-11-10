import 'package:flutter_test/flutter_test.dart';
import 'package:unicode_master_library/core/text_design/graphemes.dart';

void main() {
  group('splitGraphemes', () {
    test('plain English', () {
      expect(splitGraphemes('Sefali'), ['S', 'e', 'f', 'a', 'l', 'i']);
    });

    test('Hindi text splits into syllable clusters, not code points', () {
      expect(splitGraphemes('सेफाली'), ['से', 'फा', 'ली']);
    });

    test('a letter with combining marks is one grapheme', () {
      expect(splitGraphemes('é'), ['é']);
      expect(splitGraphemes('Ȧ̲'), ['Ȧ̲']);
    });

    test('emoji sequences stay whole', () {
      expect(splitGraphemes('👨‍👩‍👧').length, 1);
      expect(splitGraphemes('🇮🇳').length, 1);
      expect(splitGraphemes('👍🏽').length, 1);
      expect(splitGraphemes('❤️').length, 1);
    });

    test('numbers and mixed scripts', () {
      expect(splitGraphemes('A1 रि'), ['A', '1', ' ', 'रि']);
    });
  });

  group('isBlankGrapheme', () {
    test('spaces are blank, letters are not', () {
      expect(isBlankGrapheme(' '), isTrue);
      expect(isBlankGrapheme(' '), isTrue);
      expect(isBlankGrapheme('a'), isFalse);
      expect(isBlankGrapheme('✦'), isFalse);
    });
  });

  group('findSequenceProblems', () {
    test('clean text has no problems', () {
      expect(findSequenceProblems('Sefali'), isEmpty);
      expect(findSequenceProblems('Ȧ सेफाली 👨‍👩‍👧'), isEmpty);
    });

    test('orphan combining mark', () {
      expect(findSequenceProblems('̇A'), isNotEmpty);
      expect(findSequenceProblems('A ̇'), isNotEmpty);
    });

    test('dangling zero width joiner', () {
      expect(findSequenceProblems('A‍'), isNotEmpty);
    });

    test('double space and unpaired surrogate', () {
      expect(findSequenceProblems('a  b'), isNotEmpty);
      expect(
        findSequenceProblems(String.fromCharCode(0xD800)),
        isNotEmpty,
      );
    });
  });
}
