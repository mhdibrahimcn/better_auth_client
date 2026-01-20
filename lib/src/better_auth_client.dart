import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'config/client_options.dart';
import 'core/dio_client.dart';
import 'core/interceptors/auth_interceptor.dart';
import 'models/auth_error.dart';
import 'models/auth_response.dart';
import 'models/session.dart';
import 'modules/account/account_module.dart';
import 'modules/oauth/oauth_module.dart';
import 'modules/session/session_module.dart';
import 'modules/sign_in/sign_in_module.dart';
import 'modules/sign_up/sign_up_module.dart';
import 'storage/secure_storage_impl.dart';
import 'storage/storage_interface.dart';
import 'utils/constants.dart';

/// The main Better Auth client class for Flutter applications.
///
/// This client provides a type-safe interface to interact with a Better Auth
/// backend, supporting authentication, session management, and OAuth flows.
///
/// ## Basic Usage
///
/// ```dart
/// final authClient = BetterAuthClient(
///   baseUrl: String.fromEnvironment('BETTER_AUTH_URL'),
/// );
///
/// final result = await authClient.signIn.email(
///   email: 'user@example.com',
///   password: 'password123',
/// );
/// ```
///
/// ## Reactive Session Management
///
/// The client provides a [ValueNotifier] for reactive session updates:
///
/// ```dart
/// ValueListenableBuilder<Session?>(
///   valueListenable: authClient.sessionNotifier,
///   builder: (context, session, child) {
///     if (session == null) return LoginPage();
///     return HomePage(session: session);
///   },
/// );
/// ```
///
/// See also:
/// - [Better Auth Documentation](https://www.better-auth.com/docs)
/// - [GitHub Repository](https://github.com/your-org/better_auth_client)
class BetterAuthClient {
  /// The HTTP client used for API requests.
  late final Dio _dio;

  /// Storage interface for persisting tokens and sessions.
  final StorageInterface _storage;

  /// Module for sign-in operations.
  late final SignInModule signIn;

  /// Module for sign-up operations.
  late final SignUpModule signUp;

  /// Module for session management.
  late final SessionModule session;

  /// Module for OAuth operations.
  late final OAuthModule oauth;

  /// Module for account operations.
  late final AccountModule account;

  /// Reactive session state for UI updates.
  final ValueNotifier<Session?> _sessionNotifier;

  /// The base URL for API requests.
  final String baseUrl;

  /// Creates a new BetterAuthClient instance.
  ///
  /// [baseUrl] is the base URL of your Better Auth server (e.g., 'http://localhost:3000').
  /// [storage] is an optional custom storage implementation (defaults to secure storage).
  /// [options] is optional configuration options for the client.
  ///
  /// Example:
  /// ```dart
  /// final authClient = BetterAuthClient(
  ///   baseUrl: 'http://localhost:3000',
  /// );
  /// ```
  BetterAuthClient({
    required this.baseUrl,
    StorageInterface? storage,
    ClientOptions? options,
  })  : _storage = storage ?? SecureStorageImpl(),
        _sessionNotifier = ValueNotifier<Session?>(null) {
    _initializeClient();
  }

  /// Internal constructor for testing purposes.
  ///
  /// This constructor allows injecting custom Dio and Storage instances for testing.
  @visibleForTesting
  BetterAuthClient.internal({
    required Dio dio,
    required this.baseUrl,
    required StorageInterface storage,
  })  : _dio = dio,
        _storage = storage,
        _sessionNotifier = ValueNotifier<Session?>(null) {
    _initializeModules();
  }

  /// Initializes the client by setting up Dio, interceptors, and modules.
  void _initializeClient() {
    _dio = DioClient.create(baseUrl: baseUrl);
    _dio.interceptors.add(
      AuthInterceptor(storage: _storage, client: this),
    );
    _initializeModules();
    _restoreSession();
  }

  /// Initializes all authentication modules.
  void _initializeModules() {
    signIn = SignInModule(_dio, _storage, this);
    signUp = SignUpModule(_dio, _storage);
    session = SessionModule(_dio, _storage);
    oauth = OAuthModule(_dio, _storage);
    account = AccountModule(_dio, _storage);
  }

  /// Restores the session from secure storage on app startup.
  ///
  /// This method is called automatically during initialization to restore
  /// the user's session from previously stored tokens.
  Future<void> _restoreSession() async {
    try {
      final token = await _storage.read(StorageKeys.accessToken);
      if (token != null) {
        final sessionData = await getSession();
        if (sessionData.data != null) {
          _sessionNotifier.value = sessionData.data;
        }
      }
    } catch (e) {
      // Ignore errors when restoring session
    }
  }

  /// Gets the current session synchronously.
  ///
  /// Returns the current session if one exists, or null if not authenticated.
  /// For a fresh session fetch, use [getSession] instead.
  Session? get currentSession => _sessionNotifier.value;

  /// Provides a [ValueNotifier] for reactive session updates.
  ///
  /// Use this with [ValueListenableBuilder] to reactively update your UI
  /// when the session changes.
  ///
  /// Example:
  /// ```dart
  /// ValueListenableBuilder<Session?>(
  ///   valueListenable: authClient.sessionNotifier,
  ///   builder: (context, session, _) {
  ///     return session == null ? LoginPage() : HomePage();
  ///   },
  /// );
  /// ```
  ValueNotifier<Session?> get sessionNotifier => _sessionNotifier;

  /// Fetches the current session from the server.
  ///
  /// Returns an [AuthResponse] containing the session data on success,
  /// or an [AuthError] on failure.
  ///
  /// Example:
  /// ```dart
  /// final response = await authClient.getSession();
  /// if (response.isSuccess) {
  ///   print('Session expires: ${response.data!.expiresAt}');
  /// }
  /// ```
  Future<AuthResponse<Session>> getSession() async {
    try {
      final response = await _dio.get(
        ApiEndpoints.getSession,
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );
      final session =
          Session.fromJson(response.data['session'] ?? response.data);
      _sessionNotifier.value = session;
      return AuthResponse.success(session);
    } on DioException catch (e) {
      final error = AuthError.fromDio(e);
      return AuthResponse.error(error);
    }
  }

  /// Signs out the current user.
  ///
  /// This clears the stored token and updates the session state.
  /// Optionally accepts [fetchOptions] for custom fetch configuration.
  ///
  /// Example:
  /// ```dart
  /// await authClient.signOut();
  /// ```
  Future<AuthResponse<void>> signOut({
    Map<String, String>? fetchOptions,
  }) async {
    try {
      await _dio.post(
        ApiEndpoints.signOut,
        data: fetchOptions,
      );
      await _storage.delete(StorageKeys.accessToken);
      _sessionNotifier.value = null;
      return AuthResponse.success(null);
    } on DioException catch (e) {
      // Clear session even on error
      await _storage.delete(StorageKeys.accessToken);
      _sessionNotifier.value = null;
      return AuthResponse.error(AuthError.fromDio(e));
    }
  }

  /// Disposes of resources used by the client.
  ///
  /// Call this method when the client is no longer needed to clean up
  /// the Dio client and session notifier.
  void dispose() {
    _dio.close();
    _sessionNotifier.dispose();
  }
}
