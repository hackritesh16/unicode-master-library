import 'package:sqflite/sqflite.dart';

import '../core/unicode/code_point.dart';
import '../core/unicode/code_point_class.dart';
import 'unicode_explorer_repository.dart';

/// One Unicode block with how many of its code points have a UnicodeData.txt
/// entry (explicit rows plus First/Last ranges such as CJK or private use).
class BlockSummary {
  const BlockSummary({
    required this.name,
    required this.start,
    required this.end,
    required this.assignedCount,
  });

  final String name;
  final int start;
  final int end;
  final int assignedCount;

  /// Number of code points the block spans, assigned or not.
  int get size => end - start + 1;

  String get range => '${formatCodePoint(start)}..${formatCodePoint(end)}';
}

/// Paginated browsing and classification queries over the imported UCD.
///
/// Every list method is paginated (never loads the whole database) and
/// returns characters ordered by code point. [maxAge] is the Unicode version
/// filter: pass a version such as `6.1` to hide characters added after it.
/// Versions are `major.minor` numbers, so numeric comparison follows release
/// order (1.1 < 6.1 < 10.0).
class UnicodeLibraryRepository {
  UnicodeLibraryRepository(this.db);

  final Database db;

  static const int maxPageSize = 500;

  static const String _columns =
      'c.cp, c.name, c.category, c.block, c.script, c.age, c.combining_class';

  /// All blocks in code point order, with assigned counts.
  Future<List<BlockSummary>> listBlocks() async {
    final rows = await db.rawQuery('''
      SELECT b.name AS name, b.start AS start, b.end_cp AS end_cp,
        (SELECT COUNT(*) FROM characters c
           WHERE c.cp BETWEEN b.start AND b.end_cp)
        + COALESCE((
            SELECT SUM(MIN(r.end_cp, b.end_cp) - MAX(r.start, b.start) + 1)
            FROM char_ranges r
            WHERE r.start <= b.end_cp AND r.end_cp >= b.start
          ), 0) AS assigned
      FROM blocks b
      ORDER BY b.start ASC
    ''');
    return rows
        .map(
          (row) => BlockSummary(
            name: row['name']! as String,
            start: row['start']! as int,
            end: row['end_cp']! as int,
            assignedCount: row['assigned']! as int,
          ),
        )
        .toList();
  }

  /// Distinct Unicode versions present in the age data, oldest first. Feeds
  /// the version filter choices.
  Future<List<String>> availableAgeVersions() async {
    final rows = await db.rawQuery(
      'SELECT DISTINCT version FROM ages ORDER BY CAST(version AS REAL) ASC',
    );
    return rows.map((row) => row['version']! as String).toList();
  }

  Future<List<ExplorerEntry>> pageByBlock(
    String blockName, {
    int offset = 0,
    int limit = 100,
    String? maxAge,
  }) =>
      _page('block', blockName, offset, limit, maxAge);

  /// [category] is the two-letter general category, for example `Mn`.
  Future<List<ExplorerEntry>> pageByCategory(
    String category, {
    int offset = 0,
    int limit = 100,
    String? maxAge,
  }) =>
      _page('category', category, offset, limit, maxAge);

  Future<List<ExplorerEntry>> pageByScript(
    String script, {
    int offset = 0,
    int limit = 100,
    String? maxAge,
  }) =>
      _page('script', script, offset, limit, maxAge);

  /// [combiningClass] is the canonical combining class, for example 230
  /// (above) or 220 (below).
  Future<List<ExplorerEntry>> pageByCombiningClass(
    int combiningClass, {
    int offset = 0,
    int limit = 100,
    String? maxAge,
  }) =>
      _page('combining_class', combiningClass, offset, limit, maxAge);

  Future<List<ExplorerEntry>> _page(
    String column,
    Object value,
    int offset,
    int limit,
    String? maxAge,
  ) async {
    if (offset < 0) {
      throw ArgumentError.value(offset, 'offset', 'must not be negative');
    }
    if (limit < 1 || limit > maxPageSize) {
      throw ArgumentError.value(limit, 'limit', 'must be 1..$maxPageSize');
    }
    final args = <Object?>[value];
    var ageClause = '';
    if (maxAge != null) {
      final parsed = double.tryParse(maxAge);
      if (parsed == null) {
        throw ArgumentError.value(
          maxAge,
          'maxAge',
          'not a Unicode version such as 6.1',
        );
      }
      ageClause = ' AND c.age IS NOT NULL AND CAST(c.age AS REAL) <= ?';
      args.add(parsed);
    }
    args.add(limit);
    args.add(offset);
    // [column] only ever receives one of the fixed names above.
    final rows = await db.rawQuery(
      'SELECT $_columns FROM characters c WHERE c.$column = ?$ageClause '
      'ORDER BY c.cp ASC LIMIT ? OFFSET ?',
      args,
    );
    return rows.map(ExplorerEntry.fromCharacter).toList();
  }

  Future<bool> _isAssigned(int cp) async {
    final explicit = await db.query(
      'characters',
      columns: ['cp'],
      where: 'cp = ?',
      whereArgs: [cp],
      limit: 1,
    );
    if (explicit.isNotEmpty) {
      return true;
    }
    final ranges = await db.query(
      'char_ranges',
      columns: ['start'],
      where: 'start <= ? AND end_cp >= ?',
      whereArgs: [cp, cp],
      limit: 1,
    );
    return ranges.isNotEmpty;
  }

  /// Classifies any code point from 0 to 10FFFF using the database.
  Future<CodePointClass> classify(int cp) async {
    if (cp < 0 || cp > maxCodePoint) {
      throw RangeError.range(cp, 0, maxCodePoint, 'cp');
    }
    return classifyCodePoint(cp, isAssigned: await _isAssigned(cp));
  }

  /// Detail map for any code point. For an explicit character it contains
  /// every database column (name, category, decomposition, case mappings,
  /// block, script, age and so on) plus `aliases` and `properties`. For
  /// range members and unassigned code points only what is known is set.
  /// Always adds `code`, `utf8`, `utf16`, `class` and `isRange`. `utf8` and
  /// `utf16` are empty for surrogates.
  Future<Map<String, Object?>> detail(int cp) async {
    if (cp < 0 || cp > maxCodePoint) {
      throw RangeError.range(cp, 0, maxCodePoint, 'cp');
    }
    final scalar = isUnicodeScalar(cp);
    final common = <String, Object?>{
      'code': formatCodePoint(cp),
      'utf8': scalar ? utf8Hex(cp) : '',
      'utf16': scalar ? utf16Hex(cp) : '',
    };
    final explicit = await UnicodeExplorerRepository(db).details(cp);
    if (explicit != null) {
      return {
        ...explicit,
        ...common,
        'class': classifyCodePoint(cp, isAssigned: true),
        'isRange': false,
      };
    }
    final ranges = await db.query(
      'char_ranges',
      where: 'start <= ? AND end_cp >= ?',
      whereArgs: [cp, cp],
      limit: 1,
    );
    final inRange = ranges.isNotEmpty;
    return {
      'cp': cp,
      if (inRange) 'name': ranges.first['name'],
      if (inRange) 'category': ranges.first['category'],
      ...common,
      'class': classifyCodePoint(cp, isAssigned: inRange),
      'isRange': inRange,
    };
  }
}
