import 'package:restaurant_billing/core/constants/db_constants.dart';

class PaymentModel {
  final int? id;
  final int orderId;
  final String paymentMethod; // cash, card, upi
  final double amount;
  final DateTime createdAt;

  PaymentModel({
    this.id,
    required this.orderId,
    required this.paymentMethod,
    required this.amount,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      if (id != null) DbConstants.columnId: id,
      DbConstants.columnPaymentOrderId: orderId,
      DbConstants.columnPaymentMethod: paymentMethod,
      DbConstants.columnPaymentAmount: amount,
      DbConstants.columnCreatedAt: createdAt.toIso8601String(),
    };
  }

  factory PaymentModel.fromMap(Map<String, dynamic> map) {
    return PaymentModel(
      id: map[DbConstants.columnId] as int?,
      orderId: map[DbConstants.columnPaymentOrderId] as int,
      paymentMethod: map[DbConstants.columnPaymentMethod] as String,
      amount: (map[DbConstants.columnPaymentAmount] as num).toDouble(),
      createdAt: DateTime.parse(map[DbConstants.columnCreatedAt] as String),
    );
  }

  PaymentModel copyWith({
    int? id,
    int? orderId,
    String? paymentMethod,
    double? amount,
    DateTime? createdAt,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
