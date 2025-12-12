import 'package:restaurant_billing/core/constants/db_constants.dart';

class MenuItemModel {
  final int? id;
  final int categoryId;
  final String name;
  final String? description;
  final double price;
  final double taxPercentage;
  final bool allowDiscount;
  final String? imagePath;
  final bool isAvailable;
  final DateTime createdAt;

  // For display purposes (joined from category)
  final String? categoryName;

  MenuItemModel({
    this.id,
    required this.categoryId,
    required this.name,
    this.description,
    required this.price,
    this.taxPercentage = 10.0,
    this.allowDiscount = true,
    this.imagePath,
    this.isAvailable = true,
    DateTime? createdAt,
    this.categoryName,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      if (id != null) DbConstants.columnId: id,
      DbConstants.columnMenuItemCategoryId: categoryId,
      DbConstants.columnMenuItemName: name,
      DbConstants.columnMenuItemDescription: description,
      DbConstants.columnMenuItemPrice: price,
      DbConstants.columnMenuItemTaxPercentage: taxPercentage,
      DbConstants.columnMenuItemAllowDiscount: allowDiscount ? 1 : 0,
      DbConstants.columnMenuItemImagePath: imagePath,
      DbConstants.columnMenuItemIsAvailable: isAvailable ? 1 : 0,
      DbConstants.columnCreatedAt: createdAt.toIso8601String(),
    };
  }

  factory MenuItemModel.fromMap(Map<String, dynamic> map) {
    return MenuItemModel(
      id: map[DbConstants.columnId] as int?,
      categoryId: map[DbConstants.columnMenuItemCategoryId] as int,
      name: map[DbConstants.columnMenuItemName] as String,
      description: map[DbConstants.columnMenuItemDescription] as String?,
      price: (map[DbConstants.columnMenuItemPrice] as num).toDouble(),
      taxPercentage: (map[DbConstants.columnMenuItemTaxPercentage] as num?)?.toDouble() ?? 10.0,
      allowDiscount: (map[DbConstants.columnMenuItemAllowDiscount] as int?) == 1,
      imagePath: map[DbConstants.columnMenuItemImagePath] as String?,
      isAvailable: (map[DbConstants.columnMenuItemIsAvailable] as int?) == 1,
      createdAt: DateTime.parse(map[DbConstants.columnCreatedAt] as String),
      categoryName: map['category_name'] as String?,
    );
  }

  MenuItemModel copyWith({
    int? id,
    int? categoryId,
    String? name,
    String? description,
    double? price,
    double? taxPercentage,
    bool? allowDiscount,
    String? imagePath,
    bool? isAvailable,
    DateTime? createdAt,
    String? categoryName,
  }) {
    return MenuItemModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      taxPercentage: taxPercentage ?? this.taxPercentage,
      allowDiscount: allowDiscount ?? this.allowDiscount,
      imagePath: imagePath ?? this.imagePath,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      categoryName: categoryName ?? this.categoryName,
    );
  }
}
