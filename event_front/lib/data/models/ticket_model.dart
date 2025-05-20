import 'package:event_booking_app/data/models/booking_model.dart';
import 'package:event_booking_app/data/models/event_model.dart';
import 'package:event_booking_app/data/models/user_model.dart';

class TicketModel {
  final String id;
  final String bookingId;
  final String eventId;
  final String userId;
  final String ticketNumber;
  final String qrCode;
  final bool isUsed;
  final String ticketType; // Added
  final int ticketCount; // Added
  final DateTime createdAt; // Added
  final EventModel? event;
  final BookingModel? booking;
  final UserModel? user;

  TicketModel({
    required this.id,
    required this.bookingId,
    required this.eventId,
    required this.userId,
    required this.ticketNumber,
    required this.qrCode,
    required this.isUsed,
    required this.ticketType,
    required this.ticketCount,
    required this.createdAt,
    this.event,
    this.booking,
    this.user,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    String safeString(dynamic value, {String defaultValue = ''}) {
      if (value == null) return defaultValue;
      return value.toString();
    }

    String getNestedId(dynamic field, {String defaultValue = ''}) {
      if (field is Map<String, dynamic> && field.containsKey('_id')) {
        return safeString(field['_id'], defaultValue: defaultValue);
      } else if (field is String) {
        return field;
      }
      return defaultValue;
    }

    print('Parsing ticket JSON: $json');
    print('Booking field: ${json['booking']}');
    print('Event field: ${json['event']}');
    print('User field: ${json['user']}');

    return TicketModel(
      id: safeString(json['_id']),
      bookingId: getNestedId(json['booking']),
      eventId: getNestedId(json['event']),
      userId: getNestedId(json['user']),
      ticketNumber: safeString(json['ticketNumber']),
      qrCode: safeString(json['qrCode']),
      isUsed: json['isUsed'] ?? false,
      ticketType: safeString(json['ticketType']), // Added
      ticketCount: json['ticketCount'] is int ? json['ticketCount'] : 1, // Added
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(), // Added
      event: json['event'] is Map<String, dynamic>
          ? EventModel.fromJson(json['event'])
          : null,
      booking: json['booking'] is Map<String, dynamic>
          ? BookingModel.fromJson(json['booking'])
          : null,
      user: json['user'] is Map<String, dynamic>
          ? UserModel.fromJson(json['user'])
          : null,
    );
  }
}