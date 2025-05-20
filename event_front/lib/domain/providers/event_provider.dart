import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:event_booking_app/data/models/event_model.dart';
import 'package:event_booking_app/data/repositories/event_repository.dart';
import 'package:event_booking_app/domain/providers/auth_provider.dart';

final eventRepositoryProvider = Provider((ref) => EventRepository());

final eventsProvider = FutureProvider<List<EventModel>>((ref) async {
  return await ref.watch(eventRepositoryProvider).getEvents();
});

final eventDetailsProvider = FutureProvider.family<EventModel, String>((ref, id) async {
  return await ref.watch(eventRepositoryProvider).getEventDetails(id);
});

final bookmarkedEventsProvider = FutureProvider<List<EventModel>>((ref) async {
  return await ref.watch(eventRepositoryProvider).getBookmarkedEvents();
});

final userIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.userId;
});