import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restaurant_billing/data/models/order_model.dart';
import 'package:restaurant_billing/data/models/payment_model.dart';
import 'package:restaurant_billing/data/models/restaurant_model.dart';
import 'package:restaurant_billing/data/repositories/order_repository.dart';
import 'package:restaurant_billing/data/repositories/restaurant_repository.dart';
import 'package:restaurant_billing/presentation/providers/order_provider.dart';
import 'package:restaurant_billing/core/theme/app_theme.dart';
import 'package:restaurant_billing/core/utils/currency_formatter.dart';
import 'package:restaurant_billing/core/constants/app_constants.dart';
import 'package:restaurant_billing/services/printing_service.dart';
import 'package:restaurant_billing/presentation/screens/orders/invoice_screen.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';


class BillingScreen extends ConsumerStatefulWidget {
  final int orderId;

  const BillingScreen({
    super.key,
    required this.orderId,
  });

  @override
  ConsumerState<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends ConsumerState<BillingScreen> {
  String _selectedPaymentMethod = 'cash';
  bool _isProcessing = false;

  Future<void> _generateInvoice() async {
    setState(() => _isProcessing = true);

    try {
      final orderRepository = OrderRepository();
      
      // Update order status to completed
      await orderRepository.updateOrderStatus(widget.orderId, AppConstants.orderStatusCompleted);
      
      // Create payment record
      final order = await orderRepository.getOrderById(widget.orderId);
      if (order != null) {
        final payment = PaymentModel(
          orderId: widget.orderId,
          paymentMethod: _selectedPaymentMethod,
          amount: order.totalAmount,
        );
        await orderRepository.createPayment(payment);
      }

      if (mounted) {
        // Navigate to invoice screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => InvoiceScreen(orderId: widget.orderId),
          ),
        );
        
        // Refresh orders list
        ref.read(ordersProvider.notifier).loadOrders();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _printInvoice() async {
    try {
      final orderRepository = OrderRepository();
      final order = await orderRepository.getOrderById(widget.orderId);
      
      if (order == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Order not found')),
          );
        }
        return;
      }

      // Get restaurant details (optional, can be null)
      RestaurantModel? restaurant;
      
      final printingService = PrintingService();
      
      // Check Bluetooth availability
      if (!await printingService.isBluetoothAvailable()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bluetooth is not available on this device')),
          );
        }
        return;
      }

