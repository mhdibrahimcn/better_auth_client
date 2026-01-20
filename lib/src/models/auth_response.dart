import 'auth_error.dart';

/// A generic wrapper for authentication responses.
///
/// The [AuthResponse] class provides a unified way to handle both successful
/// responses and errors, eliminating the need for exceptions in normal flow.
///
/// ## Usage
///
/// ```dart
/// final response = await authClient.signIn.email(
///   email: 'user@example.com',
///   password: 'password123',
/// );
///
/// if (response.isSuccess) {
///   final session = response.data!;
///   print('Signed in: ${session.user.email}');
/// } else {
///   print('Error: ${response.error!.message}');
/// }
/// ```
///
/// See also:
/// - [AuthError] for error details
/// - [Session] for successful session data
/// - [User] for successful user data
class AuthResponse<T> {
  /// The data returned from the request.
  ///
  /// This is null if the request resulted in an error.
  final T? data;

  /// Error if the request failed.
  ///
  /// This is null if the request was successful.
  final AuthError? error;

  /// Whether the request was successful.
  ///
  /// Returns true when [error] is null.
  bool get isSuccess => error == null;

  /// Whether the request failed.
  ///
  /// Returns true when [error] is not null.
  bool get isError => error != null;

  /// Creates a successful response.
  ///
  /// The [data] parameter contains the successful response data.
  AuthResponse.success(this.data) : error = null;

  /// Creates an error response.
  ///
  /// The [error] parameter contains the error details.
  AuthResponse.error(this.error) : data = null;

  /// Unwraps the data, throwing if there's an error.
  ///
  /// Throws the [AuthError] if the response contains an error.
  /// Use this when you want to propagate errors as exceptions.
  ///
  /// Example:
  /// ```dart
  /// final session = await authClient.getSession().then((r) => r.getOrThrow());
  /// ```
  T getOrThrow() {
    if (error != null) {
      throw error!;
    }
    return data!;
  }

  /// Unwraps the data, returning null if there's an error.
  ///
  /// Safe way to access data that might not exist.
  ///
  /// Example:
  /// ```dart
  /// final session = response.getOrNull();
  /// if (session != null) {
  ///   print('Session: ${session.id}');
  /// }
  /// ```
  T? getOrNull() => data;

  /// Unwraps the data, returning the default value if there's an error.
  ///
  /// [defaultValue] is returned when the response contains an error.
  ///
  /// Example:
  /// ```dart
  /// final session = response.getOrDefault(defaultSession);
  /// ```
  T? getOrDefault(T defaultValue) => data ?? defaultValue;
}
