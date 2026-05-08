import '../models/provider_model.dart';
import 'mock_data.dart';

class ProviderRepository {
  List<ProviderModel> getAll() => MockData.providers;

  List<ProviderModel> getFeatured() =>
      MockData.providers.where((p) => p.isFeatured).toList();

  List<ProviderModel> getPopular() {
    final sorted = List<ProviderModel>.from(MockData.providers)
      ..sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
    return sorted.take(6).toList();
  }

  List<ProviderModel> search(String query) {
    final q = query.toLowerCase();
    return MockData.providers.where((p) {
      return p.name.toLowerCase().contains(q) ||
          p.specialty.toLowerCase().contains(q) ||
          p.categoryGroup.toLowerCase().contains(q) ||
          p.tags.any((t) => t.toLowerCase().contains(q));
    }).toList();
  }

  List<ProviderModel> getByCategory(String categoryGroup) {
    return MockData.providers
        .where((p) => p.categoryGroup == categoryGroup)
        .toList();
  }

  List<ProviderModel> getByCategoryId(String categoryId) {
    return MockData.providers
        .where((p) => p.categoryId == categoryId)
        .toList();
  }

  ProviderModel? getById(String id) {
    try {
      return MockData.providers.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  List<ProviderModel> filterAndSort({
    List<ProviderModel>? providers,
    String sortBy = 'popular',
    double? maxDistance,
    int? minPrice,
    int? maxPrice,
    double? minRating,
    bool? onlineOnly,
    bool? verifiedOnly,
  }) {
    var list = providers ?? MockData.providers;

    if (onlineOnly == true) list = list.where((p) => p.isOnline).toList();
    if (verifiedOnly == true) list = list.where((p) => p.isVerified).toList();
    if (minRating != null) list = list.where((p) => p.rating >= minRating).toList();
    if (maxDistance != null) {
      list = list
          .where((p) => p.distance != null && p.distance! <= maxDistance)
          .toList();
    }
    if (minPrice != null) {
      list = list.where((p) => p.pricePerHour >= minPrice).toList();
    }
    if (maxPrice != null) {
      list = list.where((p) => p.pricePerHour <= maxPrice).toList();
    }

    switch (sortBy) {
      case 'popular':
        list.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
      case 'rating':
        list.sort((a, b) => b.rating.compareTo(a.rating));
      case 'price_asc':
        list.sort((a, b) => a.pricePerHour.compareTo(b.pricePerHour));
      case 'price_desc':
        list.sort((a, b) => b.pricePerHour.compareTo(a.pricePerHour));
      case 'near':
        list.sort((a, b) {
          final da = a.distance ?? double.infinity;
          final db = b.distance ?? double.infinity;
          return da.compareTo(db);
        });
      case 'new':
        list.sort((a, b) => b.memberSince.compareTo(a.memberSince));
    }

    return list;
  }
}
