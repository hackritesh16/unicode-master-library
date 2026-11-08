import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unicode_master_library/features/name_studio/presentation/name_studio_screen.dart';
void main() {
  testWidgets('Name Studio previews styles and accepts edited text', (tester) async {
    await tester.view.physicalSize = const Size(900, 1600));
    await tester.view.devicePixelRatio = 1);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(home: NameStudioScreen()));
    expect(find.text('Name Studio'), findsOneWidget);
    expect(find.text('Mathematical Bold'), findsOneWidget);
    expect(find.text('𝐑𝐚𝐧𝐣𝐞𝐞𝐭'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'NK Player');
    await tester.pump();
    expect(find.text('𝐍𝐊 𝐏𝐥𝐚𝐲𝐞𝐫'), findsOneWidget);
  });
}
