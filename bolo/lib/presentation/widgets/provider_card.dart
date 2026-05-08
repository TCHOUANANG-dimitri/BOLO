import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/models/provider_model.dart';
import 'star_rating.dart';
import 'provider_avatar.dart';

class ProviderCard extends StatelessWidget {
  final ProviderModel provider;
  final VoidCallback? onTap;

  const ProviderCard({super.key, required this.provider, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => context.push('/provider/${provider.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Avatar
              Stack(
                children: [
                  ProviderAvatar(
                    name: provider.name,
                    avatarUrl: provider.avatarUrl,
                    size: 60,
                  ),
                  if (provider.isOnline)
                    Positioned(
                      right: 2,
                      bottom: 2,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppColors.online,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            provider.name,
                            style: AppTextStyles.titleMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (provider.isVerified)
                          const Icon(
                            Icons.verified_rounded,
                            size: 16,
                            color: AppColors.primary,
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      provider.specialty,
                      style: AppTextStyles.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        StarRating(rating: provider.rating, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          provider.ratingLabel,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          ' (${provider.reviewCount})',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Price
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    provider.priceLabel,
                    style: AppTextStyles.price,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProviderCardCompact extends StatelessWidget {
  final ProviderModel provider;

  const ProviderCardCompact({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/provider/${provider.id}'),
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ProviderAvatar(
                    name: provider.name,
                    avatarUrl: provider.avatarUrl,
                    size: 56,
                    borderRadius: 12,
                  ),
                  if (provider.isVerified)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.verified_rounded,
                          size: 12,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                provider.name,
                style: AppTextStyles.titleSmall,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                provider.specialty,
                style: AppTextStyles.caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  StarRating(rating: provider.rating, size: 12),
                  const SizedBox(width: 3),
                  Text(
                    provider.ratingLabel,
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                provider.priceLabel,
                style: AppTextStyles.price.copyWith(fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
