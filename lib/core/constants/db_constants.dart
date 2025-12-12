class DbConstants {
  // Database Info
  static const String databaseName = 'restaurant_billing.db';
  static const int databaseVersion = 2;

  // Table Names
  static const String tableRestaurants = 'restaurants';
  static const String tableTables = 'tables';
  static const String tableCategories = 'categories';
  static const String tableMenuItems = 'menu_items';
  static const String tableOrders = 'orders';
  static const String tableOrderItems = 'order_items';
  static const String tablePayments = 'payments';
  static const String tableSettings = 'settings';

  // Common Columns
  static const String columnId = 'id';
  static const String columnCreatedAt = 'created_at';
  static const String columnUpdatedAt = 'updated_at';

  // Restaurant Columns
  static const String columnRestaurantName = 'name';
  static const String columnRestaurantCode = 'code';
  static const String columnRestaurantEmail = 'email';
  static const String columnRestaurantPhone = 'phone';
  static const String columnRestaurantAddress = 'address';
  static const String columnRestaurantLogoPath = 'logo_path';
  static const String columnRestaurantTaxPercentage = 'tax_percentage';
  static const String columnRestaurantTaxEnabled = 'tax_enabled';

  // Table Columns
  static const String columnTableNumber = 'table_number';
  static const String columnTableName = 'table_name';
  static const String columnTableSeats = 'seats';
  static const String columnTableStatus = 'status';

  // Category Columns
  static const String columnCategoryName = 'name';
  static const String columnCategoryDisplayOrder = 'display_order';

  // Menu Item Columns
  static const String columnMenuItemCategoryId = 'category_id';
  static const String columnMenuItemName = 'name';
  static const String columnMenuItemDescription = 'description';
  static const String columnMenuItemPrice = 'price';
  static const String columnMenuItemTaxPercentage = 'tax_percentage';
  static const String columnMenuItemAllowDiscount = 'allow_discount';
  static const String columnMenuItemImagePath = 'image_path';
  static const String columnMenuItemIsAvailable = 'is_available';

  // Order Columns
  static const String columnOrderNumber = 'order_number';
  static const String columnOrderTableId = 'table_id';
  static const String columnOrderType = 'order_type';
  static const String columnOrderStatus = 'status';
  static const String columnOrderSubtotal = 'subtotal';
  static const String columnOrderDiscountAmount = 'discount_amount';
  static const String columnOrderTaxAmount = 'tax_amount';
  static const String columnOrderTotalAmount = 'total_amount';
  static const String columnOrderCompletedAt = 'completed_at';

  // Order Item Columns
  static const String columnOrderItemOrderId = 'order_id';
  static const String columnOrderItemMenuItemId = 'menu_item_id';
  static const String columnOrderItemQuantity = 'quantity';
  static const String columnOrderItemUnitPrice = 'unit_price';
  static const String columnOrderItemTotalPrice = 'total_price';

  // Payment Columns
  static const String columnPaymentOrderId = 'order_id';
  static const String columnPaymentMethod = 'payment_method';
  static const String columnPaymentAmount = 'amount';

  // Settings Columns
  static const String columnSettingsKey = 'key';
  static const String columnSettingsValue = 'value';
}
