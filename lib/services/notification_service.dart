import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:restaurant_billing/core/utils/app_preferences.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._init();
  
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationService._init();

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }

  void _onNotificationTap(NotificationResponse response) {
    // Handle notification tap
    // Can navigate to specific screens based on payload
  }

  Future<void> showOrderNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'orders',
      'Order Notifications',
      channelDescription: 'Notifications for order updates',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      DateTime.now().millisecond,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  Future<void> showPaymentNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'payments',
      'Payment Notifications',
      channelDescription: 'Notifications for payment updates',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      DateTime.now().millisecond,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  Future<void> showSystemNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'system',
      'System Notifications',
      channelDescription: 'System notifications and alerts',
      importance: Importance.defaultImportance,
      priority: Priority.defaultImportance,
      playSound: true,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      DateTime.now().millisecond,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  Future<void> showTestNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'test',
      'Test Notifications',
      channelDescription: 'Test notifications',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      0,
      'Test Notification',
      'This is a test notification from The Golden Spoon',
      notificationDetails,
    );
  }

  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }

  Future<void> cancel(int id) async {
    await _notificationsPlugin.cancel(id);
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
