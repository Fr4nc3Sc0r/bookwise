import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/user.dart';
import 'auth_manager.dart';

class AuthService {
  static const String baseUrl = String.fromEnvironment('BASE_URL');
  static const String apiKey = String.fromEnvironment('API_KEY');

  static Map<String, String> get headers => {
    'X-API-Key': apiKey,
    'Content-Type': 'application/json',
  };

  //registrazione
  Future<User> register(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: headers,
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      final error = jsonDecode(response.body)['detail'];
      throw Exception(error);
    }
  }

  //login
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: headers,
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      final error = jsonDecode(response.body)['detail'];
      throw Exception(error);
    }
  }

  //me function

  Future<User> getMe() async {
    final token = await AuthManager.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: {
        'X-API-Key': apiKey,
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Errore nel recupero profilo');
    }
  }
}
