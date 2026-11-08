import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';
import '../../../services/library_storage_service.dart';
import '../domain/symbol_library_data.dart';

class SymbolLibraryScreen extends StatefulWidget {
  const SymbolLibraryScreen({super.key});

  @override
  State<SymbolLibraryScreen> createState() => _SymbolLibraryScreenState();
}

class _SymbolLibraryScreenState extends State<SymbolLibraryScreen> {
  final _searchController = TextEditingController();
  String _category = 'All';
  String _query = '';
  LibraryStorageService? _storage;
  Set<String> _favoriteGlyphs = {};

  List<LibrarySymbol> get _visibleSymbols => librarySymbols.where((item) {
        final matchesCategory =
            _category == 'All' || item.category == _category;
        final matchesQuery = _query.isEmpty ||
            item.name.toLowerCase().contains(_query.toLowerCase()) ||
            item.glyph.contains(_query);
        return matchesCategory && matchesQuery;
      }).toList();

  @override
  void initState() {
    super.initState();
    _initializeStorage();
  }

  Future<void> _initializeStorage() async {
    final preferences = await SharedPreferences.getInstance();
    final storage = LibraryStorageService(preferences);
    if (!mounted) return;
    setState(() {
      _storage = storage;
      _favoriteGlyphs = storage.getFavorites()
          .where((entry) => entry.kind == 'symbol')
          .map((entry) => entry.content)
          .toSet();
    });
  }

  Future<void> _toggleFavorite(LibrarySymbol item) async {
    final storage = _storage;
    if (storage == null) return;
    final isSaved = _favoriteGlyphs.contains(item.glyph);
    if (isSaved) {
      final matches = storage.getFavorites().where((value) =>
          value.kind == 'symbol' && value.content == item.glyph);
      if (matches.isNotEmpty) {
        await storage.removeFavorite(matches.first.id);
      }
    } else {
      await storage.addFavorite(kind: 'symbol', title: item.name, content: item.glyph);
    }
    if (!mounted) return;
    setState(() {
      if (isSaved) {
        _favoriteGlyphs.remove(item.glyph);
      } else {
        _favoriteGlyphs.add(item.glyph);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _copy(LibrarySymbol item) async {
    await Clipboard.setData(ClipboardData(text: item.glyph));
    await _storage?.addHistory(
      kind: 'symbol',
      title: item.name,
      content: item.glyph,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${item.name} copied')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final symbols = _visibleSymbols;
    return Scaffold(
      appBar: AppBar(title: const Text('Emoji & Symbols')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value.trim()),
              decoration: InputDecoration(
                hintText: 'Search emoji or symbol',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: IconButton(
                  tooltip: 'Clear search',
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 46,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              children: librarySymbolCategories.map((category) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: _category == category,
                    onSelected: (_) => setState(() => _category = category),
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _category == 'All' ? 'All symbols' : _category,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                Text(
                  '${symbols.length} items',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Expanded(
            child: symbols.isEmpty
                ? const Center(child: Text('No matching symbols found'))
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.92,
                    ),
                    itemCount: symbols.length,
                    itemBuilder: (context, index) {
                      final item = symbols[index];
                      return Material(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => _copy(item),
                          onLongPress: () => _toggleFavorite(item),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.outline),
                            ),
                            padding: const EdgeInsets.all(6),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  tooltip: _favoriteGlyphs.contains(item.glyph)
                                      ? 'Remove favorite'
                                      : 'Add favorite',
                                  visualDensity: VisualDensity.compact,
                                  onPressed: _storage == null
                                      ? null
                                      : () => _toggleFavorite(item),
                                  icon: Icon(
                                    _favoriteGlyphs.contains(item.glyph)
                                        ? Icons.bookmark
                                        : Icons.bookmark_border,
                                    color: AppColors.primary,
                                    size: 18,
                                  ),
                                ),
                                Text(item.glyph,
                                    style: const TextStyle(fontSize: 29)),
                                const SizedBox(height: 6),
                                Text(
                                  item.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
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
