import 'package:duty_client/core/constants/app_constants.dart';
import 'event_model.dart';
import 'event_reward_summary_model.dart';
import 'organizer_model.dart';
import 'venue_model.dart';

class EventDetailModel extends EventModel {
  final String description;
  final String? refundPolicy;
  final List<String> images;
  final List<TicketModel> tickets;
  final List<EventLineupModel> lineup;
  final List<EventRewardSummaryModel> rewards;
  final OrganizerModel? organizerModel;
  final VenueModel? venue;
  final EventInventorySummaryModel? inventory;
  final EventWaitlistSummaryModel? waitlist;

  EventDetailModel({
    required super.id,
    required super.title,
    required super.thumbnail,
    this.policies,
    super.address,
    super.date,
    super.time,
    super.endDate,
    super.endTime,
    super.organizer,
    required this.description,
    this.refundPolicy,
    required this.images,
    required this.tickets,
    required this.lineup,
    required this.rewards,
    this.organizerModel,
    this.venue,
    this.inventory,
    this.waitlist,
    this.coverImage,
    this.latitude,
    this.longitude,
  });

  final double? latitude;
  final double? longitude;
  final String? coverImage;
  final EventPoliciesModel? policies;

  factory EventDetailModel.fromJson(Map<String, dynamic> json) {
    final content = json['content'];
    final organizerData = json['organizer'] ?? json['admin'];
    final organizerObj = organizerData != null
        ? OrganizerModel.fromJson(organizerData)
        : null;

    return EventDetailModel(
      id: content['id'],
      title: content['title'],
      policies: content['policies'] != null
          ? EventPoliciesModel.fromJson(content['policies'])
          : null,
      thumbnail: () {
        final thumb =
            content['cover'] ?? content['image'] ?? content['thumbnail'] ?? '';
        return (thumb.isNotEmpty && !thumb.toString().startsWith('http'))
            ? '${AppConstants.imageBaseUrl}$thumb'
            : thumb;
      }(),
      address: content['address'],
      date: content['start_date'],
      time: content['start_time'],
      endDate: content['end_date'],
      endTime: content['end_time'],
      organizer: organizerObj?.name, // Pass name string to parent
      description: content['description'] ?? '',
      refundPolicy: content['refund_policy'],
      images:
          (json['images'] as List?)
              ?.map((e) {
                final img = e['image']?.toString() ?? '';
                if (img.isEmpty) return null;
                return (img.startsWith('http'))
                    ? img
                    : '${AppConstants.eventCoverBaseUrl}$img';
              })
              .whereType<String>()
              .toList() ??
          [],
      tickets:
          (json['tickets'] as List?)
              ?.map((e) => TicketModel.fromJson(e))
              .toList() ??
          [],
      lineup:
          (json['lineup'] as List?)
              ?.whereType<Map>()
              .map(
                (e) => EventLineupModel.fromJson(Map<String, dynamic>.from(e)),
              )
              .toList() ??
          [],
      rewards:
          (json['rewards'] as List?)
              ?.whereType<Map>()
              .map(
                (e) => EventRewardSummaryModel.fromJson(Map<String, dynamic>.from(e)),
              )
              .toList() ??
          [],
      coverImage: () {
        final cover =
            content['cover'] ?? content['image'] ?? content['thumbnail'] ?? '';
        final coverStr = cover.toString();
        if (coverStr.isEmpty) return null;
        return (coverStr.startsWith('http'))
            ? coverStr
            : '${AppConstants.eventCoverBaseUrl}$coverStr';
      }(),
      organizerModel: organizerObj,
      latitude: double.tryParse(
        content['latitude']?.toString() ?? content['lat']?.toString() ?? '',
      ),
      longitude: double.tryParse(
        content['longitude']?.toString() ?? content['lng']?.toString() ?? '',
      ),
      venue: content['venue'] != null
          ? VenueModel.fromJson(content['venue'])
          : null,
      inventory: json['inventory'] is Map<String, dynamic>
          ? EventInventorySummaryModel.fromJson(json['inventory'])
          : (json['inventory'] is Map
                ? EventInventorySummaryModel.fromJson(
                    Map<String, dynamic>.from(json['inventory'] as Map),
                  )
                : null),
      waitlist: json['waitlist'] is Map<String, dynamic>
          ? EventWaitlistSummaryModel.fromJson(json['waitlist'])
          : (json['waitlist'] is Map
                ? EventWaitlistSummaryModel.fromJson(
                    Map<String, dynamic>.from(json['waitlist'] as Map),
                  )
                : null),
      wishlistCount: json['wishlist_count'] ?? 0,
      isWishlisted: json['is_wishlisted'] ?? false,
      social: json['social'] is Map<String, dynamic>
          ? EventSocialSummaryModel.fromJson(json['social'])
          : (json['social'] is Map
                ? EventSocialSummaryModel.fromJson(
                    Map<String, dynamic>.from(json['social'] as Map),
                  )
                : null),
    );
  }
  @override
  String toString() {
    return 'EventDetailModel(id: $id, title: $title, thumbnail: $thumbnail, address: $address, date: $date, time: $time, organizer: $organizer, description: $description, refundPolicy: $refundPolicy, images: $images, tickets: $tickets, lineup: $lineup, organizerModel: $organizerModel, coverImage: $coverImage, lat: $latitude, lng: $longitude)';
  }
}

