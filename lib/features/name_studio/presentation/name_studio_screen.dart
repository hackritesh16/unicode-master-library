import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/text_design/combining_marks.dart' show renderingDisclaimer;
import '../../../core/text_design/design_engine.dart';
import '../../../core/text_design/design_themes.dart';
import '../../../core/text_design/design_types.dart';
import '../../../core/text_design/emoji_catalog.dart';
import '../../../core/text_design/graphemes.dart';
import '../../../core/text_design/text_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/export_formats.dart';
import '../../../services/library_storage_service.dart';
import '../../../services/share_service.dart';
import '../../../shared/widgets/glass_widgets.dart';
import 'design_card.dart';

/// Name Studio: turns a name into many decorated Unicode designs, or into
/// every single font style.
class NameStudioScreen extends StatefulWidget {
  const NameStudioScreen({super.key, this.initialName = 'Sefali', this.seed});

  final String initialName;

  /// Fixed seed so the designs are reproducible (used by tests).
  final int? seed;

  @override
  State<NameStudioScreen> createState() => _NameStudioScreenState();
}

class _NameStudioScreenState extends State<NameStudioScreen> {
  static const _designKind = 'name-design';
  static const _styleKind = 'name-style';

  late final TextEditingController _controller;
  final _customEmojiController = TextEditingController();

  int _mode = 0; // 0 = designs, 1 = font styles
  String? _themeId;
  int _count = 20;
  final Set<String> _fontIds = {};
  FontMixing _mixing = FontMixing.theme;
  DecorIntensity _intensity = DecorIntensity.balanced;
  bool _useEmoji = true;
  bool _useMarks = true;
  String? _emojiGroupId;

  List<GeneratedDesign> _results = const [];
  List<String> _notes = const [];
  String _generatedFor = '';
  int _round = 0;

