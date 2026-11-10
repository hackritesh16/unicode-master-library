import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:unicode_master_library/core/unicode/code_point_class.dart';
import 'package:unicode_master_library/database/unicode_explorer_repository.dart';
import 'package:unicode_master_library/database/unicode_importer.dart';
import 'package:unicode_master_library/database/unicode_library_repository.dart';
import 'package:unicode_master_library/database/unicode_schema.dart';
import 'package:unicode_master_library/features/explorer/presentation/block_characters_screen.dart';
import 'package:unicode_master_library/features/explorer/presentation/blocks_screen.dart';
import 'package:unicode_master_library/providers/unicode_db_provider.dart';
import 'package:unicode_master_library/providers/unicode_library_provider.dart';

import '../fixtures/ucd_fixture.dart';

/// Lets real async work (the FFI SQLite isolate) finish, then rebuilds.
/// `pumpAndSettle` is not used because a loading spinner animates forever.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 40)),
    );
    await tester.pump(const Duration(milliseconds: 50));
  }
}

/// Opens an in-memory database filled from the fixture UCD files.
Future<Database> openFixtureDatabase(WidgetTester tester) async {
  late Database db;
  await tester.runAsync(() async {
    sqfliteFfiInit();
    db = await openUnicodeDatabase(
      path: inMemoryDatabasePath,
      factory: databaseFactoryFfi,
    );
    await UnicodeImporter(db).importBundle(fixtureBundle);
  });
  return db;
}

void main() {
  testWidgets('Blocks screen lists ranges and counts and filters by name',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          blockSummariesProvider.overrideWith(
            (ref) async => const [
              BlockSummary(
                name: 'Basic Latin',
                start: 0x0,
                end: 0x7F,
                assignedCount: 128,
              ),
              BlockSummary(
                name: 'Devanagari',
                start: 0x900,
                end: 0x97F,
                assignedCount: 2,
              ),
            ],
          ),
        ],
        child: const MaterialApp(home: BlocksScreen()),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Unicode Blocks'), findsOneWidget);
    expect(find.text('Basic Latin'), findsOneWidget);
    expect(find.text('U+0000..U+007F · 128 of 128 assigned'), findsOneWidget);
    expect(find.text('U+0900..U+097F · 2 of 128 assigned'), findsOneWidget);
    expect(find.text('2 of 2 blocks'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'deva');
    await tester.pump();
    expect(find.text('Basic Latin'), findsNothing);
    expect(find.text('Devanagari'), findsOneWidget);
    expect(find.text('1 of 2 blocks'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'U+0000');
    await tester.pump();
    expect(find.text('Basic Latin'), findsOneWidget);
    expect(find.text('Devanagari'), findsNothing);

    await tester.enterText(find.byType(TextField), 'no such block');
    await tester.pump();
    expect(find.text('No block matches that filter.'), findsOneWidget);
  });

  testWidgets('Blocks screen asks to install the database when it is empty',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          blockSummariesProvider.overrideWith(
            (ref) async => const <BlockSummary>[],
          ),
        ],
        child: const MaterialApp(home: BlocksScreen()),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.textContaining('Install the official Unicode database'),
        findsOneWidget);
    expect(find.text('Open Settings'), findsOneWidget);
  });

  testWidgets('Block page lists characters and applies the version filter',
      (tester) async {
    final db = await openFixtureDatabase(tester);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          unicodeDatabaseProvider.overrideWith((ref) async => db),
        ],
        child: const MaterialApp(
          home: BlockCharactersScreen(blockName: 'Emoticons'),
        ),
      ),
    );
    await settle(tester);

    expect(find.text('U+1F600..U+1F64F · 1 of 80 code points assigned'),
        findsOneWidget);
    expect(find.text('GRINNING FACE'), findsOneWidget);
    expect(find.text('All versions'), findsOneWidget);
    expect(find.text('Up to 1.1'), findsOneWidget);
    expect(find.text('Up to 6.1'), findsOneWidget);

    // GRINNING FACE was added in Unicode 6.1, so 1.1 hides it.
    await tester.tap(find.text('Up to 1.1'));
    await settle(tester);
    expect(find.text('GRINNING FACE'), findsNothing);
    expect(
      find.text('No characters in this block were added up to Unicode 1.1.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Up to 6.1'));
    await settle(tester);
    expect(find.text('GRINNING FACE'), findsOneWidget);

    await tester.tap(find.text('All versions'));
    await settle(tester);
    expect(find.text('GRINNING FACE'), findsOneWidget);

    await tester.runAsync(db.close);
  });

  testWidgets('Tapping a block opens its characters and a detail sheet',
      (tester) async {
    final db = await openFixtureDatabase(tester);
    final router = GoRouter(
      initialLocation: '/blocks',
      routes: [
        GoRoute(
          path: '/blocks',
          builder: (context, state) => const BlocksScreen(),
        ),
        GoRoute(
          path: '/block',
          builder: (context, state) => BlockCharactersScreen(
            blockName: state.uri.queryParameters['name'] ?? '',
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          unicodeDatabaseProvider.overrideWith((ref) async => db),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await settle(tester);

    expect(find.text('Basic Latin'), findsOneWidget);
    expect(find.text('Devanagari'), findsOneWidget);
    expect(find.text('U+0900..U+097F · 1 of 128 assigned'), findsOneWidget);

    await tester.tap(find.text('Devanagari'));
    await settle(tester);

    expect(find.text('DEVANAGARI LETTER A'), findsOneWidget);
    expect(find.text('U+0905'), findsOneWidget);

    await tester.tap(find.text('DEVANAGARI LETTER A'));
    await settle(tester);

    expect(find.text('Assigned'), findsOneWidget);
    expect(find.text('E0 A4 85'), findsOneWidget);
    expect(find.text('0905'), findsOneWidget);
    expect(find.text('Copy character'), findsOneWidget);

    await tester.runAsync(db.close);
  });

  group('displayGlyph', () {
    ExplorerEntry entry(int cp, String category) =>
        ExplorerEntry(codePoint: cp, name: 'TEST', category: category);

    test('plain letters are drawn as themselves', () {
      expect(displayGlyph(entry(0x41, 'Lu')), 'A');
    });

    test('combining marks sit on a dotted circle', () {
      expect(displayGlyph(entry(0x307, 'Mn')), '◌̇');
    });

    test('control and format characters have no glyph', () {
      expect(displayGlyph(entry(0x0, 'Cc')), isNull);
      expect(displayGlyph(entry(0x200D, 'Cf')), isNull);
    });

    test('surrogates have no glyph', () {
      expect(displayGlyph(entry(0xD800, 'Cs')), isNull);
    });

    test('class labels use readable wording', () {
      expect(codePointClassLabel(CodePointClass.assigned), 'Assigned');
      expect(codePointClassLabel(CodePointClass.privateUse), 'Private use');
      expect(codePointClassLabel(CodePointClass.noncharacter), 'Noncharacter');
    });
  });
}
