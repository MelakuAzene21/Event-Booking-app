import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:event_booking_app/core/config/api_config.dart';
import 'package:event_booking_app/data/models/event_model.dart';
import 'package:event_booking_app/core/utils/secure_storage.dart';

class EventRepository {
  Future<List<EventModel>> getEvents() async {
    final token = await SecureStorage.getToken();
    final Map<String, String> headers = token != null ? {'Authorization': 'Bearer $token'} : {};
    if (kDebugMode) {
      print('Get events headers: $headers');
    }
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.eventsEndpoint}'),
      headers: headers,
    );

    if (kDebugMode) {
      print('Raw response body: ${response.body}');
    }

    if (response.statusCode == 200) {
      final dynamic data = jsonDecode(response.body);
      final List<dynamic> eventList = data is List ? data : data['events'] ?? [];
      if (eventList.isNotEmpty) {
        return eventList.map((json) => EventModel.fromJson(json)).toList();
      } else {
        return [];
      }
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to fetch events');
    }
  }

  Future<EventModel> getEventDetails(String id) async {
    final token = await SecureStorage.getToken();
    final Map<String, String> headers = token != null ? {'Authorization': 'Bearer $token'} : {};
    if (kDebugMode) {
      print('Get event details headers: $headers');
    }
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.eventDetailsEndpoint}/$id'),
      headers: headers,
    );

    if (kDebugMode) {
      print('Raw event details response: ${response.body}');
    }

    if (response.statusCode == 200) {
      return EventModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to fetch event details');
    }
  }

  Future<void> toggleBookmark(String eventId) async {
    final token = await SecureStorage.getToken();
    if (token == null) {
      throw Exception('No authentication token found. Please log in.');
    }

    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
    if (kDebugMode) {
      print('Toggle bookmark headers: $headers');
      print('Toggle bookmark URL: ${ApiConfig.baseUrl}${ApiConfig.toggleBookmarkEndpoint.replaceFirst(':eventId', eventId)}');
    }

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.toggleBookmarkEndpoint.replaceFirst(':eventId', eventId)}'),
      headers: headers,
    );

    if (kDebugMode) {
      print('Toggle bookmark response: ${response.statusCode} - ${response.body}');
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      return;
    } else if (response.statusCode == 401) {
      throw Exception('Authentication failed. Please log in again.');
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to toggle bookmark');
    }
  }

  Future<List<EventModel>> getBookmarkedEvents() async {
    final token = await SecureStorage.getToken();
    if (token == null) {
      throw Exception('No authentication token found. Please log in.');
    }

    final Map<String, String> headers = {'Authorization': 'Bearer $token'};
    if (kDebugMode) {
      print('Get bookmarked events headers: $headers');
    }
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.bookmarkedEventsEndpoint}'),
      headers: headers,
    );

    if (kDebugMode) {
      print('Get bookmarked events response: ${response.statusCode} - ${response.body}');
    }

    if (response.statusCode == 200) {
      final dynamic data = jsonDecode(response.body);
      if (data is List) {
        return data.map((json) => EventModel.fromJson(json)).toList();
      } else if (data is Map && data['events'] != null) {
        return (data['events'] as List).map((json) => EventModel.fromJson(json)).toList();
      } else {
        return [];
      }
    } else {
      final dynamic errorData = jsonDecode(response.body);
      final errorMessage = errorData is Map
          ? errorData['message'] ?? errorData['error'] ?? 'Failed to fetch bookmarked events'
          : errorData.toString();
      if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please log in again.');
      } else if (response.statusCode == 404) {
        return [];
      }
      throw Exception(errorMessage);
    }
  }

  Future<void> toggleLike(String eventId, String userId) async {
    final token = await SecureStorage.getToken();
    if (token == null) {
      throw Exception('No authentication token found. Please log in.');
    }

    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({'userId': userId});

    if (kDebugMode) {
      print('Toggle like headers: $headers');
      print('Toggle like body: $body');
      print('Toggle like URL: ${ApiConfig.baseUrl}${ApiConfig.likeEndpoint}/$eventId');
    }

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.likeEndpoint}/$eventId'),
      headers: headers,
      body: body,
    );

    if (kDebugMode) {
      print('Toggle like response: ${response.statusCode} - ${response.body}');
    }

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 401) {
      throw Exception('Authentication failed. Please log in again.');
    } else if (response.statusCode == 400) {
      throw Exception('User ID is required.');
    } else if (response.statusCode == 404) {
      throw Exception('Event not found.');
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to toggle like.');
    }
  }
}