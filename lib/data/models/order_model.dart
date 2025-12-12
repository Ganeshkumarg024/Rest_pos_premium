import 'package:restaurant_billing/core/constants/db_constants.dart';
import 'order_item_model.dart';

class OrderModel {
  final int? id;
  final String orderNumber;
  final int? tableId;
  final String orderType; // dine_in, takeaway, delivery
  final String status; // open, completed, cancelled
  final double subtotal;
  final double discountAmount;
  final double taxAmount;
  final double totalAmount;
  final DateTime createdAt;
  final DateTime? completedAt;

  // For display purposes
  final String? tableName;
  final List<OrderItemModel>? items;

  OrderModel({
    this.id,
    required this.orderNumber,
    this.tableId,
    required this.orderType,
    this.status = 'open',
    this.subtotal = 0.0,
    this.discountAmount = 0.0,
    this.taxAmount = 0.0,
    this.totalAmount = 0.0,
    DateTime? createdAt,
    this.completedAt,
    this.tableName,
    this.items,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      if (id != null) DbConstants.columnId: id,
      DbConstants.columnOrderNumber: orderNumber,
      DbConstants.columnOrderTableId: tableId,
      DbConstants.columnOrderType: orderType,
      DbConstants.columnOrderStatus: status,
      DbConstants.columnOrderSubtotal: subtotal,
      DbConstants.columnOrderDiscountAmount: discountAmount,
      DbConstants.columnOrderTaxAmount: taxAmount,
      DbConstants.columnOrderTotalAmount: totalAmount,
      DbConstants.columnCreatedAt: createdAt.toIso8601String(),
      DbConstants.columnOrderCompletedAt: completedAt?.toIso8601String(),
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map[DbConstants.columnId] as int?,
      orderNumber: map[DbConstants.columnOrderNumber] as String,
      tableId: map[DbConstants.columnOrderTableId] as int?,
      orderType: map[DbConstants.columnOrderType] as String,
      status: map[DbConstants.columnOrderStatus] as String? ?? 'open',
      subtotal: (map[DbConstants.columnOrderSubtotal] as num?)?.toDouble() ?? 0.0,
      discountAmount: (map[DbConstants.columnOrderDiscountAmount] as num?)?.toDouble() ?? 0.0,
      taxAmount: (map[DbConstants.columnOrderTaxAmount] as num?)?.toDouble() ?? 0.0,
      totalAmount: (map[DbConstants.columnOrderTotalAmount] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(map[DbConstants.columnCreatedAt] as String),
      completedAt: map[DbConstants.columnOrderCompletedAt] != null
          ? DateTime.parse(map[DbConstants.columnOrderCompletedAt] as String)
          : null,
      tableName: map[DbConstants.columnTableName] as String?,
    );
  }

  OrderModel copyWith({
    int? id,
    String? orderNumber,
    int? tableId,
    String? orderType,
    String? status,
    double? subtotal,
    double? discountAmount,
    double? taxAmount,
    double? totalAmount,
    DateTime? createdAt,
    DateTime? completedAt,
    String? tableName,
    List<OrderItemModel>? items,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      tableId: tableId ?? this.tableId,
      orderType: orderType ?? this.orderType,
      status: status ?? this.status,
      subtotal: subtotal ?? this.subtotal,
      discountAmount: discountAmount ?? this.discountAmount,
      taxAmount: taxAmount ?? this.taxAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      tableName: tableName ?? this.tableName,
      items: items ?? this.items,
    );
  }
}
