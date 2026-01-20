/// Abstract interface for storage operations.
///
/// This interface defines the contract for storing and retrieving
/// authentication-related data. Implement this interface to provide
/// custom storage solutions.
///
/// ## Example Implementation
///
/// ```dart
/// class MyStorage implements StorageInterface {
///   final _storage = <String, String>{};
///
///   @override
///   Future<String?> read(String key) async => _storage[key];
///
///   @override
///   Future<void> write(String key, String value) async => _storage[key] = value;
///
///   @override
///   Future<void> delete(String key) async => _storage.remove(key);
///
///   @override
///   Future<bool> containsKey(String key) async => _storage.containsKey(key);
/// }
/// ```
///
/// See also:
/// - [SecureStorageImpl] for the default implementation
abstract class StorageInterface {
  /// Reads a value from storage.
  ///
  /// [key] The key to read.
  ///
  /// Returns the stored value, or null if not found.
  Future<String?> read(String key);

  /// Writes a value to storage.
  ///
  /// [key] The key to write.
  /// [value] The value to store.
  Future<void> write(String key, String value);

  /// Deletes a value from storage.
  ///
  /// [key] The key to delete.
  Future<void> delete(String key);

  /// Checks if a key exists.
  ///
  /// [key] The key to check.
  ///
  /// Returns true if the key exists, false otherwise.
  Future<bool> containsKey(String key);
}

/// In-memory storage for testing purposes.
///
/// This implementation stores data in memory and is useful for unit tests
/// where persistent storage is not needed.
///
/// Note: Data is lost when the object is garbage collected.
class InMemoryStorage implements StorageInterface {
  final _storage = <String, String>{};

  @override
  Future<void> delete(String key) async {
    _storage.remove(key);
  }

  @override
  Future<bool> containsKey(String key) async {
    return _storage.containsKey(key);
  }

  @override
  Future<String?> read(String key) async {
    return _storage[key];
  }

  @override
  Future<void> write(String key, String value) async {
    _storage[key] = value;
  }
}
