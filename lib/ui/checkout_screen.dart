import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/cart_service.dart';
import '../services/orders_service.dart';
import '../services/auth_service.dart'; 
import '../models/order.dart';

class CheckoutScreen extends StatefulWidget {
  static const routeName = '/checkout';
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _isPlacingOrder = false;
  String? _selectedAddress = 'Home';
  String? _selectedPaymentMethod = 'cash_on_delivery';
  
  final List<Map<String, String>> _addresses = [
    {'type': 'Home', 'address': '123, Perfume Lane\nScent City, 54000\nPakistan', 'name': 'Waseem Akram'},
    {'type': 'Office', 'address': '456, Business Street\nScent City, 54000\nPakistan', 'name': 'Waseem Akram'},
    {'type': 'Other', 'address': '789, Alternate Road\nScent City, 54000\nPakistan', 'name': 'Waseem Akram'},
  ];
  
  final List<Map<String, dynamic>> _paymentMethods = [
    {'id': 'cash_on_delivery', 'title': 'Cash on Delivery', 'subtitle': 'Pay when your order arrives', 'icon': Icons.money, 'color': Colors.green, 'iconData': Icons.money},
    {'id': 'credit_card', 'title': 'Credit Card', 'subtitle': 'Pay securely with your card', 'icon': Icons.credit_card, 'color': Colors.blue, 'iconData': Icons.credit_card},
    {'id': 'bank_transfer', 'title': 'Bank Transfer', 'subtitle': 'Transfer to our bank account', 'icon': Icons.account_balance, 'color': Colors.purple, 'iconData': Icons.account_balance},
    {'id': 'easypaisa', 'title': 'EasyPaisa', 'subtitle': 'Pay via EasyPaisa wallet or OTC', 'icon': Icons.phone_android, 'color': const Color(0xFF00A859), 'iconData': Icons.phone_android},
    {'id': 'jazzcash', 'title': 'JazzCash', 'subtitle': 'Pay via JazzCash wallet or OTC', 'icon': Icons.phone_iphone, 'color': const Color(0xFFF15A29), 'iconData': Icons.phone_iphone},
    {'id': 'sadapay', 'title': 'SadaPay', 'subtitle': 'Pay via SadaPay wallet', 'icon': Icons.wallet, 'color': const Color(0xFF5D2D86), 'iconData': Icons.account_balance_wallet},
    {'id': 'nayapay', 'title': 'NayaPay', 'subtitle': 'Pay via NayaPay wallet', 'icon': Icons.account_balance_wallet, 'color': const Color(0xFF00B2A9), 'iconData': Icons.account_balance_wallet},
    {'id': 'paypal', 'title': 'PayPal', 'subtitle': 'Pay via PayPal account', 'icon': Icons.payment, 'color': const Color(0xFF003087), 'iconData': Icons.payment},
  ];

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartService>(context);
    final double shippingFee = 5.00;
    final double totalAmount = cart.totalPrice + shippingFee;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
      ),
      body: _isPlacingOrder
          ? _buildLoadingState(context)
          : CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildSectionHeader(context, title: 'Shipping Address', onTap: () => _showAddressSelection(context)),
                      const SizedBox(height: 12),
                      _buildAddressCard(context),
                      const SizedBox(height: 32),
                      _buildSectionHeader(context, title: 'Payment Method', onTap: () => _showPaymentSelection(context)),
                      const SizedBox(height: 12),
                      _buildPaymentCard(context),
                      const SizedBox(height: 32),
                      _buildSectionHeader(context, title: 'Order Summary'),
                      const SizedBox(height: 12),
                      _buildOrderSummary(context, cart, shippingFee, totalAmount),
                      const SizedBox(height: 24),
                      if (cart.items.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Order Items (${cart.itemCount})', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 12),
                            ...cart.items.map((product) => _buildOrderItem(context, product)).toList(),
                          ],
                        ),
                    ]),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: _buildBottomBar(context, cart, totalAmount),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(strokeWidth: 3),
          const SizedBox(height: 20),
          Text('Placing Your Order...', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, {required String title, VoidCallback? onTap}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
        if (onTap != null) TextButton(onPressed: onTap, child: const Text('Change')),
      ],
    );
  }

  Widget _buildAddressCard(BuildContext context) {
    final selectedAddress = _addresses.firstWhere((addr) => addr['type'] == _selectedAddress, orElse: () => _addresses.first);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.1))),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(selectedAddress['name']!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(selectedAddress['address']!, style: TextStyle(color: Colors.grey.shade700)),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentCard(BuildContext context) {
    final selectedMethod = _paymentMethods.firstWhere((method) => method['id'] == _selectedPaymentMethod, orElse: () => _paymentMethods.first);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.1))),
      child: ListTile(
        leading: Icon(selectedMethod['iconData'], color: selectedMethod['color']),
        title: Text(selectedMethod['title']),
        subtitle: Text(selectedMethod['subtitle']),
        trailing: const Icon(Icons.check_circle, color: Colors.green),
      ),
    );
  }

  Widget _buildOrderSummary(BuildContext context, CartService cart, double shippingFee, double totalAmount) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.1))),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildSummaryRow(context, title: 'Subtotal', value: '\$${cart.totalPrice.toStringAsFixed(2)}'),
            const SizedBox(height: 12),
            _buildSummaryRow(context, title: 'Shipping Fee', value: '\$${shippingFee.toStringAsFixed(2)}'),
            const Divider(height: 32),
            _buildSummaryRow(context, title: 'Total Amount', value: '\$${totalAmount.toStringAsFixed(2)}', isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(BuildContext context, dynamic product) {
    return ListTile(
      leading: Image.network(product.imageUrl, width: 50, errorBuilder: (c, e, s) => const Icon(Icons.shopping_bag)),
      title: Text(product.name),
      subtitle: Text('\$${(product.salePrice ?? product.originalPrice).toStringAsFixed(2)}'),
    );
  }

  Widget _buildSummaryRow(BuildContext context, {required String title, required String value, bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontSize: isTotal ? 18 : 16, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        Text(value, style: TextStyle(fontSize: isTotal ? 18 : 16, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, CartService cart, double totalAmount) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(
        onPressed: _isPlacingOrder ? null : () => _placeOrder(context, cart, totalAmount),
        style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(54)),
        child: _isPlacingOrder ? const CircularProgressIndicator(color: Colors.white) : const Text('Confirm Order'),
      ),
    );
  }

  Future<void> _placeOrder(BuildContext context, CartService cart, double totalAmount) async {
    if (cart.items.isEmpty) return;
    setState(() => _isPlacingOrder = true);
    try {
      final auth = Provider.of<AuthService>(context, listen: false);
      final orders = Provider.of<OrdersService>(context, listen: false);
      final method = _paymentMethods.firstWhere((m) => m['id'] == _selectedPaymentMethod);
      final addr = _addresses.firstWhere((a) => a['type'] == _selectedAddress)['address']!;

      if (!auth.isAuthenticated) throw 'Please login to complete your order.';

      final result = await orders.placeOrder(
        products: cart.items,
        paymentMethod: method['title'],
        shippingAddress: addr,
        phoneNumber: auth.currentUser?.phoneNumber ?? 'N/A',
      );

      if (result != null) {
        await _showSuccessDialog(context, method['title']);
        cart.clear();
        if (mounted) Navigator.pop(context);
      } else {
        throw 'Could not place order.';
      }
    } catch (error) {
      if (mounted) _showErrorDialog(context, error.toString());
    } finally {
      if (mounted) setState(() => _isPlacingOrder = false);
    }
  }

  Future<void> _showSuccessDialog(BuildContext context, String method) async {
    return showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text('Success'), content: const Text('Order placed successfully!')));
  }

  Future<void> _showErrorDialog(BuildContext context, String error) async {
    return showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text('Error'), content: Text(error)));
  }

  // ================ BOTTOM SHEETS (FIXED POSITION) ================
  Future<void> _showAddressSelection(BuildContext context) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: _addresses.map((a) => ListTile(title: Text(a['type']!), onTap: () => Navigator.pop(context, a['type']))).toList(),
      ),
    );
    if (result != null) setState(() => _selectedAddress = result);
  }

  Future<void> _showPaymentSelection(BuildContext context) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => ListView(
        shrinkWrap: true,
        children: _paymentMethods.map((m) => ListTile(title: Text(m['title']), onTap: () => Navigator.pop(context, m['id']))).toList(),
      ),
    );
    if (result != null) setState(() => _selectedPaymentMethod = result);
  }
} // ✅ End of State class