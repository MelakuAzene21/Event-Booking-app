import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:event_booking_app/core/config/api_config.dart';
import 'package:event_booking_app/core/utils/secure_storage.dart';
import 'package:event_booking_app/data/models/booking_model.dart';

class BookingRepository {
  Future<BookingModel> createBooking(BookingModel booking) async {
    final token = await SecureStorage.getToken();
    if (token == null) throw Exception('No token found');
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.createBookingEndpoint}'),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'token=$token',
      },
      body: jsonEncode(booking.toJson()),
    );

    if (response.statusCode == 201) {
      return BookingModel.fromJson(jsonDecode(response.body)['booking']);
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }
}