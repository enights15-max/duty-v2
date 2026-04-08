class EventRewardSummaryModel {
  final int id;
  final String title;
  final String rewardType;
  final String? sponsorName;
  final String? sponsorLogoUrl;

  const EventRewardSummaryModel({
    required this.id,
    required this.title,
    required this.rewardType,
    this.sponsorName,
    this.sponsorLogoUrl,
  });

  factory EventRewardSummaryModel.fromJson(Map<String, dynamic> json) {
    return EventRewardSummaryModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      rewardType: json['reward_type'] ?? 'other',
      sponsorName: json['sponsor_name'],
      sponsorLogoUrl: json['sponsor_logo_url'],
    );
  }
}
