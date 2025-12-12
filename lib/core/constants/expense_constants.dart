class ExpenseCategories {
  static const String foodIngredients = 'Food & Ingredients';
  static const String utilities = 'Utilities';
  static const String salaries = 'Staff Salaries';
  static const String rent = 'Rent';
  static const String maintenance = 'Maintenance';
  static const String marketing = 'Marketing';
  static const String supplies = 'Supplies';
  static const String other = 'Other';

  static const List<String> all = [
    foodIngredients,
    utilities,
    salaries,
    rent,
    maintenance,
    marketing,
    supplies,
    other,
  ];

  static String getIcon(String category) {
    switch (category) {
      case foodIngredients:
        return '🍽️';
      case utilities:
        return '⚡';
      case salaries:
        return '💰';
      case rent:
        return '🏠';
      case maintenance:
        return '🔧';
      case marketing:
        return '📢';
      case supplies:
        return '📦';
      case other:
        return '📝';
      default:
        return '📝';
    }
  }
}

class PaymentMethods {
  static const String cash = 'Cash';
  static const String card = 'Card';
  static const String upi = 'UPI';
  static const String bankTransfer = 'Bank Transfer';
  static const String other = 'Other';

  static const List<String> all = [
    cash,
    card,
    upi,
    bankTransfer,
    other,
  ];
}
