import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/constants/app_urls.dart';
import '../../../../core/theme/colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class TransferReceiveCodePage extends ConsumerWidget {
  const TransferReceiveCodePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.dutyTheme;
    final user = ref.watch(currentUserProvider);
    final userId = int.tryParse(user?['id']?.toString() ?? '');
    final username = user?['username']?.toString().trim() ?? '';
    final firstName = user?['fname']?.toString().trim() ?? '';
    final lastName = user?['lname']?.toString().trim() ?? '';
    final displayName = '$firstName $lastName'.trim();
    final fallbackName = username.isNotEmpty ? '@$username' : 'Duty user';
    final shareName = displayName.isNotEmpty ? displayName : fallbackName;
    final qrPayload = userId != null && userId > 0
        ? AppUrls.transferRecipientCode(customerId: userId)
        : null;

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compactLayout = constraints.maxHeight < 820;
            final ultraCompactLayout = constraints.maxHeight < 740;
            final titleSize = ultraCompactLayout ? 30.0 : 34.0;
            final bodySize = compactLayout ? 13.0 : 14.0;
            final cardPadding = compactLayout ? 20.0 : 24.0;
            final qrSize = ultraCompactLayout
                ? 216.0
                : (compactLayout ? 236.0 : 268.0);

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 46,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () => context.pop(),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: palette.surfaceAlt.withValues(alpha: 0.92),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: palette.border),
                            ),
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: palette.textPrimary,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'My Code',
                          style: GoogleFonts.outfit(
                            color: palette.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(width: 48),
                      ],
                    ),
                    SizedBox(height: ultraCompactLayout ? 22 : 28),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: palette.primarySurface,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: palette.borderStrong),
                      ),
                      child: Text(
                        'RECEIVE TICKETS',
                        style: GoogleFonts.outfit(
                          color: palette.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Let someone scan this code to send you a ticket.',
                      style: GoogleFonts.outfit(
                        color: palette.textPrimary,
                        fontSize: titleSize,
                        fontWeight: FontWeight.w800,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'The sender opens their ticket, taps Transfer, and scans your code. You will still be asked to accept the request before the ticket moves.',
                      style: GoogleFonts.inter(
                        color: palette.textSecondary,
                        fontSize: bodySize,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: compactLayout ? 22 : 28),
                    Center(
                      child: Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxWidth: 420),
                        padding: EdgeInsets.all(cardPadding),
                        decoration: BoxDecoration(
                          color: palette.surface,
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(color: palette.border),
                        ),
                        child: qrPayload == null
                            ? Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.qr_code_2_rounded,
                                    color: palette.textMuted,
                                    size: 72,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'We could not generate your receive code yet.',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.outfit(
                                      color: palette.textPrimary,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Try refreshing your session and opening this screen again.',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                      color: palette.textSecondary,
                                      fontSize: 14,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: qrSize,
                                    height: qrSize,
                                    padding: EdgeInsets.all(
                                      compactLayout ? 14 : 18,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(28),
                                    ),
                                    child: QrImageView(
                                      data: qrPayload,
                                      version: QrVersions.auto,
                                      eyeStyle: const QrEyeStyle(
                                        eyeShape: QrEyeShape.square,
                                        color: kSurfaceColor,
                                      ),
                                      dataModuleStyle: const QrDataModuleStyle(
                                        dataModuleShape:
                                            QrDataModuleShape.square,
                                        color: kSurfaceColor,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: compactLayout ? 16 : 22),
                                  Text(
                                    shareName,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.outfit(
                                      color: palette.textPrimary,
                                      fontSize: compactLayout ? 22 : 26,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  if (username.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      '@$username',
                                      style: GoogleFonts.inter(
                                        color: palette.textSecondary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                  SizedBox(height: compactLayout ? 14 : 18),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: palette.surfaceAlt,
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(color: palette.border),
                                    ),
                                    child: Text(
                                      'Keep this screen open while the sender scans it. You will get a transfer request to review before anything changes.',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.inter(
                                        color: palette.textSecondary,
                                        fontSize: compactLayout ? 12.5 : 13,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: palette.textPrimary,
                                        side: BorderSide(color: palette.border),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                        ),
                                      ),
                                      onPressed: () async {
                                        await Clipboard.setData(
                                          ClipboardData(text: qrPayload),
                                        );
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Receive code copied.',
                                            ),
                                            backgroundColor: palette.success,
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.copy_rounded),
                                      label: Text(
                                        'Copy receive code',
                                        style: GoogleFonts.outfit(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
