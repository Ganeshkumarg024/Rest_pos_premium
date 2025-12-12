import 'package:restaurant_billing/data/database/database_helper.dart';
import 'package:restaurant_billing/data/models/restaurant_model.dart';
import 'package:restaurant_billing/core/constants/db_constants.dart';

class RestaurantRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> createRestaurant(RestaurantModel restaurant) async {
    return await _dbHelper.insert(
      DbConstants.tableRestaurants,
      restaurant.toMap(),
    );
  }

  Future<RestaurantModel?> getRestaurant() async {
    final results = await _dbHelper.query(
      DbConstants.tableRestaurants,
      limit: 1,
    );

    if (results.isEmpty) return null;
    return RestaurantModel.fromMap(results.first);
  }

  Future<RestaurantModel?> getRestaurantByCode(String code) async {
    final results = await _dbHelper.query(
      DbConstants.tableRestaurants,
      where: '${DbConstants.columnRestaurantCode} = ?',
      whereArgs: [code],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return RestaurantModel.fromMap(results.first);
  }

  Future<int> updateRestaurant(RestaurantModel restaurant) async {
    // If no ID provided, get the first (and only) restaurant
    if (restaurant.id == null) {
      final existing = await getRestaurant();
      if (existing != null) {
        return await _dbHelper.update(
          DbConstants.tableRestaurants,
          restaurant.toMap(),
          where: '${DbConstants.columnId} = ?',
          whereArgs: [existing.id],
        );
      } else {
        // No existing restaurant, create new one
        return await createRestaurant(restaurant);
      }
    }
    
    return await _dbHelper.update(
      DbConstants.tableRestaurants,
      restaurant.toMap(),
      where: '${DbConstants.columnId} = ?',
      whereArgs: [restaurant.id],
    );
  }

  Future<int> deleteRestaurant(int id) async {
    return await _dbHelper.delete(
      DbConstants.tableRestaurants,
      where: '${DbConstants.columnId} = ?',
      whereArgs: [id],
    );
  }
}
