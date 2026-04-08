import 'professional_event_summary_model.dart';
import 'professional_collaboration_summary_model.dart';

class ProfessionalEventInventoryDetailModel {
  final ProfessionalEventSummaryModel event;
  final ProfessionalEventInventorySummary inventory;
  final ProfessionalEventCirculationSummary circulation;
  final ProfessionalEventCollaborationSummary? collaboration;
  final List<ProfessionalTicketInventoryRow> ticketBreakdown;
  final List<ProfessionalInventoryActivityItem> recentActivity;

  const ProfessionalEventInventoryDetailModel({
    required this.event,
    required this.inventory,
    required this.circulation,
    required this.collaboration,
    required this.ticketBreakdown,
    required this.recentActivity,
  });

  factory ProfessionalEventInventoryDetailModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final eventJson = json['event'] is Map<String, dynamic>
        ? json['event'] as Map<String, dynamic>
        : json['event'] is Map
        ? Map<String, dynamic>.from(json['event'] as Map)
        : const <String, dynamic>{};
    final inventoryJson = json['inventory'] is Map<String, dynamic>
        ? json['inventory'] as Map<String, dynamic>
        : json['inventory'] is Map
        ? Map<String, dynamic>.from(json['inventory'] as Map)
        : const <String, dynamic>{};
    final circulationJson = json['circulation'] is Map<String, dynamic>
        ? json['circulation'] as Map<String, dynamic>
        : json['circulation'] is Map
        ? Map<String, dynamic>.from(json['circulation'] as Map)
        : const <String, dynamic>{};
    final collaborationJson = json['collaboration'] is Map<String, dynamic>
        ? json['collaboration'] as Map<String, dynamic>
        : json['collaboration'] is Map
        ? Map<String, dynamic>.from(json['collaboration'] as Map)
        : null;
    final breakdownJson = json['ticket_breakdown'] is List
        ? json['ticket_breakdown'] as List
        : const [];
    final activityJson = json['recent_activity'] is List
        ? json['recent_activity'] as List
        : const [];

    return ProfessionalEventInventoryDetailModel(
      event: ProfessionalEventSummaryModel.fromJson(eventJson),
      inventory: ProfessionalEventInventorySummary.fromJson(inventoryJson),
      circulation: ProfessionalEventCirculationSummary.fromJson(
        circulationJson,
      ),
      collaboration: collaborationJson == null
          ? null
          : ProfessionalEventCollaborationSummary.fromJson(collaborationJson),
      ticketBreakdown: breakdownJson
          .map(
            (item) => ProfessionalTicketInventoryRow.fromJson(
              item is Map<String, dynamic>
                  ? item
                  : Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      recentActivity: activityJson
          .map(
            (item) => ProfessionalInventoryActivityItem.fromJson(
              item is Map<String, dynamic>
                  ? item
                  : Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
    );
  }
}

class ProfessionalEventCirculationSummary {
  final int journeyEventCount;
  final int ticketsMovedCount;
  final int listingCount;
  final int resaleCount;
  final int giftTransferPendingCount;
  final int giftTransferCompletedCount;
  final int scanCount;
  final int promoResaleLockedCount;
  final double? averageResalePrice;
  final double? maxResalePrice;

  const ProfessionalEventCirculationSummary({
    required this.journeyEventCount,
    required this.ticketsMovedCount,
    required this.listingCount,
    required this.resaleCount,
    required this.giftTransferPendingCount,
    required this.giftTransferCompletedCount,
    required this.scanCount,
    required this.promoResaleLockedCount,
    required this.averageResalePrice,
    required this.maxResalePrice,
  });

  factory ProfessionalEventCirculationSummary.fromJson(
    Map<String, dynamic> json,
  ) {
    return ProfessionalEventCirculationSummary(
      journeyEventCount:
          int.tryParse(json['journey_event_count']?.toString() ?? '') ?? 0,
      ticketsMovedCount:
          int.tryParse(json['tickets_moved_count']?.toString() ?? '') ?? 0,
      listingCount: int.tryParse(json['listing_count']?.toString() ?? '') ?? 0,
      resaleCount: int.tryParse(json['resale_count']?.toString() ?? '') ?? 0,
      giftTransferPendingCount:
          int.tryParse(json['gift_transfer_pending_count']?.toString() ?? '') ??
          0,
      giftTransferCompletedCount:
          int.tryParse(
            json['gift_transfer_completed_count']?.toString() ?? '',
          ) ??
          0,
      scanCount: int.tryParse(json['scan_count']?.toString() ?? '') ?? 0,
      promoResaleLockedCount:
          int.tryParse(json['promo_resale_locked_count']?.toString() ?? '') ??
          0,
      averageResalePrice: double.tryParse(
        json['average_resale_price']?.toString() ?? '',
      ),
      maxResalePrice: double.tryParse(
        json['max_resale_price']?.toString() ?? '',
      ),
    );
  }
}

class ProfessionalTicketInventoryRow {
  final String key;
  final int? ticketId;
  final String label;
  final String pricingType;
  final double unitPrice;
  final bool inventoryLimited;
  final int? available;
  final int sold;
  final int reserved;
  final int? totalInventory;
  final double? sellThroughPercent;
  final int? maxPerUser;
  final bool reservationEnabled;

  const ProfessionalTicketInventoryRow({
    required this.key,
    required this.ticketId,
    required this.label,
    required this.pricingType,
    required this.unitPrice,
    required this.inventoryLimited,
    required this.available,
    required this.sold,
    required this.reserved,
    required this.totalInventory,
    required this.sellThroughPercent,
    required this.maxPerUser,
    required this.reservationEnabled,
  });

  factory ProfessionalTicketInventoryRow.fromJson(Map<String, dynamic> json) {
    return ProfessionalTicketInventoryRow(
      key: json['key']?.toString() ?? '',
      ticketId: int.tryParse(json['ticket_id']?.toString() ?? ''),
      label: json['label']?.toString() ?? 'Ticket',
      pricingType: json['pricing_type']?.toString() ?? 'normal',
      unitPrice: double.tryParse(json['unit_price']?.toString() ?? '0') ?? 0,
      inventoryLimited: _parseBool(json['inventory_limited']),
      available: int.tryParse(json['available']?.toString() ?? ''),
      sold: int.tryParse(json['sold']?.toString() ?? '0') ?? 0,
      reserved: int.tryParse(json['reserved']?.toString() ?? '0') ?? 0,
      totalInventory: int.tryParse(json['total_inventory']?.toString() ?? ''),
      sellThroughPercent: double.tryParse(
        json['sell_through_percent']?.toString() ?? '',
      ),
      maxPerUser: int.tryParse(json['max_per_user']?.toString() ?? ''),
      reservationEnabled: _parseBool(json['reservation_enabled']),
    );
  }
}

class ProfessionalInventoryActivityItem {
  final String id;
  final String type;
  final String title;
  final String subtitle;
  final double amount;
  final int quantity;
  final String status;
  final DateTime? occurredAt;

  const ProfessionalInventoryActivityItem({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.quantity,
    required this.status,
    required this.occurredAt,
  });

  factory ProfessionalInventoryActivityItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return ProfessionalInventoryActivityItem(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      quantity: int.tryParse(json['quantity']?.toString() ?? '0') ?? 0,
      status: json['status']?.toString() ?? '',
      occurredAt: DateTime.tryParse(json['occurred_at']?.toString() ?? ''),
    );
  }
}

bool _parseBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  return value?.toString().toLowerCase() == 'true';
}
