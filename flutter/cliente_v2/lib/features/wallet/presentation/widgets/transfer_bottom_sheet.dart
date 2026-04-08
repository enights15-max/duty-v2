import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/providers/profile_state_provider.dart';
import '../providers/wallet_provider.dart';
import '../../../../core/theme/colors.dart';

class TransferBottomSheet extends ConsumerStatefulWidget {
  final String? initialTargetWalletId;

  const TransferBottomSheet({super.key, this.initialTargetWalletId});

  @override
  ConsumerState<TransferBottomSheet> createState() =>
      _TransferBottomSheetState();
}

class _TransferBottomSheetState extends ConsumerState<TransferBottomSheet> {
  final _amountController = TextEditingController();
  final _targetWalletController = TextEditingController();
  String? _selectedTargetProfile;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialTargetWalletId != null) {
      _targetWalletController.text = widget.initialTargetWalletId!;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _targetWalletController.dispose();
    super.dispose();
  }

  Future<void> _handleTransfer() async {
    final palette = context.dutyTheme;
    final amount = double.tryParse(_amountController.text) ?? 0;
    final targetId =
        _selectedTargetProfile ?? _targetWalletController.text.trim();

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a valid amount'),
          backgroundColor: palette.warning,
        ),
      );
      return;
    }

    if (targetId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select or enter a target wallet'),
          backgroundColor: palette.warning,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final repository = ref.read(walletRepositoryProvider);
      final token = await ref.read(authTokenProvider.future);
      if (token == null) throw Exception('Not authenticated');

      await repository.transferFunds(
        token: token,
        amount: amount,
        targetWalletId: targetId,
      );

      if (!mounted) return;

      // Refresh wallet surfaces
      ref.invalidate(walletProvider);
      ref.invalidate(walletHistoryProvider);

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Transfer successful!'),
          backgroundColor: palette.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Transfer failed: ${e.toString()}'),
          backgroundColor: palette.danger,
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    final userProfiles = ref.watch(userProfilesProvider);
    final activeProfile = ref.watch(activeProfileProvider);

    // Filter out current profile from internal transfer options
    final otherProfiles = userProfiles
        .where((p) => p.id != activeProfile?.id && p.isActive)
        .toList();

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 100,
      ),
      decoration: BoxDecoration(
        color: palette.backgroundAlt,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: palette.textMuted.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Transfer Funds',
            style: GoogleFonts.splineSans(
              color: palette.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          if (otherProfiles.isNotEmpty) ...[
            Text(
              'MY ACCOUNTS',
              style: GoogleFonts.splineSans(
                color: palette.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: otherProfiles.length,
                separatorBuilder: (_, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final profile = otherProfiles[index];
                  final isSelected = _selectedTargetProfile == profile.id;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTargetProfile = isSelected ? null : profile.id;
                        if (_selectedTargetProfile != null) {
                          _targetWalletController.clear();
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 80,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? palette.primary.withValues(alpha: 0.16)
                            : palette.surfaceAlt,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? palette.primary : palette.border,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundImage: profile.avatarUrl != null
                                ? CachedNetworkImageProvider(profile.avatarUrl!)
                                : null,
                            child: profile.avatarUrl == null
                                ? const Icon(Icons.person, size: 20)
                                : null,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            profile.name,
                            style: GoogleFonts.splineSans(
                              color: isSelected
                                  ? palette.textPrimary
                                  : palette.textSecondary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],

          // External destination
          Text(
            'SEND TO OTHER',
            style: GoogleFonts.splineSans(
              color: palette.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: palette.surfaceAlt,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: palette.border),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _targetWalletController,
              onChanged: (val) {
                if (val.isNotEmpty) {
                  setState(() => _selectedTargetProfile = null);
                }
              },
              style: TextStyle(color: palette.textPrimary),
              decoration: InputDecoration(
                hintText: 'Enter Email, Profile ID or Wallet ID',
                hintStyle: TextStyle(color: palette.textMuted),
                border: InputBorder.none,
                icon: Icon(
                  Icons.alternate_email_rounded,
                  color: palette.textMuted,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Amount
          Text(
            'AMOUNT',
            style: GoogleFonts.splineSans(
              color: palette.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: palette.surfaceAlt,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: palette.border),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: GoogleFonts.splineSans(
                color: palette.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                hintText: '0.00',
                hintStyle: TextStyle(
                  color: palette.textMuted.withValues(alpha: 0.6),
                ),
                prefixText: '\$ ',
                prefixStyle: TextStyle(color: palette.primary),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Confirm Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _handleTransfer,
              style: ElevatedButton.styleFrom(
                backgroundColor: palette.primary,
                foregroundColor: palette.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: _isProcessing
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: palette.onPrimary,
                      ),
                    )
                  : Text(
                      'Confirm Transfer',
                      style: GoogleFonts.splineSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
