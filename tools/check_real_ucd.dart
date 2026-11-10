import 'dart:io';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:unicode_master_library/core/unicode/ucd_bundle.dart';
import 'package:unicode_master_library/core/unicode/ucd_parsers.dart';
import 'package:unicode_master_library/database/unicode_importer.dart';
import 'package:unicode_master_library/database/unicode_schema.dart';

Future<int> count(Database db, String table) async =>
    Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $table')) ?? 0;

Future<void> main() async {
  const directory = 'build/ucd';
  final names = [
    'UnicodeData.txt',
    'Blocks.txt',
    'Scripts.txt',
    'DerivedAge.txt',
    'PropList.txt',
    'DerivedCoreProperties.txt',
    'EastAsianWidth.txt',
    'NameAliases.txt',
    'emoji-data.txt',
    'emoji-test.txt',
    'ReadMe.txt',
  ];
  final files = <String, String>{};
  for (final name in names) {
    final file = File('$directory/$name');
    if (await file.exists()) {
      files[name] = await file.readAsString();
    }
  }

  final readme = files['ReadMe.txt'];
  if (readme == null) {
    throw StateError('Missing official UCD ReadMe.txt');
  }
  final version = parseUcdVersion(readme);
  if (version == null) {
    throw StateError('Could not detect official Unicode version');
  }
  final bundle = UcdBundle(version: version, files: files);
  final parsed = parseUcdBundle(bundle);

  sqfliteFfiInit();
  final db = await openUnicodeDatabase(
    path: inMemoryDatabasePath,
    factory: databaseFactoryFfi,
  );
  try {
    await UnicodeImporter(db).importParsed(parsed, sourceUrl: 'https://www.unicode.org/Public/UCD/latest/');
    final characters = await count(db, 'characters');
    final ranges = await count(db, 'char_ranges');
    final blocks = await count(db, 'blocks');
    final scripts = await count(db, 'scripts');
    final ages = await count(db, 'ages');
    final emoji = await count(db, 'emoji_sequences');
    final aliases = await count(db, 'name_aliases');

    if (characters <= 30000) {
      throw StateError('Expected >30,000 explicit characters; found $characters');
    }
    if (ranges < 10 || blocks < 200 || scripts < 100 || ages < 100) {
      throw StateError('Unexpectedly small UCD tables: ranges=$ranges blocks=$blocks scripts=$scripts ages=$ages');
    }
    if (aliases < 400) {
      throw StateError('Unexpectedly small NameAliases table: $aliases');
    }
    if (emoji < 3000) {
      throw StateError('Expected thousands of emoji sequences; found $emoji');
    }
    final versionInDb = await readMeta(db, 'unicode_version');
    if (versionInDb != version) {
      throw StateError('Imported version mismatch: $versionInDb != $version');
    }
    final requiredBlocks = await db.query(
      'blocks',
      where: 'name IN (?, ?, ?)',
      whereArgs: ['Basic Latin', 'Combining Diacritical Marks', 'Arrows'],
    );
    if (requiredBlocks.length != 3) {
      throw StateError('Expected Basic Latin, Combining Diacritical Marks and Arrows blocks');
    }
    final combining = await db.query(
      'characters',
      where: 'cp = ? AND category = ? AND combining_class = ?',
      whereArgs: [0x0307, 'Mn', 230],
    );
    if (combining.length != 1) {
      throw StateError('Combining dot above failed real-data verification');
    }
    stdout.writeln('UCD $version passed real-data validation.');
    stdout.writeln('characters=$characters ranges=$ranges aliases=$aliases blocks=$blocks scripts=$scripts ages=$ages emojiSequences=$emoji');
  } finally {
    await db.close();
  }
}
