import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unicode_master_library/services/library_storage_service.dart';

void main() {
  late LibraryStorageService storage;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = LibraryStorageService(await SharedPreferences.getInstance());
  });

  test('toggleFavorite saves and removes, preserving exact characters',
      () async {
    const design = '★ Ṡe̲ ★';
    expect(
      await storage.toggleFavorite(
        kind: 'name-design',
        title: 'Sefali',
        content: design,
      ),
      isTrue,
    );
    expect(storage.isFavorite('name-design', design), isTrue);
    expect(storage.getFavorites().single.content, design);

    expect(
      await storage.toggleFavorite(
        kind: 'name-design',
        title: 'Sefali',
        content: design,
      ),
      isFalse,
    );
    expect(storage.getFavorites(), isEmpty);
  });

  test('updateFavorite renames and edits content', () async {
    await storage.addFavorite(kind: 'text', title: 'Old', content: 'a');
    final id = storage.getFavorites().single.id;
    expect(await storage.updateFavorite(id, title: 'New'), isTrue);
    expect(storage.getFavorites().single.title, 'New');
    expect(storage.getFavorites().single.content, 'a');
    expect(await storage.updateFavorite(id, content: 'b'), isTrue);
    expect(storage.getFavorites().single.content, 'b');
    expect(await storage.updateFavorite('missing', title: 'x'), isFalse);
  });

  test('duplicateFavorite inserts a titled copy below the original', () async {
    await storage.addFavorite(kind: 'text', title: 'Second', content: 'b');
    await storage.addFavorite(kind: 'text', title: 'First', content: 'a');
    final firstId = storage.getFavorites().first.id;
    final copy = await storage.duplicateFavorite(firstId);
    expect(copy, isNotNull);
    final entries = storage.getFavorites();
    expect(entries.map((e) => e.title).toList(), ['First', 'First copy', 'Second']);
    expect(entries[1].content, 'a');
    expect(entries.map((e) => e.id).toSet().length, 3);
    expect(await storage.duplicateFavorite('missing'), isNull);
  });
}
