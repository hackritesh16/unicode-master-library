import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/text_design/style_palette.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_widgets.dart';

class StylePaletteScreen extends StatefulWidget {
  const StylePaletteScreen({super.key});

  @override
  State<StylePaletteScreen> createState() => _StylePaletteScreenState();
}

class _StylePaletteScreenState extends State<StylePaletteScreen> {
  String _category = 'All';
  String _query = '';

  Future<void> _copy(StylePaletteEntry entry) async {
    await Clipboard.setData(ClipboardData(text: entry.value));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${entry.name} copied')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entries = StylePalette.search(_query, category: _category);
    return Scaffold(
      appBar: const GlassAppBar(title: Text('Style Palette')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: TextField(
              onChanged: (value) => setState(() => _query = value),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search_rounded),
                hintText: 'Search name, glyph or U+ code',
              ),
            ),
          ),
          SizedBox(
            height: 46,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: StylePalette.categories.map((category) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(category),
                  selected: _category == category,
                  onSelected: (_) => setState(() => _category = category),
                ),
              )).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _category == 'All' ? 'Curated Unicode marks & symbols' : _category,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                Text('${entries.length} items',
                    style: const TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          ),
          Expanded(
            child: entries.isEmpty
                ? const Center(child: Text('No matching entries'))
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.94,
                    ),
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return Material(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => _copy(entry),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.outline),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(entry.preview,
                                    style: const TextStyle(fontSize: 30)),
                                const SizedBox(height: 6),
                                Text(entry.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(entry.code,
                                  style: const TextStyle(fontSize: 9),
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
