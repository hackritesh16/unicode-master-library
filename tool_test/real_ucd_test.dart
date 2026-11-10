// Manual real-data check. Run by .github/workflows/data-check.yml with
// `flutter test tool_test/real_ucd_test.dart` (the importer depends on
// Flutter-only packages, so plain `dart run` cannot load it).
// It lives outside `test/` so the regular CI does not need the UCD download.
import 'package:flutter_test/flutter_test.dart';

import '../tools/check_real_ucd.dart' as check;

void main() {
  test(
    'real UCD files parse and import into SQLite',
    () async {
      await check.main();
    },
    timeout: const Timeout(Duration(minutes: 10)),
  );
}
