import 'package:flutter_mvvm_sample/ui/add_task/widgets/add_task_screen.dart';
import 'package:flutter_mvvm_sample/ui/task_detail/widgets/task_detail_screen.dart';
import 'package:flutter_mvvm_sample/ui/task_list/widgets/task_list_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// routerを返すProviderを定義
/// 
/// Riverpodに何をいつ作るかを伝えるためにProviderのコールバックの中でGoRouterを生成。
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) {
          return const TaskListScreen();
        },
        routes: [
          GoRoute(
            path: 'tasks/new',
            builder: (context, state) {
              return AddTaskScreen();
            },
          ),
          GoRoute(
            path: 'tasks/:id',
            builder: (context, state) {
              final detailId = state.pathParameters['id']!;
              return TaskDetailScreen(id: detailId);
            },
          ),
        ],
      ),
    ],
  );
});
