import 'package:restaurant_billing/core/constants/db_constants.dart';

class CategoryModel {
  final int? id;
  final String name;
  final int displayOrder;
  final DateTime createdAt;

  CategoryModel({
    this.id,
    required this.name,
    this.displayOrder = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      if (id != null) DbConstants.columnId: id,
      DbConstants.columnCategoryName: name,
      DbConstants.columnCategoryDisplayOrder: displayOrder,
      DbConstants.columnCreatedAt: createdAt.toIso8601String(),
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map[DbConstants.columnId] as int?,
      name: map[DbConstants.columnCategoryName] as String,
      displayOrder: map[DbConstants.columnCategoryDisplayOrder] as int? ?? 0,
      createdAt: DateTime.parse(map[DbConstants.columnCreatedAt] as String),
    );
  }

  CategoryModel copyWith({
    int? id,
    String? name,
    int? displayOrder,
    DateTime? createdAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      displayOrder: displayOrder ?? this.displayOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
