import 'package:flutter/material.dart';

import '../../../shared/widgets/phase_placeholder.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PhasePlaceholder(
      title: 'Settings',
      icon: Icons.settings_rounded,
      message:
          'Preferences, database updates and Unicode data attribution arrive with Phases 3 and 9.',
    );
  }
}
