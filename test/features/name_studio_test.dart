import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unicode_master_library/core/text_design/design_engine.dart';
import 'package:unicode_master_library/core/text_design/design_types.dart';
import 'package:unicode_master_library/core/text_design/text_fonts.dart';
import 'package:unicode_master_library/features/name_studio/presentation/design_card.dart';
import 'package:unicode_master_library/features/name_studio/presentation/name_studio_screen.dart';
import 'package:unicode_master_library/services/library_storage_service.dart';

List<String> expectedDesigns(String name, int seed, {int count = 20}) {
  return DesignEngine.generate(
    DesignRequest(name: name, count: count, seed: seed),
  ).designs.map((design) => design.text).toList();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  // The results are a lazy list: use a tall viewport so every card is built.
  void tallView(WidgetTester tester) {
    tester.view.physicalSize = const Size(900, 5000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<void> pumpStudio(WidgetTester tester, {int seed = 5}) async {
    tallView(tester);
    await tester.pumpWidget(
      MaterialApp(home: NameStudioScreen(seed: seed)),
    );
    await tester.pump();
  }

  testWidgets('shows the designs the engine generates for the name',
      (tester) async {
    await pumpStudio(tester);
    expect(find.text('Name Studio'), findsOneWidget);
    expect(find.text('Generate 20 designs'), findsOneWidget);

    final expected = expectedDesigns('Sefali', 5);
    expect(expected.length, 20);
    expect(find.byType(DesignCard), findsNWidgets(20));
    for (final text in expected) {
      expect(find.text(text), findsOneWidget, reason: text);
    }
  });

  testWidgets('Generate replaces the designs, count selector changes label',
      (tester) async {
    await pumpStudio(tester);
    await tester.tap(find.text('50'));
    await tester.pump();
    expect(find.text('Generate 50 designs'), findsOneWidget);

    await tester.tap(find.text('Generate 50 designs'));
    await tester.pump();
    // The second round uses seed + 1 and a count of 50.
    final expected = expectedDesigns('Sefali', 6, count: 50);
    expect(find.text(expected.first), findsOneWidget);
  });

  testWidgets('tapping copy puts the exact design on the clipboard',
      (tester) async {
    final clipboard = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          clipboard.add((call.arguments as Map)['text'] as String);
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null),
    );

    await pumpStudio(tester);
    await tester.tap(find.byTooltip('Copy').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(clipboard, [expectedDesigns('Sefali', 5).first]);
    expect(find.text('Copied'), findsOneWidget);

    final prefs = await SharedPreferences.getInstance();
    final history = LibraryStorageService(prefs).getHistory();
    expect(history.single.content, expectedDesigns('Sefali', 5).first);
    expect(history.single.kind, 'name-design');
  });

  testWidgets('favorite button saves and removes the design', (tester) async {
    await pumpStudio(tester);
    await tester.tap(find.byTooltip('Add favorite').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    final prefs = await SharedPreferences.getInstance();
    final storage = LibraryStorageService(prefs);
    expect(storage.getFavorites().single.content,
        expectedDesigns('Sefali', 5).first);
    expect(find.byTooltip('Remove favorite'), findsOneWidget);

    await tester.tap(find.byTooltip('Remove favorite'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(storage.getFavorites(), isEmpty);
  });

  testWidgets('font styles tab styles the name live', (tester) async {
    await pumpStudio(tester);
    await tester.tap(find.text('Font styles'));
    await tester.pump();
    expect(find.text(TextFonts.bold.apply('Sefali')), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'NK Player');
    await tester.pump();
    expect(find.text(TextFonts.bold.apply('NK Player')), findsOneWidget);
    expect(find.text(TextFonts.script.apply('NK Player')), findsOneWidget);
  });

  testWidgets('details sheet shows code points and compatibility advice',
      (tester) async {
    await pumpStudio(tester);
    await tester.tap(find.byTooltip('Details').first);
    await tester.pumpAndSettle();
    expect(find.text('CODE POINTS'), findsOneWidget);
    expect(find.text('COMPATIBILITY'), findsOneWidget);
    expect(find.textContaining('U+'), findsWidgets);
    expect(find.textContaining('other apps and fonts may move'), findsNothing);
    expect(find.textContaining('Other apps and fonts may move'), findsOneWidget);
  });

  testWidgets('empty name shows no designs', (tester) async {
    tallView(tester);
    await tester.pumpWidget(
      const MaterialApp(home: NameStudioScreen(initialName: '', seed: 1)),
    );
    await tester.pump();
    expect(find.byType(DesignCard), findsNothing);
  });
}
