import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/events/presentation/pages/home_page.dart';
import '../../features/events/presentation/pages/event_details_page.dart';
<<<<<<< Updated upstream
=======
import '../../features/events/presentation/pages/explore_events_page.dart';
import '../../features/events/presentation/pages/organizer_profile_page.dart';
import '../../features/events/presentation/pages/venue_profile_page.dart';
import '../../features/events/presentation/pages/professional_event_create_page.dart';
import '../../features/events/presentation/pages/professional_events_manage_page.dart';
import '../../features/chat/presentation/pages/chat_room_page.dart';
import '../../features/chat/presentation/pages/conversations_list_page.dart';
import '../../features/chat/data/models/chat_model.dart';
>>>>>>> Stashed changes
import '../../features/shop/presentation/pages/checkout_page.dart';
import '../../features/shop/presentation/pages/payment_webview_page.dart';
import '../../features/events/data/models/event_detail_model.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/my_tickets_page.dart';
import '../../features/profile/presentation/pages/ticket_details_page.dart';
import '../../features/profile/data/models/booking_model.dart';
<<<<<<< Updated upstream
=======
import '../../features/profile/domain/models/profile_model.dart';
import '../../features/wallet/presentation/pages/wallet_details_page.dart';
import '../../features/wallet/presentation/pages/withdrawal_page.dart';
import '../../features/profile/presentation/pages/blackmarket_page.dart';
import '../../features/profile/presentation/pages/pending_transfers_page.dart';
import '../../features/profile/presentation/pages/transfer_request_details_page.dart';
import '../../features/profile/presentation/pages/transfer_outbox_page.dart';
import '../../features/profile/presentation/pages/public_user_profile_page.dart';
import '../../features/profile/presentation/pages/review_inbox_page.dart';
import '../../features/profile/presentation/pages/artist_profile_page.dart';
import '../../features/profile/presentation/pages/account_center_page.dart';
import '../../features/profile/presentation/pages/social_connections_page.dart';
import '../../features/loyalty/presentation/pages/loyalty_page.dart';
import '../../features/events/presentation/pages/search_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/onboarding/presentation/pages/splash_page.dart';
import '../../features/profile/presentation/pages/identity_request_page.dart';
import '../../features/scanner/presentation/pages/scanner_page.dart';
import '../../features/scanner/presentation/pages/transfer_receive_code_page.dart';
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
>>>>>>> Stashed changes

final appRouterProvider = Provider<GoRouter>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final token = prefs.getString(AppConstants.tokenKey); // Use AppConstants

  return GoRouter(
<<<<<<< Updated upstream
    initialLocation: token != null ? '/home' : '/login',
=======
    initialLocation: '/splash',
    refreshListenable: null, // We rely on Provider rebuild for now
    redirect: (context, state) => _redirectExternalDeepLink(state.uri),
>>>>>>> Stashed changes
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => ForgotPasswordPage(
          initialEmail: state.uri.queryParameters['email'],
        ),
      ),
      GoRoute(path: '/signup', builder: (context, state) => const SignupPage()),
<<<<<<< Updated upstream
      GoRoute(path: '/home', builder: (context, state) => const HomePage()),
