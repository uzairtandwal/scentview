import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/orders_service.dart';
import '../models/order.dart';

class MyOrdersScreen extends StatefulWidget {
  static const routeName = '/my-orders';
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<OrdersService>().load());
  }

  @override
  Widget build(BuildContext context) {
    final ordersSvc = context.watch<OrdersService>();
    final orders = ordersSvc.orders;
    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: orders.isEmpty
          ? const Center(child: Text('No orders yet'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: const [
                    _SummaryCard(title: 'Total Orders', valueKey: 'total'),
                    SizedBox(width: 12),
                    _SummaryCard(title: 'Pending', valueKey: 'pending'),
                  ],
                ),
                const SizedBox(height: 16),
                ...orders.map((o) => _OrderCard(order: o)),
              ],
            ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String valueKey; // 'total' or 'pending'
  const _SummaryCard({required this.title, required this.valueKey});

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<OrdersService>();
    final orders = svc.orders;
    final int value = valueKey == 'pending'
        ? orders.where((o) => o.status == 'Placed').length
        : orders.length;
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Card(
        color: cs.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 6),
              Text(
                '$value',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: cs.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '#${order.id}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: cs.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.status,
                    style: TextStyle(
                      color: cs.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${order.createdAt.toLocal()}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 60,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: order.items.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final it = order.items[index];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: it.imageUrl != null && it.imageUrl!.isNotEmpty
                        ? (it.imageUrl!.startsWith('http')
                              ? Image.network(
                                  it.imageUrl!,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(
                                  it.imageUrl!,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ))
                        : Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.image, color: Colors.grey),
                          ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${order.items.length} items'),
                Text(
                  '\$${order.total.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
