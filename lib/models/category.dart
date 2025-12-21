class Category {
  final String id;
  final String name;
  final String? imageUrl; // Changed to nullable

  Category({
    required this.id,
    required this.name,
    this.imageUrl, // Changed to optional
  });

  factory Category.fromMap(Map<String, dynamic> data, String documentId) {
    return Category(
      id: documentId,
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'], // Can be null
    );
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'imageUrl': imageUrl};
  }
}
