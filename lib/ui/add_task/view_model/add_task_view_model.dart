import 'package:flutter_mvvm_sample/data/providers/task_repository_provider.dart';
import 'package:flutter_mvvm_sample/domain/models/task.dart';
import 'package:flutter_mvvm_sample/utils/command_state.dart';
import 'package:flutter_mvvm_sample/utils/result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddTaskState {
  const AddTaskState({this.submit = const CommandState()});

  final CommandState<Task> submit;

  AddTaskState copyWith({CommandState<Task>? submit}) {
    return AddTaskState(submit: submit ?? this.submit);
  }
}

class AddTaskViewModel extends Notifier<AddTaskState> {
  @override
  AddTaskState build() {
    return const AddTaskState();
  }

  Future<void> submit(String title, String note) async {
    if (state.submit.running) return;

    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      state = state.copyWith(
        submit: CommandState(result: Result.error(Exception('タイトルがありません'))),
      );
      return;
    }

    state = state.copyWith(submit: CommandState(running: true));
    final result = await ref
        .read(taskRepositoryProvider)
        .createTask(title: trimmedTitle, note: note);

    switch (result) {
      case Ok(:final value):
        state = state.copyWith(submit: CommandState(result: Result.ok(value)));
      case Error(:final error):
        state = state.copyWith(
          submit: CommandState(result: Result.error(error)),
        );
    }
  }
}

final addTaskViewModelProvider =
    NotifierProvider.autoDispose<AddTaskViewModel, AddTaskState>(
      AddTaskViewModel.new,
    );
