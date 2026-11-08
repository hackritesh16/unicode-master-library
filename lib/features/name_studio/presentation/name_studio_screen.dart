import 'package:flutter/material.dart';

import '../../../shared/widgets/phase_placeholder.dart';

class NameStudioScreen extends StatelessWidget {
  const NameStudioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PhasePlaceholder(
      title: 'Name Studio',
      icon: Icons.auto_awesome_rounded,
      message:
          'The themed Unicode name designer is built in Phase 6.',
    );
  }
}
