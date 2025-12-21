import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scentview/models/product_model.dart';
import 'package:scentview/services/cart_service.dart';
import 'package:scentview/ui/cart_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProductDetailBottomBar extends StatelessWidget {
  final Product product;
  const ProductDetailBottomBar({required this.product, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                // TODO: Implement WhatsApp logic. Ask user for details.
              },
              icon: const FaIcon(FontAwesomeIcons.whatsapp),
              iconSize: 30,
            ),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  final cartService = Provider.of<CartService>(context, listen: false);
                  cartService.add(product);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Product added to cart!'), duration: Duration(seconds: 1)),
                  );
                },
                icon: const Icon(Icons.shopping_cart_outlined),
                label: const Text("Add to Cart"),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Theme.of(context).colorScheme.primary),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  minimumSize: const Size.fromHeight(70),
                ),
              ),
            ),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  final cartService = Provider.of<CartService>(context, listen: false);
                  cartService.add(product);
                  Navigator.of(context).pushNamed(CartScreen.routeName);
                },
                icon: const Icon(Icons.credit_card),
                label: const Text("Buy Now"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  minimumSize: const Size.fromHeight(70),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}