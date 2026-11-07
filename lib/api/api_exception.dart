/// Thrown by [ApiService] when a request fails, so screens can tell
/// "the request failed" apart from "the request succeeded with no data".
class ApiException implements Exception {
  final String message;

  /// HTTP status code, or null if the request never got a response.
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}
