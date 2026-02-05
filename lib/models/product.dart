import 'package:smart_shop/models/category.dart';
import 'package:smart_shop/models/product_variant.dart';

class Product {
  final String name;
  final String slug;
  final String description;
  final String brand;
  final Category category;
  final String image;
  final bool isActive;
  final List<ProductVariant> variants;

  const Product({
    required this.name,
    required this.slug,
    required this.description,
    required this.brand,
    required this.category,
    required this.image,
    required this.isActive,
    this.variants = const [],
  });

  Product copyWith({
    String? name,
    String? slug,
    String? description,
    String? brand,
    Category? category,
    String? image,
    bool? isActive,
    List<ProductVariant>? variants,
  }) {
    return Product(
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      brand: brand ?? this.brand,
      category: category ?? this.category,
      image: image ?? this.image,
      isActive: isActive ?? this.isActive,
      variants: variants ?? this.variants,
    );
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      category: Category.fromJson(json['category'] as Map<String, dynamic>),
      image: json['image'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'slug': slug,
      'description': description,
      'brand': brand,
      'category': category.toJson(),
      'image': image,
      'is_active': isActive,
    };
  }
}
