import 'package:sqflite/sqflite.dart';

/// SQLite schema of the Unicode database.
///
/// Design notes:
/// - `characters` only holds explicit UnicodeData.txt rows. Large
///   `<..., First>`/`<..., Last>` ranges (CJK, Hangul, private use,
///   surrogates) live in `char_ranges` and are never expanded per code point.
/// - A code point absent from both tables is unassigned.
/// - block/script/age/east_asian_width are denormalised onto `characters` for
///   fast filtering; the range tables stay authoritative for any code point.
abstract final class UnicodeSchema {
  static const int version = 1;

  /// Tables cleared and refilled on every import (everything except `meta`).
  static const List<String> dataTables = [
    'characters',
    'char_ranges',
    'name_aliases',
    'blocks',
    'scripts',
    'ages',
    'east_asian_widths',
    'properties',
    'emoji_sequences',
  ];

  static const List<String> createStatements = [
    '''
CREATE TABLE meta (
  key TEXT PRIMARY KEY NOT NULL,
  value TEXT NOT NULL
)''',
    '''
CREATE TABLE characters (
  cp INTEGER PRIMARY KEY NOT NULL,
  name TEXT NOT NULL,
  category TEXT NOT NULL,
  combining_class INTEGER NOT NULL,
  bidi_class TEXT NOT NULL,
  decomposition TEXT NOT NULL,
  decimal_value TEXT,
  digit_value TEXT,
  numeric_value TEXT,
  bidi_mirrored INTEGER NOT NULL,
  uppercase_mapping TEXT,
  lowercase_mapping TEXT,
  titlecase_mapping TEXT,
  block TEXT,
  script TEXT,
  age TEXT,
  east_asian_width TEXT
)''',
    '''
CREATE TABLE char_ranges (
  start INTEGER NOT NULL,
  end_cp INTEGER NOT NULL,
  name TEXT NOT NULL,
  category TEXT NOT NULL,
  combining_class INTEGER NOT NULL,
  bidi_class TEXT NOT NULL
)''',
    '''
CREATE TABLE name_aliases (
  cp INTEGER NOT NULL,
  alias TEXT NOT NULL,
  type TEXT NOT NULL
)''',
    'CREATE TABLE blocks (start INTEGER NOT NULL, end_cp INTEGER NOT NULL, name TEXT NOT NULL)',
    'CREATE TABLE scripts (start INTEGER NOT NULL, end_cp INTEGER NOT NULL, name TEXT NOT NULL)',
    'CREATE TABLE ages (start INTEGER NOT NULL, end_cp INTEGER NOT NULL, version TEXT NOT NULL)',
    'CREATE TABLE east_asian_widths (start INTEGER NOT NULL, end_cp INTEGER NOT NULL, value TEXT NOT NULL)',
    '''
CREATE TABLE properties (
  start INTEGER NOT NULL,
  end_cp INTEGER NOT NULL,
  name TEXT NOT NULL,
  source TEXT NOT NULL
)''',
    '''
CREATE TABLE emoji_sequences (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  sequence TEXT NOT NULL,
  cps TEXT NOT NULL,
  cp_count INTEGER NOT NULL,
  status TEXT NOT NULL,
  grp TEXT NOT NULL,
  subgroup TEXT NOT NULL,
  name TEXT NOT NULL,
  since TEXT NOT NULL
)''',
    'CREATE INDEX idx_characters_name ON characters(name)',
    'CREATE INDEX idx_characters_category ON characters(category)',
    'CREATE INDEX idx_characters_block ON characters(block)',
    'CREATE INDEX idx_characters_script ON characters(script)',
    'CREATE INDEX idx_characters_ccc ON characters(combining_class)',
    'CREATE INDEX idx_char_ranges_start ON char_ranges(start)',
    'CREATE INDEX idx_name_aliases_cp ON name_aliases(cp)',
    'CREATE INDEX idx_blocks_start ON blocks(start)',
    'CREATE INDEX idx_scripts_start ON scripts(start)',
    'CREATE INDEX idx_ages_start ON ages(start)',
    'CREATE INDEX idx_eaw_start ON east_asian_widths(start)',
    'CREATE INDEX idx_properties_start ON properties(start)',
    'CREATE INDEX idx_properties_name ON properties(name)',
    'CREATE INDEX idx_emoji_name ON emoji_sequences(name)',
    'CREATE INDEX idx_emoji_group ON emoji_sequences(grp)',
  ];
}

/// Opens (creating if needed) the Unicode database at [path].
/// Pass a [factory] (e.g. sqflite_common_ffi) to use it outside Android/iOS.
Future<Database> openUnicodeDatabase({
  required String path,
  DatabaseFactory? factory,
}) {
  final f = factory ?? databaseFactory;
  return f.openDatabase(
    path,
    options: OpenDatabaseOptions(
      version: UnicodeSchema.version,
      onCreate: (db, version) async {
        for (final statement in UnicodeSchema.createStatements) {
          await db.execute(statement);
        }
      },
    ),
  );
}
