import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/constants/app_urls.dart';
import '../models/chat_model.dart';
import '../models/chat_message_model.dart';

class ChatRemoteDataSource {
  final ApiClient _apiClient;

  ChatRemoteDataSource(this._apiClient);

  Future<List<ChatModel>> getChats() async {
    try {
      final response = await _apiClient.dio.get(AppUrls.chats);
      if (response.statusCode == 200) {
        dynamic rawData = response.data;
        if (rawData is String) {
          try {
            rawData = jsonDecode(rawData);
          } catch (e) {
            print(
              'DEBUG CHATS ERROR: Failed to decode String response: $rawData',
            );
          }
        }

        if (rawData is Map && rawData.containsKey('data')) {
          final List<dynamic> data = rawData['data'];
          return data.map((json) => ChatModel.fromJson(json)).toList();
        } else if (rawData is List) {
          return rawData.map((json) => ChatModel.fromJson(json)).toList();
        } else {
          String body = rawData.toString();
          print(
            'DEBUG CHATS ERROR: Unexpected structure. Type: ${rawData.runtimeType}. First 200 chars: ${body.length > 200 ? body.substring(0, 200) : body}',
          );
          if (body.length > 500) body = body.substring(0, 500);
          throw 'Unexpected response structure for chats: ${rawData.runtimeType}\nResponse: $body';
        }
      }
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ChatMessageModel>> getChatMessages(int chatId) async {
    try {
      final response = await _apiClient.dio.get(AppUrls.chatMessages(chatId));
      if (response.statusCode == 200) {
        dynamic rawData = response.data;
        if (rawData is String) {
          try {
            rawData = jsonDecode(rawData);
          } catch (e) {
            print('DEBUG MESSAGES ERROR: Failed to decode String response');
          }
        }

        if (rawData is Map && rawData.containsKey('data')) {
          final List<dynamic> data = rawData['data'];
          return data.map((json) => ChatMessageModel.fromJson(json)).toList();
        } else if (rawData is List) {
          return rawData
              .map((json) => ChatMessageModel.fromJson(json))
              .toList();
        } else {
          throw 'Unexpected response structure for messages: ${rawData.runtimeType}';
        }
      }
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<ChatMessageModel> sendMessage(int chatId, String message) async {
    try {
      final response = await _apiClient.dio.post(
        AppUrls.chats,
        data: {'chat_id': chatId, 'message': message},
      );
      if (response.statusCode == 200) {
        dynamic rawData = response.data;
        if (rawData is String) {
          try {
            rawData = jsonDecode(rawData);
          } catch (e) {
            print('DEBUG SEND ERROR: Failed to decode String response');
          }
        }

        if (rawData is Map && rawData.containsKey('data')) {
          return ChatMessageModel.fromJson(rawData['data']);
        } else if (rawData is Map) {
          // If the item itself is the top-level object
          return ChatMessageModel.fromJson(rawData as Map<String, dynamic>);
        } else {
          throw 'Unexpected response structure for send: ${rawData.runtimeType}';
        }
      }
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<ChatModel> startChat(int organizerId) async {
    try {
      final response = await _apiClient.dio.post(
        AppUrls.startChat,
        data: {'organizer_id': organizerId},
      );
      if (response.statusCode == 200) {
        dynamic rawData = response.data;
        if (rawData is String) {
          try {
            rawData = jsonDecode(rawData);
          } catch (e) {
            print('DEBUG START ERROR: Failed to decode String response');
          }
        }

        if (rawData is Map && rawData.containsKey('data')) {
          return ChatModel.fromJson(rawData['data']);
        } else if (rawData is Map) {
          return ChatModel.fromJson(rawData as Map<String, dynamic>);
        } else {
          throw 'Unexpected response structure for start: ${rawData.runtimeType}';
        }
      }
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final response = await _apiClient.dio.get(AppUrls.chatsUnreadCount);
      if (response.statusCode == 200) {
        return response.data['unread_count'] as int;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }
}
