# Better Auth Flutter Client

[![Pub Version](https://img.shields.io/pub/v/better_auth_flutter_client)](https://pub.dev/packages/better_auth_flutter_client)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Flutter Platform](https://img.shields.io/badge/Platform-Flutter-blue.svg)](https://flutter.dev)

A Flutter client package for Better Auth, enabling seamless authentication with Next.js backends. This package provides a type-safe, reactive authentication client that mirrors the Better Auth React client experience.

## Features

- **Email/Password Authentication**: Sign in and sign up with email and password
- **Session Management**: Get, list, and revoke sessions
- **OAuth Integration**: Support for OAuth providers (Google, GitHub, etc.)
- **Account Management**: Update profile, change password, delete account
- **Reactive State**: ValueNotifier-based session state for UI updates
- **Secure Storage**: Automatic token storage using flutter_secure_storage
- **Error Handling**: Comprehensive error handling with typed error responses
- **Input Validation**: Built-in validators for common input fields

## Getting Started

### Prerequisites

- Flutter 3.10.0 or higher
- Dart 3.0.0 or higher
- A Next.js backend running [Better Auth](https://www.better-auth.com/)

### Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  better_auth_client: ^1.0.0
```

Then run:

```bash
flutter pub get
```

### Server-Side Configuration

Ensure your Better Auth backend is configured for mobile authentication:

```typescript:auth.ts
import { betterAuth } from "better-auth";
import { bearer } from "better-auth/plugins";

export const auth = betterAuth({
    plugins: [
        bearer()
    ],
    trustedOrigins: [
        "http://localhost:3000",
        "myapp://auth-callback",
    ],
    cors: {
        origin: [
            "http://localhost:3000",
            "myapp://auth-callback",
        ],
        credentials: true,
    },
});
```

## Usage

### Basic Setup

```dart
import 'package:better_auth_client/better_auth_client.dart';

final authClient = BetterAuthClient(
  baseUrl: String.fromEnvironment('BETTER_AUTH_URL', defaultValue: 'http://localhost:3000'),
);
```

### Sign In

```dart
final response = await authClient.signIn.email(
  email: 'user@example.com',
  password: 'password123',
);

if (response.isSuccess) {
  print('Signed in as: ${response.data!.user.email}');
} else {
  print('Error: ${response.error!.message}');
}
```

### Reactive Session Management

```dart
// Listen to session changes
ValueListenableBuilder<Session?>(
  valueListenable: authClient.sessionNotifier,
  builder: (context, session, child) {
    if (session == null) {
      return LoginPage();
    }
    return HomePage(session: session);
  },
);

// Get current session
final session = authClient.currentSession;
```

### Sign Out

```dart
await authClient.signOut();
```

### Session Management

```dart
// Get current session
final response = await authClient.session.get();

// List all sessions
final sessions = await authClient.session.list();

// Revoke other sessions
await authClient.session.revokeOthers();
```

### OAuth Sign-In

```dart
final response = await authClient.oauth.signIn(
  provider: 'google',
  callbackUrlScheme: 'myapp',
);

if (response.isSuccess) {
  // OAuth sign-in successful
}
```

## API Reference

### BetterAuthClient

The main client class for authentication operations.

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `baseUrl` | `String` | The base URL of your Better Auth server |
| `currentSession` | `Session?` | The current session (synchronous access) |
| `sessionNotifier` | `ValueNotifier<Session?>` | ValueNotifier for reactive session updates |
| `signIn` | `SignInModule` | Module for sign-in operations |
| `signUp` | `SignUpModule` | Module for sign-up operations |
| `session` | `SessionModule` | Module for session management |
| `oauth` | `OAuthModule` | Module for OAuth operations |
| `account` | `AccountModule` | Module for account operations |

#### Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `getSession()` | `Future<AuthResponse<Session>>` | Fetches the current session from the server |
| `signOut()` | `Future<AuthResponse<void>>` | Signs out the current user |
| `dispose()` | `void` | Disposes of client resources |

### SignInModule

#### Methods

| Method | Parameters | Returns |
|--------|------------|---------|
| `email()` | `email: String`, `password: String` | `Future<AuthResponse<Session>>` |
| `otp()` | `email: String`, `otp: String` | `Future<AuthResponse<Session>>` |
| `anonymous()` | - | `Future<AuthResponse<Session>>` |

### SignUpModule

#### Methods

| Method | Parameters | Returns |
|--------|------------|---------|
| `email()` | `email: String`, `password: String`, `name: String?` | `Future<AuthResponse<User>>` |

### SessionModule

#### Methods

| Method | Parameters | Returns |
|--------|------------|---------|
| `get()` | - | `Future<AuthResponse<Session>>` |
| `list()` | - | `Future<AuthResponse<List<Session>>>` |
| `revoke()` | `sessionId: String` | `Future<AuthResponse<void>>` |
| `revokeOthers()` | - | `Future<AuthResponse<void>>` |

### OAuthModule

#### Methods

| Method | Parameters | Returns |
|--------|------------|---------|
| `signIn()` | `provider: String`, `callbackUrlScheme: String` | `Future<AuthResponse<Session>>` |

### AccountModule

#### Methods

| Method | Parameters | Returns |
|--------|------------|---------|
| `update()` | `name: String?`, `image: String?` | `Future<AuthResponse<User>>` |
| `changePassword()` | `newPassword: String`, `oldPassword: String?` | `Future<AuthResponse<void>>` |
| `delete()` | - | `Future<AuthResponse<void>>` |

## Error Handling

All methods return an `AuthResponse<T>` that contains either the data or an `AuthError`:

```dart
final response = await authClient.signIn.email(email: email, password: password);

if (response.isSuccess) {
  // Handle success
  final session = response.data!;
} else {
  // Handle error
  final error = response.error!;
  print('Error code: ${error.code}');
  print('Error message: ${error.message}');
}
```

### Common Error Codes

| Code | Description |
|------|-------------|
| `INVALID_CREDENTIALS` | Email or password is incorrect |
| `USER_NOT_FOUND` | No account with this email |
| `EMAIL_ALREADY_EXISTS` | Account already exists |
| `SESSION_EXPIRED` | Session has expired |
| `UNAUTHORIZED` | Not authorized to perform action |
| `VALIDATION_ERROR` | Validation failed |

## Custom Storage

You can provide a custom storage implementation:

```dart
final authClient = BetterAuthClient(
  baseUrl: baseUrl,
  storage: MyCustomStorage(),
);
```

## Example App

See the `example` directory for a complete example app demonstrating all features.

## Contributing

Contributions are welcome! Please read our [Code of Conduct](CODE_OF_CONDUCT.md) and [Contributing Guide](CONTRIBUTING.md) before submitting PRs.

## License

This package is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Dependencies

| Package | Description |
|---------|-------------|
| [dio](https://pub.dev/packages/dio) | HTTP client for API requests |
| [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage) | Secure storage for tokens |
| [flutter_web_auth_2](https://pub.dev/packages/flutter_web_auth_2) | OAuth authentication flow |
