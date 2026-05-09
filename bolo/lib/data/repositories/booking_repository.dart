import '../models/booking_model.dart';
import '../models/provider_model.dart';
import '../../core/services/local_db_service.dart';
import 'mock_data.dart';

class BookingRepository {
  final LocalDbService _db = LocalDbService();

  Future<BookingModel> create({
    required ProviderModel provider,
    required String userId,
    required DateTime date,
    required String timeSlot,
    required String location,
    String? note,
  }) async {
    final id = 'b_${DateTime.now().millisecondsSinceEpoch}';
    final booking = BookingModel(
      id: id,
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

    await _db.setDoc('bookings', id, booking.toLocal(), merge: false);
    return booking;
  }

  Future<List<BookingModel>> getUserBookings(String userId) async {
    try {
      final docs = await _db.queryDocs(
        'bookings',
        whereField: 'userId',
        whereValue: userId,
        orderBy: 'createdAt',
        descending: true,
      );
      return docs.map(BookingModel.fromLocal).toList();
    } catch (_) {
      return List.from(MockData.bookings);
    }
  }

  Stream<List<BookingModel>> watchUserBookings(String userId) {
    return _db
        .streamDocs('bookings',
            whereField: 'userId',
            whereValue: userId,
            orderBy: 'createdAt',
            descending: true)
        .map((docs) => docs.map(BookingModel.fromLocal).toList());
  }

  Future<void> updateStatus(String bookingId, BookingStatus status) async {
    await _db.updateDoc('bookings', bookingId, {
      'status': status.name,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> updatePayment(
    String bookingId, {
    required String paymentRef,
    required String paymentMethod,
  }) async {
    await _db.updateDoc('bookings', bookingId, {
      'paymentRef': paymentRef,
      'paymentMethod': paymentMethod,
      'status': BookingStatus.confirmed.name,
      'paidAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> cancel(String bookingId) async {
    await updateStatus(bookingId, BookingStatus.cancelled);
  }

  Future<bool> hasCompletedBooking(String userId, String providerId) async {
    try {
      final docs = await _db.queryDocs(
        'bookings',
        where: {
          'userId': userId,
          'providerId': providerId,
          'status': BookingStatus.completed.name,
        },
      );
      return docs.isNotEmpty;
    } catch (_) {
      return true; // mode démo : autoriser les avis
    }
  }
}
