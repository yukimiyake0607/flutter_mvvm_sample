import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_mvvm_sample/main.dart';

void main() {
  testWidgets('App starts', (tester) async {
    await tester.pumpWidget(const MainApp());
    expect(find.text('Hello World!'), findsOneWidget);
  });
}
