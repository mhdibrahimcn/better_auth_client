import 'package:dio/dio.dart';
import '../../better_auth_client.dart';
import '../../models/auth_response.dart';
import '../../models/auth_error.dart';
import '../../models/session.dart';
import '../../storage/storage_interface.dart';
import '../../utils/constants.dart';

/// Module for handling session management operations.
///
/// This module provides methods for viewing and managing authenticated sessions,
/// including listing all sessions and revoking sessions.
///
/// Obtain an instance from [BetterAuthClient.session]:
/// ```dart
/// final sessions = await authClient.session.list();
/// ```
class SessionModule {
  final Dio _dio;
  final StorageInterface _storage;

  /// Creates a new [SessionModule] instance.
  ///
  /// Typically, you won't create this directly. Use [BetterAuthClient.session] instead.
  SessionModule(this._dio, this._storage);

  /// Gets the current session.
  ///
  /// Returns an [AuthResponse] containing the current [Session].
  ///
  /// Example:
  /// ```dart
  /// final response = await authClient.session.get();
  /// if (response.isSuccess) {
  ///   print('Session expires: ${response.data!.expiresAt}');
  /// }
  /// ```
  Future<AuthResponse<Session>> get() async {
    try {
      final response = await _dio.get(ApiEndpoints.getSession);
      final session = Session.fromJson(response.data['session'] ?? response.data);
      return AuthResponse.success(session);
    } on DioException catch (e) {
      return AuthResponse.error(AuthError.fromDio(e));
    }
  }

  /// Lists all sessions for the current user.
  ///
  /// Returns an [AuthResponse] containing a list of all [Session] objects
  /// associated with the current user account.
  ///
  /// Example:
  /// ```dart
  /// final response = await authClient.session.list();
  /// if (response.isSuccess) {
  ///   for (final session in response.data!) {
  ///     print('Session: ${session.id} (${session.ipAddress})');
  ///   }
  /// }
  /// ```
  Future<AuthResponse<List<Session>>> list() async {
    try {
      final response = await _dio.get(ApiEndpoints.listSessions);
      final sessions = (response.data['sessions'] as List)
          .map((s) => Session.fromJson(s))
          .toList();
      return AuthResponse.success(sessions);
    } on DioException catch (e) {
      return AuthResponse.error(AuthError.fromDio(e));
    }
  }

  /// Revokes a specific session by ID.
  ///
  /// [sessionId] The ID of the session to revoke.
  ///
  /// Returns an [AuthResponse] indicating success or failure.
  ///
  /// Example:
  /// ```dart
  /// await authClient.session.revoke('session_123');
  /// ```
  Future<AuthResponse<void>> revoke(String sessionId) async {
    try {
      await _dio.post(ApiEndpoints.revokeSession, data: {'sessionId': sessionId});
      return AuthResponse.success(null);
    } on DioException catch (e) {
      return AuthResponse.error(AuthError.fromDio(e));
    }
  }

  /// Revokes all sessions except the current one.
  ///
  /// This is useful for signing out of all other devices while keeping
  /// the current session active.
  ///
  /// Returns an [AuthResponse] indicating success or failure.
  ///
  /// Example:
  /// ```dart
  /// await authClient.session.revokeOthers();
  /// ```
  Future<AuthResponse<void>> revokeOthers() async {
    try {
      await _dio.post(ApiEndpoints.revokeOtherSessions);
      return AuthResponse.success(null);
    } on DioException catch (e) {
      return AuthResponse.error(AuthError.fromDio(e));
    }
  }
}
