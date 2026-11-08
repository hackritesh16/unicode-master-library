import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../database/unicode_importer.dart';
import '../database/unicode_schema.dart';
import '../services/ucd_downloader.dart';

/// The opened Unicode SQLite database.
final unicodeDatabaseProvider = FutureProvider<Database>((ref) async {
  final dir = await getDatabasesPath();
  final db = await openUnicodeDatabase(path: p.join(dir, 'unicode_master.db'));
  ref.onDispose(db.close);
  return db;
});

enum UnicodeDbStatus { checking, notInstalled, installing, ready, failed }

class UnicodeDbState {
  const UnicodeDbState({
    this.status = UnicodeDbStatus.checking,
    this.installedVersion,
    this.latestVersion,
    this.characterCount = 0,
    this.stage = '',
    this.progress = 0,
    this.error,
  });

  final UnicodeDbStatus status;
  final String? installedVersion;
  final String? latestVersion;
  final int characterCount;
  final String stage;
  final double progress;
  final String? error;

  UnicodeDbState copyWith({
    UnicodeDbStatus? status,
    String? installedVersion,
    String? latestVersion,
    int? characterCount,
    String? stage,
    double? progress,
    String? error,
    bool clearError = false,
  }) {
    return UnicodeDbState(
      status: status ?? this.status,
      installedVersion: installedVersion ?? this.installedVersion,
      latestVersion: latestVersion ?? this.latestVersion,
      characterCount: characterCount ?? this.characterCount,
      stage: stage ?? this.stage,
      progress: progress ?? this.progress,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Tracks whether the Unicode database is installed and drives the optional,
/// versioned download/update.
class UnicodeDbController extends Notifier<UnicodeDbState> {
  @override
  UnicodeDbState build() {
    Future.microtask(refreshStatus);
    return const UnicodeDbState();
  }

  Future<void> refreshStatus() async {
    try {
      final db = await ref.read(unicodeDatabaseProvider.future);
      final version = await readMeta(db, 'unicode_version');
      if (version == null) {
        state = state.copyWith(
          status: UnicodeDbStatus.notInstalled,
          clearError: true,
        );
        return;
      }
      final count = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM characters'),
          ) ??
          0;
      state = state.copyWith(
        status: UnicodeDbStatus.ready,
        installedVersion: version,
        characterCount: count,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(status: UnicodeDbStatus.failed, error: '$e');
    }
  }

  /// Asks unicode.org which release is latest (does not download data).
  Future<void> checkForUpdate() async {
    final downloader = UcdDownloader();
    try {
      final latest = await downloader.fetchLatestVersion();
      state = state.copyWith(latestVersion: latest, clearError: true);
    } catch (e) {
      state = state.copyWith(error: 'Update check failed: $e');
    } finally {
      downloader.close();
    }
  }

  /// Downloads the latest UCD and imports it. On failure the previously
  /// installed database stays untouched.
  Future<void> install() async {
    if (state.status == UnicodeDbStatus.installing) {
      return;
    }
    final previous = state;
    state = state.copyWith(
      status: UnicodeDbStatus.installing,
      stage: 'Checking latest Unicode version',
      progress: 0,
      clearError: true,
    );
    final downloader = UcdDownloader();
    try {
      final bundle = await downloader.downloadLatest(
        onProgress: (file, done, total) {
          state = state.copyWith(
            stage: 'Downloading $file',
            progress: 0.5 * done / total,
          );
        },
      );
      final db = await ref.read(unicodeDatabaseProvider.future);
      await UnicodeImporter(db).importBundle(
        bundle,
        sourceUrl: UcdDownloader.baseUrl,
        onProgress: (p) {
          state = state.copyWith(
            stage: p.stage,
            progress: 0.5 + 0.5 * p.fraction,
          );
        },
      );
      state = state.copyWith(latestVersion: bundle.version);
      await refreshStatus();
    } catch (e) {
      state = previous.copyWith(
        status: previous.installedVersion == null
            ? UnicodeDbStatus.failed
            : UnicodeDbStatus.ready,
        error: 'Download or import failed: $e',
      );
    } finally {
      downloader.close();
    }
  }
}

final unicodeDbControllerProvider =
    NotifierProvider<UnicodeDbController, UnicodeDbState>(
  UnicodeDbController.new,
);
