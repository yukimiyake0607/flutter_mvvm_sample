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
  List<Task> _cache = [];

  @override
  Future<Result<Task>> createTask({
    required String title,
    required String note,
  }) {
    // TODO: implement createTask
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> deleteTask(String id) {
    // TODO: implement deleteTask
    throw UnimplementedError();
  }

  @override
  Future<Result<Task>> getTask(String id) {
    // TODO: implement getTask
    throw UnimplementedError();
  }

  @override
  Future<Result<List<Task>>> getTasks() {
    // TODO: implement getTasks
    throw UnimplementedError();
  }

  @override
  Future<Result<Task>> updateTask(Task task) {
    // TODO: implement updateTask
    throw UnimplementedError();
  }
}
