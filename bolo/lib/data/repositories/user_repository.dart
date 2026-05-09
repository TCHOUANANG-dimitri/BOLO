import 'dart:io';
import '../models/user_model.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/storage_service.dart';

class UserRepository {
  final AuthService _auth = AuthService();
  final FirestoreService _db = FirestoreService();
  final StorageService _storage = StorageService();

  // ─── Lecture ──────────────────────────────────────────────────────────────

  Future<UserModel?> getById(String uid) async {
    try {
      final data = await _db.getDoc('users', uid);
      if (data == null) return null;
      return UserModel.fromFirestore(data);
    } catch (_) {
      return null;
    }
  }

  Stream<UserModel?> watchUser(String uid) {
    return _db
        .col('users')
        .doc(uid)
        .snapshots()
        .map((snap) =>
            snap.exists ? UserModel.fromFirestore(snap.data()!) : null);
  }

  // ─── Mise à jour profil ───────────────────────────────────────────────────

  Future<UserModel?> updateProfile({
    required String userId,
    String? fullName,
    String? phone,
    String? location,
    File? avatarFile,
  }) async {
    String? avatarUrl;
    if (avatarFile != null) {
      avatarUrl = await _storage.uploadAvatar(userId, avatarFile);
    }
    await _auth.updateProfile(
      userId: userId,
      fullName: fullName,
      phone: phone,
      avatarUrl: avatarUrl,
      location: location,
    );
    return await getById(userId);
  }

  // ─── Favoris ──────────────────────────────────────────────────────────────

  Future<void> toggleFavorite(
      String userId, String providerId, bool add) async {
    await _auth.toggleFavorite(userId, providerId, add);
  }

  // ─── 2FA ─────────────────────────────────────────────────────────────────

  Future<void> enable2FA(String userId) async {
    await _db.updateDoc('users', userId, {'twoFactorEnabled': true});
  }

  Future<void> disable2FA(String userId) async {
    await _db.updateDoc('users', userId, {'twoFactorEnabled': false});
  }
}
