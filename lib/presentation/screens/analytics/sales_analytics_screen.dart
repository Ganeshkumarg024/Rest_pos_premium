import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restaurant_billing/core/theme/app_theme.dart';
import 'package:restaurant_billing/core/utils/currency_formatter.dart';
import 'package:restaurant_billing/presentation/providers/analytics_provider.dart';
import 'package:restaurant_billing/presentation/widgets/charts/sales_trend_chart.dart';
import 'package:restaurant_billing/presentation/widgets/charts/category_pie_chart.dart';
import 'package:intl/intl.dart';

class SalesAnalyticsScreen extends ConsumerStatefulWidget {
  const SalesAnalyticsScreen({super.key});

  @override
  ConsumerState<SalesAnalyticsScreen> createState() => _SalesAnalyticsScreenState();
}

class _SalesAnalyticsScreenState extends ConsumerState<SalesAnalyticsScreen> {
  DateTime _startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _endDate = DateTime.now();
  String _trendView = 'weekly'; // weekly or monthly

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateRange = AnalyticsDateRange(startDate: _startDate, endDate: _endDate);
    final summaryAsync = ref.watch(salesSummaryProvider(dateRange));
    final topItemsAsync = ref.watch(topSellingItemsProvider(dateRange));
    final categoryAsync = ref.watch(categoryDistributionProvider(dateRange));
    final combosAsync = ref.watch(frequentlyBoughtTogetherProvider(dateRange));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectDateRange,
            tooltip: 'Select Date Range',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(salesSummaryProvider);
              ref.invalidate(topSellingItemsProvider);
              ref.invalidate(categoryDistributionProvider);
              ref.invalidate(frequentlyBoughtTogetherProvider);
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(salesSummaryProvider);
          ref.invalidate(topSellingItemsProvider);
          ref.invalidate(categoryDistributionProvider);
          ref.invalidate(frequentlyBoughtTogetherProvider);
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Range Display
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: AppTheme.primaryColor.withOpacity(0.1),
                child: Text(
                  '${DateFormat('MMM dd, yyyy').format(_startDate)} - ${DateFormat('MMM dd, yyyy').format(_endDate)}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),

              // Summary Cards
              summaryAsync.when(
                data: (summary) => _buildSummarySection(summary),
                loading: () => const Center(child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                )),
                error: (error, stack) => Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Error loading summary: $error', style: const TextStyle(color: Colors.red)),
                ),
              ),

              const SizedBox(height: 16),

              // Sales Trend Chart
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                  'Sales Trend',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(value: 'weekly', label: Text('Weekly')),
                            ButtonSegment(value: 'monthly', label: Text('Monthly')),
                          ],
                          selected: {_trendView},
                          onSelectionChanged: (Set<String> selected) {
                            setState(() => _trendView = selected.first);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SalesTrendChart(
                      dateRange: dateRange,
                      trendType: _trendView,
                    ),
                  ],
                ),
              ),

              const Divider(height: 32),

              // Top Selling Items
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Top 10 Best-Selling Items',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    topItemsAsync.when(
                      data: (items) => _buildTopItemsList(items),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (error, stack) => Text('Error: $error', style: const TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ),

              const Divider(height: 32),

              // Category Distribution
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sales by Category',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    categoryAsync.when(
                      data: (categories) => CategoryPieChart(categories: categories),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (error, stack) => Text('Error: $error', style: const TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ),

              const Divider(height: 32),

              // Frequently Bought Together
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Frequently Bought Together',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    combosAsync.when(
                      data: (combos) => _buildCombosList(combos),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (error, stack) => Text('Error: $error', style: const TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummarySection(Map<String, dynamic> summary) {
    final totalOrders = summary['total_orders'] ?? 0;
    final totalRevenue = (summary['total_revenue'] ?? 0.0) as double;
    final avgOrderValue = (summary['avg_order_value'] ?? 0.0) as double;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'Total Orders',
              totalOrders.toString(),
              Icons.shopping_cart,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Total Revenue',
              CurrencyFormatter.format(totalRevenue),
              Icons.attach_money,
              Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Avg Order Value',
              CurrencyFormatter.format(avgOrderValue),
              Icons.trending_up,
              Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildTopItemsList(List<Map<String, dynamic>> items) {
    if (items.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final rank = index + 1;
        final itemName = item['item_name'] as String;
        final category = item['category'] as String;
        final totalQuantity = item['total_quantity'] as int;
        final totalRevenue = (item['total_revenue'] ?? 0.0) as double;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getRankColor(rank),
              child: Text('#$rank', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            title: Text(itemName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(category),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  CurrencyFormatter.format(totalRevenue),
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                ),
                Text(
                  '$totalQuantity sold',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCombosList(List<Map<String, dynamic>> combos) {
    if (combos.isEmpty) {
      return const Center(child: Text('No combo data available'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: combos.length,
      itemBuilder: (context, index) {
        final combo = combos[index];
        final item1Name = combo['item1_name'] as String;
        final item2Name = combo['item2_name'] as String;
        final pairCount = combo['pair_count'] as int;
        final support = (((combo['support'] ?? 0.0) as double) * 100).toStringAsFixed(1);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(Icons.link, color: AppTheme.primaryColor),
            title: Row(
              children: [
                Expanded(child: Text(item1Name)),
                const Icon(Icons.add, size: 16),
                Expanded(child: Text(item2Name)),
              ],
            ),
            subtitle: Text('Bought together $pairCount times ($support% of orders)'),
          ),
        );
      },
    );
  }

  Color _getRankColor(int rank) {
    if (rank == 1) return Colors.amber;
    if (rank == 2) return Colors.grey;
    if (rank == 3) return Colors.brown;
    return AppTheme.primaryColor;
  }
}
