import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

class DateFormatter {
  static String formatDisplay(DateTime date) {
    return DateFormat(AppConstants.dateFormatDisplay).format(date);
  }

  static String formatFull(DateTime date) {
    return DateFormat(AppConstants.dateFormatFull).format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat(AppConstants.timeFormat).format(date);
  }

  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return formatDisplay(date);
    }
  }
}
