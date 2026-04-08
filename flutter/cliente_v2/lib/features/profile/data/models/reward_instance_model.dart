class RewardInstanceModel {
  final int id;
  final String status;
  final String title;
  final String rewardType;
  final String? claimCode;
  final String? claimQrPayload;
  final DateTime? activatedAt;
  final DateTime? claimedAt;
  final String? sponsorName;
  final String? sponsorLogoUrl;

  RewardInstanceModel({
    required this.id,
    required this.status,
    required this.title,
    required this.rewardType,
    this.claimCode,
    this.claimQrPayload,
    this.activatedAt,
    this.claimedAt,
    this.sponsorName,
    this.sponsorLogoUrl,
  });

  bool get isActivated => status == 'activated';
  bool get isClaimed => status == 'claimed';
  bool get isReserved => status == 'reserved';

  factory RewardInstanceModel.fromJson(Map<String, dynamic> json) {
    final definition = json['definition'] as Map<String, dynamic>? ?? {};
    return RewardInstanceModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id']?.toString() ?? '0'),
      status: json['status']?.toString() ?? 'reserved',
      title: definition['title']?.toString() ?? 'Reward',
      rewardType: definition['reward_type']?.toString() ?? 'perk',
      claimCode: json['claim_code']?.toString(),
      claimQrPayload: json['claim_qr_payload']?.toString(),
      activatedAt: json['activated_at'] != null ? DateTime.tryParse(json['activated_at']) : null,
      claimedAt: json['claimed_at'] != null ? DateTime.tryParse(json['claimed_at']) : null,
      sponsorName: json['sponsor_identity']?['display_name']?.toString(),
      sponsorLogoUrl: json['sponsor_identity']?['logo_url']?.toString(),
    );
  }
}
