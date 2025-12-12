import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static const String _keyNotifNewOrder = 'notif_new_order';
  static const String _keyNotifOrderCompleted = 'notif_order_completed';
  static const String _keyNotifOrderCancelled = 'notif_order_cancelled';
  static const String _keyNotifSound = 'notif_sound';
  static const String _keyNotifPaymentReceived = 'notif_payment_received';
  static const String _keyNotifPaymentFailed = 'notif_payment_failed';
  static const String _keyNotifLowStock = 'notif_low_stock';
  static const String _keyNotifDailySummary = 'notif_daily_summary';
  static const String _keyNotifWeeklyReport = 'notif_weekly_report';

  static const String _keyPrinterAddress = 'printer_address';
  static const String _keyPrinterName = 'printer_name';
  static const String _keyPrinterPaperWidth = 'printer_paper_width';
  static const String _keyPrinterFontSize = 'printer_font_size';
  static const String _keyPrinterPrintOrderDetails = 'printer_print_order_details';
  static const String _keyPrinterPrintKitchenCopy = 'printer_print_kitchen_copy';
  static const String _keyPrinterNumberOfCopies = 'printer_number_of_copies';
  static const String _keyPrinterAutoReconnect = 'printer_auto_reconnect';

  // Notification Settings
  static Future<bool> getNotifNewOrder() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyNotifNewOrder) ?? true;
  }

  static Future<void> setNotifNewOrder(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifNewOrder, value);
  }

  static Future<bool> getNotifOrderCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyNotifOrderCompleted) ?? true;
  }

  static Future<void> setNotifOrderCompleted(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifOrderCompleted, value);
  }

  static Future<bool> getNotifOrderCancelled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyNotifOrderCancelled) ?? true;
  }

  static Future<void> setNotifOrderCancelled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifOrderCancelled, value);
  }

  static Future<bool> getNotifSound() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyNotifSound) ?? true;
  }

  static Future<void> setNotifSound(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifSound, value);
  }

  static Future<bool> getNotifPaymentReceived() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyNotifPaymentReceived) ?? true;
  }

  static Future<void> setNotifPaymentReceived(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifPaymentReceived, value);
  }

  static Future<bool> getNotifPaymentFailed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyNotifPaymentFailed) ?? true;
  }

  static Future<void> setNotifPaymentFailed(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifPaymentFailed, value);
  }

  static Future<bool> getNotifLowStock() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyNotifLowStock) ?? false;
  }

  static Future<void> setNotifLowStock(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifLowStock, value);
  }

  static Future<bool> getNotifDailySummary() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyNotifDailySummary) ?? false;
  }

  static Future<void> setNotifDailySummary(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifDailySummary, value);
  }

  static Future<bool> getNotifWeeklyReport() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyNotifWeeklyReport) ?? false;
  }

  static Future<void> setNotifWeeklyReport(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifWeeklyReport, value);
  }

  // Printer Settings
  static Future<String?> getPrinterAddress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPrinterAddress);
  }

  static Future<void> setPrinterAddress(String? value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value != null) {
      await prefs.setString(_keyPrinterAddress, value);
    } else {
      await prefs.remove(_keyPrinterAddress);
    }
  }

  static Future<String?> getPrinterName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPrinterName);
  }

  static Future<void> setPrinterName(String? value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value != null) {
      await prefs.setString(_keyPrinterName, value);
    } else {
      await prefs.remove(_keyPrinterName);
    }
  }

  static Future<int> getPrinterPaperWidth() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyPrinterPaperWidth) ?? 58; // Default 58mm
  }

  static Future<void> setPrinterPaperWidth(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyPrinterPaperWidth, value);
  }

  static Future<String> getPrinterFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPrinterFontSize) ?? 'Medium';
  }

  static Future<void> setPrinterFontSize(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPrinterFontSize, value);
  }

  static Future<bool> getPrinterPrintOrderDetails() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyPrinterPrintOrderDetails) ?? true;
  }

  static Future<void> setPrinterPrintOrderDetails(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyPrinterPrintOrderDetails, value);
  }

  static Future<bool> getPrinterPrintKitchenCopy() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyPrinterPrintKitchenCopy) ?? false;
  }

  static Future<void> setPrinterPrintKitchenCopy(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyPrinterPrintKitchenCopy, value);
  }

  static Future<int> getPrinterNumberOfCopies() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyPrinterNumberOfCopies) ?? 1;
  }

  static Future<void> setPrinterNumberOfCopies(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyPrinterNumberOfCopies, value);
  }

  static Future<bool> getPrinterAutoReconnect() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyPrinterAutoReconnect) ?? true;
  }

  static Future<void> setPrinterAutoReconnect(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyPrinterAutoReconnect, value);
  }

  // Clear all printer settings
  static Future<void> clearPrinterSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyPrinterAddress);
    await prefs.remove(_keyPrinterName);
  }
}
