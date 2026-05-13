import 'review_model.dart';

class ProviderModel {
  final String id;
  final String name;
  final String specialty;
  final String categoryId;
  final String categoryGroup;
  final double rating;
  final int reviewCount;
  final int experienceYears;
  final int pricePerHour;
  final String? avatarUrl;
  final String? bannerUrl;
  final String bio;
  final List<String> tags;
  final List<String> languages;
  final List<ReviewModel> reviews;
  final bool isVerified;
  final bool isOnline;
  final String location;
  final double? distance;
  final List<String> services;
  final bool isFeatured;
  final DateTime memberSince;

  const ProviderModel({
    required this.id,
    required this.name,
    required this.specialty,
    required this.categoryId,
    required this.categoryGroup,
    required this.rating,
    required this.reviewCount,
    required this.experienceYears,
    required this.pricePerHour,
    this.avatarUrl,
    this.bannerUrl,
    required this.bio,
    required this.tags,
    this.languages = const ['Français'],
    required this.reviews,
    required this.isVerified,
    required this.isOnline,
    required this.location,
    this.distance,
    required this.services,
    this.isFeatured = false,
    required this.memberSince,
  });

  String get experienceLabel {
    if (experienceYears < 2) return '$experienceYears an';
    return '$experienceYears ans';
  }

  String get priceLabel {
    final p = pricePerHour;
    if (p >= 1000) {
      return '${(p / 1000).toStringAsFixed(p % 1000 == 0 ? 0 : 1)} 000 FCFA/h';
    }
    return '$p FCFA/h';
  }

  String get ratingLabel => rating.toStringAsFixed(1);
}
