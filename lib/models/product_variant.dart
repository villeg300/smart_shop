class ProductVariant {
  final String productSlug;
  final String sku;
  final double price;
  final int stock;
  final Map<String, dynamic> attributes;
  final String image;

  const ProductVariant({
    required this.productSlug,
    required this.sku,
    required this.price,
    required this.stock,
    required this.attributes,
    required this.image,
  });

  double? get compareAtPrice {
    final value = attributes['compare_at_price'];
    if (value is num) {
      return value.toDouble();
    }
    return null;
  }

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      productSlug: json['product'] as String,
      sku: json['sku'] as String,
      price: (json['price'] as num).toDouble(),
      stock: json['stock'] as int? ?? 0,
      attributes: (json['attributes'] as Map?)?.cast<String, dynamic>() ?? {},
      image: json['image'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': productSlug,
      'sku': sku,
      'price': price,
      'stock': stock,
      'attributes': attributes,
      'image': image,
    };
  }
}
