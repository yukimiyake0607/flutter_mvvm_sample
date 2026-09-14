import 'package:flutter_mvvm_sample/data/providers/task_repository_provider.dart';
import 'package:flutter_mvvm_sample/data/repositories/task_repository.dart';
import 'package:flutter_mvvm_sample/domain/models/task.dart';
import 'package:flutter_mvvm_sample/ui/add_task/view_model/add_task_view_model.dart';
import 'package:flutter_mvvm_sample/utils/result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// 中身は空の状態。テストで処理を書いていく。
class MockTaskRepository extends Mock implements TaskRepository {}

/// createメソッドのテストに関してはFakeとMock両方のテストを追加しました。
///
/// ここではMockでテストをしています。
/// createメソッドは「空文字」の場合Result.errorを投げます。
/// Mockでは「呼んだ・呼んでいない」をverify / verifyNeverで検証することができるので、
/// 空文字テストはFakeRepositoryを作成するよりMockでやった方が楽です。
/// ただし、Fakeは連続操作を検証する際に便利なのでトレードオフです。
/// このリポジトリでは複雑なロジックを組んでいないのでMockの方が相性がいいかもしれません。
/// ただし、このリポジトリの本筋は正解を導くことではなく、公式Compassをなぞって自分なりのMVVMの考え方を
/// 構築することなのでFakeで通します。
void main() {
  test('submitが成功すると submit.completedがtrueになる(mock)', () async {
    final mock = MockTaskRepository();

    // 呼ばれた時に返す値を指定
    // Fakeの時はFakeTaskRepositoryで処理を書いていたが、
    // mockのときはtest内に返す値を書く
    when(
      () => mock.createTask(
        title: any(named: 'title'),
        note: any(named: 'note'),
      ),
      // 公式ではasyncのときthenReturnではなくthenAnswerを使用していたので合わせてます
    ).thenAnswer(
      (_) async => Result.ok(
        Task(
          id: 'task-1',
          title: 'プロテイン',
          note: 'ホエイ',
          isCompleted: false,
          createdAt: DateTime(2026, 1, 1),
        ),
      ),
    );

    final container = ProviderContainer(
      overrides: [taskRepositoryProvider.overrideWithValue(mock)],
    );
    addTearDown(container.dispose);
    container.listen(addTaskViewModelProvider, (_, _) {});

    final viewModel = container.read(addTaskViewModelProvider.notifier);
    await viewModel.submit('プロテイン', 'ホエイ');

    final state = container.read(addTaskViewModelProvider);
    expect(state.submit.completed, isTrue);
    // 呼ばれた回数もmockで確認（カウンター必要なし）
    verify(() => mock.createTask(title: 'プロテイン', note: 'ホエイ')).called(1);
  });

  test('submitが失敗すると submit.hasErrorがtrueになる(mock)', () async {
    final mock = MockTaskRepository();

    when(
      () => mock.createTask(
        title: any(named: 'title'),
        note: any(named: 'note'),
      ),
    ).thenAnswer((_) async => Result.error(Exception('失敗')));

    final container = ProviderContainer(
      overrides: [taskRepositoryProvider.overrideWithValue(mock)],
    );
    addTearDown(container.dispose);
    container.listen(addTaskViewModelProvider, (_, _) {});

    final viewModel = container.read(addTaskViewModelProvider.notifier);
    await viewModel.submit('プロテイン', '納豆も');

    final state = container.read(addTaskViewModelProvider);
    expect(state.submit.hasError, isTrue);
    verify(() => mock.createTask(title: 'プロテイン', note: '納豆も')).called(1);
  });

  test('空タイトルならRepositoryを呼ばずにhasErrorになる(mock)', () async {
    final mock = MockTaskRepository();

    final container = ProviderContainer(
      overrides: [taskRepositoryProvider.overrideWithValue(mock)],
    );
    addTearDown(container.dispose);
    container.listen(addTaskViewModelProvider, (_, _) {});

    final viewModel = container.read(addTaskViewModelProvider.notifier);
    await viewModel.submit(' ', 'メモ');

    final state = container.read(addTaskViewModelProvider);
    expect(state.submit.hasError, isTrue);
    verifyNever(
      () => mock.createTask(
        title: any(named: 'title'),
        note: any(named: 'note'),
      ),
    );
  });
}
