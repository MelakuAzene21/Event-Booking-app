import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:event_booking_app/domain/providers/ticket_provider.dart';
import 'package:event_booking_app/data/models/booking_model.dart';
import 'package:event_booking_app/data/models/ticket_model.dart';
import 'package:event_booking_app/presentation/widgets/ticket_card.dart';

class TicketsScreen extends ConsumerWidget {
  final BookingModel? temporaryBooking;
  final bool isBookingProcessing;

  const TicketsScreen({
    super.key,
    this.temporaryBooking,
    this.isBookingProcessing = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketsAsync = ref.watch(ticketsProvider);

    // Show loading state if a booking is processing and no temporary ticket is available
    if (isBookingProcessing && temporaryBooking == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Tickets'),
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
                'Processing your ticket...',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tickets'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: ticketsAsync.when(
        data: (tickets) {
          // Combine temporary booking with fetched tickets
          final List<TicketModel> displayTickets = [...tickets];
          if (temporaryBooking != null) {
            // Convert BookingModel to TicketModel
            final tempTicket = TicketModel(
              id: temporaryBooking!.id,
              bookingId: temporaryBooking!.id, // Use booking ID as bookingId
              eventId: temporaryBooking!.eventId,
              userId: temporaryBooking!.userId,
              ticketNumber: 'TCK-${temporaryBooking!.id}', // Generate ticket number
              qrCode: 'TCK-${temporaryBooking!.id}-${temporaryBooking!.userId}-${temporaryBooking!.eventId}',
              isUsed: false, // Default to false for new tickets
              ticketType: temporaryBooking!.ticketType,
              ticketCount: temporaryBooking!.ticketCount,
              createdAt: temporaryBooking!.createdAt ?? DateTime.now(),
            );
            // Avoid duplicates
            if (!displayTickets.any((t) => t.id == tempTicket.id)) {
              displayTickets.add(tempTicket);
            }
          }

          if (displayTickets.isEmpty) {
            return Center(
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
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_busy,
                        size: 80,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                      )
                          .animate()
                          .scale(duration: 600.ms, curve: Curves.easeOutBack),
                      const SizedBox(height: 24),
                      Text(
                        'No Tickets Yet!',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      )
                          .animate()
                          .fadeIn(delay: 200.ms, duration: 400.ms),
                      const SizedBox(height: 16),
                      Text(
                        'Your ticket collection is waiting to be filled! Dive into our exciting events and grab your tickets today.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[600],
                              height: 1.5,
                            ),
                      )
                          .animate()
                          .fadeIn(delay: 400.ms, duration: 400.ms),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: () {
                          context.go('/');
                        },
                        icon: const Icon(Icons.explore),
                        label: const Text('Explore Events Now'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          textStyle: const TextStyle(fontSize: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                      )
                          .animate()
                          .slideY(
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
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(ticketsProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: displayTickets.length,
              itemBuilder: (context, index) {
                return TicketCard(ticket: displayTickets[index])
                    .animate()
                    .fadeIn(delay: Duration(milliseconds: index * 100));
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 60,
                  color: Theme.of(context).colorScheme.error.withOpacity(0.7),
                ),
                const SizedBox(height: 16),
                Text(
                  'Oops, Something Went Wrong',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.error,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'We couldn\'t load your tickets. Please try again.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => ref.refresh(ticketsProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}