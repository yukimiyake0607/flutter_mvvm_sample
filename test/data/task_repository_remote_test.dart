import 'package:flutter_mvvm_sample/data/model/task_dto.dart';
import 'package:flutter_mvvm_sample/data/repositories/task_repository_remote.dart';
import 'package:flutter_mvvm_sample/domain/models/task.dart';
import 'package:flutter_mvvm_sample/utils/result.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_task_api_client.dart';

void main() {
  test('getTasksはDtoをTaskに変換する', () async {
    final client = FakeTaskApiClient(
      seed: [
        TaskDto(
          id: '1',
          title: '仕事',
          body: '会議',
          completed: false,
          createdAt: DateTime(2026, 1, 1),
        ),
      ],
    );
    final repository = TaskRepositoryRemote(client);

    final result = await repository.getTasks();

    expect(result, isA<Ok<List<Task>>>());
    final tasks = (result as Ok<List<Task>>).value;
    expect(tasks.length, 1);
    expect(tasks.first.title, '仕事');
    expect(tasks.first.note, '会議');
    expect(tasks.first.isCompleted, isFalse);
  });
}
