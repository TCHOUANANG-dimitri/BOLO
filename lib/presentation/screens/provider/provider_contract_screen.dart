import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/bolo_button.dart';
import '../../widgets/bolo_logo.dart';

class ProviderContractScreen extends StatefulWidget {
  const ProviderContractScreen({super.key});

  @override
  State<ProviderContractScreen> createState() =>
      _ProviderContractScreenState();
}

class _ProviderContractScreenState extends State<ProviderContractScreen> {
  bool _hasReadContract = false;
  bool _accepted = false;
  bool _isSigning = false;
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.offset >=
          _scrollCtrl.position.maxScrollExtent - 50) {
        if (!_hasReadContract) setState(() => _hasReadContract = true);
      }
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _signWithOtp() async {
    if (!_accepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vous devez accepter les conditions pour continuer'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSigning = true);
    final auth = context.read<AuthProvider>();
    final phone = auth.user?.phone ?? '';
    if (phone.isNotEmpty) {
      await auth.sendOtp(phone);
    }
    if (!mounted) return;
    setState(() => _isSigning = false);

    // Naviguer vers OTP avec destination = provider-profile-setup
    final encoded = Uri.encodeComponent(phone.isNotEmpty ? phone : '237600000000');
    context.go('/otp/$encoded?dest=/provider-dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const BoloLogo(size: 36),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Header
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.description_rounded,
                    color: AppColors.primary, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Contrat prestataire BOLO',
                          style: AppTextStyles.titleMedium
                              .copyWith(color: AppColors.primary)),
                      Text(
                        'Lisez le contrat jusqu\'en bas pour activer la signature.',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Contrat
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: SingleChildScrollView(
                controller: _scrollCtrl,
                padding: const EdgeInsets.all(20),
                child: _ContractText(),
              ),
            ),
          ),

          // Indicateur de lecture
          if (!_hasReadContract)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.keyboard_arrow_down_rounded,
                      color: AppColors.primary, size: 18),
                  Text(
                    'Faites défiler pour lire le contrat entier',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.primary),
                  ),
                ],
              ),
            ),

          // Acceptation + signature
          Padding(
            padding: EdgeInsets.fromLTRB(
                16, 8, 16, MediaQuery.of(context).padding.bottom + 16),
            child: Column(
              children: [
                // Checkbox
                GestureDetector(
                  onTap: _hasReadContract
                      ? () => setState(() => _accepted = !_accepted)
                      : null,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _accepted
                          ? AppColors.primaryLight
                          : AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _accepted
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _accepted
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked_rounded,
                          color: _accepted
                              ? AppColors.primary
                              : AppColors.textLight,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'J\'ai lu et j\'accepte les Conditions Générales d\'Utilisation et le Contrat Prestataire BOLO.',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: _hasReadContract
                                  ? AppColors.textPrimary
                                  : AppColors.textLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                BoloButton(
                  onPressed: _accepted ? _signWithOtp : null,
                  label: 'Signer via OTP SMS',
                  isLoading: _isSigning,
                  icon: Icons.draw_rounded,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContractText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Title('CONTRAT DE PRESTATION DE SERVICES — BOLO'),
        _Body('Date : ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}'),
        const SizedBox(height: 16),

        _Heading('1. OBJET DU CONTRAT'),
        _Body('Le présent contrat régit les relations entre BOLO (ci-après "la Plateforme") et le prestataire de services indépendant (ci-après "le Prestataire") souhaitant proposer ses services via la plateforme BOLO.'),

        _Heading('2. ENGAGEMENT DU PRESTATAIRE'),
        _Body('Le Prestataire s\'engage à :\n• Fournir des services de qualité professionnelle\n• Respecter les horaires convenus avec les clients\n• Maintenir son profil à jour\n• Traiter les clients avec respect et professionnalisme\n• Ne pas exercer d\'activité concurrente via BOLO pendant 12 mois après résiliation'),

        _Heading('3. COMMISSION BOLO'),
        _Body('BOLO prélève une commission de 15% sur chaque transaction réalisée via la plateforme. Le paiement net est versé au Prestataire dans un délai de 24 à 72 heures après validation de la mission par le client.'),

        _Heading('4. VÉRIFICATION D\'IDENTITÉ'),
        _Body('Le Prestataire accepte la vérification de son identité par BOLO. Le badge "Profil vérifié" est accordé après validation de la CNI, du selfie et du casier judiciaire. BOLO se réserve le droit de retirer ce badge en cas de non-conformité.'),

        _Heading('5. RESPONSABILITÉS'),
        _Body('Le Prestataire est responsable :\n• De la qualité de ses prestations\n• De sa propre assurance professionnelle\n• Du respect des lois en vigueur dans son pays\n• Des conséquences de ses actes durant les missions'),

        _Heading('6. RÉSILIATION'),
        _Body('BOLO peut résilier ce contrat à tout moment en cas de :\n• Comportement frauduleux\n• Plaintes répétées de clients\n• Non-respect des présentes conditions\n• Inactivité de plus de 6 mois'),

        _Heading('7. PROTECTION DES DONNÉES'),
        _Body('Les données du Prestataire sont traitées conformément au RGPD et aux lois camerounaises sur la protection des données personnelles. Elles ne sont jamais vendues à des tiers.'),

        _Heading('8. FIDÉLISATION ET AVANTAGES'),
        _Body('BOLO propose des abonnements Premium offrant :\n• Boost de visibilité dans les résultats de recherche\n• Badges spéciaux (Top Prestataire, Coup de cœur, etc.)\n• Classement dans les premières positions\n• Accès aux statistiques avancées de votre profil'),

        _Heading('9. ACCEPTATION'),
        _Body('En validant ce contrat par OTP SMS, le Prestataire reconnaît avoir lu et accepté l\'intégralité des présentes conditions. Cette validation constitue une signature électronique ayant valeur légale conformément aux lois sur la signature numérique.'),

        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '✓ Fin du contrat — Vous pouvez maintenant accepter et signer.',
            style: AppTextStyles.labelSmall
                .copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class _Title extends StatelessWidget {
  final String text;
  const _Title(this.text);
  @override
  Widget build(BuildContext context) => Text(
      text,
      style: AppTextStyles.titleMedium.copyWith(
        fontWeight: FontWeight.w800,
        color: AppColors.primary,
      ),
    );
}

class _Heading extends StatelessWidget {
  final String text;
  const _Heading(this.text);
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 6),
      child: Text(text,
          style: AppTextStyles.titleSmall
              .copyWith(fontWeight: FontWeight.w700)),
    );
}

class _Body extends StatelessWidget {
  final String text;
  const _Body(this.text);
  @override
  Widget build(BuildContext context) => Text(
      text,
      style: AppTextStyles.bodySmall
          .copyWith(color: AppColors.textSecondary, height: 1.6),
    );
}
