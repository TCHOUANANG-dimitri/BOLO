import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../widgets/bolo_logo.dart';

class ProviderLoyaltyScreen extends StatefulWidget {
  const ProviderLoyaltyScreen({super.key});

  @override
  State<ProviderLoyaltyScreen> createState() => _ProviderLoyaltyScreenState();
}

class _ProviderLoyaltyScreenState extends State<ProviderLoyaltyScreen> {
  int _selectedPlan = 0; // 0 = Free, 1 = Standard, 2 = Premium

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go('/provider-dashboard'),
        ),
        title: const BoloLogo(size: 36),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7B2FBE), Color(0xFFE040FB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.workspace_premium_rounded,
                      color: Colors.amber, size: 40),
                  const SizedBox(height: 12),
                  Text(
                    'Programme de fidélisation',
                    style: AppTextStyles.titleMedium
                        .copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Boostez votre visibilité et gagnez plus de clients grâce aux abonnements BOLO.',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: Colors.white70, height: 1.5),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Badges section
            Text('Vos badges', style: AppTextStyles.titleSmall),
            const SizedBox(height: 12),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: const [
                  _BadgeCard(
                    icon: Icons.verified_rounded,
                    label: 'Profil vérifié',
                    color: AppColors.primary,
                    earned: true,
                  ),
                  SizedBox(width: 10),
                  _BadgeCard(
                    icon: Icons.star_rounded,
                    label: 'Top noté',
                    color: Colors.amber,
                    earned: false,
                  ),
                  SizedBox(width: 10),
                  _BadgeCard(
                    icon: Icons.favorite_rounded,
                    label: 'Coup de cœur',
                    color: Colors.red,
                    earned: false,
                  ),
                  SizedBox(width: 10),
                  _BadgeCard(
                    icon: Icons.bolt_rounded,
                    label: 'Réponse rapide',
                    color: Colors.orange,
                    earned: false,
                  ),
                  SizedBox(width: 10),
                  _BadgeCard(
                    icon: Icons.emoji_events_rounded,
                    label: 'Top prestataire',
                    color: Color(0xFF7B2FBE),
                    earned: false,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Ranking card
            Text('Votre classement', style: AppTextStyles.titleSmall),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text('#12',
                              style: AppTextStyles.titleMedium
                                  .copyWith(color: AppColors.primary)),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Plombiers à Yaoundé',
                                style: AppTextStyles.titleSmall),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: 0.4,
                              backgroundColor: AppColors.primaryLight,
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Passez Premium pour atteindre le top 5',
                              style: AppTextStyles.caption
                                  .copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Plans
            Text('Choisir un abonnement', style: AppTextStyles.titleSmall),
            const SizedBox(height: 12),

            _PlanCard(
              index: 0,
              selectedIndex: _selectedPlan,
              name: 'Gratuit',
              price: 0,
              color: AppColors.textSecondary,
              features: const [
                'Profil de base',
                'Visibilité standard',
                'Messagerie incluse',
              ],
              lockedFeatures: const [
                'Boost de visibilité',
                'Badges Premium',
                'Classement prioritaire',
                'Statistiques avancées',
              ],
              onSelect: () => setState(() => _selectedPlan = 0),
            ),
            const SizedBox(height: 12),

            _PlanCard(
              index: 1,
              selectedIndex: _selectedPlan,
              name: 'Standard',
              price: 2500,
              color: AppColors.primary,
              features: const [
                'Profil boosté × 2',
                'Badge "Réponse rapide"',
                'Top 10 local garanti',
                'Statistiques de base',
              ],
              lockedFeatures: const [
                'Badge "Coup de cœur"',
                'Classement Top 3',
                'Statistiques avancées',
              ],
              onSelect: () => setState(() => _selectedPlan = 1),
            ),
            const SizedBox(height: 12),

            _PlanCard(
              index: 2,
              selectedIndex: _selectedPlan,
              name: 'Premium',
              price: 5000,
              color: const Color(0xFF7B2FBE),
              badge: 'Recommandé',
              features: const [
                'Profil boosté × 5',
                'Tous les badges inclus',
                'Top 3 local garanti',
                'Statistiques avancées',
                'Mise en avant dans la recherche',
                'Support prioritaire BOLO',
              ],
              lockedFeatures: const [],
              onSelect: () => setState(() => _selectedPlan = 2),
            ),

            const SizedBox(height: 24),

            // Subscribe button
            if (_selectedPlan > 0)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _subscribe,
                  icon: const Icon(Icons.workspace_premium_rounded),
                  label: Text(
                      'S\'abonner — ${_selectedPlan == 1 ? '2 500' : '5 000'} FCFA/mois'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedPlan == 1
                        ? AppColors.primary
                        : const Color(0xFF7B2FBE),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

            if (_selectedPlan > 0) const SizedBox(height: 12),

            Center(
              child: Text(
                'Abonnement mensuel · Résiliable à tout moment',
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.textLight),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _subscribe() {
    final plan = _selectedPlan == 1 ? 'Standard' : 'Premium';
    final price = _selectedPlan == 1 ? 2500 : 5000;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('S\'abonner au plan $plan ?'),
        content: Text(
          'Un paiement de $price FCFA/mois sera effectué via Mobile Money. Vous pouvez annuler à tout moment.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Abonnement $plan activé !'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool earned;

  const _BadgeCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.earned,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: earned ? 1.0 : 0.45,
      child: Container(
        width: 90,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: earned ? color.withOpacity(0.1) : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: earned ? color.withOpacity(0.4) : AppColors.border,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: earned ? color : AppColors.textSecondary,
                fontWeight: earned ? FontWeight.w700 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
            if (!earned) ...[
              const SizedBox(height: 4),
              const Icon(Icons.lock_rounded, size: 12, color: AppColors.textLight),
            ],
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final int index;
  final int selectedIndex;
  final String name;
  final int price;
  final Color color;
  final String? badge;
  final List<String> features;
  final List<String> lockedFeatures;
  final VoidCallback onSelect;

  const _PlanCard({
    required this.index,
    required this.selectedIndex,
    required this.name,
    required this.price,
    required this.color,
    this.badge,
    required this.features,
    required this.lockedFeatures,
    required this.onSelect,
  });

  bool get selected => index == selectedIndex;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelect,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.06) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? color : AppColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  name,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: selected ? color : AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (badge != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      badge!,
                      style: AppTextStyles.labelSmall
                          .copyWith(color: Colors.white),
                    ),
                  ),
                ],
                const Spacer(),
                Text(
                  price == 0 ? 'Gratuit' : '$price FCFA/mois',
                  style: AppTextStyles.titleSmall.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...features.map((f) => _FeatureRow(text: f, available: true)),
            ...lockedFeatures
                .map((f) => _FeatureRow(text: f, available: false)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: selected ? color : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? color : AppColors.border,
                      width: 2,
                    ),
                  ),
                  child: selected
                      ? const Icon(Icons.check_rounded,
                          size: 14, color: Colors.white)
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final String text;
  final bool available;

  const _FeatureRow({required this.text, required this.available});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            available ? Icons.check_circle_rounded : Icons.lock_rounded,
            size: 16,
            color: available ? AppColors.success : AppColors.textLight,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: available
                  ? AppColors.textPrimary
                  : AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }
}
