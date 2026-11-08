import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/composer/presentation/composer_screen.dart';
import '../../features/combining/presentation/combining_lab_screen.dart';
import '../../features/explorer/presentation/explorer_screen.dart';
import '../../features/favorites/presentation/library_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/name_studio/presentation/name_studio_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/symbols/presentation/symbol_library_screen.dart';
import '../../shared/widgets/app_shell.dart';

StatefulShellBranch _branch(String path, Widget screen) {
  return StatefulShellBranch(
    routes: [
      GoRoute(
        path: '/symbols',
        builder: (context, state) => const SymbolLibraryScreen(),
      ),
      GoRoute(path: path, builder: (context, state) => screen),
    ],
  );
}

/// Creates the app router. Branch order must match [AppShell] destinations.
GoRouter createRouter() {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(
        path: '/combining',
        builder: (context, state) => const CombiningLabScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          _branch('/home', const HomeScreen()),
          _branch('/explorer', const ExplorerScreen()),
          _branch('/studio', const NameStudioScreen()),
          _branch('/composer', const ComposerScreen()),
          _branch('/library', const LibraryScreen()),
          _branch('/settings', const SettingsScreen()),
        ],
      ),
    ],
  );
}
