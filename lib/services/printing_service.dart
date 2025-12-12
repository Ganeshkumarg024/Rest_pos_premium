import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:restaurant_billing/data/models/order_model.dart';
import 'package:restaurant_billing/data/models/restaurant_model.dart';
import 'package:intl/intl.dart';

class PrintingService {
  final FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;

  /// Request Bluetooth permissions
  Future<bool> requestPermissions() async {
    if (await Permission.bluetoothScan.request().isGranted &&
        await Permission.bluetoothConnect.request().isGranted) {
      return true;
    }
    return false;
  }

  /// Check if Bluetooth is available and enabled
  Future<bool> isBluetoothAvailable() async {
    try {
      return await _bluetooth.isAvailable ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Check if Bluetooth is enabled
  Future<bool> isBluetoothEnabled() async {
    try {
      return await _bluetooth.isEnabled ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Get list of bonded Bluetooth devices
  Future<List<BluetoothDevice>> getBondedDevices() async {
    try {
      return await _bluetooth.getBondedDevices();
    } catch (e) {
      return [];
    }
  }

  /// Generate ESC/POS commands for thermal printer (58mm)
  List<int> _generatePrintData(OrderModel order, RestaurantModel? restaurant) {
    final List<int> bytes = [];

    // ESC/POS Commands
    const esc = 0x1B;
    const gs = 0x1D;
    
    // Initialize printer
    bytes.addAll([esc, 0x40]); // Initialize
    
    // Set alignment to center
    bytes.addAll([esc, 0x61, 0x01]); // Center align
    
    // Print restaurant header (large text)
    bytes.addAll([esc, 0x21, 0x30]); // Double height + double width
    bytes.addAll(utf8.encode(restaurant?.name ?? 'Restaurant'));
    bytes.addAll([0x0A]); // Line feed
    
    // Normal text
    bytes.addAll([esc, 0x21, 0x00]); // Normal text
    
    if (restaurant?.address != null) {
      bytes.addAll(utf8.encode(restaurant!.address!));
      bytes.addAll([0x0A]);
    }
    
    if (restaurant?.phone != null) {
      bytes.addAll(utf8.encode('Tel: ${restaurant!.phone}'));
      bytes.addAll([0x0A]);
    }
    
    bytes.addAll([0x0A]); // Blank line
    bytes.addAll(utf8.encode('================================'));
    bytes.addAll([0x0A, 0x0A]);
    
    // Order details (large text)
    bytes.addAll([esc, 0x21, 0x30]); // Double height + double width
    bytes.addAll(utf8.encode('Order #${order.orderNumber}'));
    bytes.addAll([0x0A]);
    
    // Normal text
    bytes.addAll([esc, 0x21, 0x00]);
    bytes.addAll(utf8.encode(DateFormat('dd/MM/yyyy hh:mm a').format(order.createdAt)));
    bytes.addAll([0x0A]);
    
    if (order.tableName != null) {
      bytes.addAll(utf8.encode('Table: ${order.tableName}'));
      bytes.addAll([0x0A]);
    }
    
    bytes.addAll(utf8.encode('Type: ${order.orderType.toUpperCase()}'));
    bytes.addAll([0x0A, 0x0A]);
    bytes.addAll(utf8.encode('--------------------------------'));
    bytes.addAll([0x0A, 0x0A]);
    
    // Set alignment to left
    bytes.addAll([esc, 0x61, 0x00]); // Left align
    
    // Items header
    bytes.addAll(utf8.encode('Item                     Amount'));
    bytes.addAll([0x0A]);
    bytes.addAll(utf8.encode('--------------------------------'));
    bytes.addAll([0x0A]);
    
    // Print order items
    if (order.items != null) {
      for (var item in order.items!) {
        final itemName = item.menuItemName ?? 'Unknown Item';
        final qty = item.quantity;
        final price = item.unitPrice;
        final total = item.totalPrice;
        
        // Print item name
        bytes.addAll(utf8.encode(itemName));
        bytes.addAll([0x0A]);
        
        // Print quantity and price (right aligned amount)
        final qtyPrice = '  $qty x ₹${price.toStringAsFixed(2)}';
        final totalStr = '₹${total.toStringAsFixed(2)}';
        final spaces = 32 - qtyPrice.length - totalStr.length;
        bytes.addAll(utf8.encode(qtyPrice + ' ' * spaces + totalStr));
        bytes.addAll([0x0A]);
      }
    }
    
    bytes.addAll([0x0A]);
    bytes.addAll(utf8.encode('--------------------------------'));
    bytes.addAll([0x0A]);
    
    // Totals
    bytes.addAll(utf8.encode(_formatLine('Subtotal', order.subtotal)));
    bytes.addAll([0x0A]);
    bytes.addAll(utf8.encode(_formatLine('Tax (GST)', order.taxAmount)));
    bytes.addAll([0x0A]);
    
    if (order.discountAmount > 0) {
      bytes.addAll(utf8.encode(_formatLine('Discount', -order.discountAmount)));
      bytes.addAll([0x0A]);
    }
    
    bytes.addAll(utf8.encode('================================'));
    bytes.addAll([0x0A]);
    
    // Total (large text)
    bytes.addAll([esc, 0x21, 0x30]); // Double height + double width
    bytes.addAll(utf8.encode(_formatLine('TOTAL', order.totalAmount)));
    bytes.addAll([0x0A]);
    
    // Normal text
    bytes.addAll([esc, 0x21, 0x00]);
    bytes.addAll(utf8.encode('================================'));
    bytes.addAll([0x0A, 0x0A]);
    
    // Center align for footer
    bytes.addAll([esc, 0x61, 0x01]);
    bytes.addAll([esc, 0x21, 0x10]); // Bold
    bytes.addAll(utf8.encode('Thank you for your visit!'));
    bytes.addAll([0x0A]);
    bytes.addAll([esc, 0x21, 0x00]); // Normal
    bytes.addAll(utf8.encode('Please visit again'));
    bytes.addAll([0x0A, 0x0A, 0x0A]);
    
    // Cut paper
    bytes.addAll([gs, 0x56, 0x00]); // Full cut
    
    return bytes;
  }
  
  String _formatLine(String label, double amount) {
    final amountStr = '₹${amount.toStringAsFixed(2)}';
    final spaces = 32 - label.length - amountStr.length;
    return label + ' ' * spaces + amountStr;
  }

  /// Print invoice to a Bluetooth device
  Future<bool> printInvoice(
    BluetoothDevice device,
    OrderModel order,
    RestaurantModel? restaurant,
  ) async {
    BluetoothConnection? connection;
    
    try {
      // Connect to device
      connection = await BluetoothConnection.toAddress(device.address);
      
      if (!connection.isConnected) {
        return false;
      }
      
      // Generate print data
      final printData = _generatePrintData(order, restaurant);
      
      // Send data to printer
      connection.output.add(Uint8List.fromList(printData));
      await connection.output.allSent;
      
      // Wait a bit for printing to complete
      await Future.delayed(const Duration(seconds: 1));
      
      return true;
    } catch (e) {
      return false;
    } finally {
      await connection?.close();
    }
  }
}
