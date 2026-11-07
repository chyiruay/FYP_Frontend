import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherService {
  // Base URL of the Malaysian government open-data API
  final String _baseUrl = 'https://api.data.gov.my/weather';

  /// Fetch the 7-day general weather forecast.
  /// Accepts optional query parameters such as limit or contains.
  Future<dynamic> fetchForecast({Map<String, String>? queryParameters}) async {
    // Build the full URL with query parameters (e.g. ?limit=3 or ?contains=Langkawi@location__location_name)
    var uri = Uri.parse('$_baseUrl/forecast').replace(queryParameters: queryParameters);
    try {
      final response = await http.get(uri);
      print('Forecast Response status: ${response.statusCode}');
      print('Forecast Response body: ${response.body}');
      if (response.statusCode == 200) {
        // Decode the JSON response
        return jsonDecode(response.body);
      } else {
        throw Exception('Weather forecast request failed, status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching weather forecast: $e');
      throw Exception('Failed to load weather forecast, please try again later');
    }
  }

  /// Fetch weather warnings.
  /// Accepts optional query parameters such as limit or timestamp_start.
  Future<dynamic> fetchWarnings({Map<String, String>? queryParameters}) async {
    var uri = Uri.parse('$_baseUrl/warning').replace(queryParameters: queryParameters);
    try {
      final response = await http.get(uri);
      print('Warning Response status: ${response.statusCode}');
      print('Warning Response body: ${response.body}');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Warning request failed, status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching warnings: $e');
      throw Exception('Failed to load warnings, please try again later');
    }
  }

  /// Fetch earthquake warnings.
  /// Also accepts query parameters such as limit.
  Future<dynamic> fetchEarthquakeWarnings({Map<String, String>? queryParameters}) async {
    var uri = Uri.parse('$_baseUrl/warning/earthquake').replace(queryParameters: queryParameters);
    try {
      final response = await http.get(uri);
      print('Earthquake Warning Response status: ${response.statusCode}');
      print('Earthquake Warning Response body: ${response.body}');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Earthquake warning request failed, status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching earthquake warnings: $e');
      throw Exception('Failed to load earthquake warnings, please try again later');
    }
  }
}
