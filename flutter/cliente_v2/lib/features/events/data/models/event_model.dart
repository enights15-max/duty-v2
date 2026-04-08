import 'package:duty_client/core/constants/app_constants.dart';

class EventModel {
  final int id;
  final String title;
  final String thumbnail;
  final String? address;
  final String? date;
  final String? time;
  final String? endDate;
  final String? endTime;
  final String? organizer;
  final dynamic startPrice; // Can be int or string 'free'
  final String availabilityState;
  final String demandLabel;
  final bool showMarketplaceFallback;
  final bool showWaitlistCta;
  final int marketplaceAvailableCount;
  final int waitlistCount;
  final bool viewerWaitlistSubscribed;

  EventModel({
    required this.id,
    required this.title,
    required this.thumbnail,
    this.address,
    this.date,
    this.time,
    this.endDate,
    this.endTime,
    this.organizer,
    this.startPrice,
    this.availabilityState = 'available',
    this.demandLabel = 'Tickets disponibles',
    this.showMarketplaceFallback = false,
    this.showWaitlistCta = false,
    this.marketplaceAvailableCount = 0,
    this.waitlistCount = 0,
    this.viewerWaitlistSubscribed = false,
  });

  String get formattedPriceLabel {
    final value = startPrice;
    if (value == null) return 'FREE';
    if (value is num) {
      return value <= 0 ? 'FREE' : '\$${value.toStringAsFixed(0)}';
    }

    final normalized = value.toString().trim();
    if (normalized.isEmpty) return 'FREE';
    final lower = normalized.toLowerCase();
    if (lower == 'free' || lower == '0' || lower == '0.0') {
      return 'FREE';
    }

    final parsed = double.tryParse(normalized.replaceAll(',', ''));
    if (parsed != null) {
      return parsed <= 0 ? 'FREE' : '\$${parsed.toStringAsFixed(0)}';
    }

    return normalized.startsWith('\$') ? normalized : '\$$normalized';
  }

  factory EventModel.fromJson(Map<String, dynamic> json) {
    final inventorySummary = json['inventory_summary'] is Map<String, dynamic>
        ? json['inventory_summary'] as Map<String, dynamic>
        : (json['inventory_summary'] is Map
              ? Map<String, dynamic>.from(json['inventory_summary'] as Map)
              : const <String, dynamic>{});
    final waitlistSummary = json['waitlist'] is Map<String, dynamic>
        ? json['waitlist'] as Map<String, dynamic>
        : (json['waitlist'] is Map
              ? Map<String, dynamic>.from(json['waitlist'] as Map)
              : const <String, dynamic>{});

    return EventModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      title: json['title'] ?? '',
      thumbnail:
          (json['thumbnail'] != null &&
              !json['thumbnail'].toString().startsWith('http'))
          ? '${AppConstants.imageBaseUrl}${json['thumbnail']}'
          : json['thumbnail'] ?? '',
      address: json['address'],
      date: json['date'],
      time: json['time'],
      endDate: json['end_date'],
      endTime: json['end_time'],
      organizer: json['organizer'],
      startPrice: json['start_price'],
      availabilityState:
          json['availability_state']?.toString() ??
          inventorySummary['availability_state']?.toString() ??
          'available',
      demandLabel:
          json['demand_label']?.toString() ??
          inventorySummary['demand_label']?.toString() ??
          'Tickets disponibles',
      showMarketplaceFallback: _parseBool(
        json['show_marketplace_fallback'] ??
            inventorySummary['show_marketplace_fallback'],
      ),
      showWaitlistCta: _parseBool(
        json['show_waitlist_cta'] ?? inventorySummary['show_waitlist_cta'],
      ),
      marketplaceAvailableCount:
          int.tryParse(
            (json['marketplace_available_count'] ??
                    inventorySummary['marketplace_available_count'] ??
                    0)
                .toString(),
          ) ??
          0,
      waitlistCount:
          int.tryParse(
            (json['waitlist_count'] ?? waitlistSummary['waitlist_count'] ?? 0)
                .toString(),
          ) ??
          0,
      viewerWaitlistSubscribed: _parseBool(
        json['viewer_waitlist_subscribed'] ??
            waitlistSummary['viewer_waitlist_subscribed'],
      ),
    );
  }
  @override
  String toString() {
    return 'EventModel(id: $id, title: $title, thumbnail: $thumbnail, address: $address, date: $date, time: $time, organizer: $organizer, startPrice: $startPrice)';
  }
}

bool _parseBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final normalized = value?.toString().trim().toLowerCase();
  return normalized == '1' ||
      normalized == 'true' ||
      normalized == 'yes' ||
      normalized == 'on';
}
