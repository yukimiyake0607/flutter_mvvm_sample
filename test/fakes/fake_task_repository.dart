import 'package:flutter_mvvm_sample/data/repositories/task_repository.dart';
import 'package:flutter_mvvm_sample/domain/models/task.dart';
import 'package:flutter_mvvm_sample/utils/result.dart';

/// TaskRepositoryを実装したFake用Repositoryです。
///
/// Fakeが結果（成功または失敗）を返した時に、ViewModelのstateが
/// 想定通り変化するかを調べる用のRepositoryです。
class FakeTaskRepository implements TaskRepository {
  FakeTaskRepository({this.shouldFail = false, List<Task>? seed})
    : _cache = seed ?? [];

  List<Task> _cache;
  bool shouldFail;
  int createCallCount = 0;
  int getTasksCallCount = 0;
  int deleteCallCount = 0;

  @override
  Future<Result<Task>> createTask({
    required String title,
    required String note,
  }) async {
    createCallCount++;
    // 失敗かどうかはここで決める
    if (shouldFail) {
      return Result.error(Exception('失敗'));
    }

    // 本来はサーバーがidをつけますが、Fakeは適当でいいので固定。
    final task = Task(
      id: 'task-1',
      title: title,
      note: note,
      isCompleted: false,
      createdAt: DateTime(2026, 1, 1),
    );
    _cache = [..._cache, task];
    return Result.ok(task);
  }

  @override
  Future<Result<void>> deleteTask(String id) async {
    deleteCallCount++;
    if (shouldFail) {
      return Result.error(Exception('失敗'));
    }

    _cache = _cache.where((task) => task.id != id).toList();
    return Result.ok(null);
  }

  @override
  Future<Result<Task>> getTask(String id) {
    // TODO: implement getTask
    throw UnimplementedError();
  }

  @override
  Future<Result<List<Task>>> getTasks() async {
    getTasksCallCount++;

    if (shouldFail) {
      return Result.error(Exception('失敗'));
    }

    return Result.ok(List<Task>.from(_cache));
  }

  @override
  Future<Result<Task>> updateTask(Task task) {
    // TODO: implement updateTask
    throw UnimplementedError();
  }
}
