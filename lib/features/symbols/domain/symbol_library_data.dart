class LibrarySymbol {
  const LibrarySymbol(this.glyph, this.name, this.category);

  final String glyph;
  final String name;
  final String category;
}

const librarySymbols = <LibrarySymbol>[
  LibrarySymbol('😀', 'Grinning face', 'Faces'),
  LibrarySymbol('😂', 'Face with tears of joy', 'Faces'),
  LibrarySymbol('🥹', 'Face holding back tears', 'Faces'),
  LibrarySymbol('😎', 'Smiling face with sunglasses', 'Faces'),
  LibrarySymbol('🤔', 'Thinking face', 'Faces'),
  LibrarySymbol('✨', 'Sparkles', 'Stars'),
  LibrarySymbol('⭐', 'Star', 'Stars'),
  LibrarySymbol('🌟', 'Glowing star', 'Stars'),
  LibrarySymbol('💫', 'Dizzy', 'Stars'),
  LibrarySymbol('⚡', 'High voltage', 'Stars'),
  LibrarySymbol('❤️', 'Red heart', 'Hearts'),
  LibrarySymbol('🧡', 'Orange heart', 'Hearts'),
  LibrarySymbol('💛', 'Yellow heart', 'Hearts'),
  LibrarySymbol('💚', 'Green heart', 'Hearts'),
  LibrarySymbol('💙', 'Blue heart', 'Hearts'),
  LibrarySymbol('💜', 'Purple heart', 'Hearts'),
  LibrarySymbol('🖤', 'Black heart', 'Hearts'),
  LibrarySymbol('🤍', 'White heart', 'Hearts'),
  LibrarySymbol('🌸', 'Cherry blossom', 'Nature'),
  LibrarySymbol('🌻', 'Sunflower', 'Nature'),
  LibrarySymbol('🍀', 'Four leaf clover', 'Nature'),
  LibrarySymbol('🌙', 'Crescent moon', 'Nature'),
  LibrarySymbol('☀️', 'Sun', 'Nature'),
  LibrarySymbol('🌈', 'Rainbow', 'Nature'),
  LibrarySymbol('🔥', 'Fire', 'Nature'),
  LibrarySymbol('➜', 'Right arrow', 'Arrows'),
  LibrarySymbol('➤', 'Right arrowhead', 'Arrows'),
  LibrarySymbol('➳', 'Fancy right arrow', 'Arrows'),
  LibrarySymbol('↗', 'North east arrow', 'Arrows'),
  LibrarySymbol('↘', 'South east arrow', 'Arrows'),
  LibrarySymbol('⇢', 'Dashed right arrow', 'Arrows'),
  LibrarySymbol('♡', 'White heart suit', 'Shapes'),
  LibrarySymbol('♥', 'Black heart suit', 'Shapes'),
  LibrarySymbol('◆', 'Black diamond', 'Shapes'),
  LibrarySymbol('◇', 'White diamond', 'Shapes'),
  LibrarySymbol('●', 'Black circle', 'Shapes'),
  LibrarySymbol('○', 'White circle', 'Shapes'),
  LibrarySymbol('■', 'Black square', 'Shapes'),
  LibrarySymbol('□', 'White square', 'Shapes'),
  LibrarySymbol('♪', 'Eighth note', 'Music'),
  LibrarySymbol('♫', 'Beamed eighth notes', 'Music'),
  LibrarySymbol('♬', 'Beamed sixteenth notes', 'Music'),
  LibrarySymbol('♩', 'Quarter note', 'Music'),
];

List<String> get librarySymbolCategories => [
      'All',
      ...{for (final item in librarySymbols) item.category},
    ];
