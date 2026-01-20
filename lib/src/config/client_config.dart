import 'client_options.dart';

/// Configuration class for the Better Auth client.
class ClientConfig {
  /// The base URL for API requests
  final String baseUrl;

  /// Additional options for the client
  final ClientOptions options;

  /// Creates a new ClientConfig instance.
  ClientConfig({
    required this.baseUrl,
    this.options = const ClientOptions(),
  });

  /// Gets the full URL for an API endpoint
  String getEndpointUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }
}
