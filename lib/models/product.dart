import 'category.dart';

class Product {
  final String id;
  final String name;
  final String slug;
  final String brand;
  final String model;
  final Category category;
  final String? genericImage;
  final String description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Prix et stock (calculés depuis les variantes)
  final double? minPrice;
  final double? maxPrice;
  final String priceRange;
  final int totalStock;
  final bool isInStock;

  Product({
    required this.id,
    required this.name,
    required this.slug,
    required this.brand,
    required this.model,
    required this.category,
    this.genericImage,
    required this.description,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.minPrice,
    this.maxPrice,
    required this.priceRange,
    required this.totalStock,
    required this.isInStock,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      brand: json['brand'] as String,
      model: json['model'] as String? ?? '',
      category: Category.fromJson(json['category'] as Map<String, dynamic>),
      genericImage: json['generic_image'] as String?,
      description: json['description'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      minPrice: json['min_price'] != null
          ? double.tryParse(json['min_price'].toString())
          : null,
      maxPrice: json['max_price'] != null
          ? double.tryParse(json['max_price'].toString())
          : null,
      priceRange: json['price_range'] as String? ?? 'Prix non disponible',
      totalStock: json['total_stock'] as int? ?? 0,
      isInStock: json['is_in_stock'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'brand': brand,
      'model': model,
      'category_id': category.slug,
      'generic_image': genericImage,
      'description': description,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'min_price': minPrice,
      'max_price': maxPrice,
      'price_range': priceRange,
      'total_stock': totalStock,
      'is_in_stock': isInStock,
    };
  }

  String? get imageUrl => genericImage;

  Product copyWith({
    String? id,
    String? name,
    String? slug,
    String? brand,
    String? model,
    Category? category,
    String? genericImage,
    String? description,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? minPrice,
    double? maxPrice,
    String? priceRange,
    int? totalStock,
    bool? isInStock,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      category: category ?? this.category,
      genericImage: genericImage ?? this.genericImage,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      priceRange: priceRange ?? this.priceRange,
      totalStock: totalStock ?? this.totalStock,
      isInStock: isInStock ?? this.isInStock,
    );
  }

  @override
  String toString() => 'Product(name: $name, brand: $brand, slug: $slug)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
