class EventModel {
  final String id;
  final String title;
  final String description;
  final DateTime eventDate;
  final String eventTime;
  final LocationModel location;
  final List<String> images;
  final String category;
  final int likes;
  final List<String> usersLiked;
  final OrganizerModel organizer;
  final List<TicketTypeModel> ticketTypes;
  final bool isBookmarked;

  EventModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.eventDate,
    this.eventTime = '',
    required this.location,
    this.images = const [],
    this.category = '',
    this.likes = 0,
    this.usersLiked = const [],
    required this.organizer,
    this.ticketTypes = const [],
    this.isBookmarked = false,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    print('Parsing event JSON: $json');
    try {
      return EventModel(
        id: json['_id'] as String? ?? '',
        title: json['title'] as String? ?? 'Untitled Event',
        description: json['description'] as String? ?? '',
        eventDate: json['eventDate'] != null
            ? DateTime.parse(json['eventDate'] as String)
            : DateTime.now(),
        eventTime: json['eventTime'] as String? ?? '',
        location: json['location'] != null
            ? LocationModel.fromJson(json['location'] as Map<String, dynamic>)
            : LocationModel(name: '', latitude: null, longitude: null),
        images: (json['images'] as List<dynamic>?)?.cast<String>() ?? [],
        category: json['category'] as String? ?? '',
        likes: (json['likes'] as num?)?.toInt() ?? 0,
        usersLiked: (json['usersLiked'] as List<dynamic>?)?.cast<String>() ?? [],
        organizer: json['user'] != null
            ? OrganizerModel.fromJson(json['user'] as Map<String, dynamic>)
            : OrganizerModel(name: '', email: ''),
        ticketTypes: (json['ticketTypes'] as List<dynamic>?)?.map((t) => TicketTypeModel.fromJson(t as Map<String, dynamic>)).toList() ?? [],
        isBookmarked: json['isBookmarked'] as bool? ?? false,
      );
    } catch (e) {
      print('Error parsing EventModel: $e');
      rethrow;
    }
  }
}

class LocationModel {
  final String name;
  final double? latitude;
  final double? longitude;

  LocationModel({required this.name, this.latitude, this.longitude});

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      name: json['name'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }
}

class OrganizerModel {
  final String name;
  final String email;
  final String? avatar;
  final String? organizationName;

  OrganizerModel({
    required this.name,
    required this.email,
    this.avatar,
    this.organizationName,
  });

  factory OrganizerModel.fromJson(Map<String, dynamic> json) {
    return OrganizerModel(
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      avatar: json['avatar'] as String?,
      organizationName: json['organizationName'] as String?,
    );
  }
}

class TicketTypeModel {
  final String name;
  final double price;
  final int available;
  final int limit;

  TicketTypeModel({
    required this.name,
    required this.price,
    required this.available,
    required this.limit,
  });

  factory TicketTypeModel.fromJson(Map<String, dynamic> json) {
    return TicketTypeModel(
      name: json['name'] as String? ?? 'Unnamed Ticket',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      available: (json['available'] as num?)?.toInt() ?? 0,
      limit: (json['limit'] as num?)?.toInt() ?? 0,
    );
  }
}