import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../widgets/bolo_button.dart';
import '../../widgets/bolo_logo.dart';

class IdentityVerificationScreen extends StatefulWidget {
  const IdentityVerificationScreen({super.key});

  @override
  State<IdentityVerificationScreen> createState() =>
      _IdentityVerificationScreenState();
}

class _IdentityVerificationScreenState
    extends State<IdentityVerificationScreen> {
  File? _cniRecto;
  File? _cniVerso;
  File? _selfie;
  File? _casierJudiciaire;
  final _referencesCtrl = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _referencesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(
      ImageSource source, void Function(File) onPicked) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (picked != null) onPicked(File(picked.path));
  }

  bool get _canSubmit =>
      _cniRecto != null && _cniVerso != null && _selfie != null;

  Future<void> _submit() async {
    if (!_canSubmit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('CNI recto/verso et selfie sont obligatoires'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    context.go('/provider-contract');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const BoloLogo(size: 36),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_user_rounded,
                      color: Colors.white, size: 32),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Vérification d\'identité',
                            style: AppTextStyles.titleMedium
                                .copyWith(color: Colors.white)),
                        const SizedBox(height: 4),
                        Text(
                          'Ces documents permettent d\'obtenir le badge "Profil vérifié" et rassurer les clients.',
                          style: AppTextStyles.caption
                              .copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // CNI Recto
            _DocUploadCard(
              label: 'CNI / Passeport — Recto *',
              description: 'Photo nette du recto de votre pièce d\'identité',
              icon: Icons.credit_card_rounded,
              file: _cniRecto,
              isRequired: true,
              onPickGallery: () => _pickImage(
                  ImageSource.gallery, (f) => setState(() => _cniRecto = f)),
              onPickCamera: () => _pickImage(
                  ImageSource.camera, (f) => setState(() => _cniRecto = f)),
            ),
            const SizedBox(height: 14),

            // CNI Verso
            _DocUploadCard(
              label: 'CNI / Passeport — Verso *',
              description: 'Photo nette du verso de votre pièce d\'identité',
              icon: Icons.credit_card_outlined,
              file: _cniVerso,
              isRequired: true,
              onPickGallery: () => _pickImage(
                  ImageSource.gallery, (f) => setState(() => _cniVerso = f)),
              onPickCamera: () => _pickImage(
                  ImageSource.camera, (f) => setState(() => _cniVerso = f)),
            ),
            const SizedBox(height: 14),

            // Selfie
            _DocUploadCard(
              label: 'Selfie de vérification *',
              description:
                  'Prenez une photo de vous tenant votre CNI devant votre visage',
              icon: Icons.face_rounded,
              file: _selfie,
              isRequired: true,
              onPickGallery: () => _pickImage(
                  ImageSource.gallery, (f) => setState(() => _selfie = f)),
              onPickCamera: () => _pickImage(
                  ImageSource.camera, (f) => setState(() => _selfie = f)),
            ),
            const SizedBox(height: 14),

            // Casier judiciaire
            _DocUploadCard(
              label: 'Casier judiciaire',
              description:
                  'Bulletin n°3 datant de moins de 3 mois (fortement recommandé)',
              icon: Icons.gavel_rounded,
              file: _casierJudiciaire,
              isRequired: false,
              onPickGallery: () => _pickImage(ImageSource.gallery,
                  (f) => setState(() => _casierJudiciaire = f)),
              onPickCamera: () => _pickImage(ImageSource.camera,
                  (f) => setState(() => _casierJudiciaire = f)),
            ),
            const SizedBox(height: 14),

            // Références
            Text('Références professionnelles (facultatif)',
                style: AppTextStyles.titleSmall),
            const SizedBox(height: 8),
            TextField(
              controller: _referencesCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText:
                    'Noms, numéros ou emails de personnes pouvant attester de votre sérieux...',
                hintStyle: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textLight),
                filled: true,
                fillColor: AppColors.cardBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 20),

            // Note confidentialité
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.success.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock_rounded,
                      size: 16, color: AppColors.success),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Vos documents sont chiffrés et utilisés uniquement pour la vérification. Ils ne sont jamais partagés avec les clients.',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.success),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            BoloButton(
              onPressed: _submit,
              label: 'Soumettre pour vérification',
              isLoading: _isSubmitting,
              icon: Icons.upload_rounded,
            ),
          ],
        ),
      ),
    );
  }
}

class _DocUploadCard extends StatelessWidget {
  final String label;
  final String description;
  final IconData icon;
  final File? file;
  final bool isRequired;
  final VoidCallback onPickGallery;
  final VoidCallback onPickCamera;

  const _DocUploadCard({
    required this.label,
    required this.description,
    required this.icon,
    required this.file,
    required this.isRequired,
    required this.onPickGallery,
    required this.onPickCamera,
  });

  @override
  Widget build(BuildContext context) {
    final hasFile = file != null;

    return Container(
      decoration: BoxDecoration(
        color: hasFile
            ? const Color(0xFFF0FDF4)
            : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasFile
              ? AppColors.success.withOpacity(0.4)
              : AppColors.border,
        ),
      ),
      child: Column(
        children: [
          // Preview si image chargée
          if (hasFile)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(13)),
              child: Image.file(
                file!,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: hasFile
                        ? AppColors.success.withOpacity(0.12)
                        : AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    hasFile ? Icons.check_circle_rounded : icon,
                    color: hasFile ? AppColors.success : AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: AppTextStyles.titleSmall),
                      Text(
                        hasFile ? 'Document ajouté ✓' : description,
                        style: AppTextStyles.caption.copyWith(
                          color: hasFile
                              ? AppColors.success
                              : AppColors.textLight,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    _IconBtn(
                        icon: Icons.photo_library_rounded,
                        onTap: onPickGallery),
                    const SizedBox(height: 6),
                    _IconBtn(
                        icon: Icons.camera_alt_rounded,
                        onTap: onPickCamera),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: AppColors.primary),
      ),
    );
  }
}
