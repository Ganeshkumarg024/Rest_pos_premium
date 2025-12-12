class TodoModel {
  final int? id;
  final String title;
  final String? description;
  final bool isCompleted;
  final DateTime createdAt;
  final int? relatedExpenseId;

  TodoModel({
    this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    DateTime? createdAt,
    this.relatedExpenseId,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted ? 1 : 0,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'relatedExpenseId': relatedExpenseId,
    };
  }

  factory TodoModel.fromMap(Map<String, dynamic> map) {
    return TodoModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String?,
      isCompleted: (map['isCompleted'] as int) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      relatedExpenseId: map['relatedExpenseId'] as int?,
    );
  }

  TodoModel copyWith({
    int? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
    int? relatedExpenseId,
  }) {
    return TodoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      relatedExpenseId: relatedExpenseId ?? this.relatedExpenseId,
    );
  }
}
