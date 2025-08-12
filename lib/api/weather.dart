import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherService {
  // API 基础地址
  final String _baseUrl = 'https://api.data.gov.my/weather';

  /// 获取 7 天一般天气预报数据
  /// 可传入可选参数，例如 limit、contains 等查询条件
  Future<dynamic> fetchForecast({Map<String, String>? queryParameters}) async {
    // 构造完整 URL，并加入查询参数（例如 ?limit=3 或 ?contains=Langkawi@location__location_name）
    var uri = Uri.parse('$_baseUrl/forecast').replace(queryParameters: queryParameters);
    try {
      final response = await http.get(uri);
      print('Forecast Response status: ${response.statusCode}');
      print('Forecast Response body: ${response.body}');
      if (response.statusCode == 200) {
        // 将返回的 JSON 字符串转换为 Dart 对象
        return jsonDecode(response.body);
      } else {
        throw Exception('请求天气预报失败，状态码: ${response.statusCode}');
      }
    } catch (e) {
      print('获取天气预报时出错：$e');
      throw Exception('获取天气预报失败，请稍后再试');
    }
  }

  /// 获取警报信息数据
  /// 可传入可选参数，例如 limit、timestamp_start 等
  Future<dynamic> fetchWarnings({Map<String, String>? queryParameters}) async {
    var uri = Uri.parse('$_baseUrl/warning').replace(queryParameters: queryParameters);
    try {
      final response = await http.get(uri);
      print('Warning Response status: ${response.statusCode}');
      print('Warning Response body: ${response.body}');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('请求警报数据失败，状态码: ${response.statusCode}');
      }
    } catch (e) {
      print('获取警报信息时出错：$e');
      throw Exception('获取警报信息失败，请稍后再试');
    }
  }

  /// 获取地震警报数据
  /// 同样支持查询参数，例如 limit 等
  Future<dynamic> fetchEarthquakeWarnings({Map<String, String>? queryParameters}) async {
    var uri = Uri.parse('$_baseUrl/warning/earthquake').replace(queryParameters: queryParameters);
    try {
      final response = await http.get(uri);
      print('Earthquake Warning Response status: ${response.statusCode}');
      print('Earthquake Warning Response body: ${response.body}');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('请求地震警报数据失败，状态码: ${response.statusCode}');
      }
    } catch (e) {
      print('获取地震警报信息时出错：$e');
      throw Exception('获取地震警报信息失败，请稍后再试');
    }
  }
}
