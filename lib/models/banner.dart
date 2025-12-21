class Banner {
  final String id;
  final String title;
  final String? imageUrl; // Changed to nullable
  final String targetScreen;
  final String targetId;

  Banner({
    required this.id,
    required this.title,
    this.imageUrl, // Changed to optional
    required this.targetScreen,
    required this.targetId,
  });

  factory Banner.fromMap(Map<String, dynamic> data, String documentId) {
    return Banner(
      id: documentId,
      title: data['title'] ?? '',
      imageUrl: data['imageUrl'], // Can be null
      targetScreen: data['targetScreen'] ?? '',
      targetId: data['targetId'] ?? '',
    );
  }

  factory Banner.fromJson(Map<String, dynamic> json) {
    return Banner(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      imageUrl: json['image_url'],
      targetScreen: json['target_screen'] ?? '',
      targetId: json['target_id'].toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'imageUrl': imageUrl,
      'targetScreen': targetScreen,
      'targetId': targetId,
    };
  }
}
