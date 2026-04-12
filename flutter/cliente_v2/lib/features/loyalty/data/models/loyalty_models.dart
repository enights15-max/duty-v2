class LoyaltySummaryModel {
  final int currentPoints;
  final int lifetimePoints;
  final int redeemedPoints;
  final int availableRewards;

  const LoyaltySummaryModel({
    required this.currentPoints,
    required this.lifetimePoints,
    required this.redeemedPoints,
    required this.availableRewards,
  });

  factory LoyaltySummaryModel.fromJson(Map<String, dynamic> json) {
    return LoyaltySummaryModel(
      currentPoints: (json['current_points'] as num?)?.toInt() ?? 0,
      lifetimePoints: (json['lifetime_points'] as num?)?.toInt() ?? 0,
      redeemedPoints: (json['redeemed_points'] as num?)?.toInt() ?? 0,
      availableRewards: (json['available_rewards'] as num?)?.toInt() ?? 0,
    );
  }
}

class _LoyaltyRuleRef {
  final int? id;
  final String code;
  final String label;

  const _LoyaltyRuleRef({this.id, required this.code, required this.label});

  factory _LoyaltyRuleRef.fromJson(Map<String, dynamic> json) {
    return _LoyaltyRuleRef(
      id: (json['id'] as num?)?.toInt(),
      code: json['code']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
    );
  }
}

class LoyaltyHistoryItemModel {
  final int id;
  final String type;
  final int points;
  final String? referenceType;
  final String? referenceId;
  final int? balanceAfter;
  final DateTime createdAt;
  final String? ruleCode;
  final String? ruleLabel;

  const LoyaltyHistoryItemModel({
    required this.id,
    required this.type,
    required this.points,
    this.referenceType,
    this.referenceId,
    this.balanceAfter,
    required this.createdAt,
    this.ruleCode,
    this.ruleLabel,
  });

  factory LoyaltyHistoryItemModel.fromJson(Map<String, dynamic> json) {
    _LoyaltyRuleRef? rule;
    if (json['rule'] is Map<String, dynamic>) {
      rule = _LoyaltyRuleRef.fromJson(json['rule'] as Map<String, dynamic>);
    }

    return LoyaltyHistoryItemModel(
      id: (json['id'] as num).toInt(),
      type: json['type']?.toString() ?? '',
      points: (json['points'] as num?)?.toInt() ?? 0,
      referenceType: json['reference_type']?.toString(),
      referenceId: json['reference_id']?.toString(),
      balanceAfter: (json['balance_after'] as num?)?.toInt(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      ruleCode: rule?.code,
      ruleLabel: rule?.label,
    );
  }
}

class LoyaltyRewardModel {
  final int id;
  final String title;
  final String rewardType;
  final bool isActive;
  final bool isFeatured;
  final int pointsCost;
  final double? bonusAmount;
  final Map<String, dynamic>? meta;

  const LoyaltyRewardModel({
    required this.id,
    required this.title,
    required this.rewardType,
    required this.isActive,
    required this.isFeatured,
    required this.pointsCost,
    this.bonusAmount,
    this.meta,
  });

  factory LoyaltyRewardModel.fromJson(Map<String, dynamic> json) {
    return LoyaltyRewardModel(
      id: (json['id'] as num).toInt(),
      title: json['title']?.toString() ?? '',
      rewardType: json['reward_type']?.toString() ?? '',
      isActive: json['is_active'] == true || json['is_active'] == 1,
      isFeatured: json['is_featured'] == true || json['is_featured'] == 1,
      pointsCost: (json['points_cost'] as num?)?.toInt() ?? 0,
      bonusAmount: json['bonus_amount'] != null
          ? double.tryParse(json['bonus_amount'].toString())
          : null,
      meta: json['meta'] is Map<String, dynamic>
          ? json['meta'] as Map<String, dynamic>
          : null,
    );
  }
}

class LoyaltyRedemptionModel {
  final int id;
  final int rewardId;
  final String rewardType;
  final int pointsCost;
  final String status;
  final Map<String, dynamic>? meta;
  final DateTime? fulfilledAt;
  final DateTime createdAt;
  final LoyaltyRewardModel? reward;

  const LoyaltyRedemptionModel({
    required this.id,
    required this.rewardId,
    required this.rewardType,
    required this.pointsCost,
    required this.status,
    this.meta,
    this.fulfilledAt,
    required this.createdAt,
    this.reward,
  });

  factory LoyaltyRedemptionModel.fromJson(Map<String, dynamic> json) {
    return LoyaltyRedemptionModel(
      id: (json['id'] as num).toInt(),
      rewardId: (json['reward_id'] as num?)?.toInt() ?? 0,
      rewardType: json['reward_type']?.toString() ?? '',
      pointsCost: (json['points_cost'] as num?)?.toInt() ?? 0,
      status: json['status']?.toString() ?? '',
      meta: json['meta'] is Map<String, dynamic>
          ? json['meta'] as Map<String, dynamic>
          : null,
      fulfilledAt: json['fulfilled_at'] != null
          ? DateTime.tryParse(json['fulfilled_at'].toString())
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      reward: json['reward'] is Map<String, dynamic>
          ? LoyaltyRewardModel.fromJson(json['reward'] as Map<String, dynamic>)
          : null,
    );
  }
}

class LoyaltyRedeemResult {
  final LoyaltyRedemptionModel redemption;
  final LoyaltySummaryModel summary;

  const LoyaltyRedeemResult({
    required this.redemption,
    required this.summary,
  });

  factory LoyaltyRedeemResult.fromJson(Map<String, dynamic> json) {
    return LoyaltyRedeemResult(
      redemption: LoyaltyRedemptionModel.fromJson(
        json['redemption'] as Map<String, dynamic>,
      ),
      summary: LoyaltySummaryModel.fromJson(
        json['summary'] as Map<String, dynamic>,
      ),
    );
  }
}
