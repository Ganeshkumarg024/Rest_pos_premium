import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:restaurant_billing/core/constants/expense_constants.dart';
import 'package:restaurant_billing/core/theme/app_theme.dart';
import 'package:restaurant_billing/core/utils/currency_formatter.dart';
import 'package:restaurant_billing/presentation/providers/expense_provider.dart';
import 'package:restaurant_billing/services/expense_export_service.dart';
import 'package:share_plus/share_plus.dart';

class ExpenseReportsScreen extends ConsumerStatefulWidget {
  const ExpenseReportsScreen({super.key});

  @override
  ConsumerState<ExpenseReportsScreen> createState() => _ExpenseReportsScreenState();
}

class _ExpenseReportsScreenState extends ConsumerState<ExpenseReportsScreen> {
  DateTime _startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _endDate = DateTime.now();
  bool _isExporting = false;

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

  Future<void> _exportPdf(double total, Map<String, double> byCategory) async {
    setState(() => _isExporting = true);
    try {
      // Fetch detailed expenses for the report
      final repository = ref.read(expenseRepositoryProvider);
      final expenses = await repository.getExpensesByDateRange(_startDate, _endDate);

      final pdfService = ExpenseExportService();
      final pdfBytes = await pdfService.generateExpenseReportPdf(
        startDate: _startDate,
        endDate: _endDate,
        expenses: expenses,
        categorySummary: byCategory,
        totalAmount: total,
      );

      await Printing.layoutPdf(
        onLayout: (format) => pdfBytes,
        name: 'Expense_Report_${DateFormat('yyyyMMdd').format(_startDate)}-${DateFormat('yyyyMMdd').format(_endDate)}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating PDF: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<void> _exportCsv(double total, Map<String, double> byCategory) async {
    setState(() => _isExporting = true);
    try {
      final repository = ref.read(expenseRepositoryProvider);
      final expenses = await repository.getExpensesByDateRange(_startDate, _endDate);
      final exportService = ExpenseExportService();
      final csvBytes = await exportService.generateExpenseCsv(
        startDate: _startDate,
        endDate: _endDate,
        expenses: expenses,
        categorySummary: byCategory,
        totalAmount: total,
      );
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/Expense_Report_${DateFormat('yyyyMMdd').format(_startDate)}_${DateFormat('yyyyMMdd').format(_endDate)}.csv');
      await file.writeAsBytes(csvBytes);
      await Share.shareXFiles([XFile(file.path)], text: 'Expense Report CSV');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating CSV: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateRange = DateRange(start: _startDate, end: _endDate);
    final statsAsync = ref.watch(expenseStatsProvider(dateRange));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Reports'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Date Range Selector
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                ),
              ),
              child: InkWell(
                onTap: _selectDateRange,
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: AppTheme.primaryColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Report Period',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${DateFormat('dd MMM yyyy').format(_startDate)} - ${DateFormat('dd MMM yyyy').format(_endDate)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.edit, color: AppTheme.primaryColor, size: 20),
                  ],
                ),
              ),
            ),

            // Statistics Content
            statsAsync.when(
              data: (stats) {
                final total = stats['total'] as double;
                final byCategory = stats['byCategory'] as Map<String, double>;

                return Column(
                  children: [
                    // Total Expenses Card
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryColor,
                            AppTheme.primaryColor.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Total Expenses',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            CurrencyFormatter.format(total),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Category Breakdown
                    if (byCategory.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Category Breakdown',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${byCategory.length} categories',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: byCategory.length,
                        itemBuilder: (context, index) {
                          final category = byCategory.keys.elementAt(index);
                          final amount = byCategory[category]!;
                          final percentage = (amount / total * 100).toStringAsFixed(1);

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        ExpenseCategories.getIcon(category),
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          category,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        CurrencyFormatter.format(amount),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: LinearProgressIndicator(
                                            value: amount / total,
                                            backgroundColor: Colors.grey.shade200,
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              AppTheme.primaryColor,
                                            ),
                                            minHeight: 8,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        '$percentage%',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ] else ...[
                      const Padding(
                        padding: EdgeInsets.all(40),
                        child: Column(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No expenses in this period',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) => Padding(
                padding: const EdgeInsets.all(40),
                child: Center(child: Text('Error: $error')),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: statsAsync.when(
        data: (stats) {
          final total = stats['total'] as double;
          final byCategory = stats['byCategory'] as Map<String, double>;
          
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton.extended(
                onPressed: _isExporting || total == 0 
                  ? null 
                  : () => _exportPdf(total, byCategory),
                icon: _isExporting 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.picture_as_pdf),
                label: Text(_isExporting ? 'Generating...' : 'Export PDF'),
                backgroundColor: total == 0 ? Colors.grey : Colors.red,
              ),
              const SizedBox(height: 12),
              FloatingActionButton.extended(
                onPressed: _isExporting || total == 0 
                  ? null 
                  : () => _exportCsv(total, byCategory),
                icon: const Icon(Icons.table_chart),
                label: const Text('Export CSV'),
                backgroundColor: total == 0 ? Colors.grey : Colors.green,
              ),
            ],
          );
        },
        loading: () => const SizedBox(),
        error: (_, __) => const SizedBox(),
      ),
    );
  }
}
