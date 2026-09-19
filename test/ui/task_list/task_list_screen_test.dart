import 'package:flutter/material.dart';
import 'package:flutter_mvvm_sample/data/providers/task_repository_provider.dart';
import 'package:flutter_mvvm_sample/domain/models/task.dart';
import 'package:flutter_mvvm_sample/ui/task_list/widgets/task_list_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_task_repository.dart';

void main() {
  testWidgets('loadに成功するとタスク一覧画面にタスクが表示される', (tester) async {
    final fakeRepository = FakeTaskRepository(
      seed: [
        Task(
          id: '1',
          title: '仕事',
          note: '会議',
          isCompleted: false,
          createdAt: DateTime(2026, 1, 1),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [taskRepositoryProvider.overrideWithValue(fakeRepository)],
        child: const MaterialApp(home: TaskListScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));

    expect(find.text('仕事'), findsOneWidget);
  });

  testWidgets('loadに失敗すると「データの取得に失敗しました」と表示され、再試行すると成功する', (tester) async {
    final fakeRepository = FakeTaskRepository(
      seed: [
        Task(
          id: '1',
          title: '仕事',
          note: '会議',
          isCompleted: false,
          createdAt: DateTime(2026, 1, 1),
        ),
      ],
      shouldFail: true,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [taskRepositoryProvider.overrideWithValue(fakeRepository)],
        child: MaterialApp(home: TaskListScreen()),
      ),
    );
    await tester.pump(Duration(milliseconds: 1));

    expect(find.text('データの取得に失敗しました'), findsOneWidget);

    fakeRepository.shouldFail = false;

    await tester.tap(find.text('再試行'));
    await tester.pump(Duration(milliseconds: 1));

    expect(find.text('仕事'), findsOneWidget);
  });
}