      // Check if Bluetooth is enabled
      if (!await printingService.isBluetoothEnabled()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enable Bluetooth')),
          );
        }
        return;
      }

      // Request permissions
      if (!await printingService.requestPermissions()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bluetooth permissions denied')),
          );
        }
        return;
      }

      // Get bonded devices
      final devices = await printingService.getBondedDevices();
      
      if (devices.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No paired Bluetooth devices found. Please pair a printer first.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      // Show device selection dialog
      if (mounted) {
        final selectedDevice = await showDialog<BluetoothDevice>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Select Printer'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  final device = devices[index];
                  return ListTile(
                    leading: const Icon(Icons.print),
                    title: Text(device.name ?? 'Unknown Device'),
                    subtitle: Text(device.address),
                    onTap: () => Navigator.pop(context, device),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        );

        if (selectedDevice != null) {
          // Show loading
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ),
          );

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
                    : 'Failed to print invoice. Please check printer connection.',
                ),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Summary'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      ),
      body: FutureBuilder<OrderModel?>(
        future: OrderRepository().getOrderById(widget.orderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final order = snapshot.data;
          if (order == null) {
            return const Center(child: Text('Order not found'));
          }

          return FutureBuilder<RestaurantModel?>(
            future: RestaurantRepository().getRestaurant(),
            builder: (context, restaurantSnapshot) {
              final restaurant = restaurantSnapshot.data;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Restaurant Header
                    if (restaurant != null) ...[
                      Column(
                        children: [
                          // Restaurant Logo
                          if (restaurant.logoPath != null)
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppTheme.primaryColor.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: ClipOval(
                                child: Image.file(
                                  File(restaurant.logoPath!),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: AppTheme.primaryColor.withOpacity(0.1),
                                      child: const Icon(
                                        Icons.restaurant,
                                        size: 40,
                                        color: AppTheme.primaryColor,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            )
                          else
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                border: Border.all(
                                  color: AppTheme.primaryColor.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.restaurant,
                                size: 40,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          const SizedBox(height: AppTheme.spacingM),
                          
                          // Restaurant Name
                          Text(
                            restaurant.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          // Restaurant Address
                          if (restaurant.address != null && restaurant.address!.isNotEmpty) ...[
                            const SizedBox(height: AppTheme.spacingXS),
                            Text(
                              restaurant.address!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacingL),
                      const Divider(),
                      const SizedBox(height: AppTheme.spacingM),
                    ],

                    // Order Number
                    Text(
                      'Order ${order.orderNumber}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppTheme.spacingL),

                // Order Items Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingM),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Order Items List
                        if (order.items != null && order.items!.isNotEmpty)
                          ...order.items!.map((item) => Padding(
                                padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.menuItemName ?? 'Unknown Item',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            '${item.quantity} × ${CurrencyFormatter.format(item.unitPrice)}',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      CurrencyFormatter.format(item.totalPrice),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                        else
                          const Text('No items in order'),

                        const Divider(height: AppTheme.spacingL),

                        // Subtotal
                        _buildSummaryRow('Subtotal', order.subtotal),
                        const SizedBox(height: AppTheme.spacingS),

                        // Tax
                        _buildSummaryRow('Taxes (GST)', order.taxAmount),
                        const SizedBox(height: AppTheme.spacingS),

                        // Discount
                        if (order.discountAmount > 0) ...[
                          _buildSummaryRow(
                            'Discount',
                            -order.discountAmount,
                            color: AppTheme.successColor,
                          ),
                          const SizedBox(height: AppTheme.spacingS),
                        ],

                        const Divider(),

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
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppTheme.spacingL),

                // Payment Method Selection
                const Text(
                  'Select Payment Method',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingM),

                Row(
                  children: [
                    Expanded(
                      child: _PaymentMethodCard(
                        icon: Icons.money,
                        label: 'Cash',
                        value: 'cash',
                        selectedValue: _selectedPaymentMethod,
                        onTap: () => setState(() => _selectedPaymentMethod = 'cash'),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingM),
                    Expanded(
                      child: _PaymentMethodCard(
                        icon: Icons.credit_card,
                        label: 'Card',
                        value: 'card',
                        selectedValue: _selectedPaymentMethod,
                        onTap: () => setState(() => _selectedPaymentMethod = 'card'),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingM),
                    Expanded(
                      child: _PaymentMethodCard(
                        icon: Icons.qr_code,
                        label: 'UPI',
                        value: 'upi',
                        selectedValue: _selectedPaymentMethod,
                        onTap: () => setState(() => _selectedPaymentMethod = 'upi'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppTheme.spacingL),

                // Generate Invoice Button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _generateInvoice,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Generate Invoice',
                            style: TextStyle(fontSize: 18),
                          ),
                  ),
                ),

                const SizedBox(height: AppTheme.spacingM),

                // Print Button
                SizedBox(
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: _printInvoice,
                    icon: const Icon(Icons.print),
                    label: const Text(
                      'Print',
                      style: TextStyle(fontSize: 18),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      side: const BorderSide(color: AppTheme.primaryColor),
                    ),
                  ),
                ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          CurrencyFormatter.format(amount),
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String selectedValue;
  final VoidCallback onTap;

  const _PaymentMethodCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.selectedValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selectedValue;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? AppTheme.primaryColor : Colors.grey[600],
            ),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppTheme.primaryColor : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
