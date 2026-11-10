import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../database/unicode_library_repository.dart';
import '../../../providers/unicode_library_provider.dart';
import '../../../shared/widgets/glass_widgets.dart';

/// Lists every Unicode block with its code point range and how many of its
/// code points are assigned. Tapping a block opens its characters.
class BlocksScreen extends ConsumerWidget {
  const BlocksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blocks = ref.watch(blockSummariesProvider);
    return Scaffold(
      appBar: const GlassAppBar(title: Text('Unicode Blocks')),
      body: blocks.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _Message(
          icon: Icons.error_outline_rounded,
          message: 'Could not read the Unicode blocks. $error',
        ),
        data: (list) => list.isEmpty
            ? const _Message(
                icon: Icons.storage_rounded,
                message: 'Install the official Unicode database in Settings '
                    'before browsing blocks.',
                showSettings: true,
              )
            : _BlockList(blocks: list),
      ),
    );
  }
}

class _BlockList extends StatefulWidget {
  const _BlockList({required this.blocks});

  final List<BlockSummary> blocks;

  @override
  State<_BlockList> createState() => _BlockListState();
}

class _BlockListState extends State<_BlockList> {
  String _filter = '';

  @override
  Widget build(BuildContext context) {
    final needle = _filter.trim().toLowerCase();
    final visible = needle.isEmpty
        ? widget.blocks
        : widget.blocks
            .where(
              (block) =>
                  block.name.toLowerCase().contains(needle) ||
                  block.range.toLowerCase().contains(needle),
            )
            .toList();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: TextField(
            onChanged: (value) => setState(() => _filter = value),
            decoration: const InputDecoration(
              hintText: 'Filter blocks by name or range, e.g. arrows or U+0900',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${visible.length} of ${widget.blocks.length} blocks',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ),
        ),
        Expanded(
          child: visible.isEmpty
              ? const Center(child: Text('No block matches that filter.'))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
                  itemCount: visible.length,
                  itemBuilder: (context, index) =>
                      _BlockTile(block: visible[index]),
                ),
        ),
      ],
    );
  }
}

class _BlockTile extends StatelessWidget {
  const _BlockTile({required this.block});

  final BlockSummary block;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: AppColors.outline),
          ),
          title: Text(block.name),
          subtitle: Text(
            '${block.range} · ${block.assignedCount} of ${block.size} assigned',
          ),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => context.push(
            Uri(path: '/block', queryParameters: {'name': block.name})
                .toString(),
          ),
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.message,
    this.showSettings = false,
  });

  final IconData icon;
  final String message;
  final bool showSettings;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: AppColors.textSecondary),
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
