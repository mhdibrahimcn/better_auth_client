import 'package:dio/dio.dart';
import '../../better_auth_client.dart';
import '../../storage/storage_interface.dart';
import '../../utils/constants.dart';

/// Interceptor that automatically attaches Bearer tokens to requests
/// and handles 401 unauthorized responses.
class AuthInterceptor extends Interceptor {
  final StorageInterface _storage;
  final BetterAuthClient _client;

  String? _cachedToken;

  AuthInterceptor({
    required StorageInterface storage,
    required BetterAuthClient client,
  })  : _storage = storage,
        _client = client;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Get token from storage if not cached
    if (_cachedToken == null) {
      _cachedToken = await _storage.read(StorageKeys.accessToken);
    }

    // Attach Bearer token if available
    if (_cachedToken != null) {
      options.headers['Authorization'] = 'Bearer $_cachedToken';
    }

    return handler.next(options);
  }

  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    // Check if a new token was returned
    final newToken = response.data?['token'] ?? response.data?['session']?['token'];
    if (newToken != null && newToken != _cachedToken) {
      _cachedToken = newToken;
      await _storage.write(StorageKeys.accessToken, newToken);
    }
    return handler.next(response);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Handle 401 Unauthorized
    if (err.response?.statusCode == 401) {
      // Clear invalid token
      await _storage.delete(StorageKeys.accessToken);
      _cachedToken = null;
      
      // Notify client to update UI
      _client.sessionNotifier.value = null;
    }
    return handler.next(err);
  }
}
