import '../services/pocketbase_service.dart';

class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final int quantity;
  final String? image;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.quantity,
    this.image,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    String? imageUrl;

    if (json['image'] != null && json['image'] != "") {
      final fileName = json['image'];
      final recordId = json['id'];
      // ✅ ประกอบ URL เต็ม (แก้ให้โหลดภาพได้)
      imageUrl =
          "$pocketbaseUrl/api/files/products/$recordId/$fileName";
    }

    return Product(
      id: json['id'],
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      price: (json['price'] is num) ? json['price'].toDouble() : 0,
      quantity: json['quantity'] ?? 0,
      image: imageUrl,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'category': category,
        'price': price,
        'quantity': quantity,
        'image': image,
      };
}
