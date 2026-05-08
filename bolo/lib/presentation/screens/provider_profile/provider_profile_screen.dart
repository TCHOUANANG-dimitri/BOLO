import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/provider_model.dart';
import '../../../data/models/review_model.dart';
import '../../../data/repositories/provider_repository.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/bolo_button.dart';
import '../../widgets/star_rating.dart';
import '../../widgets/provider_avatar.dart';

class ProviderProfileScreen extends StatefulWidget {
  final String providerId;

  const ProviderProfileScreen({super.key, required this.providerId});

  @override
  State<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends State<ProviderProfileScreen> {
  final _repo = ProviderRepository();
  ProviderModel? _provider;

  @override
  void initState() {
    super.initState();
    _provider = _repo.getById(widget.providerId);
  }

  @override
  Widget build(BuildContext context) {
    if (_provider == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Prestataire non trouvé')),
      );
    }

    final provider = _provider!;
    final auth = context.watch<AuthProvider>();
    final isFav = auth.isFavorite(provider.id);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: Colors.white,
            leading: GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    size: 18, color: AppColors.textPrimary),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () => auth.toggleFavorite(provider.id),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    size: 20,
                    color: isFav ? AppColors.error : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Banner
                  Container(
                    decoration: const BoxDecoration(
                      gradient: AppColors.primaryGradient,
                    ),
                  ),
                  // Avatar overlay at bottom
                  Positioned(
                    bottom: -36,
                    left: 24,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ProviderAvatar(
                        name: provider.name,
                        avatarUrl: provider.avatarUrl,
                        size: 84,
                        borderRadius: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name + verified
                      Row(
                        children: [
                          Expanded(
                            child: Text(provider.name,
                                style: AppTextStyles.headlineMedium),
                          ),
                          if (provider.isVerified)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.verified_rounded,
                                      size: 14, color: AppColors.primary),
                                  const SizedBox(width: 4),
                                  Text(
                                    AppStrings.verified,
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(provider.specialty,
                          style: AppTextStyles.bodyMedium),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded,
                              size: 14, color: AppColors.textLight),
                          const SizedBox(width: 4),
                          Text(provider.location,
                              style: AppTextStyles.caption),
                          if (provider.distance != null) ...[
                            Text(' • ',
                                style: AppTextStyles.caption),
                            Text(
                              '${provider.distance!.toStringAsFixed(1)} km',
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Stats row
                      _StatsRow(provider: provider),
                      const SizedBox(height: 24),

                      // About
                      Text(AppStrings.aboutTitle,
                          style: AppTextStyles.headlineSmall),
                      const SizedBox(height: 10),
                      Text(
                        provider.bio,
                        style: AppTextStyles.bodyMedium.copyWith(
                          height: 1.7,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Tags
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: provider.tags
                            .map((tag) => _TagChip(label: tag))
                            .toList(),
                      ),
                      const SizedBox(height: 24),

                      // Languages
                      if (provider.languages.isNotEmpty) ...[
                        Row(
                          children: [
                            const Icon(Icons.language_rounded,
                                size: 16, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Text('Langues parlées',
                                style: AppTextStyles.headlineSmall),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: provider.languages
                              .map((lang) => Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryLight,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(lang,
                                        style: AppTextStyles.labelSmall.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                        )),
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Services
                      Text(AppStrings.services,
                          style: AppTextStyles.headlineSmall),
                      const SizedBox(height: 12),
                      ...provider.services.map((s) => _ServiceRow(service: s)),
                      const SizedBox(height: 24),

                      // Reviews
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(AppStrings.recentReviews,
                              style: AppTextStyles.headlineSmall),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              AppStrings.seeAll,
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...provider.reviews
                          .take(3)
                          .map((r) => _ReviewCard(review: r)),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // Bottom actions
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          MediaQuery.of(context).padding.bottom + 16,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Price
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.priceLabel,
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                Text('par heure', style: AppTextStyles.caption),
              ],
            ),
            const SizedBox(width: 16),

            // Contact
            Expanded(
              child: BoloButton(
                onPressed: () => _startConversation(context, provider),
                label: AppStrings.contact,
                isOutlined: true,
                height: 48,
              ),
            ),
            const SizedBox(width: 10),

            // Book
            Expanded(
              child: BoloButton(
                onPressed: () => context.push('/booking/${provider.id}'),
                label: AppStrings.book,
                height: 48,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startConversation(BuildContext context, ProviderModel provider) {
    context.go('/home');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Message envoyé à ${provider.name}'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final ProviderModel provider;

  const _StatsRow({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatBox(
          value: provider.ratingLabel,
          label: AppStrings.note,
          icon: Icons.star_rounded,
          iconColor: AppColors.starFilled,
        ),
        const SizedBox(width: 10),
        _StatBox(
          value: provider.reviewCount.toString(),
          label: AppStrings.reviews,
          icon: Icons.chat_bubble_rounded,
          iconColor: AppColors.info,
        ),
        const SizedBox(width: 10),
        _StatBox(
          value: provider.experienceLabel,
          label: AppStrings.experience,
          icon: Icons.work_rounded,
          iconColor: AppColors.success,
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color iconColor;

  const _StatBox({
    required this.value,
    required this.label,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(label, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;

  const _TagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: AppTextStyles.labelSmall.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w500,
      )),
    );
  }
}

class _ServiceRow extends StatelessWidget {
  final String service;

  const _ServiceRow({required this.service});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Text(service, style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
          )),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ReviewModel review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(review.authorName, style: AppTextStyles.titleSmall),
              ),
              Text(review.timeAgo, style: AppTextStyles.caption),
            ],
          ),
          const SizedBox(height: 6),
          StarRatingRow(rating: review.rating, starSize: 14),
          const SizedBox(height: 8),
          Text(
            review.comment,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
