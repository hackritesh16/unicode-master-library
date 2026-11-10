import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Android share sheet and file export. Kept thin so the formatting logic
/// stays in the pure, unit-tested `ExportFormats`.
abstract final class ShareService {
  /// Opens the system share sheet with [text].
  static Future<void> shareText(String text, {String? subject}) =>
      Share.share(text, subject: subject);

  /// Writes [content] as UTF-8 to a temporary file and shares it, so TXT and
  /// JSON exports can be saved to Drive, Files or sent in any app.
  static Future<void> shareFile({
    required String content,
    required String fileName,
    required String mimeType,
  }) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(content, encoding: utf8, flush: true);
    await Share.shareXFiles([XFile(file.path, mimeType: mimeType)]);
  }
}
