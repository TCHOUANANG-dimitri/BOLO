class ReviewModel {
  final String id;
  final String authorName;
  final String? authorAvatar;
  final double rating;
  final String comment;
  final DateTime date;
  final String? providerReply;

  const ReviewModel({
    required this.id,
    required this.authorName,
    this.authorAvatar,
    required this.rating,
    required this.comment,
    required this.date,
    this.providerReply,
  });

  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Aujourd\'hui';
    if (diff.inDays == 1) return 'Hier';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays} jours';
    if (diff.inDays < 14) return 'Il y a 1 sem.';
    if (diff.inDays < 30) return 'Il y a ${(diff.inDays / 7).floor()} sem.';
    if (diff.inDays < 60) return 'Il y a 1 mois';
    return 'Il y a ${(diff.inDays / 30).floor()} mois';
  }
}
