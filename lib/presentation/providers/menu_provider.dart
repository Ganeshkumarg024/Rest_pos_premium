import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/menu_item_model.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/menu_repository.dart';

// Repository provider
final menuRepositoryProvider = Provider((ref) => MenuRepository());

// Categories provider
final categoriesProvider = StateNotifierProvider<CategoriesNotifier, AsyncValue<List<CategoryModel>>>((ref) {
  return CategoriesNotifier(ref.read(menuRepositoryProvider));
});

class CategoriesNotifier extends StateNotifier<AsyncValue<List<CategoryModel>>> {
  final MenuRepository _repository;

  CategoriesNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadCategories();
  }

  Future<void> loadCategories() async {
    state = const AsyncValue.loading();
    try {
      final categories = await _repository.getAllCategories();
      state = AsyncValue.data(categories);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addCategory(CategoryModel category) async {
    try {
      await _repository.createCategory(category);
      await loadCategories();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> updateCategory(CategoryModel category) async {
    try {
      await _repository.updateCategory(category);
      await loadCategories();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      await _repository.deleteCategory(id);
      await loadCategories();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
}

// Menu items provider
final menuItemsProvider = StateNotifierProvider<MenuItemsNotifier, AsyncValue<List<MenuItemModel>>>((ref) {
  return MenuItemsNotifier(ref.read(menuRepositoryProvider));
});

class MenuItemsNotifier extends StateNotifier<AsyncValue<List<MenuItemModel>>> {
  final MenuRepository _repository;

  MenuItemsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadMenuItems();
  }

  Future<void> loadMenuItems() async {
    state = const AsyncValue.loading();
    try {
      final items = await _repository.getAllMenuItems();
      state = AsyncValue.data(items);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addMenuItem(MenuItemModel item) async {
    try {
      await _repository.createMenuItem(item);
      await loadMenuItems();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> createMenuItem(MenuItemModel item) async {
    try {
      await _repository.createMenuItem(item);
      await loadMenuItems();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateMenuItem(MenuItemModel item) async {
    try {
      await _repository.updateMenuItem(item);
      await loadMenuItems();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteMenuItem(int id) async {
    try {
      await _repository.deleteMenuItem(id);
      await loadMenuItems();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> toggleAvailability(int id, bool isAvailable) async {
    try {
      await _repository.toggleMenuItemAvailability(id, isAvailable);
      await loadMenuItems();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Selected category provider
final selectedCategoryProvider = StateProvider<int?>((ref) => null);
