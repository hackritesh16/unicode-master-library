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

    final bar = find.byType(NavigationBar);
    expect(tester.widget<NavigationBar>(bar).selectedIndex, 0);

    await tester.tap(
      find.descendant(of: bar, matching: find.text('Explorer')),
    );
    await tester.pumpAndSettle();

    // Assert on the navigation state rather than on icon widgets, which the
    // design system is free to restyle.
    expect(tester.widget<NavigationBar>(bar).selectedIndex, 1);
  });
}
