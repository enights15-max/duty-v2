import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/colors.dart';
import '../providers/membership_provider.dart';

class VIPMembershipsPage extends ConsumerWidget {
  const VIPMembershipsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(subscriptionPlansProvider);
    final subscribeState = ref.watch(membershipProvider);

    // Listen for subscribeState changes to launch checkout
    ref.listen<AsyncValue<String?>>(membershipProvider, (previous, next) {
      next.whenOrNull(
        data: (url) {
          if (url != null) {
            context.push('/payment-webview', extra: url);
          }
        },
        error: (err, stack) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $err'), backgroundColor: Colors.red),
          );
        },
      );
    });

    return Scaffold(
      backgroundColor: kBackgroundDark,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ELEVATE YOUR EXPERIENCE',
                    style: GoogleFonts.splineSans(
                      color: kPrimaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Exclusive VIP Benefits',
                    style: GoogleFonts.splineSans(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Unlock premium perks, priority access, and exclusive rewards by joining our VIP community.',
                    style: GoogleFonts.splineSans(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          plansAsync.when(
            data: (plans) => SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final plan = plans[index];
                  return _buildPlanCard(
                    context,
                    ref,
                    plan,
                    subscribeState.isLoading,
                  );
                }, childCount: plans.length),
              ),
            ),
            loading: () => const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: kPrimaryColor),
              ),
            ),
            error: (err, stack) => SliverFillRemaining(
              child: Center(
                child: Text(
                  'Error: $err',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: kBackgroundDark,
      expandedHeight: 0,
      floating: true,
      pinned: true,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: Colors.white,
          size: 20,
        ),
        onPressed: () => context.pop(),
      ),
      title: Text(
        'VIP Memberships',
        style: GoogleFonts.splineSans(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildPlanCard(
    BuildContext context,
    WidgetRef ref,
    dynamic plan,
    bool isLoading,
  ) {
    final bool isPlatinum = plan['name'].toString().toLowerCase().contains(
      'platinum',
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isPlatinum
              ? kPrimaryColor.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.1),
          width: isPlatinum ? 2 : 1,
        ),
        boxShadow: isPlatinum
            ? [
                BoxShadow(
                  color: kPrimaryColor.withValues(alpha: 0.1),
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      plan['name'].toString().toUpperCase(),
                      style: GoogleFonts.splineSans(
                        color: isPlatinum ? kPrimaryColor : Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                      ),
                    ),
                    if (isPlatinum)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: kPrimaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'BEST VALUE',
                          style: GoogleFonts.splineSans(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '${plan['currency'].toString().toUpperCase()} ${plan['price']}',
                      style: GoogleFonts.splineSans(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '/ month',
                      style: GoogleFonts.splineSans(
                        color: Colors.white38,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  plan['description'] ?? 'Unlock exclusive features',
                  style: GoogleFonts.splineSans(
                    color: Colors.white60,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Features
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 0),
            child: Column(
              children: [
                _buildFeatureItem('Priority Entry to all Events'),
                _buildFeatureItem('Exclusive Collectible Drops'),
                _buildFeatureItem('VIP Lounge Access'),
                _buildFeatureItem('24/7 Premium Support'),
                if (isPlatinum) _buildFeatureItem('Backstage Pass Eligibility'),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () {
                        ref
                            .read(membershipProvider.notifier)
                            .subscribe(
                              plan['id'].toString(),
                              successUrl: 'https://v2.duty.do/checkout/success',
                              cancelUrl: 'https://v2.duty.do/checkout/cancel',
                            );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPlatinum
                      ? kPrimaryColor
                      : Colors.white.withValues(alpha: 0.1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: isPlatinum
                        ? BorderSide.none
                        : const BorderSide(color: Colors.white24),
                  ),
                  elevation: 0,
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Subscribe Now',
                        style: GoogleFonts.splineSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            color: kPrimaryColor,
            size: 18,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: GoogleFonts.splineSans(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
