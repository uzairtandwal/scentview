import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import 'package:scentview/models/order.dart';
import 'package:scentview/services/auth_service.dart';
import 'package:scentview/services/cart_service.dart';
import 'package:scentview/services/orders_service.dart';
import 'widgets/feedback_dialog.dart';

class CheckoutScreen extends StatefulWidget {
  static const routeName = '/checkout';
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen>
    with SingleTickerProviderStateMixin {
  // ── State ────────────────────────────────────────────────────────────────────
  bool _isPlacingOrder = false;
  bool _orderPlaced = false;
  String _selectedPaymentMethod = 'cash_on_delivery';
  String _selectedCity = 'Lahore';
  late String _idempotencyKey;

  // Coupon
  bool _isCouponApplied = false;
  String _couponError = '';
  static const String _validCoupon = 'SCENT50';
  static const double _discountAmount = 500.0;
  static const double _shippingFee = 200.0;

  // Controllers
  final _formKey = GlobalKey<FormState>();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _couponCtrl = TextEditingController();

  // Animation
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;

  final List<String> _cities = [
    'Lahore', 'Karachi', 'Islamabad', 'Faisalabad',
    'Multan', 'Gujranwala', 'Sheikhupura', 'Nankana Sahib',
  ];

  final List<_PaymentMethod> _paymentMethods = const [
    _PaymentMethod(
      id: 'cash_on_delivery',
      title: 'Cash on Delivery',
      subtitle: 'Pay when your order arrives',
      icon: Iconsax.money_4,
      color: Color(0xFF2E7D32),
    ),
    _PaymentMethod(
      id: 'card_payment',
      title: 'Debit / Credit Card',
      subtitle: 'Pay securely via Stripe',
      icon: Iconsax.card,
      color: Color(0xFF1565C0),
    ),
    _PaymentMethod(
      id: 'easypaisa',
      title: 'EasyPaisa',
      subtitle: 'Pay via EasyPaisa wallet',
      icon: Iconsax.mobile,
      color: Color(0xFF00897B),
    ),
  ];

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _idempotencyKey = const Uuid().v4();

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user =
          Provider.of<AuthService>(context, listen: false).currentUser;
      if (user != null) {
        // Safely try to get phone/address — graceful fallback
        final dynamic u = user;
        _phoneCtrl.text = (u.phone as String?) ?? '';
        _addressCtrl.text = (u.address as String?) ?? '';
      }
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _couponCtrl.dispose();
    super.dispose();
  }

  // ── Coupon ────────────────────────────────────────────────────────────────
  void _applyCoupon(CartService cart) {
    final code = _couponCtrl.text.trim().toUpperCase();
    if (code == _validCoupon) {
      cart.applyDiscount(_discountAmount, code);
      setState(() {
        _isCouponApplied = true;
        _couponError = '';
      });
    } else {
      setState(() {
        _isCouponApplied = false;
        _couponError = 'Invalid coupon code';
      });
    }
  }

