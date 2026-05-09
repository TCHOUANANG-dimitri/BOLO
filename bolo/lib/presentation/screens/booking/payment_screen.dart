import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/services/payment_service.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/bolo_button.dart';

enum PaymentMethod { mtnMoney, orangeMoney, card }

class PaymentScreen extends StatefulWidget {
  final int amount;
  final String providerName;
  final String bookingRef;
  final String? bookingId; // ID Firestore pour confirmer après paiement

  const PaymentScreen({
    super.key,
    required this.amount,
    required this.providerName,
    required this.bookingRef,
    this.bookingId,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  PaymentMethod _selected = PaymentMethod.mtnMoney;
  final _phoneCtrl = TextEditingController();
  final _cardNumberCtrl = TextEditingController();
  final _cardExpiryCtrl = TextEditingController();
  final _cardCvvCtrl = TextEditingController();

  bool _isProcessing = false;
  String _paymentStatus = '';

  final _paymentService = PaymentService();

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _cardNumberCtrl.dispose();
    _cardExpiryCtrl.dispose();
    _cardCvvCtrl.dispose();
    super.dispose();
  }

  // ─── Lancer le paiement ───────────────────────────────────────────────────

  Future<void> _pay() async {
    // Validation
    if (_selected != PaymentMethod.card) {
      if (_phoneCtrl.text.trim().isEmpty) {
        _snack('Veuillez entrer votre numéro de téléphone');
        return;
      }
    } else {
      if (_cardNumberCtrl.text.trim().length < 16) {
        _snack('Numéro de carte invalide');
        return;
      }
    }

    setState(() {
      _isProcessing = true;
      _paymentStatus = 'Initialisation du paiement...';
    });

    try {
      if (_selected == PaymentMethod.card) {
        // Paiement carte : simulé (intégration Stripe/PayDunya en production)
        await Future.delayed(const Duration(seconds: 2));
        await _onPaymentSuccess(ref: 'CARD_${DateTime.now().millisecondsSinceEpoch}');
        return;
      }

      // Mobile Money via Campay
      setState(() => _paymentStatus = 'Envoi de la demande...');

      final result = await _paymentService.initiatePayment(
        amount: widget.amount,
        phone: _phoneCtrl.text.trim(),
        description:
            'Paiement BOLO - ${widget.providerName} (${widget.bookingRef})',
        externalReference: widget.bookingRef,
      );

      if (result.isDemo) {
        // Mode démo : succès immédiat
        setState(() => _paymentStatus = 'Paiement en cours (démo)...');
        await Future.delayed(const Duration(seconds: 2));
        await _onPaymentSuccess(ref: result.reference);
        return;
      }

      // Afficher le code USSD si disponible
      if (result.ussdCode != null && mounted) {
        setState(() => _paymentStatus =
            'Confirmez sur votre téléphone.\nCode USSD : ${result.ussdCode}');
      } else {
        setState(() =>
            _paymentStatus = 'Confirmez le paiement sur votre téléphone...');
      }

      // Polling du statut
      final status = await _paymentService.pollUntilDone(
        result.reference,
        onUpdate: (s) {
          if (!mounted) return;
          setState(() => _paymentStatus = _statusLabel(s));
        },
      );

      if (!mounted) return;

      if (status.isSuccessful) {
        await _onPaymentSuccess(ref: result.reference);
      } else {
        setState(() {
          _isProcessing = false;
          _paymentStatus = '';
        });
        _snack('Paiement échoué. Veuillez réessayer.',
            isError: true);
      }
    } on PaymentTimeoutException {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _paymentStatus = '';
      });
      _snack('Le délai de confirmation a expiré. Vérifiez votre solde.',
          isError: true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _paymentStatus = '';
      });
      _snack('Erreur de paiement : ${e.toString()}', isError: true);
    }
  }

  Future<void> _onPaymentSuccess({required String ref}) async {
    if (!mounted) return;

    // Mettre à jour le statut de la réservation dans Firestore
    if (widget.bookingId != null) {
      await context.read<BookingProvider>().confirmPayment(
            widget.bookingId!,
            paymentRef: ref,
            paymentMethod: _selected.name,
          );
    }

    setState(() {
      _isProcessing = false;
      _paymentStatus = '';
    });

    _showSuccessSheet(ref: ref);
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'PENDING':
        return 'En attente de confirmation...';
      case 'SUCCESSFUL':
        return 'Paiement réussi !';
      case 'FAILED':
        return 'Paiement échoué';
      default:
        return status;
    }
  }

  void _showSuccessSheet({required String ref}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      isScrollControlled: true,
      builder: (_) => _PaymentSuccessSheet(
        amount: widget.amount,
        method: _selected,
        ref: ref,
        onDone: () {
          Navigator.pop(context);
          context.go('/bookings');
        },
      ),
    );
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? AppColors.error : AppColors.success,
    ));
  }

  // ─── UI ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: _isProcessing ? null : () => context.pop(),
        ),
        title: Text('Paiement sécurisé', style: AppTextStyles.headlineSmall),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                const Icon(Icons.lock_rounded,
                    size: 14, color: AppColors.success),
                const SizedBox(width: 4),
                Text('Sécurisé',
                    style:
                        AppTextStyles.caption.copyWith(color: AppColors.success)),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Récapitulatif
                _SummaryCard(
                  providerName: widget.providerName,
                  amount: widget.amount,
                  ref: widget.bookingRef,
                ),
                const SizedBox(height: 24),

                Text('Mode de paiement', style: AppTextStyles.headlineSmall),
                const SizedBox(height: 14),

                _PaymentTile(
                  method: PaymentMethod.mtnMoney,
                  selected: _selected,
                  label: 'MTN Mobile Money',
                  subtitle: 'Paiement via MTN MoMo',
                  color: const Color(0xFFFFCC00),
                  icon: Icons.phone_android_rounded,
                  onTap: _isProcessing
                      ? null
                      : () => setState(
                          () => _selected = PaymentMethod.mtnMoney),
                ),
                const SizedBox(height: 10),
                _PaymentTile(
                  method: PaymentMethod.orangeMoney,
                  selected: _selected,
                  label: 'Orange Money',
                  subtitle: 'Paiement via Orange Money',
                  color: const Color(0xFFFF6600),
                  icon: Icons.phone_android_rounded,
                  onTap: _isProcessing
                      ? null
                      : () => setState(
                          () => _selected = PaymentMethod.orangeMoney),
                ),
                const SizedBox(height: 10),
                _PaymentTile(
                  method: PaymentMethod.card,
                  selected: _selected,
                  label: 'Carte bancaire',
                  subtitle: 'Visa, Mastercard',
                  color: const Color(0xFF1A56DB),
                  icon: Icons.credit_card_rounded,
                  onTap: _isProcessing
                      ? null
                      : () =>
                          setState(() => _selected = PaymentMethod.card),
                ),
                const SizedBox(height: 24),

                // Formulaire
                if (_selected == PaymentMethod.mtnMoney ||
                    _selected == PaymentMethod.orangeMoney) ...[
                  Text('Numéro de téléphone',
                      style: AppTextStyles.titleSmall),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    enabled: !_isProcessing,
                    decoration: InputDecoration(
                      hintText: _selected == PaymentMethod.mtnMoney
                          ? '670 XXX XXX (MTN)'
                          : '690 XXX XXX (Orange)',
                      prefixIcon: const Icon(Icons.phone_outlined,
                          color: AppColors.textLight),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            size: 16, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Vous recevrez une invitation USSD sur votre téléphone pour confirmer le paiement.',
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Text('Informations de carte',
                      style: AppTextStyles.titleSmall),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _cardNumberCtrl,
                    keyboardType: TextInputType.number,
                    enabled: !_isProcessing,
                    maxLength: 19,
                    decoration: InputDecoration(
                      hintText: '0000 0000 0000 0000',
                      counterText: '',
                      prefixIcon: const Icon(Icons.credit_card_rounded,
                          color: AppColors.textLight),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _cardExpiryCtrl,
                          keyboardType: TextInputType.number,
                          enabled: !_isProcessing,
                          decoration: InputDecoration(
                            hintText: 'MM/AA',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _cardCvvCtrl,
                          keyboardType: TextInputType.number,
                          obscureText: true,
                          enabled: !_isProcessing,
                          maxLength: 3,
                          decoration: InputDecoration(
                            hintText: 'CVV',
                            counterText: '',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            size: 16, color: Color(0xFF1A56DB)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Paiement carte sécurisé SSL. Vos données ne sont jamais stockées.',
                            style: AppTextStyles.caption.copyWith(
                                color: const Color(0xFF1A56DB)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 28),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.verified_user_rounded,
                        size: 14, color: AppColors.textLight),
                    const SizedBox(width: 6),
                    Text('Paiement 100% sécurisé par BOLO',
                        style: AppTextStyles.caption),
                  ],
                ),
                const SizedBox(height: 16),

                BoloButton(
                  onPressed: _isProcessing ? null : _pay,
                  label: 'Payer ${widget.amount} FCFA',
                  isLoading: _isProcessing,
                  icon: Icons.lock_rounded,
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),

          // Overlay de statut pendant le traitement
          if (_isProcessing && _paymentStatus.isNotEmpty)
            Positioned(
              bottom: 100,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(_paymentStatus,
                          style: AppTextStyles.bodyMedium),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Widgets internes ─────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final String providerName;
  final int amount;
  final String ref;

  const _SummaryCard({
    required this.providerName,
    required this.amount,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long_rounded,
                  color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text('Récapitulatif',
                  style: AppTextStyles.titleSmall
                      .copyWith(color: Colors.white70)),
            ],
          ),
          const SizedBox(height: 14),
          _Row('Prestataire', providerName),
          const SizedBox(height: 8),
          _Row('Référence', ref),
          const Divider(color: Colors.white24, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total à payer',
                  style:
                      AppTextStyles.titleMedium.copyWith(color: Colors.white)),
              Text('$amount FCFA',
                  style: AppTextStyles.headlineSmall.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w800)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: AppTextStyles.bodySmall.copyWith(color: Colors.white70)),
        Text(value,
            style: AppTextStyles.titleSmall.copyWith(color: Colors.white)),
      ],
    );
  }
}

