import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:unicode_master_library/core/unicode/code_point_class.dart';
import 'package:unicode_master_library/database/unicode_importer.dart';
import 'package:unicode_master_library/database/unicode_library_repository.dart';
import 'package:unicode_master_library/database/unicode_schema.dart';

import '../fixtures/ucd_fixture.dart';

void main() {
  sqfliteFfiInit();

  late Database db;
  late UnicodeLibraryRepository library;

  setUp(() async {
    db = await openUnicodeDatabase(
      path: inMemoryDatabasePath,
      factory: databaseFactoryFfi,
    );
    await UnicodeImporter(db).importBundle(fixtureBundle);
    library = UnicodeLibraryRepository(db);
  });

  tearDown(() async => db.close());

  group('listBlocks', () {
    test('lists blocks in code point order with assigned counts', () async {
      final blocks = await library.listBlocks();
      expect(blocks.map((b) => b.name), [
        'Basic Latin',
        'Combining Diacritical Marks',
        'Devanagari',
        'Emoticons',
      ]);
      final basicLatin = blocks.first;
      expect(basicLatin.assignedCount, 2);
      expect(basicLatin.size, 128);
      expect(basicLatin.range, 'U+0000..U+007F');
      expect(blocks[1].assignedCount, 1);
    });

    test('counts First/Last ranges, clipped to the block', () async {
      await db.insert('blocks', {
        'start': 0x3400,
        'end_cp': 0x4DBF,
        'name': 'Whole range block',
      });
      await db.insert('blocks', {
        'start': 0x4000,
        'end_cp': 0x4FFF,
        'name': 'Partial overlap block',
      });
      final blocks = await library.listBlocks();
      final whole = blocks.firstWhere((b) => b.name == 'Whole range block');
      final partial = blocks.firstWhere((b) => b.name == 'Partial overlap block');
      expect(whole.assignedCount, 0x4DBF - 0x3400 + 1);
      expect(partial.assignedCount, 0x4DBF - 0x4000 + 1);
    });
  });

  group('pagination', () {
    test('pages a block by offset and limit', () async {
      final first = await library.pageByBlock('Basic Latin', limit: 1);
      expect(first.map((e) => e.codePoint), [0x0]);
      final second =
          await library.pageByBlock('Basic Latin', limit: 1, offset: 1);
      expect(second.map((e) => e.codePoint), [0x41]);
      final none =
          await library.pageByBlock('Basic Latin', limit: 1, offset: 2);
      expect(none, isEmpty);
    });

    test('filters by category, script and combining class', () async {
      expect((await library.pageByCategory('Mn')).map((e) => e.codePoint),
          [0x307]);
      expect((await library.pageByScript('Devanagari')).map((e) => e.codePoint),
          [0x905]);
      expect(
          (await library.pageByCombiningClass(230)).map((e) => e.codePoint),
          [0x307]);
    });

    test('rejects bad paging arguments', () {
      expect(() => library.pageByBlock('Basic Latin', offset: -1),
          throwsArgumentError);
      expect(() => library.pageByBlock('Basic Latin', limit: 0),
          throwsArgumentError);
      expect(
          () => library.pageByBlock('Basic Latin',
              limit: UnicodeLibraryRepository.maxPageSize + 1),
          throwsArgumentError);
    });
  });

  group('Unicode version filter', () {
    test('hides characters added after maxAge', () async {
      expect(
          (await library.pageByBlock('Emoticons')).map((e) => e.codePoint),
          [0x1F600]);
      expect(await library.pageByBlock('Emoticons', maxAge: '6.0'), isEmpty);
      expect(
          (await library.pageByBlock('Emoticons', maxAge: '6.1'))
              .map((e) => e.codePoint),
          [0x1F600]);
    });

    test('rejects a version that is not a number', () {
      expect(() => library.pageByBlock('Emoticons', maxAge: 'latest'),
          throwsArgumentError);
    });

    test('lists available versions oldest first', () async {
      expect(await library.availableAgeVersions(), ['1.1', '6.1']);
    });
  });

  group('classify', () {
    test('uses the database for assigned and unassigned', () async {
      expect(await library.classify(0x41), CodePointClass.assigned);
      expect(await library.classify(0x3500), CodePointClass.assigned);
      expect(await library.classify(0x378), CodePointClass.unassigned);
    });

    test('recognises special classes', () async {
      expect(await library.classify(0x0), CodePointClass.control);
      expect(await library.classify(0xE000), CodePointClass.privateUse);
      expect(await library.classify(0xFFFF), CodePointClass.noncharacter);
      expect(await library.classify(0xD800), CodePointClass.surrogate);
    });
  });

  group('detail', () {
    test('explicit character has encodings and class', () async {
      final d = await library.detail(0x905);
      expect(d['name'], 'DEVANAGARI LETTER A');
      expect(d['code'], 'U+0905');
      expect(d['utf8'], 'E0 A4 85');
      expect(d['utf16'], '0905');
      expect(d['class'], CodePointClass.assigned);
      expect(d['isRange'], isFalse);
    });

    test('supplementary code point shows a surrogate pair', () async {
      final d = await library.detail(0x1F600);
      expect(d['utf16'], 'D83D DE00');
    });

    test('range member reports the range name', () async {
      final d = await library.detail(0x3500);
      expect(d['isRange'], isTrue);
      expect(d['name'], 'CJK Ideograph Extension A');
      expect(d['class'], CodePointClass.assigned);
    });

    test('private use, unassigned and surrogate are not confused', () async {
      expect((await library.detail(0xE000))['class'], CodePointClass.privateUse);
      final unassigned = await library.detail(0x378);
      expect(unassigned['class'], CodePointClass.unassigned);
      expect(unassigned.containsKey('name'), isFalse);
      final surrogate = await library.detail(0xD800);
      expect(surrogate['class'], CodePointClass.surrogate);
      expect(surrogate['utf8'], '');
      expect(surrogate['utf16'], '');
    });

    test('rejects out-of-range code points', () {
      expect(() => library.detail(0x110000), throwsA(isA<RangeError>()));
    });
  });
}
