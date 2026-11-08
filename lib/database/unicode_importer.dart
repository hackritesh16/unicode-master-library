import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../core/unicode/code_point.dart';
import '../core/unicode/ucd_bundle.dart';
import 'unicode_schema.dart';

/// Progress of an import: a stage label and a 0..1 fraction.
class ImportProgress {
  const ImportProgress(this.stage, this.fraction);

  final String stage;
  final double fraction;
}

String? _nullIfEmpty(String value) => value.isEmpty ? null : value;

/// Writes parsed UCD data into the SQLite database.
///
/// The whole import runs in one transaction: if anything fails, the previous
/// data stays intact (important for optional updates on an offline-first app).
class UnicodeImporter {
  UnicodeImporter(this._db);

  final Database _db;

  /// Parses [bundle] in a background isolate, then imports it.
  Future<void> importBundle(
    UcdBundle bundle, {
    String? sourceUrl,
    void Function(ImportProgress)? onProgress,
  }) async {
    onProgress?.call(const ImportProgress('Parsing Unicode data', 0));
    final parsed = await compute(parseUcdBundle, bundle);
    await importParsed(parsed, sourceUrl: sourceUrl, onProgress: onProgress);
  }

  Future<void> importParsed(
    ParsedUcd p, {
    String? sourceUrl,
    void Function(ImportProgress)? onProgress,
  }) async {
    void report(String stage, double fraction) =>
        onProgress?.call(ImportProgress(stage, fraction));

    await _db.transaction((txn) async {
      report('Clearing old data', 0.1);
      for (final table in UnicodeSchema.dataTables) {
        await txn.delete(table);
      }

      report('Importing characters', 0.2);
      var batch = txn.batch();
      for (final c in p.unicodeData.characters) {
        batch.insert('characters', {
          'cp': c.cp,
          'name': c.name,
          'category': c.generalCategory,
          'combining_class': c.combiningClass,
          'bidi_class': c.bidiClass,
          'decomposition': c.decomposition,
          'decimal_value': _nullIfEmpty(c.decimalValue),
          'digit_value': _nullIfEmpty(c.digitValue),
          'numeric_value': _nullIfEmpty(c.numericValue),
          'bidi_mirrored': c.bidiMirrored ? 1 : 0,
          'uppercase_mapping': _nullIfEmpty(c.uppercaseMapping),
          'lowercase_mapping': _nullIfEmpty(c.lowercaseMapping),
          'titlecase_mapping': _nullIfEmpty(c.titlecaseMapping),
        });
      }
      for (final r in p.unicodeData.ranges) {
        batch.insert('char_ranges', {
          'start': r.start,
          'end_cp': r.end,
          'name': r.name,
          'category': r.generalCategory,
          'combining_class': r.combiningClass,
          'bidi_class': r.bidiClass,
        });
      }
      for (final a in p.nameAliases) {
        batch.insert('name_aliases', {
          'cp': a.cp,
          'alias': a.alias,
          'type': a.type,
        });
      }
      await batch.commit(noResult: true);

      report('Importing blocks, scripts and ages', 0.45);
      batch = txn.batch();
      for (final r in p.blocks) {
        batch.insert('blocks', {
          'start': r.start,
          'end_cp': r.end,
          'name': r.value,
        });
      }
      for (final r in p.scripts) {
        batch.insert('scripts', {
          'start': r.start,
          'end_cp': r.end,
          'name': r.value,
        });
      }
      for (final r in p.ages) {
        batch.insert('ages', {
          'start': r.start,
          'end_cp': r.end,
          'version': r.value,
        });
      }
      for (final r in p.eastAsianWidths) {
        batch.insert('east_asian_widths', {
          'start': r.start,
          'end_cp': r.end,
          'value': r.value,
        });
      }
      for (final r in p.properties) {
        batch.insert('properties', {
          'start': r.start,
          'end_cp': r.end,
          'name': r.name,
          'source': r.source,
        });
      }
      await batch.commit(noResult: true);

      report('Importing emoji sequences', 0.6);
      batch = txn.batch();
      for (final e in p.emojiSequences) {
        batch.insert('emoji_sequences', {
          'sequence': e.sequence,
          'cps': e.codePoints
              .map((cp) => cp.toRadixString(16).toUpperCase())
              .join(' '),
          'cp_count': e.codePoints.length,
          'status': e.status,
          'grp': e.group,
          'subgroup': e.subgroup,
          'name': e.name,
          'since': e.since,
        });
      }
      await batch.commit(noResult: true);

      report('Linking blocks, scripts and ages to characters', 0.75);
      batch = txn.batch();
      void link(String column, int start, int end, String value) {
        batch.update(
          'characters',
          {column: value},
          where: 'cp BETWEEN ? AND ?',
          whereArgs: [start, end],
        );
      }

      for (final r in p.blocks) {
        link('block', r.start, r.end, r.value);
      }
      for (final r in p.scripts) {
        link('script', r.start, r.end, r.value);
      }
      for (final r in p.ages) {
        link('age', r.start, r.end, r.value);
      }
      for (final r in p.eastAsianWidths) {
        link('east_asian_width', r.start, r.end, r.value);
      }
      await batch.commit(noResult: true);

      // Control characters are named `<control>` in UnicodeData.txt; use the
      // first `control` alias from NameAliases.txt as their display name.
      await txn.rawUpdate(
        "UPDATE characters SET name = ("
        "SELECT alias FROM name_aliases "
        "WHERE name_aliases.cp = characters.cp AND name_aliases.type = 'control' "
        "ORDER BY rowid LIMIT 1) "
        "WHERE name = '<control>' AND EXISTS ("
        "SELECT 1 FROM name_aliases a "
        "WHERE a.cp = characters.cp AND a.type = 'control')",
      );

      report('Saving version information', 0.95);
      final meta = <String, String>{
        'unicode_version': p.version,
        'schema_version': UnicodeSchema.version.toString(),
        'imported_at': DateTime.now().toUtc().toIso8601String(),
        if (sourceUrl != null) 'source_url': sourceUrl,
      };
      for (final entry in meta.entries) {
        await txn.insert('meta', {
          'key': entry.key,
          'value': entry.value,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
    report('Done', 1);
  }
}

/// Convenience lookup used by diagnostics and tests.
Future<String?> readMeta(Database db, String key) async {
  final rows = await db.query('meta', where: 'key = ?', whereArgs: [key]);
  return rows.isEmpty ? null : rows.first['value'] as String;
}

/// Human-readable `U+XXXX` for a stored code point (re-exported helper).
String describeCodePoint(int cp) => formatCodePoint(cp);
