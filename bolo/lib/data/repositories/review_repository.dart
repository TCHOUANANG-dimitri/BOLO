import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';
import '../../core/services/firestore_service.dart';
import 'mock_data.dart';

class ReviewRepository {
  final FirestoreService _db = FirestoreService();

  // ─── Lire ─────────────────────────────────────────────────────────────────

  Future<List<ReviewModel>> getForProvider(String providerId) async {
    try {
      final docs = await _db.queryDocs(
        'reviews',
        whereField: 'providerId',
        whereValue: providerId,
        orderBy: 'date',
        descending: true,
      );
      return docs.map(ReviewModel.fromFirestore).toList();
    } catch (_) {
      // Fallback : retourner les avis mock du prestataire
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

  Stream<List<ReviewModel>> watchForProvider(String providerId) {
    return _db
        .streamDocs('reviews',
            whereField: 'providerId',
            whereValue: providerId,
            orderBy: 'date',
            descending: true)
        .map((docs) => docs.map(ReviewModel.fromFirestore).toList());
  }

  // ─── Créer ────────────────────────────────────────────────────────────────

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

    await _db.setDoc('reviews', id, {
      ...review.toFirestore(),
      'date': FieldValue.serverTimestamp(),
    }, merge: false);

    // Recalculer la note moyenne du prestataire
    await _recalcProviderRating(providerId);

    return review;
  }

  // ─── Likes ────────────────────────────────────────────────────────────────

  Future<void> toggleLike(
      String reviewId, String userId, bool add) async {
    if (add) {
      await _db.arrayUnion('reviews', reviewId, 'likes', userId);
    } else {
      await _db.arrayRemove('reviews', reviewId, 'likes', userId);
    }
  }

  // ─── Réponse prestataire ──────────────────────────────────────────────────

  Future<void> addProviderReply(
      String reviewId, String reply) async {
    await _db.updateDoc('reviews', reviewId, {
      'providerReply': reply,
      'replyAt': FieldValue.serverTimestamp(),
    });
  }

  // ─── Vérifier si déjà commenté ────────────────────────────────────────────

  Future<bool> hasReviewed(String userId, String providerId) async {
    try {
      final snap = await _db
          .col('reviews')
          .where('authorId', isEqualTo: userId)
          .where('providerId', isEqualTo: providerId)
          .limit(1)
          .get();
      return snap.docs.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // ─── Recalcul note moyenne ────────────────────────────────────────────────

  Future<void> _recalcProviderRating(String providerId) async {
    try {
      final snap = await _db
          .col('reviews')
          .where('providerId', isEqualTo: providerId)
          .get();
      if (snap.docs.isEmpty) return;
      final ratings = snap.docs
          .map((d) => (d.data()['rating'] as num).toDouble())
          .toList();
      final avg = ratings.reduce((a, b) => a + b) / ratings.length;
      await _db.updateDoc('providers', providerId, {
        'rating': double.parse(avg.toStringAsFixed(1)),
        'reviewCount': ratings.length,
      });
    } catch (_) {}
  }
}
