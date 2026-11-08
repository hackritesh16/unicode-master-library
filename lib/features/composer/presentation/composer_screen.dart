import 'package:flutter/material.dart';

import '../../../shared/widgets/phase_placeholder.dart';

class ComposerScreen extends StatelessWidget {
  const ComposerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PhasePlaceholder(
      title: 'Composer',
      icon: Icons.edit_rounded,
      message:
          'The manual decorative editor is built in Phase 7.',
    );
  }
}
