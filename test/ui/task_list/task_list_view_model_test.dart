import 'package:flutter_mvvm_sample/data/providers/task_repository_provider.dart';
import 'package:flutter_mvvm_sample/domain/models/task.dart';
import 'package:flutter_mvvm_sample/ui/task_list/view_model/task_list_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_task_repository.dart';

void main() {
  test('loadが成功すると tasksに入る', () async {
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

    final container = ProviderContainer(
      overrides: [taskRepositoryProvider.overrideWithValue(fakeRepository)],
    );
    addTearDown(container.dispose);
    container.listen(taskListViewModelProvider, (_, _) {});

    final viewModel = container.read(taskListViewModelProvider.notifier);
    await viewModel.load();

    final state = container.read(taskListViewModelProvider);
    expect(state.load.completed, isTrue);
    expect(state.load.running, isFalse);
    expect(state.tasks.length, 1);
    expect(state.tasks.first.title, '仕事');
  });

  test('loadが失敗すると loadのhasErrorがtrueになる', () async {
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

    final container = ProviderContainer(
      overrides: [taskRepositoryProvider.overrideWithValue(fakeRepository)],
    );
    addTearDown(container.dispose);
    container.listen(taskListViewModelProvider, (_, _) {});

    final viewModel = container.read(taskListViewModelProvider.notifier);
    await viewModel.load();

    final state = container.read(taskListViewModelProvider);
    expect(state.load.hasError, isTrue);
    expect(state.tasks, isEmpty);
  });

  test('フィルタをかけるとRepositoryは叩かず、filteredTasksだけ変わる', () async {
    final fakeRepository = FakeTaskRepository(
      seed: [
        Task(
          id: '1',
          title: '仕事',
          note: '会議',
          isCompleted: false,
          createdAt: DateTime(2026, 1, 1),
        ),
        Task(
          id: '2',
          title: '散歩',
          note: '朝30分',
          isCompleted: true,
          createdAt: DateTime(2026, 1, 1),
        ),
      ],
    );

    final container = ProviderContainer(
      overrides: [taskRepositoryProvider.overrideWithValue(fakeRepository)],
    );
    addTearDown(container.dispose);
    container.listen(taskListViewModelProvider, (_, _) {});

    final viewModel = container.read(taskListViewModelProvider.notifier);
    await viewModel.load();

    int callCount = fakeRepository.getTasksCallCount;
    viewModel.setFilter(TaskFilter.completed);

    final state = container.read(taskListViewModelProvider);
    expect(state.tasks.length, 2);
    expect(state.filteredTasks.length, 1);
    expect(state.filteredTasks.first.title, '散歩');
    expect(fakeRepository.getTasksCallCount, callCount);
  });

  test('deleteに成功すると、tasksのlengthが変わり、delete.completedがtrueになる', () async {
    final fakeRepository = FakeTaskRepository(
      seed: [
        Task(
          id: '1',
          title: '仕事',
          note: '会議',
          isCompleted: false,
          createdAt: DateTime(2026, 1, 1),
        ),
        Task(
          id: '2',
          title: '散歩',
          note: '朝30分',
          isCompleted: true,
          createdAt: DateTime(2026, 1, 1),
        ),
      ],
    );

    final container = ProviderContainer(
      overrides: [taskRepositoryProvider.overrideWithValue(fakeRepository)],
    );
    addTearDown(container.dispose);
    container.listen(taskListViewModelProvider, (_, _) {});

    final viewModel = container.read(taskListViewModelProvider.notifier);
    await viewModel.load();
    await viewModel.deleteTask('1');

    final state = container.read(taskListViewModelProvider);
    expect(state.tasks.where((task) => task.title == '仕事').toList(), isEmpty);
    expect(state.tasks.first.title, '散歩');
    expect(state.tasks.length, 1);
    expect(state.delete.completed, isTrue);
  });
}
