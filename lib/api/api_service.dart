import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/donation.dart';
import '../models/water_level.dart';
import '../models/shelter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_exception.dart';

class ApiService {
  // Set at build time so the source doesn't change per network:
  //   flutter run --dart-define=API_BASE_URL=http://<backend-host>:8000
  // Android emulator: http://10.0.2.2:8000 (the host machine).
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.0.9:8000',
  );

  /// Register a new user.
  static Future<bool> registerUser(String username, String email,
      String password, String gender) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/register/'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "email": email,
        "gender": gender,
        "password": password,
      }),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }

  /// Log in and cache the token and profile in SharedPreferences.
  static Future<bool> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/api/login/');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      String token = data['token'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', data['token']);
      await prefs.setString('username', data['username']);
      await prefs.setString('email', data['email'] ?? '');
      await prefs.setString('gender', data['gender'] ?? '');
      await prefs.setString('phone_number', data['phone_number'] ?? '');
      await prefs.setString('full_address', data['full_address'] ?? '');
      await prefs.setBool('is_employee', data['is_employee'] ?? false);


      print('Login success: ${data['token']}');

      return true;
    } else {
      print(
          'Login failed. Code: ${response.statusCode}, body: ${response.body}');
      return false;
    }
  }

  static Future<bool> updateUserProfile(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';

    final url = Uri.parse('$baseUrl/api/update_profile/');

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Failed to update profile: ${response.body}');
      return false;
    }
  }

  static Future<bool> changePassword(String oldPassword, String newPassword) async {
    final url = Uri.parse('$baseUrl/api/change_password/');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
      body: jsonEncode({
        'old_password': oldPassword,
        'new_password': newPassword,
      }),
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      // Optional: print error message for debugging
      print('Password change failed: ${response.statusCode}');
      print('Response body: ${response.body}');
      return false;
    }
  }


  /// Fetch all users (admin only).
  static Future<List<User>> fetchUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/api/users/'));

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((e) => User.fromJson(e)).toList();
    } else {
      throw ApiException("Failed to load users", statusCode: response.statusCode);
    }
  }

  /// Fetch donation items.
  static Future<List<Donation>> fetchDonations() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final response = await http.get(
      Uri.parse('$baseUrl/api/donations/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((e) => Donation.fromJson(e)).toList();
    } else {
      throw ApiException("Failed to load donations", statusCode: response.statusCode);
    }
  }

  static Future<bool> submitDonationRecord({
    required int donationId,
    required int quantity,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      print("No auth token found");
      return false;
    }

    final url = Uri.parse('$baseUrl/api/donation-records/');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
      body: jsonEncode({
        'donation': donationId,
        'quantity': quantity,
      }),
    );

    if (response.statusCode == 201) {
      print("Donation record submitted");
      return true;
    } else {
      print("Failed to submit donation record: ${response.statusCode}");
      print("Response body: ${response.body}");
      return false;
    }
  }

  /// Public endpoint: no token is sent, so it works logged out. (Sending an
  /// invalid or stale token would make the backend reject it with 401.)
  static Future<List<WaterLevel>> fetchWaterLevels(String stateCode) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/water-level/?state=$stateCode'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => WaterLevel.fromJson(e)).toList();
    } else {
      print('Failed to load water level data: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw ApiException('Failed to load water level data', statusCode: response.statusCode);
    }
  }

  /// Public endpoint, no token sent (see [fetchWaterLevels]).
  static Future<Map<String, String>> fetchStateMap() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/states/'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return {for (var s in data) s['code']: s['name']};
    } else {
      print('Failed to load state list: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw ApiException('Failed to load state list', statusCode: response.statusCode);
    }
  }

  static Future<List<dynamic>> fetchDonationHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      throw const ApiException('Please log in to view your donation history');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/donation-history/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw ApiException('Failed to load donation history',
          statusCode: response.statusCode);
    }
  }

  static Future<List<Shelter>> fetchShelters() async {
    final url = Uri.parse('$baseUrl/api/shelters/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Shelter.fromJson(item)).toList();
    } else {
      throw ApiException('Failed to load shelters', statusCode: response.statusCode);
    }
  }
}

