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
import '../../providers/review_provider.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReviewProvider>().loadReviews(widget.providerId);
    });
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
          // ─── AppBar avec bannière ───────────────────────────────────────
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
                    isFav
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
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
                  Container(
                      decoration: const BoxDecoration(
                          gradient: AppColors.primaryGradient)),
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
                              offset: const Offset(0, 4))
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
                      // Nom + badge vérifié
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
                                  Text(AppStrings.verified,
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      )),
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
                            Text(' • ', style: AppTextStyles.caption),
                            Text(
                              '${provider.distance!.toStringAsFixed(1)} km',
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Stats
                      _StatsRow(provider: provider),
                      const SizedBox(height: 24),

                      // À propos
                      Text(AppStrings.aboutTitle,
                          style: AppTextStyles.headlineSmall),
                      const SizedBox(height: 10),
                      Text(provider.bio,
                          style: AppTextStyles.bodyMedium.copyWith(
                            height: 1.7,
                            color: AppColors.textSecondary,
                          )),
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

                      // Langues
                      if (provider.languages.isNotEmpty) ...[
                        _SectionHeader(
                            icon: Icons.language_rounded,
                            label: 'Langues parlées'),
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
                                      borderRadius:
                                          BorderRadius.circular(20),
                                    ),
                                    child: Text(lang,
                                        style:
                                            AppTextStyles.labelSmall.copyWith(
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
                      ...provider.services
                          .map((s) => _ServiceRow(service: s)),
                      const SizedBox(height: 24),

                      // Section avis
                      _ReviewSection(
                        provider: provider,
                        currentUserId: auth.user?.id ?? '',
                        currentUserName: auth.user?.fullName ?? '',
                        currentUserAvatar: auth.user?.avatarUrl,
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // ─── Barre du bas ────────────────────────────────────────────────────
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
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(provider.priceLabel,
                    style: AppTextStyles.headlineSmall
                        .copyWith(color: AppColors.primary)),
                Text('par heure', style: AppTextStyles.caption),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: BoloButton(
                onPressed: () =>
                    _startConversation(context, provider),
                label: AppStrings.contact,
                isOutlined: true,
                height: 48,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: BoloButton(
                onPressed: () =>
                    context.push('/booking/${provider.id}'),
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

// ─── Section Avis (likes, notes, commentaires) ───────────────────────────────

class _ReviewSection extends StatefulWidget {
  final ProviderModel provider;
  final String currentUserId;
  final String currentUserName;
  final String? currentUserAvatar;

  const _ReviewSection({
    required this.provider,
    required this.currentUserId,
    required this.currentUserName,
    this.currentUserAvatar,
  });

  @override
  State<_ReviewSection> createState() => _ReviewSectionState();
}

class _ReviewSectionState extends State<_ReviewSection> {
  bool _canReview = false;
  bool _showAll = false;

  @override
  void initState() {
    super.initState();
    _checkCanReview();
  }

  Future<void> _checkCanReview() async {
    if (widget.currentUserId.isEmpty) return;
    final can = await context
        .read<ReviewProvider>()
        .canReview(widget.currentUserId, widget.provider.id);
    if (mounted) setState(() => _canReview = can);
  }

  @override
  Widget build(BuildContext context) {
    final reviewProv = context.watch<ReviewProvider>();
    final reviews = reviewProv.reviews;
    final displayed = _showAll ? reviews : reviews.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(AppStrings.recentReviews,
                style: AppTextStyles.headlineSmall),
            if (reviews.length > 3)
              TextButton(
                onPressed: () =>
                    setState(() => _showAll = !_showAll),
                child: Text(
                  _showAll ? 'Voir moins' : AppStrings.seeAll,
                  style: AppTextStyles.labelMedium
                      .copyWith(color: AppColors.primary),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),

        // Note globale
        if (reviews.isNotEmpty) ...[
          _GlobalRating(reviews: reviews),
          const SizedBox(height: 12),
        ],

        // Bouton Écrire un avis
        if (_canReview) ...[
          _WriteReviewButton(
            providerId: widget.provider.id,
            userId: widget.currentUserId,
            userName: widget.currentUserName,
            userAvatar: widget.currentUserAvatar,
          ),
          const SizedBox(height: 12),
        ],

        // Liste des avis
        if (reviewProv.isLoading)
          const Center(
              child: Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(),
          ))
        else if (reviews.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.rate_review_outlined,
                      size: 32, color: AppColors.textLight),
                  const SizedBox(height: 8),
                  Text('Aucun avis pour l\'instant',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textLight)),
                ],
              ),
            ),
          )
        else
          ...displayed.map((r) => _ReviewCard(
                review: r,
                currentUserId: widget.currentUserId,
                onLike: () => context
                    .read<ReviewProvider>()
                    .toggleLike(r.id, widget.currentUserId),
              )),
      ],
    );
  }
}

