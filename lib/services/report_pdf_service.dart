import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:restaurant_billing/data/models/restaurant_model.dart';
import 'package:restaurant_billing/presentation/providers/reports_provider.dart';
import 'package:restaurant_billing/core/utils/currency_formatter.dart';
import 'package:intl/intl.dart';

class ReportPdfService {
  /// Generate a professional sales report PDF (A4 portrait)
  Future<Uint8List> generateSalesReportPDF({
    required ReportsData reportData,
    required DateRange dateRange,
    RestaurantModel? restaurant,
  }) async {
    final pdf = pw.Document();

    // Load logo image if available
    pw.ImageProvider? logoImage;
    if (restaurant?.logoPath != null) {
      try {
        final logoFile = File(restaurant!.logoPath!);
        if (await logoFile.exists()) {
          final logoBytes = await logoFile.readAsBytes();
          logoImage = pw.MemoryImage(logoBytes);
        }
      } catch (e) {
        print('Failed to load logo: $e');
      }
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(40),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      if (logoImage != null)
                        pw.Image(logoImage, width: 60, height: 60),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        restaurant?.name ?? 'Restaurant',
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      if (restaurant?.address != null)
                        pw.Text(
                          restaurant!.address!,
                          style: pw.TextStyle(fontSize: 10),
                        ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'SALES REPORT',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'Period: ${DateFormat('dd MMM yyyy').format(dateRange.start)} - ${DateFormat('dd MMM yyyy').format(dateRange.end)}',
                        style: pw.TextStyle(fontSize: 10),
                      ),
                      pw.Text(
                        'Generated: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}',
                        style: pw.TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 30),

              // Summary Statistics
              pw.Text(
                'Summary',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 12),

              pw.Container(
                padding: pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard('Total Sales', CurrencyFormatter.formatForPdf(reportData.totalSales)),
                    _buildStatCard('Total Orders', '${reportData.totalOrders}'),
                    _buildStatCard('Avg Order', CurrencyFormatter.formatForPdf(reportData.averageOrderValue)),
                    _buildStatCard('Total Tax', CurrencyFormatter.formatForPdf(reportData.totalTax)),
                  ],
                ),
              ),

              pw.SizedBox(height: 30),

              // Top Selling Items
              pw.Text(
                'Top Selling Items',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 12),

              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                children: [
                  // Header row
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _buildTableHeader('Item Name'),
                      _buildTableHeader('Qty Sold'),
                      _buildTableHeader('Revenue'),
                    ],
                  ),
                  // Data rows
                  ...reportData.topItems.take(10).map((item) => pw.TableRow(
                    children: [
                      _buildTableCell(item.name),
                      _buildTableCell('${item.quantitySold}'),
                      _buildTableCell(CurrencyFormatter.formatForPdf(item.totalRevenue)),
                    ],
                  )),
                ],
              ),

              pw.Spacer(),

              // Footer
              pw.Divider(),
              pw.SizedBox(height: 8),
              pw.Text(
                'This is a computer-generated report and does not require a signature.',
                style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                textAlign: pw.TextAlign.center,
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildStatCard(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          label,
          style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
        ),
      ],
    );
  }

  pw.Widget _buildTableHeader(String text) {
    return pw.Padding(
      padding: pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
      ),
    );
  }

  pw.Widget _buildTableCell(String text) {
    return pw.Padding(
      padding: pw.EdgeInsets.all(8),
      child: pw.Text(text, style: pw.TextStyle(fontSize: 10)),
    );
  }
}
