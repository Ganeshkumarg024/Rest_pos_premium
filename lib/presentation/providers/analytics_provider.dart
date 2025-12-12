import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restaurant_billing/data/repositories/analytics_repository.dart';

// Repository provider
final analyticsRepositoryProvider = Provider((ref) => AnalyticsRepository());

// Date range for analytics
class AnalyticsDateRange {
  final DateTime startDate;
  final DateTime endDate;

  AnalyticsDateRange({required this.startDate, required this.endDate});
}

// Weekly sales trend provider
final weeklySalesTrendProvider = FutureProvider.family<List<Map<String, dynamic>>, AnalyticsDateRange>((ref, dateRange) async {
  final repository = ref.read(analyticsRepositoryProvider);
  return await repository.getWeeklySalesTrend(dateRange.startDate, dateRange.endDate);
});

// Monthly sales trend provider
final monthlySalesTrendProvider = FutureProvider.family<List<Map<String, dynamic>>, AnalyticsDateRange>((ref, dateRange) async {
  final repository = ref.read(analyticsRepositoryProvider);
  return await repository.getMonthlySalesTrend(dateRange.startDate, dateRange.endDate);
});

// Top selling items provider
final topSellingItemsProvider = FutureProvider.family<List<Map<String, dynamic>>, AnalyticsDateRange>((ref, dateRange) async {
  final repository = ref.read(analyticsRepositoryProvider);
  return await repository.getTopSellingItems(
    startDate: dateRange.startDate,
    endDate: dateRange.endDate,
    limit: 10,
  );
});

// Category distribution provider
final categoryDistributionProvider = FutureProvider.family<List<Map<String, dynamic>>, AnalyticsDateRange>((ref, dateRange) async {
  final repository = ref.read(analyticsRepositoryProvider);
  return await repository.getCategoryDistribution(dateRange.startDate, dateRange.endDate);
});

// Frequently bought together provider
final frequentlyBoughtTogetherProvider = FutureProvider.family<List<Map<String, dynamic>>, AnalyticsDateRange>((ref, dateRange) async {
  final repository = ref.read(analyticsRepositoryProvider);
  return await repository.getFrequentlyBoughtTogether(
    startDate: dateRange.startDate,
    endDate: dateRange.endDate,
    limit: 10,
  );
});

// Sales summary provider
final salesSummaryProvider = FutureProvider.family<Map<String, dynamic>, AnalyticsDateRange>((ref, dateRange) async {
  final repository = ref.read(analyticsRepositoryProvider);
  return await repository.getSalesSummary(dateRange.startDate, dateRange.endDate);
});

// Daily sales provider
final dailySalesProvider = FutureProvider.family<List<Map<String, dynamic>>, AnalyticsDateRange>((ref, dateRange) async {
  final repository = ref.read(analyticsRepositoryProvider);
  return await repository.getDailySales(dateRange.startDate, dateRange.endDate);
});

// Peak sales hours provider
final peakSalesHoursProvider = FutureProvider.family<List<Map<String, dynamic>>, AnalyticsDateRange>((ref, dateRange) async {
  final repository = ref.read(analyticsRepositoryProvider);
  return await repository.getPeakSalesHours(dateRange.startDate, dateRange.endDate);
});
