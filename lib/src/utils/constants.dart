/// API endpoint constants for Better Auth.
class ApiEndpoints {
  // Base path for all auth endpoints
  static const String basePath = '/api/auth';

  // Sign in endpoints
  static const String signInEmail = '$basePath/sign-in/email';
  static const String signInOtp = '$basePath/sign-in/otp';
  static const String signInPassword = '$basePath/sign-in/password';
  static const String signInAnonymous = '$basePath/sign-in/anonymous';

  // Sign up endpoints
  static const String signUpEmail = '$basePath/sign-up/email';

  // Session endpoints
  static const String getSession = '$basePath/session';
  static const String listSessions = '$basePath/sessions';
  static const String revokeSession = '$basePath/revoke-session';
  static const String revokeOtherSessions = '$basePath/revoke-other-sessions';
  static const String signOut = '$basePath/sign-out';

  // OAuth endpoints
  static const String oauthSignIn = '$basePath/oauth2/sign-in';
  static const String oauthCallback = '$basePath/oauth2/callback';

  // Account endpoints
  static const String deleteAccount = '$basePath/account/delete';
  static const String updateAccount = '$basePath/account/update';
  static const String changePassword = '$basePath/account/change-password';

  // MFA endpoints
  static const String enableMfa = '$basePath/mfa/enable';
  static const String disableMfa = '$basePath/mfa/disable';
  static const String verifyMfa = '$basePath/mfa/verify';
}

/// Storage key constants.
class StorageKeys {
  static const String accessToken = 'better_auth_access_token';
  static const String refreshToken = 'better_auth_refresh_token';
  static const String session = 'better_auth_session';
}
