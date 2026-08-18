class Task {
  const Task({
    required this.id,
    required this.title,
    required this.note,
    required this.isCompleted,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String note;
  final bool isCompleted;
  final DateTime createdAt;

  /// 任意のフィールドのみを変更できるcopyWithメソッドです。
  ///
  /// 名前付きの任意引数にすることで、変更したいフィールドだけ渡せます。
  /// 渡さなかったフィールドは既存インスタンスの値を引き継ぎます。
  Task copyWith({
    String? id,
    String? title,
    String? note,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      note: note ?? this.note,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
