import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

class CurrencyFormatter {
  static String format(double amount) {
    final formatter = NumberFormat.currency(
      symbol: AppConstants.defaultCurrency,
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  static String formatWithoutSymbol(double amount) {
    final formatter = NumberFormat.currency(
      symbol: '',
      decimalDigits: 2,
    );
    return formatter.format(amount).trim();
  }

  /// Format currency for PDF (replaces ₹ with Rs.)
  static String formatForPdf(double amount) {
    final formatted = format(amount);
    // Replace Rupee symbol with Rs. for PDF compatibility
    return formatted.replaceAll('₹', 'Rs. ');
  }
}
