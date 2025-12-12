import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:restaurant_billing/data/models/order_model.dart';
import 'package:restaurant_billing/data/models/restaurant_model.dart';
import 'package:restaurant_billing/core/utils/currency_formatter.dart';
import 'package:intl/intl.dart';

class PdfGeneratorService {
  /// Generate a thermal receipt-style PDF invoice
  /// Width: 58mm (165 points) - standard thermal printer width
  Future<Uint8List> generateInvoicePDF({
    required OrderModel order,
    RestaurantModel? restaurant,
  }) async {
    final pdf = pw.Document();

    // Thermal paper width: 58mm = ~165 points at 72 DPI
    const double pageWidth = 58 * PdfPageFormat.mm;
    // Variable height based on content
    const double pageHeight = 297 * PdfPageFormat.mm; // A4 height as max

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
        // If logo fails to load, continue without it
        print('Failed to load logo: $e');
      }
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(pageWidth, pageHeight),
        margin: pw.EdgeInsets.all(8),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // Restaurant Logo
              if (logoImage != null)
                pw.Container(
                  margin: pw.EdgeInsets.only(bottom: 8),
                  child: pw.Image(
                    logoImage,
                    width: 50,
                    height: 50,
                    fit: pw.BoxFit.cover,
                  ),
                ),

              // Restaurant Name
              pw.Text(
                restaurant?.name ?? 'Restaurant',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
                textAlign: pw.TextAlign.center,
              ),

              // Restaurant Details
              if (restaurant?.address != null && restaurant!.address!.isNotEmpty)
                pw.Padding(
                  padding: pw.EdgeInsets.only(top: 4),
                  child: pw.Text(
                    restaurant.address!,
                    style: pw.TextStyle(fontSize: 8),
                    textAlign: pw.TextAlign.center,
                  ),
                ),

              if (restaurant?.phone != null && restaurant!.phone!.isNotEmpty)
                pw.Padding(
                  padding: pw.EdgeInsets.only(top: 2),
                  child: pw.Text(
                    'Phone: ${restaurant.phone}',
                    style: pw.TextStyle(fontSize: 8),
                    textAlign: pw.TextAlign.center,
                  ),
                ),

              if (restaurant?.email != null && restaurant!.email!.isNotEmpty)
                pw.Padding(
                  padding: pw.EdgeInsets.only(top: 2),
                  child: pw.Text(
                    'Email: ${restaurant.email}',
                    style: pw.TextStyle(fontSize: 8),
                    textAlign: pw.TextAlign.center,
                  ),
                ),

              // Divider
              pw.Container(
                margin: pw.EdgeInsets.symmetric(vertical: 8),
                child: pw.Divider(thickness: 1),
              ),

              // Invoice Number
              _buildInfoRow('Invoice #', _generateInvoiceNumber(order.id!)),
              pw.SizedBox(height: 4),
              
              // Date
              _buildInfoRow(
                'Date',
                DateFormat('dd MMM, yyyy').format(order.createdAt),
              ),
              pw.SizedBox(height: 4),
              
              // Time
              _buildInfoRow(
                'Time',
                DateFormat('hh:mm a').format(order.createdAt),
              ),
              pw.SizedBox(height: 4),
              
              // Table
              _buildInfoRow('Table #', order.tableName ?? 'N/A'),

              // Divider
              pw.Container(
                margin: pw.EdgeInsets.symmetric(vertical: 8),
                child: pw.Divider(thickness: 1),
              ),

              // Items Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    flex: 3,
                    child: pw.Text(
                      'Item',
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.SizedBox(
                    width: 25,
                    child: pw.Text(
                      'Qty',
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                  pw.SizedBox(
                    width: 40,
                    child: pw.Text(
                      'Price',
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                      ),
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 8),

              // Items List
              ...?order.items?.map((item) => pw.Padding(
                padding: pw.EdgeInsets.only(bottom: 6),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      flex: 3,
                      child: pw.Text(
                        item.menuItemName ?? 'Unknown',
                        style: pw.TextStyle(fontSize: 9),
                      ),
                    ),
                    pw.SizedBox(
                      width: 25,
                      child: pw.Text(
                        '${item.quantity}',
                        style: pw.TextStyle(fontSize: 9),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.SizedBox(
                      width: 40,
                      child: pw.Text(
                        CurrencyFormatter.formatForPdf(item.totalPrice),
                        style: pw.TextStyle(fontSize: 9),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                  ],
                ),
              )),

              // Divider
              pw.Container(
                margin: pw.EdgeInsets.symmetric(vertical: 8),
                child: pw.Divider(thickness: 1),
              ),

              // Subtotal
              _buildSummaryRow('Subtotal', order.subtotal),
              pw.SizedBox(height: 4),

              // Tax
              _buildSummaryRow(
                'GST (${_calculateTaxPercentage(order).toStringAsFixed(0)}%)',
                order.taxAmount,
              ),

              // Divider
              pw.Container(
                margin: pw.EdgeInsets.symmetric(vertical: 8),
                child: pw.Divider(thickness: 1),
              ),

              // Total
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Total',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    CurrencyFormatter.formatForPdf(order.totalAmount),
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),

              // Divider
              pw.Container(
                margin: pw.EdgeInsets.symmetric(vertical: 8),
                child: pw.Divider(thickness: 1),
              ),

              // Thank you message
              pw.Padding(
                padding: pw.EdgeInsets.only(top: 8),
                child: pw.Text(
                  'Thank you for your visit!',
                  style: pw.TextStyle(fontSize: 9),
                  textAlign: pw.TextAlign.center,
                ),
              ),

              // Footer spacing
              pw.SizedBox(height: 16),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildInfoRow(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(fontSize: 9),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.normal),
        ),
      ],
    );
  }

  pw.Widget _buildSummaryRow(String label, double amount) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(fontSize: 10),
        ),
        pw.Text(
          CurrencyFormatter.formatForPdf(amount),
          style: pw.TextStyle(fontSize: 10),
        ),
      ],
    );
  }

  String _generateInvoiceNumber(int orderId) {
    final now = DateTime.now();
    final dateStr = DateFormat('yyyy-MM-dd').format(now);
    return 'INV-$dateStr-$orderId';
  }

  double _calculateTaxPercentage(OrderModel order) {
    if (order.subtotal > 0) {
      return (order.taxAmount / order.subtotal) * 100;
    }
    return 0.0;
  }
}
