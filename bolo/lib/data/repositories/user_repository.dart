import 'dart:io';
import '../models/user_model.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/local_db_service.dart';
import '../../core/services/storage_service.dart';

class UserRepository {
  final AuthService _auth = AuthService();
  final LocalDbService _db = LocalDbService();
  final StorageService _storage = StorageService();

  Future<UserModel?> getById(String uid) async {
    try {
      final data = await _db.getDoc('users', uid);
      return data != null ? UserModel.fromLocal(data) : null;
    } catch (_) {
      return null;
    }
  }

  Stream<UserModel?> watchUser(String uid) {
    return _db
        .streamDocs('users')
        .map((docs) {
          final match = docs.where((d) => d['id'] == uid).firstOrNull;
          return match != null ? UserModel.fromLocal(match) : null;
        });
  }

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

  Future<void> toggleFavorite(
      String userId, String providerId, bool add) async {
    await _auth.toggleFavorite(userId, providerId, add);
  }

  Future<void> enable2FA(String userId) async {
    await _db.updateDoc('users', userId, {'twoFactorEnabled': true});
  }

  Future<void> disable2FA(String userId) async {
    await _db.updateDoc('users', userId, {'twoFactorEnabled': false});
  }
}
