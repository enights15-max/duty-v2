class ProfessionalEventTicketsPayload {
  final ProfessionalManagedEvent event;
  final List<ProfessionalManagedTicket> tickets;
  final String identityType;
  final bool canManageTicketing;

  const ProfessionalEventTicketsPayload({
    required this.event,
    required this.tickets,
    required this.identityType,
    required this.canManageTicketing,
  });

  factory ProfessionalEventTicketsPayload.fromJson(Map<String, dynamic> json) {
    final eventJson = json['event'] is Map<String, dynamic>
        ? json['event'] as Map<String, dynamic>
        : json['event'] is Map
        ? Map<String, dynamic>.from(json['event'] as Map)
        : const <String, dynamic>{};
    final permissionsJson = json['permissions'] is Map<String, dynamic>
        ? json['permissions'] as Map<String, dynamic>
        : json['permissions'] is Map
        ? Map<String, dynamic>.from(json['permissions'] as Map)
        : const <String, dynamic>{};
    final ticketJson = json['tickets'] is List
        ? json['tickets'] as List
        : const [];

    return ProfessionalEventTicketsPayload(
      event: ProfessionalManagedEvent.fromJson(eventJson),
      tickets: ticketJson
          .map(
            (item) => ProfessionalManagedTicket.fromJson(
              item is Map<String, dynamic>
                  ? item
                  : Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      identityType: permissionsJson['identity_type']?.toString() ?? '',
      canManageTicketing: _parseBool(permissionsJson['can_manage_ticketing']),
    );
  }
}

class ProfessionalManagedEvent {
  final int id;
  final String title;
  final String eventType;
  final String? reviewStatus;
  final int status;
  final String? managedByType;
  final int? managedByIdentityId;
  final int? hostingVenueId;
  final int? hostingVenueIdentityId;
  final String? hostingVenueName;

  const ProfessionalManagedEvent({
    required this.id,
    required this.title,
    required this.eventType,
    required this.reviewStatus,
    required this.status,
    required this.managedByType,
    required this.managedByIdentityId,
    required this.hostingVenueId,
    required this.hostingVenueIdentityId,
    required this.hostingVenueName,
  });

  factory ProfessionalManagedEvent.fromJson(Map<String, dynamic> json) {
    final managementSummary = json['management_summary'];
    final managementMap = managementSummary is Map<String, dynamic>
        ? managementSummary
        : managementSummary is Map
        ? Map<String, dynamic>.from(managementSummary)
        : const <String, dynamic>{};
    final hostingVenueSummary = json['hosting_venue_summary'];
    final hostingVenueMap = hostingVenueSummary is Map<String, dynamic>
        ? hostingVenueSummary
        : hostingVenueSummary is Map
        ? Map<String, dynamic>.from(hostingVenueSummary)
        : const <String, dynamic>{};

    return ProfessionalManagedEvent(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title: json['title']?.toString() ?? 'Evento',
      eventType: json['event_type']?.toString() ?? 'venue',
      reviewStatus: json['review_status']?.toString(),
      status: int.tryParse(json['status']?.toString() ?? '') ?? 0,
      managedByType: managementMap['managed_by_type']?.toString(),
      managedByIdentityId: int.tryParse(
        managementMap['managed_by_identity_id']?.toString() ?? '',
      ),
      hostingVenueId: int.tryParse(
        hostingVenueMap['venue_id']?.toString() ?? '',
      ),
      hostingVenueIdentityId: int.tryParse(
        hostingVenueMap['venue_identity_id']?.toString() ?? '',
      ),
      hostingVenueName: hostingVenueMap['name']?.toString(),
    );
  }

  String? get managementLabel {
    switch (managedByType) {
      case 'organizer':
        return 'Gestionado por organizer';
      case 'venue':
        return 'Gestionado por venue';
      default:
        return null;
    }
  }

  bool get shouldShowHostingVenueContext =>
      managedByType == 'organizer' &&
      hostingVenueId != null &&
      (hostingVenueName?.trim().isNotEmpty ?? false);
}

class ProfessionalManagedTicket {
  final int id;
  final String title;
  final String? description;
  final String pricingType;
  final double? price;
  final double currentPrice;
  final double basePrice;
  final ProfessionalTicketSchedule? currentSchedule;
  final ProfessionalTicketSchedule? nextSchedule;
  final String ticketAvailableType;
  final int? ticketAvailable;
  final String maxTicketBuyType;
  final int? maxBuyTicket;
  final String earlyBirdDiscountType;
  final String discountType;
  final double? earlyBirdDiscountAmount;
  final String? earlyBirdDiscountDate;
  final String? earlyBirdDiscountTime;
  final bool reservationEnabled;
  final String? reservationDepositType;
  final double? reservationDepositValue;
  final String? reservationFinalDueDate;
  final double? reservationMinInstallmentAmount;
  final bool allowPromotionalResale;
  final String saleStatus;
  final String? archivedAt;
  final ProfessionalManagedTicketAnalytics analytics;
  final List<ProfessionalManagedTicketVariation> variations;
  final List<ProfessionalTicketSchedule> priceSchedules;
  final bool mobileEditingSupported;
  final String? mobileEditingReason;
  final int? gateTicketId;
  final String? gateTrigger;
  final String? gateTriggerDate;

  const ProfessionalManagedTicket({
    required this.id,
    required this.title,
    required this.description,
    required this.pricingType,
    required this.price,
    required this.currentPrice,
    required this.basePrice,
    required this.currentSchedule,
    required this.nextSchedule,
    required this.ticketAvailableType,
    required this.ticketAvailable,
    required this.maxTicketBuyType,
    required this.maxBuyTicket,
    required this.earlyBirdDiscountType,
    required this.discountType,
    required this.earlyBirdDiscountAmount,
    required this.earlyBirdDiscountDate,
    required this.earlyBirdDiscountTime,
    required this.reservationEnabled,
    required this.reservationDepositType,
    required this.reservationDepositValue,
    required this.reservationFinalDueDate,
    required this.reservationMinInstallmentAmount,
    required this.allowPromotionalResale,
    required this.saleStatus,
    required this.archivedAt,
    required this.analytics,
    required this.variations,
    required this.priceSchedules,
    required this.mobileEditingSupported,
    required this.mobileEditingReason,
    this.gateTicketId,
    this.gateTrigger,
    this.gateTriggerDate,
  });

  factory ProfessionalManagedTicket.fromJson(Map<String, dynamic> json) {
    final analyticsJson = json['analytics'] is Map<String, dynamic>
        ? json['analytics'] as Map<String, dynamic>
        : json['analytics'] is Map
        ? Map<String, dynamic>.from(json['analytics'] as Map)
        : const <String, dynamic>{};
    final variationJson = json['variations'] is List
        ? json['variations'] as List
        : const [];
    final scheduleJson = json['price_schedules'] is List
        ? json['price_schedules'] as List
        : const [];

    return ProfessionalManagedTicket(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title: json['title']?.toString() ?? 'Ticket',
      description: json['description']?.toString(),
      pricingType: json['pricing_type']?.toString() ?? 'normal',
      price: _tryParseDouble(json['price']),
      currentPrice: _tryParseDouble(json['current_price']) ?? 0,
      basePrice: _tryParseDouble(json['base_price']) ?? 0,
      currentSchedule: json['current_schedule'] is Map<String, dynamic>
          ? ProfessionalTicketSchedule.fromJson(
              json['current_schedule'] as Map<String, dynamic>,
            )
          : json['current_schedule'] is Map
          ? ProfessionalTicketSchedule.fromJson(
              Map<String, dynamic>.from(json['current_schedule'] as Map),
            )
          : null,
      nextSchedule: json['next_schedule'] is Map<String, dynamic>
          ? ProfessionalTicketSchedule.fromJson(
              json['next_schedule'] as Map<String, dynamic>,
            )
          : json['next_schedule'] is Map
          ? ProfessionalTicketSchedule.fromJson(
              Map<String, dynamic>.from(json['next_schedule'] as Map),
            )
          : null,
      ticketAvailableType:
          json['ticket_available_type']?.toString() ?? 'unlimited',
      ticketAvailable: int.tryParse(json['ticket_available']?.toString() ?? ''),
      maxTicketBuyType: json['max_ticket_buy_type']?.toString() ?? 'unlimited',
      maxBuyTicket: int.tryParse(json['max_buy_ticket']?.toString() ?? ''),
      earlyBirdDiscountType:
          json['early_bird_discount_type']?.toString() ?? 'disable',
      discountType: json['discount_type']?.toString() ?? 'fixed',
      earlyBirdDiscountAmount: _tryParseDouble(
        json['early_bird_discount_amount'],
      ),
      earlyBirdDiscountDate: json['early_bird_discount_date']?.toString(),
      earlyBirdDiscountTime: json['early_bird_discount_time']?.toString(),
      reservationEnabled: _parseBool(json['reservation_enabled']),
      reservationDepositType: json['reservation_deposit_type']?.toString(),
      reservationDepositValue: _tryParseDouble(
        json['reservation_deposit_value'],
      ),
      reservationFinalDueDate: json['reservation_final_due_date']?.toString(),
      reservationMinInstallmentAmount: _tryParseDouble(
        json['reservation_min_installment_amount'],
      ),
      allowPromotionalResale: _parseBool(json['allow_promotional_resale']),
      saleStatus: json['sale_status']?.toString() ?? 'active',
      archivedAt: json['archived_at']?.toString(),
      analytics: ProfessionalManagedTicketAnalytics.fromJson(analyticsJson),
      variations: variationJson
          .map(
            (item) => ProfessionalManagedTicketVariation.fromJson(
              item is Map<String, dynamic>
                  ? item
                  : Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      priceSchedules: scheduleJson
          .map(
            (item) => ProfessionalTicketSchedule.fromJson(
              item is Map<String, dynamic>
                  ? item
                  : Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      mobileEditingSupported: _parseBool(json['mobile_editing_supported']),
      mobileEditingReason: json['mobile_editing_reason']?.toString(),
      gateTicketId: int.tryParse(json['gate_ticket_id']?.toString() ?? ''),
      gateTrigger: json['gate_trigger']?.toString(),
      gateTriggerDate: json['gate_trigger_date']?.toString(),
    );
  }

  /// Whether this ticket is gated behind another ticket.
  bool get isGated => gateTicketId != null;
}

class ProfessionalManagedTicketAnalytics {
  final int? available;
  final int sold;
  final int reserved;
  final int? totalInventory;
  final double? sellThroughPercent;

  const ProfessionalManagedTicketAnalytics({
    required this.available,
    required this.sold,
    required this.reserved,
    required this.totalInventory,
    required this.sellThroughPercent,
  });

  factory ProfessionalManagedTicketAnalytics.fromJson(
    Map<String, dynamic> json,
  ) {
    return ProfessionalManagedTicketAnalytics(
      available: int.tryParse(json['available']?.toString() ?? ''),
      sold: int.tryParse(json['sold']?.toString() ?? '0') ?? 0,
      reserved: int.tryParse(json['reserved']?.toString() ?? '0') ?? 0,
      totalInventory: int.tryParse(json['total_inventory']?.toString() ?? ''),
      sellThroughPercent: _tryParseDouble(json['sell_through_percent']),
    );
  }
}

class ProfessionalManagedTicketVariation {
  final String key;
  final String name;
  final double price;
  final String ticketAvailableType;
  final int? ticketAvailable;
  final String maxTicketBuyType;
  final int? maxBuyTicket;
  final int sold;
  final int reserved;
  final bool mobileEditingSupported;

  const ProfessionalManagedTicketVariation({
    required this.key,
    required this.name,
    required this.price,
    required this.ticketAvailableType,
    required this.ticketAvailable,
    required this.maxTicketBuyType,
    required this.maxBuyTicket,
    required this.sold,
    required this.reserved,
    required this.mobileEditingSupported,
  });

  factory ProfessionalManagedTicketVariation.fromJson(
    Map<String, dynamic> json,
  ) {
    return ProfessionalManagedTicketVariation(
      key: json['key']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Variación',
      price: _tryParseDouble(json['price']) ?? 0,
      ticketAvailableType:
          json['ticket_available_type']?.toString() ?? 'limited',
      ticketAvailable: int.tryParse(json['ticket_available']?.toString() ?? ''),
      maxTicketBuyType: json['max_ticket_buy_type']?.toString() ?? 'limited',
      maxBuyTicket: int.tryParse(json['max_buy_ticket']?.toString() ?? ''),
      sold: int.tryParse(json['sold']?.toString() ?? '0') ?? 0,
      reserved: int.tryParse(json['reserved']?.toString() ?? '0') ?? 0,
      mobileEditingSupported: _parseBool(json['mobile_editing_supported']),
    );
  }
}

class ProfessionalTicketSchedule {
  final int? id;
  final String? label;
  final String? effectiveFrom;
  final double price;
  final int sortOrder;
  final bool isActive;

  const ProfessionalTicketSchedule({
    required this.id,
    required this.label,
    required this.effectiveFrom,
    required this.price,
    required this.sortOrder,
    required this.isActive,
  });

  factory ProfessionalTicketSchedule.fromJson(Map<String, dynamic> json) {
    return ProfessionalTicketSchedule(
      id: int.tryParse(json['id']?.toString() ?? ''),
      label: json['label']?.toString(),
      effectiveFrom: json['effective_from']?.toString(),
      price: _tryParseDouble(json['price']) ?? 0,
      sortOrder: int.tryParse(json['sort_order']?.toString() ?? '0') ?? 0,
      isActive: _parseBool(json['is_active']),
    );
  }
}

double? _tryParseDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

bool _parseBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  return value?.toString().toLowerCase() == 'true';
}
