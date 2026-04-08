import '../../../../core/constants/app_urls.dart';
import 'reward_instance_model.dart';

class BookingModel {
  final int id;
  final String bookingId;
  final double total;
  final String status;
  final String paymentStatus;
  final String eventTitle;
  final String? eventDate;
  final String? eventImage;
  final int quantity;
  final String? qrCodeUrl;
  final String? organizerName;
  final String? invoiceUrl;
  final bool isTransferable;
  final bool isListed;
  final double listingPrice;
  final String? transferStatus;
  final String? eventEndDate;

  final String? venueName;
  final List<RewardInstanceModel> rewards;

  BookingModel({
    required this.id,
    required this.bookingId,
    required this.total,
    required this.status,
    required this.paymentStatus,
    required this.eventTitle,
    this.eventDate,
    this.eventImage,
    required this.quantity,
    this.qrCodeUrl,
    this.organizerName,
    this.invoiceUrl,
    this.isTransferable = true,
    this.isListed = false,
    this.listingPrice = 0.0,
    this.transferStatus,
    this.eventEndDate,
    this.rewards = const [],
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    // Helper to handle image URLs
    String? getImageUrl(String? path) {
      if (path == null || path.isEmpty) return null;
      if (path.startsWith('http')) return path;
      return '${AppConstants.imageBaseUrl}$path';
    }

    return BookingModel(
      id: json['id'],
      bookingId: json['booking_id']?.toString() ?? '',
      total: double.tryParse(json['price'].toString()) ?? 0.0,
      status: json['status']?.toString() ?? 'pending',
      paymentStatus:
          json['paymentStatus']?.toString() ??
          json['payment_status']?.toString() ??
          'pending',
      eventTitle:
          json['event_title']?.toString() ??
          (json['event'] != null ? json['event']['title'] : 'Unknown Event'),
      eventDate: json['event_date']?.toString(),
      eventImage: getImageUrl(
        json['thumbnail']?.toString() ??
            (json['event'] != null ? json['event']['thumbnail'] : null),
      ),
      quantity: int.tryParse(json['quantity']?.toString() ?? '1') ?? 1,
      qrCodeUrl: json['qr_image']?.toString(),
      organizerName:
          json['organizer_name']?.toString() ??
          (json['organizer'] != null ? json['organizer']['name'] : null),
      invoiceUrl: json['invoice']?.toString(),
      isTransferable:
          json['is_transferable'] == 1 || json['is_transferable'] == true,
      isListed: json['is_listed'] == 1 || json['is_listed'] == true,
      listingPrice:
          double.tryParse(json['listing_price']?.toString() ?? '0') ?? 0.0,
      transferStatus: json['transfer_status']?.toString(),
      eventEndDate: json['event_end_date']?.toString(),
      rewards: (json['rewards'] as List? ?? [])
          .map((e) => RewardInstanceModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