class _PaymentTile extends StatelessWidget {
  final PaymentMethod method;
  final PaymentMethod selected;
  final String label;
  final String subtitle;
  final Color color;
  final IconData icon;
  final VoidCallback? onTap;

  const _PaymentTile({
    required this.method,
    required this.selected,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == method;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTextStyles.titleSmall),
                  Text(subtitle, style: AppTextStyles.caption),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color:
                      isSelected ? AppColors.primary : AppColors.border,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded,
                      size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentSuccessSheet extends StatelessWidget {
  final int amount;
  final PaymentMethod method;
  final String ref;
  final VoidCallback onDone;

  const _PaymentSuccessSheet({
    required this.amount,
    required this.method,
    required this.ref,
    required this.onDone,
  });

  String get _methodLabel {
    switch (method) {
      case PaymentMethod.mtnMoney:
        return 'MTN Mobile Money';
      case PaymentMethod.orangeMoney:
        return 'Orange Money';
      case PaymentMethod.card:
        return 'Carte bancaire';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 24, 24, MediaQuery.of(context).padding.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_rounded,
                color: AppColors.success, size: 40),
          ),
          const SizedBox(height: 16),
          Text('Paiement réussi !', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 8),
          Text(
            '$amount FCFA débités via $_methodLabel.',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Réf : $ref',
            style: AppTextStyles.caption.copyWith(color: AppColors.textLight),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Un contrat numérique a été généré et le chat sécurisé est maintenant ouvert.',
            style:
                AppTextStyles.bodySmall.copyWith(color: AppColors.textLight),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: onDone,
              child: const Text('Voir mes réservations'),
            ),
          ),
        ],
      ),
    );
  }
}
