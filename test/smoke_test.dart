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
    expect(find.text('Explore • Combine • Design • Create',
        findRichText: true, skipOffstage: false), findsNothing);
    expect(find.text('Home'), findsWidgets);
  });

  testWidgets('tapping a destination switches section', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: UnicodeMasterApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.explore_outlined));
    await tester.pumpAndSettle();

    // Screen title in the AppBar plus the nav label.
    expect(find.text('Explorer'), findsWidgets);
    expect(find.byIcon(Icons.explore_rounded), findsWidgets);
  });
}