class _GlobalRating extends StatelessWidget {
  final List<ReviewModel> reviews;
  const _GlobalRating({required this.reviews});

  @override
  Widget build(BuildContext context) {
    final avg =
        reviews.fold(0.0, (s, r) => s + r.rating) / reviews.length;
    final counts = List.generate(5, (i) {
      final star = 5 - i;
      return reviews.where((r) => r.rating.round() == star).length;
    });

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(avg.toStringAsFixed(1),
                  style: AppTextStyles.displayLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  )),
              StarRatingRow(rating: avg, starSize: 14),
              const SizedBox(height: 4),
              Text('${reviews.length} avis',
                  style: AppTextStyles.caption),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              children: List.generate(5, (i) {
                final star = 5 - i;
                final count = counts[i];
                final pct = reviews.isEmpty
                    ? 0.0
                    : count / reviews.length;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Text('$star',
                          style: AppTextStyles.caption
                              .copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(width: 4),
                      const Icon(Icons.star_rounded,
                          size: 12, color: AppColors.starFilled),
                      const SizedBox(width: 6),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: pct,
                            backgroundColor: AppColors.border,
                            valueColor:
                                const AlwaysStoppedAnimation<Color>(
                                    AppColors.primary),
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text('$count',
                          style: AppTextStyles.caption),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _WriteReviewButton extends StatelessWidget {
  final String providerId;
  final String userId;
  final String userName;
  final String? userAvatar;

  const _WriteReviewButton({
    required this.providerId,
    required this.userId,
    required this.userName,
    this.userAvatar,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showReviewSheet(context),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.rate_review_rounded,
                color: AppColors.primary, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Laisser un avis sur ce prestataire',
                style: AppTextStyles.titleSmall
                    .copyWith(color: AppColors.primary),
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  void _showReviewSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _WriteReviewSheet(
        providerId: providerId,
        userId: userId,
        userName: userName,
        userAvatar: userAvatar,
      ),
    );
  }
}

class _WriteReviewSheet extends StatefulWidget {
  final String providerId;
  final String userId;
  final String userName;
  final String? userAvatar;

  const _WriteReviewSheet({
    required this.providerId,
    required this.userId,
    required this.userName,
    this.userAvatar,
  });

  @override
  State<_WriteReviewSheet> createState() => _WriteReviewSheetState();
}

class _WriteReviewSheetState extends State<_WriteReviewSheet> {
  double _rating = 0;
  final _commentCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez donner une note')),
      );
      return;
    }
    if (_commentCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Veuillez écrire un commentaire')),
      );
      return;
    }

    setState(() => _submitting = true);
    final success = await context.read<ReviewProvider>().submitReview(
          providerId: widget.providerId,
          authorId: widget.userId,
          authorName: widget.userName,
          authorAvatar: widget.userAvatar,
          rating: _rating,
          comment: _commentCtrl.text.trim(),
        );

    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Avis publié avec succès !'
              : 'Vous avez déjà laissé un avis pour ce prestataire.',
        ),
        backgroundColor:
            success ? AppColors.success : AppColors.textLight,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.fromLTRB(
            24, 20, 24, MediaQuery.of(context).padding.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text('Votre avis', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 4),
            Text(
              'Partagez votre expérience pour aider la communauté.',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),

            // Étoiles interactives
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (i) {
                  final star = i + 1;
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _rating = star.toDouble()),
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        star <= _rating
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: star <= _rating
                            ? AppColors.starFilled
                            : AppColors.border,
                        size: 40,
                      ),
                    ),
                  );
                }),
              ),
            ),
            if (_rating > 0) ...[
              const SizedBox(height: 8),
              Center(
                child: Text(
                  _ratingLabel(_rating),
                  style: AppTextStyles.titleSmall
                      .copyWith(color: AppColors.primary),
                ),
              ),
            ],
            const SizedBox(height: 20),

            // Commentaire
            TextField(
              controller: _commentCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText:
                    'Décrivez votre expérience (ponctualité, qualité, professionnalisme...)',
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
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 20),

            BoloButton(
              onPressed: _submit,
              label: 'Publier l\'avis',
              isLoading: _submitting,
              icon: Icons.send_rounded,
            ),
          ],
        ),
      ),
    );
  }

  String _ratingLabel(double r) {
    if (r <= 1) return 'Très insatisfait';
    if (r <= 2) return 'Insatisfait';
    if (r <= 3) return 'Correct';
    if (r <= 4) return 'Bien';
    return 'Excellent !';
  }
}

