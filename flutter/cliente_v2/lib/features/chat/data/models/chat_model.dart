import 'package:equatable/equatable.dart';
import '../../../events/data/models/organizer_model.dart';

class ChatModel extends Equatable {
  final int id;
  final int customerId;
  final int organizerId;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final OrganizerModel? organizer;

  const ChatModel({
    required this.id,
    required this.customerId,
    required this.organizerId,
    this.lastMessage,
    this.lastMessageAt,
    this.organizer,
  });

  factory ChatModel.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) {
      // Create a fallback model if data is corrupted
      return const ChatModel(id: 0, customerId: 0, organizerId: 0);
    }

    return ChatModel(
      id: json['id'] ?? 0,
      customerId: json['customer_id'] ?? 0,
      organizerId: json['organizer_id'] ?? 0,
      lastMessage: json['last_message'],
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.tryParse(json['last_message_at'].toString())
          : null,
      organizer:
          json['organizer'] != null && json['organizer'] is Map<String, dynamic>
          ? OrganizerModel.fromJson(json['organizer'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  List<Object?> get props => [
    id,
    customerId,
    organizerId,
    lastMessage,
    lastMessageAt,
    organizer,
  ];
}
