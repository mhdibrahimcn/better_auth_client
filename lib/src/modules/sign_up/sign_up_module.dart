import 'package:dio/dio.dart';
import '../../models/auth_response.dart';
import '../../models/auth_error.dart';
import '../../models/user.dart';
import '../../storage/storage_interface.dart';
import '../../utils/constants.dart';

/// Callbacks for sign-up request lifecycle.
///
/// Use these callbacks to execute code at specific points during the sign-up
/// process.
///
/// Example:
/// ```dart
/// authClient.signUp.email(
///   email: email,
///   password: password,
///   callbacks: SignUpCallbacks(
///     onSuccess: (user) => showWelcome(user),
///     onError: (error) => showError(error.message),
///   ),
/// );
/// ```
class SignUpCallbacks {
  /// Called when the sign-up request starts.
  final void Function()? onRequest;

  /// Called on successful sign-up.
  ///
  /// Provides the newly created [User].
  final void Function(User user)? onSuccess;

  /// Called when sign-up fails.
  ///
  /// Provides the [AuthError] containing error details.
  final void Function(AuthError error)? onError;

  /// Creates a new [SignUpCallbacks] instance.
  SignUpCallbacks({
    this.onRequest,
    this.onSuccess,
    this.onError,
  });
}

/// Module for handling sign-up operations.
///
/// This module provides methods for registering new user accounts.
///
/// Obtain an instance from [BetterAuthClient.signUp]:
/// ```dart
/// final response = await authClient.signUp.email(
///   email: 'user@example.com',
///   password: 'password123',
///   name: 'John Doe',
/// );
/// ```
class SignUpModule {
  final Dio _dio;
  final StorageInterface _storage;

  /// Creates a new [SignUpModule] instance.
  ///
  /// Typically, you won't create this directly. Use [BetterAuthClient.signUp] instead.
  SignUpModule(this._dio, this._storage);

  /// Signs up with email and password.
  ///
  /// [email] The user's email address (required).
  /// [password] The user's password (required).
  /// [name] The user's display name (optional).
  /// [callbacks] Optional lifecycle callbacks.
  ///
  /// Returns an [AuthResponse] containing the new [User] on success.
  ///
  /// Example:
  /// ```dart
  /// final response = await authClient.signUp.email(
  ///   email: 'user@example.com',
  ///   password: 'password123',
  ///   name: 'John Doe',
  /// );
  ///
  /// if (response.isSuccess) {
  ///   print('Account created: ${response.data!.email}');
  /// }
  /// ```
  Future<AuthResponse<User>> email({
    required String email,
    required String password,
    String? name,
    SignUpCallbacks? callbacks,
  }) async {
    callbacks?.onRequest?.call();

    try {
      final response = await _dio.post(
        ApiEndpoints.signUpEmail,
        data: {
          'email': email,
          'password': password,
          if (name != null) 'name': name,
        },
      );

      final user = User.fromJson(response.data['user'] ?? response.data);
      callbacks?.onSuccess?.call(user);

      return AuthResponse.success(user);
    } on DioException catch (e) {
      final error = AuthError.fromDio(e);
      callbacks?.onError?.call(error);
      return AuthResponse.error(error);
    }
  }
}
