import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  // Stocké lors de l'envoi OTP, utilisé lors de la vérification
  String? _verificationId;
  bool _awaitingOtp = false;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get error => _error;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get awaitingOtp => _awaitingOtp;
  String? get verificationId => _verificationId;

  // ─── Initialisation ───────────────────────────────────────────────────────

  Future<void> checkAuth() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        final userData = await _userRepo.getById(firebaseUser.uid);
        _user = userData ?? _buildFallbackUser(firebaseUser);
        _status = AuthStatus.authenticated;
      } else {
        // Mode démo sans Firebase : auto-connecté
        _user = MockData.currentUser;
        _status = AuthStatus.authenticated;
      }
    } catch (_) {
      // Firebase non configuré : mode démo
      _user = MockData.currentUser;
      _status = AuthStatus.authenticated;
    }

    notifyListeners();
  }

  // ─── Connexion (email + mot de passe + 2FA si activé) ────────────────────

  Future<bool> login(String email, String password) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();

    try {
      final cred = await _authService.signInWithEmail(
        email: email,
        password: password,
      );

      final userData = await _userRepo.getById(cred.user!.uid);
      _user = userData ?? _buildFallbackUser(cred.user!);

      // Si 2FA activé → envoyer OTP, ne pas marquer comme authentifié
      if (_user!.twoFactorEnabled && _user!.phone.isNotEmpty) {
        await _sendOtpInternal(_user!.phone);
        _awaitingOtp = true;
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false; // Indique au caller qu'il faut l'OTP
      }

      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _firebaseError(e.code);
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    } catch (_) {
      // Fallback démo
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
      final cred = await _authService.registerWithEmail(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
        isProvider: isProvider,
      );

      _user = UserModel(
        id: cred.user!.uid,
        fullName: fullName,
        email: email,
        phone: phone,
        isProvider: isProvider,
        createdAt: DateTime.now(),
      );

      // Envoyer OTP pour vérifier le téléphone (2FA d'inscription)
      await _sendOtpInternal(phone);
      _awaitingOtp = true;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _firebaseError(e.code);
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

  // ─── Envoi OTP ────────────────────────────────────────────────────────────

  Future<void> sendOtp(String phone) async {
    await _sendOtpInternal(phone);
  }

  Future<void> _sendOtpInternal(String phone) async {
    try {
      await _authService.sendPhoneOtp(
        phone: phone,
        onCodeSent: (id) {
          _verificationId = id;
          notifyListeners();
        },
        onError: (err) {
          _error = err;
          notifyListeners();
        },
        onAutoVerified: (credential) async {
          await _completeOtpVerification(credential: credential);
        },
      );
    } catch (_) {
      // Firebase phone auth non disponible : mode démo
    }
  }

  // ─── Vérification OTP ─────────────────────────────────────────────────────

  Future<bool> verifyOtp(String code) async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      if (_verificationId != null) {
        final credential = PhoneAuthProvider.credential(
          verificationId: _verificationId!,
          smsCode: code,
        );
        await _completeOtpVerification(credential: credential);
        return true;
      } else {
        // Mode démo : accepter tout code à 6 chiffres
        if (code.length == 6 && RegExp(r'^\d{6}$').hasMatch(code)) {
          await _finalizeAuth();
          return true;
        }
        _error = 'Code invalide';
        _status = AuthStatus.error;
        notifyListeners();
        return false;
      }
    } on FirebaseAuthException catch (e) {
      _error = _firebaseError(e.code);
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    } catch (_) {
      // Fallback démo
      if (code.length == 6) {
        await _finalizeAuth();
        return true;
      }
      _error = 'Code invalide';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> _completeOtpVerification({
    required PhoneAuthCredential credential,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await user.linkWithCredential(credential);
      } on FirebaseAuthException catch (e) {
        if (e.code != 'provider-already-linked' &&
            e.code != 'credential-already-in-use') rethrow;
      }
      // Activer 2FA sur le profil
      await _userRepo.enable2FA(user.uid);
    } else {
      await FirebaseAuth.instance.signInWithCredential(credential);
    }
    await _finalizeAuth();
  }

  Future<void> _finalizeAuth() async {
    _awaitingOtp = false;
    _verificationId = null;
    if (_user != null) {
      _user = _user!.copyWith(twoFactorEnabled: true);
    }
    _status = AuthStatus.authenticated;
    notifyListeners();
  }

  // ─── Déconnexion ──────────────────────────────────────────────────────────

  Future<void> logout() async {
    try {
      await _authService.signOut();
    } catch (_) {}
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
      _user = updated ?? _user!.copyWith(
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

  // ─── Helpers ──────────────────────────────────────────────────────────────

  UserModel _buildFallbackUser(User firebaseUser) => UserModel(
        id: firebaseUser.uid,
        fullName: firebaseUser.displayName ?? 'Utilisateur',
        email: firebaseUser.email ?? '',
        phone: firebaseUser.phoneNumber ?? '',
        createdAt: DateTime.now(),
      );

  String _firebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Aucun compte trouvé avec cet email';
      case 'wrong-password':
        return 'Mot de passe incorrect';
      case 'email-already-in-use':
        return 'Cet email est déjà utilisé';
      case 'weak-password':
        return 'Mot de passe trop faible (min. 6 caractères)';
      case 'invalid-email':
        return 'Email invalide';
      case 'invalid-verification-code':
        return 'Code OTP incorrect';
      case 'session-expired':
        return 'Session expirée. Renvoyez le code.';
      case 'too-many-requests':
        return 'Trop de tentatives. Réessayez plus tard.';
      default:
        return 'Erreur : $code';
    }
  }
}
