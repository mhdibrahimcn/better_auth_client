import 'package:dio/dio.dart';
import '../../better_auth_client.dart';
import '../../core/token_manager.dart';
import '../../models/auth_response.dart';
import '../../models/auth_error.dart';
import '../../models/session.dart';
import '../../storage/storage_interface.dart';
import '../../utils/constants.dart';

/// Callbacks for sign-in request lifecycle.
///
/// Use these callbacks to execute code at specific points during the sign-in
/// process, such as showing loading states or handling navigation.
///
/// Example:
/// ```dart
/// authClient.signIn.email(
///   email: email,
///   password: password,
///   callbacks: SignInCallbacks(
///     onRequest: () => setState(() => _isLoading = true),
///     onSuccess: (session) => navigateToHome(session),
///     onError: (error) => showError(error.message),
///   ),
/// );
/// ```
class SignInCallbacks {
  /// Called when the sign-in request starts.
  final void Function()? onRequest;

  /// Called on successful sign-in.
  ///
  /// Provides the newly created [Session].
  final void Function(Session session)? onSuccess;

  /// Called when sign-in fails.
  ///
  /// Provides the [AuthError] containing error details.
  final void Function(AuthError error)? onError;

  /// Creates a new [SignInCallbacks] instance.
  ///
  /// All parameters are optional and can be omitted if not needed.
  SignInCallbacks({
    this.onRequest,
    this.onSuccess,
    this.onError,
  });
}

/// Module for handling sign-in operations.
///
/// This module provides methods for authenticating users with various methods
/// including email/password, OTP, and anonymous access.
///
/// Obtain an instance from [BetterAuthClient.signIn]:
/// ```dart
/// final response = await authClient.signIn.email(
///   email: 'user@example.com',
///   password: 'password123',
/// );
/// ```
class SignInModule {
  final Dio _dio;
  final StorageInterface _storage;
  final TokenManager _tokenManager;

  /// Creates a new [SignInModule] instance.
  ///
  /// Typically, you won't create this directly. Use [BetterAuthClient.signIn] instead.
  SignInModule(
    this._dio,
    this._storage,
    BetterAuthClient client,
  ) : _tokenManager = TokenManager(_storage);

  /// Signs in with email and password authentication.
  ///
  /// [email] The user's email address.
  /// [password] The user's password.
  /// [callbacks] Optional lifecycle callbacks.
  ///
  /// Returns an [AuthResponse] containing the [Session] on success.
  ///
  /// Example:
  /// ```dart
  /// final response = await authClient.signIn.email(
  ///   email: 'user@example.com',
  ///   password: 'password123',
  /// );
  ///
  /// if (response.isSuccess) {
  ///   print('Welcome, ${response.data!.user.name}');
  /// }
  /// ```
  Future<AuthResponse<Session>> email({
    required String email,
    required String password,
    SignInCallbacks? callbacks,
  }) async {
    callbacks?.onRequest?.call();

    try {
      final response = await _dio.post(
        ApiEndpoints.signInEmail,
        data: {
          'email': email,
          'password': password,
        },
      );

      final session = Session.fromJson(response.data['session'] ?? response.data);
      await _tokenManager.setAccessToken(session.token);
      callbacks?.onSuccess?.call(session);

      return AuthResponse.success(session);
    } on DioException catch (e) {
      final error = AuthError.fromDio(e);
      callbacks?.onError?.call(error);
      return AuthResponse.error(error);
    }
  }

  /// Signs in with a one-time password (OTP).
  ///
  /// [email] The user's email address.
  /// [otp] The one-time password code.
  /// [callbacks] Optional lifecycle callbacks.
  ///
  /// Returns an [AuthResponse] containing the [Session] on success.
  Future<AuthResponse<Session>> otp({
    required String email,
    required String otp,
    SignInCallbacks? callbacks,
  }) async {
    callbacks?.onRequest?.call();

    try {
      final response = await _dio.post(
        ApiEndpoints.signInOtp,
        data: {
          'email': email,
          'otp': otp,
        },
      );

      final session = Session.fromJson(response.data['session'] ?? response.data);
      await _tokenManager.setAccessToken(session.token);
      callbacks?.onSuccess?.call(session);

      return AuthResponse.success(session);
    } on DioException catch (e) {
      final error = AuthError.fromDio(e);
      callbacks?.onError?.call(error);
      return AuthResponse.error(error);
    }
  }

  /// Signs in anonymously (guest user).
  ///
  /// This creates a session without requiring any credentials. Useful for
  /// allowing users to explore an app before signing up.
  ///
  /// [callbacks] Optional lifecycle callbacks.
  ///
  /// Returns an [AuthResponse] containing the [Session] on success.
  Future<AuthResponse<Session>> anonymous({
    SignInCallbacks? callbacks,
  }) async {
    callbacks?.onRequest?.call();

    try {
      final response = await _dio.post(
        ApiEndpoints.signInAnonymous,
      );

      final session = Session.fromJson(response.data['session'] ?? response.data);
      await _tokenManager.setAccessToken(session.token);
      callbacks?.onSuccess?.call(session);

      return AuthResponse.success(session);
    } on DioException catch (e) {
      final error = AuthError.fromDio(e);
      callbacks?.onError?.call(error);
      return AuthResponse.error(error);
    }
  }
}
