import 'package:flutter/material.dart';
import 'package:flutter_mvvm_sample/ui/add_task/view_model/add_task_view_model.dart';
import 'package:flutter_mvvm_sample/utils/result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// AddTaskViewModel（ViewModel）と1：1のViewです。
///
/// repository, clientとは連携しません。
class AddTaskScreen extends ConsumerStatefulWidget {
  const AddTaskScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends ConsumerState<AddTaskScreen> {
  // タイトルとメモを管理する
  final titleController = TextEditingController();
  final noteController = TextEditingController();

  @override
  void dispose() {
    titleController.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // submitは成功・失敗を返さないので、「追加」のタップ処理はsubmitを呼ぶだけにしています。
    // 処理が完了したかはCommandStateを確認する必要があるので、ここでlistenして結果を出し分けています。
    // previousを見ないと、completed, hasErrorが残ったまま再ビルドするたびにpop, SnackBarが再発します。
    // ここでもViewModelはフラグだけ出す、ViewはナビゲーションとSnackBar表示を責務としています。
    ref.listen(addTaskViewModelProvider, (previous, next) {
      if (next.submit.hasError && previous?.submit.hasError != true) {
        switch (next.submit.result) {
          case Ok():
            break;
          case Error(:final error):
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(error.toString())));
          case null:
            break;
        }
      }

      if (next.submit.completed && previous?.submit.completed != true) {
        context.pop();
      }
    });

    final state = ref.watch(addTaskViewModelProvider);
    final notifier = ref.read(addTaskViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text('タスク追加')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'タイトル',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextField(controller: titleController),
              const SizedBox(height: 8),
              Text('メモ', style: TextStyle(fontSize: 14)),
              TextField(controller: noteController),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: state.submit.running
                    ? null
                    : () => notifier.submit(
                        titleController.text,
                        noteController.text,
                      ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  width: 200,
                  height: 50,
                  child: Center(
                    child: state.submit.running
                        ? const CircularProgressIndicator()
                        : Text(
                            '追加',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
