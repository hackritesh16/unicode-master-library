// Downloads the latest official Unicode Character Database files into
// data/unicode/raw/<version>/ (git-ignored) for inspection, archiving or
// offline fixtures. The app itself downloads and imports the same files on
// demand (see lib/services/ucd_downloader.dart); keep the file lists in sync.
//
// Usage (from the repository root):
//   dart tools/fetch_ucd.dart
import 'dart:convert';
import 'dart:io';

const base = 'https://www.unicode.org/Public/UCD/latest';

const files = <String, String>{
  'UnicodeData.txt': 'ucd/UnicodeData.txt',
  'Blocks.txt': 'ucd/Blocks.txt',
  'Scripts.txt': 'ucd/Scripts.txt',
  'DerivedAge.txt': 'ucd/DerivedAge.txt',
  'PropList.txt': 'ucd/PropList.txt',
  'DerivedCoreProperties.txt': 'ucd/DerivedCoreProperties.txt',
  'EastAsianWidth.txt': 'ucd/EastAsianWidth.txt',
  'NameAliases.txt': 'ucd/NameAliases.txt',
  'emoji-data.txt': 'ucd/emoji/emoji-data.txt',
  'emoji-test.txt': 'emoji/emoji-test.txt',
  'ReadMe.txt': 'ReadMe.txt',
};

Future<String> _get(HttpClient client, String url) async {
  final uri = Uri.parse(url);
  final request = await client.getUrl(uri);
  final response = await request.close();
  if (response.statusCode != 200) {
    throw HttpException('HTTP ${response.statusCode}', uri: uri);
  }
  return utf8.decodeStream(response);
}

Future<void> main() async {
  final client = HttpClient();
  try {
    final readme = await _get(client, '$base/ReadMe.txt');
    final match = RegExp(
      r'version\s+(\d+\.\d+\.\d+)\s+of\s+the\s+Unicode\s+Character\s+Database',
      caseSensitive: false,
    ).firstMatch(readme);
    if (match == null) {
      stderr.writeln('Could not detect the Unicode version from ReadMe.txt');
      exit(1);
    }
    final version = match.group(1)!;
    final outDir = Directory('data/unicode/raw/$version')
      ..createSync(recursive: true);
    stdout.writeln('Unicode $version -> ${outDir.path}');

    for (final entry in files.entries) {
      stdout.writeln('  ${entry.key}');
      final text = await _get(client, '$base/${entry.value}');
      File('${outDir.path}/${entry.key}').writeAsStringSync(text);
    }
    stdout.writeln('Done. Files keep their original Unicode License headers.');
  } finally {
    client.close();
  }
}
