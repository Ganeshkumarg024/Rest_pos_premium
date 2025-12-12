class AppConstants {
  // App Info
  static const String appName = 'The Chozha Pos';
  static const String appVersion = '1.0.0';

  // Default Values
  static const double defaultTaxPercentage = 10.0;
  static const String defaultCurrency = '₹';
  static const String defaultRestaurantCode = 'REST001';

  // Order Types
  static const String orderTypeDineIn = 'dine_in';
  static const String orderTypeTakeaway = 'takeaway';
  static const String orderTypeDelivery = 'delivery';

  // Order Status
  static const String orderStatusOpen = 'open';
  static const String orderStatusCompleted = 'completed';
  static const String orderStatusCancelled = 'cancelled';

  // Table Status
  static const String tableStatusAvailable = 'available';
  static const String tableStatusOccupied = 'occupied';
  static const String tableStatusReserved = 'reserved';

  // Payment Methods
  static const String paymentMethodCash = 'cash';
  static const String paymentMethodCard = 'card';
  static const String paymentMethodUPI = 'upi';

  // Settings Keys
  static const String settingsKeyThemeMode = 'theme_mode';
  static const String settingsKeyLanguage = 'language';
  static const String settingsKeyRestaurantId = 'restaurant_id';

  // Date Formats
  static const String dateFormatDisplay = 'dd MMM yyyy';
  static const String dateFormatFull = 'dd MMM yyyy, hh:mm a';
  static const String timeFormat = 'hh:mm a';

  // Validation
  static const int minPasswordLength = 6;
  static const int maxItemNameLength = 100;
  static const int maxDescriptionLength = 500;

  // Pagination
  static const int itemsPerPage = 20;

  // Animation Durations
  static const Duration animationDurationShort = Duration(milliseconds: 200);
  static const Duration animationDurationMedium = Duration(milliseconds: 300);
  static const Duration animationDurationLong = Duration(milliseconds: 500);
}
