import 'package:flutter_mvvm_sample/data/providers/task_repository_provider.dart';
import 'package:flutter_mvvm_sample/domain/models/task.dart';
import 'package:flutter_mvvm_sample/utils/command_state.dart';
import 'package:flutter_mvvm_sample/utils/result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum TaskFilter { all, active, completed }

/// TaskListViewModelで管理するStateです。
class TaskListState {
  const TaskListState({
    this.tasks = const [],
    this.filter = TaskFilter.all,
    this.load = const CommandState(),
    this.delete = const CommandState(),
  });

  final List<Task> tasks;
  final TaskFilter filter;
  final CommandState<void> load;
  final CommandState<void> delete;

  /// Stateを変更するためのcopyWithメソッドです。
  TaskListState copyWith({
    List<Task>? tasks,
    TaskFilter? filter,
    CommandState<void>? load,
    CommandState<void>? delete,
  }) {
    return TaskListState(
      tasks: tasks ?? this.tasks,
      filter: filter ?? this.filter,
      load: load ?? this.load,
      delete: delete ?? this.delete,
    );
  }

  /// Taskリストにフィルターをかけて、返すリスト内容を変更するためのgetter
  ///
  /// 表示用のTaskリストの正が2つになると、更新や作成のし忘れが発生するので
  /// フィルタ済み用のリストはStateに持たないようにしておく。
  List<Task> get filteredTasks {
    switch (filter) {
      case TaskFilter.all:
        return tasks;
      case TaskFilter.active:
        return tasks.where((t) => !t.isCompleted).toList();
      case TaskFilter.completed:
        return tasks.where((t) => t.isCompleted).toList();
    }
  }
}

/// Taskリストを管理するViewModel。
///
/// @riverpodでViewModelを生成する方式は今回取りませんでした。
/// Provider＝DI、Notifier＝画面stateを自分のコードで追えるようにするため。
class TaskListViewModel extends Notifier<TaskListState> {
  @override
  TaskListState build() {
    Future(() => load());
    return const TaskListState();
  }

  Future<void> load() async {
    // loadの連打を阻止する
    if (state.load.running) return;

    state = state.copyWith(load: CommandState(running: true));

    final repository = ref.read(taskRepositoryProvider);
    final result = await repository.getTasks();
    switch (result) {
      case Ok(:final value):
        state = state.copyWith(
          tasks: value,
          load: CommandState(result: Result.ok(null), running: false),
        );
      case Error(:final error):
        state = state.copyWith(
          load: CommandState(result: Result.error(error), running: false),
        );
    }
  }

  void setFilter(TaskFilter filter) {
    state = state.copyWith(filter: filter);
  }

  Future<void> deleteTask(String id) async {
    // 削除ボタンの連打を阻止する
    if (state.delete.running) return;

    state = state.copyWith(delete: CommandState(running: true));
    final result = await ref.read(taskRepositoryProvider).deleteTask(id);

    switch (result) {
      case Ok():
        state = state.copyWith(
          delete: CommandState(result: Result.ok(null)),
          tasks: state.tasks.where((t) => t.id != id).toList(),
        );
      case Error(:final error):
        state = state.copyWith(
          delete: CommandState(result: Result.error(error)),
        );
    }
  }
}

/// View側でTaskListViewModelをwatchするためのProvider
///
/// 一覧を離れたらdisposeする。
/// 公式のCompassではScreenのコンストラクタにViewModelを渡していますが、
/// このリポジトリではRiverpodを使用しているので、
/// Riverpodに生成タイミングと寿命を任せる設計にしています。
/// 自分でnewしてしまうと
/// - autoDisposeが効かない
/// - refが繋がらずtaskRepositoryProviderをreadできない
/// などが発生してしまうので。
final taskListViewModelProvider =
    NotifierProvider.autoDispose<TaskListViewModel, TaskListState>(
      TaskListViewModel.new,
    );
