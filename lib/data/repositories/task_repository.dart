import 'package:flutter_mvvm_sample/domain/models/task.dart';
import 'package:flutter_mvvm_sample/utils/result.dart';

/// ViewModelが呼ぶabstract Repositoryです。
///
/// ViewModelには責務の観点から例外を漏らしたくないため、
/// Repositoryでtry/catchしてResultに変換します。
abstract class TaskRepository {
  Future<Result<List<Task>>> getTasks();

  Future<Result<Task>> getTask(String id);

  Future<Result<Task>> createTask({
    required String title,
    required String note,
  });

  Future<Result<Task>> updateTask(Task task);

  Future<Result<void>> deleteTask(String id);
}
