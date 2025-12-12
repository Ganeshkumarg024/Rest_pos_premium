import 'dart:io';
import 'package:restaurant_billing/data/repositories/reports_repository.dart';
import 'package:restaurant_billing/presentation/providers/reports_provider.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';

class ReportCsvService {
  final ReportsRepository _repository = ReportsRepository();

  /// Generate a CSV file for sales report
  Future<String> generateSalesReportCSV({
    required DateRange dateRange,
  }) async {
    // Get all order items within date range
    final orderItems = await _repository.getOrderItemsForExport(
      startDate: dateRange.start,
      endDate: dateRange.end,
    );

    // Create CSV data
    List<List<dynamic>> csvData = [
      // Headers
      [
        'Order Date',
        'Order Time',
        'Order Number',
        'Item Name',
        'Quantity',
        'Unit Price',
        'Item Total',
        'Order Subtotal',
        'Tax',
        'Order Total',
        'Table',
      ],
    ];

    // Add data rows
    for (var item in orderItems) {
      final orderDate = DateTime.parse(item['order_created_at'] as String);
      
      csvData.add([
        DateFormat('yyyy-MM-dd').format(orderDate),
        DateFormat('HH:mm:ss').format(orderDate),
        item['order_number'] ?? '',
        item['item_name'] ?? '',
        item['quantity'] ?? 0,
        item['unit_price'] ?? 0.0,
        item['item_total'] ?? 0.0,
        item['order_subtotal'] ?? 0.0,
        item['order_tax'] ?? 0.0,
        item['order_total'] ?? 0.0,
        item['table_name'] ?? 'N/A',
      ]);
    }

    // Convert to CSV string
    String csv = const ListToCsvConverter().convert(csvData);
    return csv;
  }

  /// Generate a summary CSV with top selling items
  Future<String> generateTopItemsCSV({
    required DateRange dateRange,
  }) async {
    final topItems = await _repository.getTopSellingItems(limit: 100);

    List<List<dynamic>> csvData = [
      // Headers
      [
        'Rank',
        'Item Name',
        'Quantity Sold',
        'Total Revenue',
      ],
    ];

    // Add data rows
    int rank = 1;
    for (var item in topItems) {
      csvData.add([
        rank++,
        item['name'] ?? '',
        item['quantity_sold'] ?? 0,
        item['total_revenue'] ?? 0.0,
      ]);
    }

    String csv = const ListToCsvConverter().convert(csvData);
    return csv;
  }
}
