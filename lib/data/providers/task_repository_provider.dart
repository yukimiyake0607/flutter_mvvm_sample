import 'package:flutter_mvvm_sample/data/providers/task_api_client_provider.dart';
import 'package:flutter_mvvm_sample/data/repositories/task_repository.dart';
import 'package:flutter_mvvm_sample/data/repositories/task_repository_remote.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// TaskRepositoryを提供するProvider
///
/// テストでFakeに差し替えるため返す型は[TaskRepository]としています。
/// 画面を閉じてキャッシュが消えるのは困るので、autoDisposeにはしていません。
/// 
/// 公式Flutterアーキテクチャと同様に、層と層はコンストラクタ渡しでDIしています。
/// その証拠に[TaskRepositoryRemote]はClientの作り方を知りません。
/// ※依存を自分で作らず、外からもらう
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  // 依存が変わったら作り直したいので、readではなくwatchで繋ぐ
  final client = ref.watch(taskApiClientProvider);
  return TaskRepositoryRemote(client);
});
