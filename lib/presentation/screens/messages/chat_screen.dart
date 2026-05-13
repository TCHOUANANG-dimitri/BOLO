import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/message_model.dart';
import '../../../data/repositories/mock_data.dart';
import '../../providers/messages_provider.dart';
import '../../widgets/provider_avatar.dart';

class ChatScreen extends StatefulWidget {
  final String conversationId;

  const ChatScreen({super.key, required this.conversationId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  ConversationModel? _conversation;

  @override
  void initState() {
    super.initState();
    _loadConversation();
  }

  void _loadConversation() {
    final provider = context.read<MessagesProvider>();
    if (provider.conversations.isEmpty) {
      provider.loadConversations().then((_) {
        _setConversation();
      });
    } else {
      _setConversation();
    }
  }

  void _setConversation() {
    final provider = context.read<MessagesProvider>();
    try {
      setState(() {
        _conversation = provider.conversations
            .firstWhere((c) => c.id == widget.conversationId);
      });
    } catch (_) {}
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    _msgCtrl.clear();

    await context
        .read<MessagesProvider>()
        .sendMessage(widget.conversationId, text);

    _setConversation();
    _scrollToBottom();
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MessagesProvider>(
      builder: (context, messages, _) {
        ConversationModel? conv;
        try {
          conv = messages.conversations
              .firstWhere((c) => c.id == widget.conversationId);
        } catch (_) {}

        return Scaffold(
          backgroundColor: AppColors.backgroundWarm,
          appBar: AppBar(
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              onPressed: () => context.pop(),
            ),
            titleSpacing: 0,
            title: conv == null
                ? const Text('Chat')
                : Row(
                    children: [
                      Stack(
                        children: [
                          ProviderAvatar(
                            name: conv.otherUserName,
                            avatarUrl: conv.otherUserAvatar,
                            size: 40,
                          ),
                          if (conv.isOtherOnline)
                            Positioned(
                              right: 1,
                              bottom: 1,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: AppColors.online,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white, width: 1.5),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(conv.otherUserName,
                              style: AppTextStyles.titleSmall),
                          Text(
                            conv.isOtherOnline
                                ? AppStrings.online
                                : AppStrings.offline,
                            style: AppTextStyles.caption.copyWith(
                              color: conv.isOtherOnline
                                  ? AppColors.online
                                  : AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
            actions: [
              IconButton(
                icon: const Icon(Icons.phone_outlined, color: AppColors.primary),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.info_outline_rounded,
                    color: AppColors.textLight),
                onPressed: conv != null
                    ? () => context.push('/provider/${conv!.otherUserId}')
                    : null,
              ),
            ],
          ),
          body: Column(
            children: [
              // Messages list
              Expanded(
                child: conv == null || conv.messages.isEmpty
                    ? _EmptyChat(name: conv?.otherUserName ?? '')
                    : ListView.builder(
                        controller: _scrollCtrl,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        itemCount: conv.messages.length,
                        itemBuilder: (context, i) {
                          final msg = conv!.messages[i];
                          final isMe =
                              msg.senderId == MockData.currentUser.id;
                          final showTime = i == 0 ||
                              conv.messages[i].timestamp
                                      .difference(conv.messages[i - 1].timestamp)
                                      .inMinutes >
                                  30;
                          return Column(
                            children: [
                              if (showTime)
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  child: Text(
                                    msg.timeLabel,
                                    style: AppTextStyles.caption,
                                  ),
                                ),
                              _MessageBubble(message: msg, isMe: isMe),
                            ],
                          );
                        },
                      ),
              ),

              // Input
              _ChatInput(
                controller: _msgCtrl,
                onSend: _sendMessage,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;

  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 6,
          left: isMe ? 64 : 0,
          right: isMe ? 0 : 64,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          message.content,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isMe ? Colors.white : AppColors.textPrimary,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}

class _ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _ChatInput({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        10,
        16,
        MediaQuery.of(context).padding.bottom + 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Emoji button
          IconButton(
            icon: const Icon(Icons.emoji_emotions_outlined,
                color: AppColors.textLight),
            onPressed: () {},
          ),

          // Text field
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: AppStrings.typeMessage,
                  hintStyle:
                      AppTextStyles.bodySmall.copyWith(color: AppColors.textLight),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textPrimary),
                maxLines: 4,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
          ),

          // Attachment button
          IconButton(
            icon: const Icon(Icons.attach_file_rounded,
                color: AppColors.textLight),
            onPressed: () {},
          ),

          // Send button
          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyChat extends StatelessWidget {
  final String name;

  const _EmptyChat({required this.name});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chat_bubble_outline_rounded,
              size: 60, color: AppColors.textLight.withOpacity(0.4)),
          const SizedBox(height: 16),
          Text('Commencez la conversation', style: AppTextStyles.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Envoyez un message à $name',
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }
}
