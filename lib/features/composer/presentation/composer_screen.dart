import 'package:flutter/material.dart';

import '../../../shared/widgets/glass_widgets.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';
import '../domain/composer_preset.dart';
import '../../../services/library_storage_service.dart';

class ComposerScreen extends StatefulWidget {
  const ComposerScreen({super.key});

  @override
  State<ComposerScreen> createState() => _ComposerScreenState();
}

class _ComposerScreenState extends State<ComposerScreen> {
  final _textController = TextEditingController(text: 'Your Text');
  final _prefixController = TextEditingController();
  final _suffixController = TextEditingController();
  String _selectedPresetId = 'sparkle';

  ComposerPreset get _selectedPreset =>
      composerPresets.firstWhere((preset) => preset.id == _selectedPresetId);

  String get _output => buildComposerOutput(
        text: _textController.text,
        preset: _selectedPreset,
        customPrefix: _prefixController.text,
        customSuffix: _suffixController.text,
      );

  @override
  void initState() {
    super.initState();
    _textController.addListener(_refresh);
    _prefixController.addListener(_refresh);
    _suffixController.addListener(_refresh);
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    _textController
      ..removeListener(_refresh)
      ..dispose();
    _prefixController
      ..removeListener(_refresh)
      ..dispose();
    _suffixController
      ..removeListener(_refresh)
      ..dispose();
    super.dispose();
  }

  Future<void> _copyOutput() async {
    await Clipboard.setData(ClipboardData(text: _output));
    final preferences = await SharedPreferences.getInstance();
    await LibraryStorageService(preferences).addHistory(
      kind: 'text',
      title: 'Decorated text',
      content: _output,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Decorated text copied')),
    );
  }

  Future<void> _saveOutput() async {
    if (_output.isEmpty) return;
    final preferences = await SharedPreferences.getInstance();
    await LibraryStorageService(preferences).addFavorite(
      kind: 'text',
      title: 'Decorated text',
      content: _output,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved to Favorites')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlassAppBar(
        title: const Text('Decorative Composer'),
        actions: [
          IconButton(
            tooltip: 'Reset composer',
            onPressed: () {
              _textController.text = 'Your Text';
              _prefixController.clear();
              _suffixController.clear();
              setState(() => _selectedPresetId = 'sparkle');
            },
            icon: const Icon(Icons.restart_alt_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: AppColors.accentGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.auto_awesome_rounded,
                    color: Colors.white, size: 28),
                SizedBox(height: 12),
                Text(
                  'Create your own style',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Choose a frame, add custom symbols and copy the result.',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Text('YOUR TEXT', style: _sectionStyle(context)),
          const SizedBox(height: 8),
          TextField(
            controller: _textController,
            maxLength: 80,
            decoration: const InputDecoration(
              hintText: 'Type a name or short message',
              prefixIcon: Icon(Icons.text_fields_rounded),
              counterText: '',
            ),
          ),
          const SizedBox(height: 22),
          Text('CHOOSE A FRAME', style: _sectionStyle(context)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: composerPresets.map((preset) {
              return ChoiceChip(
                label: Text(preset.label),
                selected: preset.id == _selectedPresetId,
                onSelected: (_) =>
                    setState(() => _selectedPresetId = preset.id),
              );
            }).toList(),
          ),
          const SizedBox(height: 22),
          Text('CUSTOM DECORATION', style: _sectionStyle(context)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _prefixController,
                  maxLength: 12,
                  decoration: const InputDecoration(
                    labelText: 'Prefix',
                    hintText: 'e.g. ★',
                    counterText: '',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _suffixController,
                  maxLength: 12,
                  decoration: const InputDecoration(
                    labelText: 'Suffix',
                    hintText: 'e.g. ★',
                    counterText: '',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.outline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('LIVE PREVIEW', style: _sectionStyle(context)),
                const SizedBox(height: 18),
                Center(
                  child: SelectableText(
                    _output.isEmpty ? 'Your preview appears here' : _output,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: GlassButton(
                        label: 'Copy',
                        icon: Icons.copy_rounded,
                        filled: true,
                        onPressed: _output.isEmpty ? null : _copyOutput,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GlassButton(
                        label: 'Save',
                        icon: Icons.bookmark_add_outlined,
                        onPressed: _output.isEmpty ? null : _saveOutput,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Note: decorative symbols are Unicode characters. Their appearance '
            'and spacing can vary between fonts, devices and apps.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  TextStyle? _sectionStyle(BuildContext context) =>
      Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w700,
          );
}
