import 'package:dio/dio.dart';

/// Creates and configures the Dio HTTP client for API requests.
class DioClient {
  /// Creates a new Dio instance with the specified base URL.
  ///
  /// The client is configured with:
  /// - JSON content type and response type
  /// - 30 second timeouts for connect, receive, and send operations
  /// - Logging interceptor for debugging
  static Dio create({required String baseUrl}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        contentType: 'application/json',
        responseType: ResponseType.json,
      ),
    );

    // Add logging interceptor for debug mode
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );

    return dio;
  }
}
