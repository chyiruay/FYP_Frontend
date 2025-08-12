import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/donation.dart';
import '../models/water_level.dart';
import '../models/shelter.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  //static const String baseUrl = "http://10.0.2.2:8000"; //模拟器
  //static const String baseUrl = "http://192.168.59.89:8000";
  static const String baseUrl = "http://10.170.202.245:8000";


  /// 注册用户
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

  ///登录
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
      // 可以在这里处理 token 或用户数据，例如保存 token
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


  /// 获取用户列表
  static Future<List<User>> fetchUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/api/users/'));

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((e) => User.fromJson(e)).toList();
    } else {
      throw Exception("Fail to get user data");
    }
  }

  /// 获取捐赠信息
  static Future<List<Donation>> fetchDonations() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final response = await http.get(
      Uri.parse('$baseUrl/api/donations/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token', // 添加认证 token
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((e) => Donation.fromJson(e)).toList();
    } else {
      throw Exception("Fail to get donation data: ${response.statusCode}");
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

  static Future<List<WaterLevel>> fetchWaterLevels(String stateCode) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      print('No auth token found - user not logged in');
      throw Exception('Please log in to view water level data');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/water-level/?state=$stateCode'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => WaterLevel.fromJson(e)).toList();
    } else if (response.statusCode == 401) {
      print('Authentication failed - token may be invalid');
      throw Exception('Authentication failed. Please log in again.');
    } else {
      print('Failed to load water level data: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to load water level data');
    }
  }

  static Future<Map<String, String>> fetchStateMap() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      print('No auth token found - user not logged in');
      throw Exception('Please log in to view water level data');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/states/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return {for (var s in data) s['code']: s['name']};
    } else if (response.statusCode == 401) {
      print('Authentication failed - token may be invalid');
      throw Exception('Authentication failed. Please log in again.');
    } else {
      print('Failed to load state list: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to load state list');
    }
  }

  static Future<List<dynamic>> fetchDonationHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      print('No auth token found');
      return [];
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
      print('Failed to load donation history: ${response.statusCode}');
      return [];
    }
  }

  static Future<List<Shelter>> fetchShelters() async {
    final url = Uri.parse('$baseUrl/api/shelters/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Shelter.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load shelters');
    }
  }
}