class EventWaitlistSummaryModel {
  final int waitlistCount;
  final bool viewerSubscribed;

  const EventWaitlistSummaryModel({
    required this.waitlistCount,
    required this.viewerSubscribed,
  });

  factory EventWaitlistSummaryModel.fromJson(Map<String, dynamic> json) {
    bool parseBool(dynamic value) {
      if (value is bool) return value;
      if (value is num) return value != 0;
      return value?.toString().toLowerCase() == 'true';
    }

    return EventWaitlistSummaryModel(
      waitlistCount: int.tryParse(json['waitlist_count']?.toString() ?? '') ?? 0,
      viewerSubscribed: parseBool(json['viewer_waitlist_subscribed']),
    );
  }
}

class EventInventorySummaryModel {
  final bool hasPrimaryInventory;
  final bool primaryInventoryLimited;
  final int? primaryAvailableTickets;
  final int primaryTicketsSold;
  final int? primaryTotalInventory;
  final double? primarySellThroughPercent;
  final bool primarySoldOut;
  final bool lowStock;
  final int? lowStockCount;
  final int marketplaceAvailableCount;
  final bool showMarketplaceFallback;
  final bool showWaitlistCta;
  final String availabilityState;
  final String demandLabel;

  const EventInventorySummaryModel({
    required this.hasPrimaryInventory,
    required this.primaryInventoryLimited,
    required this.primaryAvailableTickets,
    required this.primaryTicketsSold,
    required this.primaryTotalInventory,
    required this.primarySellThroughPercent,
    required this.primarySoldOut,
    required this.lowStock,
    required this.lowStockCount,
    required this.marketplaceAvailableCount,
    required this.showMarketplaceFallback,
    required this.showWaitlistCta,
    required this.availabilityState,
    required this.demandLabel,
  });

  factory EventInventorySummaryModel.fromJson(Map<String, dynamic> json) {
    bool parseBool(dynamic value) {
      if (value is bool) return value;
      if (value is num) return value != 0;
      return value?.toString().toLowerCase() == 'true';
    }

    return EventInventorySummaryModel(
      hasPrimaryInventory: parseBool(json['has_primary_inventory']),
      primaryInventoryLimited: parseBool(json['primary_inventory_limited']),
      primaryAvailableTickets: int.tryParse(
        json['primary_available_tickets']?.toString() ?? '',
      ),
      primaryTicketsSold:
          int.tryParse(json['primary_tickets_sold']?.toString() ?? '') ?? 0,
      primaryTotalInventory: int.tryParse(
        json['primary_total_inventory']?.toString() ?? '',
      ),
      primarySellThroughPercent: double.tryParse(
        json['primary_sell_through_percent']?.toString() ?? '',
      ),
      primarySoldOut: parseBool(json['primary_sold_out']),
      lowStock: parseBool(json['low_stock']),
      lowStockCount: int.tryParse(json['low_stock_count']?.toString() ?? ''),
      marketplaceAvailableCount:
          int.tryParse(json['marketplace_available_count']?.toString() ?? '') ??
          0,
      showMarketplaceFallback: parseBool(json['show_marketplace_fallback']),
      showWaitlistCta: parseBool(json['show_waitlist_cta']),
      availabilityState: json['availability_state']?.toString() ?? 'available',
      demandLabel: json['demand_label']?.toString() ?? 'Tickets disponibles',
    );
  }

  bool get hasTrackedOfficialInventory => primaryAvailableTickets != null;
}

class EventLineupModel {
  final String key;
  final String sourceType;
  final String displayName;
  final int? artistId;
  final int sortOrder;
  final bool isHeadliner;

  const EventLineupModel({
    required this.key,
    required this.sourceType,
    required this.displayName,
    this.artistId,
    required this.sortOrder,
    required this.isHeadliner,
  });

