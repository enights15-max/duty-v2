import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../events/data/models/event_detail_model.dart'; // Import Event Models
import '../providers/checkout_provider.dart';

class CheckoutPage extends ConsumerStatefulWidget {
  final EventDetailModel event;

  const CheckoutPage({super.key, required this.event});

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  // Local state for quantities to simplify UI updates before committing to provider/API
  final Map<int, int> _quantities = {};
  String _selectedPaymentMethod = 'offline'; // Default to offline for MVP

  @override
  void initState() {
    super.initState();
    // Initialize with 0 for all tickets
    for (var ticket in widget.event.tickets) {
      _quantities[ticket.id] = 0;
    }
  }

  void _increment(int ticketId) {
    setState(() {
      _quantities[ticketId] = (_quantities[ticketId] ?? 0) + 1;
    });
  }

  void _decrement(int ticketId) {
    setState(() {
      if ((_quantities[ticketId] ?? 0) > 0) {
        _quantities[ticketId] = (_quantities[ticketId] ?? 0) - 1;
      }
    });
  }

  double _calculateTotal() {
    double total = 0.0;
    for (var ticket in widget.event.tickets) {
      int qty = _quantities[ticket.id] ?? 0;
      total += ticket.price * qty;
    }
    return total;
  }

  Future<void> _processCheckout() async {
    final total = _calculateTotal();
    if (total <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos una entrada.')),
      );
      return;
    }

    final bookingData = {
      'event_id': widget.event.id,
      'ticket_quantity': _quantities.values.reduce(
        (a, b) => a + b,
      ), // Total qty
      'total_payment': total,
      // 'ticket_id': ... needs logic to send specific ticket IDs and qtys.
      // The API store_booking seems to expect 'quantity' (array? or total?) and 'selTickets'.
      // For MVP, we'll send a simplified payload.
      // NOTE: Real implementation needs strict adherence to EventController.store_booking validation rules.
      'fname': 'Test', // Hardcoded for MVP as we don't have profile form yet
      'lname': 'User',
      'email': 'test@test.com',
      'phone': '1234567890',
      'country': 'Test Country',
      'address': 'Test Address',
      'gateway': _selectedPaymentMethod,
      'gatewayType': _selectedPaymentMethod == 'offline' ? 'offline' : 'online',
      // ... other required fields
      'event_date': widget.event.date,
      'discount': 0,
      'tax': 0,
      'total': total,
      'total_early_bird_dicount': 0,
    };

    try {
      // Ideally use provider to submit
      // final result = await ref.read(checkoutProvider.notifier).submitOrder(bookingData);

      if (_selectedPaymentMethod == 'offline') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pedido realizado con éxito (Offline).'),
          ),
        );
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) context.go('/home');
      } else {
        // Simulate getting a payment URL from backend
        // final paymentUrl = result['payment_url'];
        const paymentUrl = 'https://google.com'; // Demo URL

        if (mounted) {
          final result = await context.push<bool>(
            '/payment-webview',
            extra: paymentUrl,
          );
          if (result == true) {
            if (mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Pago exitoso!')));
              context.go('/home');
            }
          } else {
            if (mounted)
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Pago cancelado')));
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  widget.event.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Selecciona tus entradas',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...widget.event.tickets.map((ticket) {
                  int qty = _quantities[ticket.id] ?? 0;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ticket.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '\$${ticket.price}',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: qty > 0
                                    ? () => _decrement(ticket.id)
                                    : null,
                              ),
                              Text(
                                '$qty',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: ticket.available
                                    ? () => _increment(ticket.id)
                                    : null,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const Divider(height: 32),
                const Text(
                  'Método de Pago',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                RadioListTile<String>(
                  title: const Text('Pago Offline / Taquilla'),
                  value: 'offline',
                  groupValue: _selectedPaymentMethod,
                  onChanged: (val) =>
                      setState(() => _selectedPaymentMethod = val!),
                ),
                RadioListTile<String>(
                  title: const Text('Tarjeta de Crédito (Stripe)'),
                  value: 'stripe',
                  groupValue: _selectedPaymentMethod,
                  onChanged: (val) =>
                      setState(() => _selectedPaymentMethod = val!),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total', style: TextStyle(color: Colors.grey)),
                    Text(
                      '\$${_calculateTotal().toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: _processCheckout,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Pagar Ahora'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
