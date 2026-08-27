import 'package:flutter_mvvm_sample/domain/models/task.dart';
import 'package:flutter_mvvm_sample/utils/command_state.dart';

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

  List<Task> get filteredTasks {
    switch (filter) {
      case TaskFilter.all:
        return tasks;
      case TaskFilter.active:
        return tasks.where((t) => t.isCompleted == false).toList();
      case TaskFilter.completed:
        return tasks.where((t) => t.isCompleted == true).toList();
    }
  }
}
