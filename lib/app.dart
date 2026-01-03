import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scentview/admin/admin_home_screen.dart';
import 'package:scentview/admin/banners_screen.dart';
import 'package:scentview/admin/categories_screen.dart';
import 'package:scentview/admin/products_screen.dart';
import 'package:scentview/models/product_model.dart';
import 'package:scentview/services/auth_service.dart';
import 'package:scentview/services/cart_service.dart';
import 'package:scentview/services/orders_service.dart';
import 'package:scentview/ui/cart_screen.dart';
import 'package:scentview/ui/main_app_screen.dart';
import 'package:scentview/ui/mode_selection_screen.dart';
import 'package:scentview/ui/product_detail_screen.dart';
import 'package:scentview/ui/checkout_screen.dart';
import 'package:scentview/ui/login_screen.dart';
import 'package:scentview/ui/splash_screen.dart'; // ✅ Splash Screen Import

class ScentViewApp extends StatelessWidget {
  const ScentViewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(create: (_) => AuthService()),
        ChangeNotifierProvider<CartService>(create: (_) => CartService()),
        ChangeNotifierProvider<OrdersService>(create: (_) => OrdersService()),
      ],
      child: MaterialApp(
        title: 'ScentView',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          useMaterial3: true,
        ),
        
        // 👇 Pehle Splash Screen khulegi
        home: const SplashScreen(), 

        routes: {
          '/home-logic': (context) => Consumer<AuthService>(
            builder: (context, auth, _) {
              return FutureBuilder(
                future: auth.tryAutoLogin(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(body: Center(child: CircularProgressIndicator()));
                  }

                  // ✅ Agar Admin hai to Admin Dashboard
                  if (auth.isAuthenticated && auth.currentUser?.role == 'admin') {
                    return const AdminHomeScreen();
                  }

                  // ✅ Normal users ke liye seedha Shop (MainAppScreen) khulegi
                  return const MainAppScreen();
                },
              );
            },
          ),
          MainAppScreen.routeName: (context) => const MainAppScreen(),
          AdminHomeScreen.routeName: (context) => const AdminHomeScreen(),
          CartScreen.routeName: (context) => const CartScreen(),
          CheckoutScreen.routeName: (context) => const CheckoutScreen(),
          LoginScreen.routeName: (context) => const LoginScreen(),
          
          // ✅ Error Fix: Direct string path use kiya hai
          '/mode-selection': (context) => const ModeSelectionScreen(), 

          '/admin/banners': (context) => const BannersScreen(),
          '/admin/categories': (context) => const CategoriesScreen(),
          '/admin/products': (context) => const ProductsScreen(),
        },
        
        onGenerateRoute: (settings) {
          if (settings.name == ProductDetailScreen.routeName) {
            final args = settings.arguments as Map<String, dynamic>;
            final product = args['product'] as Product;
            final allProducts = args['allProducts'] as List<Product>;
            return MaterialPageRoute(
              builder: (context) {
                return ProductDetailScreen(
                  product: product,
                  allProducts: allProducts,
                );
              },
            );
          }
          return null;
        },
      ),
    );
  }
}