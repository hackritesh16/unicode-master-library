import 'package:unicode_master_library/core/unicode/ucd_bundle.dart';

/// Small hand-written fixtures in the real UCD file formats. They are test
/// data only, not a copy of the official files.

const unicodeDataFixture =
    '0000;<control>;Cc;0;BN;;;;;N;NULL;;;;\n'
    '0041;LATIN CAPITAL LETTER A;Lu;0;L;;;;;N;;;;0061;\n'
    '0307;COMBINING DOT ABOVE;Mn;230;NSM;;;;;N;NON-SPACING DOT ABOVE;;;;\n'
    '0905;DEVANAGARI LETTER A;Lo;0;L;;;;;N;;;;;\n'
    '1F600;GRINNING FACE;So;0;ON;;;;;N;;;;;\n'
    '3400;<CJK Ideograph Extension A, First>;Lo;0;L;;;;;N;;;;;\n'
    '4DBF;<CJK Ideograph Extension A, Last>;Lo;0;L;;;;;N;;;;;\n'
    'E000;<Private Use, First>;Co;0;L;;;;;N;;;;;\n'
    'F8FF;<Private Use, Last>;Co;0;L;;;;;N;;;;;\n';

const blocksFixture =
    '# Blocks fixture\n'
    '\n'
    '0000..007F; Basic Latin\n'
    '0300..036F; Combining Diacritical Marks\n'
    '0900..097F; Devanagari\n'
    '1F600..1F64F; Emoticons\n';

const scriptsFixture =
    '0000..0040    ; Common # fixture\n'
    '0041..005A    ; Latin # L&  [26] LATIN CAPITAL LETTER A..Z\n'
    '0300..036F    ; Inherited # Mn [112] fixture\n'
    '0900..0950    ; Devanagari # fixture\n'
    '1F600..1F64F  ; Common # So [80] fixture\n';

const agesFixture =
    '0000..001F    ; 1.1 # Cc [32] fixture\n'
    '0041..005A    ; 1.1 # L& [26] fixture\n'
    '0300..036F    ; 1.1 # Mn [112] fixture\n'
    '0905          ; 1.1 # Lo DEVANAGARI LETTER A\n'
    '1F600         ; 6.1 # So GRINNING FACE\n';

const eastAsianWidthFixture =
    '0000..001F;N # Cc [32] fixture\n'
    '0041..005A;Na # Lu [26] fixture\n'
    '1F600;W # So GRINNING FACE\n';

const propListFixture =
    '0009..000D    ; White_Space # Cc [5] fixture\n'
    '0307          ; Diacritic # Mn COMBINING DOT ABOVE\n';

const derivedCoreFixture =
    '0041..005A    ; Alphabetic # L& [26] fixture\n'
    '094D          ; InCB; Linker # Mn DEVANAGARI SIGN VIRAMA\n';

const emojiDataFixture =
    '1F600        ; Emoji                # E1.0   [1] (grinning)  fixture\n';

const nameAliasesFixture =
    '# NameAliases fixture\n'
    '0000;NULL;control\n'
    '0000;NUL;abbreviation\n';

const emojiTestFixture =
    '# group: Smileys & Emotion\n'
    '\n'
    '# subgroup: face-smiling\n'
    '1F600                                                  ; fully-qualified     # \u{1F600} E1.0 grinning face\n'
    '263A FE0F                                              ; fully-qualified     # \u263A\uFE0F E0.6 smiling face\n'
    '263A                                                   ; unqualified         # \u263A E0.6 smiling face\n';

const fixtureBundle = UcdBundle(
  version: '99.0.0',
  files: {
    'UnicodeData.txt': unicodeDataFixture,
    'Blocks.txt': blocksFixture,
    'Scripts.txt': scriptsFixture,
    'DerivedAge.txt': agesFixture,
    'EastAsianWidth.txt': eastAsianWidthFixture,
    'PropList.txt': propListFixture,
    'DerivedCoreProperties.txt': derivedCoreFixture,
    'emoji-data.txt': emojiDataFixture,
    'NameAliases.txt': nameAliasesFixture,
    'emoji-test.txt': emojiTestFixture,
  },
);
