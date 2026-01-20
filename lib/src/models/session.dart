import 'user.dart';

/// Represents an authentication session.
///
/// A [Session] contains information about an authenticated user session,
/// including the associated user, token, and expiration time.
///
/// Example:
/// ```dart
/// final session = Session.fromJson(response.data);
/// print('Session expires: ${session.expiresAt}');
/// print('User: ${session.user.email}');
/// ```
///
/// See also:
/// - [User] for user information within a session
/// - [BetterAuthClient] for session management methods
class Session {
  /// Unique session identifier.
  ///
  /// This ID uniquely identifies this specific session.
  final String id;

  /// The user associated with this session.
  final User user;

  /// The session token.
  ///
  /// This token is used to authenticate requests and should be stored securely.
  final String token;

  /// When the session expires.
  ///
  /// After this time, the session is no longer valid and the user
  /// will need to re-authenticate.
  final DateTime expiresAt;

  /// IP address from which the session was created.
  ///
  /// May be null if not provided by the server.
  final String? ipAddress;

  /// User agent of the device that created the session.
  ///
  /// May be null if not provided by the server.
  final String? userAgent;

  /// Whether this session is from the current device.
  ///
  /// This flag is true for the session that was used to create it.
  final bool isCurrent;

  /// Timestamp when the session was created.
  final DateTime createdAt;

  /// Creates a new [Session] instance.
  ///
  /// All parameters are required except [ipAddress], [userAgent], and [isCurrent].
  Session({
    required this.id,
    required this.user,
    required this.token,
    required this.expiresAt,
    this.ipAddress,
    this.userAgent,
    this.isCurrent = false,
    required this.createdAt,
  });

  /// Creates a [Session] instance from a JSON response.
  ///
  /// The [json] map should contain the keys as defined by the Better Auth API.
  ///
  /// Example:
  /// ```dart
  /// final session = Session.fromJson({
  ///   'id': 'session_123',
  ///   'token': 'abc123',
  ///   'expiresAt': '2024-12-31T23:59:59Z',
  ///   'user': {...},
  /// });
  /// ```
  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token'] as String,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : DateTime.now().add(const Duration(days: 30)),
      ipAddress: json['ipAddress'] as String?,
      userAgent: json['userAgent'] as String?,
      isCurrent: json['isCurrent'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  /// Converts this [Session] to a JSON map.
  ///
  /// The returned map can be serialized to JSON for storage or transmission.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'token': token,
      'expiresAt': expiresAt.toIso8601String(),
      'ipAddress': ipAddress,
      'userAgent': userAgent,
      'isCurrent': isCurrent,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Whether this session has expired.
  ///
  /// Returns true if [expiresAt] is in the past, false otherwise.
  /// Use this to check if re-authentication is needed.
  ///
  /// Example:
  /// ```dart
  /// if (session.isExpired) {
  ///   // Prompt user to re-authenticate
  /// }
  /// ```
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Session && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
