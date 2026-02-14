import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/events/presentation/pages/home_page.dart';
import '../../features/events/presentation/pages/event_details_page.dart';
import '../../features/shop/presentation/pages/checkout_page.dart';
import '../../features/shop/presentation/pages/payment_webview_page.dart';
import '../../features/events/data/models/event_detail_model.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/my_tickets_page.dart';
import '../../features/profile/presentation/pages/ticket_details_page.dart';
import '../../features/profile/data/models/booking_model.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final token = prefs.getString(AppConstants.tokenKey); // Use AppConstants

  return GoRouter(
    initialLocation: token != null ? '/home' : '/login',
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(path: '/signup', builder: (context, state) => const SignupPage()),
      GoRoute(path: '/home', builder: (context, state) => const HomePage()),
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
    ],
  );
});
