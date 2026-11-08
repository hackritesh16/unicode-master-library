import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';
import '../../../services/library_storage_service.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  LibraryStorageService? _storage;
  List<LibraryEntry> _favorites = const [];
  List<LibraryEntry> _history = const [];
  bool _loading = true;
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final preferences = await SharedPreferences.getInstance();
    final storage = LibraryStorageService(preferences);
    if (!mounted) return;
    setState(() {
      _storage = storage;
      _favorites = storage.getFavorites();
      _history = storage.getHistory();
      _loading = false;
    });
  }

  Future<void> _refresh() async {
    final storage = _storage;
    if (storage == null) return;
    setState(() {
      _favorites = storage.getFavorites();
      _history = storage.getHistory();
    });
  }

  Future<void> _remove(LibraryEntry entry) async {
    final storage = _storage;
    if (storage == null) return;
    if (_tab == 0) {
      await storage.removeFavorite(entry.id);
    } else {
      await storage.removeHistory(entry.id);
    }
    await _refresh();
  }

  Future<void> _clearHistory() async {
    await _storage?.clearHistory();
    await _refresh();
  }

  Future<void> _copy(LibraryEntry entry) async {
    await Clipboard.setData(ClipboardData(text: entry.content));
    await _storage?.addHistory(
      kind: entry.kind,
      title: entry.title,
      content: entry.content,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied from Library')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entries = _tab == 0 ? _favorites : _history;
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Library'),
        actions: [
          if (_tab == 1 && _history.isNotEmpty)
            IconButton(
              tooltip: 'Clear history',
              onPressed: _clearHistory,
              icon: const Icon(Icons.delete_sweep_outlined),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(
                        value: 0,
                        label: Text('Favorites'),
                        icon: Icon(Icons.bookmark_rounded),
                      ),
                      ButtonSegment(
                        value: 1,
                        label: Text('History'),
                        icon: Icon(Icons.history_rounded),
                      ),
                    ],
                    selected: {_tab},
                    onSelectionChanged: (selection) =>
                        setState(() => _tab = selection.first),
                  ),
                ),
                Expanded(
                  child: entries.isEmpty
                      ? _EmptyLibrary(isHistory: _tab == 1)
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                          itemCount: entries.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final entry = entries[index];
                            return Card(
                              color: AppColors.surface,
                              child: ListTile(
                                title: Text(entry.title),
                                subtitle: Text(
                                  entry.content,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                leading: Icon(
                                  entry.kind == 'symbol'
                                      ? Icons.emoji_emotions_outlined
                                      : Icons.text_fields_rounded,
                                  color: AppColors.primary,
                                ),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (action) {
                                    if (action == 'copy') _copy(entry);
                                    if (action == 'remove') _remove(entry);
                                  },
                                  itemBuilder: (_) => const [
                                    PopupMenuItem(
                                      value: 'copy',
                                      child: Text('Copy'),
                                    ),
                                    PopupMenuItem(
                                      value: 'remove',
                                      child: Text('Remove'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

class _EmptyLibrary extends StatelessWidget {
  const _EmptyLibrary({required this.isHistory});

  final bool isHistory;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isHistory ? Icons.history_rounded : Icons.bookmark_border_rounded,
                size: 46,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 14),
              Text(
                isHistory ? 'No recent activity' : 'No favorites yet',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              Text(
                isHistory
                    ? 'Items you create or copy will appear here.'
                    : 'Save symbols and decorated text to find them quickly.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
}
