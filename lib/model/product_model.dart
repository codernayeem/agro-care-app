import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final double originalPrice;
  final double currentPrice;
  final String imageUrl;
  final String category;
  final int rating;
  final int soldCount;
  final DateTime createdAt;
  final String tags;

  Product({
    required this.id,
    required this.name,
    required this.originalPrice,
    required this.currentPrice,
    required this.imageUrl,
    required this.category,
    required this.rating,
    required this.soldCount,
    required this.createdAt,
    required this.tags,
  });

  // Convert Firebase data to Product object
  factory Product.fromFirestore(Map<String, dynamic> data, String documentID) {
    return Product(
      id: documentID,
      name: data['name'] ?? '',
      originalPrice: (data['original_price'] as num).toDouble(),
      currentPrice: (data['current_price'] as num).toDouble(),
      imageUrl: data['image_url'] ?? '',
      category: data['category'] ?? '',
      rating: data['rating'] ?? 0,
      soldCount: data['sold_count'] ?? 0,
      createdAt: (data['created_at'] as Timestamp).toDate(),
      tags: data['tags'] ?? '',
    );
  }
}
