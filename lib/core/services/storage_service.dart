import 'dart:io';
import 'package:image_picker/image_picker.dart';

/// Gestion des fichiers locaux (pas de cloud storage en local).
/// Les fichiers sont référencés par leur chemin local.
class StorageService {
  static final StorageService _instance = StorageService._();
  factory StorageService() => _instance;
  StorageService._();

  final ImagePicker _picker = ImagePicker();

  Future<File?> pickImage({
    ImageSource source = ImageSource.gallery,
    int quality = 80,
  }) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: quality,
    );
    return picked == null ? null : File(picked.path);
  }

  /// Retourne le chemin local du fichier (préfixe "local:" pour le distinguer d'une URL)
  Future<String> uploadAvatar(String userId, File file) async {
    return 'local:${file.path}';
  }

  Future<String> uploadBanner(String entityId, File file) async {
    return 'local:${file.path}';
  }

  Future<void> deleteFileByUrl(String url) async {
    // En local, rien à supprimer côté serveur
  }

  /// Convertit une référence locale en File si applicable
  static File? localFileFromUrl(String? url) {
    if (url == null) return null;
    if (url.startsWith('local:')) return File(url.substring(6));
    return null;
  }
}
