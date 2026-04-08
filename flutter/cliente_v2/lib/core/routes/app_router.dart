import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/auth/presentation/pages/phone_login_page.dart';
import '../../features/auth/presentation/pages/complete_profile_page.dart';
import '../../features/auth/presentation/pages/otp_verification_page.dart';
import '../../features/auth/presentation/pages/email_setup_page.dart';
import '../../features/auth/presentation/pages/phone_verification_link_page.dart';
import '../../features/auth/presentation/pages/auth_lock_page.dart';
import '../../features/auth/presentation/pages/user_type_selection_page.dart';
import '../../features/events/presentation/pages/home_page.dart';
import '../../features/events/presentation/pages/event_details_page.dart';
import '../../features/events/presentation/pages/organizer_profile_page.dart';
import '../../features/events/presentation/pages/venue_profile_page.dart';
import '../../features/events/presentation/pages/professional_event_create_page.dart';
import '../../features/events/presentation/pages/professional_event_inventory_page.dart';
import '../../features/events/presentation/pages/professional_event_collaborators_page.dart';
import '../../features/events/presentation/pages/professional_event_tickets_page.dart';
import '../../features/events/presentation/pages/professional_events_manage_page.dart';
import '../../features/events/presentation/pages/professional_collaborations_page.dart';
import '../../features/events/presentation/pages/professional_stats_page.dart';
import '../../features/chat/presentation/pages/chat_room_page.dart';
import '../../features/chat/presentation/pages/conversations_list_page.dart';
import '../../features/chat/data/models/chat_model.dart';
import '../../features/shop/presentation/pages/checkout_page.dart';
import '../../features/shop/presentation/pages/payment_cc_page.dart';
import '../../features/shop/presentation/pages/payment_webview_page.dart';
import '../../features/shop/presentation/pages/ticket_success_page.dart';
import '../../features/events/data/models/event_detail_model.dart';
import '../../core/widgets/scaffold_with_navbar.dart';

import '../../features/profile/presentation/pages/my_tickets_page.dart';
import '../../features/profile/presentation/pages/ticket_details_page.dart';
import '../../features/profile/presentation/pages/account_verification_page.dart';
import '../../features/profile/presentation/pages/user_profile_page.dart';
import '../../features/profile/presentation/pages/invoice_details_page.dart';
import '../../features/profile/presentation/pages/vip_memberships_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/settings/presentation/pages/notification_settings_page.dart';
import '../../features/settings/presentation/pages/language_region_page.dart';
import '../../features/settings/presentation/pages/edit_profile_page.dart';
import '../../features/settings/presentation/pages/stored_cards_page.dart';
import '../../features/profile/data/models/booking_model.dart';
import '../../features/wallet/presentation/pages/wallet_details_page.dart';
import '../../features/wallet/presentation/pages/withdrawal_page.dart';
import '../../features/profile/presentation/pages/marketplace_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/profile/presentation/pages/identity_request_page.dart';
import '../../features/scanner/presentation/pages/scanner_page.dart';
import '../../features/scanner/presentation/pages/transfer_receive_code_page.dart';
import '../../features/events/presentation/pages/professional_dashboard_page.dart';
import '../services/app_link_service.dart';

