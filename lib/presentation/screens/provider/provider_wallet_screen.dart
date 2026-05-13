import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../widgets/bolo_button.dart';
import '../../widgets/bolo_logo.dart';

class ProviderWalletScreen extends StatefulWidget {
  const ProviderWalletScreen({super.key});

  @override
  State<ProviderWalletScreen> createState() => _ProviderWalletScreenState();
}

class _ProviderWalletScreenState extends State<ProviderWalletScreen> {
  bool _isWithdrawing = false;
  final _phoneCtrl = TextEditingController(text: '+237 6XX XXX XXX');

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _withdraw() async {
    final balance = 66750;
    if (balance == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solde insuffisant pour un retrait'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _isWithdrawing = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _isWithdrawing = false);
    _showWithdrawSuccess(balance);
  }

  void _showWithdrawSuccess(int amount) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded,
                  color: AppColors.success, size: 40),
            ),
            const SizedBox(height: 16),
            Text('Retrait initié !',
                style: AppTextStyles.titleMedium,
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              '$amount FCFA seront transférés sur votre compte Mobile Money dans 24-72h.',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('OK'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final walletBalance = 66750;
    final pendingBalance = 15000;
    final totalEarned = 153250;

    final history = [
      _WalletEntry('Mission plomberie — Alphonse M.', 'Il y a 1j', 8500, true, '15%: -1275'),
      _WalletEntry('Mission peinture — Paul A.', 'Il y a 3j', 25000, true, '15%: -3750'),
      _WalletEntry('Mission électricité — Chantal F.', 'Il y a 5j', 15000, true, '15%: -2250'),
      _WalletEntry('Retrait Mobile Money', 'Il y a 8j', -50000, false, null),
      _WalletEntry('Mission jardinage — Solange K.', 'Il y a 10j', 12000, true, '15%: -1800'),
      _WalletEntry('Mission nettoyage — Martin B.', 'Il y a 14j', 6000, true, '15%: -900'),
    ];

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
            // Main wallet card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.account_balance_wallet_rounded,
                          color: Colors.white70, size: 20),
                      const SizedBox(width: 8),
                      Text('Portefeuille BOLO',
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: Colors.white70)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${walletBalance.toStringAsFixed(0)} FCFA',
                    style: AppTextStyles.displayLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 36,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('Solde disponible',
                      style: AppTextStyles.caption
                          .copyWith(color: Colors.white60)),
                  const SizedBox(height: 16),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.pending_rounded,
                            color: Colors.white70, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          '$pendingBalance FCFA en attente',
                          style: AppTextStyles.caption
                              .copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Stats row
            Row(
              children: [
                _MiniStatCard(
                  label: 'Total gagné',
                  value: '$totalEarned FCFA',
                  icon: Icons.trending_up_rounded,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 10),
                _MiniStatCard(
                  label: 'Commissions',
                  value: '${(totalEarned * 0.15).toInt()} FCFA',
                  icon: Icons.percent_rounded,
                  color: Colors.orange,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Withdraw section
            Text('Retirer des fonds', style: AppTextStyles.titleSmall),
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
                  // Mobile money method
                  Row(
                    children: [
                      _MobileMoneyOption(
                        label: 'MTN MoMo',
                        color: const Color(0xFFFFCC00),
                        selected: true,
                        onTap: () {},
                      ),
                      const SizedBox(width: 10),
                      _MobileMoneyOption(
                        label: 'Orange Money',
                        color: const Color(0xFFFF6600),
                        selected: false,
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Numéro Mobile Money',
                      prefixIcon: const Icon(Icons.phone_rounded),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  BoloButton(
                    onPressed: _withdraw,
                    label: 'Retirer ${walletBalance.toStringAsFixed(0)} FCFA',
                    isLoading: _isWithdrawing,
                    icon: Icons.send_rounded,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Transfert sous 24–72h. Commission BOLO déjà déduite.',
                    style:
                        AppTextStyles.caption.copyWith(color: AppColors.textLight),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Text('Historique des transactions', style: AppTextStyles.titleSmall),
            const SizedBox(height: 12),

            ...history.map((e) => _HistoryTile(entry: e)),
          ],
        ),
      ),
    );
  }
}

class _WalletEntry {
  final String title;
  final String date;
  final int amount;
  final bool isIncome;
  final String? commissionNote;
  _WalletEntry(this.title, this.date, this.amount, this.isIncome,
      this.commissionNote);
}

class _HistoryTile extends StatelessWidget {
  final _WalletEntry entry;
  const _HistoryTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final isNegative = entry.amount < 0;
    final color = isNegative ? AppColors.error : AppColors.success;

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
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isNegative
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.title, style: AppTextStyles.bodySmall),
                Row(
                  children: [
                    Text(entry.date,
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.textLight)),
                    if (entry.commissionNote != null) ...[
                      const SizedBox(width: 6),
                      Text('· ${entry.commissionNote}',
                          style: AppTextStyles.caption
                              .copyWith(color: Colors.orange)),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Text(
            '${isNegative ? '' : '+'}${entry.amount} FCFA',
            style: AppTextStyles.titleSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MiniStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value,
                      style: AppTextStyles.bodySmall
                          .copyWith(fontWeight: FontWeight.w700, color: color)),
                  Text(label,
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileMoneyOption extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _MobileMoneyOption({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? color.withOpacity(0.12) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? color : AppColors.border,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.phone_android_rounded,
                    color: Colors.white, size: 18),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: selected ? color : AppColors.textSecondary,
                  fontWeight:
                      selected ? FontWeight.w700 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