  LibraryStorageService? _storage;
  Set<String> _favoriteTexts = {};

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
    final batch = DesignEngine.generate(_request(count: _count));
    _results = batch.designs;
    _notes = batch.notes;
    _generatedFor = DesignEngine.cleanName(_controller.text);
    _loadStorage();
  }

  @override
  void dispose() {
    _controller.dispose();
    _customEmojiController.dispose();
    super.dispose();
  }

  // ---- generation -------------------------------------------------------

  List<String> _customEmojis() {
    final typed = [
      for (final grapheme in splitGraphemes(_customEmojiController.text))
        if (!isBlankGrapheme(grapheme)) grapheme,
    ];
    if (typed.isNotEmpty) {
      return typed;
    }
    final groupId = _emojiGroupId;
    final group = groupId == null ? null : EmojiCatalog.byId(groupId);
    return group?.emojis ?? const [];
  }

  DesignRequest _request({required int count, Set<String> exclude = const {}}) {
    final themeId = _themeId;
    final seed = widget.seed;
    return DesignRequest(
      name: _controller.text,
      themeIds: themeId == null ? const [] : [themeId],
      count: count,
      fontIds: _fontIds.toList(),
      fontMixing: _mixing,
      useEmoji: _useEmoji,
      customEmojis: _useEmoji ? _customEmojis() : const [],
      useMarks: _useMarks,
      intensity: _intensity,
      seed: seed == null ? null : seed + _round,
      exclude: exclude,
    );
  }

  void _generate({bool more = false}) {
    FocusScope.of(context).unfocus();
    _round++;
    final existing = more ? _results.map((d) => d.text).toSet() : <String>{};
    final batch = DesignEngine.generate(
      _request(count: _count, exclude: existing),
    );
    setState(() {
      _results = more ? [..._results, ...batch.designs] : batch.designs;
      _notes = batch.notes;
      _generatedFor = DesignEngine.cleanName(_controller.text);
    });
  }

  // ---- storage, copy, share ---------------------------------------------

  Future<void> _loadStorage() async {
    final storage = await _store();
    if (storage == null || !mounted) {
      return;
    }
    setState(() {
      _favoriteTexts = {
        for (final entry in storage.getFavorites())
          if (entry.kind == _designKind || entry.kind == _styleKind)
            entry.content,
      };
    });
  }

  Future<LibraryStorageService?> _store() async {
    final existing = _storage;
    if (existing != null) {
      return existing;
    }
    try {
      final preferences = await SharedPreferences.getInstance();
      return _storage = LibraryStorageService(preferences);
    } catch (_) {
      // Storage is a convenience: copying must keep working without it.
      return null;
    }
  }

  void _toast(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(milliseconds: 1600),
        ),
      );
  }

  Future<void> _copy(String text, String kind) async {
    await Clipboard.setData(ClipboardData(text: text));
    final storage = await _store();
    await storage?.addHistory(
      kind: kind,
      title: _generatedFor.isEmpty ? 'Name design' : _generatedFor,
      content: text,
    );
    if (!mounted) {
      return;
    }
    _toast('Copied');
  }

  Future<void> _toggleFavorite(String text, String kind) async {
    final storage = await _store();
    if (storage == null) {
      return;
    }
    final saved = await storage.toggleFavorite(
      kind: kind,
      title: _generatedFor.isEmpty ? 'Name design' : _generatedFor,
      content: text,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      if (saved) {
        _favoriteTexts = {..._favoriteTexts, text};
      } else {
        _favoriteTexts = {..._favoriteTexts}..remove(text);
      }
    });
    _toast(saved ? 'Saved to Library' : 'Removed from Library');
  }

  Future<void> _showDetails(GeneratedDesign design) async {
    final action = await showDesignDetails(context, design);
    if (!mounted || action == null) {
      return;
    }
    switch (action) {
      case DesignAction.copy:
        await _copy(design.text, _designKind);
      case DesignAction.copyCodePoints:
        await Clipboard.setData(
          ClipboardData(text: ExportFormats.codePointsOf(design.text)),
        );
        if (mounted) {
          _toast('Code points copied');
        }
      case DesignAction.share:
        await _guarded(() => ShareService.shareText(design.text));
    }
  }

  Future<void> _guarded(Future<void> Function() action) async {
    try {
      await action();
    } catch (error) {
      if (mounted) {
        _toast('Could not complete that: $error');
      }
    }
  }

  List<String> get _resultTexts => [for (final d in _results) d.text];

  Future<void> _bulk(String action) async {
    if (_results.isEmpty) {
      return;
    }
    final texts = _resultTexts;
    switch (action) {
      case 'copy':
        await Clipboard.setData(
          ClipboardData(text: ExportFormats.toText(texts)),
        );
        if (mounted) {
          _toast('Copied ${texts.length} designs');
        }
      case 'codepoints':
        await Clipboard.setData(
          ClipboardData(text: ExportFormats.toCodePointReport(texts)),
        );
        if (mounted) {
          _toast('Copied designs with code points');
        }
      case 'txt':
        await _guarded(
          () => ShareService.shareFile(
            content: ExportFormats.toText(texts),
            fileName: 'unicode-designs.txt',
            mimeType: 'text/plain',
          ),
        );
      case 'json':
        await _guarded(
          () => ShareService.shareFile(
            content: ExportFormats.toJson(
              [
                for (final d in _results)
                  ExportItem(
                    text: d.text,
                    theme: d.themeId,
                    fonts: d.fontIds,
                  ),
              ],
              name: _generatedFor,
              generatedAt: DateTime.now(),
            ),
            fileName: 'unicode-designs.json',
            mimeType: 'application/json',
          ),
        );
      case 'share':
        await _guarded(
          () => ShareService.shareText(ExportFormats.toText(texts)),
        );
    }
  }

  // ---- build ------------------------------------------------------------

  TextStyle? _sectionStyle(BuildContext context) =>
      Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w700,
          );

  @override
  Widget build(BuildContext context) {
    final List<FontStyledText> fontStyles =
        _mode == 1 ? DesignEngine.fontStyles(_controller.text) : const [];
    final itemCount = _mode == 0 ? _results.length : fontStyles.length;
    final nameChanged = _mode == 0 &&
        _results.isNotEmpty &&
        DesignEngine.cleanName(_controller.text) != _generatedFor;

    return Scaffold(
      appBar: const GlassAppBar(title: Text('Name Studio')),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _nameField(),
                const SizedBox(height: 14),
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(
                      value: 0,
                      label: Text('Designs'),
                      icon: Icon(Icons.auto_awesome_rounded),
                    ),
                    ButtonSegment(
                      value: 1,
                      label: Text('Font styles'),
                      icon: Icon(Icons.text_fields_rounded),
                    ),
                  ],
                  selected: {_mode},
                  onSelectionChanged: (selection) =>
                      setState(() => _mode = selection.first),
                ),
                const SizedBox(height: 16),
                if (_mode == 0) ..._designControls(context, nameChanged),
                if (_mode == 1) ..._fontModeIntro(context),
                if (_mode == 0 && _notes.isNotEmpty)
                  for (final note in _notes)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        note,
                        style: const TextStyle(color: Colors.amber),
                      ),
                    ),
                if (_mode == 0 && _results.isNotEmpty) _resultsHeader(context),
              ]),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            sliver: SliverList.separated(
              itemCount: itemCount,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                if (_mode == 1) {
                  final style = fontStyles[index];
                  return DesignCard(
                    text: style.text,
                    caption: style.font.label,
                    isFavorite: _favoriteTexts.contains(style.text),
                    onCopy: () => _copy(style.text, _styleKind),
                    onFavorite: () => _toggleFavorite(style.text, _styleKind),
                  );
                }
                final design = _results[index];
                return DesignCard(
                  text: design.text,
                  caption: designCaption(design),
                  hasCaution: design.hasCautions,
                  isFavorite: _favoriteTexts.contains(design.text),
                  onCopy: () => _copy(design.text, _designKind),
                  onFavorite: () => _toggleFavorite(design.text, _designKind),
                  onDetails: () => _showDetails(design),
                );
              },
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (_mode == 0 && _results.isNotEmpty)
                  Center(
                    child: GlassButton(
                      label: 'Generate more',
                      icon: Icons.add_rounded,
                      onPressed: () => _generate(more: true),
                    ),
                  ),
                const SizedBox(height: 16),
                const Text(
                  renderingDisclaimer,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _nameField() {
    return TextField(
      controller: _controller,
      maxLength: maxDesignNameLength,
      textInputAction: TextInputAction.done,
      onChanged: (_) => setState(() {}),
      onSubmitted: (_) {
        if (_mode == 0) {
          _generate();
        }
      },
      decoration: InputDecoration(
        labelText: 'Your name',
        hintText: 'Type a name in any language',
        counterText: '',
        prefixIcon: const Icon(Icons.person_outline_rounded),
        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Clear name',
                icon: const Icon(Icons.close_rounded),
                onPressed: () {
                  _controller.clear();
                  setState(() {});
                },
              ),
      ),
    );
  }

  List<Widget> _fontModeIntro(BuildContext context) => [
        const Text(
          'Every Unicode font style for your name. Characters a style cannot '
          'represent (for example Hindi letters) stay exactly as typed.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 14),
      ];

  List<Widget> _designControls(BuildContext context, bool nameChanged) {
    final theme = _themeId == null ? null : DesignThemes.byId(_themeId!);
    return [
      Text('THEME', style: _sectionStyle(context)),
      const SizedBox(height: 8),
      SizedBox(
        height: 42,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: DesignThemes.all.length + 1,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            if (index == 0) {
              return ChoiceChip(
                label: const Text('All themes'),
                selected: _themeId == null,
                onSelected: (_) => setState(() => _themeId = null),
              );
            }
            final item = DesignThemes.all[index - 1];
            return ChoiceChip(
              label: Text(item.label),
              selected: _themeId == item.id,
              onSelected: (_) => setState(() => _themeId = item.id),
            );
          },
        ),
      ),
      const SizedBox(height: 6),
      Text(
        theme?.blurb ?? 'A mix of every theme',
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
      ),
      const SizedBox(height: 14),
      GlassSurface(
        padding: EdgeInsets.zero,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            title: const Text('Customize decoration'),
            subtitle: const Text('Fonts, emoji, marks, intensity'),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            children: _customizeChildren(context),
          ),
        ),
      ),
      const SizedBox(height: 14),
      Text('NUMBER OF DESIGNS', style: _sectionStyle(context)),
      const SizedBox(height: 8),
      SegmentedButton<int>(
        segments: const [
          ButtonSegment(value: 20, label: Text('20')),
          ButtonSegment(value: 50, label: Text('50')),
          ButtonSegment(value: 100, label: Text('100')),
        ],
        selected: {_count},
        onSelectionChanged: (selection) =>
            setState(() => _count = selection.first),
      ),
      const SizedBox(height: 14),
      SizedBox(
        width: double.infinity,
        child: GlassButton(
          label: 'Generate $_count designs',
          icon: Icons.auto_awesome_rounded,
          filled: true,
          onPressed: _generate,
        ),
      ),
      if (nameChanged)
        const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text(
            'The name changed. Tap Generate to update the designs.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ),
      const SizedBox(height: 16),
    ];
  }

  List<Widget> _customizeChildren(BuildContext context) {
    final fonts = [
      for (final font in TextFonts.all)
        if (font.id != 'plain') font,
    ];
    return [
      Text('FONT STYLES', style: _sectionStyle(context)),
      const SizedBox(height: 4),
      const Text(
        'None selected means each theme uses its own fonts.',
        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
      ),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 4,
        children: [
          for (final font in fonts)
            FilterChip(
              label: Text(font.label),
              selected: _fontIds.contains(font.id),
              onSelected: (selected) => setState(() {
                if (selected) {
                  _fontIds.add(font.id);
                } else {
                  _fontIds.remove(font.id);
                }
              }),
            ),
        ],
      ),
      const SizedBox(height: 14),
      Text('MIX FONTS IN ONE NAME', style: _sectionStyle(context)),
      const SizedBox(height: 8),
      SegmentedButton<FontMixing>(
        segments: const [
          ButtonSegment(value: FontMixing.theme, label: Text('Auto')),
          ButtonSegment(value: FontMixing.never, label: Text('Single')),
          ButtonSegment(value: FontMixing.often, label: Text('Mixed')),
        ],
        selected: {_mixing},
        onSelectionChanged: (selection) =>
            setState(() => _mixing = selection.first),
      ),
      const SizedBox(height: 14),
      Text('INTENSITY', style: _sectionStyle(context)),
      const SizedBox(height: 8),
      SegmentedButton<DecorIntensity>(
        segments: const [
          ButtonSegment(value: DecorIntensity.subtle, label: Text('Subtle')),
          ButtonSegment(
            value: DecorIntensity.balanced,
            label: Text('Balanced'),
          ),
          ButtonSegment(value: DecorIntensity.rich, label: Text('Rich')),
        ],
        selected: {_intensity},
        onSelectionChanged: (selection) =>
            setState(() => _intensity = selection.first),
      ),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Combining marks on letters'),
        subtitle: const Text('Dots, lines and arrows above or below letters'),
        value: _useMarks,
        onChanged: (value) => setState(() => _useMarks = value),
      ),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Emoji'),
        value: _useEmoji,
        onChanged: (value) => setState(() => _useEmoji = value),
      ),
      if (_useEmoji) ...[
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            ChoiceChip(
              label: const Text('Theme emoji'),
              selected: _emojiGroupId == null,
              onSelected: (_) => setState(() => _emojiGroupId = null),
            ),
            for (final group in EmojiCatalog.groups)
              ChoiceChip(
                label: Text(group.label),
                selected: _emojiGroupId == group.id,
                onSelected: (_) => setState(() => _emojiGroupId = group.id),
              ),
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _customEmojiController,
          maxLength: 16,
          decoration: const InputDecoration(
            labelText: 'Your own emoji (optional)',
            hintText: '🎀🦋',
            counterText: '',
          ),
        ),
      ],
    ];
  }

  Widget _resultsHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${_results.length} DESIGNS FOR "$_generatedFor"',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _sectionStyle(context),
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'Copy or export all',
            icon: const Icon(Icons.ios_share_rounded),
            onSelected: _bulk,
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'copy', child: Text('Copy all')),
              PopupMenuItem(
                value: 'codepoints',
                child: Text('Copy all with code points'),
              ),
              PopupMenuItem(value: 'txt', child: Text('Export TXT')),
              PopupMenuItem(value: 'json', child: Text('Export JSON')),
              PopupMenuItem(value: 'share', child: Text('Share all')),
            ],
          ),
        ],
      ),
    );
  }
}