  // ── Place Order ───────────────────────────────────────────────────────────
  Future<void> _placeOrder(CartService cart) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isPlacingOrder = true);

    final ordersService = Provider.of<OrdersService>(context, listen: false);
    final totalAmount = cart.totalPrice + _shippingFee;

    final orderItems = cart.items.map((item) => {
          'product_id': item.id,
          'quantity': cart.getQuantity(item),
          'price': item.salePrice ?? item.originalPrice,
        }).toList();

    final orderData = {
      'total_amount': totalAmount,
      'shipping_address': '${_addressCtrl.text.trim()}, $_selectedCity',
      'phone_number': _phoneCtrl.text.trim(),
      'payment_method': _selectedPaymentMethod,
      'items': orderItems,
    };

    final createdOrder =
        await ordersService.placeOrder(orderData, _idempotencyKey);

    if (!mounted) return;
    setState(() => _isPlacingOrder = false);

    if (createdOrder != null) {
      setState(() => _orderPlaced = true);
      cart.clear();
      await showSuccessDialog(
        context,
        title: 'Order Placed!',
        message:
            'Your order has been confirmed.\nWe\'ll notify you when it\'s on the way.',
        actionText: 'Continue Shopping',
        onAction: () => Navigator.pushNamedAndRemoveUntil(
          context,
          '/main-app',
          (route) => false,
        ),
      );
    } else {
      await showErrorDialog(
        context,
        title: 'Order Failed',
        message: 'Something went wrong. Please try again.',
        actionText: 'Try Again',
      );
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cart = Provider.of<CartService>(context);
    final totalAmount = cart.totalPrice + _shippingFee;

    return PopScope(
      canPop: !_isPlacingOrder && !_orderPlaced,
      child: Scaffold(
        backgroundColor: theme.colorScheme.surfaceContainerLowest,
        appBar: AppBar(
          backgroundColor: theme.colorScheme.surface,
          elevation: 0,
          centerTitle: false,
          title: Text(
            'Checkout',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
              letterSpacing: -0.3,
            ),
          ),
          leading: IconButton(
            icon: Icon(Iconsax.arrow_left_2,
                color: theme.colorScheme.onSurface),
            onPressed: (_isPlacingOrder || _orderPlaced)
                ? null
                : () => Navigator.pop(context),
          ),
        ),
        body: _isPlacingOrder
            ? _LoadingState()
            : FadeTransition(
                opacity: _fadeAnim,
                child: Form(
                  key: _formKey,
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.all(20),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            // ── Delivery Details ────────────────────
                            _SectionHeader(
                              icon: Iconsax.location5,
                              title: 'Delivery Details',
                            ),
                            const SizedBox(height: 12),
                            _DeliveryForm(
                              addressCtrl: _addressCtrl,
                              phoneCtrl: _phoneCtrl,
                              selectedCity: _selectedCity,
                              cities: _cities,
                              onCityChanged: (val) =>
                                  setState(() => _selectedCity = val),
                            ),

                            const SizedBox(height: 24),

                            // ── Payment Method ──────────────────────
                            _SectionHeader(
                              icon: Iconsax.wallet_15,
                              title: 'Payment Method',
                            ),
                            const SizedBox(height: 12),
                            _PaymentList(
                              methods: _paymentMethods,
                              selected: _selectedPaymentMethod,
                              onSelect: (id) => setState(
                                  () => _selectedPaymentMethod = id),
                            ),

                            const SizedBox(height: 24),

                            // ── Coupon ──────────────────────────────
                            _SectionHeader(
                              icon: Iconsax.ticket_discount,
                              title: 'Coupon Code',
                            ),
                            const SizedBox(height: 12),
                            _CouponField(
                              controller: _couponCtrl,
                              isApplied: _isCouponApplied,
                              errorText: _couponError,
                              onApply: () => _applyCoupon(cart),
                            ),

                            const SizedBox(height: 24),

                            // ── Price Summary ───────────────────────
                            _SectionHeader(
                              icon: Iconsax.receipt_1,
                              title: 'Price Details',
                            ),
                            const SizedBox(height: 12),
                            _PriceSummary(
                              cart: cart,
                              shippingFee: _shippingFee,
                              isCouponApplied: _isCouponApplied,
                              discountAmount: _discountAmount,
                              total: totalAmount,
                            ),

                            const SizedBox(height: 110),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        bottomNavigationBar: _BottomBar(
          total: totalAmount,
          isPlacing: _isPlacingOrder,
          isPlaced: _orderPlaced,
          onConfirm: () => _placeOrder(cart),
        ),
      ),
    );
  }
}

