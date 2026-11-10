import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unicode_master_library/features/symbols/presentation/style_palette_screen.dart';

void main() {
  testWidgets('Style Palette searches and filters Unicode marks', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: StylePaletteScreen()));

    expect(find.text('Style Palette'), findsOneWidget);
    expect(find.text('Combining Grave Accent'), findsOneWidget);

    await tester.tap(find.text('Below marks'));
    await tester.pump();
    expect(find.text('Combining Dot Below'), findsOneWidget);
    expect(find.text('Combining Grave Accent'), findsNothing);

    await tester.enterText(find.byType(TextField), 'U+0323');
    await tester.pump();
    expect(find.text('Combining Dot Below'), findsOneWidget);
    expect(find.text('1 items'), findsOneWidget);
  });
}