  bool get hasProfile => artistId != null && artistId! > 0;

  String get badgeLabel => isHeadliner ? 'HEADLINER' : 'LINEUP';

  factory EventLineupModel.fromJson(Map<String, dynamic> json) {
    bool asBool(dynamic value) {
      if (value == null) return false;
      if (value is bool) return value;
      if (value is num) return value != 0;
      return value.toString().toLowerCase() == 'true';
    }

    return EventLineupModel(
      key: json['key']?.toString() ?? '',
      sourceType: json['source_type']?.toString() ?? 'manual',
      displayName: json['display_name']?.toString() ?? 'Special guest',
      artistId: int.tryParse(json['artist_id']?.toString() ?? ''),
      sortOrder: int.tryParse(json['sort_order']?.toString() ?? '') ?? 0,
      isHeadliner: asBool(json['is_headliner']),
    );
  }

  @override
  String toString() {
    return 'EventLineupModel(key: $key, sourceType: $sourceType, displayName: $displayName, artistId: $artistId, sortOrder: $sortOrder, isHeadliner: $isHeadliner)';
  }
}

class TicketModel {
  final int id;
  final String title;
  final double price;
  final String? pricingType;
  final bool available;
  final String? maxTicketBuyType;
  final int? maxBuyTicket;
  final bool purchaseLimitReached;
  final int alreadyPurchasedQty;
  final int? remainingPurchaseQty;
  final bool reservationEnabled;
  final String? reservationDepositType;
  final double? reservationDepositValue;
  final DateTime? reservationFinalDueDate;
  final double? reservationMinimumInstallmentAmount;
  final double? basePrice;
  final double? currentPrice;
  final bool hasPriceSchedule;
  final double? nextPrice;
  final DateTime? nextPriceEffectiveFrom;
  final String? saleStatus;
  final int? gateTicketId;
  final String? gateTrigger;

  TicketModel({
    required this.id,
    required this.title,
    required this.price,
    this.pricingType,
    required this.available,
    this.maxTicketBuyType,
    this.maxBuyTicket,
    required this.purchaseLimitReached,
    required this.alreadyPurchasedQty,
    this.remainingPurchaseQty,
    required this.reservationEnabled,
    this.reservationDepositType,
    this.reservationDepositValue,
    this.reservationFinalDueDate,
    this.reservationMinimumInstallmentAmount,
    this.basePrice,
    this.currentPrice,
    required this.hasPriceSchedule,
    this.nextPrice,
    this.nextPriceEffectiveFrom,
    this.saleStatus,
    this.gateTicketId,
    this.gateTrigger,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    final maxBuyTicket = int.tryParse(json['max_buy_ticket']?.toString() ?? '');
    final purchaseStatusRaw = json['purchase_status']?.toString().toLowerCase();
    final purchaseQty =
        int.tryParse(json['purchase_qty']?.toString() ?? '') ?? 0;
    final remainingPurchaseQty = int.tryParse(
      json['remaining_purchase_qty']?.toString() ?? '',
    );

    return TicketModel(
      id: json['id'],
      title: json['title'] ?? 'Ticket',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      pricingType: json['pricing_type'],
      available:
          (json['ticket_stock'] == null ||
          ((json['ticket_stock'] is int && json['ticket_stock'] > 0) ||
              (json['ticket_stock'] is String &&
                  (int.tryParse(json['ticket_stock']) ?? 0) > 0))),
      maxTicketBuyType: json['max_ticket_buy_type']?.toString(),
      maxBuyTicket: maxBuyTicket,
      purchaseLimitReached:
          purchaseStatusRaw == 'true' ||
          purchaseStatusRaw == '1' ||
          purchaseStatusRaw == 'reached',
      alreadyPurchasedQty: purchaseQty,
      remainingPurchaseQty: remainingPurchaseQty,
      reservationEnabled:
          json['reservation_enabled'] == true ||
          json['reservation_enabled'] == 1 ||
          json['reservation_enabled'] == '1',
      reservationDepositType: json['reservation_deposit_type']?.toString(),
      reservationDepositValue: double.tryParse(
        json['reservation_deposit_value']?.toString() ?? '',
      ),
      reservationFinalDueDate: DateTime.tryParse(
        json['reservation_final_due_date']?.toString() ?? '',
      ),
      reservationMinimumInstallmentAmount: double.tryParse(
        json['reservation_min_installment_amount']?.toString() ?? '',
      ),
      basePrice: double.tryParse(json['base_price']?.toString() ?? ''),
      currentPrice: double.tryParse(json['current_price']?.toString() ?? ''),
      hasPriceSchedule:
          json['has_price_schedule'] == true ||
          json['has_price_schedule'] == 1 ||
          json['has_price_schedule'] == '1',
      nextPrice: double.tryParse(
        json['next_price']?.toString() ??
            json['next_price_schedule']?['price']?.toString() ??
            '',
      ),
      nextPriceEffectiveFrom: DateTime.tryParse(
        json['next_price_effective_from']?.toString() ??
            json['next_price_schedule']?['effective_from']?.toString() ??
            '',
      ),
      saleStatus: json['sale_status']?.toString(),
      gateTicketId: int.tryParse(json['gate_ticket_id']?.toString() ?? ''),
      gateTrigger: json['gate_trigger']?.toString(),
    );
  }

  bool get hasPurchaseLimit =>
      (maxTicketBuyType ?? '').toLowerCase() == 'limited' &&
      (maxBuyTicket ?? 0) > 0;

  int? get maxPurchasePerUser => hasPurchaseLimit ? maxBuyTicket : null;

  int? get remainingPurchaseAllowance {
    if (!hasPurchaseLimit) {
      return null;
    }

    if (remainingPurchaseQty != null) {
      return remainingPurchaseQty! < 0 ? 0 : remainingPurchaseQty;
    }

    final computed = (maxBuyTicket ?? 0) - alreadyPurchasedQty;
    if (computed <= 0) {
      return 0;
    }

    final maxAllowed = maxBuyTicket ?? 0;
    return computed > maxAllowed ? maxAllowed : computed;
  }

  /// Whether this ticket is gated behind another ticket and not yet on sale.
  bool get isGated =>
      gateTicketId != null &&
      (saleStatus ?? 'active').toLowerCase() == 'paused';
}

class EventSocialSummaryModel {
  final int interestedCount;
  final int visibleInterestedCount;
  final int attendingCount;
  final int visibleAttendingCount;
  final List<EventSocialPersonModel> interestedPeople;
  final List<EventSocialPersonModel> followedInterestedPeople;
  final List<EventSocialPersonModel> attendingPeople;

