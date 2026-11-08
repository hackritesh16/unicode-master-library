import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unicode_master_library/features/combining/presentation/combining_lab_screen.dart';
void main() {
  testWidgets('Combining Lab lets users add and remove marks', (tester) async {
    await tester.view.setPhysicalSize(const Size(900, 1800));
    await tester.view.setDevicePixelRatio(1);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(home: CombiningLabScreen()));
    expect(find.text('Combining Marks Lab'), findsOneWidget);
    expect(find.text('0 selected'), findsOneWidget);
    await tester.ensureVisible(find.text('Combining Acute Accent'));
    await tester.tap(find.text('Combining Acute Accent'));
    await tester.pump();
    expect(find.text('1 selected'), findsOneWidget);
    expect(find.text('U+0301'), findsOneWidget);
    expect(find.text('Applied sequence'), findsOneWidget);
    await tester.tap(find.byTooltip('Reset marks'));
    await tester.pump();
    expect(find.text('0 selected'), findsOneWidget);
    expect(find.text('No marks selected'), findsOneWidget);
  });
}
