import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:restaurant_billing/presentation/providers/menu_provider.dart';
import 'package:restaurant_billing/core/theme/app_theme.dart';
import 'package:restaurant_billing/data/models/menu_item_model.dart';
import 'package:restaurant_billing/data/models/category_model.dart';

class AddEditMenuItemScreen extends ConsumerStatefulWidget {
  final MenuItemModel? menuItem;

  const AddEditMenuItemScreen({super.key, this.menuItem});

  @override
  ConsumerState<AddEditMenuItemScreen> createState() => _AddEditMenuItemScreenState();
}

class _AddEditMenuItemScreenState extends ConsumerState<AddEditMenuItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _taxController = TextEditingController();
  
  int? _selectedCategoryId;
  bool _allowDiscount = true;
  bool _isAvailable = true;
  bool _isLoading = false;
  File? _imageFile;
  String? _existingImagePath;

  @override
  void initState() {
    super.initState();
    if (widget.menuItem != null) {
      _nameController.text = widget.menuItem!.name;
      _descriptionController.text = widget.menuItem!.description ?? '';
      _priceController.text = widget.menuItem!.price.toString();
      _taxController.text = widget.menuItem!.taxPercentage.toString();
      _selectedCategoryId = widget.menuItem!.categoryId;
      _allowDiscount = widget.menuItem!.allowDiscount;
      _isAvailable = widget.menuItem!.isAvailable;
      _existingImagePath = widget.menuItem!.imagePath;
    } else {
      _taxController.text = '10.0';
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveMenuItem() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final menuItem = MenuItemModel(
        id: widget.menuItem?.id,
        categoryId: _selectedCategoryId!,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text),
        taxPercentage: double.parse(_taxController.text),
        allowDiscount: _allowDiscount,
        imagePath: _imageFile?.path ?? _existingImagePath,
        isAvailable: _isAvailable,
        createdAt: widget.menuItem?.createdAt ?? DateTime.now(),
      );

      if (widget.menuItem == null) {
        await ref.read(menuItemsProvider.notifier).addMenuItem(menuItem);
      } else {
        await ref.read(menuItemsProvider.notifier).updateMenuItem(menuItem);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.menuItem == null
                ? 'Menu item added successfully'
                : 'Menu item updated successfully'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _taxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.menuItem == null ? 'Add Menu Item' : 'Edit Menu Item'),
      ),
      body: categoriesAsync.when(
        data: (categories) => _buildForm(categories),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildForm(List<CategoryModel> categories) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Image Picker
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
              child: _imageFile != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                      child: Image.file(
                        _imageFile!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : _existingImagePath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                          child: Image.file(
                            File(_existingImagePath!),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildImagePlaceholder();
                            },
                          ),
                        )
                      : _buildImagePlaceholder(),
            ),
          ),
          const SizedBox(height: 24),

          // Item Name
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Item Name *',
              prefixIcon: const Icon(Icons.restaurant_menu),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter item name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Description
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: 'Description',
              prefixIcon: const Icon(Icons.description),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              ),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),

          // Category Dropdown
          DropdownButtonFormField<int>(
            value: _selectedCategoryId,
            decoration: InputDecoration(
              labelText: 'Category *',
              prefixIcon: const Icon(Icons.category),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              ),
            ),
            items: categories.map((category) {
              return DropdownMenuItem(
                value: category.id,
                child: Text(category.name),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategoryId = value;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Please select a category';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Price and Tax
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(
                    labelText: 'Price (₹) *',
                    prefixIcon: const Icon(Icons.currency_rupee),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Invalid';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _taxController,
                  decoration: InputDecoration(
                    labelText: 'Tax (%)',
                    prefixIcon: const Icon(Icons.percent),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    final tax = double.tryParse(value);
                    if (tax == null || tax < 0 || tax > 100) {
                      return 'Invalid';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Switches
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Allow Discount'),
                  subtitle: const Text('Can this item be discounted?'),
                  value: _allowDiscount,
                  activeColor: AppTheme.primaryColor,
                  onChanged: (value) {
                    setState(() {
                      _allowDiscount = value;
                    });
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Available'),
                  subtitle: const Text('Is this item currently available?'),
                  value: _isAvailable,
                  activeColor: AppTheme.successColor,
                  onChanged: (value) {
                    setState(() {
                      _isAvailable = value;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Save Button
          ElevatedButton(
            onPressed: _isLoading ? null : _saveMenuItem,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    widget.menuItem == null ? 'Add Item' : 'Update Item',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate,
          size: 64,
          color: Theme.of(context).hintColor,
        ),
        const SizedBox(height: 8),
        Text(
          'Tap to add image',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).hintColor,
              ),
        ),
      ],
    );
  }
}
