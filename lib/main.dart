import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: UnicodeMasterApp()));
}

/// Phase 1 shell only. Theme, navigation and screens arrive in Phase 2+.
class UnicodeMasterApp extends StatelessWidget {
  const UnicodeMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Unicode Master Library',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: const Scaffold(
        body: Center(child: Text('Unicode Master Library')),
      ),
    );
  }
}
