import '../datasources/chat_remote_data_source.dart';
import '../models/chat_model.dart';
import '../models/chat_message_model.dart';

class ChatRepository {
  final ChatRemoteDataSource _remoteDataSource;

  ChatRepository(this._remoteDataSource);

  Future<List<ChatModel>> fetchChats() {
    return _remoteDataSource.getChats();
  }

  Future<List<ChatMessageModel>> fetchChatMessages(int chatId) {
    return _remoteDataSource.getChatMessages(chatId);
  }

  Future<ChatMessageModel> sendMessage(int chatId, String message) {
    return _remoteDataSource.sendMessage(chatId, message);
  }

  Future<ChatModel> startConversation(int organizerId) {
    return _remoteDataSource.startChat(organizerId);
  }

  Future<int> fetchUnreadCount() {
    return _remoteDataSource.getUnreadCount();
  }
}
