import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/repositories/provider_repository.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/provider_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final repo = ProviderRepository();
    final favorites = (auth.user?.favoriteProviderIds ?? [])
        .map((id) => repo.getById(id))
        .whereType<Object>()
        .map((p) => repo.getById(
              auth.user!.favoriteProviderIds.firstWhere(
                (id) => repo.getById(id) == p,
              ),
            ))
        .whereType<Object>()
        .toList();

    final favProviders = auth.user?.favoriteProviderIds
            .map((id) => repo.getById(id))
            .where((p) => p != null)
            .map((p) => p!)
            .toList() ??
        [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(AppStrings.myFavorites, style: AppTextStyles.headlineSmall),
      ),
      body: favProviders.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.favorite_border_rounded,
                      size: 72, color: AppColors.textLight.withOpacity(0.4)),
                  const SizedBox(height: 16),
                  Text('Aucun favori', style: AppTextStyles.headlineSmall),
                  const SizedBox(height: 8),
                  Text(
                    'Ajoutez des prestataires à vos favoris',
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.go('/home'),
                    child: const Text('Explorer'),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: favProviders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) =>
                  ProviderCard(provider: favProviders[i]),
            ),
    );
  }
}
