import 'package:smart_shop/models/category.dart';
import 'package:smart_shop/models/product.dart';
import 'package:smart_shop/models/product_variant.dart';
import 'package:smart_shop/models/user.dart';

final List<Category> mockCategories = [
  const Category(name: 'Toutes', slug: 'toutes'),
  const Category(name: 'Telephones', slug: 'telephones'),
  const Category(name: 'Accesoires', slug: 'accessoires'),
  const Category(name: 'Protections', slug: 'protections'),
];

final List<Product> mockProducts = [
  Product(
    name: 'Iphone 15 Pro',
    slug: 'iphone-15-pro',
    description: 'iPhone 15 Pro couleur noire, design premium.',
    brand: 'Apple',
    category: mockCategories[1],
    image: 'assets/images/phone1.jpg',
    isActive: true,
  ),
  Product(
    name: 'Iphone 15',
    slug: 'iphone-15',
    description: 'Ecran lumineux et autonomie longue durée.',
    brand: 'Samsung',
    category: mockCategories[1],
    image: 'assets/images/phone2.jpg',
    isActive: true,
  ),
  Product(
    name: 'Iphone 15 Pro',
    slug: 'iphone-15-pro',
    description: 'Ecran lumineux et autonomie longue durée.',
    brand: 'Samsung',
    category: mockCategories[1],
    image: 'assets/images/phone3.jpg',
    isActive: true,
  ),
  Product(
    name: 'Iphone 17 Pro',
    slug: 'iphone-17-pro',
    description: 'Ecran lumineux et autonomie longue durée.',
    brand: 'Samsung',
    category: mockCategories[1],
    image: 'assets/images/phone5.jpg',
    isActive: true,
  ),
  Product(
    name: 'Chargeur 45W',
    slug: 'chargeur-45w',
    description: 'Charge rapide pour vos appareils.',
    brand: 'SmartShop',
    category: mockCategories[2],
    image: 'assets/images/laptop.jpg',
    isActive: true,
  ),
  Product(
    name: 'Coque Transparente',
    slug: 'coque-transparente',
    description: 'Protection fine et élégante.',
    brand: 'SmartShop',
    category: mockCategories[3],
    image: 'assets/images/laptop.jpg',
    isActive: true,
  ),
];

final List<ProductVariant> mockProductVariants = [
  ProductVariant(
    productSlug: 'iphone-15-pro',
    sku: 'IP15P-128-BLK',
    price: 245000,
    stock: 14,
    attributes: {
      'color': 'Noir',
      'storage': '128GB',
      'compare_at_price': 265000,
    },
    image: 'assets/images/phone4.jpg',
  ),
  ProductVariant(
    productSlug: 'iphone-15-pro',
    sku: 'IP15P-128-BLK',
    price: 245000,
    stock: 14,
    attributes: {
      'color': 'Noir',
      'storage': '128GB',
      'compare_at_price': 265000,
    },
    image: 'assets/images/phone9.jpg',
  ),
  ProductVariant(
    productSlug: 'iphone-15-pro',
    sku: 'IP15P-256-BLU',
    price: 275000,
    stock: 10,
    attributes: {'color': 'Bleu', 'storage': '256GB'},
    image: 'assets/images/phone6.jpg',
  ),
  ProductVariant(
    productSlug: 'iphone-17-pro',
    sku: 'S24U-256-BLK',
    price: 235000,
    stock: 8,
    attributes: {
      'color': 'Noir',
      'storage': '256GB',
      'compare_at_price': 255000,
    },
    image: 'assets/images/phone7.jpg',
  ),
  ProductVariant(
    productSlug: 'iphone-17-pro',
    sku: 'S24U-256-BLK',
    price: 235000,
    stock: 8,
    attributes: {
      'color': 'Noir',
      'storage': '256GB',
      'compare_at_price': 255000,
    },
    image: 'assets/images/phone10.jpg',
  ),
  ProductVariant(
    productSlug: 'iphone-17-pro',
    sku: 'S24U-256-BLK',
    price: 235000,
    stock: 8,
    attributes: {
      'color': 'Noir',
      'storage': '256GB',
      'compare_at_price': 255000,
    },
    image: 'assets/images/phone7.jpg',
  ),
  ProductVariant(
    productSlug: 'iphone-15',
    sku: 'S24U-206-BLK',
    price: 8000,
    stock: 50,
    attributes: {'color': 'Transparent'},
    image: 'assets/images/phone8.jpg',
  ),
];

final List<Product> mockCatalog = mockProducts.map((product) {
  final variants = mockProductVariants
      .where((variant) => variant.productSlug == product.slug)
      .toList();
  return product.copyWith(variants: variants);
}).toList();

final List<User> mockUsers = [
  const User(
    id: 'user-001',
    name: 'Alex Doe',
    email: 'alex@example.com',
    phone: '+22501020304',
  ),
];
