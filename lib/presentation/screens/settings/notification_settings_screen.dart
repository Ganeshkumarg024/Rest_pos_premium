import 'package:flutter/material.dart';
import 'package:restaurant_billing/core/theme/app_theme.dart';
import 'package:restaurant_billing/core/utils/app_preferences.dart';
import 'package:restaurant_billing/services/notification_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _notifNewOrder = true;
  bool _notifOrderCompleted = true;
  bool _notifOrderCancelled = true;
  bool _notifSound = true;
  bool _notifPaymentReceived = true;
  bool _notifPaymentFailed = true;
  bool _notifLowStock = false;
  bool _notifDailySummary = false;
  bool _notifWeeklyReport = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await Future.wait([
      AppPreferences.getNotifNewOrder(),
      AppPreferences.getNotifOrderCompleted(),
      AppPreferences.getNotifOrderCancelled(),
      AppPreferences.getNotifSound(),
      AppPreferences.getNotifPaymentReceived(),
      AppPreferences.getNotifPaymentFailed(),
      AppPreferences.getNotifLowStock(),
      AppPreferences.getNotifDailySummary(),
      AppPreferences.getNotifWeeklyReport(),
    ]);

    if (mounted) {
      setState(() {
        _notifNewOrder = settings[0];
        _notifOrderCompleted = settings[1];
        _notifOrderCancelled = settings[2];
        _notifSound = settings[3];
        _notifPaymentReceived = settings[4];
        _notifPaymentFailed = settings[5];
        _notifLowStock = settings[6];
        _notifDailySummary = settings[7];
        _notifWeeklyReport = settings[8];
      });
    }
  }

  Future<void> _saveSettings() async {
    await Future.wait([
      AppPreferences.setNotifNewOrder(_notifNewOrder),
      AppPreferences.setNotifOrderCompleted(_notifOrderCompleted),
      AppPreferences.setNotifOrderCancelled(_notifOrderCancelled),
      AppPreferences.setNotifSound(_notifSound),
      AppPreferences.setNotifPaymentReceived(_notifPaymentReceived),
      AppPreferences.setNotifPaymentFailed(_notifPaymentFailed),
      AppPreferences.setNotifLowStock(_notifLowStock),
      AppPreferences.setNotifDailySummary(_notifDailySummary),
      AppPreferences.setNotifWeeklyReport(_notifWeeklyReport),
    ]);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification settings saved'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _testNotification() async {
    await NotificationService.instance.showTestNotification();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test notification sent'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSettings,
            tooltip: 'Save Settings',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        children: [
          Text(
            'Notification Preferences',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            'Choose which notifications you want to receive',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: AppTheme.spacingL),

          // Order Notifications
          Text(
            'Order Notifications',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.add_shopping_cart, color: AppTheme.primaryColor),
                  title: const Text('New Order Created'),
                  subtitle: const Text('Get notified when a new order is placed'),
                  value: _notifNewOrder,
                  onChanged: (value) => setState(() => _notifNewOrder = value),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.check_circle, color: AppTheme.successColor),
                  title: const Text('Order Completed'),
                  subtitle: const Text('Get notified when an order is completed'),
                  value: _notifOrderCompleted,
                  onChanged: (value) => setState(() => _notifOrderCompleted = value),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.cancel, color: AppTheme.errorColor),
                  title: const Text('Order Cancelled'),
                  subtitle: const Text('Get notified when an order is cancelled'),
                  value: _notifOrderCancelled,
                  onChanged: (value) => setState(() => _notifOrderCancelled = value),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.spacingL),

          // Payment Notifications
          Text(
            'Payment Notifications',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.attach_money, color: AppTheme.successColor),
                  title: const Text('Payment Received'),
                  subtitle: const Text('Get notified when payment is received'),
                  value: _notifPaymentReceived,
                  onChanged: (value) => setState(() => _notifPaymentReceived = value),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.money_off, color: AppTheme.errorColor),
                  title: const Text('Payment Failed'),
                  subtitle: const Text('Get notified when payment fails'),
                  value: _notifPaymentFailed,
                  onChanged: (value) => setState(() => _notifPaymentFailed = value),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.spacingL),

          // System Notifications
          Text(
            'System Notifications',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.inventory, color: AppTheme.warningColor),
                  title: const Text('Low Stock Alert'),
                  subtitle: const Text('Get notified when items are running low'),
                  value: _notifLowStock,
                  onChanged: (value) => setState(() => _notifLowStock = value),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.assessment, color: AppTheme.secondaryColor),
                  title: const Text('Daily Sales Summary'),
                  subtitle: const Text('Receive daily sales report'),
                  value: _notifDailySummary,
                  onChanged: (value) => setState(() => _notifDailySummary = value),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.bar_chart, color: AppTheme.secondaryColor),
                  title: const Text('Weekly Report'),
                  subtitle: const Text('Receive weekly sales report'),
                  value: _notifWeeklyReport,
                  onChanged: (value) => setState(() => _notifWeeklyReport = value),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.spacingL),

          // Sound Settings
          Text(
            'Sound',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Card(
            child: SwitchListTile(
              secondary: Icon(
                _notifSound ? Icons.volume_up : Icons.volume_off,
                color: AppTheme.primaryColor,
              ),
              title: const Text('Notification Sound'),
              subtitle: const Text('Play sound with notifications'),
              value: _notifSound,
              onChanged: (value) => setState(() => _notifSound = value),
            ),
          ),

          const SizedBox(height: AppTheme.spacingXL),

          // Test Notification Button
          ElevatedButton.icon(
            onPressed: _testNotification,
            icon: const Icon(Icons.notifications_active),
            label: const Text('Test Notification'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
