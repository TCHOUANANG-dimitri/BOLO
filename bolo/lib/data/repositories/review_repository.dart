import '../models/review_model.dart';
import '../../core/services/local_db_service.dart';
import 'mock_data.dart';

class ReviewRepository {
  final LocalDbService _db = LocalDbService();

  Future<List<ReviewModel>> getForProvider(String providerId) async {
    try {
      final docs = await _db.queryDocs(
        'reviews',
        whereField: 'providerId',
        whereValue: providerId,
        orderBy: 'date',
        descending: true,
      );
      if (docs.isNotEmpty) return docs.map(ReviewModel.fromLocal).toList();
      // Fallback mock si aucun avis local
      return _mockReviews(providerId);
    } catch (_) {
      return _mockReviews(providerId);
    }
  }

  Stream<List<ReviewModel>> watchForProvider(String providerId) {
    return _db
        .streamDocs('reviews',
            whereField: 'providerId',
            whereValue: providerId,
            orderBy: 'date',
            descending: true)
        .map((docs) => docs.map(ReviewModel.fromLocal).toList());
  }

  Future<ReviewModel> add({
    required String providerId,
    required String authorId,
    required String authorName,
    String? authorAvatar,
    required double rating,
    required String comment,
  }) async {
    final id = 'r_${DateTime.now().millisecondsSinceEpoch}';
    final review = ReviewModel(
      id: id,
      providerId: providerId,
      authorId: authorId,
      authorName: authorName,
      authorAvatar: authorAvatar,
      rating: rating,
      comment: comment,
      date: DateTime.now(),
    );

    await _db.setDoc('reviews', id, review.toLocal(), merge: false);
    await _recalcProviderRating(providerId);
    return review;
  }

  Future<void> toggleLike(
      String reviewId, String userId, bool add) async {
    if (add) {
      await _db.arrayUnion('reviews', reviewId, 'likes', userId);
    } else {
      await _db.arrayRemove('reviews', reviewId, 'likes', userId);
    }
  }

  Future<void> addProviderReply(String reviewId, String reply) async {
    await _db.updateDoc('reviews', reviewId, {
      'providerReply': reply,
      'replyAt': DateTime.now().toIso8601String(),
    });
  }

  Future<bool> hasReviewed(String userId, String providerId) async {
    try {
      final docs = await _db.queryDocs(
        'reviews',
        where: {'authorId': userId, 'providerId': providerId},
      );
      return docs.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> _recalcProviderRating(String providerId) async {
    try {
      final docs = await _db.queryDocs(
        'reviews',
        whereField: 'providerId',
        whereValue: providerId,
      );
      if (docs.isEmpty) return;
      final ratings =
          docs.map((d) => (d['rating'] as num).toDouble()).toList();
      final avg = ratings.reduce((a, b) => a + b) / ratings.length;
      await _db.updateDoc('providers', providerId, {
        'rating': double.parse(avg.toStringAsFixed(1)),
        'reviewCount': ratings.length,
      });
    } catch (_) {}
  }

  // ─── Fallback mock ────────────────────────────────────────────────────────

  List<ReviewModel> _mockReviews(String providerId) {
    final p = MockData.providers
        .where((p) => p.id == providerId)
        .firstOrNull;
    if (p == null) return [];
    return p.reviews
        .map((r) => ReviewModel(
              id: r.id,
              providerId: providerId,
              authorId: 'mock',
              authorName: r.authorName,
              authorAvatar: r.authorAvatar,
              rating: r.rating,
              comment: r.comment,
              date: r.date,
              providerReply: r.providerReply,
            ))
        .toList();
  }
}
