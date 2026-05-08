import 'package:flutter/foundation.dart';
import '../../data/models/booking_model.dart';
import '../../data/models/provider_model.dart';
import '../../data/repositories/mock_data.dart';

class BookingProvider extends ChangeNotifier {
  List<BookingModel> _bookings = [];
  bool _isLoading = false;
  bool _bookingSuccess = false;

  List<BookingModel> get bookings => _bookings;
  bool get isLoading => _isLoading;
  bool get bookingSuccess => _bookingSuccess;

  List<BookingModel> get upcoming => _bookings
      .where((b) =>
          b.date.isAfter(DateTime.now()) &&
          b.status != BookingStatus.cancelled)
      .toList()
    ..sort((a, b) => a.date.compareTo(b.date));

  List<BookingModel> get past => _bookings
      .where((b) =>
          b.date.isBefore(DateTime.now()) ||
          b.status == BookingStatus.completed)
      .toList()
    ..sort((a, b) => b.date.compareTo(a.date));

  Future<void> loadBookings() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 400));
    _bookings = List.from(MockData.bookings);

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createBooking({
    required ProviderModel provider,
    required DateTime date,
    required String timeSlot,
    required String location,
    String? note,
  }) async {
    _isLoading = true;
    _bookingSuccess = false;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    final booking = BookingModel(
      id: 'b_${DateTime.now().millisecondsSinceEpoch}',
      providerId: provider.id,
      providerName: provider.name,
      providerSpecialty: provider.specialty,
      providerAvatar: provider.avatarUrl,
      userId: MockData.currentUser.id,
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
    _bookingSuccess = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));
    _bookingSuccess = false;
    notifyListeners();

    return true;
  }

  Future<void> cancelBooking(String bookingId) async {
    final idx = _bookings.indexWhere((b) => b.id == bookingId);
    if (idx < 0) return;

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
    );
    notifyListeners();
  }
}
