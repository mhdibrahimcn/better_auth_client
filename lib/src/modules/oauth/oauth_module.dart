import 'package:dio/dio.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import '../../core/token_manager.dart';
import '../../models/auth_response.dart';
import '../../models/auth_error.dart';
import '../../models/session.dart';
import '../../storage/storage_interface.dart';
import '../../utils/constants.dart';

/// Module for handling OAuth authentication.
///
/// This module provides methods for authenticating users through OAuth providers
/// like Google, GitHub, and others.
///
/// Obtain an instance from [BetterAuthClient.oauth]:
/// ```dart
/// final response = await authClient.oauth.signIn(
///   provider: 'google',
///   callbackUrlScheme: 'myapp',
/// );
/// ```
///
/// ## Platform Configuration
///
/// ### iOS
/// Add the following to your `Info.plist`:
/// ```xml
/// <key>CFBundleURLTypes</key>
/// <array>
///   <dict>
///     <key>CFBundleURLSchemes</key>
///     <array>
///       <string>myapp</string>
///     </array>
///   </dict>
/// </array>
/// ```
///
/// ### Android
/// Add the following to your `android/app/src/main/AndroidManifest.xml`:
/// ```xml
/// <intent-filter>
///   <action android:name="android.intent.action.VIEW" />
///   <category android:name="android.intent.category.DEFAULT" />
///   <category android:name="android.intent.category.BROWSABLE" />
///   <data android:scheme="myapp" />
/// </intent-filter>
/// ```
class OAuthModule {
  final Dio _dio;
  final StorageInterface _storage;
  final TokenManager _tokenManager;

  /// Creates a new [OAuthModule] instance.
  ///
  /// Typically, you won't create this directly. Use [BetterAuthClient.oauth] instead.
  OAuthModule(this._dio, this._storage) : _tokenManager = TokenManager(_storage);

  /// Initiates an OAuth sign-in flow.
  ///
  /// This method opens the OAuth provider's authentication page in a browser
  /// or web view, then waits for the callback with the authentication result.
  ///
  /// [provider] The OAuth provider identifier (e.g., 'google', 'github', 'apple').
  /// [callbackUrlScheme] The URL scheme for the OAuth callback URL.
  ///
  /// Returns an [AuthResponse] containing the [Session] on successful authentication.
  ///
  /// Example:
  /// ```dart
  /// final response = await authClient.oauth.signIn(
  ///   provider: 'google',
  ///   callbackUrlScheme: 'myapp',
  /// );
  ///
  /// if (response.isSuccess) {
  ///   print('OAuth sign-in successful: ${response.data!.user.email}');
  /// }
  /// ```
  ///
  /// Note: The server must be configured with the OAuth provider and have
  /// the callback URL registered in its trusted origins.
  Future<AuthResponse<Session>> signIn({
    required String provider,
    required String callbackUrlScheme,
  }) async {
    try {
      // Get the OAuth URL from the server
      final response = await _dio.get(
        '${ApiEndpoints.oauthSignIn}/$provider',
        queryParameters: {
          'callbackUrl': '$callbackUrlScheme://oauth-callback',
        },
      );

      final authUrl = response.data['url'] as String;

      // Open the browser for authentication
      final result = await FlutterWebAuth2.authenticate(
        url: authUrl,
        callbackUrlScheme: callbackUrlScheme,
      );

      // Extract the token from the callback URL
      final token = Uri.parse(result).queryParameters['token'];

      if (token == null) {
        return AuthResponse.error(
          AuthError(
            code: 'OAUTH_ERROR',
            message: 'No token received from OAuth callback',
          ),
        );
      }

      // Complete the sign-in by exchanging the token
      final sessionResponse = await _dio.post(
        ApiEndpoints.oauthCallback,
        data: {'token': token},
      );

      final session = Session.fromJson(sessionResponse.data['session'] ?? sessionResponse.data);
      await _tokenManager.setAccessToken(session.token);

      return AuthResponse.success(session);
    } on DioException catch (e) {
      return AuthResponse.error(AuthError.fromDio(e));
    }
  }
}
