import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../widgets/bolo_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.splashGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const Spacer(flex: 2),

                // Logo
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.25),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Image.asset(
                      'assets/images/logo_white.png',
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.location_on_rounded,
                        color: AppColors.primary,
                        size: 48,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // App name
                Text(
                  'BOLO',
                  style: AppTextStyles.displayLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 3,
                    fontSize: 40,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.appTagline,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),

                const Spacer(flex: 2),

                // Illustration placeholder
                Container(
                  height: 200,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.08),
                        AppColors.primary.withOpacity(0.03),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.people_alt_rounded,
                          size: 64,
                          color: AppColors.primary.withOpacity(0.6),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Des milliers de prestataires\nvérifiés près de vous',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(flex: 1),

                // Buttons
                BoloButton(
                  onPressed: () => context.go('/login'),
                  label: AppStrings.login,
                ),
                const SizedBox(height: 12),

                BoloButton(
                  onPressed: () => context.go('/register'),
                  label: AppStrings.register,
                  isOutlined: true,
                ),
                const SizedBox(height: 12),

                // Guest mode
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => context.go('/home'),
                    child: Text(
                      'Continuer comme visiteur',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Terms
                Text(
                  'En continuant, vous acceptez nos Conditions d\'utilisation\net notre Politique de confidentialité.',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textLight,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
