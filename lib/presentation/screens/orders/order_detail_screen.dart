import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restaurant_billing/core/theme/app_theme.dart';
import 'package:restaurant_billing/core/utils/currency_formatter.dart';
import 'package:restaurant_billing/core/utils/date_formatter.dart';
import 'package:restaurant_billing/core/constants/app_constants.dart';
import 'package:restaurant_billing/data/models/order_model.dart';
import 'package:restaurant_billing/presentation/providers/order_provider.dart';
import 'package:restaurant_billing/presentation/screens/orders/invoice_screen.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  final OrderModel order;

  const OrderDetailScreen({
    super.key,
    required this.order,
  });

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  bool _isLoading = false;
  OrderModel? _fullOrder;

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  Future<void> _loadOrderDetails() async {
    setState(() => _isLoading = true);

    try {
      final repo = ref.read(orderRepositoryProvider);
      final order = await repo.getOrderById(widget.order.id!);
      
      if (mounted) {
        setState(() {
          _fullOrder = order ?? widget.order;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _fullOrder = widget.order;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading order details: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _completeOrder() async {
    setState(() => _isLoading = true);

    try {
      await ref
          .read(ordersProvider.notifier)
          .updateOrderStatus(widget.order.id!, AppConstants.orderStatusCompleted);

      if (mounted) {
        // Navigate to invoice screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => InvoiceScreen(orderId: widget.order.id!),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error completing order: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _cancelOrder() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content: const Text('Are you sure you want to cancel this order? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      await ref
          .read(ordersProvider.notifier)
          .updateOrderStatus(widget.order.id!, AppConstants.orderStatusCancelled);

      if (mounted) {
        Navigator.pop(context, true); // Return to orders list
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order cancelled successfully'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cancelling order: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  void _viewInvoice() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InvoiceScreen(orderId: widget.order.id!),
      ),
    );
  }

  Color _getStatusColor() {
    switch (widget.order.status) {
      case AppConstants.orderStatusOpen:
        return AppTheme.warningColor;
      case AppConstants.orderStatusCompleted:
        return AppTheme.successColor;
      case AppConstants.orderStatusCancelled:
        return AppTheme.errorColor;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_fullOrder == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Order Details'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final order = _fullOrder!;
    final isCancelled = order.status == AppConstants.orderStatusCancelled;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Header Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withOpacity(0.1),
                      border: Border(
                        bottom: BorderSide(
                          color: _getStatusColor().withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                order.orderNumber,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: isCancelled ? Colors.grey : Colors.black,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                order.status.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(
                              Icons.table_restaurant,
                              size: 20,
                              color: isCancelled ? Colors.grey : AppTheme.primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              order.tableName ?? 'N/A',
                              style: TextStyle(
                                fontSize: 16,
                                color: isCancelled ? Colors.grey : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 20,
                              color: isCancelled ? Colors.grey : AppTheme.primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              DateFormatter.formatRelative(order.createdAt),
                              style: TextStyle(
                                fontSize: 14,
                                color: isCancelled ? Colors.grey : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Items List
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order Items',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isCancelled ? Colors.grey : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16),

                        if (order.items != null && order.items!.isNotEmpty)
                          ...order.items!.map((item) => Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: (isCancelled ? Colors.grey : AppTheme.primaryColor)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${item.quantity}x',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: isCancelled ? Colors.grey : AppTheme.primaryColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.menuItemName ?? 'Unknown Item',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: isCancelled ? Colors.grey : Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          CurrencyFormatter.format(item.unitPrice),
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: isCancelled ? Colors.grey : Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    CurrencyFormatter.format(item.totalPrice),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: isCancelled ? Colors.grey : AppTheme.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ))
                        else
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32),
                              child: Text(
                                'No items in this order',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),

                        const SizedBox(height: 24),

                        // Totals
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Subtotal',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: isCancelled ? Colors.grey : Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    CurrencyFormatter.format(order.subtotal),
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: isCancelled ? Colors.grey : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Tax',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: isCancelled ? Colors.grey : Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    CurrencyFormatter.format(order.taxAmount),
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: isCancelled ? Colors.grey : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: isCancelled ? Colors.grey : Colors.black,
                                    ),
                                  ),
                                  Text(
                                    CurrencyFormatter.format(order.totalAmount),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: isCancelled ? Colors.grey : AppTheme.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Action Buttons based on status
                        if (order.status == AppConstants.orderStatusOpen) ...[
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton.icon(
                              onPressed: _completeOrder,
                              icon: const Icon(Icons.check_circle, size: 24),
                              label: const Text(
                                'Complete Order',
                                style: TextStyle(fontSize: 16),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.successColor,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: OutlinedButton.icon(
                              onPressed: _cancelOrder,
                              icon: const Icon(Icons.cancel, size: 24),
                              label: const Text(
                                'Cancel Order',
                                style: TextStyle(fontSize: 16),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.errorColor,
                                side: const BorderSide(color: AppTheme.errorColor),
                              ),
                            ),
                          ),
                        ] else if (order.status == AppConstants.orderStatusCompleted) ...[
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton.icon(
                              onPressed: _viewInvoice,
                              icon: const Icon(Icons.receipt_long, size: 24),
                              label: const Text(
                                'View Invoice',
                                style: TextStyle(fontSize: 16),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
