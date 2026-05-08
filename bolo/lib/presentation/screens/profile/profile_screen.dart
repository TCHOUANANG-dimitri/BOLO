import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/provider_avatar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(AppStrings.myProfile, style: AppTextStyles.headlineSmall),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
            onPressed: () => context.push('/edit-profile'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Column(
                children: [
                  Stack(
                    children: [
                      user != null
                          ? ProviderAvatar(
                              name: user.fullName,
                              avatarUrl: user.avatarUrl,
                              size: 90,
                              borderRadius: 22,
                            )
                          : Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: const Icon(Icons.person_rounded,
                                  size: 48, color: AppColors.primary),
                            ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: GestureDetector(
                          onTap: () => context.push('/edit-profile'),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt_rounded,
                                size: 14, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    user?.fullName ?? 'Utilisateur',
                    style: AppTextStyles.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  if (user?.location != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on_rounded,
                            size: 14, color: AppColors.textLight),
                        const SizedBox(width: 4),
                        Text(user!.location!, style: AppTextStyles.caption),
                      ],
                    ),
                  const SizedBox(height: 16),

                  // Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ProfileStat(value: '3', label: 'Réservations'),
                      const _StatDivider(),
                      _ProfileStat(value: '2', label: 'Favoris'),
                      const _StatDivider(),
                      _ProfileStat(value: '4.8', label: 'Note client'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Menu items
            _MenuSection(
              title: 'Mon compte',
              items: [
                _MenuItem(
                  icon: Icons.calendar_today_rounded,
                  label: AppStrings.myBookings,
                  onTap: () => context.push('/bookings'),
                  trailing: '3',
                ),
                _MenuItem(
                  icon: Icons.favorite_rounded,
                  label: AppStrings.myFavorites,
                  onTap: () => context.push('/favorites'),
                  trailing: '${user?.favoriteProviderIds.length ?? 0}',
                ),
              ],
            ),
            const SizedBox(height: 12),

            _MenuSection(
              title: 'Préférences',
              items: [
                _MenuItem(
                  icon: Icons.notifications_outlined,
                  label: AppStrings.notifications,
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.language_rounded,
                  label: AppStrings.language,
                  onTap: () {},
                  trailingWidget: Text(
                    'Français',
                    style: AppTextStyles.caption,
                  ),
                ),
                _MenuItem(
                  icon: Icons.lock_outline_rounded,
                  label: AppStrings.security,
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 12),

            _MenuSection(
              title: 'Support',
              items: [
                _MenuItem(
                  icon: Icons.help_outline_rounded,
                  label: AppStrings.help,
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.star_outline_rounded,
                  label: 'Noter l\'application',
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.share_outlined,
                  label: 'Partager BOLO',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Logout
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: ListTile(
                onTap: () => _showLogoutDialog(context, auth),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                tileColor: AppColors.error.withOpacity(0.08),
                leading: const Icon(Icons.logout_rounded,
                    color: AppColors.error, size: 22),
                title: Text(
                  AppStrings.logout,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Version
            Text('BOLO v1.0.0', style: AppTextStyles.caption),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Se déconnecter'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              auth.logout().then((_) => context.go('/login'));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Déconnecter'),
          ),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String value;
  final String label;

  const _ProfileStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Text(value,
              style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      width: 1,
      color: AppColors.border,
    );
  }
}

class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;

  const _MenuSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
          child: Text(
            title,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: items.map((item) {
              final isLast = items.last == item;
              return Column(
                children: [
                  item,
                  if (!isLast)
                    const Divider(
                        height: 1, indent: 56, color: AppColors.divider),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? trailing;
  final Widget? trailingWidget;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
    this.trailingWidget,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: AppColors.primary),
      ),
      title: Text(label, style: AppTextStyles.titleSmall),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                trailing!,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          if (trailingWidget != null) trailingWidget!,
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right_rounded,
              color: AppColors.textLight, size: 20),
        ],
      ),
    );
  }
}
