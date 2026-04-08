import 'professional_collaboration_summary_model.dart';

class ProfessionalEventSummaryModel {
  final int id;
  final String title;
  final String eventType;
  final String dateType;
  final int status;
  final String? reviewStatus;
  final String? reviewNotes;
  final String? startDate;
  final String? startTime;
  final String? endDate;
  final String? endTime;
  final String? venueSource;
  final String? venueName;
  final String? venueCity;
  final int? hostingVenueId;
  final int? hostingVenueIdentityId;
  final String? managedByType;
  final int? managedByIdentityId;
  final int? managedByLegacyId;
  final String? thumbnailUrl;
  final bool mobileAuthoringSupported;
  final String? mobileAuthoringReason;
  final ProfessionalEventInventorySummary? inventory;
  final ProfessionalEventTreasurySummary? treasurySummary;
  final ProfessionalEventCollaborationSummary? collaborationSummary;

  const ProfessionalEventSummaryModel({
    required this.id,
    required this.title,
    required this.eventType,
    required this.dateType,
    required this.status,
    this.reviewStatus,
    this.reviewNotes,
    this.startDate,
    this.startTime,
    this.endDate,
    this.endTime,
    this.venueSource,
    this.venueName,
    this.venueCity,
    this.hostingVenueId,
    this.hostingVenueIdentityId,
    this.managedByType,
    this.managedByIdentityId,
    this.managedByLegacyId,
    this.thumbnailUrl,
    this.mobileAuthoringSupported = false,
    this.mobileAuthoringReason,
    this.inventory,
    this.treasurySummary,
    this.collaborationSummary,
  });

