import 'package:flutter/foundation.dart';
import '../../core/services/auth_service.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/mock_data.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserRepository _userRepo = UserRepository();

  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String? _error;
  bool _awaitingOtp = false;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get error => _error;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get awaitingOtp => _awaitingOtp;

  // ─── Initialisation ───────────────────────────────────────────────────────

  Future<void> checkAuth() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      final userData = await _authService.currentUserData();
      if (userData != null) {
        _user = UserModel.fromLocal(userData);
        _status = AuthStatus.authenticated;
      } else {
        // Mode démo : auto-connecté avec données mock
        _user = MockData.currentUser;
        _status = AuthStatus.authenticated;
      }
    } catch (_) {
      _user = MockData.currentUser;
      _status = AuthStatus.authenticated;
    }

    notifyListeners();
  }

  // ─── Connexion ────────────────────────────────────────────────────────────

  Future<bool> login(String email, String password) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();

    try {
      final userData = await _authService.signInWithEmail(
        email: email,
        password: password,
      );
      _user = UserModel.fromLocal(userData);

      // Si 2FA activé → demander OTP
      if (_user!.twoFactorEnabled && _user!.phone.isNotEmpty) {
        await _authService.sendPhoneOtp(phone: _user!.phone);
        _awaitingOtp = true;
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }

      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    } catch (_) {
      // Fallback démo si aucun compte créé localement
      if (email.isNotEmpty && password.length >= 6) {
        _user = MockData.currentUser;
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      }
      _error = 'Email ou mot de passe incorrect';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  // ─── Inscription ──────────────────────────────────────────────────────────

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

    try {
      final userData = await _authService.registerWithEmail(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
        isProvider: isProvider,
      );
      _user = UserModel.fromLocal(userData);
      _awaitingOtp = true;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    } catch (_) {
      // Fallback démo
      _user = UserModel(
        id: 'u_${DateTime.now().millisecondsSinceEpoch}',
        fullName: fullName,
        email: email,
        phone: phone,
        isProvider: isProvider,
        createdAt: DateTime.now(),
      );
      _awaitingOtp = true;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return true;
    }
  }

  // ─── OTP ──────────────────────────────────────────────────────────────────

  Future<void> sendOtp(String phone) async {
    await _authService.sendPhoneOtp(phone: phone);
  }

  Future<bool> verifyOtp(String code) async {
    _status = AuthStatus.loading;
    notifyListeners();

    // Mode local : tout code à 6 chiffres est valide
    if (_authService.verifyOtp(code)) {
      _awaitingOtp = false;
      if (_user != null) {
        _user = _user!.copyWith(twoFactorEnabled: true);
        try {
          await _userRepo.enable2FA(_user!.id);
        } catch (_) {}
      }
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    }

    _error = 'Code invalide — entrez 6 chiffres';
    _status = AuthStatus.error;
    notifyListeners();
    return false;
  }

  // ─── Déconnexion ──────────────────────────────────────────────────────────

  Future<void> logout() async {
    await _authService.signOut();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  // ─── Mise à jour profil ───────────────────────────────────────────────────

  Future<void> updateProfile({
    String? fullName,
    String? phone,
    String? location,
    String? avatarUrl,
  }) async {
    if (_user == null) return;
    try {
      final updated = await _userRepo.updateProfile(
        userId: _user!.id,
        fullName: fullName,
        phone: phone,
        location: location,
      );
      _user = updated ??
          _user!.copyWith(
            fullName: fullName,
            phone: phone,
            location: location,
            avatarUrl: avatarUrl,
          );
    } catch (_) {
      _user = _user!.copyWith(
        fullName: fullName,
        phone: phone,
        location: location,
        avatarUrl: avatarUrl,
      );
    }
    notifyListeners();
  }

  // ─── Favoris ──────────────────────────────────────────────────────────────

  Future<void> toggleFavorite(String providerId) async {
    if (_user == null) return;
    final favorites = List<String>.from(_user!.favoriteProviderIds);
    final add = !favorites.contains(providerId);
    if (add) {
      favorites.add(providerId);
    } else {
      favorites.remove(providerId);
    }
    _user = _user!.copyWith(favoriteProviderIds: favorites);
    notifyListeners();
    try {
      await _userRepo.toggleFavorite(_user!.id, providerId, add);
    } catch (_) {}
  }

  bool isFavorite(String providerId) =>
      _user?.favoriteProviderIds.contains(providerId) ?? false;
}
