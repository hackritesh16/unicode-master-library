class NameStyle {
  const NameStyle(this.id, this.label, this.description, this.transform);
  final String id, label, description;
  final String Function(String) transform;
}
String _mapRunes(String s, int Function(int) f) => String.fromCharCodes(s.runes.map(f));
int _offset(int r, int lo, int up, int digit) {
  if (r >= 65 && r <= 90) return up + r - 65;
  if (r >= 97 && r <= 122) return lo + r - 97;
  if (r >= 48 && r <= 57 && digit != 0) return digit + r - 48;
  return r;
}
String _bold(String s) => _mapRunes(s, (r) => _offset(r, 0x1D41A, 0x1D400, 0x1D7CE));
String _mono(String s) => _mapRunes(s, (r) => _offset(r, 0x1D68A, 0x1D670, 0x1D7F6));
String _wide(String s) => _mapRunes(s, (r) => r >= 33 && r <= 126 ? r + 0xFEE0 : r);
String _circled(String s) => _mapRunes(s, (r) {
  if (r >= 65 && r <= 90) return 0x24B6 + r - 65;
  if (r >= 97 && r <= 122) return 0x24D0 + r - 97;
  if (r >= 49 && r <= 57) return 0x2460 + r - 49;
  if (r == 48) return 0x24EA;
  return r;
});
const _small = <String,String>{'a':'ᴀ','b':'ʙ','c':'ᴄ','d':'ᴅ','e':'ᴇ','f':'ꜰ','g':'ɢ','h':'ʜ','i':'ɪ','j':'ᴊ','k':'ᴋ','l':'ʟ','m':'ᴍ','n':'ɴ','o':'ᴏ','p':'ᴘ','q':'ǫ','r':'ʀ','s':'ꜱ','t':'ᴛ','u':'ᴜ','v':'ᴠ','w':'ᴡ','x':'x','y':'ʏ','z':'ᴢ'};
String _smallCaps(String s) => String.fromCharCodes(s.runes.map((r) => (_small[String.fromCharCode(r).toLowerCase()] ?? String.fromCharCode(r)).runes.first));
const nameStyles = <NameStyle>[
  NameStyle('bold','Mathematical Bold','Bold letters and numbers',_bold),
  NameStyle('mono','Monospace','Fixed-width Unicode characters',_mono),
  NameStyle('fullwidth','Fullwidth','Wide Latin characters',_wide),
  NameStyle('circled','Circled','Letters and numbers in circles',_circled),
  NameStyle('smallcaps','Small Caps','Compact uppercase-like letters',_smallCaps),
];
