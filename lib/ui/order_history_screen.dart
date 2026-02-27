import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import 'order_details_screen.dart';

class OrderHistoryScreen extends StatelessWidget {
  static const routeName = '/order-history';
  const OrderHistoryScreen({super.key});

  // ── Demo orders — replace with OrdersService in production ───────────────
  static final List<Map<String, dynamic>> _orders = [
    {
      'id': 'ORD-9921',
      'date': '12 Feb 2026',
      'status': 'Delivered',
      'total': 'PKR 12,500',
      'subtotal': 'PKR 12,300',
      'delivery': 'PKR 200',
      'items': [
        {'name': 'Dior Sauvage', 'quantity': 1, 'price': 'PKR 8,500'},
        {'name': 'Chanel Bleu', 'quantity': 1, 'price': 'PKR 4,000'},
      ],
      'customer': 'Uzair Ali',
      'address': 'House #123, Scent Street, Lahore',
      'phone': '+92 300 1234567',
      'trackingSteps': [
        {'title': 'Order Placed', 'sub': 'We received your order', 'done': true},
        {'title': 'Confirmed', 'sub': 'Payment verified', 'done': true},
        {'title': 'Shipped', 'sub': 'Out for delivery', 'done': true},
        {'title': 'Delivered', 'sub': 'Order completed', 'done': true},
      ],
    },
    {
      'id': 'ORD-8852',
      'date': '05 Feb 2026',
      'status': 'Processing',
      'total': 'PKR 8,200',
      'subtotal': 'PKR 8,000',
      'delivery': 'PKR 200',
      'items': [
        {'name': 'Versace Eros', 'quantity': 1, 'price': 'PKR 8,000'},
      ],
      'customer': 'Uzair Ali',
      'address': 'House #123, Scent Street, Lahore',
      'phone': '+92 300 1234567',
      'trackingSteps': [
        {'title': 'Order Placed', 'sub': 'We received your order', 'done': true},
        {'title': 'Confirmed', 'sub': 'Payment verified', 'done': true},
        {'title': 'Shipped', 'sub': 'On the way', 'done': false},
        {'title': 'Delivered', 'sub': 'Awaiting delivery', 'done': false},
      ],
    },
    {
      'id': 'ORD-7710',
      'date': '28 Jan 2026',
      'status': 'Cancelled',
      'total': 'PKR 15,000',
      'subtotal': 'PKR 14,800',
      'delivery': 'PKR 200',
      'items': [
        {'name': 'Tom Ford Noir', 'quantity': 1, 'price': 'PKR 14,800'},
      ],
      'customer': 'Uzair Ali',
      'address': 'House #123, Scent Street, Lahore',
      'phone': '+92 300 1234567',
      'trackingSteps': [
        {'title': 'Order Placed', 'sub': 'We received your order', 'done': true},
        {'title': 'Confirmed', 'sub': 'Payment verified', 'done': false},
        {'title': 'Shipped', 'sub': 'Order cancelled', 'done': false},
        {'title': 'Delivered', 'sub': '—', 'done': false},
      ],
    },
  ];

  // ── Status helpers ────────────────────────────────────────────────────────
  Color _statusColor(String status, ThemeData theme) =>
      switch (status.toLowerCase()) {
        'delivered'  => const Color(0xFF2E7D32),
        'processing' => const Color(0xFF1565C0),
        'shipped'    => const Color(0xFF6A1B9A),
        'cancelled'  => theme.colorScheme.error,
        _            => const Color(0xFFE65100),
      };

  IconData _statusIcon(String status) =>
      switch (status.toLowerCase()) {
        'delivered'  => Iconsax.tick_circle,
        'processing' => Iconsax.clock,
        'shipped'    => Iconsax.truck,
        'cancelled'  => Iconsax.close_circle,
        _            => Iconsax.info_circle,
      };

