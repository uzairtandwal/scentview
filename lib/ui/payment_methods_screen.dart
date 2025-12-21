import 'package:flutter/material.dart';

class PaymentMethodsScreen extends StatefulWidget {
  static const routeName = '/payment-methods';
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final List<Map<String, String>> _methods = [
    {'brand': 'Visa', 'last4': '4242'},
  ];

  void _addMethod() async {
    final ctrl = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Card (Dummy)'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Enter last 4 digits'),
          maxLength: 4,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null && result.length == 4) {
      setState(() => _methods.add({'brand': 'Card', 'last4': result}));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Methods')),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMethod,
        child: const Icon(Icons.add_card_rounded),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _methods.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final m = _methods[index];
          return Card(
            child: ListTile(
              leading: const Icon(Icons.credit_card),
              title: Text('${m['brand']} **** ${m['last4']}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => setState(() => _methods.removeAt(index)),
              ),
            ),
          );
        },
      ),
    );
  }
}
