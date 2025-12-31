import 'dart:convert'; // ✅ JSON Encode/Decode ke liye zaroori
import 'package:scentview/models/category.dart';
import 'package:scentview/services/api_service.dart';

class Product {
  final dynamic id;
  final String name;
  final String? description;
  final double originalPrice;
  final double? salePrice;
  final String imageUrl;
  final bool isFeatured;
  final bool isSlider;
  final String? badgeText;
  final String? categoryId;
  final Category? category;
  final Map<String, dynamic>? fragranceNotes;
  final String size;
  final String scentFamily;
  final int stock;
  final List<String>? tags;
  final String? brand;
  final String? sku;
  final bool isActive;
  final bool hasFreeShipping;
  final bool isTaxable;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.originalPrice,
    this.salePrice,
    required this.imageUrl,
    this.isFeatured = false,
    this.isSlider = false,
    this.badgeText,
    this.categoryId,
    this.category,
    this.fragranceNotes,
    required this.size,
    required this.scentFamily,
    required this.stock,
    this.tags,
    this.brand,
    this.sku,
    this.isActive = true,
    this.hasFreeShipping = false,
    this.isTaxable = true,
  });

  // ==================== 1. API PARSING (Jaisa aapka pehle tha) ====================
  factory Product.fromJson(Map<String, dynamic> json) {
    // Safely handle description
    String? description;
    if (json['description'] is String) {
      description = json['description'];
    } else if (json['description'] is Map) {
      description = json['description'].toString();
    } else {
      description = json['description']?.toString() ?? '';
    }

    // Safely handle image URL
    String imageUrl;
    if (json['main_image_url'] is String) {
      imageUrl = ApiService.toAbsoluteUrl(json['main_image_url']) ?? '';
    } else if (json['main_image_url'] is Map) {
      final Map<String, dynamic> imageMap = json['main_image_url'];
      String? tempUrl;
      if (imageMap.containsKey('url')) {
        tempUrl = imageMap['url']?.toString();
      } else if (imageMap.containsKey('src')) {
        tempUrl = imageMap['src']?.toString();
      }
      imageUrl = ApiService.toAbsoluteUrl(tempUrl) ?? imageMap.toString();
    } else {
      imageUrl = '';
    }

    return Product(
      id: json['id'],
      name: json['name']?.toString() ?? '',
      description: description,
      originalPrice: double.tryParse(json['price']?.toString() ?? '0.0') ?? 0.0,
      salePrice: json['sale_price'] != null ? double.tryParse(json['sale_price'].toString()) : null,
      imageUrl: imageUrl,
      isFeatured: json['is_featured'] == 1 || json['is_featured'] == true,
      isSlider: json['is_slider'] == 1 || json['is_slider'] == true,
      badgeText: json['badge_text']?.toString(),
      categoryId: json['category_id']?.toString(),
      category: json['category'] != null && json['category'] is Map<String, dynamic>
          ? Category.fromJson(json['category'])
          : null,
      fragranceNotes: json['fragrance_notes'] is Map ? Map<String, dynamic>.from(json['fragrance_notes']) : null,
      size: json['size']?.toString() ?? '',
      scentFamily: json['scent_family']?.toString() ?? '',
      stock: int.tryParse(json['stock']?.toString() ?? '0') ?? 0,
      tags: json['tags'] != null && json['tags'] is List
          ? List<String>.from(json['tags'].map((tag) => tag.toString()))
          : null,
      brand: json['brand']?.toString(),
      sku: json['sku']?.toString(),
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      hasFreeShipping: json['has_free_shipping'] == 1 || json['has_free_shipping'] == true,
      isTaxable: json['is_taxable'] == 1 || json['is_taxable'] == true,
    );
  }

  // ==================== 2. DATABASE PARSING (Offline ke liye) ====================
  // Ye function SQLite DB se data parh kar Model banata hai
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      categoryId: map['category_id']?.toString(),
      name: map['name'],
      description: map['description'],
      originalPrice: double.tryParse(map['price'].toString()) ?? 0.0,
      salePrice: map['sale_price'] != null ? double.tryParse(map['sale_price'].toString()) : null,
      stock: map['stock'] ?? 0,
      badgeText: map['badge_text'],
      isFeatured: map['is_featured'] == 1,
      imageUrl: map['main_image_url'] ?? '',
      // Complex types (JSON se Map banate hain)
      fragranceNotes: map['fragrance_notes'] != null ? jsonDecode(map['fragrance_notes']) : null,
      // Default empty values for fields not in DB schema yet
      size: '', 
      scentFamily: '',
      isSlider: false,
    );
  }

  // ==================== 3. SAVE TO DATABASE (Offline ke liye) ====================
  // Ye function Model ko Database format mein convert karta hai
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': categoryId != null ? int.tryParse(categoryId!) : null,
      'name': name,
      'description': description,
      'price': originalPrice.toString(),
      'sale_price': salePrice?.toString(),
      'stock': stock,
      'badge_text': badgeText,
      // SQLite mein boolean nahi hota, 1 ya 0 store karte hain
      'is_featured': isFeatured ? 1 : 0, 
      'main_image_url': imageUrl,
      // Map ko String bana kar save karte hain
      'fragrance_notes': fragranceNotes != null ? jsonEncode(fragranceNotes) : null,
    };
  }

  // ==================== 4. SEND TO API (Purana) ====================
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
      'category': category?.toMap(),
      'fragrance_notes': fragranceNotes,
      'size': size,
      'scent_family': scentFamily,
      'stock': stock,
      'tags': tags,
      'brand': brand,
      'sku': sku,
      'is_active': isActive,
      'has_free_shipping': hasFreeShipping,
      'is_taxable': isTaxable,
    }..removeWhere((key, value) => value == null);
  }

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
    String? categoryId,
    Category? category,
    Map<String, dynamic>? fragranceNotes,
    String? size,
    String? scentFamily,
    int? stock,
    List<String>? tags,
    String? brand,
    String? sku,
    bool? isActive,
    bool? hasFreeShipping,
    bool? isTaxable,
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
      size: size ?? this.size,
      scentFamily: scentFamily ?? this.scentFamily,
      stock: stock ?? this.stock,
      tags: tags ?? this.tags,
      brand: brand ?? this.brand,
      sku: sku ?? this.sku,
      isActive: isActive ?? this.isActive,
      hasFreeShipping: hasFreeShipping ?? this.hasFreeShipping,
      isTaxable: isTaxable ?? this.isTaxable,
    );
  }
}