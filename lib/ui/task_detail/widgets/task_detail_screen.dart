import 'package:flutter/material.dart';
import 'package:flutter_mvvm_sample/ui/task_detail/view_model/task_detail_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TaskDetailScreen extends ConsumerWidget {
  const TaskDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(taskDetailViewModelProvider(id));
    final notifier = ref.read(taskDetailViewModelProvider(id).notifier);

    ref.listen(taskDetailViewModelProvider(id), (previous, next) {
      if (next.delete.hasError && previous?.delete.hasError != true) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('削除に失敗しました')));
      }

      if (next.toggle.hasError && previous?.toggle.hasError != true) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('チェックの変更に失敗しました')));
      }

      if (next.delete.completed && previous?.delete.completed != true) {
        context.pop();
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text('タスク詳細')),
      body: Center(
        child: _TaskDetailBody(state: state, notifier: notifier),
      ),
    );
  }
}

class _TaskDetailBody extends StatelessWidget {
  const _TaskDetailBody({required this.state, required this.notifier});

  final TaskDetailState state;
  final TaskDetailViewModel notifier;

  @override
  Widget build(BuildContext context) {
    final task = state.task;
    if (task == null) {
      if (state.load.hasError) {
        return _TaskDetailError(notifier);
      } else {
        return CircularProgressIndicator();
      }
    } else {
      return Column(
        children: [
          Text(task.title, style: TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          Text(task.note),
          const SizedBox(height: 8),
          Checkbox(
            value: task.isCompleted,
            onChanged: (_) {
              notifier.toggleCompleted();
            },
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => notifier.deleteTask(),
            child: Text('削除'),
          ),
        ],
      );
    }
  }
}

class _TaskDetailError extends StatelessWidget {
  const _TaskDetailError(this.notifier);

  final TaskDetailViewModel notifier;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('データ取得に失敗しました'),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            notifier.load();
          },
          child: Text('再試行'),
        ),
      ],
    );
  }
}
