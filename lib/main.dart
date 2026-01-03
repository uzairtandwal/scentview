import 'dart:io';
import 'package:flutter/foundation.dart'; // ✅ kIsWeb ke liye zaroori hai
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart'; 
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:scentview/services/auth_service.dart';
import 'package:scentview/services/orders_service.dart'; 
import 'package:scentview/services/cart_service.dart';
import 'firebase_options.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Platform-specific database factory initialization
  if (kIsWeb) {
    // Use FFI for web
    databaseFactory = databaseFactoryFfiWeb;
  } else if (Platform.isWindows || Platform.isLinux) {
    // Use FFI for desktop
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  // For other platforms like Android/iOS, sqflite will use the default factory.

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthService()),
          ChangeNotifierProvider(create: (_) => OrdersService()),
          ChangeNotifierProvider(create: (_) => CartService()),
        ],
        child: ScentViewApp(),
      ),
    );

  } catch (e) {
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Error: ${e.toString()}')),
        ),
      ),
    );
  }
}