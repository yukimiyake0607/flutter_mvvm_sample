import 'package:flutter_mvvm_sample/data/providers/task_repository_provider.dart';
import 'package:flutter_mvvm_sample/domain/models/task.dart';
import 'package:flutter_mvvm_sample/utils/command_state.dart';
import 'package:flutter_mvvm_sample/utils/result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// [AddTaskViewModel]が管理するStateです。
/// 
/// submit: タスク追加時の状態をここで持ちます。
/// titleやnoteをStateで管理しない理由は、一時的な状態のためUI（TextEditingController）で
/// 管理すべきだと判断したからです。
class AddTaskState {
  const AddTaskState({this.submit = const CommandState()});

  // 「追加」という1操作の進行を管理。
  // 成功値を使う、使わないどちらでも選択できるようにCommandState<Task>とします。
  final CommandState<Task> submit;

  AddTaskState copyWith({CommandState<Task>? submit}) {
    return AddTaskState(submit: submit ?? this.submit);
  }
}

/// AddTaskScreen（View）と1：1のViewModelです。
/// 
/// Repositoryとはreadします。
/// Service, Dtoとは連携しません。
/// contextが必要な操作はViewに任せています。
class AddTaskViewModel extends Notifier<AddTaskState> {
  
  // 一覧とは違い初期取得するものがないので、空のAddTaskStateを返すだけ。
  @override
  AddTaskState build() {
    return const AddTaskState();
  }

  /// View側で実行するsubmitメソッド。
  /// 
  /// 空タイトルの場合はRepositoryを呼ばずにResult.errorにして返す。
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

/// [AddTaskViewModel]を管理するProvider。
/// 
/// 画面を離れたら破棄するためautoDisposeをつけています。
final addTaskViewModelProvider =
    NotifierProvider.autoDispose<AddTaskViewModel, AddTaskState>(
      AddTaskViewModel.new,
    );
