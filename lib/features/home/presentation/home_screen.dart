import 'package:flutter/material.dart';

import '../../../shared/widgets/phase_placeholder.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PhasePlaceholder(
      title: 'Home',
      icon: Icons.home_rounded,
      message:
          'Explore • Combine • Design • Create\n\nQuick search, shortcuts and recent designs arrive once the features they link to exist (Phase 8).',
    );
  }
}
