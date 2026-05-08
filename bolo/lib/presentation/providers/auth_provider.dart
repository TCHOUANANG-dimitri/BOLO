import 'package:flutter/foundation.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/mock_data.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String? _error;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get error => _error;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  Future<void> checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Simulate logged in user
    _user = MockData.currentUser;
    _status = AuthStatus.authenticated;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    if (email.isNotEmpty && password.length >= 6) {
      _user = MockData.currentUser;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } else {
      _error = 'Email ou mot de passe incorrect';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required bool isProvider,
  }) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    _user = UserModel(
      id: 'u_new',
      fullName: fullName,
      email: email,
      phone: phone,
      isProvider: isProvider,
      createdAt: DateTime.now(),
    );
    _status = AuthStatus.authenticated;
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> updateProfile({
    String? fullName,
    String? phone,
    String? location,
  }) async {
    if (_user == null) return;
    _user = _user!.copyWith(
      fullName: fullName,
      phone: phone,
      location: location,
    );
    notifyListeners();
  }

  void toggleFavorite(String providerId) {
    if (_user == null) return;
    final favorites = List<String>.from(_user!.favoriteProviderIds);
    if (favorites.contains(providerId)) {
      favorites.remove(providerId);
    } else {
      favorites.add(providerId);
    }
    _user = _user!.copyWith(favoriteProviderIds: favorites);
    notifyListeners();
  }

  bool isFavorite(String providerId) =>
      _user?.favoriteProviderIds.contains(providerId) ?? false;
}
