import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:event_booking_app/data/models/ticket_model.dart';
import 'package:event_booking_app/domain/providers/ticket_provider.dart';

class TicketCard extends ConsumerWidget {
  final TicketModel ticket;

  const TicketCard({super.key, required this.ticket});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Event: ${ticket.event?.title ?? 'Unknown Event'}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text('Ticket: ${ticket.ticketNumber.isEmpty ? 'N/A' : ticket.ticketNumber}'),
            Text('Status: ${ticket.isUsed ? 'Used' : 'Valid'}'),
            const SizedBox(height: 8),
            QrImageView(
              data: ticket.qrCode.isEmpty ? 'N/A' : ticket.qrCode,
              size: 100,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Ticket'),
                      content: const Text('Are you sure you want to delete this ticket?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Delete', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    await ref.read(ticketProvider.notifier).deleteTicket(ticket.id);
                    ref.invalidate(ticketsProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ticket deleted successfully')),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}