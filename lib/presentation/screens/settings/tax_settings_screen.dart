import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restaurant_billing/core/theme/app_theme.dart';
import 'package:restaurant_billing/presentation/providers/restaurant_provider.dart';

class TaxSettingsScreen extends ConsumerStatefulWidget {
  const TaxSettingsScreen({super.key});

  @override
  ConsumerState<TaxSettingsScreen> createState() => _TaxSettingsScreenState();
}

class _TaxSettingsScreenState extends ConsumerState<TaxSettingsScreen> {
  bool _taxEnabled = true;
  double _taxPercentage = 10.0;
  bool _isLoading = false;
  bool _hasChanges = false;

  final _formKey = GlobalKey<FormState>();
  final _taxController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _taxController.dispose();
    super.dispose();
  }

  void _loadSettings() {
    ref.read(restaurantProvider.notifier).loadRestaurant().then((_) {
      final restaurant = ref.read(restaurantProvider).value;
      if (restaurant != null && mounted) {
        setState(() {
          _taxEnabled = restaurant.taxEnabled;
          _taxPercentage = restaurant.taxPercentage;
          _taxController.text = _taxPercentage.toStringAsFixed(1);
        });
      }
    });
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final restaurant = ref.read(restaurantProvider).value;
      if (restaurant == null) return;

      final updatedRestaurant = restaurant.copyWith(
        taxEnabled: _taxEnabled,
        taxPercentage: _taxPercentage,
      );

      await ref.read(restaurantProvider.notifier).updateRestaurant(updatedRestaurant);

      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasChanges = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tax settings updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating settings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tax Setup'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tax Configuration',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: AppTheme.spacingS),
              Text(
                'Configure tax settings for your restaurant. These settings will apply to all new orders.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
              const SizedBox(height: AppTheme.spacingL),

              // Tax Enable/Disable Switch
              Card(
                child: SwitchListTile(
                  secondary: Icon(
                    _taxEnabled ? Icons.check_circle : Icons.cancel,
                    color: _taxEnabled ? AppTheme.successColor : AppTheme.errorColor,
                  ),
                  title: const Text(
                    'Enable Tax',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    _taxEnabled
                        ? 'Tax will be calculated on all orders'
                        : 'No tax will be applied to orders',
                  ),
                  value: _taxEnabled,
                  activeThumbColor: AppTheme.successColor,
                  onChanged: (value) {
                    setState(() {
                      _taxEnabled = value;
                      _hasChanges = true;
                    });
                  },
                ),
              ),

              const SizedBox(height: AppTheme.spacingM),

              // Tax Percentage Field
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.percent,
                            color: _taxEnabled ? AppTheme.primaryColor : Colors.grey,
                          ),
                          const SizedBox(width: AppTheme.spacingS),
                          Text(
                            'Tax Percentage',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: _taxEnabled ? Colors.black : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacingM),
                      TextFormField(
                        controller: _taxController,
                        enabled: _taxEnabled,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Tax Percentage',
                          hintText: 'Enter tax percentage',
                          suffixText: '%',
                          border: const OutlineInputBorder(),
                          enabled: _taxEnabled,
                        ),
                        validator: (value) {
                          if (!_taxEnabled) return null;
                          if (value == null || value.isEmpty) {
                            return 'Please enter tax percentage';
                          }
                          final tax = double.tryParse(value);
                          if (tax == null) {
                            return 'Please enter a valid number';
                          }
                          if (tax < 0 || tax > 100) {
                            return 'Tax must be between 0 and 100';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          final tax = double.tryParse(value);
                          if (tax != null) {
                            setState(() {
                              _taxPercentage = tax;
                              _hasChanges = true;
                            });
                          }
                        },
                      ),
                      if (_taxEnabled) ...[
                        const SizedBox(height: AppTheme.spacingS),
                        Text(
                          'This will be the default tax rate applied to all orders.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppTheme.spacingL),

              // Info Card
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700),
                    const SizedBox(width: AppTheme.spacingM),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Important',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Changes will only apply to new orders. Existing orders will retain their original tax amounts.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppTheme.spacingXL),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _hasChanges && !_isLoading ? _saveSettings : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Save Changes',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
