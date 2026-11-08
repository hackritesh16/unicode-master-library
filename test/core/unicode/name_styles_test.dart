import 'package:flutter_test/flutter_test.dart';
import 'package:unicode_master_library/core/unicode/name_styles.dart';
void main() {
  test('bold maps ASCII letters and digits', () => expect(nameStyles.first.transform('Ab9'), '𝐀𝐛𝟗'));
  test('monospace maps letters and digits', () => expect(nameStyles[1].transform('A0'), '𝙰𝟶'));
  test('fullwidth preserves spaces and non-ASCII', () => expect(nameStyles[2].transform('A B क'), 'Ａ Ｂ क'));
  test('circled maps letters and numbers', () => expect(nameStyles[3].transform('Az10'), 'Ⓐⓩ①⓪'));
  test('small caps preserves unsupported characters', () => expect(nameStyles[4].transform('Ab क!'), 'ᴀʙ क!'));
}
