import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Scaffold with the bottom navigation bar shared by the six main sections.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _destinations = <NavigationDestination>[
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home_rounded),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(Icons.explore_outlined),
      selectedIcon: Icon(Icons.explore_rounded),
      label: 'Explorer',
    ),
    NavigationDestination(
      icon: Icon(Icons.auto_awesome_outlined),
      selectedIcon: Icon(Icons.auto_awesome_rounded),
      label: 'Studio',
    ),
    NavigationDestination(
      icon: Icon(Icons.edit_outlined),
      selectedIcon: Icon(Icons.edit_rounded),
      label: 'Composer',
    ),
    NavigationDestination(
      icon: Icon(Icons.bookmarks_outlined),
      selectedIcon: Icon(Icons.bookmarks_rounded),
      label: 'Library',
    ),
    NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings_rounded),
      label: 'Settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        destinations: _destinations,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}
