import 'professional_event_summary_model.dart';
import 'professional_collaboration_summary_model.dart';

class ProfessionalMetricComparison {
  final double current;
  final double? previous;
  final double? delta;
  final double? deltaPercent;

  const ProfessionalMetricComparison({
    required this.current,
    required this.previous,
    required this.delta,
    required this.deltaPercent,
  });

  factory ProfessionalMetricComparison.fromJson(dynamic json) {
    final map = json is Map<String, dynamic>
        ? json
        : json is Map
        ? Map<String, dynamic>.from(json)
        : const <String, dynamic>{};

    return ProfessionalMetricComparison(
      current: double.tryParse(map['current']?.toString() ?? '0') ?? 0,
      previous: map['previous'] == null
          ? null
          : double.tryParse(map['previous']?.toString() ?? ''),
      delta: map['delta'] == null
          ? null
          : double.tryParse(map['delta']?.toString() ?? ''),
      deltaPercent: map['delta_percent'] == null
          ? null
          : double.tryParse(map['delta_percent']?.toString() ?? ''),
    );
  }
}

class ProfessionalDashboardModel {
  final String profileType;
  final String range;
  final double balance;
  final int eventCount;
  final int ticketSales;
  final double averageRating;
  final int reviewCount;
  final double grossSales;
  final double netSales;
  final double ledgerInflow;
  final double ledgerOutflow;
  final int ledgerEntries;
  final int ticketsAvailable;
  final double? sellThroughPercent;
  final int soldOutEvents;
  final int lowStockEvents;
  final int marketplaceFallbackEvents;
  final Map<String, ProfessionalMetricComparison> comparisons;
  final List<ProfessionalEventSummaryModel> upcomingEvents;
  final List<ProfessionalEventSummaryModel> inventoryWatch;
  final ProfessionalCollaborationSummary? collaborationSummary;

  const ProfessionalDashboardModel({
    required this.profileType,
    required this.range,
    required this.balance,
    required this.eventCount,
    required this.ticketSales,
    required this.averageRating,
    required this.reviewCount,
    required this.grossSales,
    required this.netSales,
    required this.ledgerInflow,
    required this.ledgerOutflow,
    required this.ledgerEntries,
    required this.ticketsAvailable,
    required this.sellThroughPercent,
    required this.soldOutEvents,
    required this.lowStockEvents,
    required this.marketplaceFallbackEvents,
    required this.comparisons,
    required this.upcomingEvents,
    required this.inventoryWatch,
    required this.collaborationSummary,
  });

  factory ProfessionalDashboardModel.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] is Map<String, dynamic>
        ? json['stats'] as Map<String, dynamic>
        : json['stats'] is Map
        ? Map<String, dynamic>.from(json['stats'] as Map)
        : const <String, dynamic>{};

    final rawComparisons = json['comparisons'] is Map<String, dynamic>
        ? json['comparisons'] as Map<String, dynamic>
        : json['comparisons'] is Map
        ? Map<String, dynamic>.from(json['comparisons'] as Map)
        : const <String, dynamic>{};

    final rawUpcoming = json['upcoming_events'] is List
        ? json['upcoming_events'] as List
        : const [];
    final rawInventoryWatch = json['inventory_watch'] is List
        ? json['inventory_watch'] as List
        : const [];
    final collaborationJson =
        json['collaboration_summary'] is Map<String, dynamic>
        ? json['collaboration_summary'] as Map<String, dynamic>
        : json['collaboration_summary'] is Map
        ? Map<String, dynamic>.from(json['collaboration_summary'] as Map)
        : null;

    return ProfessionalDashboardModel(
      profileType: json['profile_type']?.toString() ?? '',
      range: json['range']?.toString() ?? 'all',
      balance: double.tryParse(stats['balance']?.toString() ?? '0') ?? 0,
      eventCount: int.tryParse(stats['event_count']?.toString() ?? '0') ?? 0,
      ticketSales: int.tryParse(stats['ticket_sales']?.toString() ?? '0') ?? 0,
      averageRating:
          double.tryParse(stats['average_rating']?.toString() ?? '0') ?? 0,
      reviewCount: int.tryParse(stats['review_count']?.toString() ?? '0') ?? 0,
      grossSales: double.tryParse(stats['gross_sales']?.toString() ?? '0') ?? 0,
      netSales: double.tryParse(stats['net_sales']?.toString() ?? '0') ?? 0,
      ledgerInflow:
          double.tryParse(stats['ledger_inflow']?.toString() ?? '0') ?? 0,
      ledgerOutflow:
          double.tryParse(stats['ledger_outflow']?.toString() ?? '0') ?? 0,
      ledgerEntries:
          int.tryParse(stats['ledger_entries']?.toString() ?? '0') ?? 0,
      ticketsAvailable:
          int.tryParse(stats['tickets_available']?.toString() ?? '0') ?? 0,
      sellThroughPercent: stats['sell_through_percent'] == null
          ? null
          : double.tryParse(stats['sell_through_percent']?.toString() ?? ''),
      soldOutEvents:
          int.tryParse(stats['sold_out_events']?.toString() ?? '0') ?? 0,
      lowStockEvents:
          int.tryParse(stats['low_stock_events']?.toString() ?? '0') ?? 0,
      marketplaceFallbackEvents:
          int.tryParse(
            stats['marketplace_fallback_events']?.toString() ?? '0',
          ) ??
          0,
      comparisons: rawComparisons.map(
        (key, value) =>
            MapEntry(key, ProfessionalMetricComparison.fromJson(value)),
      ),
      upcomingEvents: rawUpcoming
          .map(
            (item) => ProfessionalEventSummaryModel.fromJson(
              item is Map<String, dynamic>
                  ? item
                  : Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      inventoryWatch: rawInventoryWatch
          .map(
            (item) => ProfessionalEventSummaryModel.fromJson(
              item is Map<String, dynamic>
                  ? item
                  : Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      collaborationSummary: collaborationJson == null
          ? null
          : ProfessionalCollaborationSummary.fromJson(collaborationJson),
    );
  }
}
