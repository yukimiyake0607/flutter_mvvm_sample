# flutter_mvvm_sample

[![CI](https://github.com/yukimiyake0607/flutter_mvvm_sample/actions/workflows/ci.yml/badge.svg)](https://github.com/yukimiyake0607/flutter_mvvm_sample/actions/workflows/ci.yml)

Flutter 公式のレイヤード MVVM を、自分なりに解釈したRepositoryです。**どのクラスが何を担当し、データがどちら向きに流れるか** を優先的に実装。

```
View  →  ViewModel  →  Repository  →  Service
表示と操作     画面の状態      アプリ内の正     アプリの外
```

View は Repository を知りません。ViewModel は Service も DTO も知りません。タスクを変えてよいのは Repository だけです（SSOT）。ここは公式通りに設計してます。

---

## UI層（MVVMのViewとViewModel）

公式 MVVM の UI層は **View** と **ViewModel** に分かれています。
また、View と ViewModelは1：1にしています。つまり、ViewModelを複数のViewで使用することはしません。
ViewはnavigationやSnackBarなど、`context` が必要な処理を担当します。RepositoryとのやりとりはViewModelに任せます。
View が [`taskRepositoryProvider`](lib/data/providers/task_repository_provider.dart) を watch / read してはいけません。Riverpod の `Provider` は DI、`Notifier` は画面の状態です。View が Repository を見ると ViewModel を飛ばし、層の境界と「1つ下だけ Fake」するテストが壊れます。<br>
ViewModelとRepositoryはmany-to-manyです。実際に3画面の ViewModel が同じ `taskRepositoryProvider` を呼び出しています。

- `TaskListScreen` と `TaskListViewModel`
- `TaskDetailScreen` と `TaskDetailViewModel`
- `AddTaskScreen` と `AddTaskViewModel`

---

## Data層（MVVMのModel層）

公式 MVVM の Data（Model） 層は **Service** と **Repository** に分かれます。

- `TaskApiClient`（`[lib/data/services/task_api_client.dart](lib/data/services/task_api_client.dart)`）  
  アプリの外を 1 クラスに閉じます。本番なら HTTP、今はサーバーがないので遅延つきのインメモリです。返すのは `TaskDto` と例外だけ。
  ここに模擬DBも管理してます。（DB・サーバーがないので、実務では管理しないものも含まれてます）
- `TaskRepository`
  アプリ内の正です。Client を呼び、DTO を `Task` に変え、失敗を `Result` に変え、キャッシュします。ViewModelとのやりとりはここで。

---

## Domain層（Usecase）は置かない

公式では任意の層となっています。
複数Repositoryをまたぐとき、複雑な処理や複数のViewModelで再利用する時に足しますが、このリポジトリでは必要ないので足していません。

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

## 公式 Compass との差分

責務とデータの矢印（View → ViewModel → Repository → Service）は公式どおりです。差し替えているのは状態管理と DI の手段だけです。

| 箇所       | 公式 Compass                            | このリポジトリ                              |
| ---------- | --------------------------------------- | ------------------------------------------- |
| 状態の購読 | `ChangeNotifier` + `ListenableBuilder`  | `Notifier` + `ref.watch`                    |
| DI         | `package:provider` のコンストラクタ注入 | Riverpod の `Provider` / `NotifierProvider` |
| Command    | `Command` が `ChangeNotifier`           | 不変値の `CommandState`                     |

公式 Compass は `ChangeNotifier` + `provider` なのに Riverpod にする理由は、実務ではほとんどChangeNotifierを使用しないからなのと、DIと状態管理をまとめてできるためです。
層の役割は変えず、View が状態を購読する手段だけを替えます。`ChangeNotifier` と Riverpod を混在させません。

---

## テスト

層が分かれていることを示すために書きました。
各テストは1つ下の層だけFakeする。（ViewModelのテストはRepositoryのみFakeにする）
ViewModel は `TaskRepository` しか知らないので、ViewModel テストで override するのは `taskRepositoryProvider` です。`FakeTaskApiClient` は Repository テスト用で、ViewModel テストには不要です。ViewModel が Service まで知ると両方の Fake が必要になり、テストが複雑になります。

| 見る層           | 偽物                 | 差し替え                            |
| ---------------- | -------------------- | ----------------------------------- |
| ViewModel        | `FakeTaskRepository` | `ProviderContainer` の `overrides`  |
| View（一覧のみ） | 同じ Fake            | `ProviderScope` の `overrides`      |
| Repository       | `FakeTaskApiClient`  | コンストラクタ。Riverpod は使わない |

### Fakeを選んだ理由（Mockではないか）

公式Compassと同じくメモリ上のリストで実装したFakeを選択。
どちらでもテストは書けるのですが、今回テストで確認したかったのは呼び出し回数より、**契約どおりに `Result` が返るか**と、リストが本当に増減するかです。<br>
※一部Fakeテストと比較するために`mocktail` は依存に残しています。

---

## MVVMの所感

### 使い勝手の良さ

「UIである View」と「状態と操作を持つ ViewModel」に切ることで、ロジックが Widget に漏れにくく、層ごとにテストしやすかったです。<br>
呼び出す側が下の層のインスタンスを用意するのではなく、Provider が組み立ててコンストラクタで渡すのでテストで1 つ下だけ Fake に差し替えられます。<br>
Riverpod の `NotifierProvider` があるので、ViewModel作成の容易性もありFlutter との相性はいいと思いました。<br>
公式が勧めているかつ、実務の状態管理とも載せやすいのが現場でよく見る理由だと思います。<br>
※MVCはWidgetにロジックが寄りやすいので、個人的にはMVVMの方が好みです。

### デメリット

正直この規模のアプリであればMVVMのデメリットは感じにくいです。ただし、出てくるとしたら次のような点かと思います。

- ファイルと手順が増える：画面を1つ足すとView、ViewModel、Stateなどが一気に増えます。小さな機能の場合過剰になりそう。
- 1 つの変更が複数ファイルに飛ぶ：層を切っているために画面の項目追加で DTO・Domain・Repository・ViewModel・View にまたがることがありそう。
- ViewModel が厚くなりやすい： 複数 Repository をまたぐ処理や、複数画面で同じ業務ルールが必要になると、公式は UseCase（Domain 層）を検討しろと言ってます。その見極め基準をチーム内でコーディング規約等（今だとrulesで検知できますが）で共有しないと、少しずつ崩れていきます。
