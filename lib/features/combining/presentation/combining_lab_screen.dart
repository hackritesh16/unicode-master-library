import 'package:flutter/material.dart';

import '../../../shared/widgets/glass_widgets.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/unicode/code_point.dart';

/// Interactive sandbox for learning how Unicode combining marks affect text.
class CombiningLabScreen extends StatefulWidget {
  const CombiningLabScreen({super.key});

  @override
  State<CombiningLabScreen> createState() => _CombiningLabScreenState();
}

class _CombiningLabScreenState extends State<CombiningLabScreen> {
  final _baseController = TextEditingController(text: 'a');
  final List<CombiningMark> _selected = [];

  String get _result => _baseController.text +
      String.fromCharCodes(_selected.map((mark) => mark.codePoint));

  @override
  void dispose() {
    _baseController.dispose();
    super.dispose();
  }

  void _toggle(CombiningMark mark) {
    setState(() {
      if (_selected.contains(mark)) {
        _selected.remove(mark);
      } else {
        _selected.add(mark);
      }
    });
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: _result));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Combined text copied')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlassAppBar(
        title: const Text('Combining Marks Lab'),
        actions: [
          IconButton(
            tooltip: 'Reset marks',
            onPressed: _selected.isEmpty
                ? null
                : () => setState(_selected.clear),
            icon: const Icon(Icons.restart_alt_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Build a character',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          const Text(
            'Enter a base character, then add one or more Unicode combining '
            'marks. Rendering depends on the font and platform.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _baseController,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Base text',
              hintText: 'Type a letter or short text',
              prefixIcon: Icon(Icons.text_fields_rounded),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.outline),
            ),
            child: Column(
              children: [
                const Text('LIVE PREVIEW',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      letterSpacing: 1.4,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    )),
                const SizedBox(height: 14),
                SelectableText(
                  _result.isEmpty ? ' ' : _result,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 54,
                    height: 1.5,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _selected.isEmpty
                      ? 'No marks selected'
                      : '${_selected.length} mark(s) applied',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _result.isEmpty ? null : _copy,
                  icon: const Icon(Icons.copy_rounded),
                  label: const Text('Copy result'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: Text('Choose combining marks',
                    style: Theme.of(context).textTheme.titleMedium),
              ),
              Text('${_selected.length} selected',
                  style: const TextStyle(color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 10),
          ..._markGroups.entries.map((group) => _MarkGroup(
                title: group.key,
                marks: group.value,
                selected: _selected,
                onTap: _toggle,
              )),
          if (_selected.isNotEmpty) ...[
            const SizedBox(height: 18),
            Text('Applied sequence',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selected
                  .map((mark) => InputChip(
                        label: Text('${mark.glyph}  ${mark.shortName}'),
                        onDeleted: () => _toggle(mark),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 12),
            SelectableText(
              formatCodePointSequence(
                _selected.map((mark) => mark.codePoint),
              ),
              style: const TextStyle(
                color: AppColors.secondary,
              ),
            ),
          ],
          const SizedBox(height: 24),
          const Text(
            'Note: combining marks are separate code points. The lab preserves '
            'the order you select; it does not perform Unicode normalization.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _MarkGroup extends StatelessWidget {
  const _MarkGroup({
    required this.title,
    required this.marks,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final List<CombiningMark> marks;
  final List<CombiningMark> selected;
  final ValueChanged<CombiningMark> onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          ...marks.map((mark) {
            final active = selected.contains(mark);
            return Card(
              margin: const EdgeInsets.only(bottom: 6),
              color: active ? AppColors.surfaceHigh : AppColors.surface,
              child: ListTile(
                onTap: () => onTap(mark),
                leading: Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(mark.glyph,
                      style: const TextStyle(fontSize: 25)),
                ),
                title: Text(mark.name),
                subtitle: Text(
                  '${formatCodePoint(mark.codePoint)} • CCC ${mark.combiningClass}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
                trailing: Icon(
                  active ? Icons.check_circle : Icons.add_circle_outline,
                  color: active ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class CombiningMark {
  const CombiningMark(
    this.codePoint,
    this.name,
    this.combiningClass,
    this.shortName,
  );

  final int codePoint;
  final String name;
  final int combiningClass;
  final String shortName;

  String get glyph => String.fromCharCode(codePoint);
}

const Map<String, List<CombiningMark>> _markGroups = {
  'Accents': [
    CombiningMark(0x0300, 'Combining Grave Accent', 230, 'Grave'),
    CombiningMark(0x0301, 'Combining Acute Accent', 230, 'Acute'),
    CombiningMark(0x0302, 'Combining Circumflex Accent', 230, 'Circumflex'),
    CombiningMark(0x0303, 'Combining Tilde', 230, 'Tilde'),
    CombiningMark(0x0308, 'Combining Diaeresis', 230, 'Diaeresis'),
    CombiningMark(0x030A, 'Combining Ring Above', 230, 'Ring above'),
    CombiningMark(0x0327, 'Combining Cedilla', 202, 'Cedilla'),
  ],
  'Below and overlay marks': [
    CombiningMark(0x0323, 'Combining Dot Below', 220, 'Dot below'),
    CombiningMark(0x0331, 'Combining Macron Below', 220, 'Macron below'),
    CombiningMark(0x0338, 'Combining Long Solidus Overlay', 1, 'Overlay'),
  ],
  'Devanagari marks': [
    CombiningMark(0x0902, 'Devanagari Sign Anusvara', 0, 'Anusvara'),
    CombiningMark(0x0903, 'Devanagari Sign Visarga', 0, 'Visarga'),
    CombiningMark(0x093C, 'Devanagari Sign Nukta', 7, 'Nukta'),
    CombiningMark(0x094D, 'Devanagari Sign Virama', 9, 'Virama'),
  ],
};
