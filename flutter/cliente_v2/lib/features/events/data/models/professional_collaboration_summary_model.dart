class ProfessionalCollaborationItem {
  final int id;
  final int eventId;
  final String eventTitle;
  final int identityId;
  final String identityType;
  final String? displayName;
  final String roleType;
  final String status;
  final int splitId;
  final double splitValue;
  final bool requiresClaim;
  final bool autoRelease;
  final List<ProfessionalCollaborationModeAuditItem> modeHistory;
  final double amountReserved;
  final double amountClaimed;
  final double claimableAmount;
  final DateTime? releasedAt;
  final DateTime? claimedAt;
  final DateTime? lastCalculatedAt;

  const ProfessionalCollaborationItem({
    required this.id,
    required this.eventId,
    required this.eventTitle,
    required this.identityId,
    required this.identityType,
    required this.displayName,
    required this.roleType,
    required this.status,
    required this.splitId,
    required this.splitValue,
    required this.requiresClaim,
    required this.autoRelease,
    required this.modeHistory,
    required this.amountReserved,
    required this.amountClaimed,
    required this.claimableAmount,
    required this.releasedAt,
    required this.claimedAt,
    required this.lastCalculatedAt,
  });

  factory ProfessionalCollaborationItem.fromJson(Map<String, dynamic> json) {
    final rawModeHistory = json['mode_history'] is List
        ? json['mode_history'] as List
        : const [];

    return ProfessionalCollaborationItem(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      eventId: int.tryParse(json['event_id']?.toString() ?? '') ?? 0,
      eventTitle: json['event_title']?.toString().trim().isNotEmpty == true
          ? json['event_title'].toString().trim()
          : 'Evento',
      identityId: int.tryParse(json['identity_id']?.toString() ?? '') ?? 0,
      identityType: json['identity_type']?.toString() ?? '',
      displayName: json['display_name']?.toString(),
      roleType: json['role_type']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending_release',
      splitId: int.tryParse(json['split_id']?.toString() ?? '') ?? 0,
      splitValue: _parseDouble(json['split_value']),
      requiresClaim: _parseBool(json['requires_claim'], fallback: true),
      autoRelease: _parseBool(json['auto_release']),
      modeHistory: rawModeHistory
          .map(
            (item) => ProfessionalCollaborationModeAuditItem.fromJson(
              item is Map<String, dynamic>
                  ? item
                  : Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      amountReserved: _parseDouble(json['amount_reserved']),
      amountClaimed: _parseDouble(json['amount_claimed']),
      claimableAmount: _parseDouble(json['claimable_amount']),
      releasedAt: DateTime.tryParse(json['released_at']?.toString() ?? ''),
      claimedAt: DateTime.tryParse(json['claimed_at']?.toString() ?? ''),
      lastCalculatedAt: DateTime.tryParse(
        json['last_calculated_at']?.toString() ?? '',
      ),
    );
  }

  bool get canClaimNow =>
      status == 'claimable' && claimableAmount > 0 && id > 0;

  bool get isAutoReleaseMode => autoRelease && !requiresClaim;

  String get payoutModeLabel => isAutoReleaseMode ? 'Auto release' : 'Manual';

  ProfessionalCollaborationModeAuditItem? get latestModeChange =>
      modeHistory.isEmpty ? null : modeHistory.first;

  String get statusLabel {
    switch (status) {
      case 'pending_event_completion':
        return 'Pendiente por evento';
      case 'pending_release':
        return 'Pendiente de liberación';
      case 'claimable':
        return 'Listo para reclamar';
      case 'claimed':
        return 'Reclamado';
      case 'cancelled':
        return 'Cancelado';
      default:
        return status;
    }
  }

  String get roleLabel {
    switch (roleType) {
      case 'artist':
        return 'Artista';
      case 'venue':
        return 'Venue';
      case 'organizer':
        return 'Organizer';
      default:
        return roleType;
    }
  }

  String get amountReservedLabel => 'RD\$${amountReserved.toStringAsFixed(2)}';

  String get amountClaimedLabel => 'RD\$${amountClaimed.toStringAsFixed(2)}';

  String? get claimableAmountLabel {
    if (claimableAmount <= 0) {
      return null;
    }
    return 'RD\$${claimableAmount.toStringAsFixed(2)}';
  }
}

class ProfessionalCollaborationModeAuditItem {
  final int id;
  final int? actorIdentityId;
  final String? actorIdentityType;
  final bool previousRequiresClaim;
  final bool previousAutoRelease;
  final bool newRequiresClaim;
  final bool newAutoRelease;
  final String source;
  final DateTime? changedAt;

  const ProfessionalCollaborationModeAuditItem({
    required this.id,
    required this.actorIdentityId,
    required this.actorIdentityType,
    required this.previousRequiresClaim,
    required this.previousAutoRelease,
    required this.newRequiresClaim,
    required this.newAutoRelease,
    required this.source,
    required this.changedAt,
  });

  factory ProfessionalCollaborationModeAuditItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return ProfessionalCollaborationModeAuditItem(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      actorIdentityId: int.tryParse(
        json['actor_identity_id']?.toString() ?? '',
      ),
      actorIdentityType: json['actor_identity_type']?.toString(),
      previousRequiresClaim: _parseBool(
        json['previous_requires_claim'],
        fallback: true,
      ),
      previousAutoRelease: _parseBool(json['previous_auto_release']),
      newRequiresClaim: _parseBool(json['new_requires_claim'], fallback: true),
      newAutoRelease: _parseBool(json['new_auto_release']),
      source: json['source']?.toString() ?? '',
      changedAt: DateTime.tryParse(json['changed_at']?.toString() ?? ''),
    );
  }

  bool get previousIsAutoRelease =>
      previousAutoRelease && !previousRequiresClaim;

  bool get nextIsAutoRelease => newAutoRelease && !newRequiresClaim;

  String get previousModeLabel =>
      previousIsAutoRelease ? 'Auto release' : 'Manual';

  String get nextModeLabel => nextIsAutoRelease ? 'Auto release' : 'Manual';
}

class ProfessionalCollaborationSummary {
  final double claimableAmount;
  final double pendingAmount;
  final double claimedAmount;
  final List<ProfessionalCollaborationItem> items;
  final ProfessionalRewardsPerformance? rewardsPerformance;

  const ProfessionalCollaborationSummary({
    required this.claimableAmount,
    required this.pendingAmount,
    required this.claimedAmount,
    required this.items,
    this.rewardsPerformance,
  });

  factory ProfessionalCollaborationSummary.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] is List ? json['items'] as List : const [];
    final rawRewards = json['rewards_performance'] as Map<String, dynamic>?;

    return ProfessionalCollaborationSummary(
      claimableAmount: _parseDouble(json['claimable_amount']),
      pendingAmount: _parseDouble(json['pending_amount']),
      claimedAmount: _parseDouble(json['claimed_amount']),
      items: rawItems
          .map(
            (item) => ProfessionalCollaborationItem.fromJson(
              item is Map<String, dynamic>
                  ? item
                  : Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      rewardsPerformance: rawRewards != null
          ? ProfessionalRewardsPerformance.fromJson(rawRewards)
          : null,
    );
  }

  double get autoReleasedAmount => items.fold<double>(
    0,
    (sum, item) =>
        sum +
        (item.isAutoReleaseMode && item.amountClaimed > 0
            ? item.amountClaimed
            : 0),
  );

  bool get hasRewardsActivity => (rewardsPerformance?.totalIssued ?? 0) > 0;
}

class ProfessionalRewardsPerformance {
  final int totalIssued;
  final int totalClaimed;
  final Map<int, ProfessionalEventRewardsPerformance> byEvent;

  const ProfessionalRewardsPerformance({
    required this.totalIssued,
    required this.totalClaimed,
    required this.byEvent,
  });

  factory ProfessionalRewardsPerformance.fromJson(Map<String, dynamic> json) {
    final rawByEvent = json['by_event'] as Map<String, dynamic>? ?? {};
    final byEvent = rawByEvent.map((key, value) {
      return MapEntry(
        int.tryParse(key) ?? 0,
        ProfessionalEventRewardsPerformance.fromJson(
          value as Map<String, dynamic>,
        ),
      );
    });

    return ProfessionalRewardsPerformance(
      totalIssued: int.tryParse(json['total_issued']?.toString() ?? '') ?? 0,
      totalClaimed: int.tryParse(json['total_claimed']?.toString() ?? '') ?? 0,
      byEvent: byEvent,
    );
  }
}

class ProfessionalEventRewardsPerformance {
  final int totalIssued;
  final int totalClaimed;

  const ProfessionalEventRewardsPerformance({
    required this.totalIssued,
    required this.totalClaimed,
  });

  factory ProfessionalEventRewardsPerformance.fromJson(
    Map<String, dynamic> json,
  ) {
    return ProfessionalEventRewardsPerformance(
      totalIssued: int.tryParse(json['total_issued']?.toString() ?? '') ?? 0,
      totalClaimed: int.tryParse(json['total_claimed']?.toString() ?? '') ?? 0,
    );
  }
}

class ProfessionalEventCollaborationSummary {
  final double distributableAmount;
  final double reservedForCollaborators;
  final int claimableCount;
  final List<ProfessionalCollaborationItem> splits;
  final List<ProfessionalCollaborationSuggestion> suggestions;
  final List<ProfessionalEventCollaborationActivityItem> activity;

  const ProfessionalEventCollaborationSummary({
    required this.distributableAmount,
    required this.reservedForCollaborators,
    required this.claimableCount,
    required this.splits,
    required this.suggestions,
    required this.activity,
  });

  factory ProfessionalEventCollaborationSummary.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawSplits = json['splits'] is List
        ? json['splits'] as List
        : const [];
    final rawSuggestions = json['suggestions'] is List
        ? json['suggestions'] as List
        : const [];
    final rawActivity = json['activity'] is List
        ? json['activity'] as List
        : const [];

    return ProfessionalEventCollaborationSummary(
      distributableAmount: _parseDouble(json['distributable_amount']),
      reservedForCollaborators: _parseDouble(
        json['reserved_for_collaborators'],
      ),
      claimableCount:
          int.tryParse(json['claimable_count']?.toString() ?? '') ?? 0,
      splits: rawSplits
          .map(
            (item) => ProfessionalCollaborationItem.fromJson(
              item is Map<String, dynamic>
                  ? item
                  : Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      suggestions: rawSuggestions
          .map(
            (item) => ProfessionalCollaborationSuggestion.fromJson(
              item is Map<String, dynamic>
                  ? item
                  : Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      activity: rawActivity
          .map(
            (item) => ProfessionalEventCollaborationActivityItem.fromJson(
              item is Map<String, dynamic>
                  ? item
                  : Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
    );
  }

  ProfessionalEventCollaborationActivityItem? get latestActivity =>
      activity.isEmpty ? null : activity.first;
}

class ProfessionalCollaborationSuggestion {
  final int identityId;
  final String identityType;
  final String roleType;
  final String displayName;
  final String source;

  const ProfessionalCollaborationSuggestion({
    required this.identityId,
    required this.identityType,
    required this.roleType,
    required this.displayName,
    required this.source,
  });

  factory ProfessionalCollaborationSuggestion.fromJson(
    Map<String, dynamic> json,
  ) {
    return ProfessionalCollaborationSuggestion(
      identityId: int.tryParse(json['identity_id']?.toString() ?? '') ?? 0,
      identityType: json['identity_type']?.toString() ?? '',
      roleType: json['role_type']?.toString() ?? '',
      displayName: json['display_name']?.toString() ?? 'Colaborador',
      source: json['source']?.toString() ?? '',
    );
  }
}

class ProfessionalEventCollaborationActivityItem {
  final String id;
  final String type;
  final String title;
  final String subtitle;
  final double amount;
  final bool isAutomatic;
  final DateTime? occurredAt;

  const ProfessionalEventCollaborationActivityItem({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isAutomatic,
    required this.occurredAt,
  });

  factory ProfessionalEventCollaborationActivityItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return ProfessionalEventCollaborationActivityItem(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      amount: _parseDouble(json['amount']),
      isAutomatic: _parseBool(json['is_automatic']),
      occurredAt: DateTime.tryParse(json['occurred_at']?.toString() ?? ''),
    );
  }

  String? get amountLabel =>
      amount > 0 ? 'RD\$${amount.toStringAsFixed(2)}' : null;
}

double _parseDouble(dynamic value) {
  return double.tryParse(value?.toString() ?? '0') ?? 0;
}

bool _parseBool(dynamic value, {bool fallback = false}) {
  if (value is bool) {
    return value;
  }

  final normalized = value?.toString().trim().toLowerCase();
  if (normalized == null || normalized.isEmpty) {
    return fallback;
  }

  return normalized == '1' ||
      normalized == 'true' ||
      normalized == 'yes' ||
      normalized == 'on';
}
