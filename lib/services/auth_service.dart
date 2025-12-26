import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthUser {
  final String name;
  final String email;
  final String role;
  final String? photoUrl;
  final DateTime? createdAt;
  final String? phoneNumber;
  final String? address;

  const AuthUser({
    required this.name,
    required this.email,
    required this.role,
    this.photoUrl,
    this.createdAt,
    this.phoneNumber,
    this.address,
  });
}

class AuthService {
  final _controller = StreamController<AuthUser?>.broadcast();
  AuthUser? _current;
  final String _baseUrl = 'http://scentview.alwaysdata.net';

  AuthService() {
    _bootstrap();
  }

  Stream<AuthUser?> get user => _controller.stream;
  AuthUser? get currentUser => _current;

  Future<void> _bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null && token.isNotEmpty) {
      ApiService.authToken = token;
      try {
        final res = await http.get(
          Uri.parse('$_baseUrl/api/me'),
          headers: {'Authorization': 'Bearer $token'},
        );
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body) as Map<String, dynamic>;
          _current = AuthUser(
            name: data['name'] ?? '',
            email: data['email'] ?? '',
            role: data['role'] ?? 'user',
            photoUrl: data['photo_url'],
            createdAt: data['created_at'] != null ? DateTime.parse(data['created_at']) : null,
            phoneNumber: data['phone_number'],
            address: data['address'],
          );
          _controller.add(_current);
        }
      } catch (_) {}
    } else {
      _controller.add(null);
    }
  }

  /// Signs in a user and returns an error message on failure, or null on success.
  Future<String?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
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
      ApiService.authToken = token;
      _current = AuthUser(
        name: user['name'] ?? '',
        email: user['email'] ?? '',
        role: user['role'] ?? 'user',
        photoUrl: user['photo_url'],
        createdAt: user['created_at'] != null ? DateTime.parse(user['created_at']) : null,
        phoneNumber: user['phone_number'],
        address: user['address'],
      );
      _controller.add(_current);
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('API Sign-In Error: $e');
      }
      return 'An unexpected error occurred.';
    }
  }

  /// Creates a new user and returns an error message on failure, or null on success.
  Future<String?> createUserWithEmailAndPassword(
    String name,
    String email,
    String password,
  ) async {
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
      ApiService.authToken = token;
      _current = AuthUser(
        name: user['name'] ?? '',
        email: user['email'] ?? '',
        role: user['role'] ?? 'user',
        photoUrl: user['photo_url'],
        createdAt: user['created_at'] != null ? DateTime.parse(user['created_at']) : null,
        phoneNumber: user['phone_number'],
        address: user['address'],
      );
      _controller.add(_current);
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('API Registration Error: $e');
      }
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
    ApiService.authToken = null;
    _current = null;
    _controller.add(null);
  }

  Future<bool> isAdmin() async {
    final u = _current;
    if (u == null) return false;
    // single predefined admin account
    if (u.email.toLowerCase() == 'waseem@gmail.com') return true;
    return u.role == 'admin';
  }

  void dispose() {
    _controller.close();
  }
}
