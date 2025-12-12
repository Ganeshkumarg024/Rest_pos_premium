import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/order_model.dart';
import '../../data/models/order_item_model.dart';
import '../../data/repositories/order_repository.dart';

// Repository provider
final orderRepositoryProvider = Provider((ref) => OrderRepository());

// Orders provider
final ordersProvider = StateNotifierProvider<OrdersNotifier, AsyncValue<List<OrderModel>>>((ref) {
  return OrdersNotifier(ref.read(orderRepositoryProvider));
});

class OrdersNotifier extends StateNotifier<AsyncValue<List<OrderModel>>> {
  final OrderRepository _repository;

  OrdersNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadOrders();
  }

  Future<void> loadOrders() async {
    state = const AsyncValue.loading();
    try {
      final orders = await _repository.getAllOrders();
      state = AsyncValue.data(orders);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> loadOrdersByStatus(String status) async {
    state = const AsyncValue.loading();
    try {
      final orders = await _repository.getOrdersByStatus(status);
      state = AsyncValue.data(orders);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<int?> createOrder(OrderModel order, List<OrderItemModel> items) async {
    try {
      final orderId = await _repository.createOrder(order);
      
      for (var item in items) {
        await _repository.createOrderItem(item.copyWith(orderId: orderId));
      }
      
      await loadOrders();
      return orderId;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return null;
    }
  }

  Future<void> updateOrderStatus(int id, String status) async {
    try {
      await _repository.updateOrderStatus(id, status);
      await loadOrders();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Dashboard stats provider
final dashboardStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.read(orderRepositoryProvider);
  return await repository.getTodayStats();
});

// Pending orders provider (orders awaiting payment)
final pendingOrdersProvider = FutureProvider<List<OrderModel>>((ref) async {
  final repository = ref.read(orderRepositoryProvider);
  return await repository.getOrdersByStatus('open');
});

// Cart provider (for creating orders)
class CartItem {
  final int menuItemId;
  final String name;
  final double price;
  int quantity;

  CartItem({
    required this.menuItemId,
    required this.name,
    required this.price,
    this.quantity = 1,
  });

  double get total => price * quantity;
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addItem(int menuItemId, String name, double price) {
    final existingIndex = state.indexWhere((item) => item.menuItemId == menuItemId);
    
    if (existingIndex >= 0) {
      final updatedList = [...state];
      updatedList[existingIndex].quantity++;
      state = updatedList;
    } else {
      state = [
        ...state,
        CartItem(menuItemId: menuItemId, name: name, price: price),
      ];
    }
  }

  void removeItem(int menuItemId) {
    state = state.where((item) => item.menuItemId != menuItemId).toList();
  }

  void updateQuantity(int menuItemId, int quantity) {
    if (quantity <= 0) {
      removeItem(menuItemId);
      return;
    }

    final updatedList = [...state];
    final index = updatedList.indexWhere((item) => item.menuItemId == menuItemId);
    if (index >= 0) {
      updatedList[index].quantity = quantity;
      state = updatedList;
    }
  }

  void clear() {
    state = [];
  }

  double get subtotal {
    return state.fold(0.0, (sum, item) => sum + item.total);
  }

  double calculateTax(double taxPercentage) {
    return subtotal * (taxPercentage / 100);
  }

  double calculateTotal(double taxPercentage, double discountAmount) {
    return subtotal + calculateTax(taxPercentage) - discountAmount;
  }
}
