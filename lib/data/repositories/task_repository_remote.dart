import 'package:flutter_mvvm_sample/data/repositories/task_repository.dart';
import 'package:flutter_mvvm_sample/data/services/task_api_client.dart';
import 'package:flutter_mvvm_sample/domain/models/task.dart';
import 'package:flutter_mvvm_sample/utils/result.dart';

class TaskRepositoryRemote implements TaskRepository {
  TaskRepositoryRemote(this._taskApiClient);

  final TaskApiClient _taskApiClient;

  /// メモリキャッシュ用のListです。
  ///
  /// RepositoryはSSOTの役割なので、Taskを唯一触れるのはここだけ。
  /// 外部からは変換できないようにプライベートフィールドとして持つ。
  List<Task>? _cache;

  @override
  Future<Result<Task>> createTask({
    required String title,
    required String note,
  }) async {
    try {
      final taskDto = await _taskApiClient.createTask(title: title, note: note);
      final task = taskDto.toDomain();

      if (_cache != null && _cache!.isNotEmpty) {
        _cache = [..._cache!, task];
      } else {
        _cache = [task];
      }

      return Result.ok(task);
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  @override
  Future<Result<void>> deleteTask(String id) {
    // TODO: implement deleteTask
    throw UnimplementedError();
  }

  @override
  Future<Result<Task>> getTask(String id) async {
    try {
      // キャッシュの中にある場合は、外部APIを叩かない
      final taskInCache = _cache?.where((t) => t.id == id).firstOrNull;
      if (taskInCache != null) return Result.ok(taskInCache);

      final taskDto = await _taskApiClient.fetchTask(id);
      final task = taskDto.toDomain();

      _cache = [...?_cache, task];

      return Result.ok(task);
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  @override
  Future<Result<List<Task>>> getTasks() async {
    try {
      final dtoTasks = await _taskApiClient.fetchTasks();
      final tasks = dtoTasks.map((dtoTask) => dtoTask.toDomain()).toList();

      // 取得されたデータをキャッシュに保管
      _cache = tasks;

      // 返すリストをそのまま渡すのではなく、コピーを渡す（SSOT）
      return Result.ok(List<Task>.from(tasks));
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  @override
  Future<Result<Task>> updateTask(Task task) {
    // TODO: implement updateTask
    throw UnimplementedError();
  }
}
