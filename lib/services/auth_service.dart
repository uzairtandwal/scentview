import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; 
import 'api_service.dart';
import 'package:scentview/utils/url_utils.dart';

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
  final String _baseUrl = '${UrlUtils.domainUrl}/api/v1';
  
  static bool _fcmAlreadySynced = false;
  bool _isInitializing = false;

  AuthService() {
    // We will call bootstrap/tryAutoLogin explicitly from the UI or a controlled point
    // to avoid constructor-based side effects that can cause loops.
  }

  Stream<AuthUser?> get user => _controller.stream;
  AuthUser? get currentUser => _current;
  bool get isAuthenticated => _current != null;

  Future<void> syncFcmToken(String userId) async {
    if (_fcmAlreadySynced) return; 

    final token = ApiService.authToken;
    if (token == null) return;

    try {
      String? fcmToken = await FirebaseMessaging.instance.getToken();
      
      if (fcmToken != null) {
        final response = await http.post(
          Uri.parse('$_baseUrl/update-fcm-token'),
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
          _fcmAlreadySynced = true;
          if (kDebugMode) print("✅ FCM Token Synced Successfully");
        }
      }
    } catch (e) {
      if (kDebugMode) print("❌ FCM Sync Error: $e");
    }
  }

  Future<bool> tryAutoLogin() async {
    // Prevent overlapping calls
    if (_isInitializing) return false;
    _isInitializing = true;

    if (kDebugMode) print('🔍 AUTH_SERVICE: tryAutoLogin CALLED!');
    
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    if (token == null || token.isEmpty) {
      _isInitializing = false;
      if (_current != null) {
        _current = null;
        _controller.add(null);
        notifyListeners();
      }
      return false;
    }

    ApiService.setAuthToken(token);
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/me'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 30));
      
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final newUser = AuthUser(
          id: data['id']?.toString(),
          name: data['name'] ?? '',
          email: data['email'] ?? '',
          role: data['role'] ?? 'user',
          photoUrl: data['photo_url'],
          createdAt: data['created_at'] != null ? DateTime.parse(data['created_at']) : null,
          phoneNumber: data['phone_number'],
          address: data['address'],
        );

        bool changed = _current == null || _current!.email != newUser.email;
        _current = newUser;

        if (_current?.id != null) {
          // Sync FCM in background, don't await to avoid blocking
          syncFcmToken(_current!.id!);
        }

        _controller.add(_current);
        if (changed) {
           notifyListeners();
        }
        _isInitializing = false;
        return true;
      } else {
        ApiService.setAuthToken(null);
        _current = null;
        _controller.add(null);
        notifyListeners();
        _isInitializing = false;
        return false;
      }
    } catch (e) {
      if (kDebugMode) print('Auto-Login Error: $e');
      _isInitializing = false;
      // Don't clear current on network error to avoid losing session
      return false;
    }
  }

  Future<String?> signInWithEmailAndPassword(String email, String password) async {
    try {
      if (kDebugMode) print('🔐 AUTH_SERVICE: Attempting login for $email');
      
      final res = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 30));
      
      if (kDebugMode) print('📡 AUTH_SERVICE: Response Status: ${res.statusCode}');
      
      if (res.statusCode >= 300) {
        try {
          final body = jsonDecode(res.body);
          if (body is Map && body['message'] != null) return body['message'];
        } catch (_) {}
        return 'Incorrect email or password. Please try again.';
      }
      
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final token = data['token'] as String?;
      final user = data['user'] as Map<String, dynamic>?;
      
      if (token == null || user == null) {
         if (kDebugMode) print('❌ AUTH_SERVICE: Token or User is NULL in response');
         return 'Invalid server response.';
      }
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      ApiService.setAuthToken(token);
      
      _fcmAlreadySynced = false;

      _current = AuthUser(
        id: user['id']?.toString(),
        name: user['name'] ?? '',
        email: user['email'] ?? '',
        role: user['role'] ?? 'user',
        photoUrl: user['photo_url'],
        createdAt: user['created_at'] != null ? DateTime.tryParse(user['created_at'].toString()) : null,
        phoneNumber: user['phone_number'],
        address: user['address'],
      );

      if (_current?.id != null) syncFcmToken(_current!.id!);
      
      _controller.add(_current);
      notifyListeners();
      if (kDebugMode) print('✅ AUTH_SERVICE: Login Successful');
      return null;
    } catch (e) {
      if (kDebugMode) print('❌ API Sign-In Error: $e');
      return 'An unexpected error occurred: $e';
    }
  }

  Future<String?> createUserWithEmailAndPassword(String name, String email, String password) async {
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/register'),
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
      
      _fcmAlreadySynced = false;

      _current = AuthUser(
        id: user['id']?.toString(),
        name: user['name'] ?? '',
        email: user['email'] ?? '',
        role: user['role'] ?? 'user',
        photoUrl: user['photo_url'],
        createdAt: user['created_at'] != null ? DateTime.parse(data['created_at']) : null,
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
          Uri.parse('$_baseUrl/logout'),
          headers: {'Authorization': 'Bearer $token'},
        );
      }
    } catch (_) {}
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    ApiService.setAuthToken(null);
    _current = null;
    _fcmAlreadySynced = false;
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
