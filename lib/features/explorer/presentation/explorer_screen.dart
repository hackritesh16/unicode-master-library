import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../database/unicode_explorer_repository.dart';
import '../../../providers/unicode_db_provider.dart';
import '../../../shared/widgets/glass_widgets.dart';

class ExplorerScreen extends ConsumerStatefulWidget {
  const ExplorerScreen({super.key});

  @override
  ConsumerState<ExplorerScreen> createState() => _ExplorerScreenState();
}

class _ExplorerScreenState extends ConsumerState<ExplorerScreen> {
  final _controller = TextEditingController();
  List<ExplorerEntry> _entries = const [];
  bool _loading = false;
  String? _error;
  String _activeQuery = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final database = await ref.read(unicodeDatabaseProvider.future);
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
      _activeQuery = _controller.text.trim();
    });
    try {
      final results = await UnicodeExplorerRepository(database)
          .search(_activeQuery);
      if (!mounted) return;
      setState(() => _entries = results);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Search failed: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _showDetails(ExplorerEntry entry) async {
    final db = await ref.read(unicodeDatabaseProvider.future);
    if (!mounted) return;
    final details = await UnicodeExplorerRepository(db).details(entry.codePoint);
    if (!mounted) return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      builder: (context) => _CharacterDetails(entry: entry, details: details),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(unicodeDbControllerProvider, (previous, next) {
      if (next.status == UnicodeDbStatus.ready &&
          previous?.status != UnicodeDbStatus.ready) {
        _search();
      }
    });
    final database = ref.watch(unicodeDatabaseProvider);
    return Scaffold(
      appBar: GlassAppBar(
        title: const Text('Unicode Explorer'),
        actions: [
          IconButton(
            tooltip: 'Browse Unicode blocks',
            onPressed: () => context.push('/blocks'),
            icon: const Icon(Icons.grid_view_rounded),
          ),
          IconButton(
            tooltip: 'Combining Marks Lab',
            onPressed: () => context.push('/combining'),
            icon: const Icon(Icons.science_outlined),
          ),
          IconButton(
            tooltip: 'Refresh',
            onPressed: database.hasValue ? _search : null,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: database.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _DatabaseUnavailable(
          message: 'Could not open the Unicode database. $error',
        ),
        data: (_) => ref.watch(unicodeDbControllerProvider).status ==
                UnicodeDbStatus.checking
            ? const Center(child: CircularProgressIndicator())
            : ref.watch(unicodeDbControllerProvider).installedVersion == null
                ? const _DatabaseUnavailable(
                    message: 'Install the official Unicode database in '
                        'Settings before exploring characters.',
                    showSettings: true,
                  )
                : _buildExplorer(),
      ),
    );
  }

  Widget _buildExplorer() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _controller,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _search(),
                decoration: InputDecoration(
                  hintText: 'Search name, character, U+0905, block...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: IconButton(
                    tooltip: 'Clear search',
                    onPressed: () {
                      _controller.clear();
                      _search();
                    },
                    icon: const Icon(Icons.close_rounded),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _activeQuery.isEmpty
                          ? 'Characters'
                          : 'Results for “$_activeQuery”',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  Text(
                    _entries.length.toString(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (_loading) const LinearProgressIndicator(minHeight: 2),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(_error!, style: const TextStyle(color: AppColors.error)),
          ),
        Expanded(
          child: _entries.isEmpty && !_loading
              ? _EmptyResults(query: _activeQuery)
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final columns = width >= 900
                        ? 8
                        : width >= 600
                            ? 6
                            : width >= 400
                                ? 4
                                : 3;
                    return GridView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 20),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 0.88,
                      ),
                      itemCount: _entries.length,
                      itemBuilder: (context, index) {
                        final entry = _entries[index];
                        return _CharacterTile(
                          entry: entry,
                          onTap: () => _showDetails(entry),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _CharacterTile extends StatelessWidget {
  const _CharacterTile({required this.entry, required this.onTap});

  final ExplorerEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cp = entry.codePoint;
    final glyph = cp >= 0 && cp <= 0x10FFFF &&
            !(cp >= 0xD800 && cp <= 0xDFFF)
        ? String.fromCharCode(cp)
        : '—';
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.outline),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Center(
                  child: Text(glyph, style: const TextStyle(
                    fontSize: 34, color: AppColors.textPrimary,
                  )),
                ),
              ),
              Text(entry.code, style: const TextStyle(
                fontSize: 10, color: AppColors.secondary,
                fontWeight: FontWeight.w600,
              )),
              const SizedBox(height: 3),
              Text(entry.name, maxLines: 2, overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CharacterDetails extends StatelessWidget {
  const _CharacterDetails({required this.entry, required this.details});

  final ExplorerEntry entry;
  final Map<String, Object?>? details;

  @override
  Widget build(BuildContext context) {
    final d = details;
    final aliases = (d?['aliases'] as List?) ?? const [];
    final properties = (d?['properties'] as List?) ?? const [];
    final cp = entry.codePoint;
    final scalar = cp >= 0 && cp <= 0x10FFFF &&
        !(cp >= 0xD800 && cp <= 0xDFFF);
    final glyph = scalar ? String.fromCharCode(cp) : '—';

    Widget line(String label, String value) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 112, child: Text(label,
                style: const TextStyle(color: AppColors.textSecondary))),
              Expanded(child: SelectableText(value)),
            ],
          ),
        );

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Text(glyph,
              style: const TextStyle(fontSize: 64, height: 1.2))),
            const SizedBox(height: 8),
            Center(child: Text(entry.name, textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge)),
            const SizedBox(height: 20),
            line('Code point', entry.code),
            line('Category', entry.category ?? 'Range record'),
            line('Block', entry.block ?? '—'),
            line('Script', entry.script ?? '—'),
            line('Unicode age', entry.age ?? '—'),
            line('Combining class', entry.combiningClass.toString()),
            line('UTF-8', d?['utf8'] as String? ?? 'Not available'),
            if (aliases.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('Name aliases', style: Theme.of(context).textTheme.titleSmall),
              ...aliases.map((a) {
                final item = a as Map;
                return line(item['type'] as String? ?? 'Alias',
                    item['alias'] as String? ?? '');
              }),
            ],
            if (properties.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('Properties', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: properties.map((p) {
                  final item = p as Map;
                  return Chip(label: Text(item['name'] as String? ?? ''),
                    visualDensity: VisualDensity.compact);
                }).toList(),
              ),
            ],
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: scalar ? () async {
                await Clipboard.setData(ClipboardData(text: glyph));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Character copied')),
                  );
                }
              } : null,
              icon: const Icon(Icons.copy_rounded),
              label: const Text('Copy character'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults({required this.query});
  final String query;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.search_off_rounded, size: 42,
                  color: AppColors.textSecondary),
              const SizedBox(height: 12),
              Text(query.isEmpty ? 'No characters found' : 'No matching results',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              const Text('Try a character, name, block, or code point such as '
                  'U+0905.'),
            ],
          ),
        ),
      );
}

class _DatabaseUnavailable extends StatelessWidget {
  const _DatabaseUnavailable({required this.message, this.showSettings = false});

  final String message;
  final bool showSettings;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.storage_rounded, size: 48,
                  color: AppColors.textSecondary),
              const SizedBox(height: 16),
              Text(message, textAlign: TextAlign.center),
              if (showSettings) ...[
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => context.go('/settings'),
                  child: const Text('Open Settings'),
                ),
              ],
            ],
          ),
        ),
      );
}
