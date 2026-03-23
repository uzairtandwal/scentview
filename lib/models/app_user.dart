class AuthUser {
  final String uid;
  final String email;
  final String? name;
  final String? profileImageUrl;
  final String? phone; 

  AuthUser({
    required this.uid,
    required this.email,
    this.name,
    this.profileImageUrl,
    this.phone, 
  });

  // API se data lene ke liye fromJson zaroori hai
  factory AuthUser.fromJson(Map<String, dynamic> data) {
    return AuthUser(
      uid: data['id']?.toString() ?? '', 
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      profileImageUrl: data['profileImageUrl'] ?? '',
      phone: data['phone']?.toString() ?? '', 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': uid,
      'email': email, 
      'name': name, 
      'profileImageUrl': profileImageUrl,
      'phone': phone,
    };
  }
}