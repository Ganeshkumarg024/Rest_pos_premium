import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restaurant_billing/data/repositories/reports_repository.dart';

// Repository provider
final reportsRepositoryProvider = Provider((ref) => ReportsRepository());

// Reports data model
class ReportsData {
  final double totalSales;
  final int totalOrders;
  final double averageOrderValue;
  final double totalTax;
  final double salesChange;
  final List<DailySales> weeklySales;
  final List<TopSellingItem> topItems;
  final List<PaymentMethodStat> paymentMethods;

  ReportsData({
    required this.totalSales,
    required this.totalOrders,
    required this.averageOrderValue,
    required this.totalTax,
    required this.salesChange,
    required this.weeklySales,
    required this.topItems,
    required this.paymentMethods,
  });
}

class DailySales {
  final DateTime date;
  final double amount;

  DailySales({required this.date, required this.amount});
}

class TopSellingItem {
  final int id;
  final String name;
  final int quantitySold;
  final double totalRevenue;
  final String? imagePath;

  TopSellingItem({
    required this.id,
    required this.name,
    required this.quantitySold,
    required this.totalRevenue,
    this.imagePath,
  });
}

class PaymentMethodStat {
  final String method;
  final int count;
  final double total;

  PaymentMethodStat({
    required this.method,
    required this.count,
    required this.total,
  });
}

// Reports provider
final reportsProvider = FutureProvider.family<ReportsData, DateRange>((ref, dateRange) async {
  final repository = ref.read(reportsRepositoryProvider);

  // Fetch all data in parallel
  final results = await Future.wait([
    repository.getTotalSales(startDate: dateRange.start, endDate: dateRange.end),
    repository.getTotalOrders(startDate: dateRange.start, endDate: dateRange.end),
    repository.getAverageOrderValue(startDate: dateRange.start, endDate: dateRange.end),
    repository.getTotalTax(startDate: dateRange.start, endDate: dateRange.end),
    repository.getSalesComparison(currentStart: dateRange.start, currentEnd: dateRange.end),
    repository.getWeeklySales(),
    repository.getTopSellingItems(limit: 5),
    repository.getPaymentMethodBreakdown(),
  ]);

  final salesComparison = results[4] as Map<String, double>;
  final weeklySalesData = results[5] as List<Map<String, dynamic>>;
  final topItemsData = results[6] as List<Map<String, dynamic>>;
  final paymentMethodsData = results[7] as List<Map<String, dynamic>>;

  return ReportsData(
    totalSales: results[0] as double,
    totalOrders: results[1] as int,
    averageOrderValue: results[2] as double,
    totalTax: results[3] as double,
    salesChange: salesComparison['change'] ?? 0.0,
    weeklySales: weeklySalesData
        .map((e) => DailySales(
              date: DateTime.parse(e['date'] as String),
              amount: (e['total'] as num?)?.toDouble() ?? 0.0,
            ))
        .toList(),
    topItems: topItemsData
        .map((e) => TopSellingItem(
              id: e['id'] as int,
              name: e['name'] as String,
              quantitySold: e['quantity_sold'] as int,
              totalRevenue: (e['total_revenue'] as num?)?.toDouble() ?? 0.0,
              imagePath: e['image_path'] as String?,
            ))
        .toList(),
    paymentMethods: paymentMethodsData
        .map((e) => PaymentMethodStat(
              method: e['method'] as String,
              count: e['count'] as int,
              total: (e['total'] as num?)?.toDouble() ?? 0.0,
            ))
        .toList(),
  );
});

// Date range model
class DateRange {
  final DateTime start;
  final DateTime end;

  DateRange({required this.start, required this.end});

  factory DateRange.today() {
    final now = DateTime.now();
    return DateRange(
      start: DateTime(now.year, now.month, now.day),
      end: DateTime(now.year, now.month, now.day, 23, 59, 59),
    );
  }

  factory DateRange.thisWeek() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return DateRange(
      start: DateTime(weekStart.year, weekStart.month, weekStart.day),
      end: DateTime(now.year, now.month, now.day, 23, 59, 59),
    );
  }

  factory DateRange.thisMonth() {
    final now = DateTime.now();
    return DateRange(
      start: DateTime(now.year, now.month, 1),
      end: DateTime(now.year, now.month, now.day, 23, 59, 59),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DateRange &&
          runtimeType == other.runtimeType &&
          start == other.start &&
          end == other.end;

  @override
  int get hashCode => start.hashCode ^ end.hashCode;
}

// Current date range provider
final currentDateRangeProvider = StateProvider<DateRange>((ref) => DateRange.today());
