import 'package:cloud_firestore/cloud_firestore.dart';

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
  final String? paymentRef;
  final String? paymentMethod;

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
    this.paymentRef,
    this.paymentMethod,
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

  // ─── Firestore ────────────────────────────────────────────────────────────

  factory BookingModel.fromFirestore(Map<String, dynamic> data) {
    DateTime parseDate(dynamic v) {
      if (v is Timestamp) return v.toDate();
      if (v is DateTime) return v;
      return DateTime.now();
    }

    BookingStatus parseStatus(String? s) {
      return BookingStatus.values.firstWhere(
        (e) => e.name == s,
        orElse: () => BookingStatus.pending,
      );
    }

    return BookingModel(
      id: data['id'] ?? '',
      providerId: data['providerId'] ?? '',
      providerName: data['providerName'] ?? '',
      providerSpecialty: data['providerSpecialty'] ?? '',
      providerAvatar: data['providerAvatar'],
      userId: data['userId'] ?? '',
      date: parseDate(data['date']),
      timeSlot: data['timeSlot'] ?? '',
      location: data['location'] ?? '',
      note: data['note'],
      status: parseStatus(data['status']),
      totalPrice: (data['totalPrice'] as num?)?.toInt() ?? 0,
      createdAt: parseDate(data['createdAt']),
      paymentRef: data['paymentRef'],
      paymentMethod: data['paymentMethod'],
    );
  }

  Map<String, dynamic> toFirestore() => {
        'id': id,
        'providerId': providerId,
        'providerName': providerName,
        'providerSpecialty': providerSpecialty,
        'providerAvatar': providerAvatar,
        'userId': userId,
        'date': Timestamp.fromDate(date),
        'timeSlot': timeSlot,
        'location': location,
        'note': note,
        'status': status.name,
        'totalPrice': totalPrice,
        'createdAt': Timestamp.fromDate(createdAt),
        'paymentRef': paymentRef,
        'paymentMethod': paymentMethod,
      };
}
