import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unicode_master_library/features/composer/presentation/composer_screen.dart';

Finder preview(String value) => find.byWidgetPredicate(
      (widget) => widget is SelectableText && widget.data == value,
    );

void main() {
  testWidgets('Composer updates preview when text and frame change',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ComposerScreen()));

    expect(find.text('Decorative Composer'), findsOneWidget);
    expect(preview('✦ Your Text ✦'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'NK Player');
    await tester.pump();
    expect(preview('✦ NK Player ✦'), findsOneWidget);

    await tester.ensureVisible(find.text('Royal'));
    await tester.tap(find.text('Royal'));
    await tester.pump();
    expect(preview('꧁༺ NK Player ༻꧂'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(1), '★');
    await tester.pump();
    expect(preview('★NK Player ༻꧂'), findsOneWidget);
  });
}
