import 'package:dio/dio.dart';
import '../../models/auth_response.dart';
import '../../models/auth_error.dart';
import '../../models/user.dart';
import '../../storage/storage_interface.dart';
import '../../utils/constants.dart';

/// Module for handling account operations.
///
/// This module provides methods for users to manage their own account,
/// including updating profile information, changing passwords, and deleting accounts.
///
/// Obtain an instance from [BetterAuthClient.account]:
/// ```dart
/// final response = await authClient.account.update(name: 'New Name');
/// ```
class AccountModule {
  final Dio _dio;
  final StorageInterface _storage;

  /// Creates a new [AccountModule] instance.
  ///
  /// Typically, you won't create this directly. Use [BetterAuthClient.account] instead.
  AccountModule(this._dio, this._storage);

  /// Updates the current user's account information.
  ///
  /// [name] The new display name (optional).
  /// [image] The new profile image URL (optional).
  ///
  /// Returns an [AuthResponse] containing the updated [User] on success.
  ///
  /// Example:
  /// ```dart
  /// final response = await authClient.account.update(
  ///   name: 'John Doe',
  ///   image: 'https://example.com/avatar.jpg',
  /// );
  ///
  /// if (response.isSuccess) {
  ///   print('Profile updated: ${response.data!.name}');
  /// }
  /// ```
  Future<AuthResponse<User>> update({
    String? name,
    String? image,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.updateAccount,
        data: {
          if (name != null) 'name': name,
          if (image != null) 'image': image,
        },
      );

      final user = User.fromJson(response.data['user'] ?? response.data);
      return AuthResponse.success(user);
    } on DioException catch (e) {
      return AuthResponse.error(AuthError.fromDio(e));
    }
  }

  /// Changes the user's password.
  ///
  /// [newPassword] The new password (required).
  /// [oldPassword] The current password (optional, depends on server config).
  ///
  /// Returns an [AuthResponse] indicating success or failure.
  ///
  /// Example:
  /// ```dart
  /// final response = await authClient.account.changePassword(
  ///   newPassword: 'newPassword123',
  ///   oldPassword: 'oldPassword123',
  /// );
  ///
  /// if (response.isSuccess) {
  ///   print('Password changed successfully');
  /// }
  /// ```
  Future<AuthResponse<void>> changePassword({
    required String newPassword,
    String? oldPassword,
  }) async {
    try {
      await _dio.post(
        ApiEndpoints.changePassword,
        data: {
          'newPassword': newPassword,
          if (oldPassword != null) 'oldPassword': oldPassword,
        },
      );
      return AuthResponse.success(null);
    } on DioException catch (e) {
      return AuthResponse.error(AuthError.fromDio(e));
    }
  }

  /// Deletes the current user's account.
  ///
  /// This action is irreversible. Use with caution.
  ///
  /// Returns an [AuthResponse] indicating success or failure.
  ///
  /// Example:
  /// ```dart
  /// final response = await authClient.account.delete();
  ///
  /// if (response.isSuccess) {
  ///   print('Account deleted');
  /// }
  /// ```
  Future<AuthResponse<void>> delete() async {
    try {
      await _dio.post(ApiEndpoints.deleteAccount);
      return AuthResponse.success(null);
    } on DioException catch (e) {
      return AuthResponse.error(AuthError.fromDio(e));
    }
  }
}
