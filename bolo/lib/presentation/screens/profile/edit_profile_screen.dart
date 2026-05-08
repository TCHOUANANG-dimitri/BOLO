import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/bolo_button.dart';
import '../../widgets/bolo_text_field.dart';
import '../../widgets/provider_avatar.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _locationCtrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameCtrl = TextEditingController(text: user?.fullName ?? '');
    _phoneCtrl = TextEditingController(text: user?.phone ?? '');
    _locationCtrl = TextEditingController(text: user?.location ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    await context.read<AuthProvider>().updateProfile(
          fullName: _nameCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
          location: _locationCtrl.text.trim(),
        );
    setState(() => _isSaving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil mis à jour !')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(AppStrings.editProfile, style: AppTextStyles.headlineSmall),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar
            Center(
              child: Stack(
                children: [
                  user != null
                      ? ProviderAvatar(
                          name: user.fullName,
                          avatarUrl: user.avatarUrl,
                          size: 100,
                          borderRadius: 24,
                        )
                      : Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Icon(Icons.person_rounded,
                              size: 52, color: AppColors.primary),
                        ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt_rounded,
                          size: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Name
            BoloTextField(
              controller: _nameCtrl,
              label: AppStrings.fullName,
              hint: 'Jean Dupont',
              prefixIcon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: 16),

            // Email (read only)
            BoloTextField(
              controller: TextEditingController(text: user?.email ?? ''),
              label: AppStrings.email,
              hint: 'votre@email.com',
              prefixIcon: Icons.email_outlined,
              readOnly: true,
            ),
            const SizedBox(height: 16),

            // Phone
            BoloTextField(
              controller: _phoneCtrl,
              label: AppStrings.phone,
              hint: '+221 77 000 00 00',
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone_outlined,
            ),
            const SizedBox(height: 16),

            // Location
            BoloTextField(
              controller: _locationCtrl,
              label: 'Localisation',
              hint: 'Dakar, Sénégal',
              prefixIcon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 32),

            BoloButton(
              onPressed: _save,
              label: AppStrings.save,
              isLoading: _isSaving,
            ),
          ],
        ),
      ),
    );
  }
}
