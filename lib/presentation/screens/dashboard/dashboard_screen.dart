import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restaurant_billing/presentation/providers/order_provider.dart';
import 'package:restaurant_billing/presentation/providers/restaurant_provider.dart';
import 'package:restaurant_billing/core/theme/app_theme.dart';
import 'package:restaurant_billing/core/utils/currency_formatter.dart';
import 'package:restaurant_billing/presentation/widgets/summary_card.dart';
import 'package:restaurant_billing/presentation/widgets/quick_action_button.dart';
import 'package:restaurant_billing/presentation/screens/orders/create_order_screen.dart';
import 'package:restaurant_billing/presentation/screens/orders/orders_list_screen.dart';
import 'package:restaurant_billing/presentation/screens/orders/pending_payments_screen.dart';
import 'package:restaurant_billing/presentation/screens/menu/menu_screen.dart';
import 'package:restaurant_billing/presentation/screens/reports/reports_screen.dart';
import 'package:restaurant_billing/presentation/screens/settings/settings_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = 0;

  List<Widget> get _screens => [
    _DashboardHome(onNavigate: (index) => setState(() => _selectedIndex = index)),
    const OrdersListScreen(),
    const MenuScreen(),
    const ReportsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class _DashboardHome extends ConsumerWidget {
  final Function(int) onNavigate;
  
  const _DashboardHome({required this.onNavigate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('The Golden Spoon'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // Show profile or logout
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        await ref.read(authProvider.notifier).logout();
                        if (context.mounted) {
                          Navigator.of(context).pop(); // Close dialog
                          // Navigate to login screen and clear all routes
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            '/login',
                            (route) => false,
                          );
                        }
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardStatsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Cards
              statsAsync.when(
                data: (stats) => Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: SummaryCard(
                            title: "Today's Sales",
                            value: CurrencyFormatter.format(stats['totalSales'] ?? 0.0),
                            subtitle: '+15% vs yesterday',
                            icon: Icons.attach_money,
                            color: AppTheme.successColor,
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacingM),
                        Expanded(
                          child: SummaryCard(
                            title: 'Active Orders',
                            value: '${stats['activeOrders'] ?? 0}',
                            subtitle: '2 new in last hour',
                            icon: Icons.shopping_cart,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingM),
                    SummaryCard(
                      title: 'Pending Payments',
                      value: '${stats['pendingPayments'] ?? 0}',
                      subtitle: '1 waiting >10min',
                      icon: Icons.pending_actions,
                      color: AppTheme.warningColor,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PendingPaymentsScreen(),
                          ),
                        ).then((_) {
                          // Refresh dashboard after returning
                          ref.invalidate(dashboardStatsProvider);
                        });
                      },
                    ),
                  ],
                ),
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppTheme.spacingXL),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, stack) => Center(
                  child: Text('Error loading stats: $error'),
                ),
              ),

              const SizedBox(height: AppTheme.spacingL),

              // Quick Actions
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: AppTheme.spacingM),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: AppTheme.spacingM,
                crossAxisSpacing: AppTheme.spacingM,
                childAspectRatio: 1.5,
                children: [
                  QuickActionButton(
                    icon: Icons.add_circle,
                    label: 'New Order',
                    color: AppTheme.primaryColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateOrderScreen(),
                        ),
                      );
                    },
                  ),
                  QuickActionButton(
                    icon: Icons.bar_chart,
                    label: 'Reports',
                    color: AppTheme.secondaryColor,
                    onTap: () {
                      onNavigate(3); // Navigate to Reports tab
                    },
                  ),
                  QuickActionButton(
                    icon: Icons.restaurant_menu,
                    label: 'Menu',
                    color: AppTheme.warningColor,
                    onTap: () {
                      onNavigate(2); // Navigate to Menu tab
                    },
                  ),
                  QuickActionButton(
                    icon: Icons.settings,
                    label: 'Settings',
                    color: Colors.grey,
                    onTap: () {
                      onNavigate(4); // Navigate to Settings tab
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
