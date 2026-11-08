import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unicode_master_library/features/symbols/presentation/symbol_library_screen.dart';

void main() {
  testWidgets('Symbol library filters by category and search', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SymbolLibraryScreen()));

    expect(find.text('Emoji & Symbols'), findsOneWidget);
    expect(find.text('Grinning face'), findsOneWidget);

    await tester.tap(find.text('Hearts'));
    await tester.pump();
    expect(find.text('Red heart'), findsOneWidget);
    expect(find.text('Grinning face'), findsNothing);

    await tester.enterText(find.byType(TextField), 'Blue heart');
    await tester.pump();
    expect(find.text('Blue heart'), findsOneWidget);
    expect(find.text('Red heart'), findsNothing);
  });
}