  factory ProfessionalEventSummaryModel.fromJson(Map<String, dynamic> json) {
    final venueSummary = json['venue_summary'];
    final venueMap = venueSummary is Map<String, dynamic>
        ? venueSummary
        : venueSummary is Map
        ? Map<String, dynamic>.from(venueSummary)
        : const <String, dynamic>{};
    final hostingVenueSummary = json['hosting_venue_summary'];
    final hostingVenueMap = hostingVenueSummary is Map<String, dynamic>
        ? hostingVenueSummary
        : hostingVenueSummary is Map
        ? Map<String, dynamic>.from(hostingVenueSummary)
        : venueMap;
    final managementSummary = json['management_summary'];
    final managementMap = managementSummary is Map<String, dynamic>
        ? managementSummary
        : managementSummary is Map
        ? Map<String, dynamic>.from(managementSummary)
        : const <String, dynamic>{};
    final inventoryJson = json['inventory'] is Map<String, dynamic>
        ? json['inventory'] as Map<String, dynamic>
        : json['inventory'] is Map
        ? Map<String, dynamic>.from(json['inventory'] as Map)
        : null;
    final treasuryJson = json['treasury_summary'] is Map<String, dynamic>
        ? json['treasury_summary'] as Map<String, dynamic>
        : json['treasury_summary'] is Map
        ? Map<String, dynamic>.from(json['treasury_summary'] as Map)
        : null;
    final collaborationJson =
        json['collaboration_summary'] is Map<String, dynamic>
        ? json['collaboration_summary'] as Map<String, dynamic>
        : json['collaboration_summary'] is Map
        ? Map<String, dynamic>.from(json['collaboration_summary'] as Map)
        : null;

    return ProfessionalEventSummaryModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title: json['title']?.toString().trim().isNotEmpty == true
          ? json['title'].toString().trim()
          : 'Untitled event',
      eventType: json['event_type']?.toString() ?? '',
      dateType: json['date_type']?.toString() ?? '',
      status: int.tryParse(json['status']?.toString() ?? '') ?? 0,
      reviewStatus: json['review_status']?.toString(),
      reviewNotes: json['review_notes']?.toString(),
      startDate: json['start_date']?.toString(),
      startTime: json['start_time']?.toString(),
      endDate: json['end_date']?.toString(),
      endTime: json['end_time']?.toString(),
      venueSource: json['venue_source']?.toString(),
      venueName: hostingVenueMap['name']?.toString(),
      venueCity: hostingVenueMap['city']?.toString(),
      hostingVenueId: int.tryParse(
        hostingVenueMap['venue_id']?.toString() ?? '',
      ),
      hostingVenueIdentityId: int.tryParse(
        hostingVenueMap['venue_identity_id']?.toString() ?? '',
      ),
      managedByType: managementMap['managed_by_type']?.toString(),
      managedByIdentityId: int.tryParse(
        managementMap['managed_by_identity_id']?.toString() ?? '',
      ),
      managedByLegacyId: int.tryParse(
        managementMap['managed_by_legacy_id']?.toString() ?? '',
      ),
      thumbnailUrl: json['thumbnail_url']?.toString(),
      mobileAuthoringSupported: json['mobile_authoring_supported'] == true,
      mobileAuthoringReason: json['mobile_authoring_reason']?.toString(),
      inventory: inventoryJson == null
          ? null
          : ProfessionalEventInventorySummary.fromJson(inventoryJson),
      treasurySummary: treasuryJson == null
          ? null
          : ProfessionalEventTreasurySummary.fromJson(treasuryJson),
      collaborationSummary: collaborationJson == null
          ? null
          : ProfessionalEventCollaborationSummary.fromJson(collaborationJson),
    );
  }

  String get statusLabel {
    switch (reviewStatus) {
      case 'pending':
        return 'En revisión';
      case 'approved':
        return 'Aprobado';
      case 'changes_requested':
        return 'Cambios solicitados';
      case 'rejected':
        return 'Rechazado';
    }

    switch (status) {
      case 1:
        return 'Publicado';
      case 2:
        return 'Borrador';
      default:
        return 'Estado $status';
    }
  }

  bool get isOrganizerManaged => managedByType == 'organizer';

  bool get isVenueManaged => managedByType == 'venue';

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

  String? get hostingVenueLabel {
    final name = venueName?.trim();
    if (name == null || name.isEmpty) {
      return null;
    }

    return 'Venue anfitrión: $name';
  }

  bool get shouldShowHostingVenueContext =>
      isOrganizerManaged &&
      venueSource == 'registered' &&
      hostingVenueId != null &&
      (venueName?.trim().isNotEmpty ?? false);

  bool get canClaimTreasuryNow => treasurySummary?.canReleaseNow == true;

  String? get claimableAmountLabel {
    final amount = treasurySummary?.claimableAmount ?? 0;
    if (amount <= 0) {
      return null;
    }

    return 'RD\$${amount.toStringAsFixed(2)}';
  }
}

class ProfessionalEventInventorySummary {
  final int? primaryAvailableTickets;
  final int primaryTicketsSold;
  final int? primaryTotalInventory;
  final double? primarySellThroughPercent;
  final bool primarySoldOut;
  final bool lowStock;
  final int marketplaceAvailableCount;
  final bool showMarketplaceFallback;
  final String availabilityState;
  final String demandLabel;

  const ProfessionalEventInventorySummary({
    required this.primaryAvailableTickets,
    required this.primaryTicketsSold,
    required this.primaryTotalInventory,
    required this.primarySellThroughPercent,
    required this.primarySoldOut,
    required this.lowStock,
    required this.marketplaceAvailableCount,
    required this.showMarketplaceFallback,
    required this.availabilityState,
    required this.demandLabel,
  });

  factory ProfessionalEventInventorySummary.fromJson(
    Map<String, dynamic> json,
  ) {
    bool parseBool(dynamic value) {
      if (value is bool) return value;
      if (value is num) return value != 0;
      return value?.toString().toLowerCase() == 'true';
    }

    return ProfessionalEventInventorySummary(
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
      marketplaceAvailableCount:
          int.tryParse(json['marketplace_available_count']?.toString() ?? '') ??
          0,
      showMarketplaceFallback: parseBool(json['show_marketplace_fallback']),
      availabilityState: json['availability_state']?.toString() ?? 'available',
      demandLabel: json['demand_label']?.toString() ?? 'Tickets disponibles',
    );
  }
}

