import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; 
import 'api_service.dart';

class AuthUser {
  final String? id; 
  final String name;
  final String email;
  final String role;
  final String? photoUrl;
  final DateTime? createdAt;
  final String? phoneNumber;
  final String? address;

  const AuthUser({
    this.id,
    required this.name,
    required this.email,
    required this.role,
    this.photoUrl,
    this.createdAt,
    this.phoneNumber,
    this.address,
  });
}

class AuthService extends ChangeNotifier {
  final _controller = StreamController<AuthUser?>.broadcast();
  AuthUser? _current;
  final String _baseUrl = 'https://scentview.alwaysdata.net';
  
  // ✅ GATEKEEPER: Loop ko rokne ke liye
  static bool _fcmAlreadySynced = false;

  AuthService() {
    _bootstrap();
  }

  Stream<AuthUser?> get user => _controller.stream;
  AuthUser? get currentUser => _current;
  bool get isAuthenticated => _current != null;

  Future<void> _bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null && token.isNotEmpty) {
      ApiService.setAuthToken(token);
    }
    await tryAutoLogin();
  }

  // ✅ Token Sync Function: Updated with Gatekeeper
  Future<void> syncFcmToken(String userId) async {
    // Agar pehle sync ho chuka hai toh ruk jao
    if (_fcmAlreadySynced) return; 

    final token = ApiService.authToken;
    if (kDebugMode) print("🔄 Syncing FCM Token. AuthToken present: ${token != null}");

    try {
      String? fcmToken = await FirebaseMessaging.instance.getToken();
      
      if (fcmToken != null) {
        final response = await http.post(
          Uri.parse('$_baseUrl/api/update-fcm-token'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            "user_id": userId,
            "fcm_token": fcmToken,
          }),
        );

        if (response.statusCode == 200) {
          _fcmAlreadySynced = true; // ✅ Mark as synced
          if (kDebugMode) print("✅ FCM Token Synced Successfully (Only Once)");
        } else if (response.statusCode == 429) {
          if (kDebugMode) print("❌ Server Blocked: 429 Error. Waiting for cooldown.");
        }
      }
    } catch (e) {
      if (kDebugMode) print("❌ FCM Sync Error: $e");
    }
  }

  Future<bool> tryAutoLogin() async {
    if (kDebugMode) print('------------------------------------------');
    if (kDebugMode) print('🔍 AUTH_SERVICE: tryAutoLogin CALLED!');
    if (kDebugMode) print('------------------------------------------');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    if (token == null || token.isEmpty) {
      _controller.add(null);
      return false;
    }

    ApiService.setAuthToken(token);
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/api/me'),
        headers: {'Authorization': 'Bearer $token'},
      );
      
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        _current = AuthUser(
          id: data['id']?.toString(),
          name: data['name'] ?? '',
          email: data['email'] ?? '',
          role: data['role'] ?? 'user',
          photoUrl: data['photo_url'],
          createdAt: data['created_at'] != null ? DateTime.parse(data['created_at']) : null,
          phoneNumber: data['phone_number'],
          address: data['address'],
        );

        if (_current?.id != null) syncFcmToken(_current!.id!);

        _controller.add(_current);
        notifyListeners();
        return true;
      } else {
        ApiService.setAuthToken(null);
        _controller.add(null);
        return false;
      }
    } catch (e) {
      if (kDebugMode) print('Auto-Login Error: $e');
      _controller.add(null);
      return false;
    }
  }

  Future<String?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      
      if (res.statusCode >= 300) {
        return 'Incorrect email or password. Please try again.';
      }
      
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final token = data['token'] as String?;
      final user = data['user'] as Map<String, dynamic>?;
      
      if (token == null || user == null) return 'Invalid server response.';
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      ApiService.setAuthToken(token);
      
      // ✅ Reset sync flag upon new login
      _fcmAlreadySynced = false;

      _current = AuthUser(
        id: user['id']?.toString(),
        name: user['name'] ?? '',
        email: user['email'] ?? '',
        role: user['role'] ?? 'user',
        photoUrl: user['photo_url'],
        createdAt: user['created_at'] != null ? DateTime.parse(user['created_at']) : null,
        phoneNumber: user['phone_number'],
        address: user['address'],
      );

      if (_current?.id != null) await syncFcmToken(_current!.id!);
      
      _controller.add(_current);
      notifyListeners();
      return null;
    } catch (e) {
      if (kDebugMode) print('API Sign-In Error: $e');
      return 'An unexpected error occurred.';
    }
  }

  Future<String?> createUserWithEmailAndPassword(String name, String email, String password) async {
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/api/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );
      
      if (res.statusCode >= 300) {
        return 'Registration failed. Email may already be in use.';
      }
      
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final token = data['token'] as String?;
      final user = data['user'] as Map<String, dynamic>?;
      
      if (token == null || user == null) return 'Invalid server response.';
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      ApiService.setAuthToken(token);
      
      // ✅ Reset sync flag
      _fcmAlreadySynced = false;

      _current = AuthUser(
        id: user['id']?.toString(),
        name: user['name'] ?? '',
        email: user['email'] ?? '',
        role: user['role'] ?? 'user',
        photoUrl: user['photo_url'],
        createdAt: user['created_at'] != null ? DateTime.parse(user['created_at']) : null,
        phoneNumber: user['phone_number'],
        address: user['address'],
      );

      if (_current?.id != null) await syncFcmToken(_current!.id!);
      
      _controller.add(_current);
      notifyListeners();
      return null;
    } catch (e) {
      if (kDebugMode) print('API Registration Error: $e');
      return 'An unexpected error occurred.';
    }
  }

  Future<void> signOut() async {
    try {
      final token = ApiService.authToken;
      if (token != null) {
        await http.post(
          Uri.parse('$_baseUrl/api/logout'),
          headers: {'Authorization': 'Bearer $token'},
        );
      }
    } catch (_) {}
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    ApiService.setAuthToken(null);
    _current = null;
    _fcmAlreadySynced = false; // Reset on logout
    _controller.add(null);
    notifyListeners();
  }

  Future<bool> isAdmin() async {
    final u = _current;
    if (u == null) return false;
    if (u.email.toLowerCase() == 'waseem@gmail.com') return true;
    return u.role == 'admin';
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }
}