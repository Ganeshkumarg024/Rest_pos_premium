import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:restaurant_billing/data/models/order_model.dart';
import 'package:restaurant_billing/data/models/restaurant_model.dart';
import 'package:restaurant_billing/data/repositories/order_repository.dart';
import 'package:restaurant_billing/data/repositories/restaurant_repository.dart';
import 'package:restaurant_billing/core/theme/app_theme.dart';
import 'package:restaurant_billing/core/utils/currency_formatter.dart';
import 'package:restaurant_billing/services/printing_service.dart';
import 'package:restaurant_billing/services/pdf_generator_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class InvoiceScreen extends ConsumerStatefulWidget {
  final int orderId;

  const InvoiceScreen({
    super.key,
    required this.orderId,
  });

  @override
  ConsumerState<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends ConsumerState<InvoiceScreen> {
  Future<Map<String, dynamic>> _loadInvoiceData() async {
    final orderRepository = OrderRepository();
    final restaurantRepository = RestaurantRepository();

    final order = await orderRepository.getOrderById(widget.orderId);
    final restaurant = await restaurantRepository.getRestaurant();
    final items = await orderRepository.getOrderItems(widget.orderId);

    return {
      'order': order,
      'restaurant': restaurant,
      'items': items,
    };
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

  Future<void> _handlePrint(OrderModel order, RestaurantModel? restaurant) async {
    try {
      final printingService = PrintingService();
      
      // Check Bluetooth availability
      if (!await printingService.isBluetoothAvailable()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bluetooth not available')),
          );
        }
        return;
      }

      // Get paired devices
      final devices = await printingService.getBondedDevices();
      
      if (devices.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No paired Bluetooth devices found')),
          );
        }
        return;
      }

      // Use first device or show selection dialog
      final selectedDevice = devices.first;

      // Show loading dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      // Print invoice
      final printed = await printingService.printInvoice(
        selectedDevice,
        order,
        restaurant,
      );

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              printed 
                ? 'Invoice printed successfully' 
                : 'Failed to print invoice',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading if open
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _handleShare(OrderModel order, RestaurantModel? restaurant) async {
    try {
      final invoiceText = '''
Invoice: ${_generateInvoiceNumber(order.id!)}
${restaurant?.name ?? 'Restaurant'}
${restaurant?.address ?? ''}

Date: ${DateFormat('dd MMM, yyyy').format(order.createdAt)}
Time: ${DateFormat('hh:mm a').format(order.createdAt)}
Table: ${order.tableName ?? 'N/A'}

Items:
${order.items?.map((item) => '${item.menuItemName} x${item.quantity} - ${CurrencyFormatter.format(item.totalPrice)}').join('\n')}

Subtotal: ${CurrencyFormatter.format(order.subtotal)}
Tax: ${CurrencyFormatter.format(order.taxAmount)}
Total: ${CurrencyFormatter.format(order.totalAmount)}

Thank you for your visit!
      ''';

      await Share.share(invoiceText, subject: 'Invoice ${_generateInvoiceNumber(order.id!)}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing: $e')),
        );
      }
    }
  }

  Future<void> _handleDownload(OrderModel order, RestaurantModel? restaurant) async {
    try {
      // Show loading dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      // Generate PDF
      final pdfService = PdfGeneratorService();
      final pdfBytes = await pdfService.generateInvoicePDF(
        order: order,
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

      // Generate filename
      final invoiceNumber = _generateInvoiceNumber(order.id!);
      final filename = 'invoice_$invoiceNumber.pdf';
      final filePath = '${downloadsDir.path}/$filename';

      // Save PDF file
      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);

      if (mounted) {
        Navigator.pop(context); // Close loading dialog

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invoice saved to Downloads/$filename'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Open',
              textColor: Colors.white,
              onPressed: () {
                // Open file with default app
                // Note: This would require an additional package like open_file
                // For now, just showing the path
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading if open
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Invoice'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _loadInvoiceData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final order = snapshot.data!['order'] as OrderModel?;
          final restaurant = snapshot.data!['restaurant'] as RestaurantModel?;
          final items = snapshot.data!['items'] as List;

          if (order == null) {
            return const Center(child: Text('Order not found'));
          }

          final invoiceNumber = _generateInvoiceNumber(order.id!);

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Restaurant Logo
                      if (restaurant?.logoPath != null)
                        ClipOval(
                          child: Image.file(
                            File(restaurant!.logoPath!),
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.restaurant,
                                  size: 40,
                                  color: AppTheme.primaryColor,
                                ),
                              );
                            },
                          ),
                        )
                      else
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.restaurant,
                            size: 40,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      const SizedBox(height: 16),

                      // Restaurant Name
                      Text(
                        restaurant?.name ?? 'Restaurant',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),

                      // Restaurant Address
                      if (restaurant?.address != null && restaurant!.address!.isNotEmpty)
                        Text(
                          restaurant.address!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      
                      // Restaurant Phone
                      if (restaurant?.phone != null && restaurant!.phone!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Phone: ${restaurant.phone}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      
                      // Restaurant Email
                      if (restaurant?.email != null && restaurant!.email!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Email: ${restaurant.email}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: 32),

                      // Divider
                      Divider(color: Colors.grey[300], height: 1),
                      const SizedBox(height: 24),

                      // Invoice Details
                      _buildInvoiceRow('Invoice #', invoiceNumber),
                      const SizedBox(height: 12),
                      _buildInvoiceRow('Date', DateFormat('dd MMMM, yyyy').format(order.createdAt)),
                      const SizedBox(height: 12),
                      _buildInvoiceRow('Time', DateFormat('hh:mm a').format(order.createdAt)),
                      const SizedBox(height: 12),
                      _buildInvoiceRow('Table #', order.tableName ?? 'N/A'),
                      const SizedBox(height: 32),

                      // Divider
                      Divider(color: Colors.grey[300], height: 1),
                      const SizedBox(height: 24),

                      // Items Header
                      Row(
                        children: [
                          const Expanded(
                            flex: 3,
                            child: Text(
                              'Item',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const Expanded(
                            flex: 1,
                            child: Text(
                              'Qty',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Price',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Items List
                      ...items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                item.menuItemName ?? 'Unknown',
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                '${item.quantity}',
                                style: const TextStyle(fontSize: 15),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                CurrencyFormatter.format(item.totalPrice),
                                style: const TextStyle(fontSize: 15),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      )),
                      const SizedBox(height: 24),

                      // Divider
                      Divider(color: Colors.grey[300], height: 1),
                      const SizedBox(height: 16),

                      // Summary
                      _buildSummaryRow('Subtotal', order.subtotal),
                      const SizedBox(height: 12),
                      _buildSummaryRow('GST (${_calculateTaxPercentage(order).toStringAsFixed(0)}%)', order.taxAmount),
                      const SizedBox(height: 16),
                      
                      // Total
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            CurrencyFormatter.format(order.totalAmount),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Thank You Message
                      Text(
                        'Thank you for your visit!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Action Buttons
                      Row(
                        children: [
                          // Print Button
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _handlePrint(order, restaurant),
                              icon: const Icon(Icons.print, size: 20),
                              label: const Text('Print'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                side: BorderSide(color: Colors.grey[400]!),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Share Button
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _handleShare(order, restaurant),
                              icon: const Icon(Icons.share, size: 20),
                              label: const Text('Share'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                side: BorderSide(color: Colors.grey[400]!),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Download Button
                          Expanded(
                            flex: 2,
                            child: ElevatedButton.icon(
                              onPressed: () => _handleDownload(order, restaurant),
                              icon: const Icon(Icons.download, size: 20),
                              label: const Text('Download'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInvoiceRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 15),
        ),
        Text(
          CurrencyFormatter.format(amount),
          style: const TextStyle(fontSize: 15),
        ),
      ],
    );
  }
}
