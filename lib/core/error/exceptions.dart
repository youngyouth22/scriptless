/// Exception thrown when a server/network operation fails.
class ServerException implements Exception {
  /// Creates a [ServerException].
  const ServerException({
    required this.message,
    this.statusCode,
  });

  /// Human-readable description of the error.
  final String message;

  /// Optional HTTP status code.
  final int? statusCode;

  @override
  String toString() => 'ServerException: $message (Status Code: $statusCode)';
}

/// Wrapper around Supabase `AuthException` for domain-layer use.
class AuthExceptionWrapper implements Exception {
  /// Creates an [AuthExceptionWrapper].
  const AuthExceptionWrapper({required this.message});

  /// Human-readable description of the auth error.
  final String message;

  @override
  String toString() => 'AuthException: $message';
}
