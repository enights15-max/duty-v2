import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/chat_provider.dart';
import '../../data/models/chat_model.dart';
import '../../data/models/chat_message_model.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../../../../core/theme/colors.dart';

class ChatRoomPage extends ConsumerStatefulWidget {
  final ChatModel chat;

  const ChatRoomPage({super.key, required this.chat});

  @override
  ConsumerState<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends ConsumerState<ChatRoomPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    if (widget.chat == null && widget.chatId != null) {
      final chatAsync = ref.watch(chatByIdProvider(widget.chatId!));
      return chatAsync.when(
        data: (chat) {
          if (chat == null) {
            return Scaffold(
              backgroundColor: palette.background,
              appBar: AppBar(
                backgroundColor: palette.backgroundAlt,
                elevation: 0,
              ),
              body: Center(
                child: Text(
                  'Chat no encontrado',
                  style: TextStyle(color: palette.textPrimary),
                ),
              ),
            );
          }
          return _buildChatContent(chat);
        },
        loading: () => Scaffold(
          backgroundColor: palette.background,
          appBar: AppBar(backgroundColor: palette.backgroundAlt, elevation: 0),
          body: Center(
            child: CircularProgressIndicator(color: palette.primary),
          ),
        ),
        error: (err, stack) => Scaffold(
          backgroundColor: palette.background,
          appBar: AppBar(backgroundColor: palette.backgroundAlt, elevation: 0),
          body: Center(
            child: Text(
              'Error: $err',
              style: TextStyle(color: palette.textPrimary),
            ),
          ),
        ),
      );
    }

    return _buildChatContent(widget.chat!);
  }

  Widget _buildChatContent(ChatModel chat) {
    final palette = context.dutyTheme;
    final messagesAsync = ref.watch(chatMessagesProvider(chat.id));
    final actionState = ref.watch(chatActionProvider);

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.backgroundAlt,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: palette.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: palette.primary.withValues(alpha: 0.16),
              backgroundImage: otherAvatarUrl != null
                  ? CachedNetworkImageProvider(otherAvatarUrl)
                  : null,
              child: otherAvatarUrl == null
                  ? Icon(
                      _getIconForType(chat.otherType),
                      color: palette.textMuted,
                      size: 18,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.chat.organizer?.name ?? 'Organizer',
                    style: GoogleFonts.splineSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: palette.textPrimary,
                    ),
                  ),
                  Text(
                    'Online', // Placeholder
                    style: TextStyle(color: palette.success, fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                WidgetsBinding.instance.addPostFrameCallback(
                  (_) => _scrollToBottom(),
                );
                return RefreshIndicator(
                  onRefresh: () =>
                      ref.refresh(chatMessagesProvider(chat.id).future),
                  color: palette.primary,
                  backgroundColor: palette.surface,
                  child: ListView.builder(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      // Use currentUserId for accurate differentiation
                      final isMe = message.senderId == currentUserId;

                      // Check if it's the last message in a sequence from the same sender
                      bool isLastInSequence = true;
                      if (index < messages.length - 1) {
                        final nextMessage = messages[index + 1];
                        if (nextMessage.senderId == message.senderId) {
                          isLastInSequence = false;
                        }
                      }

                      return _buildMessageBubble(
                        chat,
                        message,
                        isMe,
                        !isMe && isLastInSequence,
                        isLastInSequence,
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Text(
                  'Error: $err',
                  style: TextStyle(color: palette.textSecondary),
                ),
              ),
            ),
          ),
          _buildInputArea(actionState.isLoading),
        ],
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'artist':
        return Icons.mic_external_on;
      case 'venue':
        return Icons.location_on;
      case 'organizer':
        return Icons.business;
      default:
        return Icons.person;
    }
  }

  Widget _buildMessageBubble(
    ChatModel chat,
    ChatMessageModel message,
    bool isMe,
    bool showAvatar,
    bool isLastInSequence,
  ) {
    final palette = context.dutyTheme;
    final otherAvatarUrl = AppUrls.getAvatarUrl(
      chat.otherPhoto,
      isOrganizer: chat.otherType == 'organizer',
    );

    return Padding(
      padding: EdgeInsets.only(bottom: isLastInSequence ? 12 : 4),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            if (showAvatar)
              CircleAvatar(
                radius: 12,
                backgroundColor: palette.primary.withValues(alpha: 0.12),
                backgroundImage: otherAvatarUrl != null
                    ? CachedNetworkImageProvider(otherAvatarUrl)
                    : null,
                child: otherAvatarUrl == null
                    ? Icon(
                        _getIconForType(chat.otherType),
                        color: palette.textMuted,
                        size: 10,
                      )
                    : null,
              )
            else
              const SizedBox(width: 24),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? palette.primary : palette.surfaceAlt,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(
                    isMe ? 18 : (isLastInSequence ? 4 : 18),
                  ),
                  bottomRight: Radius.circular(
                    isMe ? (isLastInSequence ? 4 : 18) : 18,
                  ),
                ),
                boxShadow: [
                  if (isMe)
                    BoxShadow(
                      color: palette.primary.withValues(alpha: 0.22),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message.message,
                    style: TextStyle(
                      color: isMe ? palette.onPrimary : palette.textPrimary,
                      fontSize: 14,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat('HH:mm').format(message.createdAt),
                        style: TextStyle(
                          color: isMe
                              ? palette.onPrimary.withValues(alpha: 0.68)
                              : palette.textMuted,
                          fontSize: 9,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.isRead ? Icons.done_all : Icons.done,
                          color: message.isRead
                              ? palette.info
                              : palette.onPrimary.withValues(alpha: 0.68),
                          size: 11,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('HH:mm').format(message.createdAt),
                  style: TextStyle(
                    color: isMe ? Colors.white70 : Colors.white38,
                    fontSize: 10,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.isRead ? Icons.done_all : Icons.done,
                    color: Colors.white70,
                    size: 12,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(ChatModel chat, bool isLoading) {
    final palette = context.dutyTheme;
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        16,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: palette.backgroundAlt,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: palette.surface,
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: _messageController,
                style: TextStyle(color: palette.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(color: palette.textMuted),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: isLoading
                ? null
                : () {
                    if (_messageController.text.trim().isNotEmpty) {
                      ref
                          .read(chatActionProvider.notifier)
                          .sendMessage(
                            widget.chat.id,
                            _messageController.text.trim(),
                          );
                      _messageController.clear();
                    }
                  },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: palette.primary,
                shape: BoxShape.circle,
              ),
              child: isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: palette.onPrimary,
                      ),
                    )
                  : Icon(Icons.send, color: palette.onPrimary, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
