import 'package:flutter_mvvm_sample/utils/result.dart';

/// 画面上の「1つの非同期操作」の進行状況。
///
/// 1画面に load と delete のように操作が複数あるとき、
/// 単一の isLoading では「初回読み込み中」と「行の削除中」を区別できない。
/// 操作ごとに [running] と [result] を持つことで、View は
/// `load.running` なら全面スピナー、`delete.running` ならその行だけ待つ、と分岐できる。
///
/// 公式 Compass の Command（ChangeNotifier）と同じ役割だが、
/// 購読は Riverpod の Notifier が state を差し替えたときに行うため、
/// このクラス自体は ChangeNotifier にしない。置き換えられる不変値として持つ。
///
/// [result] が null なのは、まだ一度も完了していないか、実行中で前回結果を消したとき。
/// 実行開始時は `CommandState(running: true)`（[result] はデフォルト null）を新しい state にする。
class CommandState<T> {
  const CommandState({this.result, this.running = false});

  /// この操作の直近の結果。未実行・実行中は null。
  final Result<T>? result;

  /// この操作が現在実行中なら true。連打防止にも使う。
  final bool running;

  /// 直近の結果が失敗なら true。View のエラー表示用。
  bool get hasError => result is Error<T>;

  /// 直近の結果が成功なら true。View の完了後ナビ用。
  bool get completed => result is Ok<T>;
}
