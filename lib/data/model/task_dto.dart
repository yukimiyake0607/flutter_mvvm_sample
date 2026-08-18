import 'package:flutter_mvvm_sample/domain/models/task.dart';

/// APIが返す形をそのまま変換するDTOクラスです。
///
/// 実務ではAPIが返すレスポンスフィールドと、Domainクラスフィールド名は異なることが多々あるので、
/// それを想定してあえて[body], [completed]としました。
class TaskDto {
  const TaskDto({
    required this.id,
    required this.title,
    required this.body,
    required this.completed,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String body;
  final bool completed;
  final DateTime createdAt;

  /// TaskクラスからTaskDtoクラスを生成するためのfactoryコンストラクタ
  factory TaskDto.fromDomain(Task task) {
    return TaskDto(
      id: task.id,
      title: task.title,
      body: task.note,
      completed: task.isCompleted,
      createdAt: task.createdAt,
    );
  }

  /// TaskDtoクラスからTaskクラスを生成するためのインスタンスメソッド
  /// 
  /// ドメインモデルに変換する時に使用します。
  /// ViewModelはDtoのことを知らなくていいので、Data層で変換。
  Task toDomain() {
    return Task(
      id: id,
      title: title,
      note: body,
      isCompleted: completed,
      createdAt: createdAt,
    );
  }
}
