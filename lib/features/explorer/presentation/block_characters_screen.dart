import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/unicode/code_point.dart';
import '../../../core/unicode/code_point_class.dart';
import '../../../database/unicode_explorer_repository.dart';
import '../../../providers/unicode_library_provider.dart';
import '../../../shared/widgets/glass_widgets.dart';

/// Text to draw for [entry], or null when the character cannot be shown.
///
/// Control and format characters are invisible, so they get no glyph (the
/// tile shows an icon instead). Combining marks are drawn on a dotted circle
/// (U+25CC) so they have something to attach to.
String? displayGlyph(ExplorerEntry entry) {
  final cp = entry.codePoint;
  if (!isUnicodeScalar(cp)) {
    return null;
  }
  if (classifyCodePoint(cp, isAssigned: true) == CodePointClass.control ||
      entry.category == 'Cf') {
    return null;
  }
  final glyph = String.fromCharCode(cp);
  return (entry.category ?? '').startsWith('M') ? '◌$glyph' : glyph;
}

/// Human-readable label for a [CodePointClass].
String codePointClassLabel(CodePointClass value) => switch (value) {
      CodePointClass.assigned => 'Assigned',
      CodePointClass.unassigned => 'Unassigned',
      CodePointClass.privateUse => 'Private use',
      CodePointClass.control => 'Control',
      CodePointClass.surrogate => 'Surrogate',
      CodePointClass.noncharacter => 'Noncharacter',
    };

/// The characters of one Unicode block, loaded a page at a time, with the
/// Unicode version filter (hide characters added after a chosen version).
class BlockCharactersScreen extends ConsumerStatefulWidget {
  const BlockCharactersScreen({required this.blockName, super.key});

  final String blockName;

  @override
  ConsumerState<BlockCharactersScreen> createState() =>
      _BlockCharactersScreenState();
}

class _BlockCharactersScreenState extends ConsumerState<BlockCharactersScreen> {
  static const _pageSize = 120;

  final _scroll = ScrollController();
  List<ExplorerEntry> _entries = const [];
  bool _loading = false;
  bool _hasMore = true;
  String? _maxAge;
  String? _error;

  /// Bumped whenever the filter changes so a page that was still loading for
  /// the old filter is dropped instead of being appended.
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.hasClients && _scroll.position.extentAfter < 600) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_loading || !_hasMore) {
      return;
    }
    final generation = _generation;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final library = await ref.read(unicodeLibraryRepositoryProvider.future);
      final page = await library.pageByBlock(
        widget.blockName,
        offset: _entries.length,
        limit: _pageSize,
        maxAge: _maxAge,
      );
      if (!mounted || generation != _generation) {
        return;
      }
      setState(() {
        _entries = [..._entries, ...page];
        _hasMore = page.length == _pageSize;
      });
    } catch (e) {
      if (!mounted || generation != _generation) {
        return;
      }
      setState(() => _error = 'Could not load characters: $e');
    } finally {
      if (mounted && generation == _generation) {
        setState(() => _loading = false);
      }
    }
  }

  void _setMaxAge(String? value) {
    if (value == _maxAge) {
      return;
    }
    setState(() {
      _maxAge = value;
      _generation++;
      _entries = const [];
      _hasMore = true;
      _loading = false;
      _error = null;
    });
    if (_scroll.hasClients) {
      _scroll.jumpTo(0);
    }
    _loadMore();
  }

  Future<void> _showDetail(ExplorerEntry entry) async {
    final library = await ref.read(unicodeLibraryRepositoryProvider.future);
    final detail = await library.detail(entry.codePoint);
    if (!mounted) {
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      builder: (context) => _CharacterSheet(entry: entry, detail: detail),
    );
  }

  @override
  Widget build(BuildContext context) {
    final versions =
        ref.watch(ageVersionsProvider).valueOrNull ?? const <String>[];
    final summary = ref
        .watch(blockSummariesProvider)
        .valueOrNull
        ?.where((block) => block.name == widget.blockName)
        .firstOrNull;
    return Scaffold(
      appBar: GlassAppBar(
        title: Text(widget.blockName, overflow: TextOverflow.ellipsis),
      ),
      body: Column(
        children: [
          if (summary != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${summary.range} · ${summary.assignedCount} of '
                  '${summary.size} code points assigned',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ),
            ),
          if (versions.isNotEmpty)
            _VersionFilter(
              versions: versions,
              selected: _maxAge,
              onChanged: _setMaxAge,
            ),
          Expanded(child: _buildBody(summary?.assignedCount)),
        ],
      ),
    );
  }

  Widget _buildBody(int? assignedCount) {
    if (_error != null && _entries.isEmpty) {
      return _Note(
        icon: Icons.error_outline_rounded,
        message: _error!,
        onRetry: _loadMore,
      );
    }
    if (_entries.isEmpty) {
      if (_hasMore) {
        return const Center(child: CircularProgressIndicator());
      }
      final String message;
      if (_maxAge != null) {
        message =
            'No characters in this block were added up to Unicode $_maxAge.';
      } else if ((assignedCount ?? 0) > 0) {
        message = 'This block is stored as a range (for example CJK '
            'ideographs or private use), so its code points are not listed '
            'one by one.';
      } else {
        message = 'This block has no assigned characters.';
      }
      return _Note(icon: Icons.search_off_rounded, message: message);
    }
    return LayoutBuilder(
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
          controller: _scroll,
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 20),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.88,
          ),
          itemCount: _entries.length + (_hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= _entries.length) {
              return _error != null
                  ? Center(
                      child: TextButton(
                        onPressed: _loadMore,
                        child: const Text('Retry'),
                      ),
                    )
                  : const Center(child: CircularProgressIndicator());
            }
            final entry = _entries[index];
            return _CharacterTile(
              entry: entry,
              onTap: () => _showDetail(entry),
            );
          },
        );
      },
    );
  }
}

