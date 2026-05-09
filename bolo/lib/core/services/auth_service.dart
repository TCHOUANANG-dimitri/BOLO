import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ─── Inscription ──────────────────────────────────────────────────────────

  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required bool isProvider,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await cred.user?.updateDisplayName(fullName);

    await _db.collection('users').doc(cred.user!.uid).set({
      'id': cred.user!.uid,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'isProvider': isProvider,
      'avatarUrl': null,
      'location': null,
      'createdAt': FieldValue.serverTimestamp(),
      'twoFactorEnabled': false,
      'favoriteProviderIds': [],
    });

    return cred;
  }

  // ─── Connexion ────────────────────────────────────────────────────────────

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // ─── OTP / 2FA (Firebase Phone Auth) ─────────────────────────────────────

  Future<void> sendPhoneOtp({
    required String phone,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
    Function(PhoneAuthCredential)? onAutoVerified,
  }) async {
    final formatted = _formatPhone(phone);
    await _auth.verifyPhoneNumber(
      phoneNumber: formatted,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (credential) => onAutoVerified?.call(credential),
      verificationFailed: (e) => onError(e.message ?? 'Échec de la vérification'),
      codeSent: (verificationId, _) => onCodeSent(verificationId),
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  Future<bool> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await user.linkWithCredential(credential);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'provider-already-linked' ||
            e.code == 'credential-already-in-use') {
          await _auth.signInWithCredential(credential);
        } else {
          rethrow;
        }
      }
      await _db.collection('users').doc(user.uid).update({
        'twoFactorEnabled': true,
        'phone': user.phoneNumber ?? '',
      });
    } else {
      await _auth.signInWithCredential(credential);
    }
    return true;
  }

  // ─── Profil ───────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.exists ? doc.data() : null;
  }

  Future<void> updateProfile({
    required String userId,
    String? fullName,
    String? phone,
    String? avatarUrl,
    String? location,
  }) async {
    final data = <String, dynamic>{};
    if (fullName != null) {
      data['fullName'] = fullName;
      await _auth.currentUser?.updateDisplayName(fullName);
    }
    if (phone != null) data['phone'] = phone;
    if (avatarUrl != null) data['avatarUrl'] = avatarUrl;
    if (location != null) data['location'] = location;
    if (data.isNotEmpty) {
      await _db.collection('users').doc(userId).update(data);
    }
  }

  Future<void> toggleFavorite(
      String userId, String providerId, bool add) async {
    final ref = _db.collection('users').doc(userId);
    if (add) {
      await ref.update({
        'favoriteProviderIds': FieldValue.arrayUnion([providerId])
      });
    } else {
      await ref.update({
        'favoriteProviderIds': FieldValue.arrayRemove([providerId])
      });
    }
  }

  Future<void> signOut() async => await _auth.signOut();

  // ─── Helpers ──────────────────────────────────────────────────────────────

  String _formatPhone(String phone) {
    final clean = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (clean.startsWith('+')) return clean;
    if (clean.startsWith('237')) return '+$clean';
    return '+237$clean';
  }
}
