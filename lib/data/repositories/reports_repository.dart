import 'package:restaurant_billing/data/database/database_helper.dart';
import 'package:restaurant_billing/core/constants/db_constants.dart';

class ReportsRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Get total sales for a period
  Future<double> getTotalSales({DateTime? startDate, DateTime? endDate}) async {
    final start = startDate ?? DateTime.now().subtract(const Duration(days: 1));
    final end = endDate ?? DateTime.now();

    final results = await _dbHelper.rawQuery('''
      SELECT SUM(${DbConstants.columnOrderTotalAmount}) as total
      FROM ${DbConstants.tableOrders}
      WHERE ${DbConstants.columnCreatedAt} >= ? 
      AND ${DbConstants.columnCreatedAt} <= ?
      AND ${DbConstants.columnOrderStatus} = 'completed'
    ''', [start.toIso8601String(), end.toIso8601String()]);

    return (results.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  // Get total orders count
  Future<int> getTotalOrders({DateTime? startDate, DateTime? endDate}) async {
    final start = startDate ?? DateTime.now().subtract(const Duration(days: 1));
    final end = endDate ?? DateTime.now();

    final results = await _dbHelper.rawQuery('''
      SELECT COUNT(*) as count
      FROM ${DbConstants.tableOrders}
      WHERE ${DbConstants.columnCreatedAt} >= ? 
      AND ${DbConstants.columnCreatedAt} <= ?
      AND ${DbConstants.columnOrderStatus} = 'completed'
    ''', [start.toIso8601String(), end.toIso8601String()]);

    return (results.first['count'] as int?) ?? 0;
  }

  // Get average order value
  Future<double> getAverageOrderValue({DateTime? startDate, DateTime? endDate}) async {
    final start = startDate ?? DateTime.now().subtract(const Duration(days: 1));
    final end = endDate ?? DateTime.now();

    final results = await _dbHelper.rawQuery('''
      SELECT AVG(${DbConstants.columnOrderTotalAmount}) as avg
      FROM ${DbConstants.tableOrders}
      WHERE ${DbConstants.columnCreatedAt} >= ? 
      AND ${DbConstants.columnCreatedAt} <= ?
      AND ${DbConstants.columnOrderStatus} = 'completed'
    ''', [start.toIso8601String(), end.toIso8601String()]);

    return (results.first['avg'] as num?)?.toDouble() ?? 0.0;
  }

  // Get total tax collected
  Future<double> getTotalTax({DateTime? startDate, DateTime? endDate}) async {
    final start = startDate ?? DateTime.now().subtract(const Duration(days: 1));
    final end = endDate ?? DateTime.now();

    final results = await _dbHelper.rawQuery('''
      SELECT SUM(${DbConstants.columnOrderTaxAmount}) as total
      FROM ${DbConstants.tableOrders}
      WHERE ${DbConstants.columnCreatedAt} >= ? 
      AND ${DbConstants.columnCreatedAt} <= ?
      AND ${DbConstants.columnOrderStatus} = 'completed'
    ''', [start.toIso8601String(), end.toIso8601String()]);

    return (results.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  // Get daily sales for the week
  Future<List<Map<String, dynamic>>> getWeeklySales() async {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    
    final results = await _dbHelper.rawQuery('''
      SELECT 
        DATE(${DbConstants.columnCreatedAt}) as date,
        SUM(${DbConstants.columnOrderTotalAmount}) as total
      FROM ${DbConstants.tableOrders}
      WHERE ${DbConstants.columnCreatedAt} >= ?
      AND ${DbConstants.columnOrderStatus} = 'completed'
      GROUP BY DATE(${DbConstants.columnCreatedAt})
      ORDER BY date ASC
    ''', [weekStart.toIso8601String()]);

    return results;
  }

  // Get top selling items
  Future<List<Map<String, dynamic>>> getTopSellingItems({int limit = 10}) async {
    final results = await _dbHelper.rawQuery('''
      SELECT 
        m.${DbConstants.columnId},
        m.${DbConstants.columnMenuItemName} as name,
        m.${DbConstants.columnMenuItemImagePath} as image_path,
        SUM(oi.${DbConstants.columnOrderItemQuantity}) as quantity_sold,
        SUM(oi.${DbConstants.columnOrderItemTotalPrice}) as total_revenue
      FROM ${DbConstants.tableOrderItems} oi
      INNER JOIN ${DbConstants.tableMenuItems} m 
        ON oi.${DbConstants.columnOrderItemMenuItemId} = m.${DbConstants.columnId}
      INNER JOIN ${DbConstants.tableOrders} o
        ON oi.${DbConstants.columnOrderItemOrderId} = o.${DbConstants.columnId}
      WHERE o.${DbConstants.columnOrderStatus} = 'completed'
      GROUP BY m.${DbConstants.columnId}
      ORDER BY quantity_sold DESC
      LIMIT ?
    ''', [limit]);

    return results;
  }

  // Get payment method breakdown
  Future<List<Map<String, dynamic>>> getPaymentMethodBreakdown() async {
    final results = await _dbHelper.rawQuery('''
      SELECT 
        ${DbConstants.columnPaymentMethod} as method,
        COUNT(*) as count,
        SUM(${DbConstants.columnPaymentAmount}) as total
      FROM ${DbConstants.tablePayments}
      GROUP BY ${DbConstants.columnPaymentMethod}
      ORDER BY total DESC
    ''');

    return results;
  }

  // Get sales comparison (current vs previous period)
  Future<Map<String, double>> getSalesComparison({
    required DateTime currentStart,
    required DateTime currentEnd,
  }) async {
    final duration = currentEnd.difference(currentStart);
    final previousStart = currentStart.subtract(duration);
    final previousEnd = currentStart;

    final currentSales = await getTotalSales(
      startDate: currentStart,
      endDate: currentEnd,
    );

    final previousSales = await getTotalSales(
      startDate: previousStart,
      endDate: previousEnd,
    );

    final change = previousSales > 0
        ? ((currentSales - previousSales) / previousSales) * 100
        : 0.0;

    return {
      'current': currentSales,
      'previous': previousSales,
      'change': change,
    };
  }

  // Get detailed order items for export
  Future<List<Map<String, dynamic>>> getOrderItemsForExport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final results = await _dbHelper.rawQuery('''
      SELECT 
        o.${DbConstants.columnCreatedAt} as order_created_at,
        o.${DbConstants.columnOrderNumber} as order_number,
        o.${DbConstants.columnOrderSubtotal} as order_subtotal,
        o.${DbConstants.columnOrderTaxAmount} as order_tax,
        o.${DbConstants.columnOrderTotalAmount} as order_total,
        t.${DbConstants.columnTableNumber} as table_name,
        m.${DbConstants.columnMenuItemName} as item_name,
        oi.${DbConstants.columnOrderItemQuantity} as quantity,
        oi.${DbConstants.columnOrderItemUnitPrice} as unit_price,
        oi.${DbConstants.columnOrderItemTotalPrice} as item_total
      FROM ${DbConstants.tableOrders} o
      INNER JOIN ${DbConstants.tableOrderItems} oi 
        ON o.${DbConstants.columnId} = oi.${DbConstants.columnOrderItemOrderId}
      INNER JOIN ${DbConstants.tableMenuItems} m 
        ON oi.${DbConstants.columnOrderItemMenuItemId} = m.${DbConstants.columnId}
      LEFT JOIN ${DbConstants.tableTables} t 
        ON o.${DbConstants.columnOrderTableId} = t.${DbConstants.columnId}
      WHERE o.${DbConstants.columnCreatedAt} >= ? 
        AND o.${DbConstants.columnCreatedAt} <= ?
        AND o.${DbConstants.columnOrderStatus} = 'completed'
      ORDER BY o.${DbConstants.columnCreatedAt} DESC, o.${DbConstants.columnId}, m.${DbConstants.columnMenuItemName}
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);

    return results;
  }
}
