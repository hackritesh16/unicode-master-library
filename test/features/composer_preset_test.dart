import 'package:flutter_test/flutter_test.dart';
import 'package:unicode_master_library/features/composer/domain/composer_preset.dart';

void main() {
  group('buildComposerOutput', () {
    test('wraps text with the selected preset', () {
      expect(
        buildComposerOutput(text: 'Ranjeet', preset: composerPresets[0]),
        '✦ Ranjeet ✦',
      );
    });

    test('custom prefix and suffix override preset decoration', () {
      expect(
        buildComposerOutput(
          text: 'NK Player',
          preset: composerPresets[1],
          customPrefix: '<',
          customSuffix: '>',
        ),
        '<NK Player>',
      );
    });

    test('one custom side can be used with the preset other side', () {
      expect(
        buildComposerOutput(
          text: 'Hello',
          preset: composerPresets[2],
          customPrefix: '★',
        ),
        '★Hello』',
      );
    });

    test('empty text produces empty output', () {
      expect(buildComposerOutput(text: '', preset: composerPresets[0]), '');
    });
  });
}
