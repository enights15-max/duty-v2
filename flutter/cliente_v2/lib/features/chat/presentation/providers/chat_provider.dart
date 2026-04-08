import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/chat_remote_data_source.dart';
import '../../data/repositories/chat_repository.dart';
import '../../data/models/chat_model.dart';
import '../../data/models/chat_message_model.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final remoteDataSource = ChatRemoteDataSource(apiClient);
  return ChatRepository(remoteDataSource);
});

final allChatsProvider = FutureProvider<List<ChatModel>>((ref) async {
  return ref.watch(chatRepositoryProvider).fetchChats();
});

final chatMessagesProvider = FutureProvider.family<List<ChatMessageModel>, int>(
  (ref, chatId) async {
    return ref.watch(chatRepositoryProvider).fetchChatMessages(chatId);
  },
);

final chatActionProvider =
    StateNotifierProvider<ChatActionNotifier, AsyncValue<void>>((ref) {
      return ChatActionNotifier(ref.watch(chatRepositoryProvider), ref);
    });

class ChatActionNotifier extends StateNotifier<AsyncValue<void>> {
  final ChatRepository _repository;
  final Ref _ref;

  ChatActionNotifier(this._repository, this._ref)
    : super(const AsyncValue.data(null));

  Future<void> sendMessage(int chatId, String message) async {
    state = const AsyncValue.loading();
    try {
      await _repository.sendMessage(chatId, message);
      state = const AsyncValue.data(null);
      // Refresh messages
      _ref.invalidate(chatMessagesProvider(chatId));
      _ref.invalidate(allChatsProvider);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<ChatModel?> startChat(int organizerId) async {
    state = const AsyncValue.loading();
    try {
      final chat = await _repository.startConversation(organizerId);
      state = const AsyncValue.data(null);
      _ref.invalidate(allChatsProvider);
      return chat;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return null;
    }
  }
}
