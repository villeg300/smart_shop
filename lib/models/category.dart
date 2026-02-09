class Category {
  final String name;
  final String slug;
  final bool isActive;
  final DateTime createdAt;
  final int productCount;

  Category({
    required this.name,
    required this.slug,
    required this.isActive,
    required this.createdAt,
    required this.productCount,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      name: json['name'] as String,
      slug: json['slug'] as String,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      productCount: json['product_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'slug': slug,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'product_count': productCount,
    };
  }

  Category copyWith({
    String? name,
    String? slug,
    bool? isActive,
    DateTime? createdAt,
    int? productCount,
  }) {
    return Category(
      name: name ?? this.name,
      slug: slug ?? this.slug,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      productCount: productCount ?? this.productCount,
    );
  }

  @override
  String toString() => 'Category(name: $name, slug: $slug)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category && other.slug == slug;
  }

  @override
  int get hashCode => slug.hashCode;
}
