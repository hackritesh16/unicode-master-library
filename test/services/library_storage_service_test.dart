import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unicode_master_library/services/library_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('favorites are saved and duplicate entries are ignored', () async {
    final service = LibraryStorageService(await SharedPreferences.getInstance());
    await service.addFavorite(kind: 'symbol', title: 'Star', content: '⭐');
    await service.addFavorite(kind: 'symbol', title: 'Star', content: '⭐');

    expect(service.getFavorites(), hasLength(1));
    expect(service.isFavorite('symbol', '⭐'), isTrue);
  });

  test('history moves repeated content to the top and can be cleared', () async {
    final service = LibraryStorageService(await SharedPreferences.getInstance());
    await service.addHistory(kind: 'text', title: 'First', content: 'A');
    await service.addHistory(kind: 'text', title: 'Second', content: 'B');
    await service.addHistory(kind: 'text', title: 'First', content: 'A');

    expect(service.getHistory().first.content, 'A');
    expect(service.getHistory(), hasLength(2));
    await service.clearHistory();
    expect(service.getHistory(), isEmpty);
  });
}
