import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/cart_service.dart';
import '../cart_screen.dart';
import '../profile_screen.dart';
import '../search_results_screen.dart';
import 'app_logo.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final searchController = TextEditingController();
    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          const AppLogo(size: 36),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search),
                ),
                onSubmitted: (query) {
                  if (query.isNotEmpty) {
                    Navigator.pushNamed(
                      context,
                      SearchResultsScreen.routeName,
                      arguments: query,
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
      actions: [
        Consumer<CartService>(
          builder: (context, cart, child) {
            return Badge(
              label: Text(cart.itemCount.toString()),
              isLabelVisible: cart.itemCount > 0,
              child: IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                tooltip: 'Cart',
                onPressed: () =>
                    Navigator.pushNamed(context, CartScreen.routeName),
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.person_outline),
          tooltip: 'Profile',
          onPressed: () =>
              Navigator.pushNamed(context, ProfileScreen.routeName),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
