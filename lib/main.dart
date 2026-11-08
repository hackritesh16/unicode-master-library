import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'shared/widgets/glass_widgets.dart';

void main() {
  runApp(const ProviderScope(child: UnicodeMasterApp()));
}

class UnicodeMasterApp extends StatefulWidget {
  const UnicodeMasterApp({super.key});

  @override
  State<UnicodeMasterApp> createState() => _UnicodeMasterAppState();
}

class _UnicodeMasterAppState extends State<UnicodeMasterApp> {
  late final GoRouter _router = createRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Unicode Master Library',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: _router,
      // One ambient backdrop behind every route, including routes outside the
      // bottom-navigation shell (Combining Lab, Symbols).
      builder: (context, child) =>
          GlassBackground(child: child ?? const SizedBox.shrink()),
    );
  }
}
