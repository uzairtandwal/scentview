class Banner {
  final String id;
  final String title;
  final String? imageUrl;
  final String targetScreen;
  final String targetId;
  final bool isActive;
  final DateTime? createdAt;
  final String? description;
  final int? sortOrder;

  Banner({
    required this.id,
    required this.title,
    this.imageUrl,
    required this.targetScreen,
    required this.targetId,
    this.isActive = true,
    this.createdAt,
    this.description,
    this.sortOrder = 0,
  });

  factory Banner.fromMap(Map<String, dynamic> data, String documentId) {
    return Banner(
      id: documentId,
      title: data['title'] ?? '',
      // FIX: Yahan URL theek ho raha hai
      imageUrl: _fixUrl(data['imageUrl']), 
      targetScreen: data['targetScreen'] ?? '',
      targetId: data['targetId'] ?? '',
      isActive: data['isActive'] ?? true,
      createdAt: data['createdAt'] != null ? (data['createdAt'] as dynamic).toDate() : null,
      description: data['description'],
      sortOrder: data['sortOrder'] ?? 0,
    );
  }

  factory Banner.fromJson(Map<String, dynamic> json) {
    return Banner(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      
      // FIX: Yahan URL check aur fix ho raha hai
      imageUrl: _fixUrl(json['image_url'] ?? json['imageUrl']),
      
      targetScreen: json['target_screen'] ?? json['targetScreen'] ?? '',
      targetId: json['target_id']?.toString() ?? json['targetId']?.toString() ?? '',
      isActive: json['is_active'] == 1 || 
               json['is_active'] == true || 
               json['isActive'] == true || 
               json['isActive'] == 1,
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'].toString()) 
          : json['createdAt'] != null 
              ? DateTime.tryParse(json['createdAt'].toString()) 
              : null,
      description: json['description'],
      sortOrder: json['sort_order'] != null 
          ? int.tryParse(json['sort_order'].toString()) 
          : json['sortOrder'] != null 
              ? int.tryParse(json['sortOrder'].toString()) 
              : 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'imageUrl': imageUrl,
      'targetScreen': targetScreen,
      'targetId': targetId,
      'isActive': isActive,
      'createdAt': createdAt,
      'description': description,
      'sortOrder': sortOrder ?? 0,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image_url': imageUrl,
      'target_screen': targetScreen,
      'target_id': targetId,
      'is_active': isActive ? 1 : 0,
      'sort_order': sortOrder ?? 0,
      'created_at': createdAt?.toIso8601String(),
      'description': description,
    };
  }

  // === HELPER FUNCTION TO FIX BROKEN IMAGES ===
  static String? _fixUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    
    // 1. Agar URL pehle se theek hai (http/https se shuru ho raha hai), to waisa hi rehne do
    if (url.startsWith('http')) return url;

    // 2. Safai: Agar shuru mein '/' laga hai to hata do
    String cleanPath = url;
    if (cleanPath.startsWith('/')) {
      cleanPath = cleanPath.substring(1);
    }
    
    // 3. Agar URL sirf filename hai (e.g., scaled_banner_1.webp), to uske shuru mein sahi domain aur folder lagao.
    // Aap ke database screenshot ke mutabiq folder 'storage/uploads/' hai.
    return 'https://scentview.alwaysdata.net/storage/uploads/$cleanPath';
  }
}