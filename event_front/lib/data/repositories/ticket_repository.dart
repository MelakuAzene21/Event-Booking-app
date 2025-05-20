import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:event_booking_app/core/config/api_config.dart';
import 'package:event_booking_app/core/utils/secure_storage.dart';
import 'package:event_booking_app/data/models/ticket_model.dart';

class TicketRepository {
  Future<List<TicketModel>> getUserTickets() async {
    final token = await SecureStorage.getToken();
    if (token == null) throw Exception('No authentication token found.');

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.userTicketsEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
          'Cookie': 'token=$token',
        },
      ).timeout(const Duration(seconds: 10));

      if (kDebugMode) {
        print('Get tickets response: ${response.statusCode}');
        print('Raw response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (kDebugMode) {
          print('Parsed tickets data: $data');
        }
        return data.map((json) => TicketModel.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        if (kDebugMode) {
          print('No tickets found for this user.');
        }
        return [];
      } else {
        final error = jsonDecode(response.body)['message'] ?? 'Failed to fetch tickets.';
        throw Exception(error);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching tickets: $e');
      }
      throw Exception('Unable to fetch tickets. Please try again.');
    }
  }

  Future<void> deleteTicket(String ticketId) async {
    final token = await SecureStorage.getToken();
    if (token == null) throw Exception('No authentication token found.');

    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.deleteTicketEndpoint}/$ticketId'),
        headers: {
          'Content-Type': 'application/json',
          'Cookie': 'token=$token',
        },
      ).timeout(const Duration(seconds: 10));

      if (kDebugMode) {
        print('Delete ticket response: ${response.statusCode}, ${response.body}');
      }

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body)['message'] ?? 'Failed to delete ticket.';
        throw Exception(error);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting ticket: $e');
      }
      throw Exception('Unable to delete ticket. Please try again.');
    }
  }
}