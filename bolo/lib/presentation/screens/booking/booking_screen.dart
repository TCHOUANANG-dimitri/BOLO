import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/provider_model.dart';
import '../../../data/repositories/mock_data.dart';
import '../../../data/repositories/provider_repository.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/bolo_button.dart';
import '../../widgets/provider_avatar.dart';
import 'payment_screen.dart';

class BookingScreen extends StatefulWidget {
  final String providerId;

  const BookingScreen({super.key, required this.providerId});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _repo = ProviderRepository();
  final _noteCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _missionCtrl = TextEditingController();

  ProviderModel? _provider;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedTime;
  int _selectedDuration = 2;

  @override
  void initState() {
    super.initState();
    _provider = _repo.getById(widget.providerId);
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    _locationCtrl.dispose();
    _missionCtrl.dispose();
    super.dispose();
  }

  int get _totalPrice => (_provider?.pricePerHour ?? 0) * _selectedDuration;

  String _timeAfterHours(String time, int hours) {
    final h = int.parse(time.split(':')[0]) + hours;
    return '${h.toString().padLeft(2, '0')}:00';
  }

  Future<void> _proceedToPayment() async {
    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez choisir un horaire')),
      );
      return;
    }
    if (_locationCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez indiquer le lieu de mission')),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final userId = auth.user?.id ?? 'demo_user';
    final bookingRef = 'BOL-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    // Save booking (pending payment)
    final booking = await context.read<BookingProvider>().createBooking(
      provider: _provider!,
      userId: userId,
      date: _selectedDate,
      timeSlot: '$_selectedTime - ${_timeAfterHours(_selectedTime!, _selectedDuration)}',
      location: _locationCtrl.text.trim(),
      note: _missionCtrl.text.trim().isNotEmpty ? _missionCtrl.text.trim() : null,
    );

    if (!mounted) return;

    // Go to payment
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          amount: _totalPrice,
          providerName: _provider!.name,
          bookingRef: bookingRef,
          bookingId: booking?.id,
        ),
      ),
    );
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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(AppStrings.bookingTitle, style: AppTextStyles.headlineSmall),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Provider summary
            _ProviderSummary(provider: provider),
            const SizedBox(height: 20),

            // Date picker
            Text(AppStrings.selectDate, style: AppTextStyles.headlineSmall),
            const SizedBox(height: 12),
            _DatePicker(
              selected: _selectedDate,
              onChanged: (d) => setState(() {
                _selectedDate = d;
                _selectedTime = null;
              }),
            ),
            const SizedBox(height: 20),

            // Duration
            Text('Durée estimée', style: AppTextStyles.headlineSmall),
            const SizedBox(height: 12),
            Row(
              children: [1, 2, 3, 4, 6, 8].map((h) {
                final active = _selectedDuration == h;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedDuration = h),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: active ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: active ? AppColors.primary : AppColors.border,
                        ),
                      ),
                      child: Text('${h}h',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: active ? Colors.white : AppColors.textSecondary,
                            fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                          ),
                          textAlign: TextAlign.center),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Time slots
            Text(AppStrings.selectTime, style: AppTextStyles.headlineSmall),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, childAspectRatio: 2.2,
                mainAxisSpacing: 8, crossAxisSpacing: 8,
              ),
              itemCount: MockData.timeSlots.length,
              itemBuilder: (context, i) {
                final slot = MockData.timeSlots[i];
                final active = _selectedTime == slot;
                return GestureDetector(
                  onTap: () => setState(() => _selectedTime = slot),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    decoration: BoxDecoration(
                      color: active ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: active ? AppColors.primary : AppColors.border,
                      ),
                    ),
                    child: Center(
                      child: Text(slot,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: active ? Colors.white : AppColors.textSecondary,
                            fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                          )),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // Location (required)
            _SectionLabel(label: 'Lieu de la mission *', icon: Icons.location_on_rounded),
            const SizedBox(height: 8),
            TextField(
              controller: _locationCtrl,
              decoration: InputDecoration(
                hintText: 'Adresse complète (quartier, ville...)',
                hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
                prefixIcon: const Icon(Icons.place_outlined, color: AppColors.textLight),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),

            // Mission details
            _SectionLabel(label: 'Détails de la mission', icon: Icons.description_outlined),
            const SizedBox(height: 8),
            TextField(
              controller: _missionCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Décrivez votre besoin, vos attentes, contraintes particulières...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),

            // Optional note
            _SectionLabel(label: 'Note supplémentaire (optionnel)', icon: Icons.note_outlined),
            const SizedBox(height: 8),
            TextField(
              controller: _noteCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Informations complémentaires...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 24),

            // Price summary
            _PriceSummary(
              pricePerHour: provider.pricePerHour,
              duration: _selectedDuration,
              total: _totalPrice,
            ),
            const SizedBox(height: 24),

            Consumer<BookingProvider>(
              builder: (context, booking, _) => BoloButton(
                onPressed: _proceedToPayment,
                label: 'Passer au paiement',
                isLoading: booking.isLoading,
                icon: Icons.arrow_forward_rounded,
              ),
            ),
            const SizedBox(height: 16),

            // Info
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_rounded, size: 13, color: AppColors.textLight),
                  const SizedBox(width: 5),
                  Text('Paiement sécurisé par BOLO', style: AppTextStyles.caption),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _ProviderSummary extends StatelessWidget {
  final ProviderModel provider;
  const _ProviderSummary({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ProviderAvatar(name: provider.name, avatarUrl: provider.avatarUrl, size: 56),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(provider.name, style: AppTextStyles.titleMedium),
                Text(provider.specialty, style: AppTextStyles.bodySmall),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 13, color: AppColors.textLight),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(provider.location,
                          style: AppTextStyles.caption, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(provider.priceLabel, style: AppTextStyles.price),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final IconData icon;
  const _SectionLabel({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(label, style: AppTextStyles.titleSmall),
      ],
    );
  }
}

class _PriceSummary extends StatelessWidget {
  final int pricePerHour;
  final int duration;
  final int total;

  const _PriceSummary({
    required this.pricePerHour,
    required this.duration,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          _PriceRow(label: 'Tarif horaire', value: '$pricePerHour FCFA/h'),
          const SizedBox(height: 8),
          _PriceRow(label: 'Durée estimée', value: '$duration heure(s)'),
          const Divider(height: 20, color: AppColors.primary),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total estimé', style: AppTextStyles.titleMedium),
              Text('$total FCFA',
                  style: AppTextStyles.price.copyWith(fontSize: 20)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Commission BOLO incluse. Paiement sécurisé après confirmation.',
            style: AppTextStyles.caption.copyWith(color: AppColors.primary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  const _PriceRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        Text(value, style: AppTextStyles.titleSmall),
      ],
    );
  }
}

class _DatePicker extends StatelessWidget {
  final DateTime selected;
  final ValueChanged<DateTime> onChanged;

  const _DatePicker({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final days = List.generate(14, (i) => DateTime.now().add(Duration(days: i + 1)));
    const dayNames = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];

    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final day = days[i];
          final active = selected.year == day.year &&
              selected.month == day.month && selected.day == day.day;
          return GestureDetector(
            onTap: () => onChanged(day),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 58,
              decoration: BoxDecoration(
                color: active ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: active ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(dayNames[day.weekday - 1],
                      style: AppTextStyles.caption.copyWith(
                        color: active ? Colors.white70 : AppColors.textLight)),
                  const SizedBox(height: 4),
                  Text('${day.day}',
                      style: AppTextStyles.titleLarge.copyWith(
                        color: active ? Colors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
