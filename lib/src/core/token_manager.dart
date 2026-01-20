import '../storage/storage_interface.dart';
import '../utils/constants.dart';

/// Manages authentication tokens securely.
class TokenManager {
  final StorageInterface _storage;

  TokenManager(this._storage);

  /// Gets the current access token.
  Future<String?> getAccessToken() async {
    return await _storage.read(StorageKeys.accessToken);
  }

  /// Saves the access token.
  Future<void> setAccessToken(String token) async {
    await _storage.write(StorageKeys.accessToken, token);
  }

  /// Gets the current refresh token.
  Future<String?> getRefreshToken() async {
    return await _storage.read(StorageKeys.refreshToken);
  }

  /// Saves the refresh token.
  Future<void> setRefreshToken(String token) async {
    await _storage.write(StorageKeys.refreshToken, token);
  }

  /// Clears all tokens.
  Future<void> clearTokens() async {
    await _storage.delete(StorageKeys.accessToken);
    await _storage.delete(StorageKeys.refreshToken);
  }

  /// Checks if user has valid tokens.
  Future<bool> hasValidSession() async {
    final accessToken = await _storage.read(StorageKeys.accessToken);
    return accessToken != null && accessToken.isNotEmpty;
  }
}