=======
      GoRoute(
        path: '/phone-login',
        builder: (context, state) => const PhoneLoginPage(),
      ),
      GoRoute(
        path: '/otp-verification',
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>? ?? {};
          return OtpVerificationPage(
            initialVerificationId: extras['verificationId']?.toString() ?? '',
            phoneNumber: extras['phoneNumber']?.toString() ?? '',
            resendToken: extras['resendToken'] is int
                ? extras['resendToken'] as int
                : null,
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
          final extras = state.extra as Map<String, dynamic>? ?? {};
          final token = extras['token']?.toString() ?? '';
          final phoneNumber = extras['phoneNumber']?.toString() ?? '';
          return PhoneVerificationLinkPage(
            verificationToken: token,
            phoneNumber: phoneNumber,
          );
        },
      ),
      GoRoute(
        path: '/scanner',
        builder: (context, state) {
          final modeParam = state.uri.queryParameters['mode'];
          final mode = modeParam == 'transfer'
              ? ScannerMode.transfer
              : ScannerMode.event;
          final booking = state.extra is BookingModel
              ? state.extra as BookingModel
              : null;
          return ScannerPage(initialMode: mode, transferBooking: booking);
        },
      ),
      GoRoute(
        path: '/scanner/my-code',
        builder: (context, state) => const TransferReceiveCodePage(),
      ),

      // ShellRoute for persistent bottom navigation
      ShellRoute(
        builder: (context, state, child) {
          return ScaffoldWithNavBar(child: child);
        },
        routes: [
          GoRoute(path: '/home', builder: (context, state) => const HomePage()),
          GoRoute(
            path: '/explore',
            builder: (context, state) => const ExploreEventsPage(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const UserProfilePage(),
          ),
          GoRoute(
            path: '/my-tickets',
            builder: (context, state) => const MyTicketsPage(),
          ),
          GoRoute(
            path: '/marketplace',
            builder: (context, state) => const BlackmarketPage(),
          ),
          GoRoute(
            path: '/messages',
            builder: (context, state) => const ConversationsListPage(),
          ),
        ],
      ),

      // Other routes (fullscreen, no bottom nav)
>>>>>>> Stashed changes
      GoRoute(
        path: '/event-details/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return EventDetailsPage(eventId: id);
        },
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) {
          final event = state.extra as EventDetailModel;
          return CheckoutPage(event: event);
        },
      ),
      GoRoute(
        path: '/payment-webview',
        builder: (context, state) {
          final url = state.extra as String;
          return PaymentWebViewPage(url: url);
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/my-tickets',
        builder: (context, state) => const MyTicketsPage(),
      ),
      GoRoute(
        path: '/ticket-details/:id',
        builder: (context, state) {
          final booking = state.extra as BookingModel;
          return TicketDetailsPage(booking: booking);
        },
      ),
<<<<<<< Updated upstream
=======
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
            rawBookingInfo: extras['rawBookingInfo'] as Map<String, dynamic>?,
          );
        },
      ),
      GoRoute(
        path: '/wallet',
        builder: (context, state) => const WalletDetailsPage(),
      ),
      GoRoute(
        path: '/loyalty',
        builder: (context, state) => const LoyaltyPage(),
      ),
      GoRoute(
        path: '/withdraw',
        builder: (context, state) => const WithdrawalPage(),
      ),
      GoRoute(
        path: '/memberships',
        builder: (context, state) => const VIPMembershipsPage(),
      ),
      GoRoute(
        path: '/chat-room',
        builder: (context, state) {
          final chat = state.extra;
          final idParam = state.uri.queryParameters['id'];
          final chatId = idParam != null ? int.tryParse(idParam) : null;

          if (chat is ChatModel) {
            return ChatRoomPage(chat: chat);
          } else if (chatId != null) {
            return ChatRoomPage(chatId: chatId);
          }
          return const Scaffold(body: Center(child: Text('Invalid chat data')));
        },
      ),
      GoRoute(
        path: '/identity-request',
        builder: (context, state) {
          final extra = state.extra;

          if (extra is Map<String, dynamic>) {
            final profile = extra['profile'];
            final prefillProfile = extra['prefill_profile'];
            final type = extra['type']?.toString();

            if (profile is AppProfile) {
              return IdentityRequestPage(
                initialType: type ?? profile.type.name,
                existingProfile: profile,
              );
            }

            if (prefillProfile is AppProfile) {
              return IdentityRequestPage(
                initialType: type ?? prefillProfile.type.name,
                prefillProfile: prefillProfile,
              );
            }

            return IdentityRequestPage(initialType: type ?? 'organizer');
          }

          if (extra is AppProfile) {
            return IdentityRequestPage(
              initialType: extra.type.name,
              existingProfile: extra,
            );
          }

          final type = extra?.toString() ?? 'organizer';
          return IdentityRequestPage(initialType: type);
        },
      ),
      GoRoute(
        path: '/account-center',
        builder: (context, state) => const AccountCenterPage(),
      ),
>>>>>>> Stashed changes
    ],
  );
});
