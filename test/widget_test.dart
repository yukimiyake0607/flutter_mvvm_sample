import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_mvvm_sample/main.dart';

void main() {
  testWidgets('App starts', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MainApp()));
    expect(find.text('タスクリスト'), findsOneWidget);
  });
}
