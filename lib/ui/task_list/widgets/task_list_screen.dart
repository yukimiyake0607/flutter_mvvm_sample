import 'package:flutter/material.dart';
import 'package:flutter_mvvm_sample/ui/task_list/view_model/task_list_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Taskリストを表示するためのViewです。[TaskListViewModel]と1：1。
///
/// ViewにはRepository, Clientをimportさせません。
/// ナビゲーションはViewの責務としており、[TaskListViewModel]には書かない。
class TaskListScreen extends ConsumerWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(taskListViewModelProvider);
    final viewModel = ref.read(taskListViewModelProvider.notifier);

    // 削除ボタンタップ時に失敗した場合はここでSnackBarを表示させる。
    // なので呼び出し側ではawaitしない。
    ref.listen(taskListViewModelProvider, (previous, next) {
      // hasErrorがtrueとして残るとフィルタのたびにSnackBarが表示されるので、
      // previousの確認も入れてます。
      if (next.delete.hasError && previous?.delete.hasError != true) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('削除に失敗しました')));
      }
    });

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
        _TaskListBodyRow(filter: state.filter, viewModel: viewModel),
        Expanded(
          child: state.filteredTasks.isEmpty
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
                      trailing: IconButton(
                        onPressed: () {
                          viewModel.deleteTask(task.id);
                        },
                        icon: Icon(Icons.delete, color: Colors.red),
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
  const _TaskListBodyRow({required this.filter, required this.viewModel});

  final TaskFilter filter;
  final TaskListViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      runSpacing: 8,
      spacing: 8,
      children: [
        FilterChip(
          label: const Text('すべて'),
          selected: filter == TaskFilter.all,
          onSelected: (_) => viewModel.setFilter(TaskFilter.all),
        ),
        FilterChip(
          label: const Text('未完了'),
          selected: filter == TaskFilter.active,
          onSelected: (_) => viewModel.setFilter(TaskFilter.active),
        ),
        FilterChip(
          label: const Text('完了'),
          selected: filter == TaskFilter.completed,
          onSelected: (_) => viewModel.setFilter(TaskFilter.completed),
        ),
      ],
    );
  }
}
