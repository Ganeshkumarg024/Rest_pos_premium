import 'package:restaurant_billing/data/database/database_helper.dart';
import 'package:restaurant_billing/data/models/order_model.dart';
import 'package:restaurant_billing/data/models/order_item_model.dart';
import 'package:restaurant_billing/data/models/payment_model.dart';
import 'package:restaurant_billing/core/constants/db_constants.dart';

class OrderRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Order operations
  Future<int> createOrder(OrderModel order) async {
    return await _dbHelper.insert(
      DbConstants.tableOrders,
      order.toMap(),
    );
  }

  Future<List<OrderModel>> getAllOrders() async {
    final results = await _dbHelper.rawQuery('''
      SELECT o.*, t.${DbConstants.columnTableName}
      FROM ${DbConstants.tableOrders} o
      LEFT JOIN ${DbConstants.tableTables} t
      ON o.${DbConstants.columnOrderTableId} = t.${DbConstants.columnId}
      ORDER BY o.${DbConstants.columnCreatedAt} DESC
    ''');

    return results.map((map) => OrderModel.fromMap(map)).toList();
  }

  Future<List<OrderModel>> getOrdersByStatus(String status) async {
    final results = await _dbHelper.rawQuery('''
      SELECT o.*, t.${DbConstants.columnTableName}
      FROM ${DbConstants.tableOrders} o
      LEFT JOIN ${DbConstants.tableTables} t
      ON o.${DbConstants.columnOrderTableId} = t.${DbConstants.columnId}
      WHERE o.${DbConstants.columnOrderStatus} = ?
      ORDER BY o.${DbConstants.columnCreatedAt} DESC
    ''', [status]);

    return results.map((map) => OrderModel.fromMap(map)).toList();
  }

  Future<OrderModel?> getOrderById(int id) async {
    final results = await _dbHelper.rawQuery('''
      SELECT o.*, t.${DbConstants.columnTableName}
      FROM ${DbConstants.tableOrders} o
      LEFT JOIN ${DbConstants.tableTables} t
      ON o.${DbConstants.columnOrderTableId} = t.${DbConstants.columnId}
      WHERE o.${DbConstants.columnId} = ?
    ''', [id]);

    if (results.isEmpty) return null;
    
    final order = OrderModel.fromMap(results.first);
    final items = await getOrderItems(id);
    
    return order.copyWith(items: items);
  }

  Future<OrderModel?> getOrderByNumber(String orderNumber) async {
    final results = await _dbHelper.rawQuery('''
      SELECT o.*, t.${DbConstants.columnTableName}
      FROM ${DbConstants.tableOrders} o
      LEFT JOIN ${DbConstants.tableTables} t
      ON o.${DbConstants.columnOrderTableId} = t.${DbConstants.columnId}
      WHERE o.${DbConstants.columnOrderNumber} = ?
    ''', [orderNumber]);

    if (results.isEmpty) return null;
    return OrderModel.fromMap(results.first);
  }

  Future<int> updateOrder(OrderModel order) async {
    return await _dbHelper.update(
      DbConstants.tableOrders,
      order.toMap(),
      where: '${DbConstants.columnId} = ?',
      whereArgs: [order.id],
    );
  }

  Future<int> updateOrderStatus(int id, String status) async {
    final data = {
      DbConstants.columnOrderStatus: status,
    };
    
    if (status == 'completed') {
      data[DbConstants.columnOrderCompletedAt] = DateTime.now().toIso8601String();
    }

    return await _dbHelper.update(
      DbConstants.tableOrders,
      data,
      where: '${DbConstants.columnId} = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteOrder(int id) async {
    return await _dbHelper.delete(
      DbConstants.tableOrders,
      where: '${DbConstants.columnId} = ?',
      whereArgs: [id],
    );
  }

  // Order item operations
  Future<int> createOrderItem(OrderItemModel orderItem) async {
    return await _dbHelper.insert(
      DbConstants.tableOrderItems,
      orderItem.toMap(),
    );
  }

  Future<List<OrderItemModel>> getOrderItems(int orderId) async {
    final results = await _dbHelper.rawQuery('''
      SELECT oi.*, m.${DbConstants.columnMenuItemName}, m.${DbConstants.columnMenuItemDescription}
      FROM ${DbConstants.tableOrderItems} oi
      LEFT JOIN ${DbConstants.tableMenuItems} m
      ON oi.${DbConstants.columnOrderItemMenuItemId} = m.${DbConstants.columnId}
      WHERE oi.${DbConstants.columnOrderItemOrderId} = ?
      ORDER BY oi.${DbConstants.columnCreatedAt} ASC
    ''', [orderId]);

    return results.map((map) => OrderItemModel.fromMap(map)).toList();
  }

  Future<int> deleteOrderItem(int id) async {
    return await _dbHelper.delete(
      DbConstants.tableOrderItems,
      where: '${DbConstants.columnId} = ?',
      whereArgs: [id],
    );
  }

  // Payment operations
  Future<int> createPayment(PaymentModel payment) async {
    return await _dbHelper.insert(
      DbConstants.tablePayments,
      payment.toMap(),
    );
  }

  Future<List<PaymentModel>> getPaymentsByOrder(int orderId) async {
    final results = await _dbHelper.query(
      DbConstants.tablePayments,
      where: '${DbConstants.columnPaymentOrderId} = ?',
      whereArgs: [orderId],
    );

    return results.map((map) => PaymentModel.fromMap(map)).toList();
  }

  // Analytics
  Future<Map<String, dynamic>> getTodayStats() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day).toIso8601String();

    // Total sales
    final salesResult = await _dbHelper.rawQuery('''
      SELECT SUM(${DbConstants.columnOrderTotalAmount}) as total
      FROM ${DbConstants.tableOrders}
      WHERE ${DbConstants.columnOrderStatus} = 'completed'
      AND ${DbConstants.columnCreatedAt} >= ?
    ''', [startOfDay]);

    final totalSales = (salesResult.first['total'] as num?)?.toDouble() ?? 0.0;

    // Active orders
    final activeResult = await _dbHelper.rawQuery('''
      SELECT COUNT(*) as count
      FROM ${DbConstants.tableOrders}
      WHERE ${DbConstants.columnOrderStatus} = 'open'
    ''');

    final activeOrders = activeResult.first['count'] as int? ?? 0;

    // Pending payments (completed orders without payments)
    final pendingResult = await _dbHelper.rawQuery('''
      SELECT COUNT(*) as count
      FROM ${DbConstants.tableOrders}
      WHERE ${DbConstants.columnOrderStatus} = 'completed'
      AND ${DbConstants.columnId} NOT IN (
        SELECT DISTINCT ${DbConstants.columnPaymentOrderId}
        FROM ${DbConstants.tablePayments}
      )
    ''');

    final pendingPayments = pendingResult.first['count'] as int? ?? 0;

    return {
      'totalSales': totalSales,
      'activeOrders': activeOrders,
      'pendingPayments': pendingPayments,
    };
  }

  Future<String> generateOrderNumber() async {
    final now = DateTime.now();
    final prefix = 'ORD${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    
    final results = await _dbHelper.rawQuery('''
      SELECT COUNT(*) as count
      FROM ${DbConstants.tableOrders}
      WHERE ${DbConstants.columnOrderNumber} LIKE ?
    ''', ['$prefix%']);

    final count = (results.first['count'] as int? ?? 0) + 1;
    return '$prefix${count.toString().padLeft(4, '0')}';
  }
}
