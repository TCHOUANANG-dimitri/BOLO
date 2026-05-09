import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/bolo_logo.dart';

class ProviderDashboardScreen extends StatefulWidget {
  const ProviderDashboardScreen({super.key});

  @override
  State<ProviderDashboardScreen> createState() =>
      _ProviderDashboardScreenState();
}

class _ProviderDashboardScreenState extends State<ProviderDashboardScreen> {
  int _selectedTab = 0;

  // Mock state for rates / calendar
  double _hourlyRate = 5000;
  double _dailyRate = 25000;
  final List<bool> _availableDays = [true, true, true, true, true, false, false];
  final List<String> _days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
  String _startTime = '08:00';
  String _endTime = '18:00';

  static const _times = [
    '06:00', '07:00', '08:00', '09:00', '10:00',
    '11:00', '12:00', '13:00', '14:00', '15:00',
    '16:00', '17:00', '18:00', '19:00', '20:00', '21:00',
  ];

  @override
  Widget build(BuildContext context) {
    final userName = context.watch<AuthProvider>().user?.fullName ?? 'Prestataire';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go('/home'),
        ),
        title: const BoloLogo(size: 36),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_rounded, color: AppColors.primary),
            onPressed: () => context.go('/provider-messages'),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.go('/provider-requests'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Greeting banner
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person_rounded,
                      color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Bonjour, $userName',
                          style: AppTextStyles.titleMedium
                              .copyWith(color: Colors.white)),
                      const SizedBox(height: 2),
                      Text('Votre profil est en ligne ✓',
                          style: AppTextStyles.caption
                              .copyWith(color: Colors.white70)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('ACTIF',
                      style: AppTextStyles.labelSmall
                          .copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),

          // Quick stats row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                _StatCard(label: 'Missions', value: '12', icon: Icons.work_rounded),
                const SizedBox(width: 10),
                _StatCard(label: 'Note', value: '4.8★', icon: Icons.star_rounded),
                const SizedBox(width: 10),
                _StatCard(label: 'Revenus', value: '87 500', icon: Icons.payments_rounded, suffix: 'FCFA'),
              ],
            ),
          ),

          // Quick nav row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                _QuickNavButton(
                  icon: Icons.account_balance_wallet_rounded,
                  label: 'Portefeuille',
                  onTap: () => context.go('/provider-wallet'),
                ),
                const SizedBox(width: 10),
                _QuickNavButton(
                  icon: Icons.workspace_premium_rounded,
                  label: 'Fidélisation',
                  onTap: () => context.go('/provider-loyalty'),
                  color: const Color(0xFF7B2FBE),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                _QuickNavButton(
                  icon: Icons.chat_rounded,
                  label: 'Messages clients',
                  onTap: () => context.go('/provider-messages'),
                ),
              ],
            ),
          ),

          // Tabs
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _TabChip(label: 'Tarifs', selected: _selectedTab == 0, onTap: () => setState(() => _selectedTab = 0)),
                const SizedBox(width: 8),
                _TabChip(label: 'Calendrier', selected: _selectedTab == 1, onTap: () => setState(() => _selectedTab = 1)),
                const SizedBox(width: 8),
                _TabChip(label: 'Revenus', selected: _selectedTab == 2, onTap: () => setState(() => _selectedTab = 2)),
              ],
            ),
          ),

          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: [
                _buildRatesTab(),
                _buildCalendarTab(),
                _buildRevenuesTab(),
              ][_selectedTab],
            ),
          ),
        ],
      ),

      // FAB — go to requests
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/provider-requests'),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.inbox_rounded, color: Colors.white),
        label: Text('Demandes',
            style: AppTextStyles.labelMedium.copyWith(color: Colors.white)),
      ),
    );
  }

  // ─── Tab: Tarifs ──────────────────────────────────────────────────────────

  Widget _buildRatesTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Modifier vos tarifs', style: AppTextStyles.titleSmall),
        const SizedBox(height: 16),

        _RateSliderCard(
          label: 'Tarif horaire',
          icon: Icons.schedule_rounded,
          value: _hourlyRate,
          min: 1000,
          max: 50000,
          divisions: 49,
          onChanged: (v) => setState(() => _hourlyRate = v),
        ),
        const SizedBox(height: 14),
        _RateSliderCard(
          label: 'Tarif journalier',
          icon: Icons.today_rounded,
          value: _dailyRate,
          min: 5000,
          max: 200000,
          divisions: 195,
          onChanged: (v) => setState(() => _dailyRate = v),
        ),
        const SizedBox(height: 20),

        // Save button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _saveRates,
            icon: const Icon(Icons.save_rounded),
            label: const Text('Enregistrer les tarifs'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _saveRates() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Tarifs mis à jour : ${_hourlyRate.toInt()} FCFA/h · ${_dailyRate.toInt()} FCFA/j'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ─── Tab: Calendrier ──────────────────────────────────────────────────────

  Widget _buildCalendarTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Jours disponibles', style: AppTextStyles.titleSmall),
        const SizedBox(height: 12),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(7, (i) {
            final selected = _availableDays[i];
            return GestureDetector(
              onTap: () =>
                  setState(() => _availableDays[i] = !_availableDays[i]),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primary
                      : AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: selected ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Text(
                  _days[i],
                  style: AppTextStyles.labelMedium.copyWith(
                    color: selected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: 20),
        Text('Plage horaire', style: AppTextStyles.titleSmall),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _TimeDropdown(
                label: 'De',
                value: _startTime,
                times: _times,
                onChanged: (v) => setState(() => _startTime = v!),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _TimeDropdown(
                label: 'À',
                value: _endTime,
                times: _times,
                onChanged: (v) => setState(() => _endTime = v!),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _saveCalendar,
            icon: const Icon(Icons.calendar_today_rounded),
            label: const Text('Enregistrer le calendrier'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _saveCalendar() {
    final selectedDays = _days
        .asMap()
        .entries
        .where((e) => _availableDays[e.key])
        .map((e) => e.value)
        .join(', ');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calendrier mis à jour : $selectedDays · $_startTime–$_endTime'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ─── Tab: Revenus ─────────────────────────────────────────────────────────

  Widget _buildRevenuesTab() {
    final transactions = [
      _Transaction('Plomberie — Ngoa-Ekelle', 'Il y a 2j', 8500, true),
      _Transaction('Électricité — Bastos', 'Il y a 5j', 15000, true),
      _Transaction('Peinture — Odza', 'Il y a 8j', 25000, true),
      _Transaction('Nettoyage — Mvog-Mbi', 'Il y a 12j', 6000, false),
      _Transaction('Jardinage — Nsimeyong', 'Il y a 15j', 12000, true),
    ];

    final totalEarned = transactions
        .where((t) => t.completed)
        .fold(0, (s, t) => s + t.amount);
    final commission = (totalEarned * 0.15).toInt();
    final net = totalEarned - commission;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary cards
        Row(
          children: [
            Expanded(
              child: _EarningsCard(
                label: 'Total brut',
                amount: totalEarned,
                color: AppColors.primary,
                icon: Icons.trending_up_rounded,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _EarningsCard(
                label: 'Net perçu',
                amount: net,
                color: AppColors.success,
                icon: Icons.account_balance_wallet_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded,
                  size: 16, color: Colors.orange),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Commission BOLO (15%) : ${commission.toString()} FCFA déduits',
                  style: AppTextStyles.caption
                      .copyWith(color: Colors.orange.shade800),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Historique des missions', style: AppTextStyles.titleSmall),
            TextButton(
              onPressed: () => context.go('/provider-wallet'),
              child: const Text('Voir tout'),
            ),
          ],
        ),

        ...transactions.map((t) => _TransactionTile(transaction: t)),
      ],
    );
  }
}

// ─── Sub-widgets ────────────────────────────────────────────────────────────

class _QuickNavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _QuickNavButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(label,
                  style: AppTextStyles.labelMedium
                      .copyWith(color: color, fontWeight: FontWeight.w600)),
              const Spacer(),
              Icon(Icons.arrow_forward_ios_rounded, size: 12, color: color),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final String? suffix;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(height: 4),
            Text(value,
                style: AppTextStyles.titleSmall
                    .copyWith(fontWeight: FontWeight.w800)),
            if (suffix != null)
              Text(suffix!,
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textLight)),
            Text(label,
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TabChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _RateSliderCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  const _RateSliderCard({
    required this.label,
    required this.icon,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(label, style: AppTextStyles.titleSmall),
              const Spacer(),
              Text(
                '${value.toInt()} FCFA',
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.primaryLight,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withOpacity(0.1),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${min.toInt()} FCFA',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textLight)),
              Text('${max.toInt()} FCFA',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textLight)),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimeDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> times;
  final ValueChanged<String?> onChanged;

  const _TimeDropdown({
    required this.label,
    required this.value,
    required this.times,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.textLight)),
          DropdownButton<String>(
            value: value,
            items: times
                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
            onChanged: onChanged,
            isExpanded: true,
            underline: const SizedBox(),
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _EarningsCard extends StatelessWidget {
  final String label;
  final int amount;
  final Color color;
  final IconData icon;

  const _EarningsCard({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text('${amount.toStringAsFixed(0)} FCFA',
              style: AppTextStyles.titleSmall
                  .copyWith(color: color, fontWeight: FontWeight.w800)),
          Text(label,
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _Transaction {
  final String title;
  final String date;
  final int amount;
  final bool completed;
  _Transaction(this.title, this.date, this.amount, this.completed);
}

class _TransactionTile extends StatelessWidget {
  final _Transaction transaction;
  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: transaction.completed
                  ? AppColors.success.withOpacity(0.1)
                  : AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              transaction.completed
                  ? Icons.check_circle_rounded
                  : Icons.cancel_rounded,
              color:
                  transaction.completed ? AppColors.success : AppColors.error,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(transaction.title, style: AppTextStyles.titleSmall),
                Text(transaction.date,
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textLight)),
              ],
            ),
          ),
          Text(
            '${transaction.amount} FCFA',
            style: AppTextStyles.titleSmall.copyWith(
              color: transaction.completed
                  ? AppColors.success
                  : AppColors.textLight,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
