import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LibraryEntry {
  const LibraryEntry({
    required this.id,
    required this.kind,
    required this.title,
    required this.content,
    required this.savedAt,
  });

  final String id;
  final String kind;
  final String title;
  final String content;
  final DateTime savedAt;

  Map<String, Object?> toJson() => {
        'id': id,
        'kind': kind,
        'title': title,
        'content': content,
        'savedAt': savedAt.toIso8601String(),
      };

  factory LibraryEntry.fromJson(Map<String, dynamic> json) => LibraryEntry(
        id: json['id'] as String,
        kind: json['kind'] as String,
        title: json['title'] as String,
        content: json['content'] as String,
        savedAt: DateTime.parse(json['savedAt'] as String),
      );
}

class LibraryStorageService {
  LibraryStorageService(this._preferences);

  static const _favoritesKey = 'unicode_library_favorites_v1';
  static const _historyKey = 'unicode_library_history_v1';
  static const maxHistoryItems = 60;

  final SharedPreferences _preferences;

  List<LibraryEntry> getFavorites() => _read(_favoritesKey);

  List<LibraryEntry> getHistory() => _read(_historyKey);

  bool isFavorite(String kind, String content) => getFavorites().any(
        (entry) => entry.kind == kind && entry.content == content,
      );

  Future<void> addFavorite({
    required String kind,
    required String title,
    required String content,
  }) async {
    final entries = getFavorites();
    if (entries.any((entry) => entry.kind == kind && entry.content == content)) {
      return;
    }
    final now = DateTime.now();
    entries.insert(
      0,
      LibraryEntry(
        id: '${now.microsecondsSinceEpoch}',
        kind: kind,
        title: title,
        content: content,
        savedAt: now,
      ),
    );
    await _write(_favoritesKey, entries);
  }

  Future<void> removeFavorite(String id) async {
    final entries = getFavorites()..removeWhere((entry) => entry.id == id);
    await _write(_favoritesKey, entries);
  }

  Future<void> addHistory({
    required String kind,
    required String title,
    required String content,
  }) async {
    final now = DateTime.now();
    final entries = getHistory()
      ..removeWhere((entry) => entry.kind == kind && entry.content == content);
    entries.insert(
      0,
      LibraryEntry(
        id: '${now.microsecondsSinceEpoch}',
        kind: kind,
        title: title,
        content: content,
        savedAt: now,
      ),
    );
    if (entries.length > maxHistoryItems) {
      entries.removeRange(maxHistoryItems, entries.length);
    }
    await _write(_historyKey, entries);
  }

  Future<void> removeHistory(String id) async {
    final entries = getHistory()..removeWhere((entry) => entry.id == id);
    await _write(_historyKey, entries);
  }

  Future<void> clearHistory() => _preferences.remove(_historyKey);

  List<LibraryEntry> _read(String key) {
    final raw = _preferences.getString(key);
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => LibraryEntry.fromJson(item as Map<String, dynamic>))
          .toList();
    } on FormatException {
      return [];
    } on TypeError {
      return [];
    }
  }

  Future<void> _write(String key, List<LibraryEntry> entries) =>
      _preferences.setString(
        key,
        jsonEncode(entries.map((entry) => entry.toJson()).toList()),
      );
}
