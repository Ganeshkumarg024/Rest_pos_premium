import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restaurant_billing/presentation/providers/theme_provider.dart';
import 'package:restaurant_billing/core/theme/app_theme.dart';
import 'package:restaurant_billing/presentation/screens/settings/restaurant_profile_screen.dart';
import 'package:restaurant_billing/presentation/screens/menu/category_management_screen.dart';
import 'package:restaurant_billing/presentation/screens/tables/table_management_screen.dart';
import 'package:restaurant_billing/presentation/screens/settings/tax_settings_screen.dart';
import 'package:restaurant_billing/presentation/screens/settings/notification_settings_screen.dart';
import 'package:restaurant_billing/presentation/screens/settings/printer_settings_screen.dart';
import 'package:restaurant_billing/presentation/screens/expenses/expense_list_screen.dart';
import 'package:restaurant_billing/presentation/screens/todos/todo_list_screen.dart';
import 'package:restaurant_billing/presentation/screens/analytics/sales_analytics_screen.dart';


class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        children: [
          Text(
            'Home / Settings',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            'Settings',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            'Manage your restaurant\'s configuration and preferences.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: AppTheme.spacingL),

          // Restaurant Profile
          _SettingCard(
            icon: Icons.restaurant,
            title: 'Restaurant Profile',
            subtitle: 'Update your business name, address, and contact details.',
            iconColor: AppTheme.primaryColor,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RestaurantProfileScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: AppTheme.spacingM),
          _SettingCard(
            icon: Icons.category,
            title: 'Category Management',
            subtitle: 'Manage menu categories and their display order.',
            iconColor: AppTheme.secondaryColor,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CategoryManagementScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: AppTheme.spacingM),
          _SettingCard(
            icon: Icons.table_restaurant,
            title: 'Table Management',
            subtitle: 'Add, edit, and manage restaurant tables.',
            iconColor: Colors.green,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TableManagementScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: AppTheme.spacingM),

          // // Payment Gateways
          // _SettingCard(
          //   icon: Icons.credit_card,
          //   title: 'Payment Gateways',
          //   subtitle: 'Connect and manage your payment processing options.',
          //   onTap: () {},
          // ),

          // const SizedBox(height: AppTheme.spacingM),

          // // User Permissions
          // _SettingCard(
          //   icon: Icons.people,
          //   title: 'User Permissions',
          //   subtitle: 'Define roles and access levels for your staff.',
          //   onTap: () {},
          // ),

          const SizedBox(height: AppTheme.spacingM),

          // Notifications
          _SettingCard(
            icon: Icons.notifications,
            title: 'Notifications',
            subtitle: 'Configure email and push notification settings.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationSettingsScreen(),
                ),
              );
            },
          ),

          // const SizedBox(height: AppTheme.spacingM),

          // // Billing & Subscription (UI only)
          // _SettingCard(
          //   icon: Icons.receipt,
          //   title: 'Billing & Subscription',
          //   subtitle: 'Manage your subscription plan and view payment history.',
          //   onTap: () {},
          // ),

          // const SizedBox(height: AppTheme.spacingM),

          // // API & Integrations (UI only)
          // _SettingCard(
          //   icon: Icons.api,
          //   title: 'API & Integrations',
          //   subtitle: 'Connect with third-party services and manage API keys.',
          //   onTap: () {},
          // ),

          // const SizedBox(height: AppTheme.spacingM),

          // Tax Setup
          _SettingCard(
            icon: Icons.calculate,
            title: 'Tax Setup',
            subtitle: 'Configure default tax percentages and rules.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TaxSettingsScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: AppTheme.spacingM),

          // Expense Tracker
          _SettingCard(
            icon: Icons.account_balance_wallet,
            title: 'Expense Tracker',
            subtitle: 'Track daily expenses, manage categories, and view reports.',
            iconColor: Colors.orange,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ExpenseListScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: AppTheme.spacingM),

          // Todo List
          _SettingCard(
            icon: Icons.check_box,
            title: 'Todo List',
            subtitle: 'Manage your expense-related tasks and action items.',
            iconColor: Colors.green,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TodoListScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: AppTheme.spacingM),

          // Sales Analytics
          _SettingCard(
            icon: Icons.analytics,
            title: 'Sales Analytics',
            subtitle: 'View trends, top items, and customer insights.',
            iconColor: Colors.purple,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SalesAnalyticsScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: AppTheme.spacingM),



          const SizedBox(height: AppTheme.spacingM),

          // Printer Configuration (UI only)
          _SettingCard(
            icon: Icons.print,
            title: 'Printer Configuration',
            subtitle: 'Setup Bluetooth or WiFi printer for receipts.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PrinterSettingsScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: AppTheme.spacingM),

          // Dark Mode Toggle
          Card(
            child: SwitchListTile(
              secondary: Icon(
                isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: AppTheme.primaryColor,
              ),
              title: const Text('Dark Mode'),
              subtitle: const Text('Toggle between light and dark theme'),
              value: isDarkMode,
              activeThumbColor: AppTheme.primaryColor,
              onChanged: (value) {
                ref.read(themeModeProvider.notifier).toggleTheme();
              },
            ),
          ),

          const SizedBox(height: AppTheme.spacingM),

          // Backup & Restore
          _SettingCard(
            icon: Icons.backup,
            title: 'Backup & Restore',
            subtitle: 'Export or import your local database.',
            onTap: () {},
          ),

          const SizedBox(height: AppTheme.spacingM),

          // Clear Database
          _SettingCard(
            icon: Icons.delete_forever,
            title: 'Clear Database',
            subtitle: 'Delete all local data (cannot be undone).',
            iconColor: AppTheme.errorColor,
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear Database'),
                  content: const Text(
                    'Are you sure you want to delete all data? This action cannot be undone.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Database cleared')),
                        );
                      },
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: AppTheme.errorColor),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SettingCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;

  const _SettingCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(AppTheme.spacingS),
          decoration: BoxDecoration(
            color: (iconColor ?? AppTheme.primaryColor).withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
          ),
          child: Icon(
            icon,
            color: iconColor ?? AppTheme.primaryColor,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
