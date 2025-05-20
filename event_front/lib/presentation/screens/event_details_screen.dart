import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:event_booking_app/domain/providers/event_provider.dart';
import 'package:event_booking_app/domain/providers/auth_provider.dart';

class EventDetailsScreen extends ConsumerWidget {
  final String eventId;

  const EventDetailsScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(eventDetailsProvider(eventId));
    final authState = ref.watch(authProvider);
    final userId = ref.watch(userIdProvider);

    return Scaffold(
      body: eventAsync.when(
        data: (event) {
          final isLiked = userId != null && event.usersLiked.contains(userId);
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                floating: false,
                pinned: true,
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    event.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: 'event-${event.id}',
                        child: CachedNetworkImage(
                          imageUrl: event.images.isNotEmpty ? event.images[0] : 'https://via.placeholder.com/300x200',
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[300],
                            child: const Center(child: CircularProgressIndicator()),
                          ),
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                        ),
                      ),
                      Positioned(
                        top: 40,
                        right: 16,
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                if (!authState.isAuthenticated  userId == null) {
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
                                  await ref.read(eventRepositoryProvider).toggleLike(event.id, userId);
                                  ref.invalidate(eventDetailsProvider(eventId));
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
                              child: CircleAvatar(
                                backgroundColor: Colors.black54,
                                radius: 20,
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  child: Icon(
                                    isLiked ? Icons.favorite : Icons.favorite_border,
                                    key: ValueKey<bool>(isLiked),
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () async {
                                if (!authState.isAuthenticated) {
                                  context.push('/login');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Please log in to bookmark events'),
                                      backgroundColor: Colors.orange,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                  return;
                                }
                                try {
                                  await ref.read(eventRepositoryProvider).toggleBookmark(event.id);
                                  ref.invalidate(eventDetailsProvider(eventId));
                                  ref.invalidate(bookmarkedEventsProvider);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        event.isBookmarked ? 'Bookmark removed successfully' : 'Event bookmarked successfully',
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                      backgroundColor: Colors.green,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                  
                                } catch (e) {
                                  String errorMessage = e.toString();
                                  if (errorMessage.contains('Authentication failed')) {
                                    errorMessage = 'Session expired. Please log in again.';
                                    context.push('/login');
                                  }
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Failed to toggle bookmark: $errorMessage'),
                                      backgroundColor: Theme.of(context).colorScheme.error,
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                }
                              },
                              child: CircleAvatar(
                                backgroundColor: Colors.black54,
                                radius: 20,
                                child: Icon(
                                  event.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.favorite, color: Colors.red),
                              const SizedBox(width: 4),
                              Text('${event.likes} Likes'),
                            ],
                          ),
                          Chip(
                            label: Text(event.category),
                            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                          ),
                        ],
                      ).animate().fadeIn(),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 20),
                          const SizedBox(width: 8),
                          Text(DateFormat('MMM dd, yyyy').format(event.eventDate),
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ).animate().fadeIn(delay: const Duration(milliseconds: 100)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            event.eventTime,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ).animate().fadeIn(delay: const Duration(milliseconds: 200)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              event.location.name.isNotEmpty ? event.location.name : 'Location not specified',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: const Duration(milliseconds: 300)),
                      if (event.location.latitude != null && event.location.longitude != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 32.0),
                          child: Text(
                            'Lat: ${event.location.latitude}, Lon: ${event.location.longitude}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ).animate().fadeIn(delay: const Duration(milliseconds: 400)),
                      const SizedBox(height: 16),
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.titleLarge,
                      ).animate().fadeIn(delay: const Duration(milliseconds: 500)),
                      const SizedBox(height: 8),
                      Text(
                        event.description.isNotEmpty ? event.description : 'No description available',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ).animate().fadeIn(delay: const Duration(milliseconds: 600)),
                      const SizedBox(height: 16),
                      Text(
                        'Organizer',
                        style: Theme.of(context).textTheme.titleLarge,
                      ).animate().fadeIn(delay: const Duration(milliseconds: 700)),
                      const SizedBox(height: 8),
                      ListTile(
                        leading: CircleAvatar(
                          backgroundImage: event.organizer.avatar != null
                              ? NetworkImage(event.organizer.avatar!)
                              : null,
                          child: event.organizer.avatar == null
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        title: Text(event.organizer.name),
                        subtitle: Text(event.organizer.email),
                      ).animate().fadeIn(delay: const Duration(milliseconds: 800)),
                      if (event.organizer.organizationName != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            'Organization: ${event.organizer.organizationName}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ).animate().fadeIn(delay: const Duration(milliseconds: 900)),
                        const SizedBox(height: 16),
                      Text(
                        'Tickets',
                        style: Theme.of(context).textTheme.titleLarge,
                      ).animate().fadeIn(delay: const Duration(milliseconds: 1000)),
                      const SizedBox(height: 8),
                      ...event.ticketTypes.map((ticket) => Card(
                            child: ListTile(
                              title: Text(ticket.name.isNotEmpty ? ticket.name : 'Unnamed Ticket'),
                              subtitle: Text(
                                'Price: \$${ticket.price.toStringAsFixed(2)} | Available: ${ticket.available} / ${ticket.limit}',
                              ),
                            ),
                          ).animate().fadeIn(delay: const Duration(milliseconds: 1100))),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 300,
              floating: false,
              pinned: true,
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              flexibleSpace: FlexibleSpaceBar(
                title: Container(
                  width: 150,
                  height: 20,
                  color: Colors.grey[300],
                ),
                background: Container(
                  color: Colors.grey[300],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 80,
                          height: 20,
                          color: Colors.grey[300],
                        ),
                        Container(
                          width: 60,
                          height: 20,
                          color: Colors.grey[300],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 100,
                          height: 16,
                          color: Colors.grey[300],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 80,
                          height: 16,
                          color: Colors.grey[300],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 120,
                          height: 16,
                          color: Colors.grey[300],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: 100,
                      height: 24,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      height: 40,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: 100,
                      height: 24,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[300],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 100,
                              height: 16,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: 80,
                              height: 12,
                              color: Colors.grey[300],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: 100,
                      height: 24,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      height: 60,
                      color: Colors.grey[300],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ).animate().shimmer(duration: const Duration(milliseconds: 1000), color: Colors.grey[100]),
        error: (error, _) {
          bool isNetworkError = error is SocketException  error.toString().contains('Failed host lookup')  error.toString().contains('Network');
          bool isNotFound = error.toString().contains('404')  error.toString().contains('Event not found');
          if (isNetworkError) {
            return SliverToBoxAdapter(
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        Theme.of(context).colorScheme.background,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.wifi_off,
                        size: 80,
                        color: Theme.of(context).colorScheme.error.withOpacity(0.7),
                      ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                      const SizedBox(height: 24),
                      Text(
                        'No Internet Connection',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.error,
                            ),
                      ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                      const SizedBox(height: 16),
                      Text(
                        'Please check your internet connection and try again.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[600],
                              height: 1.5,
                            ),
                      ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: () => ref.refresh(eventDetailsProvider(eventId)),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try Again'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                      ).animate().slideY(
                            begin: 0.2,
                            end: 0,
                            delay: 600.ms,
                            duration: 400.ms,
                            curve: Curves.easeOut,
                          ),
                    ],
                  ),
                ),
              ),
            );
          } else if (isNotFound) {
            return SliverToBoxAdapter(
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        Theme.of(context).colorScheme.background,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_busy,
                        size: 80,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                        ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                      const SizedBox(height: 24),
                      Text(
                        'Event Not Found',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                      const SizedBox(height: 16),
                      Text(
                        'No details are available for this event. It may have been removed or does not exist.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[600],
                              height: 1.5,
                            ),
                      ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: () => context.go('/home'),
                        icon: const Icon(Icons.home),
                        label: const Text('Back to Home'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                      ).animate().slideY(
                            begin: 0.2,
                            end: 0,
                            delay: 600.ms,
                            duration: 400.ms,
                            curve: Curves.easeOut,
                          ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return SliverToBoxAdapter(
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        Theme.of(context).colorScheme.background,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 80,
                        color: Theme.of(context).colorScheme.error.withOpacity(0.7),
                      ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                      const SizedBox(height: 24),
                      Text(
                        'Oops, Something Went Wrong',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.error,
                            ),
                      ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                      const SizedBox(height: 16),
                      Text(
                        'We couldn\'t load the event details. Please try again later.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[600],
                              height: 1.5,
                            ),
                            ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: () => ref.refresh(eventDetailsProvider(eventId)),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try Again'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                      ).animate().slideY(
                            begin: 0.2,
                            end: 0,
                            delay: 600.ms,
                            duration: 400.ms,
                            curve: Curves.easeOut,
                          ),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
      floatingActionButton: eventAsync.when(
        data: (event) => FloatingActionButton.extended(
          onPressed: () {
            if (authState.isAuthenticated) {
              context.push('/booking/${event.id}');
            } else {
              context.push('/login');
            }
          },
          label: const Text('Book Now'),
          icon: const Icon(Icons.event),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
        ).animate().fadeIn(delay: const Duration(milliseconds: 1200)),
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}