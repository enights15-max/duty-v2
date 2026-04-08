class WalletTransactionModel {
  final String id;
  final String type;
  final double amount;
  final String? referenceId;
  final String description;
  final DateTime createdAt;

  WalletTransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    this.referenceId,
    required this.description,
    required this.createdAt,
  });

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    return WalletTransactionModel(
      id: json['id'].toString(),
      type: json['type'] ?? '',
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      referenceId: json['reference_id'],
      description: json['description'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}
