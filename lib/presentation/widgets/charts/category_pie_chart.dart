import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:restaurant_billing/core/theme/app_theme.dart';
import 'package:restaurant_billing/core/utils/currency_formatter.dart';

class CategoryPieChart extends StatefulWidget {
  final List<Map<String, dynamic>> categories;

  const CategoryPieChart({super.key, required this.categories});

  @override
  State<CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<CategoryPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.categories.isEmpty) {
      return const SizedBox(
        height: 300,
        child: Center(child: Text('No category data available')),
      );
    }

    final total = widget.categories.fold<double>(
        0, (sum, cat) => sum + ((cat['total_sales'] ?? 0.0) as double));
    final colors = _generateColors(widget.categories.length);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 280,
            child: Row(
              children: [
                // Pie Chart
                Expanded(
                  flex: 3,
                  child: PieChart(
                    PieChartData(
                      sections: List.generate(widget.categories.length, (index) {
                        final category = widget.categories[index];
                        final sales = (category['total_sales'] ?? 0.0) as double;
                        final percentage = (sales / total * 100);
                        final isTouched = index == touchedIndex;

                        return PieChartSectionData(
                          color: colors[index],
                          value: sales,
                          title: '${percentage.toStringAsFixed(1)}%',
                          radius: isTouched ? 70 : 60,
                          titleStyle: TextStyle(
                            fontSize: isTouched ? 16 : 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                          titlePositionPercentageOffset: 0.55,
                        );
                      }),
                      sectionsSpace: 3,
                      centerSpaceRadius: 45,
                      centerSpaceColor: Colors.grey.shade50,
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              touchedIndex = -1;
                              return;
                            }
                            touchedIndex = pieTouchResponse
                                .touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                // Legend
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(widget.categories.length, (index) {
                      final category = widget.categories[index];
                      final categoryName = category['category'] as String;
                      final sales = (category['total_sales'] ?? 0.0) as double;
                      final quantity = category['total_quantity'] ?? 0;
                      final isTouched = index == touchedIndex;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: colors[index],
                                shape: BoxShape.circle,
                                boxShadow: isTouched
                                    ? [
                                        BoxShadow(
                                          color: colors[index].withOpacity(0.6),
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                        ),
                                      ]
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    categoryName,
                                    style: TextStyle(
                                      fontWeight: isTouched
                                          ? FontWeight.bold
                                          : FontWeight.w600,
                                      fontSize: isTouched ? 14 : 13,
                                      color: isTouched
                                          ? AppTheme.primaryColor
                                          : Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    CurrencyFormatter.format(sales),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '$quantity items',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _generateColors(int count) {
    final baseColors = [
      const Color(0xFFFF6384),
      const Color(0xFF36A2EB),
      const Color(0xFFFFCE56),
      const Color(0xFF4BC0C0),
      const Color(0xFF9966FF),
      const Color(0xFFFF9F40),
      const Color(0xFFFF6384),
      const Color(0xFFC9CBCF),
    ];

    return List.generate(count, (index) => baseColors[index % baseColors.length]);
  }
}
