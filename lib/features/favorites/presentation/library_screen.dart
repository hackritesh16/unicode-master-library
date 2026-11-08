import 'package:flutter/material.dart';

import '../../../shared/widgets/phase_placeholder.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PhasePlaceholder(
      title: 'Library',
      icon: Icons.bookmarks_rounded,
      message:
          'Favorites, saved designs and history are built in Phase 9.',
    );
  }
}
