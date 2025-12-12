import 'package:restaurant_billing/core/utils/app_preferences.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._init();

  NotificationService._init();

  Future<void> initialize() async {
    // Placeholder for future notification system integration
    print('Notification service initialized');
  }

  Future<void> showOrderNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    print('Order Notification: $title - $body');
  }

  Future<void> showPaymentNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    print('Payment Notification: $title - $body');
  }

  Future<void> showSystemNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    print('System Notification: $title - $body');
  }

  Future<void> showTestNotification() async {
    print('Test Notification: This is a test notification from The Chozha Pos');
  }

  Future<void> cancelAll() async {
    print('All notifications cancelled');
  }

  Future<void> cancel(int id) async {
    print('Cancelled notification: $id');
  }

  // Helper methods to check if notifications should be shown
  static Future<void> notifyNewOrder(String orderNumber) async {
    if (await AppPreferences.getNotifNewOrder()) {
      await instance.showOrderNotification(
        title: 'New Order Created',
        body: 'Order $orderNumber has been created',
        payload: 'order:$orderNumber',
      );
    }
  }

  static Future<void> notifyOrderCompleted(String orderNumber) async {
    if (await AppPreferences.getNotifOrderCompleted()) {
      await instance.showOrderNotification(
        title: 'Order Completed',
        body: 'Order $orderNumber has been completed',
        payload: 'order:$orderNumber',
      );
    }
  }

  static Future<void> notifyOrderCancelled(String orderNumber) async {
    if (await AppPreferences.getNotifOrderCancelled()) {
      await instance.showOrderNotification(
        title: 'Order Cancelled',
        body: 'Order $orderNumber has been cancelled',
        payload: 'order:$orderNumber',
      );
    }
  }

  static Future<void> notifyPaymentReceived(double amount) async {
    if (await AppPreferences.getNotifPaymentReceived()) {
      await instance.showPaymentNotification(
        title: 'Payment Received',
        body: 'Received payment of ₹${amount.toStringAsFixed(2)}',
      );
    }
  }
}
