import 'package:sqflite/sqflite.dart';

import '../core/unicode/code_point.dart';

/// A character row returned by the Explorer. Range rows represent Unicode
/// ranges that are intentionally not expanded in the database.
class ExplorerEntry {
  const ExplorerEntry({
    required this.codePoint,
    required this.name,
    this.category,
    this.block,
    this.script,
    this.age,
    this.combiningClass = 0,
    this.isRange = false,
  });

  final int codePoint;
  final String name;
  final String? category;
  final String? block;
  final String? script;
  final String? age;
  final int combiningClass;
  final bool isRange;

  String get code => formatCodePoint(codePoint);

  factory ExplorerEntry.fromCharacter(Map<String, Object?> row) =>
      ExplorerEntry(
        codePoint: row['cp']! as int,
        name: row['name']! as String,
        category: row['category'] as String?,
        block: row['block'] as String?,
        script: row['script'] as String?,
        age: row['age'] as String?,
        combiningClass: row['combining_class'] as int? ?? 0,
      );

  factory ExplorerEntry.fromRange(Map<String, Object?> row, int cp) =>
      ExplorerEntry(
        codePoint: cp,
        name: row['name'] as String? ?? 'Unicode range',
        category: row['category'] as String?,
        isRange: true,
      );
}

/// Read-only search API over the imported Unicode Character Database.
class UnicodeExplorerRepository {
  const UnicodeExplorerRepository(this.db);

  final Database db;

  Future<List<ExplorerEntry>> search(String rawQuery, {int limit = 120}) async {
    final query = rawQuery.trim();
    if (query.isEmpty) {
      final rows = await db.query(
        'characters',
        columns: ['cp', 'name', 'category', 'block', 'script', 'age',
          'combining_class'],
        orderBy: 'cp ASC',
        limit: limit,
      );
      return rows.map(ExplorerEntry.fromCharacter).toList();
    }

    final hasPrefix = query.toLowerCase().startsWith('u+') ||
        query.toLowerCase().startsWith('0x');
    final hexMatch = RegExp(r'^[0-9a-fA-F]+').matchAsPrefix(query)?.group(0);
    final isBareHexCode = query.length > 1 && hexMatch == query;
    final explicitCp = hasPrefix || isBareHexCode
        ? tryParseCodePointQuery(query)
        : null;
    // Prefer a literal character for one-character input such as "A".
    final typedRune = query.runes.length == 1 ? query.runes.first : null;
    final cp = explicitCp ?? typedRune;
    if (cp != null && isUnicodeScalar(cp)) {
      final rows = await db.query(
        'characters',
        columns: ['cp', 'name', 'category', 'block', 'script', 'age',
          'combining_class'],
        where: 'cp = ?',
        whereArgs: [cp],
        limit: 1,
      );
      if (rows.isNotEmpty) {
        return [ExplorerEntry.fromCharacter(rows.first)];
      }
      final ranges = await db.query(
        'char_ranges',
        columns: ['name', 'category'],
        where: 'start <= ? AND end_cp >= ?',
        whereArgs: [cp, cp],
        limit: 1,
      );
      return ranges.isEmpty
          ? const []
          : [ExplorerEntry.fromRange(ranges.first, cp)];
    }

    final pattern = '%$query%';
    final rows = await db.rawQuery(
      '''
      SELECT c.cp, c.name, c.category, c.block, c.script, c.age,
             c.combining_class
      FROM characters c
      WHERE c.name LIKE ? COLLATE NOCASE
         OR c.block LIKE ? COLLATE NOCASE
         OR c.script LIKE ? COLLATE NOCASE
         OR c.category LIKE ? COLLATE NOCASE
         OR EXISTS (
           SELECT 1 FROM name_aliases a
           WHERE a.cp = c.cp AND a.alias LIKE ? COLLATE NOCASE
         )
      ORDER BY
        CASE WHEN c.name = ? COLLATE NOCASE THEN 0 ELSE 1 END,
        c.cp ASC
      LIMIT ?
      ''',
      [pattern, pattern, pattern, pattern, pattern, query, limit],
    );
    return rows.map(ExplorerEntry.fromCharacter).toList();
  }

  Future<Map<String, Object?>?> details(int cp) async {
    final rows = await db.query(
      'characters',
      where: 'cp = ?',
      whereArgs: [cp],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final row = rows.first;
    final aliases = await db.query(
      'name_aliases',
      columns: ['alias', 'type'],
      where: 'cp = ?',
      whereArgs: [cp],
      orderBy: 'alias ASC',
    );
    final properties = await db.query(
      'properties',
      columns: ['name', 'source'],
      where: 'start <= ? AND end_cp >= ?',
      whereArgs: [cp, cp],
      orderBy: 'name ASC',
    );
    return {
      ...row,
      'aliases': aliases,
      'properties': properties,
      'utf8': isUnicodeScalar(cp) ? utf8Hex(cp) : '',
    };
  }
}
