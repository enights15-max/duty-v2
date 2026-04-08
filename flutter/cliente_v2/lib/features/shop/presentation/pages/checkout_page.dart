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

  final TextEditingController _couponController = TextEditingController();

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

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

<<<<<<< Updated upstream
      if (_selectedPaymentMethod == 'offline') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pedido realizado con éxito (Offline).'),
          ),
=======
      final bookingData = {
        'event_id': widget.event.id,
        'quantity': quantityCout,
        'total_payment': total,
        'fname': currentUser['fname'] ?? 'Guest',
        'lname': currentUser['lname'] ?? '',
        'email': currentUser['email'] ?? 'guest@duty.do',
        'phone': currentUser['phone'] ?? '',
        'customer_id':
            currentUser['id'], // Critical for linking booking to user
        'country': currentUser['country'] ?? 'Domincan Republic',
        'address': currentUser['address'] ?? 'Santo Domingo',
        'city': currentUser['city'] ?? '',
        'state': currentUser['state'] ?? '',
        'zip_code': currentUser['zip_code'] ?? '',
        'gatewayType': 'online',
        'event_date': widget.event.date,
        'discount': checkoutState.discountAmount,
        'coupon_code': checkoutState.appliedCouponCode ?? '',
        'tax': 0,
        'total': total,
        'total_early_bird_dicount': 0,
      };

      if (fundingBreakdown.requiresCard &&
          checkoutState.selectedCardId == null) {
        throw Exception(
          'Selecciona una tarjeta guardada o agrega una nueva antes de pagar.',
>>>>>>> Stashed changes
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
  Widget _buildCouponSection(CheckoutState state) {
    if (state.appliedCouponCode != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: Colors.greenAccent.withAlpha((255 * 0.1).toInt()),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.greenAccent.withAlpha((255 * 0.3).toInt()),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.greenAccent, size: 20),
                const SizedBox(width: 8),
                Text(
                  "Cupón aplicado: ${state.appliedCouponCode}",
                  style: GoogleFonts.splineSans(
                    color: Colors.greenAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                _couponController.clear();
                ref.read(checkoutProvider.notifier).removeCoupon();
              },
              child: const Icon(Icons.close, color: Colors.white70, size: 20),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _couponController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Código promocional",
                hintStyle: TextStyle(color: Colors.grey[600]),
                filled: true,
                fillColor: Colors.white.withAlpha((255 * 0.05).toInt()),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              if (_couponController.text.trim().isEmpty) return;
              FocusScope.of(context).unfocus();
              ref.read(checkoutProvider.notifier).applyCoupon(
                _couponController.text.trim(),
                widget.event.id,
                0.0,
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: kPrimaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "Aplicar",
                style: GoogleFonts.splineSans(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
<<<<<<< Updated upstream
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
=======
                          Text(
                            "Select Tickets",
                            style: GoogleFonts.splineSans(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      ...widget.event.tickets.map((ticket) {
                        final qty =
                            ref
                                .watch(checkoutProvider)
                                .selectedTickets[ticket.id] ??
                            0;
                        return _TicketCard(
                          ticket: ticket,
                          qty: qty,
                          onIncrement: () => _increment(ticket.id),
                          onDecrement: () => _decrement(ticket.id),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Sticky Bottom Bar
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _StickyBottomBar(
            total: total,
            btnText: "Checkout",
            onTap: _goToPayment,
          ),
        ),
      ],
    );
  }

  // --- Step 2: Payment Checkout ---
  Widget _buildPaymentStep(BuildContext context, CheckoutState state) {
    final fundingBreakdown = calculateFundingBreakdown(
      state,
      state.totalAmount,
    );

    return SafeArea(
      child: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    _GlassIconButton(
                      icon: Icons.arrow_back,
                      onTap: () => ref
                          .read(checkoutProvider.notifier)
                          .goToStep(CheckoutStep.selection),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      "Checkout (2/3)",
                      style: GoogleFonts.splineSans(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Progress
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 4,
                            width: 30,
                            decoration: BoxDecoration(
                              color: kPrimaryColor.withAlpha(
                                (255 * 0.3).toInt(),
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            height: 4,
                            width: 30,
                            decoration: BoxDecoration(
                              color: kPrimaryColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            height: 4,
                            width: 30,
                            decoration: BoxDecoration(
                              color: kPrimaryColor.withAlpha(
                                (255 * 0.3).toInt(),
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      Text(
                        "ORDER SUMMARY",
                        style: GoogleFonts.splineSans(
                          color: Colors.grey[500],
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Order Summary Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E192D),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withAlpha((255 * 0.05).toInt()),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: CachedNetworkImage(
                                    imageUrl:
                                        widget.event.coverImage ??
                                        widget.event.thumbnail,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorWidget: (_, _, _) => Container(
                                      width: 80,
                                      height: 80,
                                      color: Colors.grey[850],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.event.title,
                                        style: GoogleFonts.splineSans(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        widget.event.date ?? '',
                                        style: GoogleFonts.splineSans(
                                          color: Colors.grey[400],
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "${widget.event.tickets.fold<int>(0, (sum, ticket) => sum + (state.selectedTickets[ticket.id] ?? 0))}x Tickets",
                                        style: GoogleFonts.splineSans(
                                          color: kPrimaryColor,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            const Divider(color: Colors.white10),
                            const SizedBox(height: 10),
                            _SummaryRow(
                              label: "Subtotal",
                              value:
                                  "\$${state.totalAmount.toStringAsFixed(2)}",
                            ),
                            if (state.appliedCouponCode != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: _SummaryRow(
                                  label: "Descuento (Cupón)",
                                  value:
                                      "- \$${state.discountAmount.toStringAsFixed(2)}",
                                ),
                              ),
                            if (state.applyBonusBalance)
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: _SummaryRow(
                                  label: "Bonus aplicado",
                                  value:
                                      "- \$${fundingBreakdown.bonusApplied.toStringAsFixed(2)}",
                                ),
                              ),
                            if (state.applyWalletBalance)
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: _SummaryRow(
                                  label: "Wallet aplicado",
                                  value:
                                      "- \$${fundingBreakdown.walletApplied.toStringAsFixed(2)}",
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: _SummaryRow(
                                label: fundingBreakdown.requiresCard
                                    ? "Saldo a tarjeta"
                                    : "Saldo restante",
                                value:
                                    "\$${fundingBreakdown.cardAmount.toStringAsFixed(2)}",
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Total",
                                  style: GoogleFonts.splineSans(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  fundingBreakdown.requiresCard
                                      ? "\$${fundingBreakdown.cardAmount.toStringAsFixed(2)}"
                                      : "Cubierto",
                                  style: GoogleFonts.splineSans(
                                    color: kPrimaryColor,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),
                      Text(
                        "PAYMENT OPTIONS",
                        style: GoogleFonts.splineSans(
                          color: Colors.grey[500],
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Payment Methods
                      _PaymentOption(
                        icon: Icons.local_activity_outlined,
                        title: "Bono Duty",
                        subtitle:
                            "Disponible: \$${state.bonusBalance.toStringAsFixed(2)}",
                        isSelected: state.applyBonusBalance,
                        onTap: () => ref
                            .read(checkoutProvider.notifier)
                            .toggleBonusBalance(!state.applyBonusBalance),
                      ),
                      const SizedBox(height: 12),
                      _PaymentOption(
                        icon: Icons.account_balance_wallet,
                        title: "DUTY Wallet",
                        subtitle:
                            "Disponible: \$${state.walletBalance.toStringAsFixed(2)}",
                        isSelected: state.applyWalletBalance,
                        onTap: () => ref
                            .read(checkoutProvider.notifier)
                            .toggleWalletBalance(!state.applyWalletBalance),
                      ),
                      const SizedBox(height: 12),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha((255 * 0.03).toInt()),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withAlpha((255 * 0.06).toInt()),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              fundingBreakdown.requiresCard
                                  ? Icons.credit_card
                                  : Icons.check_circle_outline,
                              color: fundingBreakdown.requiresCard
                                  ? Colors.amberAccent
                                  : Colors.greenAccent,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                fundingBreakdown.requiresCard
                                    ? 'El checkout usará primero bono y wallet. La tarjeta solo cubrirá el remanente de \$${fundingBreakdown.cardAmount.toStringAsFixed(2)}.'
                                    : 'La compra queda totalmente cubierta con saldo interno. No se cargará tarjeta.',
                                style: GoogleFonts.splineSans(
                                  color: Colors.grey[300],
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      Text(
                        "CARD FOR REMAINING BALANCE",
                        style: GoogleFonts.splineSans(
                          color: Colors.grey[500],
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Saved Cards Section
                      ...state.savedCards.map((card) {
                        final isSelected = state.selectedCardId == card.id;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: _PaymentOption(
                            icon: Icons.credit_card,
                            title: "${card.brand} ending in ${card.last4}",
                            subtitle: fundingBreakdown.requiresCard
                                ? "Expires ${card.expiry} · Remanente \$${fundingBreakdown.cardAmount.toStringAsFixed(2)}"
                                : "Expires ${card.expiry}",
                            isSelected: isSelected,
                            onTap: () => ref
                                .read(checkoutProvider.notifier)
                                .selectCard(card.id),
                          ),
                        );
                      }),

                      // Pay with new Card Option
                      GestureDetector(
                        onTap: () async {
                          await ref
                              .read(checkoutProvider.notifier)
                              .addNewCard(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: state.selectedCardId == 'new_card'
                                ? kPrimaryColor.withAlpha((255 * 0.1).toInt())
                                : Colors.white.withAlpha((255 * 0.02).toInt()),
                            border: Border.all(
                              color: state.selectedCardId == 'new_card'
                                  ? kPrimaryColor
                                  : Colors.white.withAlpha(
                                      (255 * 0.05).toInt(),
                                    ),
                              style: BorderStyle.solid,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
>>>>>>> Stashed changes
                            children: [
                              Text(
                                ticket.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
<<<<<<< Updated upstream
                              Text(
                                '\$${ticket.price}',
                                style: const TextStyle(color: Colors.grey),
=======
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Add New Card",
                                    style: GoogleFonts.splineSans(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (state.selectedCardId == 'new_card')
                                    Text(
                                      "Pay via secure payment sheet",
                                      style: GoogleFonts.splineSans(
                                        color: kPrimaryColor,
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                              const Spacer(),
                              if (state.selectedCardId == 'new_card')
                                const Icon(
                                  Icons.check_circle,
                                  color: kPrimaryColor,
                                ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Coupon Input
                      _buildCouponSection(state),

                      /* Temporarily hidden
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.all(16),
...
                      ),
                      */
                      const SizedBox(height: 100), // Space for bottom bar
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Builder(
              builder: (context) {
                return _StickyBottomBar(
                  total: fundingBreakdown.requiresCard
                      ? fundingBreakdown.cardAmount
                      : state.totalAmount,
                  btnText: fundingBreakdown.requiresCard
                      ? "Confirmar y pagar"
                      : "Confirmar compra",
                  onTap: _processCheckout,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- Step 3: Order Confirmation ---
  Widget _buildConfirmationStep(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(color: kBackgroundColor),
      child: Stack(
        children: [
          // Ambient Glow
          Positioned(
            top: -50,
            left: -50,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: kPrimaryColor.withAlpha((255 * 0.2).toInt()),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Success Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: kPrimaryColor.withAlpha((255 * 0.1).toInt()),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: kPrimaryColor.withAlpha((255 * 0.5).toInt()),
                      ),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: kPrimaryColor,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Order Confirmed",
                    style: GoogleFonts.splineSans(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "You're in! Transaction complete.",
                    style: GoogleFonts.splineSans(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Golden Ticket
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(
                        0xFF162E24,
                      ), // Dark Green/Black mix for ticket
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withAlpha((255 * 0.1).toInt()),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha((255 * 0.5).toInt()),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Ticket Image
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                          child: SizedBox(
                            height: 180,
                            width: double.infinity,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                CachedNetworkImage(
                                  imageUrl: widget.event.thumbnail,
                                  fit: BoxFit.cover,
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.cover,
                                            colorFilter: ColorFilter.mode(
                                              Colors.black.withValues(
                                                alpha: 0.2,
                                              ),
                                              BlendMode.darken,
                                            ),
                                          ),
                                        ),
                                      ),
                                ),
                                const Positioned(
                                  bottom: 16,
                                  left: 16,
                                  child: Text(
                                    "VIP ACCESS",
                                    style: TextStyle(
                                      color: kPrimaryColor,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5,
                                      backgroundColor: Colors.black45,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "DATE",
                                        style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 10,
                                        ),
                                      ),
                                      Text(
                                        widget.event.date ?? "TBA",
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        "TIME",
                                        style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 10,
                                        ),
                                      ),
                                      Text(
                                        widget.event.time ?? "TBA",
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              // Perforation
                              Row(
                                children: List.generate(
                                  15,
                                  (index) => Expanded(
                                    child: Container(
                                      height: 2,
                                      color: Colors.white10,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              // QR Placeholder
                              Container(
                                width: 100,
                                height: 100,
                                color: Colors.white,
                                child: Center(
                                  child: Icon(
                                    Icons.qr_code_2,
                                    size: 80,
                                    color: Colors.black,
                                  ),
                                ),
>>>>>>> Stashed changes
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
