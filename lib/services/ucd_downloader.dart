import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/unicode/ucd_bundle.dart';
import '../core/unicode/ucd_parsers.dart';

class UcdDownloadException implements Exception {
  const UcdDownloadException(this.message);

  final String message;

  @override
  String toString() => 'UcdDownloadException: $message';
}

/// Downloads the latest Unicode Character Database from unicode.org.
///
/// The version is detected from `UCD/latest/ReadMe.txt`, never hardcoded.
/// File layout (verified against unicode.org): data files live in
/// `latest/ucd/`, `emoji-data.txt` in `latest/ucd/emoji/`, and
/// `emoji-test.txt` in `latest/emoji/`.
class UcdDownloader {
  UcdDownloader({http.Client? client, this.timeout = const Duration(seconds: 60)})
      : _client = client ?? http.Client();

  static const String baseUrl = 'https://www.unicode.org/Public/UCD/latest';

  /// bundle file name -> path below [baseUrl].
  static const Map<String, String> requiredPaths = {
    'UnicodeData.txt': 'ucd/UnicodeData.txt',
    'Blocks.txt': 'ucd/Blocks.txt',
    'Scripts.txt': 'ucd/Scripts.txt',
    'DerivedAge.txt': 'ucd/DerivedAge.txt',
    'PropList.txt': 'ucd/PropList.txt',
    'DerivedCoreProperties.txt': 'ucd/DerivedCoreProperties.txt',
    'EastAsianWidth.txt': 'ucd/EastAsianWidth.txt',
    'NameAliases.txt': 'ucd/NameAliases.txt',
    'emoji-data.txt': 'ucd/emoji/emoji-data.txt',
  };

  static const Map<String, String> optionalPaths = {
    'emoji-test.txt': 'emoji/emoji-test.txt',
  };

  final http.Client _client;
  final Duration timeout;

  Future<String> _getText(String relativePath) async {
    final uri = Uri.parse('$baseUrl/$relativePath');
    try {
      final response = await _client.get(uri).timeout(timeout);
      if (response.statusCode != 200) {
        throw UcdDownloadException('HTTP ${response.statusCode} for $uri');
      }
      // Decode bytes explicitly: unicode.org text files are UTF-8 but may be
      // served without a charset, and emoji-test.txt contains real emoji.
      return utf8.decode(response.bodyBytes);
    } on UcdDownloadException {
      rethrow;
    } catch (e) {
      throw UcdDownloadException('Failed to download $uri: $e');
    }
  }

  /// Returns the version of the latest UCD release, e.g. `18.0.0`.
  Future<String> fetchLatestVersion() async {
    final readme = await _getText('ReadMe.txt');
    final version = parseUcdVersion(readme);
    if (version == null) {
      throw const UcdDownloadException(
        'Could not detect the Unicode version from ReadMe.txt',
      );
    }
    return version;
  }

  /// Downloads every required file and, when available, the optional ones.
  /// Required-file failures abort with [UcdDownloadException]; optional files
  /// are skipped on failure.
  Future<UcdBundle> downloadLatest({
    void Function(String file, int done, int total)? onProgress,
  }) async {
    final version = await fetchLatestVersion();
    final total = requiredPaths.length + optionalPaths.length;
    final files = <String, String>{};
    var done = 0;

    for (final entry in requiredPaths.entries) {
      onProgress?.call(entry.key, done, total);
      files[entry.key] = await _getText(entry.value);
      done++;
    }
    for (final entry in optionalPaths.entries) {
      onProgress?.call(entry.key, done, total);
      try {
        files[entry.key] = await _getText(entry.value);
      } on UcdDownloadException {
        // Optional file: continue without it.
      }
      done++;
    }
    onProgress?.call('done', total, total);
    return UcdBundle(version: version, files: files);
  }

  void close() => _client.close();
}
