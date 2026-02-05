class Product {
  final String name;
  final String category;
  final double price;
  final double? oldPrice;
  final String imageUrl;
  final bool isFavorite;
  final String description;

  const Product({
    required this.name,
    required this.category,
    required this.price,
    this.oldPrice,
    required this.imageUrl,
    required this.isFavorite,
    required this.description,
  });
}

final List<Product> products = [
  const Product(
    name: "Iphone 15 pro",
    category: "Telephone",
    price: 245000,
    oldPrice: 220000,
    imageUrl: "assets/images/laptop.jpg",
    isFavorite: false,
    description: "iphone 15 pro couleur noire ",
  ),
  const Product(
    name: "Iphone 15 pro",
    category: "Telephone",
    price: 245000,
    oldPrice: 200000,
    imageUrl: "assets/images/laptop.jpg",
    isFavorite: true,
    description: "iphone 15 pro couleur noire ",
  ),
  const Product(
    name: "Iphone 15 pro",
    category: "Telephone",
    price: 345000,
    oldPrice: 280000,
    imageUrl: "assets/images/laptop.jpg",
    isFavorite: false,
    description: "iphone 15 pro couleur noire ",
  ),
  const Product(
    name: "Iphone 15 pro",
    category: "Telephone",
    price: 245000,
    oldPrice: 210000,
    imageUrl: "assets/images/laptop.jpg",
    isFavorite: true,
    description: "iphone 15 pro couleur noire ",
  ),
  const Product(
    name: "Iphone 15 pro",
    category: "Telephone",
    price: 245000,
    oldPrice: 220000,
    imageUrl: "assets/images/laptop.jpg",
    isFavorite: false,
    description: "iphone 15 pro couleur noire ",
  ),
  const Product(
    name: "Iphone 15 pro",
    category: "Telephone",
    price: 245000,
    oldPrice: 200000,
    imageUrl: "assets/images/laptop.jpg",
    isFavorite: true,
    description: "iphone 15 pro couleur noire ",
  ),
  const Product(
    name: "Iphone 15 pro",
    category: "Telephone",
    price: 345000,
    oldPrice: 280000,
    imageUrl: "assets/images/laptop.jpg",
    isFavorite: false,
    description: "iphone 15 pro couleur noire ",
  ),
  const Product(
    name: "Iphone 18 pro",
    category: "Telephone",
    price: 245000,
    oldPrice: 210000,
    imageUrl: "assets/images/laptop.jpg",
    isFavorite: true,
    description: "iphone 15 pro couleur noire ",
  ),
];
