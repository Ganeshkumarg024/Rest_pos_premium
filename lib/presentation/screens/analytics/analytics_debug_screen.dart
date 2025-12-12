import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restaurant_billing/data/database/database_helper.dart';

class AnalyticsDebugScreen extends ConsumerWidget {
  const AnalyticsDebugScreen({super.key});

  Future<Map<String, dynamic>> _debugQueries() async {
    final db = await DatabaseHelper.instance.database;
    
    // Check if orders exist
    final ordersResult = await db.rawQuery('SELECT COUNT(*) as count FROM orders');
    final ordersCount = ordersResult.first['count'] as int;
    
    // Check if order_items exist
    final orderItemsResult = await db.rawQuery('SELECT COUNT(*) as count FROM order_items');
    final orderItemsCount = orderItemsResult.first['count'] as int;
    
    // Check date range of orders
    final dateRangeResult = await db.rawQuery('''
      SELECT 
        MIN(created_at) as earliest,
        MAX(created_at) as latest
      FROM orders
    ''');
    
    // Get sample analytics data
    final analyticsResult = await db.rawQuery('''
      SELECT 
        o.id as order_id,
        o.created_at,
        o.total_amount,
        COUNT(oi.id) as item_count
      FROM orders o
      LEFT JOIN order_items oi ON o.id = oi.order_id
      GROUP BY o.id
      LIMIT 5
    ''');
    
    return {
      'orders_count': ordersCount,
      'order_items_count': orderItemsCount,
      'date_range': dateRangeResult.first,
      'sample_orders': analyticsResult,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics Debug')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _debugQueries(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          
          final data = snapshot.data!;
          
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildCard('Orders Count', data['orders_count'].toString()),
              _buildCard('Order Items Count', data['order_items_count'].toString()),
              _buildCard('Earliest Order', data['date_range']['earliest']?.toString() ?? 'None'),
              _buildCard('Latest Order', data['date_range']['latest']?.toString() ?? 'None'),
              const SizedBox(height: 16),
              const Text('Sample Orders:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ...((data['sample_orders'] as List).map((order) => Card(
                child: ListTile(
                  title: Text('Order ${order['order_id']}'),
                  subtitle: Text('Date: ${order['created_at']}\nAmount: ₹${order['total_amount']}\nItems: ${order['item_count']}'),
                ),
              ))),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCard(String label, String value) {
    return Card(
      child: ListTile(
        title: Text(label),
        trailing: Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
