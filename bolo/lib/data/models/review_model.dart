class ReviewModel {
  final String id;
  final String providerId;
  final String authorId;
  final String authorName;
  final String? authorAvatar;
  final double rating;
  final String comment;
  final DateTime date;
  final String? providerReply;
  final List<String> likes;

  const ReviewModel({
    required this.id,
    required this.providerId,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    required this.rating,
    required this.comment,
    required this.date,
    this.providerReply,
    this.likes = const [],
  });

  int get likeCount => likes.length;
  bool isLikedBy(String userId) => likes.contains(userId);

  String get timeAgo {
    final diff = DateTime.now().difference(date);
    if (diff.inDays == 0) return 'Aujourd\'hui';
    if (diff.inDays == 1) return 'Hier';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays} j';
    if (diff.inDays < 14) return 'Il y a 1 sem.';
    if (diff.inDays < 30) return 'Il y a ${(diff.inDays / 7).floor()} sem.';
    if (diff.inDays < 60) return 'Il y a 1 mois';
    return 'Il y a ${(diff.inDays / 30).floor()} mois';
  }

  // ─── Local DB ─────────────────────────────────────────────────────────────

  factory ReviewModel.fromLocal(Map<String, dynamic> data) {
    DateTime date = DateTime.now();
    final rawDate = data['date'];
    if (rawDate is String) date = DateTime.tryParse(rawDate) ?? date;

    return ReviewModel(
      id: data['id'] ?? '',
      providerId: data['providerId'] ?? '',
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '',
      authorAvatar: data['authorAvatar'],
      rating: (data['rating'] as num?)?.toDouble() ?? 5.0,
      comment: data['comment'] ?? '',
      date: date,
      providerReply: data['providerReply'],
      likes: List<String>.from(data['likes'] ?? []),
    );
  }

  factory ReviewModel.fromFirestore(Map<String, dynamic> data) =>
      ReviewModel.fromLocal(data);

  Map<String, dynamic> toLocal() => {
        'id': id,
        'providerId': providerId,
        'authorId': authorId,
        'authorName': authorName,
        'authorAvatar': authorAvatar,
        'rating': rating,
        'comment': comment,
        'date': date.toIso8601String(),
        'providerReply': providerReply,
        'likes': likes,
      };

  Map<String, dynamic> toFirestore() => toLocal();

  ReviewModel copyWith({
    String? providerReply,
    List<String>? likes,
  }) =>
      ReviewModel(
        id: id,
        providerId: providerId,
        authorId: authorId,
        authorName: authorName,
        authorAvatar: authorAvatar,
        rating: rating,
        comment: comment,
        date: date,
        providerReply: providerReply ?? this.providerReply,
        likes: likes ?? this.likes,
      );
}
