import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/services/api.dart' as app_api;
import 'package:frontend/services/auth_service.dart';

class DonationService {
  // Create a new donation
  static Future<bool> createDonation({
    required String description,
    required String quantity,
    required DateTime expiresAt,
    required String imageUrl,
    required double lat,
    required double lng,
  }) async {
    final token = await AuthService.getToken();

    final response = await http.post(
      Uri.parse('${app_api.Api.baseUrl}/donations/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'description': description,
        'quantity': quantity,
        'expiresAt': expiresAt.toIso8601String(),
        'image': imageUrl,
        'location': {'lat': lat, 'lng': lng},
      }),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      print("Donation failed: ${response.body}");
      return false;
    }
  }

  static Future<List<dynamic>> getAllAvailableDonations() async {
    final token = await AuthService.getToken();

    final response = await http.get(
      Uri.parse('${app_api.Api.baseUrl}/donations/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("Failed to fetch available donations: ${response.body}");
      return [];
    }
  }

  // Fetch donor's own donations
  static Future<List<dynamic>> getMyDonations() async {
    final token = await AuthService.getToken();

    final response = await http.get(
      Uri.parse('${app_api.Api.baseUrl}/donations/my'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data;
    } else {
      print("Failed to fetch donations: ${response.body}");
      return [];
    }
  }

  // Update a donation
  static Future<bool> updateDonation(
    String id,
    Map<String, dynamic> data,
  ) async {
    final token = await AuthService.getToken();

    final response = await http.put(
      Uri.parse('${app_api.Api.baseUrl}/donations/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    return response.statusCode == 200;
  }

  // Delete a donation
  static Future<bool> deleteDonation(String id) async {
    final token = await AuthService.getToken();

    final response = await http.delete(
      Uri.parse('${app_api.Api.baseUrl}/donations/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    return response.statusCode == 200;
  }

  static Future<bool> claimDonation(String donationId) async {
    final token = await AuthService.getToken();

    final response = await http.post(
      Uri.parse('${app_api.Api.baseUrl}/orders'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'donationId': donationId}),
    );

    return response.statusCode == 200;
  }

  static Future<bool> confirmDonationStatus(String donationId) async {
    final token = await AuthService.getToken();

    final response = await http.put(
      Uri.parse('${app_api.Api.baseUrl}/api/donations/confirm/$donationId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print("Failed to confirm donation: ${response.body}");
      return false;
    }
  }
}
