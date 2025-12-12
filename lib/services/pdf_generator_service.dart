import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
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
    
    // Load logo from assets instead of file path
    pw.ImageProvider? logoImage;
    try {
      // Load from assets - this will work in the PDF
      final logoData = await rootBundle.load('assets/images/logo.png');
      logoImage = pw.MemoryImage(logoData.buffer.asUint8List());
    } catch (e) {
      print('Failed to load logo from assets: $e');
    }

    // Calculate content height dynamically
    final itemCount = order.items?.length ?? 0;
    final baseHeight = 380.0;
    final itemHeight = itemCount * 20.0;
    final totalHeight = baseHeight + itemHeight + 30; // Minimal padding at bottom

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(pageWidth, totalHeight),
        margin: const pw.EdgeInsets.all(10),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              // Restaurant Logo - Fixed to show properly
              if (logoImage != null)
                pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 8),
                  width: 60,
                  height: 60,
                  decoration: pw.BoxDecoration(
                    shape: pw.BoxShape.circle,
                    color: PdfColors.white,
                  ),
                  child: pw.ClipOval(
                    child: pw.Image(
                      logoImage,
                      fit: pw.BoxFit.cover,
                    ),
                  ),
                ),

              // Restaurant Name
              pw.Text(
                restaurant?.name ?? 'The Chozha Pos',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
                textAlign: pw.TextAlign.center,
              ),

              // Restaurant Details
              if (restaurant?.address != null && restaurant!.address!.isNotEmpty)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 3),
                  child: pw.Text(
                    restaurant.address!,
                    style: const pw.TextStyle(fontSize: 8),
                    textAlign: pw.TextAlign.center,
                  ),
                ),

              if (restaurant?.phone != null && restaurant!.phone!.isNotEmpty)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 2),
                  child: pw.Text(
                    'Phone: ${restaurant.phone}',
                    style: const pw.TextStyle(fontSize: 8),
                    textAlign: pw.TextAlign.center,
                  ),
                ),

              if (restaurant?.email != null && restaurant!.email!.isNotEmpty)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 2),
                  child: pw.Text(
                    'Email: ${restaurant.email}',
                    style: const pw.TextStyle(fontSize: 8),
                    textAlign: pw.TextAlign.center,
                  ),
                ),

              // Divider
              pw.Container(
                margin: const pw.EdgeInsets.symmetric(vertical: 8),
                child: pw.Divider(thickness: 1),
              ),

              // Invoice Number
              _buildInfoRow('Invoice #', _generateInvoiceNumber(order.id!)),
              pw.SizedBox(height: 3),
              
              // Date
              _buildInfoRow(
                'Date',
                DateFormat('dd MMMM, yyyy').format(order.createdAt),
              ),
              pw.SizedBox(height: 3),
              
              // Time
              _buildInfoRow(
                'Time',
                DateFormat('hh:mm a').format(order.createdAt),
              ),
              pw.SizedBox(height: 3),
              
              // Table
              _buildInfoRow('Table #', order.tableName ?? 'N/A'),

              // Divider
              pw.Container(
                margin: const pw.EdgeInsets.symmetric(vertical: 8),
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

              pw.SizedBox(height: 6),

              // Items List
              ...?order.items?.map((item) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 5),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      flex: 3,
                      child: pw.Text(
                        item.menuItemName ?? 'Unknown',
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                    ),
                    pw.SizedBox(
                      width: 25,
                      child: pw.Text(
                        '${item.quantity}',
                        style: const pw.TextStyle(fontSize: 9),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.SizedBox(
                      width: 40,
                      child: pw.Text(
                        CurrencyFormatter.formatForPdf(item.totalPrice),
                        style: const pw.TextStyle(fontSize: 9),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                  ],
                ),
              )),

              // Divider
              pw.Container(
                margin: const pw.EdgeInsets.symmetric(vertical: 8),
                child: pw.Divider(thickness: 1),
              ),

              // Subtotal
              _buildSummaryRow('Subtotal', order.subtotal),
              pw.SizedBox(height: 3),

              // Tax
              _buildSummaryRow(
                'GST (${_calculateTaxPercentage(order).toStringAsFixed(0)}%)',
                order.taxAmount,
              ),

              // Divider
              pw.Container(
                margin: const pw.EdgeInsets.symmetric(vertical: 8),
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
                margin: const pw.EdgeInsets.symmetric(vertical: 8),
                child: pw.Divider(thickness: 1),
              ),

              // Thank you message
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 4, bottom: 4),
                child: pw.Text(
                  'Thank you for your visit!',
                  style: const pw.TextStyle(fontSize: 9),
                  textAlign: pw.TextAlign.center,
                ),
              ),

              // Cut line indicator (dashed line at bottom)
              pw.Container(
                margin: const pw.EdgeInsets.only(top: 8),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Container(
                      width: 30,
                      height: 1,
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(
                          bottom: pw.BorderSide(
                            color: PdfColors.grey400,
                            width: 1,
                            style: pw.BorderStyle.dashed,
                          ),
                        ),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 6),
                      child: pw.Icon(
                        const pw.IconData(0xe146), // scissors icon
                        size: 12,
                        color: PdfColors.grey400,
                      ),
                    ),
                    pw.Container(
                      width: 30,
                      height: 1,
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(
                          bottom: pw.BorderSide(
                            color: PdfColors.grey400,
                            width: 1,
                            style: pw.BorderStyle.dashed,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
