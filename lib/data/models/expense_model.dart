class ExpenseModel {
  final int? id;
  final String category;
  final double amount;
  final DateTime date;
  final String? description;
  final String paymentMethod;
  final DateTime createdAt;

  ExpenseModel({
    this.id,
    required this.category,
    required this.amount,
    required this.date,
    this.description,
    this.paymentMethod = 'Cash',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(),
      'description': description,
      'payment_method': paymentMethod,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'] as int?,
      category: map['category'] as String,
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      description: map['description'] as String?,
      paymentMethod: map['payment_method'] as String? ?? 'Cash',
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  ExpenseModel copyWith({
    int? id,
    String? category,
    double? amount,
    DateTime? date,
    String? description,
    String? paymentMethod,
    DateTime? createdAt,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      description: description ?? this.description,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
