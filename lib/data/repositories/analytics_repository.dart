import 'package:restaurant_billing/data/database/database_helper.dart';

class AnalyticsRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Weekly/Monthly Sales Trends
  Future<List<Map<String, dynamic>>> getWeeklySalesTrend(DateTime startDate, DateTime endDate) async {
    final db = await _dbHelper.database;
    
    final result = await db.rawQuery('''
      SELECT 
        strftime('%Y-%W', created_at) as week,
        SUM(total_amount) as total_sales,
        COUNT(*) as order_count
      FROM orders
      WHERE strftime('%Y-%m-%d', created_at) >= strftime('%Y-%m-%d', ?)
        AND strftime('%Y-%m-%d', created_at) <= strftime('%Y-%m-%d', ?)
      GROUP BY week
      ORDER BY week ASC
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);
    
    return result;
  }

  Future<List<Map<String, dynamic>>> getMonthlySalesTrend(DateTime startDate, DateTime endDate) async {
    final db = await _dbHelper.database;
    
    final result = await db.rawQuery('''
      SELECT 
        strftime('%Y-%m', created_at) as month,
        SUM(total_amount) as total_sales,
        COUNT(*) as order_count
      FROM orders
      WHERE strftime('%Y-%m-%d', created_at) >= strftime('%Y-%m-%d', ?)
        AND strftime('%Y-%m-%d', created_at) <= strftime('%Y-%m-%d', ?)
      GROUP BY month
      ORDER BY month ASC
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);
    
    return result;
  }

  // Top Selling Items
  Future<List<Map<String, dynamic>>> getTopSellingItems({
    required DateTime startDate,
    required DateTime endDate,
    int limit = 10,
  }) async {
    final db = await _dbHelper.database;
    
    final result = await db.rawQuery('''
      SELECT 
        oi.menu_item_id,
        m.name as item_name,
        c.name as category,
        m.price,
        SUM(oi.quantity) as total_quantity,
        SUM(oi.quantity * oi.unit_price) as total_revenue,
        COUNT(DISTINCT oi.order_id) as order_count
      FROM order_items oi
      INNER JOIN menu_items m ON oi.menu_item_id = m.id
      INNER JOIN categories c ON m.category_id = c.id
      INNER JOIN orders o ON oi.order_id = o.id
      WHERE strftime('%Y-%m-%d', o.created_at) >= strftime('%Y-%m-%d', ?)
        AND strftime('%Y-%m-%d', o.created_at) <= strftime('%Y-%m-%d', ?)
      GROUP BY oi.menu_item_id
      ORDER BY total_quantity DESC
      LIMIT ?
    ''', [startDate.toIso8601String(), endDate.toIso8601String(), limit]);
    
    return result;
  }

  // Category Distribution for Pie Chart
  Future<List<Map<String, dynamic>>> getCategoryDistribution(DateTime startDate, DateTime endDate) async {
    final db = await _dbHelper.database;
    
    final result = await db.rawQuery('''
      SELECT 
        c.name as category,
        SUM(oi.quantity * oi.unit_price) as total_sales,
        SUM(oi.quantity) as total_quantity,
        COUNT(DISTINCT oi.order_id) as order_count
      FROM order_items oi
      INNER JOIN menu_items m ON oi.menu_item_id = m.id
      INNER JOIN categories c ON m.category_id = c.id
      INNER JOIN orders o ON oi.order_id = o.id
      WHERE strftime('%Y-%m-%d', o.created_at) >= strftime('%Y-%m-%d', ?)
        AND strftime('%Y-%m-%d', o.created_at) <= strftime('%Y-%m-%d', ?)
      GROUP BY c.id, c.name
      ORDER BY total_sales DESC
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);
    
    return result;
  }

  // Frequently Bought Together Analysis
  Future<List<Map<String, dynamic>>> getFrequentlyBoughtTogether({
    required DateTime startDate,
    required DateTime endDate,
    int limit = 10,
    double minSupport = 0.1, // 10% of orders
  }) async {
    final db = await _dbHelper.database;
    
    // First, get total order count
    final totalOrdersResult = await db.rawQuery('''
      SELECT COUNT(DISTINCT id) as total
      FROM orders
      WHERE strftime('%Y-%m-%d', created_at) >= strftime('%Y-%m-%d', ?)
        AND strftime('%Y-%m-%d', created_at) <= strftime('%Y-%m-%d', ?)
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);
    
    final totalOrders = totalOrdersResult.first['total'] as int;
    final minSupportCount = (totalOrders * minSupport).ceil();
    
    // Find item pairs that appear together
    final result = await db.rawQuery('''
      SELECT 
        a.menu_item_id as item1_id,
        b.menu_item_id as item2_id,
        m1.name as item1_name,
        m2.name as item2_name,
        COUNT(DISTINCT a.order_id) as pair_count,
        CAST(COUNT(DISTINCT a.order_id) AS REAL) / ? as support
      FROM order_items a
      INNER JOIN order_items b ON a.order_id = b.order_id AND a.menu_item_id < b.menu_item_id
      INNER JOIN menu_items m1 ON a.menu_item_id = m1.id
      INNER JOIN menu_items m2 ON b.menu_item_id = m2.id
      INNER JOIN orders o ON a.order_id = o.id
      WHERE strftime('%Y-%m-%d', o.created_at) >= strftime('%Y-%m-%d', ?)
        AND strftime('%Y-%m-%d', o.created_at) <= strftime('%Y-%m-%d', ?)
      GROUP BY a.menu_item_id, b.menu_item_id
      HAVING pair_count >= ?
      ORDER BY pair_count DESC, support DESC
      LIMIT ?
    ''', [totalOrders, startDate.toIso8601String(), endDate.toIso8601String(), minSupportCount, limit]);
    
    return result;
  }

  // Sales Summary Stats
  Future<Map<String, dynamic>> getSalesSummary(DateTime startDate, DateTime endDate) async {
    final db = await _dbHelper.database;
    
    final result = await db.rawQuery('''
      SELECT 
        COUNT(*) as total_orders,
        SUM(total_amount) as total_revenue,
        AVG(total_amount) as avg_order_value,
        MAX(total_amount) as max_order_value,
        MIN(total_amount) as min_order_value
      FROM orders
      WHERE strftime('%Y-%m-%d', created_at) >= strftime('%Y-%m-%d', ?)
        AND strftime('%Y-%m-%d', created_at) <= strftime('%Y-%m-%d', ?)
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);
    
    return result.first;
  }

  // Daily Sales Breakdown
  Future<List<Map<String, dynamic>>> getDailySales(DateTime startDate, DateTime endDate) async {
    final db = await _dbHelper.database;
    
    final result = await db.rawQuery('''
      SELECT 
        DATE(created_at) as date,
        SUM(total_amount) as total_sales,
        COUNT(*) as order_count,
        AVG(total_amount) as avg_order_value
      FROM orders
      WHERE strftime('%Y-%m-%d', created_at) >= strftime('%Y-%m-%d', ?)
        AND strftime('%Y-%m-%d', created_at) <= strftime('%Y-%m-%d', ?)
      GROUP BY date
      ORDER BY date ASC
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);
    
    return result;
  }

  // Peak Sales Hours
  Future<List<Map<String, dynamic>>> getPeakSalesHours(DateTime startDate, DateTime endDate) async {
    final db = await _dbHelper.database;
    
    final result = await db.rawQuery('''
      SELECT 
        strftime('%H', created_at) as hour,
        SUM(total_amount) as total_sales,
        COUNT(*) as order_count
      FROM orders
      WHERE strftime('%Y-%m-%d', created_at) >= strftime('%Y-%m-%d', ?)
        AND strftime('%Y-%m-%d', created_at) <= strftime('%Y-%m-%d', ?)
      GROUP BY hour
      ORDER BY total_sales DESC
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);
    
    return result;
  }
}
