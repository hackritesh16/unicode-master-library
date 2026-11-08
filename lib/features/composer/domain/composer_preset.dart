class ComposerPreset {
  const ComposerPreset({
    required this.id,
    required this.label,
    required this.prefix,
    required this.suffix,
  });

  final String id;
  final String label;
  final String prefix;
  final String suffix;
}

const composerPresets = <ComposerPreset>[
  ComposerPreset(
    id: 'sparkle',
    label: 'Sparkle',
    prefix: '✦ ',
    suffix: ' ✦',
  ),
  ComposerPreset(
    id: 'royal',
    label: 'Royal',
    prefix: '꧁༺ ',
    suffix: ' ༻꧂',
  ),
  ComposerPreset(
    id: 'brackets',
    label: 'Brackets',
    prefix: '『',
    suffix: '』',
  ),
  ComposerPreset(
    id: 'wings',
    label: 'Wings',
    prefix: '𓆩 ',
    suffix: ' 𓆪',
  ),
  ComposerPreset(
    id: 'heart',
    label: 'Heart',
    prefix: '♡ ',
    suffix: ' ♡',
  ),
  ComposerPreset(
    id: 'minimal',
    label: 'Minimal',
    prefix: '— ',
    suffix: ' —',
  ),
];

String buildComposerOutput({
  required String text,
  required ComposerPreset preset,
  String customPrefix = '',
  String customSuffix = '',
}) {
  if (text.isEmpty) return '';
  final prefix = customPrefix.isEmpty ? preset.prefix : customPrefix;
  final suffix = customSuffix.isEmpty ? preset.suffix : customSuffix;
  return '$prefix$text$suffix';
}
