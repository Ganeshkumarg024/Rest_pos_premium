import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restaurant_billing/presentation/providers/order_provider.dart';
import 'package:restaurant_billing/core/theme/app_theme.dart';
import 'package:restaurant_billing/core/utils/currency_formatter.dart';
import 'package:restaurant_billing/core/utils/date_formatter.dart';
import 'package:restaurant_billing/core/constants/app_constants.dart';
import 'package:restaurant_billing/presentation/screens/orders/order_detail_screen.dart';

class OrdersListScreen extends ConsumerStatefulWidget {
  const OrdersListScreen({super.key});

  @override
  ConsumerState<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends ConsumerState<OrdersListScreen> {
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ordersProvider.notifier).loadOrders();
    });
  }

  void _applyFilter(String filter) {
    setState(() => _selectedFilter = filter);
    
    if (filter == 'all') {
      ref.read(ordersProvider.notifier).loadOrders();
    } else {
      ref.read(ordersProvider.notifier).loadOrdersByStatus(filter);
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
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
    final ordersAsync = ref.watch(ordersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
      ),
      body: Column(
        children: [
          // Filter Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: Row(
              children: [
                _FilterChip(
                  label: 'All',
                  isSelected: _selectedFilter == 'all',
                  onTap: () => _applyFilter('all'),
                ),
                const SizedBox(width: AppTheme.spacingS),
                _FilterChip(
                  label: 'Open',
                  isSelected: _selectedFilter == AppConstants.orderStatusOpen,
                  onTap: () => _applyFilter(AppConstants.orderStatusOpen),
                ),
                const SizedBox(width: AppTheme.spacingS),
                _FilterChip(
                  label: 'Completed',
                  isSelected: _selectedFilter == AppConstants.orderStatusCompleted,
                  onTap: () => _applyFilter(AppConstants.orderStatusCompleted),
                ),
                const SizedBox(width: AppTheme.spacingS),
                _FilterChip(
                  label: 'Cancelled',
                  isSelected: _selectedFilter == AppConstants.orderStatusCancelled,
                  onTap: () => _applyFilter(AppConstants.orderStatusCancelled),
                ),
              ],
            ),
          ),

          // Orders List
          Expanded(
            child: ordersAsync.when(
              data: (orders) {
                if (orders.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: AppTheme.spacingM),
                        Text(
                          'No orders found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    _applyFilter(_selectedFilter);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppTheme.spacingM),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(AppTheme.spacingM),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                order.orderNumber,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppTheme.spacingS,
                                  vertical: AppTheme.spacingXS,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(order.status).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                                ),
                                child: Text(
                                  order.status.toUpperCase(),
                                  style: TextStyle(
                                    color: _getStatusColor(order.status),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: AppTheme.spacingS),
                              if (order.tableName != null)
                                Row(
                                  children: [
                                    const Icon(Icons.table_restaurant, size: 16),
                                    const SizedBox(width: AppTheme.spacingXS),
                                    Text(order.tableName!),
                                  ],
                                ),
                              const SizedBox(height: AppTheme.spacingXS),
                              Row(
                                children: [
                                  const Icon(Icons.access_time, size: 16),
                                  const SizedBox(width: AppTheme.spacingXS),
                                  Text(DateFormatter.formatRelative(order.createdAt)),
                                ],
                              ),
                              const SizedBox(height: AppTheme.spacingS),
                              Text(
                                CurrencyFormatter.format(order.totalAmount),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () async {
                            // Navigate to order details
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OrderDetailScreen(order: order),
                              ),
                            );
                            
                            // Refresh orders list if changes were made
                            if (result == true && mounted) {
                              _applyFilter(_selectedFilter);
                            }
                          },
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: AppTheme.spacingM),
                    Text('Error: $error'),
                    const SizedBox(height: AppTheme.spacingM),
                    ElevatedButton(
                      onPressed: () => _applyFilter(_selectedFilter),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingM,
          vertical: AppTheme.spacingS,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
