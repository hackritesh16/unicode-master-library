import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unicode_master_library/main.dart';

void main() {
  testWidgets('app starts on Home with six nav destinations', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: UnicodeMasterApp()));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationDestination), findsNWidgets(6));
    expect(find.text('Home'), findsWidgets);
  });

  testWidgets('tapping a destination switches section', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: UnicodeMasterApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.explore_outlined));
    await tester.pumpAndSettle();

    // Explorer is now selected: its filled icon shows in the nav bar
    // and in the screen's placeholder badge.
    expect(find.byIcon(Icons.explore_rounded), findsWidgets);
    expect(find.byType(AppBar), findsOneWidget);
  });
}
