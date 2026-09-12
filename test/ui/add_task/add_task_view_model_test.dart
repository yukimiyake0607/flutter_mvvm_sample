import 'package:flutter_mvvm_sample/data/providers/task_repository_provider.dart';
import 'package:flutter_mvvm_sample/ui/add_task/view_model/add_task_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_task_repository.dart';

void main() {
  test('submitが成功すると submit.completedがtrueになる', () async {
    // 失敗しないFake用のRepositoryインスタンスを作成
    final fakeRepository = FakeTaskRepository();

    // Repositoryを頼んだらfakeを渡すcontainer
    final container = ProviderContainer(
      overrides: [taskRepositoryProvider.overrideWithValue(fakeRepository)],
    );
    addTearDown(container.dispose);

    // autoDisposeのViewModelが途中で捨てられないように
    container.listen(addTaskViewModelProvider, (_, _) {});

    // 画面が「追加」を押した
    final viewModel = container.read(addTaskViewModelProvider.notifier);
    await viewModel.submit('プロテイン', 'ホエイ');

    // ViewModelのstateを読む
    // shouldFailではないので成功するはず
    final state = container.read(addTaskViewModelProvider);
    expect(state.submit.completed, isTrue);
  });
}
