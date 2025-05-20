import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/foundation.dart';
import 'package:event_booking_app/data/models/event_model.dart';
import 'package:event_booking_app/domain/providers/event_provider.dart';
import 'package:event_booking_app/domain/providers/auth_provider.dart';

class EventCard extends ConsumerWidget {
  final EventModel event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final userId = ref.watch(userIdProvider);
    final isLiked = userId != null && event.usersLiked.contains(userId);

    return GestureDetector(
      onTap: () => context.push('/event/${event.id}'),
      child: Hero(
        tag: 'event-${event.id}',
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            height: 260,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: CachedNetworkImage(
                          imageUrl: event.images.isNotEmpty && event.images[0].isNotEmpty && Uri.tryParse(event.images[0])?.hasAbsolutePath == true
                              ? event.images[0]
                              : 'https://via.placeholder.com/300x200',
                          height: 140,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) {
                            if (kDebugMode) {
                              print('Image load error for Event ID: ${event.id}, URL: $url, Error: $error');
                            }
                            return const Icon(Icons.broken_image, size: 50, color: Colors.grey);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${DateFormat('MMM dd, yyyy').format(event.eventDate)} • ${event.location.name}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: Chip(
                              label: Text(
                                event.category,
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () async {
                              if (!authState.isAuthenticated || userId == null) {
                                context.push('/login');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please log in to like events'),
                                    backgroundColor: Colors.orange,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                                return;
                              }
                              try {
                                if (kDebugMode) {
                                  print('Toggling like for event: ${event.id}, user: $userId');
                                }
                                await ref.read(eventRepositoryProvider).toggleLike(event.id, userId);
                                ref.invalidate(eventsProvider);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isLiked ? 'Like removed' : 'Event liked!',
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor: Colors.green,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              } catch (e) {
                                if (kDebugMode) {
                                  print('Error toggling like: $e');
                                }
                                String errorMessage = e.toString();
                                if (errorMessage.contains('Authentication failed')) {
                                  errorMessage = 'Session expired. Please log in again.';
                                  context.push('/login');
                                } else if (errorMessage.contains('Event not found')) {
                                  errorMessage = 'This event is no longer available.';
                                } else if (errorMessage.contains('User ID is required')) {
                                  errorMessage = 'User information is missing. Please log in again.';
                                  context.push('/login');
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to toggle like: $errorMessage'),
                                    backgroundColor: Theme.of(context).colorScheme.error,
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                              }
                            },
                            child: Row(
                              children: [
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  child: Icon(
                                    isLiked ? Icons.favorite : Icons.favorite_border,
                                    key: ValueKey<bool>(isLiked),
                                    color: Colors.red,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${event.likes}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().scale(duration: const Duration(milliseconds: 300));
  }
}