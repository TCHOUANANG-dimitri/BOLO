import 'package:flutter/foundation.dart';
import '../../data/models/provider_model.dart';
import '../../data/repositories/provider_repository.dart';

enum SearchFilter { all, popular, near, newProviders }

class SearchProvider extends ChangeNotifier {
  final ProviderRepository _repo = ProviderRepository();

  String _query = '';
  List<ProviderModel> _results = [];
  bool _isLoading = false;
  SearchFilter _activeFilter = SearchFilter.all;
  String _sortBy = 'popular';
  bool? _onlineOnly;
  bool? _verifiedOnly;
  int? _maxPrice;
  double? _minRating;

  String get query => _query;
  List<ProviderModel> get results => _results;
  bool get isLoading => _isLoading;
  SearchFilter get activeFilter => _activeFilter;
  String get sortBy => _sortBy;
  bool? get onlineOnly => _onlineOnly;
  bool? get verifiedOnly => _verifiedOnly;
  int? get maxPrice => _maxPrice;
  double? get minRating => _minRating;

  Future<void> search(String query, {String? categoryGroup}) async {
    _query = query;
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 400));

    List<ProviderModel> base;
    if (categoryGroup != null) {
      base = _repo.getByCategory(categoryGroup);
    } else if (query.isEmpty) {
      base = _repo.getAll();
    } else {
      base = _repo.search(query);
    }

    _results = _repo.filterAndSort(
      providers: base,
      sortBy: _sortBy,
      onlineOnly: _onlineOnly,
      verifiedOnly: _verifiedOnly,
      maxPrice: _maxPrice,
      minRating: _minRating,
    );

    _isLoading = false;
    notifyListeners();
  }

  void setFilter(SearchFilter filter) {
    _activeFilter = filter;
    switch (filter) {
      case SearchFilter.all:
        _sortBy = 'popular';
      case SearchFilter.popular:
        _sortBy = 'rating';
      case SearchFilter.near:
        _sortBy = 'near';
      case SearchFilter.newProviders:
        _sortBy = 'new';
    }
    _applyCurrentFilters();
    notifyListeners();
  }

  void setOnlineOnly(bool? value) {
    _onlineOnly = value;
    _applyCurrentFilters();
  }

  void setVerifiedOnly(bool? value) {
    _verifiedOnly = value;
    _applyCurrentFilters();
  }

  void setMaxPrice(int? value) {
    _maxPrice = value;
    _applyCurrentFilters();
  }

  void setMinRating(double? value) {
    _minRating = value;
    _applyCurrentFilters();
  }

  void clearFilters() {
    _onlineOnly = null;
    _verifiedOnly = null;
    _maxPrice = null;
    _minRating = null;
    _sortBy = 'popular';
    _activeFilter = SearchFilter.all;
    _applyCurrentFilters();
  }

  void _applyCurrentFilters() {
    List<ProviderModel> base = _query.isEmpty
        ? _repo.getAll()
        : _repo.search(_query);

    _results = _repo.filterAndSort(
      providers: base,
      sortBy: _sortBy,
      onlineOnly: _onlineOnly,
      verifiedOnly: _verifiedOnly,
      maxPrice: _maxPrice,
      minRating: _minRating,
    );
    notifyListeners();
  }
}
