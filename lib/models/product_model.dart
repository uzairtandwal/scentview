import 'package:scentview/services/api_service.dart';

class Product {
  final dynamic id;
  final String name;
  final String description;
  final double originalPrice;
  final double? salePrice;
  final String imageUrl;
  final bool isFeatured;
  final bool isSlider;
  final String? badgeText; // TAG (Sale, New, etc.)
  final dynamic categoryId;
  final dynamic category;
  final Map<String, dynamic>? fragranceNotes; // ✅ Added this

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.originalPrice,
    this.salePrice,
    required this.imageUrl,
    this.isFeatured = false,
    this.isSlider = false,
    this.badgeText,
    required this.categoryId,
    this.category,
    this.fragranceNotes,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      originalPrice: double.tryParse(json['price'].toString()) ?? 0.0,
      salePrice: json['sale_price'] != null ? double.tryParse(json['sale_price'].toString()) : null,
      imageUrl: ApiService.toAbsoluteUrl(json['main_image_url']?.toString()) ?? '',
      isFeatured: json['is_featured'] == 1 || json['is_featured'] == true,
      isSlider: json['is_slider'] == 1 || json['is_slider'] == true,
      // IMPORTANT: Mapping Badge Text correctly
      badgeText: json['badge_text'], 
      categoryId: json['category_id'],
      category: json['category'],
      // ✅ Handle fragrance notes safely
      fragranceNotes: json['fragrance_notes'] is Map<String, dynamic> 
          ? json['fragrance_notes'] 
          : null,
    );
  }

  // ✅ Added toJson (Required for API/Storage)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': originalPrice,
      'sale_price': salePrice,
      'main_image_url': imageUrl,
      'is_featured': isFeatured,
      'is_slider': isSlider,
      'badge_text': badgeText,
      'category_id': categoryId,
      'category': category,
      'fragrance_notes': fragranceNotes,
    };
  }

  // ✅ Added copyWith (Required for UI Updates)
  Product copyWith({
    dynamic id,
    String? name,
    String? description,
    double? originalPrice,
    double? salePrice,
    String? imageUrl,
    bool? isFeatured,
    bool? isSlider,
    String? badgeText,
    dynamic categoryId,
    dynamic category,
    Map<String, dynamic>? fragranceNotes,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      originalPrice: originalPrice ?? this.originalPrice,
      salePrice: salePrice ?? this.salePrice,
      imageUrl: imageUrl ?? this.imageUrl,
      isFeatured: isFeatured ?? this.isFeatured,
      isSlider: isSlider ?? this.isSlider,
      badgeText: badgeText ?? this.badgeText,
      categoryId: categoryId ?? this.categoryId,
      category: category ?? this.category,
      fragranceNotes: fragranceNotes ?? this.fragranceNotes,
    );
  }
}