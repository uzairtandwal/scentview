import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/cart_service.dart';
import '../services/orders_service.dart';
import '../services/firestore_service.dart';
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
  
  // ================ UPDATED PAYMENT METHODS WITHOUT IMAGES ================
  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'cash_on_delivery', 
      'title': 'Cash on Delivery', 
      'subtitle': 'Pay when your order arrives', 
      'icon': Icons.money,
      'color': Colors.green,
      'iconData': Icons.money,
    },
    {
      'id': 'credit_card', 
      'title': 'Credit Card', 
      'subtitle': 'Pay securely with your card', 
      'icon': Icons.credit_card,
      'color': Colors.blue,
      'iconData': Icons.credit_card,
    },
    {
      'id': 'bank_transfer', 
      'title': 'Bank Transfer', 
      'subtitle': 'Transfer to our bank account', 
      'icon': Icons.account_balance,
      'color': Colors.purple,
      'iconData': Icons.account_balance,
    },
    {
      'id': 'easypaisa', 
      'title': 'EasyPaisa', 
      'subtitle': 'Pay via EasyPaisa wallet or OTC', 
      'icon': Icons.phone_android,
      'color': Color(0xFF00A859), // EasyPaisa green
      'iconData': Icons.phone_android,
    },
    {
      'id': 'jazzcash', 
      'title': 'JazzCash', 
      'subtitle': 'Pay via JazzCash wallet or OTC', 
      'icon': Icons.phone_iphone,
      'color': Color(0xFFF15A29), // JazzCash orange
      'iconData': Icons.phone_iphone,
    },
    {
      'id': 'sadapay', 
      'title': 'SadaPay', 
      'subtitle': 'Pay via SadaPay wallet', 
      'icon': Icons.wallet,
      'color': Color(0xFF5D2D86), // SadaPay purple
      'iconData': Icons.account_balance_wallet,
    },
    {
      'id': 'nayapay', 
      'title': 'NayaPay', 
      'subtitle': 'Pay via NayaPay wallet', 
      'icon': Icons.account_balance_wallet,
      'color': Color(0xFF00B2A9), // NayaPay teal
      'iconData': Icons.account_balance_wallet,
    },
    {
      'id': 'paypal', 
      'title': 'PayPal', 
      'subtitle': 'Pay via PayPal account', 
      'icon': Icons.payment,
      'color': Color(0xFF003087), // PayPal blue
      'iconData': Icons.payment,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartService>(context, listen: false);
    final double shippingFee = 5.00;
    final double totalAmount = cart.totalPrice + shippingFee;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
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
                      // ================ SHIPPING ADDRESS SECTION ================
                      _buildSectionHeader(
                        context,
                        title: 'Shipping Address',
                        onTap: () {
                          _showAddressSelection(context);
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildAddressCard(context),
                      
                      const SizedBox(height: 32),
                      
                      // ================ PAYMENT METHOD SECTION ================
                      _buildSectionHeader(
                        context,
                        title: 'Payment Method',
                        onTap: () {
                          _showPaymentSelection(context);
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildPaymentCard(context),
                      
                      const SizedBox(height: 32),
                      
                      // ================ ORDER SUMMARY SECTION ================
                      _buildSectionHeader(
                        context,
                        title: 'Order Summary',
                      ),
                      const SizedBox(height: 12),
                      _buildOrderSummary(context, cart, shippingFee, totalAmount),
                      
                      const SizedBox(height: 24),
                      
                      // ================ ITEMS LIST ================
                      if (cart.items.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order Items (${cart.itemCount})',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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

  // ================ LOADING STATE ================
  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Placing Your Order...',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please wait while we confirm your order',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  // ================ SECTION HEADER ================
  Widget _buildSectionHeader(BuildContext context, {
    required String title,
    VoidCallback? onTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        if (onTap != null)
          TextButton(
            onPressed: onTap,
            child: Text(
              'Change',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  // ================ ADDRESS CARD ================
  Widget _buildAddressCard(BuildContext context) {
    final selectedAddress = _addresses.firstWhere(
      (addr) => addr['type'] == _selectedAddress,
      orElse: () => _addresses.first,
    );

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_on_outlined,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          selectedAddress['type']!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    selectedAddress['name']!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    selectedAddress['address']!,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================ PAYMENT CARD ================
  Widget _buildPaymentCard(BuildContext context) {
    final selectedMethod = _paymentMethods.firstWhere(
      (method) => method['id'] == _selectedPaymentMethod,
      orElse: () => _paymentMethods.first,
    );

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: selectedMethod['color'].withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                selectedMethod['iconData'] as IconData,
                color: selectedMethod['color'],
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedMethod['title'] as String,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: selectedMethod['color'],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    selectedMethod['subtitle'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.check_circle,
              color: selectedMethod['color'],
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // ================ ORDER SUMMARY ================
  Widget _buildOrderSummary(BuildContext context, CartService cart, double shippingFee, double totalAmount) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildSummaryRow(
              context,
              title: 'Subtotal',
              value: '\$${cart.totalPrice.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 12),
            _buildSummaryRow(
              context,
              title: 'Shipping Fee',
              value: '\$${shippingFee.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 12),
            _buildSummaryRow(
              context,
              title: 'Tax',
              value: '\$0.00',
            ),
            const SizedBox(height: 16),
            Divider(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
              height: 1,
            ),
            const SizedBox(height: 16),
            _buildSummaryRow(
              context,
              title: 'Total Amount',
              value: '\$${totalAmount.toStringAsFixed(2)}',
              isTotal: true,
            ),
            if (cart.itemCount > 0)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  'Including ${cart.itemCount} item${cart.itemCount > 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ================ ORDER ITEM ================
  Widget _buildOrderItem(BuildContext context, dynamic product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
              image: product.imageUrl != null && product.imageUrl.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(product.imageUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: product.imageUrl == null || product.imageUrl.isEmpty
                ? Center(
                    child: Icon(
                      Icons.shopping_bag_outlined,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                      size: 24,
                    ),
                  )
                : null,
          ),
          
          const SizedBox(width: 16),
          
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${product.originalPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================ SUMMARY ROW ================
  Widget _buildSummaryRow(
    BuildContext context, {
    required String title,
    required String value,
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            color: isTotal
                ? Theme.of(context).colorScheme.onSurface
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 20 : 16,
            fontWeight: FontWeight.w700,
            color: isTotal
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  // ================ BOTTOM BAR ================
  Widget _buildBottomBar(BuildContext context, CartService cart, double totalAmount) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                '\$${totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _placeOrder(context, cart, totalAmount);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isPlacingOrder
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Processing...',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  : const Text(
                      'Confirm Order',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ================ HELPER FUNCTIONS ================
  Future<void> _showAddressSelection(BuildContext context) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Select Address',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              ..._addresses.map((address) {
                return ListTile(
                  onTap: () {
                    Navigator.pop(context, address['type']);
                  },
                  leading: Icon(
                    Icons.location_on_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(address['type']!),
                  subtitle: Text(address['address']!),
                  trailing: _selectedAddress == address['type']
                      ? Icon(
                          Icons.check_circle,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                );
              }).toList(),
            ],
          ),
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedAddress = result;
      });
    }
  }

  // ================ UPDATED PAYMENT SELECTION WITHOUT IMAGES ================
  Future<void> _showPaymentSelection(BuildContext context) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Payment Method',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Payment Methods List
              Expanded(
                child: ListView.builder(
                  itemCount: _paymentMethods.length,
                  itemBuilder: (context, index) {
                    final method = _paymentMethods[index];
                    final isSelected = _selectedPaymentMethod == method['id'];
                    
                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected 
                              ? method['color'] as Color
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: ListTile(
                        onTap: () {
                          Navigator.pop(context, method['id'] as String);
                        },
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: method['color'].withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            method['iconData'] as IconData,
                            color: method['color'] as Color,
                            size: 24,
                          ),
                        ),
                        title: Text(
                          method['title'] as String,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isSelected 
                                ? method['color'] as Color
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        subtitle: Text(
                          method['subtitle'] as String,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(
                                Icons.check_circle,
                                color: method['color'] as Color,
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Note Section
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  children: [
                    Text(
                      'Apply Transfer to the payment method.',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'All options used for reference only',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedPaymentMethod = result;
      });
    }
  }

  Future<void> _placeOrder(BuildContext context, CartService cart, double totalAmount) async {
    if (cart.items.isEmpty) return;

    setState(() {
      _isPlacingOrder = true;
    });

    try {
      // Get selected payment method title
      final selectedMethod = _paymentMethods.firstWhere(
        (method) => method['id'] == _selectedPaymentMethod,
        orElse: () => _paymentMethods.first,
      );

      // Get shipping address
      final shippingAddress = _addresses.firstWhere(
        (addr) => addr['type'] == _selectedAddress,
        orElse: () => _addresses.first,
      )['address']!;

      // Save order locally
      final cartItems = List.of(cart.items);
      await context.read<OrdersService>().addOrder(
        cartItems,
        paymentMethod: selectedMethod['title'] as String,
        shippingAddress: shippingAddress,
      );
      
      // Prepare order for Firestore
      final items = cartItems.map((p) => OrderItem(
        id: p.id,
        name: p.name,
        price: p.originalPrice,
        quantity: 1,
        imageUrl: p.imageUrl,
      )).toList();
      
      final order = Order(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt: DateTime.now(),
        items: items,
        total: totalAmount,
        status: 'Pending',
        paymentMethod: selectedMethod['title'] as String,
        shippingAddress: shippingAddress,
      );

      // Save to Firestore
      await FirestoreService().addOrder(order);

      // Show success dialog
      await _showSuccessDialog(context, selectedMethod['title'] as String);
            
      // Clear cart
      cart.clear();
      
      // Navigate back
      if (mounted) {
        Navigator.pop(context);
      }
      
    } catch (error) {
      // Show error dialog
      if (mounted) {
        await _showErrorDialog(context, error.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPlacingOrder = false;
        });
      }
    }
  }

  // ================ SUCCESS DIALOG ================
  Future<void> _showSuccessDialog(BuildContext context, String paymentMethod) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 48,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Order Confirmed!',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Payment Method: $paymentMethod',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Thank you for your purchase. Your order has been placed successfully.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text('Continue Shopping'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showErrorDialog(BuildContext context, String error) async {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Order Failed'),
        content: Text('There was an error processing your order: $error'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}