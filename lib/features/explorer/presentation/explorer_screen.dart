import 'package:flutter/material.dart';

import '../../../shared/widgets/phase_placeholder.dart';

class ExplorerScreen extends StatelessWidget {
  const ExplorerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PhasePlaceholder(
      title: 'Explorer',
      icon: Icons.explore_rounded,
      message:
          'The Unicode character grid and search need the Unicode database. Built in Phases 3 and 4.',
    );
  }
}
