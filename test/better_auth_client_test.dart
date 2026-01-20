import 'package:flutter_test/flutter_test.dart';
import 'package:better_auth_client/better_auth_client.dart';

void main() {
  group('User Model Tests', () {
    test('User fromJson creates correct User instance', () {
      final json = {
        'id': 'user_123',
        'email': 'test@example.com',
        'name': 'Test User',
        'image': 'https://example.com/image.png',
        'emailVerified': true,
        'role': 'user',
        'createdAt': '2024-01-01T00:00:00.000Z',
        'updatedAt': '2024-01-02T00:00:00.000Z',
        'metadata': {'key': 'value'},
      };

      final user = User.fromJson(json);

      expect(user.id, 'user_123');
      expect(user.email, 'test@example.com');
      expect(user.name, 'Test User');
      expect(user.image, 'https://example.com/image.png');
      expect(user.emailVerified, true);
      expect(user.role, 'user');
      expect(user.metadata, {'key': 'value'});
    });

    test('User toJson returns correct JSON', () {
      final user = User(
        id: 'user_123',
        email: 'test@example.com',
        name: 'Test User',
        createdAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
        updatedAt: DateTime.parse('2024-01-02T00:00:00.000Z'),
      );

      final json = user.toJson();

      expect(json['id'], 'user_123');
      expect(json['email'], 'test@example.com');
      expect(json['name'], 'Test User');
    });
  });

  group('Session Model Tests', () {
    test('Session fromJson creates correct Session instance', () {
      final json = {
        'id': 'session_123',
        'token': 'token_abc',
        'expiresAt': '2024-12-31T23:59:59.000Z',
        'ipAddress': '192.168.1.1',
        'userAgent': 'Flutter/1.0',
        'isCurrent': true,
        'createdAt': '2024-01-01T00:00:00.000Z',
        'user': {
          'id': 'user_123',
          'email': 'test@example.com',
          'createdAt': '2024-01-01T00:00:00.000Z',
          'updatedAt': '2024-01-02T00:00:00.000Z',
        },
      };

      final session = Session.fromJson(json);

      expect(session.id, 'session_123');
      expect(session.token, 'token_abc');
      expect(session.isCurrent, true);
      expect(session.user.id, 'user_123');
    });

    test('Session isExpired returns correct value', () {
      final expiredSession = Session(
        id: 'session_123',
        token: 'token_abc',
        expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
        user: User(
          id: 'user_123',
          email: 'test@example.com',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        createdAt: DateTime.now(),
      );

      final validSession = Session(
        id: 'session_456',
        token: 'token_def',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
        user: User(
          id: 'user_123',
          email: 'test@example.com',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        createdAt: DateTime.now(),
      );

      expect(expiredSession.isExpired, true);
      expect(validSession.isExpired, false);
    });
  });

  group('AuthResponse Tests', () {
    test('AuthResponse.success returns correct values', () {
      final session = Session(
        id: 'session_123',
        token: 'token_abc',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
        user: User(
          id: 'user_123',
          email: 'test@example.com',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        createdAt: DateTime.now(),
      );

      final response = AuthResponse.success(session);

      expect(response.isSuccess, true);
      expect(response.isError, false);
      expect(response.data, session);
      expect(response.error, null);
    });

    test('AuthResponse.error returns correct values', () {
      final error = AuthError(
        code: 'INVALID_CREDENTIALS',
        message: 'Invalid email or password',
      );

      final response = AuthResponse.error(error);

      expect(response.isSuccess, false);
      expect(response.isError, true);
      expect(response.data, null);
      expect(response.error, error);
    });

    test('getOrThrow throws on error', () {
      final error = AuthError(
        code: 'TEST_ERROR',
        message: 'Test error message',
      );

      final response = AuthResponse.error(error);

      expect(() => response.getOrThrow(), throwsA(isA<AuthError>()));
    });

    test('getOrNull returns null on error', () {
      final error = AuthError(
        code: 'TEST_ERROR',
        message: 'Test error message',
      );

      final response = AuthResponse.error(error);

      expect(response.getOrNull(), null);
    });

    test('getOrDefault returns default on error', () {
      final error = AuthError(
        code: 'TEST_ERROR',
        message: 'Test error message',
      );

      final response = AuthResponse.error(error);

      expect(response.getOrDefault('default'), 'default');
    });
  });

  group('AuthError Tests', () {
    test('AuthError constants have correct values', () {
      expect(AuthError.invalidCredentials.code, 'INVALID_CREDENTIALS');
      expect(AuthError.userNotFound.code, 'USER_NOT_FOUND');
      expect(AuthError.emailAlreadyExists.code, 'EMAIL_ALREADY_EXISTS');
      expect(AuthError.sessionExpired.code, 'SESSION_EXPIRED');
      expect(AuthError.unauthorized.code, 'UNAUTHORIZED');
    });

    test('AuthError validation factory creates correct error', () {
      final errors = {'email': 'Invalid email'};
      final error = AuthError.validation(errors);

      expect(error.code, 'VALIDATION_ERROR');
      expect(error.message, 'Validation failed');
      expect(error.details, errors);
    });
  });

  group('InMemoryStorage Tests', () {
    test('InMemoryStorage read/write operations work correctly', () async {
      final storage = InMemoryStorage();

      await storage.write('key1', 'value1');
      expect(await storage.read('key1'), 'value1');

      await storage.write('key1', 'value2');
      expect(await storage.read('key1'), 'value2');

      await storage.delete('key1');
      expect(await storage.read('key1'), null);
    });

    test('InMemoryStorage containsKey works correctly', () async {
      final storage = InMemoryStorage();

      await storage.write('existingKey', 'value');
      expect(await storage.containsKey('existingKey'), true);
      expect(await storage.containsKey('nonExistingKey'), false);
    });
  });

  group('Validators Tests', () {
    test('validateEmail returns null for valid email', () {
      expect(Validators.validateEmail('test@example.com'), null);
    });

    test('validateEmail returns error for invalid email', () {
      expect(Validators.validateEmail('invalid'), isNotNull);
      expect(Validators.validateEmail(''), isNotNull);
      expect(Validators.validateEmail(null), isNotNull);
    });

    test('validatePassword returns null for valid password', () {
      expect(Validators.validatePassword('password123'), null);
    });

    test('validatePassword returns error for short password', () {
      expect(Validators.validatePassword('short'), isNotNull);
    });

    test('validatePasswordConfirmation returns null for matching passwords', () {
      expect(Validators.validatePasswordConfirmation('password123', 'password123'), null);
    });

    test('validatePasswordConfirmation returns error for mismatched passwords', () {
      expect(Validators.validatePasswordConfirmation('password123', 'different'), isNotNull);
    });
  });
}
