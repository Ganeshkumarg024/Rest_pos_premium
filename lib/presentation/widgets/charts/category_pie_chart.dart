import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:restaurant_billing/core/theme/app_theme.dart';
import 'package:restaurant_billing/core/utils/currency_formatter.dart';

class CategoryPieChart extends StatelessWidget {
  final List<Map<String, dynamic>> categories;

  const CategoryPieChart({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const SizedBox(
        height: 250,
        child: Center(child: Text('No category data available')),
      );
    }

    final total = categories.fold<double>(0, (sum, cat) => sum + ((cat['total_sales'] ?? 0.0) as double));
    final colors = _generateColors(categories.length);

    return Column(
      children: [
        SizedBox(
          height: 250,
          child: PieChart(
            PieChartData(
              sections: List.generate(categories.length, (index) {
                final category = categories[index];
                final sales = (category['total_sales'] ?? 0.0) as double;
                final percentage = (sales / total * 100);
                final isTouched = false; // Can be made interactive later

                return PieChartSectionData(
                  color: colors[index],
                  value: sales,
                  title: '${percentage.toStringAsFixed(1)}%',
                  radius: isTouched ? 110 : 100,
                  titleStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  badgeWidget: isTouched
                      ? Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Text(
                            category['category'] as String,
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        )
                      : null,
                  badgePositionPercentageOffset: 1.3,
                );
              }),
              sectionsSpace: 2,
              centerSpaceRadius: 60,
              centerSpaceColor: Colors.white,
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  // Can add interaction here
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Legend
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: List.generate(categories.length, (index) {
            final category = categories[index];
            final categoryName = category['category'] as String;
            final sales = (category['total_sales'] ?? 0.0) as double;

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: colors[index],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      categoryName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      CurrencyFormatter.format(sales),
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ],
            );
          }),
        ),
      ],
    );
  }

  List<Color> _generateColors(int count) {
    final baseColors = [
      AppTheme.primaryColor,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.pink,
      Colors.amber,
      Colors.indigo,
    ];

    return List.generate(count, (index) => baseColors[index % baseColors.length]);
  }
}