  void _showTracking(BuildContext context, Map<String, dynamic> order) {
    final theme = Theme.of(context);
    final steps = order['trackingSteps'] as List;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TrackingSheet(
        orderId: order['id'] as String,
        steps: steps,
        theme: theme,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Order History',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20,
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
      body: _orders.isEmpty
          ? _EmptyState(theme: theme)
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              itemCount: _orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (_, i) {
                final order = _orders[i];
                final color =
                    _statusColor(order['status'] as String, theme);
                return _OrderCard(
                  order: order,
                  statusColor: color,
                  statusIcon: _statusIcon(order['status'] as String),
                  theme: theme,
                  onTrack: () => _showTracking(context, order),
                  onViewDetails: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderDetailsScreen(
                        order: {...order, 'color': color},
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// ─── Order Card ───────────────────────────────────────────────────────────────
class _OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final Color statusColor;
  final IconData statusIcon;
  final ThemeData theme;
  final VoidCallback onTrack;
  final VoidCallback onViewDetails;

  const _OrderCard({
    required this.order,
    required this.statusColor,
    required this.statusIcon,
    required this.theme,
    required this.onTrack,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final items = order['items'] as List<dynamic>;
    final itemsLabel = items
        .map((i) => i['name'] as String)
        .join(', ');

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top row: ID + Status badge ──────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order['id'] as String,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: theme.colorScheme.onSurface,
                    letterSpacing: -0.2,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 12, color: statusColor),
                      const SizedBox(width: 5),
                      Text(
                        order['status'] as String,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Divider(
                height: 1,
                color: theme.colorScheme.outline.withValues(alpha: 0.1),
              ),
            ),

            // ── Items ───────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Iconsax.box, size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    itemsLabel,
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.65),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // ── Date ────────────────────────────────────────
            Row(
              children: [
                Icon(Iconsax.calendar_1, size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                const SizedBox(width: 8),
                Text(
                  order['date'] as String,
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.onSurface
                        .withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // ── Bottom row: Total + Buttons ─────────────────
            Row(
              children: [
                Text(
                  order['total'] as String,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                    color: theme.colorScheme.primary,
                    letterSpacing: -0.3,
                  ),
                ),
                const Spacer(),

                // View Details
                OutlinedButton(
                  onPressed: onViewDetails,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    side: BorderSide(
                      color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    ),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    minimumSize: Size.zero,
                  ),
                  child: Text(
                    'Details',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.7),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Track Order
                ElevatedButton(
                  onPressed: onTrack,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    minimumSize: Size.zero,
                  ),
                  child: const Text(
                    'Track',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tracking Sheet ───────────────────────────────────────────────────────────
class _TrackingSheet extends StatelessWidget {
  final String orderId;
  final List<dynamic> steps;
  final ThemeData theme;

  const _TrackingSheet({
    required this.orderId,
    required this.steps,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final primary = theme.colorScheme.primary;
    final doneColor = const Color(0xFF2E7D32);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.paddingOf(context).bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
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
          const SizedBox(height: 20),

          // Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Iconsax.truck, size: 18, color: primary),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Track Order',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                  Text(
                    orderId,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Steps
          ...steps.asMap().entries.map((entry) {
            final i      = entry.key;
            final step   = entry.value as Map;
            final isDone = step['done'] as bool;
            final isLast = i == steps.length - 1;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timeline column
                SizedBox(
                  width: 28,
                  child: Column(
                    children: [
                      // Circle
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: isDone
                              ? doneColor.withValues(alpha: 0.12)
                              : theme.colorScheme.surfaceContainerHighest,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDone
                                ? doneColor.withValues(alpha: 0.5)
                                : theme.colorScheme.outline
                                    .withValues(alpha: 0.2),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          isDone
                              ? Iconsax.tick_circle
                              : Iconsax.record_circle,
                          size: 14,
                          color: isDone
                              ? doneColor
                              : theme.colorScheme.onSurface
                                  .withValues(alpha: 0.3),
                        ),
                      ),
                      // Connector — not on last item
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 36,
                          margin: const EdgeInsets.symmetric(vertical: 2),
                          color: isDone
                              ? doneColor.withValues(alpha: 0.3)
                              : theme.colorScheme.outline
                                  .withValues(alpha: 0.15),
                        ),
                    ],
                  ),
                ),

                const SizedBox(width: 14),

                // Step text
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step['title'] as String,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: isDone
                                ? theme.colorScheme.onSurface
                                : theme.colorScheme.onSurface
                                    .withValues(alpha: 0.4),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          step['sub'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: isDone ? 0.55 : 0.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final ThemeData theme;
  const _EmptyState({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Iconsax.bag,
                size: 36,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No orders yet',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your order history will\nappear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}