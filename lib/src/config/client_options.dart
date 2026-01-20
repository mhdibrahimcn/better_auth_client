/// Options for customizing the behavior of the Better Auth client.
class ClientOptions {
  /// Whether to enable debug logging.
  final bool enableDebugLogging;

  /// Custom timeout for requests in seconds.
  final int timeoutSeconds;

  /// Whether to automatically refresh expired tokens.
  final bool autoRefreshToken;

  /// Creates a new [ClientOptions] instance.
  const ClientOptions({
    this.enableDebugLogging = false,
    this.timeoutSeconds = 30,
    this.autoRefreshToken = true,
  });

  /// Creates a copy with optional overrides.
  ClientOptions copyWith({
    bool? enableDebugLogging,
    int? timeoutSeconds,
    bool? autoRefreshToken,
  }) {
    return ClientOptions(
      enableDebugLogging: enableDebugLogging ?? this.enableDebugLogging,
      timeoutSeconds: timeoutSeconds ?? this.timeoutSeconds,
      autoRefreshToken: autoRefreshToken ?? this.autoRefreshToken,
    );
  }
}
