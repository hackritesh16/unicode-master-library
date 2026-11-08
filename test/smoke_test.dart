import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unicode_master_library/main.dart';

void main() {
  testWidgets('app shell builds', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: UnicodeMasterApp()));
    expect(find.text('Unicode Master Library'), findsOneWidget);
  });
}
