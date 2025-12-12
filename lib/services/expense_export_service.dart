import 'dart:convert';
import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:restaurant_billing/data/models/expense_model.dart';
import 'package:restaurant_billing/core/utils/currency_formatter.dart';
import 'package:intl/intl.dart';

class ExpenseExportService {

  // New CSV export method
  Future<Uint8List> generateExpenseCsv({
    required DateTime startDate,
    required DateTime endDate,
    required List<ExpenseModel> expenses,
    required Map<String, double> categorySummary,
    required double totalAmount,
    String restaurantName = 'The Chozha Pos',
  }) async {
    // Build CSV rows
    final List<List<dynamic>> rows = [];
    // Header
    rows.add(['Date', 'Category', 'Description', 'Method', 'Amount']);
    final dateFormat = DateFormat('dd MMM yyyy');
    for (final e in expenses) {
      rows.add([
        dateFormat.format(e.date),
        e.category,
        e.description ?? '-',
        e.paymentMethod,
        e.amount,
      ]);
    }
    // Convert to CSV string
    final csv = ListToCsvConverter().convert(rows);
    // Return as Uint8List
    return Uint8List.fromList(utf8.encode(csv));
  }

  Future<Uint8List> generateExpenseReportPdf({
    required DateTime startDate,
    required DateTime endDate,
    required List<ExpenseModel> expenses,
    required Map<String, double> categorySummary,
    required double totalAmount,
    String restaurantName = 'The Chozha Pos',
  }) async {
    final pdf = pw.Document();

    // Load font if needed, but standard fonts work for basic text
    // Load logo
    pw.ImageProvider? logoImage;
    try {
      final logoData = await rootBundle.load('assets/images/logo.png');
      logoImage = pw.MemoryImage(logoData.buffer.asUint8List());
    } catch (e) {
      print('Failed to load logo: $e');
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          _buildHeader(restaurantName, startDate, endDate, logoImage),
          pw.SizedBox(height: 20),
          _buildSummarySection(totalAmount, expenses.length, categorySummary.length),
          pw.SizedBox(height: 20),
          _buildCategoryTable(categorySummary, totalAmount),
          pw.SizedBox(height: 20),
          pw.Text(
            'Detailed Expenses',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey800,
            ),
          ),
          pw.SizedBox(height: 10),
          _buildExpenseTable(expenses),
          pw.SizedBox(height: 20),
          _buildFooter(),
        ],
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildHeader(
    String restaurantName,
    DateTime startDate,
    DateTime endDate,
    pw.ImageProvider? logo,
  ) {
    final dateFormat = DateFormat('dd MMM yyyy');
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Expense Report',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  restaurantName,
                  style: pw.TextStyle(
                    fontSize: 16,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
            if (logo != null)
              pw.Container(
                width: 60,
                height: 60,
                child: pw.Image(logo),
              ),
          ],
        ),
        pw.SizedBox(height: 20),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey100,
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Row(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Text(
                'Period: ',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                '${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}',
              ),
            ],
          ),
        ),
        pw.Divider(color: PdfColors.grey300),
      ],
    );
  }

  pw.Widget _buildSummarySection(double totalAmount, int totalCount, int categoryCount) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        _buildSummaryCard('Total Expenses', CurrencyFormatter.format(totalAmount), PdfColors.red50),
        _buildSummaryCard('Total Transactions', totalCount.toString(), PdfColors.blue50),
        _buildSummaryCard('Active Categories', categoryCount.toString(), PdfColors.green50),
      ],
    );
  }

  pw.Widget _buildSummaryCard(String title, String value, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        margin: const pw.EdgeInsets.symmetric(horizontal: 4),
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          color: color,
          borderRadius: pw.BorderRadius.circular(8),
          border: pw.Border.all(color: PdfColors.grey200),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              title,
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey700,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _buildCategoryTable(Map<String, double> categorySummary, double totalAmount) {
    final headers = ['Category', 'Amount', '% of Total'];
    final data = categorySummary.entries.map((e) {
      final percentage = (e.value / totalAmount * 100).toStringAsFixed(1);
      return [
        e.key,
        CurrencyFormatter.format(e.value),
        '$percentage%',
      ];
    }).toList();

    return pw.Table.fromTextArray(
      headers: headers,
      data: data,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blue700),
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerRight,
        2: pw.Alignment.centerRight,
      },
      oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
    );
  }

  pw.Widget _buildExpenseTable(List<ExpenseModel> expenses) {
    final headers = ['Date', 'Category', 'Description', 'Method', 'Amount'];
    final dateFormat = DateFormat('dd MMM yyyy');
    
    final data = expenses.map((e) {
      return [
        dateFormat.format(e.date),
        e.category,
        e.description ?? '-',
        e.paymentMethod,
        CurrencyFormatter.format(e.amount),
      ];
    }).toList();

    return pw.Table.fromTextArray(
      headers: headers,
      data: data,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey800),
      cellHeight: 25,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerLeft,
        3: pw.Alignment.center,
        4: pw.Alignment.centerRight,
      },
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(3),
        3: const pw.FlexColumnWidth(2),
        4: const pw.FlexColumnWidth(2),
      },
      oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey50),
    );
  }

  pw.Widget _buildFooter() {
    return pw.Column(
      children: [
        pw.Divider(color: PdfColors.grey300),
        pw.SizedBox(height: 4),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Generated on ${DateFormat('dd MMM yyyy HH:mm').format(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey500),
            ),
            pw.Text(
              'Page 1', // Simple pagination placeholder
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey500),
            ),
          ],
        ),
      ],
    );
  }
}
