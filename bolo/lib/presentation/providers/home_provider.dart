import 'package:flutter/foundation.dart';
import '../../data/models/provider_model.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/mock_data.dart';
import '../../data/repositories/provider_repository.dart';

class HomeProvider extends ChangeNotifier {
  final ProviderRepository _repo = ProviderRepository();

  bool _isLoading = false;
  List<ProviderModel> _popularProviders = [];
  List<CategoryModel> _mainCategories = [];

  bool get isLoading => _isLoading;
  List<ProviderModel> get popularProviders => _popularProviders;
  List<CategoryModel> get mainCategories => _mainCategories;

  Future<void> loadHome() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    _popularProviders = _repo.getPopular();
    _mainCategories = MockData.mainCategories;

    _isLoading = false;
    notifyListeners();
  }
}
