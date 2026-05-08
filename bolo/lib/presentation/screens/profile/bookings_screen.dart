import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/booking_model.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/provider_avatar.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider>().loadBookings();
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(AppStrings.myBookings, style: AppTextStyles.headlineSmall),
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: AppTextStyles.labelLarge,
          tabs: const [
            Tab(text: 'À venir'),
            Tab(text: 'Passées'),
          ],
        ),
      ),
      body: Consumer<BookingProvider>(
        builder: (context, bookings, _) {
          if (bookings.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          return TabBarView(
            controller: _tabCtrl,
            children: [
              _BookingList(
                bookings: bookings.upcoming,
                emptyMessage: 'Aucune réservation à venir',
              ),
              _BookingList(
                bookings: bookings.past,
                emptyMessage: 'Aucune réservation passée',
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BookingList extends StatelessWidget {
  final List<BookingModel> bookings;
  final String emptyMessage;

  const _BookingList({required this.bookings, required this.emptyMessage});

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_today_rounded,
                size: 64, color: AppColors.textLight.withOpacity(0.4)),
            const SizedBox(height: 16),
            Text(emptyMessage, style: AppTextStyles.titleMedium),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) => _BookingCard(booking: bookings[i]),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final BookingModel booking;

  const _BookingCard({required this.booking});

  Color _statusColor() {
    switch (booking.status) {
      case BookingStatus.pending:
        return AppColors.warning;
      case BookingStatus.confirmed:
        return AppColors.success;
      case BookingStatus.inProgress:
        return AppColors.info;
      case BookingStatus.completed:
        return AppColors.textLight;
      case BookingStatus.cancelled:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ProviderAvatar(
                name: booking.providerName,
                avatarUrl: booking.providerAvatar,
                size: 48,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(booking.providerName, style: AppTextStyles.titleSmall),
                    Text(booking.providerSpecialty, style: AppTextStyles.caption),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor().withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  booking.statusLabel,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: _statusColor(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 12),
          Row(
            children: [
              _InfoChip(
                  icon: Icons.calendar_today_rounded,
                  label: booking.dateLabel),
              const SizedBox(width: 12),
              _InfoChip(
                  icon: Icons.access_time_rounded, label: booking.timeSlot),
            ],
          ),
          const SizedBox(height: 6),
          _InfoChip(
              icon: Icons.location_on_rounded, label: booking.location),
          if (booking.note != null && booking.note!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.notes_rounded,
                    size: 14, color: AppColors.textLight),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(booking.note!,
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${booking.totalPrice} FCFA',
                style: AppTextStyles.price,
              ),
              if (booking.status == BookingStatus.pending ||
                  booking.status == BookingStatus.confirmed)
                TextButton(
                  onPressed: () =>
                      context.read<BookingProvider>().cancelBooking(booking.id),
                  style: TextButton.styleFrom(foregroundColor: AppColors.error),
                  child: const Text('Annuler'),
                ),
              if (booking.status == BookingStatus.completed)
                TextButton(
                  onPressed: () {},
                  child: const Text('Laisser un avis'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.primary),
        const SizedBox(width: 5),
        Text(label, style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        )),
      ],
    );
  }
}
