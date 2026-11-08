import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unicode_master_library/features/combining/presentation/combining_lab_screen.dart';

void main() {
  testWidgets('Combining Lab lets users add and remove marks', (tester) async {
    // The screen is a lazy ListView: widgets below the viewport (plus a small
    // cache extent) are not built. Use a tall viewport so the whole screen,
    // including the "Applied sequence" section at the bottom, is built.
    tester.view.physicalSize = const Size(900, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: CombiningLabScreen()));
    expect(find.text('Combining Marks Lab'), findsOneWidget);
    expect(find.text('0 selected'), findsOneWidget);

    await tester.tap(find.text('Combining Acute Accent'));
    await tester.pump();

    expect(find.text('1 selected'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is SelectableText && widget.data == 'U+0301',
      ),
      findsOneWidget,
    );
    expect(find.text('Applied sequence'), findsOneWidget);

    await tester.tap(find.byTooltip('Reset marks'));
    await tester.pump();
    expect(find.text('0 selected'), findsOneWidget);
    expect(find.text('No marks selected'), findsOneWidget);
  });
}
