import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TaskListScreen extends ConsumerWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('タスクリスト')),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                context.go('/tasks/new');
              },
              child: Text('追加'),
            ),
            ElevatedButton(
              onPressed: () {
                context.go('/tasks/dummy');
              },
              child: Text('詳細へ'),
            ),
          ],
        ),
      ),
    );
  }
}
