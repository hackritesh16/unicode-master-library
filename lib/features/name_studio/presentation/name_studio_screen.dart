import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/unicode/name_styles.dart';
import '../../../services/library_storage_service.dart';
import '../../../shared/widgets/glass_widgets.dart';

class NameStudioScreen extends StatefulWidget {
  const NameStudioScreen({super.key});
  @override
  State<NameStudioScreen> createState() => _NameStudioScreenState();
}
class _NameStudioScreenState extends State<NameStudioScreen> {
  final _controller = TextEditingController(text: 'Ranjeet');
  String _query = '';
  @override
  void initState() { super.initState(); _controller.addListener(_changed); }
  void _changed() => setState(() {});
  @override
  void dispose() { _controller.removeListener(_changed); _controller.dispose(); super.dispose(); }
  Future<void> _copy(String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    final preferences = await SharedPreferences.getInstance();
    await LibraryStorageService(preferences).addHistory(
      kind: 'name-style',
      title: 'Styled name',
      content: value,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Style copied to clipboard')));
  }
  @override
  Widget build(BuildContext context) {
    final input = _controller.text;
    final styles = nameStyles.where((s) => _query.isEmpty || s.label.toLowerCase().contains(_query.toLowerCase())).toList();
    return Scaffold(
      appBar: GlassAppBar(title: const Text('Name Studio'), actions: [
        IconButton(tooltip: 'Clear name', onPressed: input.isEmpty ? null : _controller.clear, icon: const Icon(Icons.clear_rounded)),
      ]),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(gradient: AppColors.accentGradient, borderRadius: BorderRadius.circular(20)),
          child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 28), SizedBox(height: 12),
            Text('Make your name stand out', style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w800)),
            SizedBox(height: 5), Text('Type once. Get multiple Unicode styles instantly.', style: TextStyle(color: Colors.white70)),
          ])),
        const SizedBox(height: 20),
        TextField(controller: _controller, maxLength: 40, decoration: const InputDecoration(labelText: 'Your name or text', hintText: 'Enter text to style', prefixIcon: Icon(Icons.edit_rounded), counterText: '')),
        const SizedBox(height: 16),
        TextField(onChanged: (v) => setState(() => _query = v), decoration: const InputDecoration(hintText: 'Find a style', prefixIcon: Icon(Icons.search_rounded), isDense: true)),
        const SizedBox(height: 18),
        Row(children: [
          Text('STYLE COLLECTION', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.textSecondary, letterSpacing: 1.2)),
          const Spacer(), Text('${styles.length} styles', style: const TextStyle(color: AppColors.textSecondary)),
        ]),
        const SizedBox(height: 10),
        if (input.isEmpty) const Padding(padding: EdgeInsets.symmetric(vertical: 30), child: Text('Enter some text to see your styles.'))
        else if (styles.isEmpty) const Padding(padding: EdgeInsets.symmetric(vertical: 30), child: Text('No matching style found.'))
        else ...styles.map((style) {
          final output = style.transform(input);
          return Card(color: AppColors.surface, margin: const EdgeInsets.only(bottom: 10),
            child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [Expanded(child: Text(style.label, style: const TextStyle(fontWeight: FontWeight.w700))),
                IconButton(tooltip: 'Copy ${style.label}', onPressed: () => _copy(output), icon: const Icon(Icons.copy_rounded))]),
              Text(style.description, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 12), SelectableText(output, style: const TextStyle(fontSize: 22, color: AppColors.textPrimary)),
            ])));
        }),
        const SizedBox(height: 12),
        const Text('Compatibility note: special Unicode glyphs depend on the font, device and app. Unsupported characters stay unchanged; these styles change text characters, not the original spelling.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ]),
    );
  }
}
