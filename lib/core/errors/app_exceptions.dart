abstract class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, [this.code]);

  @override
  String toString() => message;
}

class ValidationException extends AppException {
  const ValidationException(String message) : super(message, 'validation_error');
}

class AuthenticationException extends AppException {
  const AuthenticationException(String message, [String? code])
      : super(message, code);
}

class NetworkException extends AppException {
  const NetworkException(String message) : super(message, 'network_error');
}

class ServerException extends AppException {
  const ServerException(String message) : super(message, 'server_error');
}

class UserNotFoundException extends AppException {
  const UserNotFoundException(String message) : super(message, 'user_not_found');
}