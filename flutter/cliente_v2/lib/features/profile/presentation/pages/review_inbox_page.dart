import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/colors.dart';
import '../../data/models/review_prompt_model.dart';
import '../providers/review_prompt_provider.dart';

class ReviewInboxPage extends ConsumerWidget {
  const ReviewInboxPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final promptsAsync = ref.watch(pendingReviewPromptsProvider);

    return Scaffold(
      backgroundColor: kBackgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(
          'Reviews pendientes',
          style: GoogleFonts.splineSans(fontWeight: FontWeight.w700),
        ),
      ),
      body: promptsAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No tienes reviews pendientes por ahora.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.splineSans(color: Colors.white70),
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final item = items[index];
              return _PromptCard(item: item);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: GoogleFonts.splineSans(color: Colors.white70),
            ),
          ),
        ),
      ),
    );
  }
}

class _PromptCard extends ConsumerWidget {
  final ReviewPromptModel item;

  const _PromptCard({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatter = DateFormat('MMM d, yyyy');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: _imageBox(item.eventThumbnailUrl, 72, 72),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.eventTitle,
                        style: GoogleFonts.splineSans(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.eventEndAt != null
                            ? 'Evento concluido el ${formatter.format(item.eventEndAt!.toLocal())}'
                            : 'Evento concluido',
                        style: GoogleFonts.splineSans(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...item.targets.map(
              (target) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _TargetRow(item: item, target: target),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageBox(String? imageUrl, double width, double height) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        width: width,
        height: height,
        color: Colors.white10,
        alignment: Alignment.center,
        child: const Icon(Icons.rate_review_outlined, color: Colors.white54),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorWidget: (_, _, _) => Container(
        width: width,
        height: height,
        color: Colors.white10,
        alignment: Alignment.center,
        child: const Icon(Icons.rate_review_outlined, color: Colors.white54),
      ),
    );
  }
}

class _TargetRow extends ConsumerWidget {
  final ReviewPromptModel item;
  final ReviewPromptTargetModel target;

  const _TargetRow({required this.item, required this.target});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArtist = target.targetType == 'artist';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.white10,
            backgroundImage:
                target.imageUrl != null && target.imageUrl!.isNotEmpty
                ? CachedNetworkImageProvider(target.imageUrl!)
                : null,
            child: target.imageUrl == null || target.imageUrl!.isEmpty
                ? const Icon(Icons.person_outline, color: Colors.white70)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  target.title,
                  style: GoogleFonts.splineSans(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  target.displayName,
                  style: GoogleFonts.splineSans(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isArtist) ...[
                OutlinedButton(
                  onPressed: () => _openTipSheet(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white24),
                  ),
                  child: const Text('Propina'),
                ),
                const SizedBox(width: 8),
              ],
              FilledButton.tonal(
                onPressed: () => _openReviewSheet(context, ref),
                child: const Text('Calificar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openReviewSheet(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF151522),
      builder: (context) => _ReviewComposer(item: item, target: target),
    );
  }

  Future<void> _openTipSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF151522),
      builder: (context) => _ArtistTipComposer(item: item, target: target),
    );
  }
}

class _ReviewComposer extends ConsumerStatefulWidget {
  final ReviewPromptModel item;
  final ReviewPromptTargetModel target;

  const _ReviewComposer({required this.item, required this.target});

  @override
  ConsumerState<_ReviewComposer> createState() => _ReviewComposerState();
}

