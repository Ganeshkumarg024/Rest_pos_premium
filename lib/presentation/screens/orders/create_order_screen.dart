import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restaurant_billing/presentation/providers/menu_provider.dart';
import 'package:restaurant_billing/presentation/providers/order_provider.dart';
import 'package:restaurant_billing/presentation/providers/restaurant_provider.dart';
import 'package:restaurant_billing/core/theme/app_theme.dart';
import 'package:restaurant_billing/core/utils/currency_formatter.dart';
import 'package:restaurant_billing/core/constants/app_constants.dart';
import 'package:restaurant_billing/data/models/order_model.dart';
import 'package:restaurant_billing/data/models/order_item_model.dart';
import 'package:restaurant_billing/data/repositories/order_repository.dart';
import 'package:restaurant_billing/presentation/screens/orders/billing_screen.dart';


class CreateOrderScreen extends ConsumerStatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  ConsumerState<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends ConsumerState<CreateOrderScreen> with SingleTickerProviderStateMixin {
  String _orderType = AppConstants.orderTypeDineIn;
  final _tableController = TextEditingController();
  final _searchController = TextEditingController();
  late TabController _tabController;
  double _discountAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {}); // Rebuild when tab changes
      }
    });
  }

  @override
  void dispose() {
    _tableController.dispose();
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _proceedToBilling() async {
    final cart = ref.read(cartProvider);
    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add items to cart')),
      );
      return;
    }

    // Generate order number
    final orderNumber = await OrderRepository().generateOrderNumber();
    
    // Calculate totals
    final restaurant = ref.read(restaurantProvider).value;
    final taxEnabled = restaurant?.taxEnabled ?? true;
    final taxPercentage = restaurant?.taxPercentage ?? AppConstants.defaultTaxPercentage;
    
    final subtotal = ref.read(cartProvider.notifier).subtotal;
    final taxAmount = taxEnabled ? ref.read(cartProvider.notifier).calculateTax(taxPercentage) : 0.0;
    final total = subtotal + taxAmount - _discountAmount;

    // Create order
    final order = OrderModel(
      orderNumber: orderNumber,
      orderType: _orderType,
      subtotal: subtotal,
      discountAmount: _discountAmount,
      taxAmount: taxAmount,
      totalAmount: total,
    );

    // Create order items
    final orderItems = cart.map((item) => OrderItemModel(
      orderId: 0, // Will be set by repository
      menuItemId: item.menuItemId,
      quantity: item.quantity,
      unitPrice: item.price,
      totalPrice: item.total,
    )).toList();

    // Save order
    final orderId = await ref.read(ordersProvider.notifier).createOrder(order, orderItems);

    if (orderId != null && mounted) {
      ref.read(cartProvider.notifier).clear();
      
      // Navigate to billing screen instead of popping
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => BillingScreen(orderId: orderId),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final menuItemsAsync = ref.watch(menuItemsProvider);
    final restaurant = ref.watch(restaurantProvider).value;
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    
    final taxEnabled = restaurant?.taxEnabled ?? true;
    final taxPercentage = restaurant?.taxPercentage ?? AppConstants.defaultTaxPercentage;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Order'),
      ),
      body: Column(
        children: [
          // Order Type Selection
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: Row(
              children: [
                Expanded(
                  child: _OrderTypeChip(
                    label: 'Dine-in',
                    isSelected: _orderType == AppConstants.orderTypeDineIn,
                    onTap: () => setState(() => _orderType = AppConstants.orderTypeDineIn),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingS),
                Expanded(
                  child: _OrderTypeChip(
                    label: 'Takeaway',
                    isSelected: _orderType == AppConstants.orderTypeTakeaway,
                    onTap: () => setState(() => _orderType = AppConstants.orderTypeTakeaway),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingS),
                Expanded(
                  child: _OrderTypeChip(
                    label: 'Delivery',
                    isSelected: _orderType == AppConstants.orderTypeDelivery,
                    onTap: () => setState(() => _orderType = AppConstants.orderTypeDelivery),
                  ),
                ),
              ],
            ),
          ),

          // Table Number (if dine-in)
          if (_orderType == AppConstants.orderTypeDineIn)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
              child: TextField(
                controller: _tableController,
                decoration: const InputDecoration(
                  labelText: 'Table Number',
                  hintText: 'T-12',
                ),
              ),
            ),

          const SizedBox(height: AppTheme.spacingM),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search for food or drinks',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),

          const SizedBox(height: AppTheme.spacingM),

          // Category Tabs
          categoriesAsync.when(
            data: (categories) => TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: AppTheme.primaryColor,
              unselectedLabelColor: AppTheme.textSecondary,
              indicatorColor: AppTheme.primaryColor,
              tabs: categories.map((cat) => Tab(text: cat.name)).toList(),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // Menu Items List
          Expanded(
            child: categoriesAsync.when(
              data: (categories) {
                return menuItemsAsync.when(
                  data: (menuItems) {
                    // Get the selected category
                    final selectedCategory = categories.isNotEmpty && _tabController.index < categories.length
                        ? categories[_tabController.index]
                        : null;

                    // Filter items by category, search query, and availability
                    final filteredItems = menuItems.where((item) {
                      final searchQuery = _searchController.text.toLowerCase();
                      final matchesSearch = item.name.toLowerCase().contains(searchQuery);
                      final matchesCategory = selectedCategory == null || item.categoryId == selectedCategory.id;
                      return matchesSearch && matchesCategory && item.isAvailable;
                    }).toList();

                return ListView.builder(
                  padding: const EdgeInsets.all(AppTheme.spacingM),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    final cartItem = cart.firstWhere(
                      (c) => c.menuItemId == item.id,
                      orElse: () => CartItem(menuItemId: -1, name: '', price: 0),
                    );
                    final quantity = cartItem.menuItemId == item.id ? cartItem.quantity : 0;

                    return Card(
                      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
                      child: ListTile(
                        leading: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                            child: item.imagePath != null && File(item.imagePath!).existsSync()
                                ? Image.file(
                                    File(item.imagePath!),
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(Icons.fastfood, color: AppTheme.primaryColor);
                                    },
                                  )
                                : Icon(Icons.fastfood, color: AppTheme.primaryColor),
                          ),
                        ),
                        title: Text(item.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (item.description != null)
                              Text(
                                item.description!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            Text(
                              CurrencyFormatter.format(item.price),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                        trailing: quantity > 0
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline),
                                    color: AppTheme.primaryColor,
                                    onPressed: () {
                                      cartNotifier.updateQuantity(item.id!, quantity - 1);
                                    },
                                  ),
                                  Text(
                                    '$quantity',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle),
                                    color: AppTheme.primaryColor,
                                    onPressed: () {
                                      cartNotifier.updateQuantity(item.id!, quantity + 1);
                                    },
                                  ),
                                ],
                              )
                            : ElevatedButton(
                                onPressed: () {
                                  cartNotifier.addItem(item.id!, item.name, item.price);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.successColor,
                                ),
                                child: const Text('Add'),
                              ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(child: Text('Error: $error')),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Center(child: CircularProgressIndicator()),
            ),
          ),

          // Cart Summary
          if (cart.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Subtotal'),
                      Text(CurrencyFormatter.format(cartNotifier.subtotal)),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Add Discount'),
                      Text(
                        CurrencyFormatter.format(_discountAmount),
                        style: const TextStyle(color: AppTheme.primaryColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  if (taxEnabled) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Tax (${taxPercentage.toStringAsFixed(1)}%)'),
                        Text(CurrencyFormatter.format(cartNotifier.calculateTax(taxPercentage))),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingS),
                  ],
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(cartNotifier.calculateTotal(10.0, _discountAmount)),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _proceedToBilling,
                      child: Text('Review Order (${cart.length} items)'),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _OrderTypeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _OrderTypeChip({
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
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
