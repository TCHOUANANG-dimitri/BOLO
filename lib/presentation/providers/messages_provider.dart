import 'package:flutter/foundation.dart';
import '../../data/models/message_model.dart';
import '../../data/repositories/mock_data.dart';

class MessagesProvider extends ChangeNotifier {
  List<ConversationModel> _conversations = [];
  bool _isLoading = false;

  List<ConversationModel> get conversations => _conversations;
  bool get isLoading => _isLoading;

  int get totalUnread =>
      _conversations.fold(0, (sum, c) => sum + c.unreadCount);

  Future<void> loadConversations() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 400));
    _conversations = List.from(MockData.conversations);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> sendMessage(String conversationId, String content) async {
    final idx = _conversations.indexWhere((c) => c.id == conversationId);
    if (idx < 0) return;

    final msg = MessageModel(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: MockData.currentUser.id,
      receiverId: _conversations[idx].otherUserId,
      content: content,
      timestamp: DateTime.now(),
      isRead: false,
    );

    final conv = _conversations[idx];
    final updated = ConversationModel(
      id: conv.id,
      otherUserId: conv.otherUserId,
      otherUserName: conv.otherUserName,
      otherUserAvatar: conv.otherUserAvatar,
      otherUserSpecialty: conv.otherUserSpecialty,
      isOtherOnline: conv.isOtherOnline,
      messages: [...conv.messages, msg],
      unreadCount: 0,
    );

    _conversations[idx] = updated;
    notifyListeners();

    // Simulate auto-reply
    if (conv.isOtherOnline) {
      await Future.delayed(const Duration(seconds: 2));
      _simulateReply(conversationId);
    }
  }

  void _simulateReply(String conversationId) {
    final idx = _conversations.indexWhere((c) => c.id == conversationId);
    if (idx < 0) return;

    final replies = [
      'D\'accord, je note cela.',
      'Parfait ! À très bientôt.',
      'Merci pour votre message.',
      'Bien sûr, je suis disponible.',
      'Je reviens vers vous rapidement.',
    ];

    final reply = MessageModel(
      id: 'reply_${DateTime.now().millisecondsSinceEpoch}',
      senderId: _conversations[idx].otherUserId,
      receiverId: MockData.currentUser.id,
      content: replies[DateTime.now().second % replies.length],
      timestamp: DateTime.now(),
      isRead: false,
    );

    final conv = _conversations[idx];
    _conversations[idx] = ConversationModel(
      id: conv.id,
      otherUserId: conv.otherUserId,
      otherUserName: conv.otherUserName,
      otherUserAvatar: conv.otherUserAvatar,
      otherUserSpecialty: conv.otherUserSpecialty,
      isOtherOnline: conv.isOtherOnline,
      messages: [...conv.messages, reply],
      unreadCount: conv.unreadCount + 1,
    );
    notifyListeners();
  }

  void markAsRead(String conversationId) {
    final idx = _conversations.indexWhere((c) => c.id == conversationId);
    if (idx < 0) return;

    final conv = _conversations[idx];
    _conversations[idx] = ConversationModel(
      id: conv.id,
      otherUserId: conv.otherUserId,
      otherUserName: conv.otherUserName,
      otherUserAvatar: conv.otherUserAvatar,
      otherUserSpecialty: conv.otherUserSpecialty,
      isOtherOnline: conv.isOtherOnline,
      messages: conv.messages,
      unreadCount: 0,
    );
    notifyListeners();
  }
}
