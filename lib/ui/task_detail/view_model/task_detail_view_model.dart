import 'package:flutter_mvvm_sample/data/providers/task_repository_provider.dart';
import 'package:flutter_mvvm_sample/domain/models/task.dart';
import 'package:flutter_mvvm_sample/utils/command_state.dart';
import 'package:flutter_mvvm_sample/utils/result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TaskDetailState {
  const TaskDetailState({
    this.task,
    this.load = const CommandState(),
    this.toggle = const CommandState(),
    this.delete = const CommandState(),
  });

  final Task? task;
  final CommandState<void> load;
  final CommandState<void> toggle;
  final CommandState<void> delete;

  TaskDetailState copyWith({
    Task? task,
    CommandState<void>? load,
    CommandState<void>? toggle,
    CommandState<void>? delete,
  }) {
    return TaskDetailState(
      task: task ?? this.task,
      load: load ?? this.load,
      toggle: toggle ?? this.toggle,
      delete: delete ?? this.delete,
    );
  }
}

class TaskDetailViewModel extends Notifier<TaskDetailState> {
  TaskDetailViewModel(this.id);
  final String id;

  @override
  TaskDetailState build() {
    Future(() => load());
    return const TaskDetailState();
  }

  Future<void> load() async {
    // loadの連打防止
    if (state.load.running) return;

    state = state.copyWith(load: CommandState(running: true));
    final result = await ref.read(taskRepositoryProvider).getTask(id);
    switch (result) {
      case Ok(:final value):
        state = state.copyWith(
          task: value,
          load: CommandState(result: Result.ok(null)),
        );
      case Error(:final error):
        state = state.copyWith(load: CommandState(result: Result.error(error)));
    }
  }

  Future<void> toggleCompleted() async {
    final task = state.task;
    if (task == null) return;
    if (state.toggle.running) return;

    state = state.copyWith(toggle: CommandState(running: true));
    final result = await ref
        .read(taskRepositoryProvider)
        .updateTask(task.copyWith(isCompleted: !task.isCompleted));
    switch (result) {
      case Ok(:final value):
        state = state.copyWith(
          task: value,
          toggle: CommandState(result: Result.ok(null)),
        );
      case Error(:final error):
        state = state.copyWith(
          toggle: CommandState(result: Result.error(error)),
        );
    }
  }

  Future<void> deleteTask() async {
    if (state.task == null) return;
    if (state.delete.running) return;

    state = state.copyWith(delete: CommandState(running: true));
    final result = await ref.read(taskRepositoryProvider).deleteTask(id);
    switch (result) {
      case Ok():
        state = state.copyWith(delete: CommandState(result: Result.ok(null)));
      case Error(:final error):
        state = state.copyWith(
          delete: CommandState(result: Result.error(error)),
        );
    }
  }
}

final taskDetailViewModelProvider = NotifierProvider.autoDispose
    .family<TaskDetailViewModel, TaskDetailState, String>(
      TaskDetailViewModel.new,
    );
