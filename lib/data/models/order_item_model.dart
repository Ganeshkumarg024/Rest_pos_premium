import 'package:restaurant_billing/core/constants/db_constants.dart';

class OrderItemModel {
  final int? id;
  final int orderId;
  final int menuItemId;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final DateTime createdAt;

  // For display purposes
  final String? menuItemName;
  final String? menuItemDescription;

  OrderItemModel({
    this.id,
    required this.orderId,
    required this.menuItemId,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    DateTime? createdAt,
    this.menuItemName,
    this.menuItemDescription,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      if (id != null) DbConstants.columnId: id,
      DbConstants.columnOrderItemOrderId: orderId,
      DbConstants.columnOrderItemMenuItemId: menuItemId,
      DbConstants.columnOrderItemQuantity: quantity,
      DbConstants.columnOrderItemUnitPrice: unitPrice,
      DbConstants.columnOrderItemTotalPrice: totalPrice,
      DbConstants.columnCreatedAt: createdAt.toIso8601String(),
    };
  }

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      id: map[DbConstants.columnId] as int?,
      orderId: map[DbConstants.columnOrderItemOrderId] as int,
      menuItemId: map[DbConstants.columnOrderItemMenuItemId] as int,
      quantity: map[DbConstants.columnOrderItemQuantity] as int,
      unitPrice: (map[DbConstants.columnOrderItemUnitPrice] as num).toDouble(),
      totalPrice: (map[DbConstants.columnOrderItemTotalPrice] as num).toDouble(),
      createdAt: DateTime.parse(map[DbConstants.columnCreatedAt] as String),
      menuItemName: map[DbConstants.columnMenuItemName] as String?,
      menuItemDescription: map[DbConstants.columnMenuItemDescription] as String?,
    );
  }

  OrderItemModel copyWith({
    int? id,
    int? orderId,
    int? menuItemId,
    int? quantity,
    double? unitPrice,
    double? totalPrice,
    DateTime? createdAt,
    String? menuItemName,
    String? menuItemDescription,
  }) {
    return OrderItemModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      menuItemId: menuItemId ?? this.menuItemId,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      createdAt: createdAt ?? this.createdAt,
      menuItemName: menuItemName ?? this.menuItemName,
      menuItemDescription: menuItemDescription ?? this.menuItemDescription,
    );
  }
}
