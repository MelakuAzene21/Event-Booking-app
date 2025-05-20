
class ApiConfig {
  static const String baseUrl = 'https://event-booking-app-flutter-1.onrender.com/api';

  static const String eventsEndpoint = '/events/getEvent';
  static const String eventDetailsEndpoint = '/events';
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String logoutEndpoint = '/auth/logout';
  static const String profileEndpoint = '/auth/profile';
  static const String createBookingEndpoint = '/bookings/create-booking';
  static const String userTicketsEndpoint = '/tickets/user';
  static const String deleteTicketEndpoint = '/tickets/delete';
  static const String toggleBookmarkEndpoint = '/bookmarks/event/:eventId/toggle';
  static const String bookmarkedEventsEndpoint = '/bookmarks/bookmarkedEvents';
    static const String likeEndpoint = '/events/userLike';

}