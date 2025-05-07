import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Api {
  static const String baseUrl =
      'https://02c3-2402-d000-810c-28c2-a80b-92d1-eec8-e7d7.ngrok-free.app';
}

class AuthService {
  static Future<bool> loginUser(String email, String password) async {
    final response = await http.post(
      Uri.parse('${Api.baseUrl}/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      await prefs.setString('role', data['role']);
      return true;
    } else {
      print('Login failed: ${response.body}');
      return false;
    }
  }

  static Future<bool> registerUser(
    String name,
    String email,
    String password,
    String role,
    double lat,
    double lng,
  ) async {
    final response = await http.post(
      Uri.parse('${Api.baseUrl}/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'role': role,
        'location': {'lat': lat, 'lng': lng},
        'profilePic': "", // Optional, if needed
      }),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      print('Registration failed: ${response.body}');
      return false;
    }
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return null;

    final parts = token.split('.');
    if (parts.length != 3) return null;

    final payload = jsonDecode(
      utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
    );
    return payload['_id'] ?? payload['user'] ?? payload['sub'];
  }

  static Future<bool> updateProfile(Map<String, dynamic> data) async {
    final token = await getToken();
    final response = await http.put(
      Uri.parse('${Api.baseUrl}/api/auth/update'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data), // Ensure data includes 'mobileNumber' if needed
    );

    return response.statusCode == 200;
  }

  static Future<void> logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> saveRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('role', role);
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }

  static Future<Map<String, dynamic>?> getProfile() async {
    final token = await getToken();

    final response = await http.get(
      Uri.parse('${Api.baseUrl}/api/auth/me'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Failed to fetch profile: ${response.body}');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getUserById(String userId) async {
    final token = await AuthService.getToken();

    final response = await http.get(
      Uri.parse('${Api.baseUrl}/api/auth/users/$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("Failed to fetch user details: ${response.body}");
      return null;
    }
  }
}
