enum BookingStatus { pending, confirmed, inProgress, completed, cancelled }

class BookingModel {
  final String id;
  final String providerId;
  final String providerName;
  final String providerSpecialty;
  final String? providerAvatar;
  final String userId;
  final DateTime date;
  final String timeSlot;
  final String location;
  final String? note;
  final BookingStatus status;
  final int totalPrice;
  final DateTime createdAt;

  const BookingModel({
    required this.id,
    required this.providerId,
    required this.providerName,
    required this.providerSpecialty,
    this.providerAvatar,
    required this.userId,
    required this.date,
    required this.timeSlot,
    required this.location,
    this.note,
    required this.status,
    required this.totalPrice,
    required this.createdAt,
  });

  String get statusLabel {
    switch (status) {
      case BookingStatus.pending:
        return 'En attente';
      case BookingStatus.confirmed:
        return 'Confirmée';
      case BookingStatus.inProgress:
        return 'En cours';
      case BookingStatus.completed:
        return 'Terminée';
      case BookingStatus.cancelled:
        return 'Annulée';
    }
  }

  String get dateLabel {
    const months = [
      'jan', 'fév', 'mar', 'avr', 'mai', 'juin',
      'juil', 'août', 'sep', 'oct', 'nov', 'déc'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
