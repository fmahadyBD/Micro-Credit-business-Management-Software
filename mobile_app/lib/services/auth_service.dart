import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = '${dotenv.env['API_BASE_URL']}/auth';

  Future<bool> register(String firstName, String lastName, String email, String password) async {
    final url = Uri.parse("$baseUrl/register");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "firstname": firstName,
        "lastname": lastName,
        "email": email,
        "password": password,
      }),
    );

    return response.statusCode == 202;
  }

  Future<String?> login(String email, String password) async {
    final url = Uri.parse("$baseUrl/authenticate");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['token'];
    } else {
      return null;
    }
  }
}
