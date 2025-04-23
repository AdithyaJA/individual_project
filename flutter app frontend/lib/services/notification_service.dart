import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'api.dart' as app_api;

class NotificationService {
  static Future<List<dynamic>> getNotifications() async {
    final token = await AuthService.getToken();

    final response = await http.get(
      Uri.parse('${app_api.Api.baseUrl}/api/notifications'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("Failed to fetch notifications: ${response.body}");
      return [];
    }
  }

  static Future<bool> createNotification({
    required String userId,
    required String message,
    String type = 'info', // optional: can be 'info', 'alert', 'donation'
  }) async {
    final token = await AuthService.getToken();

    final response = await http.post(
      Uri.parse('${app_api.Api.baseUrl}/notifications'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'user': userId, 'message': message, 'type': type}),
    );

    if (response.statusCode == 201) {
      print("✅ Notification created!");
      return true;
    } else {
      print("❌ Failed to create notification: ${response.body}");
      return false;
    }
  }

  static Future<bool> markAsRead(String notificationId) async {
    final token = await AuthService.getToken();

    final response = await http.put(
      Uri.parse(
        '${app_api.Api.baseUrl}/api/notifications/$notificationId/read',
      ),
      headers: {'Authorization': 'Bearer $token'},
    );

    return response.statusCode == 200;
  }

  static Future<bool> deleteNotification(String notificationId) async {
    final token = await AuthService.getToken();

    final response = await http.delete(
      Uri.parse('${app_api.Api.baseUrl}/api/notifications/$notificationId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    return response.statusCode == 200;
  }

  static Future<List<dynamic>> getMyNotifications() async {
    final token = await AuthService.getToken(); // ✅ fixed here
    final response = await http.get(
      Uri.parse('${app_api.Api.baseUrl}/notifications/my'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("Failed to fetch notifications: ${response.body}");
      return [];
    }
  }

  static Future<bool> clearAllNotifications() async {
    final token = await AuthService.getToken(); // ✅ uses AuthService
    final response = await http.delete(
      Uri.parse('${app_api.Api.baseUrl}/notifications/clear'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return response.statusCode == 200;
  }
}
