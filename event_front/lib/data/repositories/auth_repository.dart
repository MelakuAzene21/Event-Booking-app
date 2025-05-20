import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:event_booking_app/core/config/api_config.dart';
import 'package:event_booking_app/core/utils/secure_storage.dart';
import 'package:event_booking_app/data/models/user_model.dart';

class AuthRepository {
  Future<UserModel> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.loginEndpoint}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = response.headers['set-cookie']?.split(';').first.split('=')[1];
      if (token != null) await SecureStorage.saveToken(token);
      return UserModel.fromJson(data['user']);
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  Future<UserModel> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.registerEndpoint}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    if (response.statusCode == 201) {
      return UserModel.fromJson(jsonDecode(response.body)['user']);
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  Future<void> logout() async {
    final token = await SecureStorage.getToken();
    if (token == null) throw Exception('No token found');
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.logoutEndpoint}'),
      headers: {'Cookie': 'token=$token'},
    );

    if (response.statusCode == 200) {
      await SecureStorage.deleteToken();
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  Future<UserModel> getProfile() async {
    final token = await SecureStorage.getToken();
    if (token == null) throw Exception('No token found');
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.profileEndpoint}'),
      headers: {'Cookie': 'token=$token'},
    );

    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }
}