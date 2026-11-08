import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:unicode_master_library/core/unicode/ucd_bundle.dart';
import 'package:unicode_master_library/database/unicode_importer.dart';
import 'package:unicode_master_library/database/unicode_schema.dart';

import '../fixtures/ucd_fixture.dart';

Future<int> _count(Database db, String table) async =>
    Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $table')) ??
    0;

Future<Map<String, Object?>> _char(Database db, int cp) async {
  final rows = await db.query('characters', where: 'cp = ?', whereArgs: [cp]);
  expect(rows, hasLength(1), reason: 'character $cp should exist');
  return rows.first;
}

void main() {
  sqfliteFfiInit();

  late Database db;
  late ParsedUcd parsed;

  setUp(() async {
    db = await openUnicodeDatabase(
      path: inMemoryDatabasePath,
      factory: databaseFactoryFfi,
    );
    parsed = parseUcdBundle(fixtureBundle);
  });

  tearDown(() async {
    await db.close();
  });

  test('imports all tables', () async {
    await UnicodeImporter(db).importParsed(parsed);

    expect(await _count(db, 'characters'), 5);
    expect(await _count(db, 'char_ranges'), 2);
    expect(await _count(db, 'name_aliases'), 2);
    expect(await _count(db, 'blocks'), 4);
    expect(await _count(db, 'scripts'), 5);
    expect(await _count(db, 'ages'), 5);
    expect(await _count(db, 'east_asian_widths'), 3);
    expect(await _count(db, 'properties'), 5);
    expect(await _count(db, 'emoji_sequences'), 3);
  });

  test('does not expand First/Last ranges into characters', () async {
    await UnicodeImporter(db).importParsed(parsed);
    final inCjkRange = await db.query(
      'characters',
      where: 'cp BETWEEN ? AND ?',
      whereArgs: [0x3400, 0x4DBF],
    );
    expect(inCjkRange, isEmpty);
    final ranges = await db.query('char_ranges', orderBy: 'start');
    expect(ranges.first['name'], 'CJK Ideograph Extension A');
    expect(ranges.last['category'], 'Co');
  });

  test('links block, script, age and width onto characters', () async {
    await UnicodeImporter(db).importParsed(parsed);

    final hindi = await _char(db, 0x0905);
    expect(hindi['block'], 'Devanagari');
    expect(hindi['script'], 'Devanagari');
    expect(hindi['age'], '1.1');
    expect(hindi['east_asian_width'], isNull);

    final mark = await _char(db, 0x0307);
    expect(mark['combining_class'], 230);
    expect(mark['script'], 'Inherited');
    expect(mark['block'], 'Combining Diacritical Marks');

    final a = await _char(db, 0x41);
    expect(a['block'], 'Basic Latin');
    expect(a['script'], 'Latin');
    expect(a['east_asian_width'], 'Na');

    final emoji = await _char(db, 0x1F600);
    expect(emoji['age'], '6.1');
    expect(emoji['east_asian_width'], 'W');
    expect(emoji['block'], 'Emoticons');
  });

  test('control characters get their alias as name', () async {
    await UnicodeImporter(db).importParsed(parsed);
    expect((await _char(db, 0))['name'], 'NULL');
  });

  test('stores emoji sequences with multi-code-point data intact', () async {
    await UnicodeImporter(db).importParsed(parsed);
    final rows = await db.query(
      'emoji_sequences',
      where: 'cps = ?',
      whereArgs: ['263A FE0F'],
    );
    expect(rows, hasLength(1));
    expect(rows.first['cp_count'], 2);
    expect(rows.first['status'], 'fully-qualified');
    expect(rows.first['grp'], 'Smileys & Emotion');
    expect(rows.first['subgroup'], 'face-smiling');
    expect((rows.first['sequence'] as String).runes.toList(), [
      0x263A,
      0xFE0F,
    ]);
  });

  test('writes version metadata', () async {
    await UnicodeImporter(db).importParsed(parsed, sourceUrl: 'test://ucd');
    expect(await readMeta(db, 'unicode_version'), '99.0.0');
    expect(await readMeta(db, 'schema_version'), '1');
    expect(await readMeta(db, 'source_url'), 'test://ucd');
    expect(await readMeta(db, 'imported_at'), isNotNull);
  });

  test('re-import replaces data instead of duplicating it', () async {
    final importer = UnicodeImporter(db);
    await importer.importParsed(parsed);
    await importer.importParsed(parsed);
    expect(await _count(db, 'characters'), 5);
    expect(await _count(db, 'blocks'), 4);
    expect(await _count(db, 'emoji_sequences'), 3);
  });

  test('failed import rolls back and keeps previous data', () async {
    final importer = UnicodeImporter(db);
    await importer.importParsed(parsed);

    // Two rows with the same primary key make the batch insert fail midway.
    final broken = ParsedUcd(
      version: '100.0.0',
      unicodeData: UnicodeDataParseResultFixture.duplicateKey(parsed),
      blocks: parsed.blocks,
      scripts: parsed.scripts,
      ages: parsed.ages,
      eastAsianWidths: parsed.eastAsianWidths,
      properties: parsed.properties,
      nameAliases: parsed.nameAliases,
      emojiSequences: parsed.emojiSequences,
    );

    await expectLater(importer.importParsed(broken), throwsA(anything));

    expect(await readMeta(db, 'unicode_version'), '99.0.0');
    expect(await _count(db, 'characters'), 5);
  });
}

/// Builds a UnicodeData result containing the same code point twice.
class UnicodeDataParseResultFixture {
  static dynamic duplicateKey(ParsedUcd parsed) {
    final chars = [...parsed.unicodeData.characters, parsed.unicodeData.characters.first];
    return _build(chars, parsed);
  }

  static dynamic _build(List chars, ParsedUcd parsed) {
    // Imported lazily to keep the helper compact.
    return _Result(
      List.of(chars.cast()),
      parsed.unicodeData.ranges,
    );
  }
}

class _Result implements dynamic {
  _Result(this.characters, this.ranges);
  final List characters;
  final List ranges;
}
