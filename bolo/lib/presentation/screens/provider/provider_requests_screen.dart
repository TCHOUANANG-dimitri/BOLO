import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../widgets/bolo_logo.dart';

enum _RequestStatus { pending, accepted, refused }

class _BookingRequest {
  final String id;
  final String clientName;
  final String? clientAvatar;
  final String service;
  final String location;
  final DateTime date;
  final String timeSlot;
  final int proposedAmount;
  final String? note;
  _RequestStatus status;

  _BookingRequest({
    required this.id,
    required this.clientName,
    this.clientAvatar,
    required this.service,
    required this.location,
    required this.date,
    required this.timeSlot,
    required this.proposedAmount,
    this.note,
    this.status = _RequestStatus.pending,
  });
}

class ProviderRequestsScreen extends StatefulWidget {
  const ProviderRequestsScreen({super.key});

  @override
  State<ProviderRequestsScreen> createState() => _ProviderRequestsScreenState();
}

class _ProviderRequestsScreenState extends State<ProviderRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  final List<_BookingRequest> _requests = [
    _BookingRequest(
      id: '1',
      clientName: 'Alphonse Mbarga',
      service: 'Plomberie',
      location: 'Ngoa-Ekelle, Yaoundé',
      date: DateTime.now().add(const Duration(days: 2)),
      timeSlot: '09:00 - 11:00',
      proposedAmount: 8500,
      note: 'Fuite sous l\'évier de la cuisine. Urgent si possible.',
    ),
    _BookingRequest(
      id: '2',
      clientName: 'Chantal Fouda',
      service: 'Électricité',
      location: 'Bastos, Yaoundé',
      date: DateTime.now().add(const Duration(days: 3)),
      timeSlot: '14:00 - 17:00',
      proposedAmount: 15000,
      note: 'Installation d\'une prise extérieure.',
    ),
    _BookingRequest(
      id: '3',
      clientName: 'Paul Atanga',
      service: 'Peinture',
      location: 'Odza, Yaoundé',
      date: DateTime.now().add(const Duration(days: 5)),
      timeSlot: '08:00 - 18:00',
      proposedAmount: 25000,
      status: _RequestStatus.accepted,
    ),
    _BookingRequest(
      id: '4',
      clientName: 'Solange Kono',
      service: 'Nettoyage',
      location: 'Mvog-Mbi, Yaoundé',
      date: DateTime.now().subtract(const Duration(days: 2)),
      timeSlot: '10:00 - 13:00',
      proposedAmount: 6000,
      status: _RequestStatus.refused,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  List<_BookingRequest> get _pending =>
      _requests.where((r) => r.status == _RequestStatus.pending).toList();
  List<_BookingRequest> get _accepted =>
      _requests.where((r) => r.status == _RequestStatus.accepted).toList();
  List<_BookingRequest> get _refused =>
      _requests.where((r) => r.status == _RequestStatus.refused).toList();

  void _accept(String id) {
    setState(() {
      _requests.firstWhere((r) => r.id == id).status = _RequestStatus.accepted;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Demande acceptée — Le client a été notifié'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _refuse(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Refuser la demande ?'),
        content: const Text(
            'Le client sera notifié et pourra chercher un autre prestataire.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _requests.firstWhere((r) => r.id == id).status =
                    _RequestStatus.refused;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Demande refusée'),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Refuser', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

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
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(text: 'En attente (${_pending.length})'),
            Tab(text: 'Acceptées (${_accepted.length})'),
            Tab(text: 'Refusées (${_refused.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _buildList(_pending, showActions: true),
          _buildList(_accepted, showActions: false),
          _buildList(_refused, showActions: false),
        ],
      ),
    );
  }

  Widget _buildList(List<_BookingRequest> list, {required bool showActions}) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_rounded,
                size: 64, color: AppColors.textLight.withOpacity(0.4)),
            const SizedBox(height: 12),
            Text('Aucune demande ici',
                style: AppTextStyles.titleSmall
                    .copyWith(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) =>
          _RequestCard(request: list[i], showActions: showActions,
              onAccept: () => _accept(list[i].id),
              onRefuse: () => _refuse(list[i].id)),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final _BookingRequest request;
  final bool showActions;
  final VoidCallback onAccept;
  final VoidCallback onRefuse;

  const _RequestCard({
    required this.request,
    required this.showActions,
    required this.onAccept,
    required this.onRefuse,
  });

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Color get _statusColor {
    switch (request.status) {
      case _RequestStatus.accepted:
        return AppColors.success;
      case _RequestStatus.refused:
        return AppColors.error;
      case _RequestStatus.pending:
        return Colors.orange;
    }
  }

  String get _statusLabel {
    switch (request.status) {
      case _RequestStatus.accepted:
        return 'Acceptée';
      case _RequestStatus.refused:
        return 'Refusée';
      case _RequestStatus.pending:
        return 'En attente';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.primaryLight,
                  child: Text(
                    request.clientName.isNotEmpty
                        ? request.clientName[0].toUpperCase()
                        : '?',
                    style: AppTextStyles.titleMedium
                        .copyWith(color: AppColors.primary),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(request.clientName,
                          style: AppTextStyles.titleSmall),
                      Text(request.service,
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.primary)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _statusLabel,
                    style: AppTextStyles.labelSmall
                        .copyWith(color: _statusColor),
                  ),
                ),
              ],
            ),
          ),

          // Details
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                _DetailRow(
                    icon: Icons.calendar_today_rounded,
                    text: _formatDate(request.date)),
                const SizedBox(height: 8),
                _DetailRow(
                    icon: Icons.schedule_rounded, text: request.timeSlot),
                const SizedBox(height: 8),
                _DetailRow(
                    icon: Icons.location_on_rounded, text: request.location),
                const SizedBox(height: 8),
                _DetailRow(
                  icon: Icons.payments_rounded,
                  text: '${request.proposedAmount} FCFA',
                  bold: true,
                ),
                if (request.note != null) ...[
                  const SizedBox(height: 8),
                  _DetailRow(
                      icon: Icons.notes_rounded, text: request.note!),
                ],
              ],
            ),
          ),

          // Actions
          if (showActions)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onRefuse,
                      icon: const Icon(Icons.close_rounded, size: 18),
                      label: const Text('Refuser'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onAccept,
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: const Text('Accepter'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool bold;

  const _DetailRow(
      {required this.icon, required this.text, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color:
                  bold ? AppColors.textPrimary : AppColors.textSecondary,
              fontWeight:
                  bold ? FontWeight.w700 : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}
