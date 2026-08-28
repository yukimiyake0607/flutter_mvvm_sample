import 'package:flutter/material.dart';
import 'package:flutter_mvvm_sample/ui/task_list/view_model/task_list_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TaskListScreen extends ConsumerWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(taskListViewModelProvider);
    final notifier = ref.read(taskListViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text('タスクリスト')),
      body: _TaskListBody(state: state, notifier: notifier),
    );
  }
}

class _TaskListBody extends StatelessWidget {
  const _TaskListBody({required this.state, required this.notifier});

  final TaskListState state;
  final TaskListViewModel notifier;

  @override
  Widget build(BuildContext context) {
    if (state.tasks.isEmpty && state.load.running) {
      return Center(child: const CircularProgressIndicator());
    }

    if (state.tasks.isEmpty && state.load.hasError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('データの取得に失敗しました'),
            ElevatedButton(onPressed: notifier.load, child: Text('再試行')),
          ],
        ),
      );
    }

    if (state.filteredTasks.isEmpty) {
      return const Center(child: Text('タスクがありません'));
    }
    return ListView.builder(
      itemCount: state.filteredTasks.length,
      itemBuilder: (context, index) {
        final task = state.filteredTasks[index];
        return ListTile(
          leading: Checkbox(value: task.isCompleted, onChanged: null),
          title: Text(task.title),
        );
      },
    );
  }
}
