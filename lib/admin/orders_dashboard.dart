import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:iconsax/iconsax.dart';
import '../../models/order.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_egg_loader.dart';

class AdminOrdersDashboard extends StatefulWidget {
  static const String routeName = '/admin/orders';
  const AdminOrdersDashboard({Key? key}) : super(key: key);

  @override
  State<AdminOrdersDashboard> createState() => _AdminOrdersDashboardState();
}

class _AdminOrdersDashboardState extends State<AdminOrdersDashboard> {
  final ApiService _apiService = ApiService();
  late Future<List<Order>> _ordersFuture;

  // Luxury Theme Colors
  static const Color _bgBlack = Color(0xFF0F0F0F);
  static const Color _cardBlack = Color(0xFF1A1A1A);
  static const Color _gold = Color(0xFFFFD700);
  static const Color _textGold = Color(0xFFC5A059);
  static const Color _textWhite = Colors.white;
  static const Color _textGray = Color(0xFF9E9E9E);

  @override
  void initState() {
    super.initState();
    _ordersFuture = _apiService.fetchAdminOrders();
  }

  void _refreshOrders() {
    setState(() {
      _ordersFuture = _apiService.fetchAdminOrders();
    });
  }

  Future<void> _updateStatus(String orderId, String newStatus) async {
    try {
      await _apiService.updateOrderStatus(orderId, newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order $orderId status updated to $newStatus'),
            backgroundColor: Colors.green,
          ),
        );
        _refreshOrders();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgBlack,
      appBar: AppBar(
        backgroundColor: _bgBlack,
        elevation: 0,
        title: const Text(
          'Orders Dashboard',
          style: TextStyle(
            color: _gold,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        iconTheme: const IconThemeData(color: _gold),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.refresh, color: _gold),
            onPressed: _refreshOrders,
          ),
        ],
      ),
      body: FutureBuilder<List<Order>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CustomEggLoader(size: 80, color: _gold));
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Iconsax.danger, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: _textWhite),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _refreshOrders,
                    style: ElevatedButton.styleFrom(backgroundColor: _gold),
                    child: const Text('Retry', style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No orders found',
                style: TextStyle(color: _textGray, fontSize: 18),
              ),
            );
          }

          final orders = snapshot.data!;
          
          // Manual Calculation for Summary Cards
          double totalRevenue = 0;
          int activeOrders = 0;
          for (var order in orders) {
            totalRevenue += order.total;
            if (order.status.toLowerCase() != 'completed' && 
                order.status.toLowerCase() != 'cancelled') {
              activeOrders++;
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Cards
                _buildSummaryCards(totalRevenue, activeOrders, orders.length),
                
                const SizedBox(height: 32),
                
                const Text(
                  'ORDER LIST',
                  style: TextStyle(
                    color: _gold,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Orders Table
                _buildOrdersTable(orders),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCards(double revenue, int active, int total) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Revenue',
            'Rs ${revenue.toStringAsFixed(0)}',
            Iconsax.money_3,
            const Color(0xFFC5A059),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Active Orders',
            active.toString(),
            Iconsax.timer_1,
            const Color(0xFFC5A059),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Total Count',
            total.toString(),
            Iconsax.bag_tick,
            const Color(0xFFC5A059),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBlack,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _gold.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _gold, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: _textWhite,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: _textGray,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersTable(List<Order> orders) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _cardBlack,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _gold.withOpacity(0.1), width: 1),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(_bgBlack),
          headingTextStyle: const TextStyle(
            color: _gold,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          dataTextStyle: const TextStyle(color: _textWhite, fontSize: 13),
          columnSpacing: 24,
          horizontalMargin: 20,
          columns: const [
            DataColumn(label: Text('ID')),
            DataColumn(label: Text('Customer')),
            DataColumn(label: Text('Amount')),
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Action')),
          ],
          rows: orders.map((order) => _buildOrderRow(order)).toList(),
        ),
      ),
    );
  }

  DataRow _buildOrderRow(Order order) {
    final dateStr = DateFormat('dd MMM yyyy').format(order.createdAt);
    
    return DataRow(
      cells: [
        DataCell(Text('#${order.id}', style: const TextStyle(color: _gold, fontWeight: FontWeight.bold))),
        DataCell(Text(order.shippingAddress.split(',').first)), // Showing first part of address as name surrogate if name not direct
        DataCell(Text('Rs ${order.total.toStringAsFixed(0)}')),
        DataCell(Text(dateStr)),
        DataCell(_buildStatusBadge(order.status)),
        DataCell(
          DropdownButton<String>(
            dropdownColor: _cardBlack,
            icon: const Icon(Icons.arrow_drop_down, color: _gold),
            underline: const SizedBox(),
            value: ['Pending', 'Processing', 'Shipped', 'Completed', 'Cancelled']
                    .contains(order.status) ? order.status : 'Pending',
            items: ['Pending', 'Processing', 'Shipped', 'Completed', 'Cancelled']
                .map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: const TextStyle(color: _textWhite, fontSize: 12)),
              );
            }).toList(),
            onChanged: (newValue) {
              if (newValue != null && newValue != order.status) {
                _updateStatus(order.id, newValue);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'completed':
        color = Colors.green;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'processing':
        color = Colors.blue;
        break;
      case 'shipped':
        color = Colors.purple;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = _gold;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