class _ReviewCard extends StatelessWidget {
  final ReviewModel review;
  final String currentUserId;
  final VoidCallback onLike;

  const _ReviewCard({
    required this.review,
    required this.currentUserId,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    final liked = review.isLikedBy(currentUserId);

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
          // Auteur + date
          Row(
            children: [
              // Avatar
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    review.authorName.isNotEmpty
                        ? review.authorName[0].toUpperCase()
                        : '?',
                    style: AppTextStyles.titleSmall
                        .copyWith(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.authorName,
                        style: AppTextStyles.titleSmall),
                    Text(review.timeAgo,
                        style: AppTextStyles.caption),
                  ],
                ),
              ),
              // Like
              GestureDetector(
                onTap: currentUserId.isNotEmpty ? onLike : null,
                child: Row(
                  children: [
                    Icon(
                      liked
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      size: 18,
                      color: liked
                          ? AppColors.error
                          : AppColors.textLight,
                    ),
                    if (review.likeCount > 0) ...[
                      const SizedBox(width: 4),
                      Text('${review.likeCount}',
                          style: AppTextStyles.caption.copyWith(
                            color: liked
                                ? AppColors.error
                                : AppColors.textLight,
                            fontWeight: FontWeight.w600,
                          )),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Note étoiles
          StarRatingRow(rating: review.rating, starSize: 14),
          const SizedBox(height: 8),

          // Commentaire
          Text(
            review.comment,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),

          // Réponse prestataire
          if (review.providerReply != null &&
              review.providerReply!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
                border: Border(
                  left: BorderSide(
                      color: AppColors.primary, width: 3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.verified_rounded,
                          size: 12, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text('Réponse du prestataire',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          )),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(review.providerReply!,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Widgets utilitaires ─────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SectionHeader({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(label, style: AppTextStyles.headlineSmall),
        ],
      );
}

class _StatsRow extends StatelessWidget {
  final ProviderModel provider;
  const _StatsRow({required this.provider});

  @override
  Widget build(BuildContext context) => Row(
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
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Text(value,
                  style: AppTextStyles.headlineSmall
                      .copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(label, style: AppTextStyles.caption),
            ],
          ),
        ),
      );
}

class _TagChip extends StatelessWidget {
  final String label;
  const _TagChip({required this.label});

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            )),
      );
}

class _ServiceRow extends StatelessWidget {
  final String service;
  const _ServiceRow({required this.service});

  @override
  Widget build(BuildContext context) => Padding(
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
            Expanded(
              child: Text(service,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textPrimary)),
            ),
          ],
        ),
      );
}
