import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:event_booking_app/data/models/booking_model.dart';
import 'package:event_booking_app/data/repositories/booking_repository.dart';

final bookingRepositoryProvider = Provider((ref) => BookingRepository());

final bookingProvider = StateNotifierProvider<BookingNotifier, BookingState>((ref) {
  return BookingNotifier(ref.watch(bookingRepositoryProvider));
});

class BookingState {
  final BookingModel? booking;
  final String? error;

  BookingState({this.booking, this.error});

  BookingState copyWith({BookingModel? booking, String? error}) {
    return BookingState(
      booking: booking ?? this.booking,
      error: error,
    );
  }
}

class BookingNotifier extends StateNotifier<BookingState> {
  final BookingRepository _bookingRepository;

  BookingNotifier(this._bookingRepository) : super(BookingState());

  Future<void> createBooking(BookingModel booking) async {
    try {
      final newBooking = await _bookingRepository.createBooking(booking);
      state = state.copyWith(booking: newBooking, error: null);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}