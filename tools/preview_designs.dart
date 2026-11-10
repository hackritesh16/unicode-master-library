// Prints sample Name Studio output. Run from the repository root:
//   dart run tools/preview_designs.dart [name]
// It is used by CI so generated designs can be reviewed in the build log.
import 'dart:io';

import 'package:unicode_master_library/core/text_design/design_engine.dart';
import 'package:unicode_master_library/core/text_design/design_themes.dart';
import 'package:unicode_master_library/core/text_design/design_types.dart';

void main(List<String> args) {
  final names = args.isEmpty
      ? ['Sefali', 'Ritesh', 'सेफाली', 'Player 1']
      : [args.join(' ')];

  for (final name in names) {
    stdout.writeln('\n=== $name ===');
    for (final theme in DesignThemes.all) {
      final batch = DesignEngine.generate(
        DesignRequest(name: name, themeIds: [theme.id], count: 4, seed: 7),
      );
      stdout.writeln('--- ${theme.label}');
      for (final design in batch.designs) {
        stdout.writeln(design.text.replaceAll('\n', '\n    '));
      }
    }
  }

  stdout.writeln('\n=== capacity (unique designs for "Sefali") ===');
  final watch = Stopwatch()..start();
  for (final theme in DesignThemes.all) {
    final batch = DesignEngine.generate(
      DesignRequest(name: 'Sefali', themeIds: [theme.id], count: 100, seed: 3),
    );
    stdout.writeln('${theme.id.padRight(14)} ${batch.designs.length}/100');
  }
  final mixed = DesignEngine.generate(
    const DesignRequest(name: 'Sefali', count: 100, seed: 3),
  );
  watch.stop();
  stdout.writeln('mixed all themes  ${mixed.designs.length}/100');
  stdout.writeln('generation time for 16 batches: ${watch.elapsedMilliseconds} ms');
}
