import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/unicode_library_repository.dart';
import 'unicode_db_provider.dart';

/// Block browsing, classification and detail queries over the imported UCD.
final unicodeLibraryRepositoryProvider =
    FutureProvider<UnicodeLibraryRepository>((ref) async {
  final db = await ref.watch(unicodeDatabaseProvider.future);
  return UnicodeLibraryRepository(db);
});

/// Every block with its assigned count, in code point order.
///
/// Auto-disposed so the list is read again each time a screen opens. That
/// keeps it correct after the Unicode database is installed or updated in
/// Settings, without any extra invalidation.
final blockSummariesProvider =
    FutureProvider.autoDispose<List<BlockSummary>>((ref) async {
  final library = await ref.watch(unicodeLibraryRepositoryProvider.future);
  return library.listBlocks();
});

/// Unicode versions present in the age data, oldest first. Feeds the
/// version filter.
final ageVersionsProvider =
    FutureProvider.autoDispose<List<String>>((ref) async {
  final library = await ref.watch(unicodeLibraryRepositoryProvider.future);
  return library.availableAgeVersions();
});
