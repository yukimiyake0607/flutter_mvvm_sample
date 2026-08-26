import 'package:flutter_mvvm_sample/data/services/task_api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final taskApiClientProvider = Provider<TaskApiClient>((ref) {
  return TaskApiClient();
});
