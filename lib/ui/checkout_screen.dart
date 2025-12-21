import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/cart_service.dart';
import '../services/orders_service.dart';
import '../services/firestore_service.dart';
import '../models/order.dart';

class CheckoutScreen extends StatelessWidget {
  static const routeName = '/checkout';
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionTitle(context, 'Shipping Address'),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Waseem Akram\n123, Perfume Lane\nScent City, 54000\nPakistan',
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle(context, 'Payment Method'),
          const Card(
            child: ListTile(
              leading: Icon(Icons.money),
              title: Text('Cash on Delivery'),
              subtitle: Text('Pay when your order arrives'),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle(context, 'Order Summary'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildSummaryRow(
                    context,
                    'Subtotal:',
                    '\$${cart.totalPrice.toStringAsFixed(2)}',
                  ),
                  const SizedBox(height: 8),
                  _buildSummaryRow(context, 'Shipping:', '\$5.00'),
                  const Divider(height: 24),
                  _buildSummaryRow(
                    context,
                    'Total:',
                    '\$${(cart.totalPrice + 5.00).toStringAsFixed(2)}',
                    isTotal: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () async {
            // Show confirmation dialog
            final cartItems = List.of(cart.items);
            await context.read<OrdersService>().addOrder(cartItems);
            try {
              final items = cartItems
                  .map(
                    (p) => OrderItem(
                      id: p.id,
                      name: p.name,
                      price: p.originalPrice,
                      quantity: 1,
                      imageUrl: p.imageUrl,
                    ),
                  )
                  .toList();
              final total = items.fold<double>(
                0.0,
                (s, i) => s + (i.price * i.quantity),
              );
              final order = Order(
                id: 'temp',
                createdAt: DateTime.now(),
                items: items,
                total: total,
                status: 'Paid',
              );
              await FirestoreService().addOrder(order);
            } catch (_) {
              // Ignore Firestore errors for demo and still show confirmation
            }
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Order Confirmed!'),
                content: const Text(
                  'Thank you for your purchase. Your order has been placed.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      // Clear the cart
                      cart.clear();
                      // Pop twice: once for the dialog, once for the checkout screen
                      Navigator.of(ctx).pop();
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            // Corrected from ElevatedButton.fromStyle
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          child: const Text('Confirm Order'),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String title,
    String value, {
    bool isTotal = false,
  }) {
    final style = isTotal
        ? Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)
        : Theme.of(context).textTheme.titleMedium;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: style),
        Text(value, style: style),
      ],
    );
  }
}
