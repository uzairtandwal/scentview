class AppUser {
  final String uid;
  final String email;
  final String? name;
  final String? profileImageUrl;

  AppUser({
    required this.uid,
    required this.email,
    this.name,
    this.profileImageUrl,
  });

  factory AppUser.fromMap(Map<String, dynamic> data, String documentId) {
    return AppUser(
      uid: documentId,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      profileImageUrl: data['profileImageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'email': email, 'name': name, 'profileImageUrl': profileImageUrl};
  }
}