// ─── Payment Method Model ─────────────────────────────────────────────────────
class _PaymentMethod {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _PaymentMethod({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}

// ─── Section Header ───────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 10),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}

// ─── Delivery Form ────────────────────────────────────────────────────────────
class _DeliveryForm extends StatelessWidget {
  final TextEditingController addressCtrl;
  final TextEditingController phoneCtrl;
  final String selectedCity;
  final List<String> cities;
  final ValueChanged<String> onCityChanged;

  const _DeliveryForm({
    required this.addressCtrl,
    required this.phoneCtrl,
    required this.selectedCity,
    required this.cities,
    required this.onCityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Address field
          _FieldLabel(label: 'Street Address', icon: Iconsax.map),
          const SizedBox(height: 8),
          TextFormField(
            controller: addressCtrl,
            maxLines: 2,
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Address is required' : null,
            decoration: _inputDecor(
              theme,
              hint: 'House #, Street, Area...',
            ),
          ),

          const SizedBox(height: 16),

          // Phone field
          _FieldLabel(label: 'Phone Number', icon: Iconsax.call),
          const SizedBox(height: 8),
          TextFormField(
            controller: phoneCtrl,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Phone is required';
              if (v.trim().length < 10) return 'Enter a valid phone number';
              return null;
            },
            decoration: _inputDecor(theme, hint: '03001234567'),
          ),

          const SizedBox(height: 16),

          // City selector
          _FieldLabel(label: 'City', icon: Iconsax.building),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: cities.map((city) {
              final isSelected = city == selectedCity;
              return GestureDetector(
                onTap: () => onCityChanged(city),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    city,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w400,
                      color: isSelected
                          ? Colors.white
                          : theme.colorScheme.onSurface
                              .withValues(alpha: 0.7),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecor(ThemeData theme, {required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
        fontSize: 13,
      ),
      filled: true,
      fillColor: theme.colorScheme.surfaceContainerHighest
          .withValues(alpha: 0.4),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: theme.colorScheme.primary,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.colorScheme.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.colorScheme.error, width: 1.5),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  final IconData icon;

  const _FieldLabel({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 14,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
          ),
        ),
      ],
    );
  }
}

// ─── Payment List ─────────────────────────────────────────────────────────────
class _PaymentList extends StatelessWidget {
  final List<_PaymentMethod> methods;
  final String selected;
  final ValueChanged<String> onSelect;

  const _PaymentList({
    required this.methods,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: methods.map((m) {
        final isSelected = selected == m.id;
        return GestureDetector(
          onTap: () => onSelect(m.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? m.color.withValues(alpha: 0.05)
                  : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? m.color.withValues(alpha: 0.6)
                    : theme.colorScheme.outline.withValues(alpha: 0.15),
                width: isSelected ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: m.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(m.icon, color: m.color, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        m.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        m.subtitle,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(Iconsax.tick_circle, color: m.color, size: 20),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Coupon Field ─────────────────────────────────────────────────────────────
class _CouponField extends StatelessWidget {
  final TextEditingController controller;
  final bool isApplied;
  final String errorText;
  final VoidCallback onApply;

  const _CouponField({
    required this.controller,
    required this.isApplied,
    required this.errorText,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final success = const Color(0xFF2E7D32);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isApplied
              ? success.withValues(alpha: 0.4)
              : theme.colorScheme.outline.withValues(alpha: 0.12),
          width: isApplied ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: !isApplied,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                hintText: 'Enter coupon code',
                hintStyle: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
                  fontSize: 13,
                ),
                border: InputBorder.none,
                isDense: true,
                prefixIcon: Icon(
                  Iconsax.ticket_discount,
                  size: 18,
                  color: isApplied
                      ? success
                      : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
                errorText: errorText.isNotEmpty ? errorText : null,
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: isApplied ? null : onApply,
            style: ElevatedButton.styleFrom(
              backgroundColor: isApplied ? success : theme.colorScheme.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              isApplied ? 'Applied ✓' : 'Apply',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Price Summary ────────────────────────────────────────────────────────────
class _PriceSummary extends StatelessWidget {
  final CartService cart;
  final double shippingFee;
  final bool isCouponApplied;
  final double discountAmount;
  final double total;

  const _PriceSummary({
    required this.cart,
    required this.shippingFee,
    required this.isCouponApplied,
    required this.discountAmount,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _PriceRow(
            label: 'Subtotal (${cart.itemCount} items)',
            value: 'PKR ${cart.totalPrice.toStringAsFixed(0)}',
            theme: theme,
          ),
          const SizedBox(height: 10),
          _PriceRow(
            label: 'Shipping',
            value: 'PKR ${shippingFee.toStringAsFixed(0)}',
            theme: theme,
          ),
          if (isCouponApplied) ...[
            const SizedBox(height: 10),
            _PriceRow(
              label: 'Coupon Discount',
              value: '- PKR ${discountAmount.toStringAsFixed(0)}',
              valueColor: const Color(0xFF2E7D32),
              theme: theme,
            ),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Divider(
              color: theme.colorScheme.outline.withValues(alpha: 0.15),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                'PKR ${total.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final ThemeData theme;

  const _PriceRow({
    required this.label,
    required this.value,
    required this.theme,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: valueColor ??
                theme.colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}

// ─── Bottom Bar ───────────────────────────────────────────────────────────────
class _BottomBar extends StatelessWidget {
  final double total;
  final bool isPlacing;
  final bool isPlaced;
  final VoidCallback onConfirm;

  const _BottomBar({
    required this.total,
    required this.isPlacing,
    required this.isPlaced,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.paddingOf(context).bottom + 16,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: (isPlacing || isPlaced) ? null : onConfirm,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: isPlacing
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(
                'Confirm Order · PKR ${total.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
      ),
    );
  }
}

// ─── Loading State ────────────────────────────────────────────────────────────
class _LoadingState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: theme.colorScheme.primary),
          const SizedBox(height: 20),
          Text(
            'Placing your order...',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