class _ReviewComposerState extends ConsumerState<_ReviewComposer> {
  final TextEditingController _commentController = TextEditingController();
  int _rating = 5;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final actionState = ref.watch(reviewPromptActionProvider);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottomInset + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.target.displayName,
            style: GoogleFonts.splineSans(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.target.title,
            style: GoogleFonts.splineSans(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(5, (index) {
              final value = index + 1;
              return IconButton(
                onPressed: () => setState(() => _rating = value),
                icon: Icon(
                  value <= _rating
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  color: const Color(0xFFF59E0B),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _commentController,
            maxLines: 4,
            style: GoogleFonts.splineSans(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Comentario opcional',
              hintStyle: GoogleFonts.splineSans(color: Colors.white38),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.04),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: actionState.isLoading ? null : _submit,
              child: actionState.isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Enviar review'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      await ref
          .read(reviewPromptActionProvider.notifier)
          .submit(
            targetType: widget.target.targetType,
            targetId: widget.target.targetId,
            eventId: widget.item.eventId,
            rating: _rating,
            comment: _commentController.text.trim().isEmpty
                ? null
                : _commentController.text.trim(),
          );

      if (!mounted) return;
      navigator.pop();
      messenger.showSnackBar(
        const SnackBar(content: Text('Review enviada correctamente.')),
      );
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('No se pudo enviar la review.')),
      );
    }
  }
}

class _ArtistTipComposer extends ConsumerStatefulWidget {
  final ReviewPromptModel item;
  final ReviewPromptTargetModel target;

  const _ArtistTipComposer({required this.item, required this.target});

  @override
  ConsumerState<_ArtistTipComposer> createState() => _ArtistTipComposerState();
}

class _ArtistTipComposerState extends ConsumerState<_ArtistTipComposer> {
  final TextEditingController _amountController = TextEditingController(
    text: '250',
  );
  static const List<double> _presets = [100, 250, 500, 1000];

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(artistTipFlowProvider.notifier).bootstrap(),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tipState = ref.watch(artistTipFlowProvider);
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    final breakdown = ref
        .read(artistTipFlowProvider.notifier)
        .calculateBreakdown(amount <= 0 ? 0 : amount);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottomInset + 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Propina para ${widget.target.displayName}',
              style: GoogleFonts.splineSans(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Solo disponible para asistentes de eventos concluidos.',
              style: GoogleFonts.splineSans(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _presets
                  .map(
                    (preset) => ChoiceChip(
                      label: Text('RD\$${preset.toStringAsFixed(0)}'),
                      selected:
                          (double.tryParse(_amountController.text.trim()) ??
                              0) ==
                          preset,
                      onSelected: (_) {
                        setState(() {
                          _amountController.text = preset.toStringAsFixed(0);
                        });
                      },
                      labelStyle: GoogleFonts.splineSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      selectedColor: Colors.white.withValues(alpha: 0.18),
                      backgroundColor: Colors.white.withValues(alpha: 0.05),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: GoogleFonts.splineSans(color: Colors.white),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Monto de propina',
                labelStyle: GoogleFonts.splineSans(color: Colors.white70),
                prefixText: 'RD\$ ',
                prefixStyle: GoogleFonts.splineSans(color: Colors.white),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.04),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile.adaptive(
              value: tipState.applyWalletBalance,
              onChanged: tipState.walletBalance > 0
                  ? ref.read(artistTipFlowProvider.notifier).toggleWalletBalance
                  : null,
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Usar wallet',
                style: GoogleFonts.splineSans(color: Colors.white),
              ),
              subtitle: Text(
                'Disponible: RD\$${tipState.walletBalance.toStringAsFixed(2)}',
                style: GoogleFonts.splineSans(color: Colors.white70),
              ),
            ),
            _TipSummaryRow(
              label: 'Wallet',
              value: 'RD\$${breakdown.walletApplied.toStringAsFixed(2)}',
            ),
            _TipSummaryRow(
              label: 'Tarjeta',
              value: 'RD\$${breakdown.cardAmount.toStringAsFixed(2)}',
            ),
            _TipSummaryRow(
              label: 'Total',
              value: 'RD\$${breakdown.amount.toStringAsFixed(2)}',
              highlight: true,
            ),
            if (breakdown.requiresCard) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Tarjetas guardadas',
                      style: GoogleFonts.splineSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: tipState.isLoading
                        ? null
                        : () => ref
                              .read(artistTipFlowProvider.notifier)
                              .addNewCard(context),
                    child: const Text('Agregar tarjeta'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (tipState.savedCards.isEmpty)
                Text(
                  'Necesitas una tarjeta guardada para cubrir el resto de la propina.',
                  style: GoogleFonts.splineSans(color: Colors.white70),
                )
              else
                ...tipState.savedCards.map(
                  (card) => InkWell(
                    onTap: () => ref
                        .read(artistTipFlowProvider.notifier)
                        .selectCard(card.id),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: tipState.selectedCardId == card.id
                              ? Colors.white54
                              : Colors.white12,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            tipState.selectedCardId == card.id
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${card.brand.toUpperCase()} •••• ${card.last4}',
                                  style: GoogleFonts.splineSans(
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  card.expiry.isEmpty
                                      ? 'Tarjeta guardada'
                                      : 'Expira ${card.expiry}',
                                  style: GoogleFonts.splineSans(
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
            if (tipState.error != null) ...[
              const SizedBox(height: 12),
              Text(
                tipState.error!,
                style: GoogleFonts.splineSans(color: kDangerColor),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: tipState.isLoading || amount <= 0 ? null : _submit,
                child: tipState.isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Enviar propina'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;

    try {
      final response = await ref
          .read(artistTipFlowProvider.notifier)
          .submitTip(
            artistId: widget.target.targetId,
            bookingId: widget.item.bookingId,
            amount: amount,
          );

      if (!mounted) return;
      navigator.pop();
      final summary = response['data']?['payment_summary'] as Map?;
      final walletAmount = (summary?['wallet_amount'] as num?)?.toDouble() ?? 0;
      final cardAmount = (summary?['card_amount'] as num?)?.toDouble() ?? 0;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Propina enviada. Wallet: RD\$${walletAmount.toStringAsFixed(2)} · Tarjeta: RD\$${cardAmount.toStringAsFixed(2)}',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('No se pudo procesar la propina.')),
      );
    }
  }
}

class _TipSummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _TipSummaryRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.splineSans(
              color: highlight ? Colors.white : Colors.white70,
              fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.splineSans(
              color: highlight ? Colors.white : Colors.white70,
              fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
