import 'package:restaurant_billing/data/database/database_helper.dart';
import 'package:restaurant_billing/data/models/menu_item_model.dart';
import 'package:restaurant_billing/data/models/category_model.dart';
import 'package:restaurant_billing/core/constants/db_constants.dart';

class MenuRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Category operations
  Future<List<CategoryModel>> getAllCategories() async {
    final results = await _dbHelper.query(
      DbConstants.tableCategories,
      orderBy: '${DbConstants.columnCategoryDisplayOrder} ASC',
    );

    return results.map((map) => CategoryModel.fromMap(map)).toList();
  }

  Future<int> createCategory(CategoryModel category) async {
    return await _dbHelper.insert(
      DbConstants.tableCategories,
      category.toMap(),
    );
  }

  Future<int> updateCategory(CategoryModel category) async {
    return await _dbHelper.update(
      DbConstants.tableCategories,
      category.toMap(),
      where: '${DbConstants.columnId} = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> deleteCategory(int id) async {
    return await _dbHelper.delete(
      DbConstants.tableCategories,
      where: '${DbConstants.columnId} = ?',
      whereArgs: [id],
    );
  }

  // Menu item operations
  Future<List<MenuItemModel>> getAllMenuItems() async {
    final results = await _dbHelper.rawQuery('''
      SELECT m.*, c.${DbConstants.columnCategoryName} as category_name
      FROM ${DbConstants.tableMenuItems} m
      LEFT JOIN ${DbConstants.tableCategories} c
      ON m.${DbConstants.columnMenuItemCategoryId} = c.${DbConstants.columnId}
      ORDER BY m.${DbConstants.columnCreatedAt} DESC
    ''');

    return results.map((map) => MenuItemModel.fromMap(map)).toList();
  }

  Future<List<MenuItemModel>> getMenuItemsByCategory(int categoryId) async {
    final results = await _dbHelper.rawQuery('''
      SELECT m.*, c.${DbConstants.columnCategoryName} as category_name
      FROM ${DbConstants.tableMenuItems} m
      LEFT JOIN ${DbConstants.tableCategories} c
      ON m.${DbConstants.columnMenuItemCategoryId} = c.${DbConstants.columnId}
      WHERE m.${DbConstants.columnMenuItemCategoryId} = ?
      ORDER BY m.${DbConstants.columnMenuItemName} ASC
    ''', [categoryId]);

    return results.map((map) => MenuItemModel.fromMap(map)).toList();
  }

  Future<List<MenuItemModel>> getAvailableMenuItems() async {
    final results = await _dbHelper.rawQuery('''
      SELECT m.*, c.${DbConstants.columnCategoryName} as category_name
      FROM ${DbConstants.tableMenuItems} m
      LEFT JOIN ${DbConstants.tableCategories} c
      ON m.${DbConstants.columnMenuItemCategoryId} = c.${DbConstants.columnId}
      WHERE m.${DbConstants.columnMenuItemIsAvailable} = 1
      ORDER BY c.${DbConstants.columnCategoryDisplayOrder}, m.${DbConstants.columnMenuItemName}
    ''');

    return results.map((map) => MenuItemModel.fromMap(map)).toList();
  }

  Future<MenuItemModel?> getMenuItemById(int id) async {
    final results = await _dbHelper.rawQuery('''
      SELECT m.*, c.${DbConstants.columnCategoryName} as category_name
      FROM ${DbConstants.tableMenuItems} m
      LEFT JOIN ${DbConstants.tableCategories} c
      ON m.${DbConstants.columnMenuItemCategoryId} = c.${DbConstants.columnId}
      WHERE m.${DbConstants.columnId} = ?
    ''', [id]);

    if (results.isEmpty) return null;
    return MenuItemModel.fromMap(results.first);
  }

  Future<int> createMenuItem(MenuItemModel menuItem) async {
    return await _dbHelper.insert(
      DbConstants.tableMenuItems,
      menuItem.toMap(),
    );
  }

  Future<int> updateMenuItem(MenuItemModel menuItem) async {
    return await _dbHelper.update(
      DbConstants.tableMenuItems,
      menuItem.toMap(),
      where: '${DbConstants.columnId} = ?',
      whereArgs: [menuItem.id],
    );
  }

  Future<int> deleteMenuItem(int id) async {
    return await _dbHelper.delete(
      DbConstants.tableMenuItems,
      where: '${DbConstants.columnId} = ?',
      whereArgs: [id],
    );
  }

  Future<int> toggleMenuItemAvailability(int id, bool isAvailable) async {
    return await _dbHelper.update(
      DbConstants.tableMenuItems,
      {DbConstants.columnMenuItemIsAvailable: isAvailable ? 1 : 0},
      where: '${DbConstants.columnId} = ?',
      whereArgs: [id],
    );
  }
}
