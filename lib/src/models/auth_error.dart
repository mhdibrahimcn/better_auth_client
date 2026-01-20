import 'package:dio/dio.dart';

/// Represents an authentication error.
///
/// The [AuthError] class contains error information including a machine-readable
/// error code, human-readable message, and optional details.
///
/// ## Error Handling
///
/// ```dart
/// final response = await authClient.signIn.email(
///   email: email,
///   password: password,
/// );
///
/// if (response.isError) {
///   final error = response.error!;
///   print('Code: ${error.code}');
///   print('Message: ${error.message}');
///   if (error.details != null) {
///     print('Details: ${error.details}');
///   }
/// }
/// ```
///
/// See also:
/// - [AuthResponse] for response wrapping
/// - [BetterAuthClient] for error-generating operations
class AuthError {
  /// Error code for programmatic handling.
  ///
  /// Standard codes include:
  /// - `INVALID_CREDENTIALS`: Email or password is incorrect
  /// - `USER_NOT_FOUND`: No account with this email
  /// - `EMAIL_ALREADY_EXISTS`: Account already exists
  /// - `SESSION_EXPIRED`: Session has expired
  /// - `UNAUTHORIZED`: Not authorized to perform action
  /// - `VALIDATION_ERROR`: Validation failed
  final String code;

  /// Human-readable error message.
  final String message;

  /// Additional error details.
  ///
  /// For validation errors, this contains field-specific errors.
  /// May be null if no details are available.
  final Map<String, dynamic>? details;

  /// Creates a new [AuthError] instance.
  ///
  /// The [code] should be a machine-readable identifier.
  /// The [message] should be user-friendly description.
  /// The [details] parameter is optional and can contain additional context.
  AuthError({
    required this.code,
    required this.message,
    this.details,
  });

  /// Creates an [AuthError] from a [DioException].
  ///
  /// This factory extracts error information from Dio HTTP exceptions,
  /// including response body content if available.
  factory AuthError.fromDio(DioException exception) {
    final response = exception.response;
    final data = response?.data as Map<String, dynamic>?;

    if (data != null) {
      return AuthError(
        code: data['code'] as String? ?? _mapStatusToCode(exception.type),
        message:
            data['message'] as String? ?? exception.message ?? 'Unknown error',
        details: data['details'] as Map<String, dynamic>?,
      );
    }

    return AuthError(
      code: _mapStatusToCode(exception.type),
      message: exception.message ?? 'Unknown error',
    );
  }

  /// Maps Dio exception types to error codes.
  static String _mapStatusToCode(DioExceptionType type) {
    switch (type) {
      case DioExceptionType.connectionTimeout:
        return 'CONNECTION_TIMEOUT';
      case DioExceptionType.sendTimeout:
        return 'SEND_TIMEOUT';
      case DioExceptionType.receiveTimeout:
        return 'RECEIVE_TIMEOUT';
      case DioExceptionType.badResponse:
        return 'BAD_RESPONSE';
      case DioExceptionType.cancel:
        return 'CANCELLED';
      default:
        return 'UNKNOWN_ERROR';
    }
  }

  /// Creates a validation error with field-specific details.
  ///
  /// The [errors] map should contain field names as keys and error messages
  /// as values.
  ///
  /// Example:
  /// ```dart
  /// final error = AuthError.validation({
  ///   'email': 'Invalid email format',
  ///   'password': 'Too short',
  /// });
  /// ```
  factory AuthError.validation(Map<String, dynamic> errors) {
    return AuthError(
      code: 'VALIDATION_ERROR',
      message: 'Validation failed',
      details: errors,
    );
  }

  /// Error indicating invalid credentials.
  ///
  /// Returned when email/password authentication fails.
  static AuthError invalidCredentials = AuthError(
    code: 'INVALID_CREDENTIALS',
    message: 'Invalid email or password',
  );

  /// Error indicating user not found.
  ///
  /// Returned when no account exists for the provided email.
  static AuthError userNotFound = AuthError(
    code: 'USER_NOT_FOUND',
    message: 'No account found with this email',
  );

  /// Error indicating email already exists.
  ///
  /// Returned during sign-up when an account with the email already exists.
  static AuthError emailAlreadyExists = AuthError(
    code: 'EMAIL_ALREADY_EXISTS',
    message: 'An account with this email already exists',
  );

  /// Error indicating session has expired.
  ///
  /// Returned when the user's session is no longer valid.
  static AuthError sessionExpired = AuthError(
    code: 'SESSION_EXPIRED',
    message: 'Your session has expired. Please sign in again.',
  );

  /// Error indicating unauthorized access.
  ///
  /// Returned when the user doesn't have permission for the action.
  static AuthError unauthorized = AuthError(
    code: 'UNAUTHORIZED',
    message: 'You are not authorized to perform this action',
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthError && other.code == code;
  }

  @override
  int get hashCode => code.hashCode;
}
