import 'package:flutter_mvvm_sample/data/model/task_dto.dart';

/// 内部リストからTaskDtoを返すクラスです。
///
/// 本来はサーバーとやりとりをして、DBからJSONを受け取りDtoに変換しますが、
/// ここではサーバーはないので、サーバーの役割もここで担います。
/// つまり、HTTPからJSONをもらってTaskDtoにするまでをこのクラスで完結させます。
/// ※300ms待って、通信っぽくする
class TaskApiClient {
  TaskApiClient()
    : _tasks = [
        TaskDto(
          id: '1',
          title: '仕事',
          body: '会議',
          completed: false,
          createdAt: DateTime(2026, 1, 1),
        ),
        TaskDto(
          id: '2',
          title: '散歩',
          body: '朝の散歩。30分くらい歩く。',
          completed: true,
          createdAt: DateTime(2026, 1, 2),
        ),
        TaskDto(
          id: '3',
          title: '食材を買いに行く',
          body: 'バナナ、ヨーグルト、米',
          completed: false,
          createdAt: DateTime(2026, 1, 3),
        ),
        TaskDto(
          id: '4',
          title: '読書',
          body: '積読している本を読む',
          completed: false,
          createdAt: DateTime(2026, 1, 4),
        ),
        TaskDto(
          id: '5',
          title: 'ジム',
          body: '',
          completed: true,
          createdAt: DateTime(2026, 1, 5),
        ),
      ];

  // サーバーのDBに入っている模擬データ
  final List<TaskDto> _tasks;

  //あとでUIから「次の通信を失敗させる」ために使う。
  bool shouldFail = false;

  /// 模擬的にAPIからデータを取得するメソッド。
  Future<List<TaskDto>> fetchTasks() async {
    await _waitCommunication();
    // このクラスでは追加・削除もするので、_tasksをコピーして返す。
    return List<TaskDto>.from(_tasks);
  }
  
  /// 模擬通信固有の処理を共通化。
  /// 
  /// - 300ms待つ
  /// - shouldFailがtrueの場合Exceptionを投げる
  Future<void> _waitCommunication() async {
    await Future.delayed(Duration(milliseconds: 300));
    if (shouldFail) {
      throw Exception('通信に失敗しました');
    }
  }
}
