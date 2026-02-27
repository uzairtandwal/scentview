import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class OrderDetailsScreen extends StatelessWidget {
  static const routeName = '/order-details';
  final Map<String, dynamic> order;

  const OrderDetailsScreen({super.key, required this.order});

  // ── Status color helper ────────────────────────────────────────────────────
  Color _statusColor(ThemeData theme) {
    final status = (order['status'] as String? ?? '').toLowerCase();
    return switch (status) {
      'delivered'  => const Color(0xFF2E7D32),
      'processing' => const Color(0xFF1565C0),
      'cancelled'  => theme.colorScheme.error,
      'shipped'    => const Color(0xFF6A1B9A),
      _            => const Color(0xFFE65100),
    };
  }

  IconData _statusIcon() {
    final status = (order['status'] as String? ?? '').toLowerCase();
    return switch (status) {
      'delivered'  => Iconsax.tick_circle,
      'processing' => Iconsax.clock,
      'cancelled'  => Iconsax.close_circle,
      'shipped'    => Iconsax.truck,
      _            => Iconsax.info_circle,
    };
  }

  void _openRefundSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _RefundSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme   = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final color   = (order['color'] as Color?) ?? _statusColor(theme);
    final status  = order['status'] as String? ?? 'Pending';
    final orderId = order['id']?.toString() ?? '';

    // Real items from order map — fallback to empty list
    final items = (order['items'] as List<dynamic>?) ?? [];
    final subtotal   = order['subtotal']   as String? ?? order['total'] as String? ?? '—';
    final delivery   = order['delivery']   as String? ?? 'PKR 200';
    final total      = order['total']      as String? ?? '—';
    final address    = order['address']    as String? ?? '—';
    final phone      = order['phone']      as String? ?? '';
    final customerName = order['customer'] as String? ?? '';

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Order #$orderId',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: theme.colorScheme.onSurface,
            letterSpacing: -0.3,
          ),
        ),
        leading: IconButton(
          icon: Icon(Iconsax.arrow_left_2,
              color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ── Status Card ───────────────────────────────────
            _StatusCard(
              status: status,
              color: color,
              icon: _statusIcon(),
              theme: theme,
            ),

            const SizedBox(height: 16),

            // ── Items ─────────────────────────────────────────
            _InfoCard(
              title: 'Items Summary',
              icon: Iconsax.box,
              theme: theme,
              child: items.isEmpty
                  ? Text(
                      'No items data available',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.5),
                        fontSize: 13,
                      ),
                    )
                  : Column(
                      children: items.map<Widget>((item) {
                        final name  = item['name']     as String? ?? '—';
                        final qty   = item['quantity'] as int?    ?? 1;
                        final price = item['price']    as String? ?? '—';
                        return _ItemRow(
                          name: name,
                          qty: qty,
                          price: price,
                          theme: theme,
                        );
                      }).toList(),
                    ),
            ),

            const SizedBox(height: 14),

            // ── Delivery Address ──────────────────────────────
            _InfoCard(
              title: 'Delivery Address',
              icon: Iconsax.location,
              theme: theme,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (customerName.isNotEmpty)
                    Text(
                      customerName,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  if (customerName.isNotEmpty) const SizedBox(height: 4),
                  Text(
                    address,
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.7),
                      height: 1.5,
                    ),
                  ),
                  if (phone.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      phone,
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── Bill Details ──────────────────────────────────
            _InfoCard(
              title: 'Bill Details',
              icon: Iconsax.receipt_1,
              theme: theme,
              child: Column(
                children: [
                  _PriceRow(
                    label: 'Subtotal',
                    value: subtotal,
                    theme: theme,
                  ),
                  const SizedBox(height: 8),
                  _PriceRow(
                    label: 'Delivery Fee',
                    value: delivery,
                    theme: theme,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Divider(
                      color: theme.colorScheme.outline.withValues(alpha: 0.15),
                    ),
                  ),
                  _PriceRow(
                    label: 'Total Amount',
                    value: total,
                    isTotal: true,
                    theme: theme,
                  ),
                ],
              ),
            ),

            // ── Refund Button (only for Delivered) ────────────
            if (status.toLowerCase() == 'delivered') ...[
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () => _openRefundSheet(context),
                icon: Icon(
                  Iconsax.refresh_circle,
                  color: theme.colorScheme.error,
                  size: 18,
                ),
                label: Text(
                  'Request Refund / Return',
                  style: TextStyle(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  side: BorderSide(
                    color: theme.colorScheme.error.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ─── Status Card ──────────────────────────────────────────────────────────────
class _StatusCard extends StatelessWidget {
  final String status;
  final Color color;
  final IconData icon;
  final ThemeData theme;

  const _StatusCard({
    required this.status,
    required this.color,
    required this.icon,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order Status',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                status,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Info Card ────────────────────────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final ThemeData theme;

  const _InfoCard({
    required this.title,
    required this.icon,
    required this.child,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final primary = theme.colorScheme.primary;
    return Container(
      width: double.infinity,
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
          Row(
            children: [
              Icon(icon, size: 16, color: primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: primary,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

// ─── Item Row ─────────────────────────────────────────────────────────────────
class _ItemRow extends StatelessWidget {
  final String name;
  final int qty;
  final String price;
  final ThemeData theme;

  const _ItemRow({
    required this.name,
    required this.qty,
    required this.price,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$name × $qty',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),
          Text(
            price,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Price Row ────────────────────────────────────────────────────────────────
class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;
  final ThemeData theme;

  const _PriceRow({
    required this.label,
    required this.value,
    required this.theme,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            fontSize: isTotal ? 15 : 13,
            color: isTotal
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: isTotal ? 18 : 13,
            color: isTotal
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withValues(alpha: 0.8),
            letterSpacing: isTotal ? -0.3 : 0,
          ),
        ),
      ],
    );
  }
}

// ─── Refund Sheet (StatefulWidget — reason selection) ─────────────────────────
class _RefundSheet extends StatefulWidget {
  const _RefundSheet();

  @override
  State<_RefundSheet> createState() => _RefundSheetState();
}

class _RefundSheetState extends State<_RefundSheet> {
  int? _selectedReason;
  final _detailsCtrl = TextEditingController();
  bool _isSubmitting = false;

  static const _reasons = [
    'Item was damaged',
    'Wrong perfume received',
    'Not satisfied with quality',
    'Seal was broken on delivery',
    'Other',
  ];

  @override
  void dispose() {
    _detailsCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a reason'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Refund request submitted successfully!'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF2E7D32),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final error = theme.colorScheme.error;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Iconsax.refresh_circle,
                              color: error, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Refund Request',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Text(
                      'SELECT REASON',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: primary,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Reason options
                    ..._reasons.asMap().entries.map((entry) {
                      final isSelected = _selectedReason == entry.key;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedReason = entry.key),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? error.withValues(alpha: 0.06)
                                : theme.colorScheme.surfaceContainerHighest
                                    .withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? error.withValues(alpha: 0.4)
                                  : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected
                                    ? Iconsax.tick_circle
                                    : Iconsax.record_circle,
                                size: 18,
                                color: isSelected
                                    ? error
                                    : theme.colorScheme.onSurface
                                        .withValues(alpha: 0.4),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                entry.value,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: isSelected
                                      ? error
                                      : theme.colorScheme.onSurface
                                          .withValues(alpha: 0.75),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 16),

                    // Extra details
                    Text(
                      'ADDITIONAL DETAILS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: primary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _detailsCtrl,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Describe your issue in detail...',
                        hintStyle: TextStyle(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.35),
                          fontSize: 13,
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.4),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                              color: primary, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.all(14),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Submit button
            Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                0,
                24,
                MediaQuery.paddingOf(context).bottom + 20,
              ),
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: error,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Submit Request',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}