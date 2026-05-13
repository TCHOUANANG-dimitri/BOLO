import 'package:flutter/foundation.dart';
import '../../data/models/review_model.dart';
import '../../data/repositories/review_repository.dart';
import '../../data/repositories/booking_repository.dart';

class ReviewProvider extends ChangeNotifier {
  final ReviewRepository _reviewRepo = ReviewRepository();
  final BookingRepository _bookingRepo = BookingRepository();

  List<ReviewModel> _reviews = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _currentProviderId;

  List<ReviewModel> get reviews => _reviews;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;

  double get averageRating {
    if (_reviews.isEmpty) return 0;
    final sum = _reviews.fold(0.0, (acc, r) => acc + r.rating);
    return sum / _reviews.length;
  }

  // ─── Charger les avis d'un prestataire ────────────────────────────────────

  Future<void> loadReviews(String providerId) async {
    if (_currentProviderId == providerId && _reviews.isNotEmpty) return;
    _isLoading = true;
    _currentProviderId = providerId;
    notifyListeners();

    _reviews = await _reviewRepo.getForProvider(providerId);

    _isLoading = false;
    notifyListeners();
  }

  void watchReviews(String providerId) {
    _currentProviderId = providerId;
    _reviewRepo.watchForProvider(providerId).listen((list) {
      _reviews = list;
      notifyListeners();
    });
  }

  // ─── Soumettre un avis ────────────────────────────────────────────────────

  Future<bool> submitReview({
    required String providerId,
    required String authorId,
    required String authorName,
    String? authorAvatar,
    required double rating,
    required String comment,
  }) async {
    if (rating < 1 || comment.trim().isEmpty) return false;

    _isSubmitting = true;
    notifyListeners();

    try {
      // Vérifier doublon
      final alreadyReviewed =
          await _reviewRepo.hasReviewed(authorId, providerId);
      if (alreadyReviewed) {
        _isSubmitting = false;
        notifyListeners();
        return false;
      }

      final review = await _reviewRepo.add(
        providerId: providerId,
        authorId: authorId,
        authorName: authorName,
        authorAvatar: authorAvatar,
        rating: rating,
        comment: comment,
      );
      _reviews.insert(0, review);
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (_) {
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  // ─── Liker / unliker un avis ──────────────────────────────────────────────

  Future<void> toggleLike(String reviewId, String userId) async {
    final idx = _reviews.indexWhere((r) => r.id == reviewId);
    if (idx < 0) return;

    final review = _reviews[idx];
    final isLiked = review.isLikedBy(userId);
    final newLikes = List<String>.from(review.likes);
    if (isLiked) {
      newLikes.remove(userId);
    } else {
      newLikes.add(userId);
    }
    _reviews[idx] = review.copyWith(likes: newLikes);
    notifyListeners();

    try {
      await _reviewRepo.toggleLike(reviewId, userId, !isLiked);
    } catch (_) {}
  }

  // ─── Répondre à un avis (prestataire) ────────────────────────────────────

  Future<void> replyToReview(String reviewId, String reply) async {
    try {
      await _reviewRepo.addProviderReply(reviewId, reply);
      final idx = _reviews.indexWhere((r) => r.id == reviewId);
      if (idx >= 0) {
        _reviews[idx] = _reviews[idx].copyWith(providerReply: reply);
        notifyListeners();
      }
    } catch (_) {}
  }

  // ─── Vérifier si l'utilisateur peut laisser un avis ──────────────────────

  Future<bool> canReview(String userId, String providerId) async {
    try {
      final hasBooking =
          await _bookingRepo.hasCompletedBooking(userId, providerId);
      if (!hasBooking) return false;
      final alreadyReviewed =
          await _reviewRepo.hasReviewed(userId, providerId);
      return !alreadyReviewed;
    } catch (_) {
      return true; // Mode démo : autoriser
    }
  }

  void clearProvider() {
    _reviews = [];
    _currentProviderId = null;
    notifyListeners();
  }
}
