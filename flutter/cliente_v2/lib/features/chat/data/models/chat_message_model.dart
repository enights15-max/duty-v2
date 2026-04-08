import 'package:equatable/equatable.dart';

class ChatMessageModel extends Equatable {
  final int id;
  final int chatId;
  final int senderId;
  final String senderType;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  const ChatMessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderType,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  factory ChatMessageModel.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) {
      return ChatMessageModel(
        id: 0,
        chatId: 0,
        senderId: 0,
        senderType: '',
        message: '',
        isRead: false,
        createdAt: DateTime.now(),
      );
    }
    return ChatMessageModel(
      id: json['id'] ?? 0,
      chatId: json['chat_id'] ?? 0,
      senderId: json['sender_id'] ?? 0,
      senderType: json['sender_type'] ?? '',
      message: json['message'] ?? '',
      isRead: json['is_read'] == 1 || json['is_read'] == true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat_id': chatId,
      'sender_id': senderId,
      'sender_type': senderType,
      'message': message,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    chatId,
    senderId,
    senderType,
    message,
    isRead,
    createdAt,
  ];
}