class ProfessionalEventTreasurySummary {
  final String status;
  final bool eventCompleted;
  final String? eventEndedAt;
  final String? holdUntil;
  final int? remainingHoldHours;
  final bool requiresAdminApproval;
  final bool autoPayoutEnabled;
  final double grossCollected;
  final double refundedAmount;
  final double netCollected;
  final double platformFeeTotal;
  final double reservedForOwner;
  final double reservedForCollaborators;
  final double releasedToWallet;
  final double availableForSettlement;
  final double claimableAmount;
  final bool canReleaseNow;

  const ProfessionalEventTreasurySummary({
    required this.status,
    required this.eventCompleted,
    required this.eventEndedAt,
    required this.holdUntil,
    required this.remainingHoldHours,
    required this.requiresAdminApproval,
    required this.autoPayoutEnabled,
    required this.grossCollected,
    required this.refundedAmount,
    required this.netCollected,
    required this.platformFeeTotal,
    required this.reservedForOwner,
    required this.reservedForCollaborators,
    required this.releasedToWallet,
    required this.availableForSettlement,
    required this.claimableAmount,
    required this.canReleaseNow,
  });

  factory ProfessionalEventTreasurySummary.fromJson(Map<String, dynamic> json) {
    bool parseBool(dynamic value) {
      if (value is bool) return value;
      if (value is num) return value != 0;
      return value?.toString().toLowerCase() == 'true';
    }

    double parseDouble(dynamic value) {
      return double.tryParse(value?.toString() ?? '0') ?? 0;
    }

    return ProfessionalEventTreasurySummary(
      status: json['status']?.toString() ?? 'collecting',
      eventCompleted: parseBool(json['event_completed']),
      eventEndedAt: json['event_ended_at']?.toString(),
      holdUntil: json['hold_until']?.toString(),
      remainingHoldHours: int.tryParse(
        json['remaining_hold_hours']?.toString() ?? '',
      ),
      requiresAdminApproval: parseBool(json['requires_admin_approval']),
      autoPayoutEnabled: parseBool(json['auto_payout_enabled']),
      grossCollected: parseDouble(json['gross_collected']),
      refundedAmount: parseDouble(json['refunded_amount']),
      netCollected: parseDouble(json['net_collected']),
      platformFeeTotal: parseDouble(json['platform_fee_total']),
      reservedForOwner: parseDouble(json['reserved_for_owner']),
      reservedForCollaborators: parseDouble(json['reserved_for_collaborators']),
      releasedToWallet: parseDouble(json['released_to_wallet']),
      availableForSettlement: parseDouble(json['available_for_settlement']),
      claimableAmount: parseDouble(json['claimable_amount']),
      canReleaseNow: parseBool(json['can_release_now']),
    );
  }

  String get statusLabel {
    switch (status) {
      case 'collecting':
        return 'Recaudando';
      case 'awaiting_settlement':
        return 'En período de gracia';
      case 'settlement_hold':
        return 'Liquidación en hold';
      case 'eligible_for_payout':
        return 'Listo para reclamar';
      case 'settled':
        return 'Liquidado';
      default:
        return status;
    }
  }

  String get statusHelper {
    switch (status) {
      case 'collecting':
        return 'Los fondos siguen protegidos dentro del presupuesto del evento.';
      case 'awaiting_settlement':
        return remainingHoldHours == null
            ? 'El evento terminó y está esperando el cierre financiero.'
            : 'Quedan aproximadamente $remainingHoldHours h antes de poder liberar fondos.';
      case 'settlement_hold':
        return 'Hay una retención activa por revisión, reprogramación o reembolso.';
      case 'eligible_for_payout':
        return 'Ya puedes mover este saldo al wallet profesional.';
      case 'settled':
        return 'El saldo reclamable de este evento ya fue liberado.';
      default:
        return 'Estado financiero disponible para este evento.';
    }
  }
}
