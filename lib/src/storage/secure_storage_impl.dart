import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'storage_interface.dart';

/// Secure storage implementation using flutter_secure_storage.
class SecureStorageImpl implements StorageInterface {
  final FlutterSecureStorage _storage;

  SecureStorageImpl({
    FlutterSecureStorage? storage,
  }) : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  @override
  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  @override
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  @override
  Future<bool> containsKey(String key) async {
    final containsKey = await _storage.containsKey(key: key);
    return containsKey;
  }
}
