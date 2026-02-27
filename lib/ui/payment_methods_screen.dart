import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class PaymentMethodsScreen extends StatefulWidget {
  static const routeName = '/payment-methods';
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  // ── Aapka existing data — bilkul same ──
  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': '1',
      'type': 'credit_card',
      'brand': 'Visa',
      'last4': '4242',
      'isDefault': true,
      'icon': Icons.credit_card_rounded,
      'color': Colors.blue,
    },
    {
      'id': '2',
      'type': 'paypal',
      'brand': 'PayPal',
      'last4': '****',
      'isDefault': false,
      'icon': Icons.payment_rounded,
      'color': Colors.blue.shade800,
    },
    {
      'id': '3',
      'type': 'cash_on_delivery',
      'brand': 'Cash on Delivery',
      'last4': 'N/A',
      'isDefault': false,
      'icon': Icons.money_rounded,
      'color': Colors.green,
    },
  ];

  String? _selectedMethodId = '1';

  // ── NAYA: Checkout toggle options ──
  final Map<String, bool> _checkoutOptions = {
    'Cash on Delivery': true,
    'JazzCash': true,
    'EasyPaisa': false,
    'Bank Transfer': false,
    'Credit/Debit Card': true,
  };

  final Map<String, IconData> _optionIcons = {
    'Cash on Delivery': Iconsax.money_25,
    'JazzCash': Iconsax.mobile5,
    'EasyPaisa': Iconsax.mobile5,
    'Bank Transfer': Iconsax.bank,
    'Credit/Debit Card': Iconsax.card5,
  };

  final Map<String, Color> _optionColors = {
    'Cash on Delivery': Colors.green,
    'JazzCash': Colors.red,
    'EasyPaisa': Colors.teal,
    'Bank Transfer': Colors.blue,
    'Credit/Debit Card': Colors.purple,
  };

  // ── Aapke existing functions — bilkul same ──
  void _addPaymentMethod() async {
    final result = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _AddPaymentMethodBottomSheet(
          onCardAdded: (last4) {
            Navigator.pop(ctx, last4);
          },
        );
      },
    );

    if (result != null && result.length == 4) {
      setState(() {
        _paymentMethods.add({
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'type': 'credit_card',
          'brand': 'Card',
          'last4': result,
          'isDefault': false,
          'icon': Icons.credit_card_rounded,
          'color': Colors.purple,
        });
      });
      _showSuccessSnackbar(context, 'Payment method added successfully');
    }
  }

  void _setAsDefault(String methodId) {
    setState(() {
      for (var method in _paymentMethods) {
        method['isDefault'] = false;
      }
      final method =
          _paymentMethods.firstWhere((m) => m['id'] == methodId);
      method['isDefault'] = true;
      _selectedMethodId = methodId;
    });
    _showSuccessSnackbar(context, 'Default payment method updated');
  }

  void _deletePaymentMethod(String methodId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: const Text('Remove Payment Method'),
          content: const Text(
              'Are you sure you want to remove this payment method?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      setState(() {
        _paymentMethods
            .removeWhere((method) => method['id'] == methodId);
        if (_selectedMethodId == methodId &&
            _paymentMethods.isNotEmpty) {
          _paymentMethods.first['isDefault'] = true;
          _selectedMethodId = _paymentMethods.first['id'];
        }
      });
      _showSuccessSnackbar(context, 'Payment method removed');
    }
  }

  void _showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle,
                color: Colors.green.shade400, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Payment Methods',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPaymentMethod,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add_card_rounded),
      ),
      body: _paymentMethods.isEmpty
          ? _buildEmptyState(context)
          : CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // ── Aapka existing info banner ──
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              color:
                                  Theme.of(context).colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Your payment information is secure and encrypted',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Aapka existing header ──
                      Text(
                        'Saved Payment Methods',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 16),
                    ]),
                  ),
                ),

                // ── Aapki existing payment method cards ──
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final method = _paymentMethods[index];
                        final isSelected =
                            _selectedMethodId == method['id'];
                        final isDefault = method['isDefault'] == true;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? Theme.of(context)
                                      .colorScheme
                                      .primary
                                  : Theme.of(context)
                                      .colorScheme
                                      .outline
                                      .withOpacity(0.1),
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              ListTile(
                                contentPadding:
                                    const EdgeInsets.fromLTRB(
                                        16, 12, 12, 12),
                                leading: Container(
                                  width: 44, height: 44,
                                  decoration: BoxDecoration(
                                    color: (method['color'] as Color)
                                        .withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    method['icon'] as IconData,
                                    color: method['color'] as Color,
                                    size: 22,
                                  ),
                                ),
                                title: Text(
                                  method['brand'] as String,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface,
                                  ),
                                ),
                                subtitle: method['type'] == 'credit_card'
                                    ? Text(
                                        '**** ${method['last4']}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.6),
                                        ),
                                      )
                                    : null,
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isDefault)
                                      Container(
                                        padding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade50,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          border: Border.all(
                                              color: Colors
                                                  .green.shade100),
                                        ),
                                        child: Text(
                                          'Default',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color:
                                                Colors.green.shade700,
                                          ),
                                        ),
                                      ),
                                    const SizedBox(width: 12),
                                    IconButton(
                                      onPressed: () =>
                                          _deletePaymentMethod(
                                              method['id'] as String),
                                      icon: Icon(
                                        Icons.delete_outline_rounded,
                                        color: Colors.red.shade600,
                                        size: 22,
                                      ),
                                      splashRadius: 20,
                                    ),
                                  ],
                                ),
                                onTap: () => setState(() =>
                                    _selectedMethodId =
                                        method['id'] as String),
                              ),
                              if (!isDefault)
                                Container(
                                  padding: const EdgeInsets.fromLTRB(
                                      16, 0, 16, 12),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton(
                                      onPressed: () => _setAsDefault(
                                          method['id'] as String),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor:
                                            Theme.of(context)
                                                .colorScheme
                                                .primary,
                                        side: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      child:
                                          const Text('Set as Default'),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                      childCount: _paymentMethods.length,
                    ),
                  ),
                ),

                // ════════════════════════════════════════════════
                // NAYA SECTION: Checkout Payment Options Toggle
                // ════════════════════════════════════════════════
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Section Header
                      Text(
                        'Checkout Payment Options',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),

                      // Info
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.orange.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline_rounded,
                                color: Colors.orange.shade600,
                                size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Enable or disable payment options shown at checkout.',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.orange.shade800),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Toggle list
                      Container(
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: _checkoutOptions.entries
                              .map((e) =>
                                  _buildToggleTile(e.key, e.value))
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 100),
                    ]),
                  ),
                ),
              ],
            ),
    );
  }

  // ── Toggle Tile (naya) ──────────────────────────────────────
  Widget _buildToggleTile(String method, bool isEnabled) {
    final Color color = _optionColors[method] ?? Colors.grey;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _optionIcons[method] ?? Iconsax.wallet_3,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              method,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: isEnabled,
              onChanged: (val) {
                setState(() => _checkoutOptions[method] = val);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(val
                        ? '$method enabled at checkout'
                        : '$method disabled'),
                    backgroundColor:
                        val ? Colors.green : Colors.orange,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              activeColor: color,
              activeTrackColor: color.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  // ── Aapka existing empty state — bilkul same ──
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120, height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.credit_card_off_rounded,
                size: 60,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.4),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Payment Methods',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Add a payment method to make purchases faster',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _addPaymentMethod,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(160, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Add Payment Method'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Aapka existing bottom sheet — bilkul same ──
class _AddPaymentMethodBottomSheet extends StatefulWidget {
  final Function(String) onCardAdded;
  const _AddPaymentMethodBottomSheet({required this.onCardAdded});

  @override
  State<_AddPaymentMethodBottomSheet> createState() =>
      _AddPaymentMethodBottomSheetState();
}

class _AddPaymentMethodBottomSheetState
    extends State<_AddPaymentMethodBottomSheet> {
  final TextEditingController _cardNumberController =
      TextEditingController();
  final TextEditingController _expiryController =
      TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.only(
        top: 20, left: 20, right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .outline
                    .withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'Add Payment Method',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Add a new credit or debit card',
            style: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),

          // Card Number
          TextField(
            controller: _cardNumberController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Card Number',
              hintText: '1234 5678 9012 3456',
              prefixIcon:
                  const Icon(Icons.credit_card_rounded),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            maxLength: 19,
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _expiryController,
                  keyboardType: TextInputType.datetime,
                  decoration: InputDecoration(
                    labelText: 'MM/YY',
                    hintText: '12/25',
                    prefixIcon: const Icon(
                        Icons.calendar_today_rounded),
                    border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(12)),
                  ),
                  maxLength: 5,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _cvvController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'CVV',
                    hintText: '123',
                    prefixIcon:
                        const Icon(Icons.lock_rounded),
                    border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(12)),
                  ),
                  maxLength: 3,
                  obscureText: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Cardholder Name
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Cardholder Name',
              hintText: 'John Doe',
              prefixIcon:
                  const Icon(Icons.person_outline_rounded),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12)),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final cardNumber =
                        _cardNumberController.text.trim();
                    if (cardNumber.length >= 4) {
                      final last4 = cardNumber.substring(
                          cardNumber.length - 4);
                      widget.onCardAdded(last4);
                    } else {
                      widget.onCardAdded('4242');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12)),
                  ),
                  child: const Text('Save Card'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}