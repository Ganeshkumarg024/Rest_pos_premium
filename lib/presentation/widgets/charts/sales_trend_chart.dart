import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restaurant_billing/core/theme/app_theme.dart';
import 'package:restaurant_billing/core/utils/currency_formatter.dart';
import 'package:restaurant_billing/presentation/providers/analytics_provider.dart';
import 'package:intl/intl.dart';

class SalesTrendChart extends ConsumerWidget {
  final AnalyticsDateRange dateRange;
  final String trendType; // 'weekly' or 'monthly'

  const SalesTrendChart({
    super.key,
    required this.dateRange,
    required this.trendType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendAsync = trendType == 'weekly'
        ? ref.watch(weeklySalesTrendProvider(dateRange))
        : ref.watch(monthlySalesTrendProvider(dateRange));

    return trendAsync.when(
      data: (trendData) {
        if (trendData.isEmpty) {
          return const SizedBox(
            height: 250,
            child: Center(child: Text('No data available for this period')),
          );
        }

        return SizedBox(
          height: 250,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: _calculateInterval(trendData),
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey.shade300,
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= trendData.length) return const Text('');
                      
                      final label = trendType == 'weekly'
                          ? _getWeekLabel(trendData[index]['week'] as String)
                          : _getMonthLabel(trendData[index]['month'] as String);
                      
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          label,
                          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 50,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        CurrencyFormatter.format(value),
                        style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade300),
                  left: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              minX: 0,
              maxX: (trendData.length - 1).toDouble(),
              minY: 0,
              maxY: _calculateMaxY(trendData),
              lineBarsData: [
                LineChartBarData(
                  spots: _generateSpots(trendData),
                  isCurved: true,
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.primaryColor.withOpacity(0.5),
                    ],
                  ),
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 4,
                        color: Colors.white,
                        strokeWidth: 2,
                        strokeColor: AppTheme.primaryColor,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryColor.withOpacity(0.3),
                        AppTheme.primaryColor.withOpacity(0.0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                enabled: true,
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                    return touchedBarSpots.map((barSpot) {
                      final index = barSpot.x.toInt();
                      final sales = (trendData[index]['total_sales'] ?? 0.0) as double;
                      final orders = trendData[index]['order_count'] ?? 0;
                      
                      return LineTooltipItem(
                        '${CurrencyFormatter.format(sales)}\n$orders orders',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox(
        height: 250,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => SizedBox(
        height: 250,
        child: Center(child: Text('Error: $error', style: const TextStyle(color: Colors.red))),
      ),
    );
  }

  List<FlSpot> _generateSpots(List<Map<String, dynamic>> data) {
    return List.generate(data.length, (index) {
      final sales = (data[index]['total_sales'] ?? 0.0) as double;
      return FlSpot(index.toDouble(), sales);
    });
  }

  double _calculateMaxY(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return 1000;
    
    double max = 0;
    for (var item in data) {
      final sales = (item['total_sales'] ?? 0.0) as double;
      if (sales > max) max = sales;
    }
    
    return max * 1.2; // Add 20% padding
  }

  double _calculateInterval(List<Map<String, dynamic>> data) {
    final maxY = _calculateMaxY(data);
    return maxY /5; // 5 horizontal lines
  }

  String _getWeekLabel(String week) {
    // Format: "2024-01" -> "W1"
    final parts = week.split('-');
    return parts.length == 2 ? 'W${parts[1]}' : week;
  }

  String _getMonthLabel(String month) {
    // Format: "2024-01" -> "Jan"
    try {
      final date = DateTime.parse('$month-01');
      return DateFormat('MMM').format(date);
    } catch (e) {
      return month;
    }
  }
}