  const EventSocialSummaryModel({
    required this.interestedCount,
    required this.visibleInterestedCount,
    required this.attendingCount,
    required this.visibleAttendingCount,
    required this.interestedPeople,
    required this.followedInterestedPeople,
    required this.attendingPeople,
  });

  bool get hasAnyData =>
      interestedCount > 0 ||
      attendingCount > 0 ||
      interestedPeople.isNotEmpty ||
      attendingPeople.isNotEmpty;

  factory EventSocialSummaryModel.fromJson(Map<String, dynamic> json) {
    List<EventSocialPersonModel> parsePeople(String key) {
      final raw = json[key];
      if (raw is! List) return const [];
      return raw
          .whereType<Map>()
          .map(
            (item) => EventSocialPersonModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    }

    return EventSocialSummaryModel(
      interestedCount:
          int.tryParse(json['interested_count']?.toString() ?? '') ?? 0,
      visibleInterestedCount:
          int.tryParse(json['visible_interested_count']?.toString() ?? '') ?? 0,
      attendingCount:
          int.tryParse(json['attending_count']?.toString() ?? '') ?? 0,
      visibleAttendingCount:
          int.tryParse(json['visible_attending_count']?.toString() ?? '') ?? 0,
      interestedPeople: parsePeople('interested_people'),
      followedInterestedPeople: parsePeople('followed_interested_people'),
      attendingPeople: parsePeople('attending_people'),
    );
  }
}

class EventSocialPersonModel {
  final int id;
  final String name;
  final String? username;
  final String? photo;
  final bool isFollowing;

  const EventSocialPersonModel({
    required this.id,
    required this.name,
    this.username,
    this.photo,
    required this.isFollowing,
  });

  factory EventSocialPersonModel.fromJson(Map<String, dynamic> json) {
    bool asBool(dynamic value) {
      if (value == null) return false;
      if (value is bool) return value;
      if (value is num) return value != 0;
      return value.toString().toLowerCase() == 'true';
    }

    return EventSocialPersonModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? 'Duty user',
      username: json['username']?.toString(),
      photo: json['photo']?.toString(),
      isFollowing: asBool(json['is_following']),
    );
  }
}

class EventPoliciesModel {
  final bool adultAgeRestrictions;

  EventPoliciesModel({required this.adultAgeRestrictions});

  factory EventPoliciesModel.fromJson(Map<String, dynamic> json) {
    return EventPoliciesModel(
      adultAgeRestrictions: json['adultAgeRestrictions'] ?? false,
    );
  }
}
