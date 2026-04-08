import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/chat_provider.dart';
import '../../data/models/chat_model.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../../../../core/theme/colors.dart';

class ConversationsListPage extends ConsumerWidget {
  const ConversationsListPage({super.key});

  @override
  ConsumerState<ConversationsListPage> createState() =>
      _ConversationsListPageState();
}

class _ConversationsListPageState extends ConsumerState<ConversationsListPage> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _startBackgroundRefresh();
  }

  void _startBackgroundRefresh() {
    // Refresh conversation list every 15 seconds in background
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (mounted) {
        ref.invalidate(allChatsProvider);
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    final chatsAsync = ref.watch(allChatsProvider);
    final double bottomContentInset =
        MediaQuery.of(context).padding.bottom + 132;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.backgroundAlt,
        elevation: 0,
        title: Text(
          'Messages',
          style: GoogleFonts.splineSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: palette.textPrimary,
          ),
        ),
      ),
      body: chatsAsync.when(
        data: (chats) {
          if (chats.isEmpty) {
            return _buildEmptyState();
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(allChatsProvider.future),
            color: palette.primary,
            backgroundColor: palette.surface,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(0, 16, 0, bottomContentInset),
              itemCount: chats.length,
              separatorBuilder: (context, index) =>
                  Divider(color: palette.border, indent: 80),
              itemBuilder: (context, index) {
                final chat = chats[index];
                return _buildConversationItem(context, chat);
              },
            ),
          );
        },
        loading: () =>
            Center(child: CircularProgressIndicator(color: palette.primary)),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Text(
                'Error: $err',
                style: TextStyle(color: palette.textSecondary, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final palette = context.dutyTheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: palette.primary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: GoogleFonts.splineSans(
              fontSize: 18,
              color: palette.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Contact an organizer to start a conversation',
            style: TextStyle(color: palette.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationItem(BuildContext context, ChatModel chat) {
    final palette = context.dutyTheme;
    return ListTile(
      onTap: () => context.push('/chat-room', extra: chat),
      leading: CircleAvatar(
        radius: 28,
        backgroundColor: palette.primary.withValues(alpha: 0.12),
        backgroundImage: chat.otherPhoto != null
            ? CachedNetworkImageProvider(
                (chat.otherType == 'organizer' ||
                        chat.otherType == 'venue' ||
                        chat.otherType == 'artist')
                    ? (AppUrls.getAvatarUrl(
                            chat.otherPhoto,
                            isOrganizer: true,
                          ) ??
                          '')
                    : (AppUrls.getAvatarUrl(chat.otherPhoto) ?? ''),
              )
            : null,
        child: chat.otherPhoto == null
            ? Icon(_getIconForType(chat.otherType), color: palette.textMuted)
            : null,
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              chat.otherName,
              style: TextStyle(
                color: palette.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            _formatTimestamp(chat.lastMessageAt),
            style: TextStyle(color: palette.textMuted, fontSize: 12),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          chat.lastMessage ?? 'Start a conversation',
          style: TextStyle(
            color: chat.unreadCount > 0
                ? palette.textPrimary
                : palette.textSecondary,
            fontSize: 13,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (chat.unreadCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: palette.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                chat.unreadCount.toString(),
                style: TextStyle(
                  color: palette.onPrimary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(height: 4),
          Icon(Icons.chevron_right, color: palette.textMuted, size: 16),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return DateFormat('MMM d').format(date);
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
