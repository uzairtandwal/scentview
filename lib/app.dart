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

class ScentViewApp extends StatelessWidget {
  const ScentViewApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        ChangeNotifierProvider<CartService>(create: (_) => CartService()),
        ChangeNotifierProvider<OrdersService>(create: (_) => OrdersService()),
      ],
      child: MaterialApp(
        title: 'ScentView',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const ModeSelectionScreen(),
          MainAppScreen.routeName: (context) => const MainAppScreen(),
          AdminHomeScreen.routeName: (context) => const AdminHomeScreen(),
          CartScreen.routeName: (context) => const CartScreen(),
          '/admin/dashboard': (context) => const AdminHomeScreen(),
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