String? _redirectExternalDeepLink(Uri uri) {
  final isExternalUri = uri.scheme.isNotEmpty || uri.host.isNotEmpty;
  if (!isExternalUri) {
    return null;
  }

  final eventId = AppLinkParser.eventIdFromUri(uri);
  if (eventId != null && eventId > 0) {
    return '/event-details/$eventId';
  }

  return null;
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final tokenState = ref.watch(authTokenProvider);
  final token = tokenState.valueOrNull;
  final isLoggedIn = token != null;
  final faceIdEnabled = ref.watch(faceIdEnabledProvider);
  final onboardingSeen = ref.watch(onboardingSeenProvider);
  final userType = ref.watch(userTypeProvider);

  return GoRouter(
    initialLocation: !onboardingSeen
        ? '/onboarding'
        : (userType == null
              ? '/user-type-selection'
              : (isLoggedIn
                    ? (faceIdEnabled ? '/auth-lock' : '/home')
                    : '/login')),
    refreshListenable: null, // We rely on Provider rebuild for now
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/user-type-selection',
        builder: (context, state) => const UserTypeSelectionPage(),
      ),
      GoRoute(
        path: '/auth-lock',
        builder: (context, state) => const AuthLockPage(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(path: '/signup', builder: (context, state) => const SignupPage()),
      GoRoute(
        path: '/phone-login',
        builder: (context, state) => const PhoneLoginPage(),
      ),
      GoRoute(
        path: '/otp-verification',
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>? ?? {};
          return OtpVerificationPage(
            verificationId: extras['verificationId']?.toString() ?? '',
            phoneNumber: extras['phoneNumber']?.toString() ?? '',
          );
        },
      ),
      GoRoute(
        path: '/complete-profile',
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>? ?? {};
          return CompleteProfilePage(
            idToken: extras['idToken']?.toString() ?? '',
            phoneNumber: extras['phoneNumber']?.toString() ?? '',
          );
        },
      ),
      GoRoute(
        path: '/setup-email',
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>? ?? {};
          return EmailSetupPage(
            setupToken: extras['setup_token']?.toString() ?? '',
            phoneNumber: extras['phoneNumber']?.toString() ?? '',
          );
        },
      ),
      GoRoute(
        path: '/verify-phone-link',
        builder: (context, state) {
          final token = state.extra?.toString() ?? '';
          return PhoneVerificationLinkPage(verificationToken: token);
        },
      ),

      // ShellRoute for persistent bottom navigation
      ShellRoute(
        builder: (context, state, child) {
          return ScaffoldWithNavBar(child: child);
        },
        routes: [
          GoRoute(path: '/home', builder: (context, state) => const HomePage()),
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const ProfessionalDashboardPage(),
          ),
          GoRoute(
            path: '/explore',
            builder: (context, state) => const ExploreEventsPage(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const UserProfilePage(),
          ),
          GoRoute(
            path: '/wallet',
            builder: (context, state) => const WalletDetailsPage(),
          ),
          GoRoute(
            path: '/withdraw',
            builder: (context, state) => const WithdrawalPage(),
          ),
          GoRoute(
            path: '/my-tickets',
            builder: (context, state) => const MyTicketsPage(),
          ),
          GoRoute(
            path: '/marketplace',
            builder: (context, state) => const MarketplacePage(),
          ),
          GoRoute(
            path: '/messages',
            builder: (context, state) => const ConversationsListPage(),
          ),
        ],
      ),

      // Other routes (fullscreen, no bottom nav)
      GoRoute(
        path: '/event-details/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return EventDetailsPage(eventId: id);
        },
      ),
      GoRoute(
        path: '/organizer-profile/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return OrganizerProfilePage(organizerId: id);
        },
      ),
      GoRoute(
        path: '/venue-profile/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return VenueProfilePage(venueId: id);
        },
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) {
          final event = state.extra;
          if (event is EventDetailModel) {
            return CheckoutPage(event: event);
          }
          return const Scaffold(
            body: Center(child: Text('Invalid event data')),
          );
        },
      ),
      GoRoute(
        path: '/payment-cc',
        builder: (context, state) {
          final payload = state.extra as Map<String, dynamic>? ?? {};
          return PaymentCCPage(bookingPayload: payload);
        },
      ),
      GoRoute(
        path: '/payment-webview',
        builder: (context, state) {
          final url = state.extra?.toString() ?? '';
          return PaymentWebViewPage(url: url);
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
        routes: [
          GoRoute(
            path: 'notifications',
            builder: (context, state) => const NotificationSettingsPage(),
          ),
          GoRoute(
            path: 'language',
            builder: (context, state) => const LanguageRegionPage(),
          ),
          GoRoute(
            path: 'verification',
            builder: (context, state) => const AccountVerificationPage(),
          ),
          GoRoute(
            path: 'edit-profile',
            builder: (context, state) => const EditProfilePage(),
          ),
          GoRoute(
            path: 'stored-cards',
            builder: (context, state) => const StoredCardsPage(),
          ),
        ],
      ),
      GoRoute(
        path: '/ticket-details/:id',
        builder: (context, state) {
          final booking = state.extra;
          if (booking is BookingModel) {
            return TicketDetailsPage(booking: booking);
          }
          return const Scaffold(
            body: Center(child: Text('Invalid ticket data')),
          );
        },
      ),
      GoRoute(path: '/search', builder: (context, state) => const SearchPage()),
      GoRoute(
        path: '/artists',
        builder: (context, state) =>
            const DiscoveryDirectoryPage(kind: DiscoveryKind.artists),
      ),
      GoRoute(
        path: '/organizers',
        builder: (context, state) =>
            const DiscoveryDirectoryPage(kind: DiscoveryKind.organizers),
      ),
      GoRoute(
        path: '/venues',
        builder: (context, state) =>
            const DiscoveryDirectoryPage(kind: DiscoveryKind.venues),
      ),
      GoRoute(
        path: '/professional/events',
        builder: (context, state) => const ProfessionalEventsManagePage(),
      ),
      GoRoute(
        path: '/professional/events/create',
        builder: (context, state) => const ProfessionalEventCreatePage(),
      ),
      GoRoute(
        path: '/professional/events/:id/inventory',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          if (id != null) {
            return ProfessionalEventInventoryPage(eventId: id);
          }
          return const Scaffold(
            body: Center(child: Text('Invalid professional event id')),
          );
        },
      ),
      GoRoute(
        path: '/professional/events/:id/tickets',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          if (id != null) {
            return ProfessionalEventTicketsPage(eventId: id);
          }
          return const Scaffold(
            body: Center(child: Text('Invalid professional event id')),
          );
        },
      ),
      GoRoute(
        path: '/professional/events/:id/collaborators',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          if (id != null) {
            return ProfessionalEventCollaboratorsPage(eventId: id);
          }
          return const Scaffold(
            body: Center(child: Text('Invalid professional event id')),
          );
        },
      ),
      GoRoute(
        path: '/professional/stats',
        builder: (context, state) => const ProfessionalStatsPage(),
      ),
      GoRoute(
        path: '/professional/collaborations',
        builder: (context, state) => const ProfessionalCollaborationsPage(),
      ),
      GoRoute(
        path: '/professional/events/:id/edit',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          if (id != null) {
            return ProfessionalEventCreatePage(eventId: id);
          }
          return const Scaffold(
            body: Center(child: Text('Invalid professional event id')),
          );
        },
      ),
      GoRoute(
        path: '/pending-transfers',
        builder: (context, state) => const PendingTransfersPage(),
      ),
      GoRoute(
        path: '/transfer-outbox',
        builder: (context, state) => const TransferOutboxPage(),
      ),
      GoRoute(
        path: '/transfer-requests/:id',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          if (id != null) {
            return TransferRequestDetailsPage(transferId: id);
          }
          return const Scaffold(
            body: Center(child: Text('Invalid transfer request id')),
          );
        },
      ),
      GoRoute(
        path: '/reviews/pending',
        builder: (context, state) => const ReviewInboxPage(),
      ),
      GoRoute(
        path: '/invoice-details',
        builder: (context, state) {
          final url = state.extra?.toString() ?? '';
          return InvoiceDetailsPage(url: url);
        },
      ),
      GoRoute(
        path: '/ticket-success',
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>? ?? {};
          return TicketSuccessPage(
            bookingId: extras['bookingId']?.toString() ?? '',
            eventTitle: extras['eventTitle']?.toString() ?? '',
          );
        },
      ),
      GoRoute(
        path: '/loyalty',
        builder: (context, state) => const LoyaltyPage(),
      ),
      GoRoute(
        path: '/memberships',
        builder: (context, state) => const VIPMembershipsPage(),
      ),
      GoRoute(
        path: '/chat-room',
        builder: (context, state) {
          final chat = state.extra;
          if (chat is ChatModel) {
            return ChatRoomPage(chat: chat);
          }
          return const Scaffold(body: Center(child: Text('Invalid chat data')));
        },
      ),
      GoRoute(
        path: '/identity-request',
        builder: (context, state) {
          final type = state.extra?.toString() ?? 'organizer';
          return IdentityRequestPage(initialType: type);
        },
      ),
    ],
  );
});
