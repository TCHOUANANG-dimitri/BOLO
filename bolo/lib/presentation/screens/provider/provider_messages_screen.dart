import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/message_model.dart';
import '../../providers/messages_provider.dart';
import '../../widgets/bolo_logo.dart';
import '../../widgets/provider_avatar.dart';

class ProviderMessagesScreen extends StatefulWidget {
  const ProviderMessagesScreen({super.key});

  @override
  State<ProviderMessagesScreen> createState() => _ProviderMessagesScreenState();
}

class _ProviderMessagesScreenState extends State<ProviderMessagesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MessagesProvider>().loadConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go('/provider-dashboard'),
        ),
        title: const BoloLogo(size: 36),
        centerTitle: true,
        actions: [
          // Badge avec nb de non-lus
          Consumer<MessagesProvider>(
            builder: (_, msgs, __) {
              final unread = msgs.conversations
                  .fold(0, (s, c) => s + c.unreadCount);
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.mark_chat_read_rounded,
                        color: AppColors.primary),
                    onPressed: () {},
                  ),
                  if (unread > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$unread',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<MessagesProvider>(
        builder: (context, messages, _) {
          if (messages.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (messages.conversations.isEmpty) {
            return _EmptyProviderMessages();
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: messages.conversations.length,
            separatorBuilder: (_, __) => const Divider(
              height: 1,
              indent: 80,
              endIndent: 20,
            ),
            itemBuilder: (context, i) {
              final conv = messages.conversations[i];
              return _ProviderConversationTile(
                conversation: conv,
                onTap: () {
                  messages.markAsRead(conv.id);
                  context.push('/chat/${conv.id}');
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _ProviderConversationTile extends StatelessWidget {
  final ConversationModel conversation;
  final VoidCallback onTap;

  const _ProviderConversationTile({
    required this.conversation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final last = conversation.lastMessage;
    final hasUnread = conversation.unreadCount > 0;

    return ListTile(
      onTap: onTap,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Stack(
        children: [
          ProviderAvatar(
            name: conversation.otherUserName,
            avatarUrl: conversation.otherUserAvatar,
            size: 52,
          ),
          if (conversation.isOtherOnline)
            Positioned(
              right: 2,
              bottom: 2,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.online,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              conversation.otherUserName,
              style: AppTextStyles.titleSmall.copyWith(
                fontWeight:
                    hasUnread ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          if (last != null)
            Text(
              last.timeLabel,
              style: AppTextStyles.caption.copyWith(
                color: hasUnread
                    ? AppColors.primary
                    : AppColors.textLight,
                fontWeight:
                    hasUnread ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
        ],
      ),
      subtitle: Row(
        children: [
          // Label "client" discret
          Container(
            margin: const EdgeInsets.only(right: 6),
            padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Client',
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.primary, fontSize: 9),
            ),
          ),
          Expanded(
            child: Text(
              last?.content ?? 'Nouvelle conversation',
              style: AppTextStyles.bodySmall.copyWith(
                color: hasUnread
                    ? AppColors.textPrimary
                    : AppColors.textLight,
                fontWeight: hasUnread
                    ? FontWeight.w500
                    : FontWeight.w400,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          if (hasUnread)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(
                  horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${conversation.unreadCount}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyProviderMessages extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.forum_rounded,
              size: 48,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Aucun message pour l\'instant',
            style: AppTextStyles.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Les clients qui vous contactent\napparaîtront ici.',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => context.go('/provider-dashboard'),
            icon: const Icon(Icons.dashboard_rounded),
            label: const Text('Retour au tableau de bord'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
