import 'package:shared_preferences/shared_preferences.dart';
import 'local_db_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._();
  factory AuthService() => _instance;
  AuthService._();

  final LocalDbService _db = LocalDbService();
  static const _sessionKey = 'auth_session_user_id';

  // ─── Session ───────────────────────────────────────────────────────────────

  Future<String?> currentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sessionKey);
  }

  Future<Map<String, dynamic>?> currentUserData() async {
    final id = await currentUserId();
    if (id == null) return null;
    return await _db.getDoc('users', id);
  }

  Future<void> _saveSession(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, userId);
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  // ─── Inscription ──────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> registerWithEmail({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required bool isProvider,
  }) async {
    // Vérifier si l'email existe déjà
    final existing = await _db.queryDocs('users',
        whereField: 'email', whereValue: email.toLowerCase().trim());
    if (existing.isNotEmpty) {
      throw AuthException('email-already-in-use');
    }

    final id = 'u_${DateTime.now().millisecondsSinceEpoch}';
    final userData = {
      'id': id,
      'fullName': fullName,
      'email': email.toLowerCase().trim(),
      'password': _hash(password),
      'phone': phone,
      'isProvider': isProvider,
      'avatarUrl': null,
      'location': null,
      'createdAt': DateTime.now().toIso8601String(),
      'twoFactorEnabled': false,
      'favoriteProviderIds': <String>[],
    };

    await _db.setDoc('users', id, userData, merge: false);
    await _saveSession(id);

    return userData;
  }

  // ─── Connexion ────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final users = await _db.queryDocs('users',
        whereField: 'email', whereValue: email.toLowerCase().trim());

    if (users.isEmpty) throw AuthException('user-not-found');

    final user = users.first;
    if (user['password'] != _hash(password)) {
      throw AuthException('wrong-password');
    }

    await _saveSession(user['id'] as String);
    return user;
  }

  // ─── OTP (mode démo local) ─────────────────────────────────────────────────
  // En local, tout code à 6 chiffres est accepté.
  // Le code "123456" est toujours valide pour les tests.

  Future<void> sendPhoneOtp({required String phone}) async {
    // En mode local : simule l'envoi sans rien faire.
    // Dans les logs console on peut afficher le "code envoyé"
    // ignore: avoid_print
    print('[BOLO LOCAL] OTP envoyé au $phone — utilisez n\'importe quel code à 6 chiffres');
    await Future.delayed(const Duration(milliseconds: 500));
  }

  bool verifyOtp(String code) {
    return code.length == 6 && RegExp(r'^\d{6}$').hasMatch(code);
  }

  // ─── Profil ───────────────────────────────────────────────────────────────

  Future<void> updateProfile({
    required String userId,
    String? fullName,
    String? phone,
    String? avatarUrl,
    String? location,
  }) async {
    final data = <String, dynamic>{};
    if (fullName != null) data['fullName'] = fullName;
    if (phone != null) data['phone'] = phone;
    if (avatarUrl != null) data['avatarUrl'] = avatarUrl;
    if (location != null) data['location'] = location;
    if (data.isNotEmpty) {
      await _db.updateDoc('users', userId, data);
    }
  }

  Future<void> toggleFavorite(
      String userId, String providerId, bool add) async {
    if (add) {
      await _db.arrayUnion('users', userId, 'favoriteProviderIds', providerId);
    } else {
      await _db.arrayRemove('users', userId, 'favoriteProviderIds', providerId);
    }
  }

  // ─── Hash simple ─────────────────────────────────────────────────────────
  // Pas de dépendance externe — hashCode suffit pour le dev local.

  String _hash(String input) {
    var hash = 5381;
    for (final c in input.codeUnits) {
      hash = ((hash << 5) + hash) + c;
      hash = hash & 0x7FFFFFFF; // garder positif sur 31 bits
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }
}

class AuthException implements Exception {
  final String code;
  AuthException(this.code);

  String get message {
    switch (code) {
      case 'user-not-found':
        return 'Aucun compte trouvé avec cet email';
      case 'wrong-password':
        return 'Mot de passe incorrect';
      case 'email-already-in-use':
        return 'Cet email est déjà utilisé';
      case 'weak-password':
        return 'Mot de passe trop faible (min. 6 caractères)';
      default:
        return 'Erreur d\'authentification';
    }
  }
}
