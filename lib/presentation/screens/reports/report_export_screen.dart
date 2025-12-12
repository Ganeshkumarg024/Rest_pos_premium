import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:restaurant_billing/core/theme/app_theme.dart';
import 'package:restaurant_billing/core/utils/currency_formatter.dart';
import 'package:restaurant_billing/data/models/restaurant_model.dart';
import 'package:restaurant_billing/data/repositories/restaurant_repository.dart';
import 'package:restaurant_billing/presentation/providers/reports_provider.dart';
import 'package:restaurant_billing/services/report_pdf_service.dart';
import 'package:restaurant_billing/services/report_csv_service.dart';
import 'package:intl/intl.dart';

class ReportExportScreen extends ConsumerStatefulWidget {
  final ReportsData reportData;
  final DateRange dateRange;
  final String periodName;

  const ReportExportScreen({
    super.key,
    required this.reportData,
    required this.dateRange,
    required this.periodName,
  });

  @override
  ConsumerState<ReportExportScreen> createState() => _ReportExportScreenState();
}

class _ReportExportScreenState extends ConsumerState<ReportExportScreen> {
  bool _isLoading = false;

  Future<void> _exportPDF() async {
    setState(() => _isLoading = true);

    try {
      // Get restaurant data
      final restaurantRepo = RestaurantRepository();
      final restaurant = await restaurantRepo.getRestaurant();

      // Generate PDF
      final pdfService = ReportPdfService();
      final pdfBytes = await pdfService.generateSalesReportPDF(
        reportData: widget.reportData,
        dateRange: widget.dateRange,
        restaurant: restaurant,
      );

      // Get Downloads directory
      Directory? downloadsDir;
      if (Platform.isAndroid) {
        downloadsDir = Directory('/storage/emulated/0/Download');
      } else {
        downloadsDir = await getDownloadsDirectory();
      }

      if (downloadsDir == null || !await downloadsDir.exists()) {
        throw Exception('Downloads directory not found');
      }

      // Save PDF
      final dateStr = DateFormat('yyyyMMdd').format(DateTime.now());
      final filename = 'sales_report_$dateStr.pdf';
      final file = File('${downloadsDir.path}/$filename');
      await file.writeAsBytes(pdfBytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Report saved to Downloads/$filename'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _exportCSV() async {
    setState(() => _isLoading = true);

    try {
      // Generate CSV
      final csvService = ReportCsvService();
      final csvData = await csvService.generateSalesReportCSV(
        dateRange: widget.dateRange,
      );

      // Get Downloads directory
      Directory? downloadsDir;
      if (Platform.isAndroid) {
        downloadsDir = Directory('/storage/emulated/0/Download');
      } else {
        downloadsDir = await getDownloadsDirectory();
      }

      if (downloadsDir == null || !await downloadsDir.exists()) {
        throw Exception('Downloads directory not found');
      }

      // Save CSV
      final dateStr = DateFormat('yyyyMMdd').format(DateTime.now());
      final filename = 'sales_report_$dateStr.csv';
      final file = File('${downloadsDir.path}/$filename');
      await file.writeAsString(csvData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Report saved to Downloads/$filename'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting CSV: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Report'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Period Info - Now editable
                    GestureDetector(
                      onTap: () async {
                        final DateTimeRange? picked = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                          initialDateRange: DateTimeRange(
                            start: widget.dateRange.start,
                            end: widget.dateRange.end,
                          ),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: AppTheme.primaryColor,
                                  onPrimary: Colors.white,
                                  surface: Colors.white,
                                  onSurface: Colors.black,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );

                        if (picked != null && mounted) {
                          // Navigate back and pass new date range
                          Navigator.pop(context, picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.primaryColor.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
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
                                  widget.periodName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${DateFormat('MMM dd').format(widget.dateRange.start)} - ${DateFormat('MMM dd, yyyy').format(widget.dateRange.end)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  color: AppTheme.primaryColor,
                                  size: 28,
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.edit,
                                  color: AppTheme.primaryColor,
                                  size: 20,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Summary Statistics
                    const Text(
                      'Summary',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.5,
                      children: [
                        _buildStatCard(
                          'Total Sales',
                          CurrencyFormatter.format(widget.reportData.totalSales),
                          Icons.attach_money,
                          Colors.green,
                        ),
                        _buildStatCard(
                          'Total Orders',
                          '${widget.reportData.totalOrders}',
                          Icons.shopping_cart,
                          Colors.blue,
                        ),
                        _buildStatCard(
                          'Avg Order',
                          CurrencyFormatter.format(widget.reportData.averageOrderValue),
                          Icons.trending_up,
                          Colors.orange,
                        ),
                        _buildStatCard(
                          'Tax Collected',
                          CurrencyFormatter.format(widget.reportData.totalTax),
                          Icons.receipt,
                          Colors.purple,
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Top Items Preview
                    if (widget.reportData.topItems.isNotEmpty) ...[
                      const Text(
                        'Top Selling Items Preview',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      ...widget.reportData.topItems.take(5).map((item) => Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                            child: Icon(Icons.restaurant, color: AppTheme.primaryColor),
                          ),
                          title: Text(item.name),
                          subtitle: Text('Sold: ${item.quantitySold}'),
                          trailing: Text(
                            CurrencyFormatter.format(item.totalRevenue),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      )),

                      const SizedBox(height: 32),
                    ],

                    // Export Buttons
                    const Text(
                      'Export Options',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _exportPDF,
                        icon: const Icon(Icons.picture_as_pdf, size: 24),
                        label: const Text(
                          'Download as PDF',
                          style: TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade400,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _exportCSV,
                        icon: const Icon(Icons.table_chart, size: 24),
                        label: const Text(
                          'Download as CSV',
                          style: TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade400,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
