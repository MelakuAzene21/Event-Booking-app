import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:event_booking_app/data/models/ticket_model.dart';
import 'package:event_booking_app/data/repositories/ticket_repository.dart';

final ticketRepositoryProvider = Provider((ref) => TicketRepository());

final ticketsProvider = FutureProvider<List<TicketModel>>((ref) async {
  try {
    final tickets = await ref.watch(ticketRepositoryProvider).getUserTickets();
    if (tickets.isEmpty && kDebugMode) {
      print('Tickets provider: No tickets available for this user.');
    }
    return tickets;
  } catch (e) {
    if (kDebugMode) {
      print('Tickets provider error: $e');
    }
    throw Exception('Failed to load tickets. Please try again later.');
  }
});

final ticketProvider = StateNotifierProvider<TicketNotifier, TicketState>((ref) {
  return TicketNotifier(ref.watch(ticketRepositoryProvider));
});

class TicketState {
  final String? error;

  TicketState({this.error});

  TicketState copyWith({String? error}) {
    return TicketState(error: error);
  }
}

class TicketNotifier extends StateNotifier<TicketState> {
  final TicketRepository _ticketRepository;

  TicketNotifier(this._ticketRepository) : super(TicketState());

  Future<void> deleteTicket(String ticketId) async {
    try {
      await _ticketRepository.deleteTicket(ticketId);
      state = state.copyWith(error: null);
    } catch (e) {
      if (kDebugMode) {
        print('Ticket notifier error deleting ticket: $e');
      }
      state = state.copyWith(error: 'Failed to delete ticket. Please try again.');
    }
  }
}