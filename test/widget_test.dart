import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_mvvm_sample/main.dart';

void main() {
  testWidgets('App starts', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MainApp()));
    expect(find.text('タスクリスト'), findsOneWidget);

    // ViewModel.build の Future(() => load()) と、フェイク API の 300ms 遅延を消化する。
    // pumpAndSettle は CircularProgressIndicator の無限アニメで終わらない。
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  });
}
