import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/restaurant_model.dart';
import '../../data/repositories/restaurant_repository.dart';

// Repository provider
final restaurantRepositoryProvider = Provider((ref) => RestaurantRepository());

// Restaurant state provider
final restaurantProvider = StateNotifierProvider<RestaurantNotifier, AsyncValue<RestaurantModel?>>((ref) {
  return RestaurantNotifier(ref.read(restaurantRepositoryProvider));
});

class RestaurantNotifier extends StateNotifier<AsyncValue<RestaurantModel?>> {
  final RestaurantRepository _repository;

  RestaurantNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadRestaurant();
  }

  Future<void> loadRestaurant() async {
    state = const AsyncValue.loading();
    try {
      final restaurant = await _repository.getRestaurant();
      state = AsyncValue.data(restaurant);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<RestaurantModel?> getRestaurant() async {
    return await _repository.getRestaurant();
  }

  Future<void> createRestaurant(RestaurantModel restaurant) async {
    try {
      await _repository.createRestaurant(restaurant);
      await loadRestaurant();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateRestaurant(RestaurantModel restaurant) async {
    try {
      await _repository.updateRestaurant(restaurant);
      await loadRestaurant();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Auth state provider (simple local auth)
final authProvider = StateNotifierProvider<AuthNotifier, bool>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<bool> {
  AuthNotifier() : super(false) {
    checkAuth();
  }

  Future<void> checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('is_logged_in') ?? false;
  }

  Future<bool> login(String code, String email, String password) async {
    // Hardcoded credentials validation
    const validCode = 'ADMIN';
    const validEmail = 'ADMIN';
    const validPassword = 'ADMIN';
    
    if (code == validCode && email == validEmail && password == validPassword) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', true);
      await prefs.setString('restaurant_code', code);
      state = true;
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', false);
    state = false;
  }
}
