class BookingModel {
  final String id;
  final String eventId;
  final String userId;
  final String ticketType;
  final int ticketCount;
  final double totalAmount;

  BookingModel({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.ticketType,
    required this.ticketCount,
    required this.totalAmount,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    String safeString(dynamic value, {String defaultValue = ''}) {
      return value?.toString() ?? defaultValue;
    }

    return BookingModel(
      id: safeString(json['_id']),
      eventId: safeString(json['event']),
      userId: safeString(json['user']),
      ticketType: safeString(json['ticketType'], defaultValue: 'Unknown'),
      ticketCount: json['ticketCount'] as int? ?? 0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  //get createdAt => null;

  Map<String, dynamic> toJson() {
    return {
      'event': eventId,
      'ticketType': ticketType,
      'ticketCount': ticketCount,
      'totalAmount': totalAmount,
    };
  }
}