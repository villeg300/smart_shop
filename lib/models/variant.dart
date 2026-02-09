import 'attribute_value.dart';

class ProductMini {
  final String id;
  final String name;
  final String slug;
  final String brand;
  final String model;

  ProductMini({
    required this.id,
    required this.name,
    required this.slug,
    required this.brand,
    required this.model,
  });

  factory ProductMini.fromJson(Map<String, dynamic> json) {
    return ProductMini(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      brand: json['brand'] as String,
      model: json['model'] as String? ?? '',
    );
  }
}

class Variant {
  final String id;
  final ProductMini product;
  final String? sku;
  final double price;
  final int stock;
  final List<AttributeValue> attributes;
  final String? image;
  final String? description;
  final bool isActive;
  final DateTime createdAt;

  // Promotions
  final double? promoPrice;
  final int? promoPercentage;

  // Propriétés calculées
  final String attributesDisplay;
  final String fullName;
  final double finalPrice;
  final double? oldPrice;
  final int discountPercentage;
  final String formattedPrice;
  final String? formattedOldPrice;
  final bool hasPromotion;
  final bool isInStock;

  Variant({
    required this.id,
    required this.product,
    this.sku,
    required this.price,
    required this.stock,
    required this.attributes,
    this.image,
    this.description,
    required this.isActive,
    required this.createdAt,
    this.promoPrice,
    this.promoPercentage,
    required this.attributesDisplay,
    required this.fullName,
    required this.finalPrice,
    this.oldPrice,
    required this.discountPercentage,
    required this.formattedPrice,
    this.formattedOldPrice,
    required this.hasPromotion,
    required this.isInStock,
  });

  factory Variant.fromJson(Map<String, dynamic> json) {
    final attributesList =
        (json['attributes'] as List<dynamic>?)
            ?.map(
              (attr) => AttributeValue.fromJson(attr as Map<String, dynamic>),
            )
            .toList() ??
        [];

    return Variant(
      id: json['id'] as String,
      product: ProductMini.fromJson(json['product'] as Map<String, dynamic>),
      sku: json['sku'] as String?,
      price: double.parse(json['price'].toString()),
      stock: json['stock'] as int,
      attributes: attributesList,
      image: json['image'] as String?,
      description:
          json['description'] as String? ?? json['variant_description'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      promoPrice: json['promo_price'] != null
          ? double.tryParse(json['promo_price'].toString())
          : null,
      promoPercentage: json['promo_percentage'] as int?,
      attributesDisplay: json['attributes_display'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      finalPrice: double.parse(json['final_price'].toString()),
      oldPrice: json['old_price'] != null
          ? double.tryParse(json['old_price'].toString())
          : null,
      discountPercentage: json['discount_percentage'] as int? ?? 0,
      formattedPrice: json['formatted_price'] as String? ?? '0',
      formattedOldPrice: json['formatted_old_price'] as String?,
      hasPromotion: json['has_promotion'] as bool? ?? false,
      isInStock: json['is_in_stock'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': product.id,
      'sku': sku,
      'price': price,
      'stock': stock,
      'attribute_ids': attributes.map((attr) => attr.id).toList(),
      'image': image,
      'description': description,
      'is_active': isActive,
      'promo_price': promoPrice,
      'promo_percentage': promoPercentage,
    };
  }

  String? get imageUrl {
    if (image == null || image!.isEmpty) {
      return null;
    }
    return image;
  }

  String get displayName => fullName.isNotEmpty ? fullName : product.name;

  Map<String, String> get attributesMap {
    final map = <String, String>{};
    for (final attr in attributes) {
      map[attr.attributeName] = attr.value;
    }
    return map;
  }

  Variant copyWith({
    String? id,
    ProductMini? product,
    String? sku,
    double? price,
    int? stock,
    List<AttributeValue>? attributes,
    String? image,
    String? description,
    bool? isActive,
    DateTime? createdAt,
    double? promoPrice,
    int? promoPercentage,
    String? attributesDisplay,
    String? fullName,
    double? finalPrice,
    double? oldPrice,
    int? discountPercentage,
    String? formattedPrice,
    String? formattedOldPrice,
    bool? hasPromotion,
    bool? isInStock,
  }) {
    return Variant(
      id: id ?? this.id,
      product: product ?? this.product,
      sku: sku ?? this.sku,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      attributes: attributes ?? this.attributes,
      image: image ?? this.image,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      promoPrice: promoPrice ?? this.promoPrice,
      promoPercentage: promoPercentage ?? this.promoPercentage,
      attributesDisplay: attributesDisplay ?? this.attributesDisplay,
      fullName: fullName ?? this.fullName,
      finalPrice: finalPrice ?? this.finalPrice,
      oldPrice: oldPrice ?? this.oldPrice,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      formattedPrice: formattedPrice ?? this.formattedPrice,
      formattedOldPrice: formattedOldPrice ?? this.formattedOldPrice,
      hasPromotion: hasPromotion ?? this.hasPromotion,
      isInStock: isInStock ?? this.isInStock,
    );
  }

  @override
  String toString() => 'Variant(sku: $sku, product: ${product.name})';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Variant && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
