import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Api {
  static const String baseUrl = 'https://c555-2402-d000-810c-2402-299c-5531-6905-640b.ngrok-free.app'; // Update this!
}

class AuthService {
static Future<bool> loginUser(String email, String password) async {
  final response = await http.post(
    Uri.parse('${Api.baseUrl}/api/auth/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': email,
      'password': password,
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', data['token']);
    await prefs.setString('role', data['role']); // ✅ add this line
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
      'location': {
        'lat': lat,
        'lng': lng,
      },
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

}
