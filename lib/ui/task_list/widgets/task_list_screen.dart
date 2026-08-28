import 'package:flutter/material.dart';
import 'package:flutter_mvvm_sample/ui/task_list/view_model/task_list_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TaskListScreen extends ConsumerWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(taskListViewModelProvider);
    final viewModel = ref.read(taskListViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text('タスクリスト')),
      body: _TaskListBody(state: state, viewModel: viewModel),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          context.go('/tasks/new');
        },
      ),
    );
  }
}

class _TaskListBody extends StatelessWidget {
  const _TaskListBody({required this.state, required this.viewModel});

  final TaskListState state;
  final TaskListViewModel viewModel;

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
            ElevatedButton(onPressed: viewModel.load, child: Text('再試行')),
          ],
        ),
      );
    }

    return Column(
      children: [
        _TaskListBodyRow(viewModel: viewModel),
        Expanded(
          child: state.tasks.isEmpty
              ? Center(child: Text('タスクがありません'))
              : ListView.builder(
                  itemCount: state.filteredTasks.length,
                  itemBuilder: (context, index) {
                    final task = state.filteredTasks[index];
                    return ListTile(
                      onTap: () {
                        context.go('/tasks/${task.id}');
                      },
                      leading: Checkbox(
                        value: task.isCompleted,
                        onChanged: null,
                      ),
                      title: Text(task.title),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _TaskListBodyRow extends StatelessWidget {
  const _TaskListBodyRow({required this.viewModel});

  final TaskListViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            viewModel.setFilter(TaskFilter.all);
          },
          child: Text('すべて'),
        ),
        ElevatedButton(
          onPressed: () {
            viewModel.setFilter(TaskFilter.active);
          },
          child: Text('未完了'),
        ),
        ElevatedButton(
          onPressed: () {
            viewModel.setFilter(TaskFilter.completed);
          },
          child: Text('完了'),
        ),
      ],
    );
  }
}
