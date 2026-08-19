# flutter_mvvm_sample

[CI](https://github.com/yukimiyake0607/flutter_mvvm_sample/actions/workflows/ci.yml)

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



## 今後この README に足すこと

- 公式 Compass は `ChangeNotifier` + `provider` なのに、なぜ Riverpod にするか
- MVVM の使い勝手のよさとデメリット

