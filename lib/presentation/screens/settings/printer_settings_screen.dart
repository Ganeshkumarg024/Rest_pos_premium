import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:restaurant_billing/core/theme/app_theme.dart';
import 'package:restaurant_billing/core/utils/app_preferences.dart';

class PrinterSettingsScreen extends StatefulWidget {
  const PrinterSettingsScreen({super.key});

  @override
  State<PrinterSettingsScreen> createState() => _PrinterSettingsScreenState();
}

class _PrinterSettingsScreenState extends State<PrinterSettingsScreen> {
  List<BluetoothDevice> _devices = [];
  bool _isScanning = false;
  String? _connectedAddress;
  String? _connectedName;
  int _paperWidth = 58;
  String _fontSize = 'Medium';
  bool _printOrderDetails = true;
  bool _printKitchenCopy = false;
  int _numberOfCopies = 1;
  bool _autoReconnect = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await Future.wait([
      AppPreferences.getPrinterAddress(),
      AppPreferences.getPrinterName(),
      AppPreferences.getPrinterPaperWidth(),
      AppPreferences.getPrinterFontSize(),
      AppPreferences.getPrinterPrintOrderDetails(),
      AppPreferences.getPrinterPrintKitchenCopy(),
      AppPreferences.getPrinterNumberOfCopies(),
      AppPreferences.getPrinterAutoReconnect(),
    ]);

    if (mounted) {
      setState(() {
        _connectedAddress = settings[0] as String?;
        _connectedName = settings[1] as String?;
        _paperWidth = settings[2] as int;
        _fontSize = settings[3] as String;
        _printOrderDetails = settings[4] as bool;
        _printKitchenCopy = settings[5] as bool;
        _numberOfCopies = settings[6] as int;
        _autoReconnect = settings[7] as bool;
      });
    }
  }

  Future<void> _saveSettings() async {
    await Future.wait([
      AppPreferences.setPrinterPaperWidth(_paperWidth),
      AppPreferences.setPrinterFontSize(_fontSize),
      AppPreferences.setPrinterPrintOrderDetails(_printOrderDetails),
      AppPreferences.setPrinterPrintKitchenCopy(_printKitchenCopy),
      AppPreferences.setPrinterNumberOfCopies(_numberOfCopies),
      AppPreferences.setPrinterAutoReconnect(_autoReconnect),
    ]);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Printer settings saved'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _scanForDevices() async {
    // Request Bluetooth permissions
    final status = await Permission.bluetoothScan.request();
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bluetooth permission required'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() => _isScanning = true);

    try {
      final devices = await FlutterBluetoothSerial.instance.getBondedDevices();
      setState(() {
        _devices = devices;
        _isScanning = false;
      });
    } catch (e) {
      setState(() => _isScanning = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error scanning: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _connectToPrinter(BluetoothDevice device) async {
    setState(() {
      _connectedAddress = device.address;
      _connectedName = device.name;
    });

    await AppPreferences.setPrinterAddress(device.address);
    await AppPreferences.setPrinterName(device.name);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connected to ${device.name}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _disconnectPrinter() async {
    setState(() {
      _connectedAddress = null;
      _connectedName = null;
    });

    await AppPreferences.clearPrinterSettings();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Printer disconnected'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Printer Configuration'),
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
          // Connection Status
          Card(
            color: _connectedAddress != null ? Colors.green.shade50 : Colors.grey.shade100,
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              child: Row(
                children: [
                  Icon(
                    _connectedAddress != null ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                    color: _connectedAddress != null ? Colors.green : Colors.grey,
                    size: 32,
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _connectedAddress != null ? 'Connected' : 'Not Connected',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_connectedName != null)
                          Text(
                            _connectedName!,
                            style: const TextStyle(color: AppTheme.textSecondary),
                          ),
                      ],
                    ),
                  ),
                  if (_connectedAddress != null)
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: _disconnectPrinter,
                      tooltip: 'Disconnect',
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppTheme.spacingL),

          // Scan for Printers
          ElevatedButton.icon(
            onPressed: _isScanning ? null : _scanForDevices,
            icon: _isScanning
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.search),
            label: Text(_isScanning ? 'Scanning...' : 'Scan for Printers'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),

          if (_devices.isNotEmpty) ...[
            const SizedBox(height: AppTheme.spacingL),
            Text(
              'Available Printers',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppTheme.spacingS),
            ..._devices.map((device) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.print, color: AppTheme.primaryColor),
                    title: Text(device.name ?? 'Unknown'),
                    subtitle: Text(device.address),
                    trailing: ElevatedButton(
                      onPressed: () => _connectToPrinter(device),
                      child: const Text('Connect'),
                    ),
                  ),
                )),
          ],

          const SizedBox(height: AppTheme.spacingL),

          // Printer Settings
          Text(
            'Printer Settings',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppTheme.spacingS),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.settings_ethernet),
                  title: const Text('Paper Width'),
                  trailing: DropdownButton<int>(
                    value: _paperWidth,
                    items: const [
                      DropdownMenuItem(value: 58, child: Text('58mm')),
                      DropdownMenuItem(value: 80, child: Text('80mm')),
                    ],
                    onChanged: (value) => setState(() => _paperWidth = value!),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.text_fields),
                  title: const Text('Font Size'),
                  trailing: DropdownButton<String>(
                    value: _fontSize,
                    items: const [
                      DropdownMenuItem(value: 'Small', child: Text('Small')),
                      DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                      DropdownMenuItem(value: 'Large', child: Text('Large')),
                    ],
                    onChanged: (value) => setState(() => _fontSize = value!),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.content_copy),
                  title: const Text('Number of Copies'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: _numberOfCopies > 1
                            ? () => setState(() => _numberOfCopies--)
                            : null,
                      ),
                      Text('$_numberOfCopies'),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => setState(() => _numberOfCopies++),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.spacingM),

          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.description),
                  title: const Text('Print Order Details'),
                  subtitle: const Text('Include all order items'),
                  value: _printOrderDetails,
                  onChanged: (value) => setState(() => _printOrderDetails = value),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.restaurant_menu),
                  title: const Text('Print Kitchen Copy'),
                  subtitle: const Text('Print extra copy for kitchen'),
                  value: _printKitchenCopy,
                  onChanged: (value) => setState(() => _printKitchenCopy = value),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.autorenew),
                  title: const Text('Auto Reconnect'),
                  subtitle: const Text('Reconnect automatically if disconnected'),
                  value: _autoReconnect,
                  onChanged: (value) => setState(() => _autoReconnect = value),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
