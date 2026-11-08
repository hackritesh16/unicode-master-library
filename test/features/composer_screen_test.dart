import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unicode_master_library/features/composer/presentation/composer_screen.dart';

Finder preview(String value) => find.byWidgetPredicate(
      (widget) => widget is SelectableText && widget.data == value,
    );

void main() {
  testWidgets('Composer updates preview when text and frame change',
      (tester) async {
    // The screen is a lazy ListView: the live preview sits below the default
    // 800x600 test viewport and would not be built. Use a tall viewport.
    tester.view.physicalSize = const Size(900, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: ComposerScreen()));

    expect(find.text('Decorative Composer'), findsOneWidget);
    expect(preview('✦ Your Text ✦'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'NK Player');
    await tester.pump();
    expect(preview('✦ NK Player ✦'), findsOneWidget);

    await tester.tap(find.text('Royal'));
    await tester.pump();
    expect(preview('꧁༺ NK Player ༻꧂'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(1), '★');
    await tester.pump();
    expect(preview('★NK Player ༻꧂'), findsOneWidget);
  });
}
