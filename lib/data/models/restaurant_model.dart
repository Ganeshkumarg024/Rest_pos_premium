import 'package:restaurant_billing/core/constants/db_constants.dart';

class RestaurantModel {
  final int? id;
  final String name;
  final String code;
  final String? email;
  final String? phone;
  final String? address;
  final String? logoPath;
  final double taxPercentage;
  final bool taxEnabled;
  final DateTime createdAt;

  RestaurantModel({
    this.id,
    required this.name,
    required this.code,
    this.email,
    this.phone,
    this.address,
    this.logoPath,
    this.taxPercentage = 10.0,
    this.taxEnabled = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      if (id != null) DbConstants.columnId: id,
      DbConstants.columnRestaurantName: name,
      DbConstants.columnRestaurantCode: code,
      DbConstants.columnRestaurantEmail: email,
      DbConstants.columnRestaurantPhone: phone,
      DbConstants.columnRestaurantAddress: address,
      DbConstants.columnRestaurantLogoPath: logoPath,
      DbConstants.columnRestaurantTaxPercentage: taxPercentage,
      DbConstants.columnRestaurantTaxEnabled: taxEnabled ? 1 : 0,
      DbConstants.columnCreatedAt: createdAt.toIso8601String(),
    };
  }

  factory RestaurantModel.fromMap(Map<String, dynamic> map) {
    return RestaurantModel(
      id: map[DbConstants.columnId] as int?,
      name: map[DbConstants.columnRestaurantName] as String,
      code: map[DbConstants.columnRestaurantCode] as String,
      email: map[DbConstants.columnRestaurantEmail] as String?,
      phone: map[DbConstants.columnRestaurantPhone] as String?,
      address: map[DbConstants.columnRestaurantAddress] as String?,
      logoPath: map[DbConstants.columnRestaurantLogoPath] as String?,
      taxPercentage: (map[DbConstants.columnRestaurantTaxPercentage] as num?)?.toDouble() ?? 10.0,
      taxEnabled: (map[DbConstants.columnRestaurantTaxEnabled] as int?) == 1,
      createdAt: DateTime.parse(map[DbConstants.columnCreatedAt] as String),
    );
  }

  RestaurantModel copyWith({
    int? id,
    String? name,
    String? code,
    String? email,
    String? phone,
    String? address,
    String? logoPath,
    double? taxPercentage,
    bool? taxEnabled,
    DateTime? createdAt,
  }) {
    return RestaurantModel(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      logoPath: logoPath ?? this.logoPath,
      taxPercentage: taxPercentage ?? this.taxPercentage,
      taxEnabled: taxEnabled ?? this.taxEnabled,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
