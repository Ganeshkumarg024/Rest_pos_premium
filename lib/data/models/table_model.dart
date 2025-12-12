import 'package:restaurant_billing/core/constants/db_constants.dart';

class TableModel {
  final int? id;
  final String tableNumber;
  final String? tableName;
  final int seats;
  final String status; // available, occupied, reserved
  final DateTime createdAt;

  TableModel({
    this.id,
    required this.tableNumber,
    this.tableName,
    this.seats = 4,
    this.status = 'available',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      if (id != null) DbConstants.columnId: id,
      DbConstants.columnTableNumber: tableNumber,
      DbConstants.columnTableName: tableName,
      DbConstants.columnTableSeats: seats,
      DbConstants.columnTableStatus: status,
      DbConstants.columnCreatedAt: createdAt.toIso8601String(),
    };
  }

  factory TableModel.fromMap(Map<String, dynamic> map) {
    return TableModel(
      id: map[DbConstants.columnId] as int?,
      tableNumber: map[DbConstants.columnTableNumber] as String,
      tableName: map[DbConstants.columnTableName] as String?,
      seats: map[DbConstants.columnTableSeats] as int? ?? 4,
      status: map[DbConstants.columnTableStatus] as String? ?? 'available',
      createdAt: DateTime.parse(map[DbConstants.columnCreatedAt] as String),
    );
  }

  TableModel copyWith({
    int? id,
    String? tableNumber,
    String? tableName,
    int? seats,
    String? status,
    DateTime? createdAt,
  }) {
    return TableModel(
      id: id ?? this.id,
      tableNumber: tableNumber ?? this.tableNumber,
      tableName: tableName ?? this.tableName,
      seats: seats ?? this.seats,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
