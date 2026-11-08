import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:unicode_master_library/database/unicode_explorer_repository.dart';
import 'package:unicode_master_library/database/unicode_importer.dart';
import 'package:unicode_master_library/database/unicode_schema.dart';

import '../fixtures/ucd_fixture.dart';

void main() {
  sqfliteFfiInit();

  late Database db;
  late UnicodeExplorerRepository explorer;

  setUp(() async {
    db = await openUnicodeDatabase(
      path: inMemoryDatabasePath,
      factory: databaseFactoryFfi,
    );
    await UnicodeImporter(db).importBundle(fixtureBundle);
    explorer = UnicodeExplorerRepository(db);
  });

  tearDown(() async => db.close());

  test('empty query returns a bounded code point list', () async {
    final results = await explorer.search('', limit: 3);
    expect(results, hasLength(3));
    expect(results.first.codePoint, 0x0);
  });

  test('searches character names without case sensitivity', () async {
    final results = await explorer.search('latin capital letter a');
    expect(results, hasLength(1));
    expect(results.single.codePoint, 0x41);
    expect(results.single.name, 'LATIN CAPITAL LETTER A');
  });

  test('searches by block and script', () async {
    final devanagari = await explorer.search('Devanagari');
    expect(devanagari.map((entry) => entry.codePoint), contains(0x905));
    expect(devanagari, hasLength(1));

    // A block query correctly returns every fixture character in Basic Latin,
    // not just the first result.
    final basicLatin = await explorer.search('Basic Latin');
    expect(basicLatin.map((entry) => entry.codePoint), containsAll([0x0, 0x41]));
    expect(basicLatin, hasLength(2));
  });

  test('accepts U+ notation and literal characters', () async {
    expect((await explorer.search('U+0905')).single.codePoint, 0x905);
    expect((await explorer.search('अ')).single.codePoint, 0x905);
    expect((await explorer.search('A')).single.codePoint, 0x41);
  });

  test('searches by general category', () async {
    expect((await explorer.search('Lu')).single.codePoint, 0x41);
  });

  test('finds unexpanded Unicode ranges by code point', () async {
    final results = await explorer.search('U+3400');
    expect(results, hasLength(1));
    expect(results.single.isRange, isTrue);
    expect(results.single.name, 'CJK Ideograph Extension A');
  });

  test('returns no result for unassigned code point', () async {
    expect(await explorer.search('U+10FFFF'), isEmpty);
  });

  test('loads aliases, properties and UTF-8 details', () async {
    final details = await explorer.details(0x905);
    expect(details, isNotNull);
    expect(details!['utf8'], 'E0 A4 85');
    expect(details['aliases'], isA<List>());
    expect(details['properties'], isA<List>());
  });
}
