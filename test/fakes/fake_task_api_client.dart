import 'package:flutter_mvvm_sample/data/model/task_dto.dart';
import 'package:flutter_mvvm_sample/data/services/task_api_client.dart';

class FakeTaskApiClient extends TaskApiClient {
  FakeTaskApiClient({this.seed = const [], bool shouldFail = false}) {
    this.shouldFail = shouldFail;
  }
  List<TaskDto> seed;
  int fetchTasksCallCount = 0;

  @override
  Future<List<TaskDto>> fetchTasks() async {
    fetchTasksCallCount++;
    if (shouldFail) {
      throw Exception('失敗');
    }

    return List<TaskDto>.from(seed);
  }
}
