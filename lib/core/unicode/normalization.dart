import 'package:unorm_dart/unorm_dart.dart' as unorm;

/// Unicode normalization forms.
enum NormalizationForm { nfc, nfd, nfkc, nfkd }

/// Normalizes [text] to [form].
///
/// Note: `A` + U+0308 becomes the single code point U+00C4 under NFC. The
/// decoration engine therefore never normalizes its own output; it only uses
/// this for comparison, search and decomposing accented input letters.
String normalizeText(String text, NormalizationForm form) {
  switch (form) {
    case NormalizationForm.nfc:
      return unorm.nfc(text);
    case NormalizationForm.nfd:
      return unorm.nfd(text);
    case NormalizationForm.nfkc:
      return unorm.nfkc(text);
    case NormalizationForm.nfkd:
      return unorm.nfkd(text);
  }
}

/// True when [a] and [b] are canonically equivalent (same NFC form).
bool canonicallyEqual(String a, String b) =>
    normalizeText(a, NormalizationForm.nfc) ==
    normalizeText(b, NormalizationForm.nfc);
