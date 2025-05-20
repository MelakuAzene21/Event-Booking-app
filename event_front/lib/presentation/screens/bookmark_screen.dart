import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:event_booking_app/domain/providers/event_provider.dart';
import 'package:event_booking_app/domain/providers/auth_provider.dart';
import 'package:event_booking_app/data/models/event_model.dart';

class BookmarkScreen extends ConsumerWidget {
  final EventModel? temporaryEvent;
  final bool isBookmarkProcessing;

  const BookmarkScreen({
    super.key,
    this.temporaryEvent,
    this.isBookmarkProcessing = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final bookmarkedEventsAsync = ref.watch(bookmarkedEventsProvider);

    if (!authState.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.go('/'),
          ),
          title: const Text('Bookmarked Events'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Please log in to view your bookmarked events.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.push('/login'),
                child: const Text('Log In'),
              ),
            ],
          ),
        ),
      );
    }

    if (isBookmarkProcessing && temporaryEvent == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.go('/'),
          ),
          title: const Text('Bookmarked Events'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Processing your bookmark...',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/'),
        ),
        title: const Text('Bookmarked Events'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: bookmarkedEventsAsync.when(
        data: (events) {
          final List<EventModel> displayEvents = [...events];
          if (temporaryEvent != null) {
            if (!displayEvents.any((e) => e.id == temporaryEvent!.id)) {
              displayEvents.add(temporaryEvent!);
            }
          }

          if (displayEvents.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'No bookmarked events found.',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/'),
                    child: const Text('Explore Events'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(bookmarkedEventsProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: displayEvents.length,
              itemBuilder: (context, index) {
                final event = displayEvents[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: CachedNetworkImage(
                      imageUrl: event.images.isNotEmpty ? event.images[0] : 'https://via.placeholder.com/100x100',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                    ),
                    title: Text(
                      event.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('MMM dd, yyyy').format(event.eventDate),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          event.location.name.isNotEmpty ? event.location.name : 'Location not specified',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.bookmark, color: Colors.blue),
                      onPressed: () async {
                        try {
                          await ref.read(eventRepositoryProvider).toggleBookmark(event.id);
                          ref.invalidate(bookmarkedEventsProvider);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Bookmark removed successfully'),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to remove bookmark: $e'),
                              backgroundColor: Theme.of(context).colorScheme.error,
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        }
                      },
                    ),
                    onTap: () => context.push('/event/${event.id}'),
                  ),
                ).animate().fadeIn(delay: Duration(milliseconds: 100 * index));
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.refresh(bookmarkedEventsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}