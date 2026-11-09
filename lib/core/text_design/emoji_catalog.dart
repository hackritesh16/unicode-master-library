import 'graphemes.dart';

/// A curated emoji group for the Emoji Library and the Name Studio.
/// Entries may be single code points or multi-code-point sequences (VS16,
/// ZWJ). The test suite checks every entry against the official
/// `emoji-test.txt` and requires the fully-qualified form.
class EmojiGroup {
  const EmojiGroup(this.id, this.label, this.emojis);

  final String id;
  final String label;
  final List<String> emojis;
}

abstract final class EmojiCatalog {
  static const List<EmojiGroup> groups = [
    EmojiGroup('hearts', 'Hearts', [
      '❤️',
      '🧡',
      '💛',
      '💚',
      '💙',
      '💜',
      '🖤',
      '🤍',
      '🤎',
      '💖',
      '💗',
      '💓',
      '💞',
      '💕',
      '💝',
      '💘',
      '💟',
      '❣️',
      '🩷',
      '🩵',
      '🩶',
      '💔',
      '❤️‍\u{1F525}',
      '❤️‍\u{1FA79}',
    ]),
    EmojiGroup('flowers', 'Flowers', [
      '🌸',
      '🌺',
      '🌹',
      '🌷',
      '🌻',
      '🌼',
      '💐',
      '🪷',
      '🥀',
      '🌾',
      '🍀',
      '🌿',
      '🪻',
      '\u{1F3F5}️',
    ]),
    EmojiGroup('butterflies', 'Butterflies & insects', [
      '🦋',
      '🐝',
      '🐞',
      '🐛',
      '🪲',
    ]),
    EmojiGroup('animals', 'Animals', [
      '🐱',
      '🐶',
      '🐰',
      '🦊',
      '🐻',
      '🐼',
      '🐨',
      '🦁',
      '🐯',
      '🐺',
      '🦄',
      '🐴',
      '🐥',
      '🦢',
      '🦚',
      '🦜',
      '🐬',
      '🐳',
      '🐢',
      '🦉',
      '🐙',
    ]),
    EmojiGroup('nature', 'Nature', [
      '🌙',
      '☀️',
      '🌈',
      '☁️',
      '❄️',
      '🔥',
      '💧',
      '🌊',
      '🍃',
      '🍂',
      '🍁',
      '🌲',
      '🌴',
      '🌵',
      '🌍',
      '🌞',
      '\u{1F54A}️',
    ]),
    EmojiGroup('faces', 'Faces', [
      '😊',
      '😍',
      '🥰',
      '😘',
      '😎',
      '🤩',
      '😇',
      '🥺',
      '😏',
      '😈',
      '🤭',
      '😌',
      '🥳',
      '😋',
      '🙈',
      '🤗',
      '😜',
      '😉',
      '😁',
    ]),
    EmojiGroup('stars', 'Stars & sparkles', [
      '⭐',
      '🌟',
      '✨',
      '💫',
      '⚡',
      '🌠',
      '☄️',
      '💥',
      '🎇',
      '🎆',
    ]),
    EmojiGroup('royal', 'Royal', [
      '👑',
      '💎',
      '🏰',
      '🔱',
      '⚜️',
      '\u{1F5E1}️',
      '⚔️',
      '\u{1F6E1}️',
      '🏆',
      '🥂',
      '💍',
      '🦅',
    ]),
    EmojiGroup('objects', 'Objects', [
      '🎀',
      '🎧',
      '🎮',
      '\u{1F579}️',
      '💄',
      '🎁',
      '🎈',
      '🎉',
      '🎊',
      '🪞',
      '🧸',
      '📿',
      '🔮',
      '🧿',
      '🪄',
      '\u{1F56F}️',
      '🎵',
      '🎶',
      '📷',
      '💌',
      '👜',
      '👗',
      '👠',
    ]),
    EmojiGroup('decorations', 'Decorations', [
      '🎀',
      '✨',
      '💫',
      '🎊',
      '🎈',
      '🪩',
      '🧿',
      '🪬',
      '🔮',
      '🪄',
      '🎐',
      '🏮',
      '🎏',
      '🫧',
      '🪅',
    ]),
    EmojiGroup('attitude', 'Attitude', [
      '😈',
      '🔥',
      '⚡',
      '☠️',
      '💀',
      '🖤',
      '🥀',
      '👊',
      '🦅',
      '🐺',
    ]),
    EmojiGroup('gaming', 'Gaming', [
      '🎮',
      '\u{1F579}️',
      '👾',
      '⚔️',
      '🏆',
      '💀',
      '🔥',
      '⚡',
      '🎯',
      '🧩',
      '🎲',
      '♟️',
    ]),
  ];

  static EmojiGroup? byId(String id) {
    for (final group in groups) {
      if (group.id == id) {
        return group;
      }
    }
    return null;
  }

  /// Every curated emoji once, in group order.
  static List<String> get all {
    final seen = <String>{};
    return [
      for (final group in groups)
        for (final emoji in group.emojis)
          if (seen.add(emoji)) emoji,
    ];
  }

  /// Matches by group name or by the emoji itself.
  static List<String> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      return const [];
    }
    final seen = <String>{};
    return [
      for (final group in groups)
        for (final emoji in group.emojis)
          if ((group.label.toLowerCase().contains(q) || emoji == query.trim()) &&
              seen.add(emoji))
            emoji,
    ];
  }

  /// Number of user-perceived characters; a ZWJ sequence counts as one.
  static int graphemeCount(String emoji) => splitGraphemes(emoji).length;
}
