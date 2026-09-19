# flutter_mvvm_sample

[![CI](https://github.com/yukimiyake0607/flutter_mvvm_sample/actions/workflows/ci.yml/badge.svg)](https://github.com/yukimiyake0607/flutter_mvvm_sample/actions/workflows/ci.yml)

Flutter 公式のレイヤード MVVM を、自分なりに解釈したRepositoryです。**どのクラスが何を担当し、データがどちら向きに流れるか** を優先的に実装。

```
View  →  ViewModel  →  Repository  →  Service
表示と操作     画面の状態      アプリ内の正     アプリの外
```

View は Repository を知りません。ViewModel は Service も DTO も知りません。タスクを変えてよいのは Repository だけです（SSOT）。ここは公式通りに設計してます。

---

## ドメインモデルと API モデル

モデルはDomain・Dtoの2つを用意。
今回は少々無理やり、note ↔︎ body、isCompleted ↔︎ completed と変化させています。
2 つに分けることで、API の都合を UI まで漏らさないようにでき、サーバーが JSON のキーを変えても、直すのは DTO と変換だけにできます。ただ、1に対して管理するモデルが2つになるので、実務の際は規模感などを基にトレードオフで導入検討すべきです。

- `Task`（`[lib/domain/models/task.dart](lib/domain/models/task.dart)`）  
  画面と ViewModel が見るモデルです。フィールドはアプリの言葉（`note` / `isCompleted`）です。不変で、更新は `copyWith` 。
- `TaskDto`（`[lib/data/model/task_dto.dart](lib/data/model/task_dto.dart)`）  
  API の形。実務ではレスポンス名とドメイン名がずれることが多いので、意図的に `body` / `completed` にしています。変換（`toDomain` / `fromDomain`）は Data 層に閉じ、ViewModel は `Task` だけを見る。

---

## 成功・失敗と、操作ごとの進行

- `Result`（`[lib/utils/result.dart](lib/utils/result.dart)`）  
  Data 層とのやり取りでは例外を画面まで投げずに、Resultクラスで表現。
- `CommandState`（`[lib/utils/command_state.dart](lib/utils/command_state.dart)`）  
  1 画面に「読み込み」と「削除」のように操作が複数あるときは、CommandStateで複数の状態を管理できるようにしています。公式 Compass の Command と同じ役割ですが、`ChangeNotifier` にはせず、Riverpod が差し替える不変値にします。

---

## Data層（MVVMのModel層）

公式 MVVM の Data（Model） 層は **Service** と **Repository** に分かれます。

- `TaskApiClient`（`[lib/data/services/task_api_client.dart](lib/data/services/task_api_client.dart)`）  
  アプリの外を 1 クラスに閉じます。本番なら HTTP、今はサーバーがないので遅延つきのインメモリです。返すのは `TaskDto` と例外だけ。
  ここに模擬DBも管理してます。（DB・サーバーがないので、実務では管理しないものも含まれてます）
- `TaskRepository`
  アプリ内の正です。Client を呼び、DTO を `Task` に変え、失敗を `Result` に変え、キャッシュします。ViewModelとのやりとりはここで。

---

## UI層（MVVMのViewとViewModel）

公式 MVVM の UI層は **View** と **ViewModel** に分かれています。
また、View と ViewModelは1：1にしています。つまり、ViewModelを複数のViewで使用することはしません。
Viewはnavigationなどを担当しますが、RepositoryとのやりとりはViewModelに任せます。
ViewModelとRepositoryはmany-to-manyです。実際に3画面で `[taskRepositoryProvider](lib/data/providers/task_repository_provider.dart)` を呼び出してます。

- `TaskListScreen` と `TaskListViewModel`
- `TaskDetailScreen` と `TaskDetailViewModel`
- `AddTaskScreen` と `AddTaskViewModel`

---

## テスト

層が分かれていることを示すために書きました。
各テストは1つ下の層だけFakeする。（ViewModelのテストはRepositoryのみFakeにする）

| 見る層 | 偽物 | 差し替え |
|---|---|---|
| ViewModel | `FakeTaskRepository` | `ProviderContainer` の `overrides` |
| View（一覧のみ） | 同じ Fake | `ProviderScope` の `overrides` |
| Repository | `FakeTaskApiClient` | コンストラクタ。Riverpod は使わない |

### Fakeを選んだ理由（Mockではないか）
公式Compassと同じくメモリ上のリストで実装したFakeを選択。
どちらでもテストは書けるのですが、今回テストで確認したかったのは呼び出し回数より、**契約どおりに `Result` が返るか**と、リストが本当に増減するかです。
※一部Fakeテストと比較するために`mocktail` は依存に残しています。

---

## 今後この README に足すこと

- 公式 Compass は `ChangeNotifier` + `provider` なのに、なぜ Riverpod にするか
- MVVM の使い勝手のよさとデメリット
