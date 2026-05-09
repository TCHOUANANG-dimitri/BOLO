import 'package:flutter/foundation.dart';
import '../../data/models/booking_model.dart';
import '../../data/models/provider_model.dart';
import '../../data/repositories/booking_repository.dart';
import '../../data/repositories/mock_data.dart';

class BookingProvider extends ChangeNotifier {
  final BookingRepository _repo = BookingRepository();

  List<BookingModel> _bookings = [];
  bool _isLoading = false;

  List<BookingModel> get bookings => _bookings;
  bool get isLoading => _isLoading;

  List<BookingModel> get upcoming => _bookings
      .where((b) =>
          b.date.isAfter(DateTime.now()) &&
          b.status != BookingStatus.cancelled)
      .toList()
    ..sort((a, b) => a.date.compareTo(b.date));

  List<BookingModel> get past => _bookings
      .where((b) =>
          b.date.isBefore(DateTime.now()) ||
          b.status == BookingStatus.completed ||
          b.status == BookingStatus.cancelled)
      .toList()
    ..sort((a, b) => b.date.compareTo(a.date));

  // ─── Charger ──────────────────────────────────────────────────────────────

  Future<void> loadBookings(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _bookings = await _repo.getUserBookings(userId);
    } catch (_) {
      _bookings = List.from(MockData.bookings);
    }
    _isLoading = false;
    notifyListeners();
  }

  // Écoute en temps réel Firestore
  void watchBookings(String userId) {
    _repo.watchUserBookings(userId).listen((list) {
      _bookings = list;
      notifyListeners();
    });
  }

  // ─── Créer ────────────────────────────────────────────────────────────────

  Future<BookingModel?> createBooking({
    required ProviderModel provider,
    required String userId,
    required DateTime date,
    required String timeSlot,
    required String location,
    String? note,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final booking = await _repo.create(
        provider: provider,
        userId: userId,
        date: date,
        timeSlot: timeSlot,
        location: location,
        note: note,
      );
      _bookings.insert(0, booking);
      _isLoading = false;
      notifyListeners();
      return booking;
    } catch (_) {
      // Fallback local
      final booking = BookingModel(
        id: 'b_${DateTime.now().millisecondsSinceEpoch}',
        providerId: provider.id,
        providerName: provider.name,
        providerSpecialty: provider.specialty,
        providerAvatar: provider.avatarUrl,
        userId: userId,
        date: date,
        timeSlot: timeSlot,
        location: location,
        note: note,
        status: BookingStatus.pending,
        totalPrice: provider.pricePerHour,
        createdAt: DateTime.now(),
      );
      _bookings.insert(0, booking);
      _isLoading = false;
      notifyListeners();
      return booking;
    }
  }

  // ─── Mettre à jour après paiement ────────────────────────────────────────

  Future<void> confirmPayment(
    String bookingId, {
    required String paymentRef,
    required String paymentMethod,
  }) async {
    try {
      await _repo.updatePayment(bookingId,
          paymentRef: paymentRef, paymentMethod: paymentMethod);
    } catch (_) {}
    final idx = _bookings.indexWhere((b) => b.id == bookingId);
    if (idx >= 0) {
      final b = _bookings[idx];
      _bookings[idx] = BookingModel(
        id: b.id,
        providerId: b.providerId,
        providerName: b.providerName,
        providerSpecialty: b.providerSpecialty,
        providerAvatar: b.providerAvatar,
        userId: b.userId,
        date: b.date,
        timeSlot: b.timeSlot,
        location: b.location,
        note: b.note,
        status: BookingStatus.confirmed,
        totalPrice: b.totalPrice,
        createdAt: b.createdAt,
        paymentRef: paymentRef,
        paymentMethod: paymentMethod,
      );
      notifyListeners();
    }
  }

  // ─── Annuler ──────────────────────────────────────────────────────────────

  Future<void> cancelBooking(String bookingId) async {
    try {
      await _repo.cancel(bookingId);
    } catch (_) {}
    final idx = _bookings.indexWhere((b) => b.id == bookingId);
    if (idx >= 0) {
      final b = _bookings[idx];
      _bookings[idx] = BookingModel(
        id: b.id,
        providerId: b.providerId,
        providerName: b.providerName,
        providerSpecialty: b.providerSpecialty,
        providerAvatar: b.providerAvatar,
        userId: b.userId,
        date: b.date,
        timeSlot: b.timeSlot,
        location: b.location,
        note: b.note,
        status: BookingStatus.cancelled,
        totalPrice: b.totalPrice,
        createdAt: b.createdAt,
        paymentRef: b.paymentRef,
        paymentMethod: b.paymentMethod,
      );
      notifyListeners();
    }
  }
}