class _VersionFilter extends StatelessWidget {
  const _VersionFilter({
    required this.versions,
    required this.selected,
    required this.onChanged,
  });

  final List<String> versions;
  final String? selected;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: const Text('All versions'),
              selected: selected == null,
              onSelected: (_) => onChanged(null),
            ),
          ),
          for (final version in versions)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text('Up to $version'),
                selected: selected == version,
                onSelected: (_) => onChanged(version),
              ),
            ),
        ],
      ),
    );
  }
}

class _CharacterTile extends StatelessWidget {
  const _CharacterTile({required this.entry, required this.onTap});

  final ExplorerEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final glyph = displayGlyph(entry);
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
                  child: glyph == null
                      ? const Icon(
                          Icons.visibility_off_outlined,
                          color: AppColors.textSecondary,
                        )
                      : Text(
                          glyph,
                          style: const TextStyle(
                            fontSize: 34,
                            color: AppColors.textPrimary,
                          ),
                        ),
                ),
              ),
              Text(
                entry.code,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                entry.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CharacterSheet extends StatelessWidget {
  const _CharacterSheet({required this.entry, required this.detail});

  final ExplorerEntry entry;
  final Map<String, Object?> detail;

  @override
  Widget build(BuildContext context) {
    final glyph = displayGlyph(entry);
    final cp = entry.codePoint;
    final raw = isUnicodeScalar(cp) ? String.fromCharCode(cp) : null;
    final charClass = detail['class'] as CodePointClass;

    Widget line(String label, String value) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 112,
                child: Text(
                  label,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
              Expanded(child: Text(value)),
            ],
          ),
        );

    String text(String key) {
      final value = detail[key] as String?;
      return value == null || value.isEmpty ? '—' : value;
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: glyph == null
                  ? const Icon(Icons.visibility_off_outlined, size: 56)
                  : Text(
                      glyph,
                      style: const TextStyle(fontSize: 64, height: 1.2),
                    ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                entry.name,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 20),
            line('Code point', text('code')),
            line('Class', codePointClassLabel(charClass)),
            line('Category', text('category')),
            line('Block', text('block')),
            line('Script', text('script')),
            line('Unicode age', text('age')),
            line('UTF-8', text('utf8')),
            line('UTF-16', text('utf16')),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: raw == null || glyph == null
                  ? null
                  : () async {
                      await Clipboard.setData(ClipboardData(text: raw));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Character copied')),
                        );
                      }
                    },
              icon: const Icon(Icons.copy_rounded),
              label: const Text('Copy character'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note({required this.icon, required this.message, this.onRetry});

  final IconData icon;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 42, color: AppColors.textSecondary),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center),
              if (onRetry != null) ...[
                const SizedBox(height: 16),
                FilledButton(onPressed: onRetry, child: const Text('Retry')),
              ],
            ],
          ),
        ),
      );
}
